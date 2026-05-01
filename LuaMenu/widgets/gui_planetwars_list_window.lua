--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
	return {
		name      = "Planetwars List Window",
		desc      = "Handles planetwars battle list display.",
		author    = "GoogleFrog",
		date      = "7 March 2017",
		license   = "GNU LGPL, v2.1 or later",
		layer     = -100000,
		enabled   = true  --  loaded by default?
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Variables

local planetwarsSoon = false
local planetwarsEnabled = false
local planetwarsLevelRequired = false

local IMG_LINK = LUA_DIRNAME .. "images/link.png"

local panelInterface
local PLANET_NAME_LENGTH = 450
local FACTION_SPACING = 134
local LIST_PHASE_FRACTIONS = false

local phaseTimer
local requiredGame = false

local URGENT_ATTACK_TIME = 3000 -- Fifty minutes
local attackUrgent = false

local MISSING_ENGINE_TEXT = "Game engine update required, restart the menu to apply."
local MISSING_GAME_TEXT = "Game version update required. Wait for a download or restart to apply it immediately."
local PW_SOON_TEXT = "Planetwars is starting soon. "

local updates = 0

local ATTACKER_SOUND = "sounds/marker_place.wav"
local DEFENDER_SOUND = "sounds/alarm.wav"

local DoUnMatchedActivityUpdate -- Activity update function

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Utilities

local function HexToColorString(hex)
	return Engine.textColorCodes.Color .. string.char(
		tonumber(hex:sub(2, 3), 16) or 255,
		tonumber(hex:sub(4, 5), 16) or 255,
		tonumber(hex:sub(6, 7), 16) or 255
	)
end

local function HaveRightEngineVersion()
	local configuration = WG.Chobby.Configuration
	if configuration.useWrongEngine then
		return true
	end
	local engineVersion = WG.LibLobby.lobby:GetSuggestedEngineVersion()
	return (not engineVersion) or configuration:IsValidEngineVersion(engineVersion)
end

local function HaveRightGameVersion()
	if not requiredGame then
		return false
	end
	local haveGame = VFS.HasArchive(requiredGame)
	return haveGame
end

local function TryToJoinPlanet(planetData)
	local lobby = WG.LibLobby.lobby

	local mapName = planetData.Map
	if not VFS.HasArchive(mapName) then
		queuePlanetJoin = planetData
		WG.DownloadHandler.MaybeDownloadArchive(mapName, "map", -1)
		WG.Chobby.InformationPopup("Map download required to attack planet. Please wait.")
		return
	end
	queuePlanetJoin = nil

	if not HaveRightEngineVersion() then
		WG.Chobby.InformationPopup("Game engine update required, restart the menu to apply.")
		return
	end

	if not HaveRightGameVersion() then
		WG.Chobby.InformationPopup("Game version update required, restart the menu to apply.")
		return
	end

	lobby:PwJoinPlanet(planetData.PlanetID, planetData.AttackerFaction)
	if panelInterface then
		panelInterface.SetPlanetJoined(planetData.PlanetID, planetData.AttackerFaction)
	end
	WG.Analytics.SendOnetimeEvent("lobby:multiplayer:planetwars:join_site")
end

local function GetAttackingOrDefending(lobby, attackerFactions, defenderFactions, currentMode)
	local myFaction = lobby:GetMyFaction()
	if defenderFactions and #defenderFactions > 0 then
		return false, true
	elseif attackerFactions and #attackerFactions > 0 then
		return true, false
	end
	--local attackPhase = false
	--local defendPhase = false
	--if attackerFactions then
	--	for i = 1, #attackerFactions do
	--		if myFaction == attackerFactions[i] then
	--			attackPhase = true
	--			break
	--		end
	--	end
	--end
	--if defenderFactions then
	--	for i = 1, #defenderFactions do
	--		if myFaction == defenderFactions[i] then
	--			defendPhase = true
	--			break
	--		end
	--	end
	--end
	--return attackPhase, defendPhase
	return false, false
end

local function IsPhaseUrgent()
	local timeRemaining = phaseTimer and phaseTimer.GetTimeRemaining()
	return timeRemaining and timeRemaining < URGENT_ATTACK_TIME
end

local function FindMatchingPlanet(planetID, planetAttacker, planets)
	if not planetID then
		return false
	end
	for i = 1, #planets do
		if planets[i].PlanetID == planetID and planets[i].AttackerFaction == planetAttacker then
			return planets[i]
		end
	end
	return false
end

local function GetActivityToPrompt(lobby, attackerFactions, defenderFactions, currentMode, planets)
	if not (planets and planets[1]) then
		return false
	end
	local activePlanet = lobby.planetwarsData.attackingPlanet or lobby.planetwarsData.defendingPlanet
	local activePlanetAttacker = lobby.planetwarsData.attackingPlanetAttacker or lobby.planetwarsData.defendingPlanetAttacker
	if currentMode == lobby.PW_DEFEND and activePlanet then
		local myPlanet = FindMatchingPlanet(activePlanet, activePlanetAttacker, planets)
		if myPlanet then
			return myPlanet, true, true, true
		end
		return false
	end
	local attackPhase = (currentMode == lobby.PW_ATTACK)
	if currentMode == lobby.PW_DEFEND and activePlanet then
		local myPlanet = FindMatchingPlanet(activePlanet, activePlanetAttacker, planets)
		if myPlanet then
			return myPlanet, attackPhase, true, not attackPhase
		end
	end
	
	if attackPhase and lobby.planetwarsData.charges == 0 then
		return false -- Cannot attack with no charges
	end

	if IsPhaseUrgent() then
		local targetPlanet, minMissing
		for i = 1, #planets do
			if planets[i].CanSelectForBattle then
				local missing = planets[i].Needed - planets[i].Count
				if missing > 0 and ((not minMissing) or (missing < minMissing)) then
					targetPlanet = planets[i]
					minMissing = missing
				end
			end
		end
		return targetPlanet, attackPhase
	else
		for i = 1, #planets do
			if planets[i].CanSelectForBattle and planets[i].Count + 1 == planets[i].Needed then
				return planets[i], attackPhase
			end
		end
	end
	return false
end

local function ListToString(list)
	local outStr = ""
	for i = 1, #list do
		if i == #list then
			outStr = outStr .. list[i]
		else
			outStr = outStr .. list[i] .. ", "
		end
	end
	return outStr
end

local function HasAttackCharges()
	return (WG.LibLobby.lobby:GetPlanetwarsData().charges or 0) > 0
end

local function GetAttackingPlanet()
	local myAttack, myFactionAttack = false, false
	local planets = WG.LibLobby.lobby:GetPlanetwarsData().planets
	local myFaction = WG.LibLobby.lobby:GetMyFaction()
	if not (planets and myFaction) then
		return false, false
	end
	for i = 1, #planets do
		local planetData = planets[i]
		if planetData.AttackerFaction == myFaction then
			myFactionAttack = true
		end
		if planetData.PlayerIsAttacker then
			myAttack = planetData.PlanetName
		end
	end
	return myAttack, myFactionAttack
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Timing

local function GetPhaseTimer()
	local deadlineSeconds
	local startTimer

	local externalFunctions = {}

	function externalFunctions.SetNewDeadline(newDeadlineSeconds)
		deadlineSeconds = newDeadlineSeconds
		startTimer = Spring.GetTimer()
	end

	function externalFunctions.GetTimeRemaining()
		if not deadlineSeconds then
			return false
		end
		return math.max(0, deadlineSeconds - math.ceil(Spring.DiffTimers(Spring.GetTimer(), startTimer)))
	end

	return externalFunctions
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Extended Controls

local function GetLinkButton(holder, x, y, width, text, link)
	local config = WG.Chobby.Configuration

	local btnLink = Button:New {
		x = x,
		y = t,
		width = width,
		height = 24,
		classname = "button_square",
		caption = "",
		padding = {0, 0, 0, 0},
		parent = holder,
		OnClick = {
			function ()
				WG.BrowserHandler.OpenUrl(link)
			end
		},
		--tooltip = link,
	}
	local tbText = TextBox:New {
		x = 2,
		y = 3,
		right = 20,
		align = "left",
		objectOverrideFont = config:GetFont(3),
		parent = btnLink,
	}
	local imgLink = Image:New {
		x = 0,
		y = 4,
		width = 18,
		height = 18,
		keepAspect = true,
		file = IMG_LINK,
		parent = btnLink,
	}

	local externalFunctions = {}

	function externalFunctions.SetText(newText)
		newText = StringUtilities.GetTruncatedStringWithDotDot(newText, tbText.font, width - 24)
		tbText:SetText(newText)
		local length = tbText.font:GetTextWidth(newText)
		imgLink:SetPos(length + 7)
	end

	function externalFunctions.GetControl()
		return btnLink
	end

	-- Initialization
	externalFunctions.SetText(text)

	return externalFunctions
end

local function GetPlanetImage(holder, x, y, size, planetImage, structureList)
	local children = {}

	if structureList then
		for i = 1, #structureList do
			children[#children + 1] = Image:New {
				x = 0,
				y = 0,
				right = 0,
				bottom = 0,
				keepAspect = true,
				file = "LuaMenu/images/structures/" .. structureList[i],
			}
		end
	end

	local planetImageControl

	if planetImage then
		planetImageControl = Image:New {
			x = "25%",
			y = "25%",
			right = "25%",
			bottom = "25%",
			keepAspect = true,
			file = "LuaMenu/images/planets/" .. planetImage,
		}
		children[#children + 1] = planetImageControl
	end

	local imagePanel = Panel:New {
		classname = "panel_light",
		x = x,
		y = y,
		width = size,
		height = size,
		padding = {1,1,1,1},
		children = children,
		parent = holder,
	}

	return imagePanel
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Battle Nagger

local function InitializeActivityPromptHandler()
	local lobby = WG.LibLobby.lobby
	local Configuration = WG.Chobby.Configuration
	local planetData

	local planetID
	local planetImage
	local planetImageSize = 77
	local oldIsAttacker = false
	local newNotification = true

	local holder = Panel:New {
		x = 0,
		y = 0,
		right = 0,
		bottom = 0,
		classname = "overlay_panel",
		padding = {0,0,0,0},
		caption = "",
		resizable = false,
		draggable = false,
	}

	local button = Button:New {
		name = "join",
		x = "70%",
		right = 4,
		y = 4,
		bottom = 4,
		padding = {0,0,0,0},
		caption = "Join",
		objectOverrideFont = Configuration:GetButtonFont(3),
		classname = "action_button",
		OnClick = {
			function()
				if planetData then
					TryToJoinPlanet(planetData)
				end
			end
		},
		parent = holder,
	}

	local bottomBound = 5
	local bigMode = true

	local planetStatusTextBox = TextBox:New {
		x = 20,
		y = 18,
		width = 195,
		height = 20,
		objectOverrideFont = Configuration:GetFont(2),
		text = "",
		parent = holder
	}
	local battleStatusTextBox = TextBox:New {
		x = 38,
		y = 18,
		width = 195,
		height = 20,
		objectOverrideFont = Configuration:GetFont(2),
		text = "",
		parent = holder
	}
	local battleStatusText = ""

	local seperator = Line:New {
		x = 0,
		y = 25,
		width = 195,
		height = 2,
		parent = holder
	}

	local oldXSize, oldYSize
	local function Resize(obj, xSize, ySize)
		if xSize then
			oldXSize, oldYSize = xSize, ySize
		elseif not oldXSize then
			return
		else
			xSize, ySize = oldXSize, oldYSize
		end
		local statusX, statusWidth = 2, 195
		planetImageSize = ySize - 2
		if planetImage then
			planetImage:SetPos(1, 1, planetImageSize, planetImageSize)
			statusX = ySize - 5
		end

		if ySize < 60 then
			planetStatusTextBox:SetPos(statusX + xSize/4 - 52, 2, statusWidth)
			seperator:SetPos(statusX + xSize/4 - 60, 14, statusWidth)
			battleStatusTextBox:SetPos(statusX + xSize/4 - 52, 20, statusWidth)
			bigMode = false
		else
			planetStatusTextBox:SetPos(statusX + xSize/4 - 62, 18, statusWidth)
			seperator:SetPos(statusX + xSize/4 - 70, 34, statusWidth)
			battleStatusTextBox:SetPos(statusX + xSize/4 - 62, 44, statusWidth)
			bigMode = true
		end
	end

	local function PossiblyPlayWarning(isAttacker)
		if (not newNotification) and isAttacker == oldIsAttacker then
			return
		end
		newNotification = false
		oldIsAttacker = isAttacker
		if not Configuration.planetwarsNotifications2 then
			return
		end
		if WG.WrapperLoopback then
			if isAttacker then
				WG.WrapperLoopback.Alert("Planetwars: attack a planet.")
			else
				WG.WrapperLoopback.Alert("Planetwars: defense required!")
			end
		end

		local snd_volui = Spring.GetConfigString("snd_volui")
		local snd_volmaster = Spring.GetConfigString("snd_volmaster")
		-- These are defaults. Should be audible enough.
		Spring.SetConfigString("snd_volui", 100)
		Spring.SetConfigString("snd_volmaster", 60)
		if Configuration.menuNotificationVolume ~= 0 then
			Spring.PlaySoundFile((isAttacker and ATTACKER_SOUND) or DEFENDER_SOUND, Configuration.menuNotificationVolume or 1, "ui")
		end
		WG.Delay(function()
			Spring.SetConfigString("snd_volui", snd_volui)
			Spring.SetConfigString("snd_volmaster", snd_volmaster)
		end, 10)
	end

	holder.OnResize = {Resize}

	local externalFunctions = {}

	local oldTimeRemaing = ""
	function externalFunctions.UpdateTimer(forceUpdate)
		local timeRemaining = phaseTimer.GetTimeRemaining()
		timeRemaining = (timeRemaining and Spring.Utilities.FormatTime(timeRemaining, false)) or ""
		if timeRemaining == oldTimeRemaing and (not forceUpdate) then
			return
		end
		oldTimeRemaing = timeRemaining

		battleStatusTextBox:SetText(battleStatusText .. timeRemaining)
	end

	function externalFunctions.SetActivity(newPlanetData, isAttacker, alreadyJoined, waitingForAllies)
		planetData = newPlanetData
		PossiblyPlayWarning(isAttacker)
		if alreadyJoined then
			if isAttacker then
				planetStatusTextBox:SetText("Attacking: " .. planetData.PlanetName)
				if waitingForAllies then
					battleStatusText = "Attackers " .. newPlanetData.Count .. "/" .. newPlanetData.Needed .. ", "
				else
					battleStatusText = "Defenders " .. newPlanetData.Count .. "/" .. newPlanetData.Needed .. ", "
				end
			else
				planetStatusTextBox:SetText("Defending: " .. planetData.PlanetName)
				battleStatusText = "Defenders " .. newPlanetData.Count .. "/" .. newPlanetData.Needed .. ", "
			end
		else
			if isAttacker then
				planetStatusTextBox:SetText("Attack: " .. planetData.PlanetName)
				battleStatusText = "Players " .. newPlanetData.Count .. "/" .. newPlanetData.Needed .. ", "
			else
				planetStatusTextBox:SetText("Defend: " .. planetData.PlanetName)
				battleStatusText = "Players " .. newPlanetData.Count .. "/" .. newPlanetData.Needed .. ", "
			end
		end

		externalFunctions.UpdateTimer(true)

		button:SetVisibility(not alreadyJoined)

		if alreadyJoined then
			if planetID ~= newPlanetData.PlanetID then
				if planetImage then
					planetImage:Dispose()
				end
				planetImage = GetPlanetImage(holder, 1, 1, planetImageSize, newPlanetData.PlanetImage, newPlanetData.StructureImages)
			end
		elseif planetImage then
			planetImage:Dispose()
			planetImage = nil
		end

		Resize()
	end

	function externalFunctions.NotifyHidden()
		newNotification = true
	end

	function externalFunctions.GetHolder()
		return holder
	end

	return externalFunctions
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Planet List

local function MakePlanetControl(planetData, DeselectOtherFunc, attackPhase, defendPhase)
	local Configuration = WG.Chobby.Configuration
	local lobby = WG.LibLobby.lobby

	local config = WG.Chobby.Configuration
	local planetName = planetData.PlanetName
	local mapName = planetData.Map
	local planetID = planetData.PlanetID
	local planetAttacker = planetData.AttackerFaction
	local canSelectPlanet = planetData.CanSelectForBattle
	local owner = (planetData.OwnerFaction == lobby:GetMyFaction())
	local myAttacking = planetData.PlayerIsAttacker
	local myDefending = planetData.PlayerIsDefender

	local joinedBattle = myAttacking or myDefending
	local downloading = false
	local currentPlayers = planetData.Count or 0
	local maxPlayers = planetData.Needed or 0

	local btnJoin, btnLeave

	local holder = Panel:New {
		x = 0,
		y = 0,
		width = "100%",
		resizable = false,
		draggable = false,
		padding = {0, 0, 0, 0},
	}

	local planetImage = GetPlanetImage(holder, 2, 2, 86, planetData.PlanetImage, planetData.StructureImages)

	local minimapPanel = Panel:New {
		x = 100,
		y = 5,
		width = 26,
		height = 26,
		padding = {1,1,1,1},
		parent = holder,
	}
	local btnMinimap = Button:New {
		x = 0,
		y = 0,
		right = 0,
		bottom = 0,
		classname = "button_square",
		caption = "",
		parent = minimapPanel,
		padding = {1,1,1,1},
		OnClick = {
			function ()
				if mapName and config.gameConfig.link_particularMapPage ~= nil then
					WG.BrowserHandler.OpenUrl(config.gameConfig.link_particularMapPage(mapName))
				end
			end
		},
	}

	local mapImageFile, needDownload = config:GetMinimapSmallImage(mapName)
	local imMinimap = Image:New {
		x = 0,
		y = 0,
		right = 0,
		bottom = 0,
		keepAspect = true,
		file = mapImageFile,
		fallbackFile = Configuration:GetLoadingImage(2),
		checkFileExists = needDownload,
		parent = btnMinimap,
	}

	local btnPlanetLink = Button:New {
		x = 130,
		y = WG.TOP_BUTTON_Y,
		width = PLANET_NAME_LENGTH,
		height = 24,
		classname = "button_square",
		caption = "",
		padding = {0, 0, 0, 0},
		parent = holder,
		OnClick = {
			function ()
				WG.BrowserHandler.OpenUrl("https://zero-k.info/Planetwars/Planet/" .. planetID)
			end
		}
	}
	local tbPlanetName = TextBox:New {
		x = 2,
		y = 3,
		right = 20,
		align = "left",
		objectOverrideFont = config:GetFont(3),
		parent = btnPlanetLink,
	}
	local imgPlanetLink = Image:New {
		x = 0,
		y = 4,
		width = 18,
		height = 18,
		keepAspect = true,
		file = IMG_LINK,
		parent = btnPlanetLink,
	}

	local playerCaption = TextBox:New {
		name = "missionName",
		x = 270,
		y = 55,
		width = 480,
		height = 20,
		valign = 'center',
		objectOverrideFont = Configuration:GetFont(3),
		text = "0/0",
		parent = holder,
	}

	local function SetPlanetName(planet)
		local newPlanetName = planet.PlanetName
		newPlanetName = StringUtilities.GetTruncatedStringWithDotDot(newPlanetName, tbPlanetName.font, PLANET_NAME_LENGTH - 24)
		if defendPhase and planet.AttackerAvgWhr then
			local skill = math.floor((planet.AttackerAvgWhr + 50)/100)*100
			newPlanetName = newPlanetName .. string.format(" (skill %d)", skill)
		end
		local factionData = planet.OwnerFaction and lobby:GetFactionData(planet.OwnerFaction)
		if factionData and factionData.Color then
			newPlanetName = HexToColorString(factionData.Color) .. newPlanetName
		end
		tbPlanetName:SetText(newPlanetName)
		local length = tbPlanetName.font:GetTextWidth(newPlanetName)
		imgPlanetLink:SetPos(length + 7)
		planetName = newPlanetName
	end

	local function UpdateCaptions()
		if myAttacking and defendPhase then
			playerCaption:SetText("You are attacking - Defenders: " .. currentPlayers .. "/" .. maxPlayers)
		elseif joinedBattle and not (myAttacking and defendPhase) then
			playerCaption:SetText("Joined - Waiting for players: " .. currentPlayers .. "/" .. maxPlayers)
		else
			playerCaption:SetText(currentPlayers .. "/" .. maxPlayers)
		end
	end

	local function UpdateJoinButton()
		local showButton = false
		if not joinedBattle and canSelectPlanet then
			playerCaption:SetPos(270)
			local needMap = not VFS.HasArchive(mapName)
			if needMap then
				showButton = true
				if downloading then
					btnJoin:SetCaption(i18n("downloading"))
				else
					btnJoin:SetCaption(i18n("download_map"))
				end
			elseif HasAttackCharges() or defendPhase then
				showButton = true
				if attackPhase then
					btnJoin:SetCaption(i18n("attack_planet"))
				elseif defendPhase then
					btnJoin:SetCaption(i18n("defend_planet"))
				else
					btnJoin:SetCaption("???")
				end
			end
		end
		
		UpdateCaptions()
		playerCaption:SetPos(showButton and 270 or 104)
		btnJoin:SetVisibility(showButton)
		btnLeave:SetVisibility(joinedBattle and not (myAttacking and defendPhase))
	end

	btnJoin = Button:New {
		x = 100,
		width = 160,
		bottom = 6,
		height = WG.BUTTON_HEIGHT,
		caption = i18n("defend_planet"),
		objectOverrideFont = Configuration:GetButtonFont(3),
		classname = "option_button",
		OnClick = {
			function(obj)
				if not VFS.HasArchive(mapName) then
					if not downloading then
						WG.DownloadHandler.MaybeDownloadArchive(mapName, "map", -1)
						downloading = true
						UpdateJoinButton()
					end
					return
				end

				if not HaveRightEngineVersion() then
					WG.Chobby.InformationPopup("Engine update required, restart the game to apply.")
					return
				end

				if not HaveRightGameVersion() then
					WG.Chobby.InformationPopup("Version update required, restart the game to apply.")
					return
				end

				joinedBattle = true
				lobby:PwJoinPlanet(planetID, planetAttacker)
				UpdateJoinButton()
				DeselectOtherFunc(planetID)
				WG.Analytics.SendOnetimeEvent("lobby:multiplayer:planetwars:join")
			end
		},
		parent = holder
	}

	btnLeave = Button:New {
		x = 430,
		width = 80,
		bottom = 6,
		height = WG.BUTTON_HEIGHT,
		caption = i18n("leave"),
		objectOverrideFont = Configuration:GetButtonFont(3),
		classname = "negative_button",
		OnClick = {
			function(obj)
				joinedBattle = false
				lobby:PwCancel()
				UpdateJoinButton()
			end
		},
		parent = holder
	}

	-- Initialization
	SetPlanetName(planetData)
	UpdateJoinButton()

	local externalFunctions = {}

	function externalFunctions.UpdatePlanetControl(newPlanetData, newAttackPhase, newDefendPhase, resetJoinedBattle)
		mapName = newPlanetData.Map
		currentPlayers = newPlanetData.Count or 0
		maxPlayers = newPlanetData.Needed or 0

		if resetJoinedBattle then
			joinedBattle = false
		end

		planetAttacker = newPlanetData.AttackerFaction
		canSelectPlanet = newPlanetData.CanSelectForBattle
		owner = (newPlanetData.OwnerFaction == lobby:GetMyFaction())
		attackPhase, defendPhase = newAttackPhase, newDefendPhase
		myAttacking = newPlanetData.PlayerIsAttacker
		myDefending = newPlanetData.PlayerIsDefender
		joinedBattle = myAttacking or myDefending

		if planetID ~= newPlanetData.PlanetID then
			planetImage:Dispose()
			planetImage = GetPlanetImage(holder, 2, 2, 86, newPlanetData.PlanetImage, newPlanetData.StructureImages)

			imMinimap.file, imMinimap.checkFileExists = config:GetMinimapSmallImage(mapName)
			imMinimap:ResetImageLoadTimer()
			imMinimap:Invalidate()

			SetPlanetName(newPlanetData)
		end
		planetID = newPlanetData.PlanetID

		UpdateJoinButton()
	end

	function externalFunctions.UpdateJoinCheck()
		if not holder.visible then
			return
		end
		UpdateJoinButton()
	end

	function externalFunctions.Deselect(exceptionPlanetID)
		if (not holder.visible) or (planetID == exceptionPlanetID) then
			return
		end
		if joinedBattle then
			joinedBattle = false
			UpdateJoinButton()
		end
	end

	function externalFunctions.GetControl()
		return holder
	end

	function externalFunctions.GetSortOrder(defaultOrder)
		if defendPhase and myAttacking then
			return {"000", planetName} -- Put the planet I am attacking at the top
		end
		if canSelectPlanet then
			return {string.format("%03d", defaultOrder), planetName}
		end
		if owner then
			return {"a" .. planetName, planetName}
		end
		
		return {"b" .. planetName, planetName}
	end

	function externalFunctions.SetPlanetJoinedIfIDMatches(checkPlanetID, checkPlanetAttacker)
		if (not holder.visible) or (planetID ~= checkPlanetID) or (planetAttacker ~= checkPlanetAttacker) then
			return
		end

		joinedBattle = true
		UpdateJoinButton()
		DeselectOtherFunc(planetID)
	end

	return externalFunctions
end

local function GetPlanetList(parentControl)

	local planets = {}

	local function DeselectPlanets(exceptionPlanetID)
		for i = 1, #planets do
			planets[i].Deselect(exceptionPlanetID)
		end
	end

	local headings = {
		{
			name = "Priority",
			x = 0,
			width = 160,
		},
		{
			name = "Name",
			x = 160,
			width = 160,
		
		},
	}
	local sortableList = WG.Chobby.SortableList(parentControl, nil, 90, 1, true, false, nil, true)

	local externalFunctions = {}

	function externalFunctions.SetPlanetList(newPlanetList, attackPhase, defendPhase, modeSwitched)
		if modeSwitched then
			queuePlanetJoin = nil
		end
		sortableList:Clear()
		local items = {}
		if newPlanetList then
			for i = 1, #newPlanetList do
				if planets[i] then
					planets[i].UpdatePlanetControl(newPlanetList[i], attackPhase, defendPhase, modeSwitched)
				else
					planets[i] = MakePlanetControl(newPlanetList[i], DeselectPlanets, attackPhase, defendPhase)
				end
				items[i] = {i, planets[i].GetControl(), planets[i].GetSortOrder(i)}
			end
			sortableList:AddItems(items)
		end
	end

	function externalFunctions.UpdateJoinCheck()
		for i = 1, #planets do
			planets[i].UpdateJoinCheck()
		end
	end

	function externalFunctions.SetPlanetJoined(planetID, planetAttacker)
		for i = 1, #planets do
			planets[i].SetPlanetJoinedIfIDMatches(planetID, planetAttacker)
		end
	end

	return externalFunctions
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Faction Selection

local function MakeFactionSelector(parent, x, y, SelectionFunc, CancelFunc, right, bottom)
	local Configuration = WG.Chobby.Configuration

	local factionText = VFS.Include(LUA_DIRNAME .. "configs/planetwars/factionText.lua") or {}

	local lobby = WG.LibLobby.lobby
	local factionList = lobby and lobby.planetwarsData.factionList
	if not (lobby or factionList) then
		return
	end

	local HolderType = (right and bottom and ScrollPanel) or Control

	local offset = 15
	local holder = HolderType:New {
		x = x,
		y = y,
		width = not (right and bottom) and 400,
		right = right,
		bottom = bottom,
		height = (#factionList)*FACTION_SPACING + 40,
		horizontalScrollbar = false,
		padding = (right and bottom and {5, 5, 5, 5}) or {0, 0, 0, 0},
		parent = parent,
	}

	local startIndex, endIndex, direction = 1, #factionList, 1
	if updates%2 == 0 then
		startIndex, endIndex, direction = #factionList, 1, -1
	end

	for i = startIndex, endIndex, direction do
		local shortname = factionList[i].Shortcut
		local name = factionList[i].Name
		local factionData = factionText[shortname] or {}

		local buttonPos = 140
		if factionData.imageLarge then
			Image:New {
				x = 2,
				y = offset + 5,
				width = 128,
				height = 128,
				keepAspect = true,
				file = factionData.imageLarge,
				parent = holder,
			}
		elseif factionData.image then
			buttonPos = 86
			Image:New {
				x = 8,
				y = offset,
				width = 64,
				height = 64,
				keepAspect = true,
				file = factionData.image,
				parent = holder,
			}
		end

		Button:New {
			x = buttonPos,
			y = offset,
			width = 290,
			height = WG.BUTTON_HEIGHT,
			caption = "Join " .. name,
			objectOverrideFont = Configuration:GetButtonFont(3),
			classname = "action_button",
			OnClick = {
				function()
					lobby:JoinFactionRequest(shortname)
					if SelectionFunc then
						SelectionFunc()
					end
				end
			},
			parent = holder,
		}

		if factionData.motto then
			TextBox:New {
				x = buttonPos,
				y = offset + 56,
				width = 360,
				height = 45,
				objectOverrideFont = Configuration:GetFont(2),
				text = [["]] .. factionData.motto .. [["]],
				parent = holder,
			}
			offset = offset + 30
		end
		if factionData.motto then
			TextBox:New {
				x = buttonPos,
				y = offset + 56,
				width = 360,
				height = 45,
				objectOverrideFont = Configuration:GetFont(2),
				text = factionData.desc,
				parent = holder,
			}
		end

		offset = offset + FACTION_SPACING
	end

	Button:New {
		x = 140,
		y = offset,
		width = 170,
		height = 35,
		caption = "Factions Page",
		objectOverrideFont = Configuration:GetButtonFont(2),
		classname = "option_button",
		padding = {2,4,4,4},
		OnClick = {
			function()
				WG.BrowserHandler.OpenUrl("https://zero-k.info/Factions")
			end
		},
		parent = holder,
		children = {
			Image:New {
				right = 1,
				y = 4,
				width = 18,
				height = 18,
				keepAspect = true,
				file = IMG_LINK
			}
		}
	}

	if CancelFunc then
		Button:New {
			x = 316,
			y = offset,
			width = 84,
			height = 35,
			objectOverrideFont =  WG.Chobby.Configuration:GetButtonFont(2),
			caption = i18n("cancel"),
			classname = "negative_button",
			OnClick = {
				function()
					CancelFunc()
				end
			},
			parent = holder,
		}
	end

	return holder
end

local function MakeFactionSelectionPopup()
	local Configuration = WG.Chobby.Configuration
	local lobby = WG.LibLobby.lobby

	local factionList = lobby and lobby.planetwarsData.factionList
	if not factionList then
		return
	end

	local factionWindow = Window:New {
		x = 700,
		y = 300,
		width = 460,
		height = 130 + (#factionList)*FACTION_SPACING,
		caption = "",
		resizable = false,
		draggable = false,
		parent = WG.Chobby.lobbyInterfaceHolder,
		classname = "main_window",
		OnDispose = {
			function()
				lobby:RemoveListener("OnJoinBattleFailed", onJoinBattleFailed)
				lobby:RemoveListener("OnJoinBattle", onJoinBattle)
			end
		},
	}

	local function CancelFunc()
		factionWindow:Dispose()
	end

	MakeFactionSelector(factionWindow, 16, 45, CancelFunc, CancelFunc)

	TextBox:New {
		x = 38,
		right = 15,
		y = 15,
		height = 35,
		objectOverrideFont = Configuration:GetFont(3),
		text = "Join a faction to play Planetwars",
		parent = factionWindow,
	}

	local popupHolder = WG.Chobby.PriorityPopup(factionWindow, CancelFunc, CancelFunc)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Initialization

local function InitializeControls(window)
	local Configuration = WG.Chobby.Configuration
	local lobby = WG.LibLobby.lobby

	local title = "Planetwars"
	local missingResources = false
	local factionLinkButton

	local oldAttackerFaction, oldDefenderFactions, oldMode = "", {}, 1
	local pwData = lobby:GetPlanetwarsData()
	local charges, rechargeTime = pwData.charges or 0, pwData.nextRechargeTime

	local lblTitle = Label:New {
		x = 20,
		right = 5,
		y = WG.TOP_LABEL_Y,
		height = 20,
		objectOverrideFont = Configuration:GetFont(3),
		caption = "Planetwars",
		parent = window
	}

	local btnClose = Button:New {
		right = 11,
		y = WG.TOP_BUTTON_Y,
		width = 80,
		height = WG.BUTTON_HEIGHT,
		caption = i18n("close"),
		objectOverrideFont = Configuration:GetButtonFont(3),
		classname = "negative_button",
		OnClick = {
			function()
				window:Hide()
			end
		},
		parent = window
	}

	local listHolder = Control:New {
		x = 12,
		right = 12,
		y = 152,
		bottom = 46,
		padding = {5, 5, 5, 5},
		parent = window,
	}

	Button:New {
		x = 15,
		bottom = 12,
		width = 150,
		height = 32,
		caption = "Galaxy Map",
		objectOverrideFont = Configuration:GetButtonFont(2),
		classname = "option_button",
		padding = {2,4,4,4},
		OnClick = {
			function()
				WG.BrowserHandler.OpenUrl("https://zero-k.info/Planetwars")
			end
		},
		children = {
			Image:New {
				right = 1,
				y = 4,
				width = 18,
				height = 18,
				keepAspect = true,
				file = IMG_LINK
			}
		},
		parent = window,
	}
	local seeMorePlanets = TextBox:New {
		x = 174,
		right = 16,
		bottom = 18,
		height = 50,
		objectOverrideFont = Configuration:GetFont(2),
		text = "Select planets on the Galaxy Map for more options.",
		parent = window
	}

	local planetList = GetPlanetList(listHolder)

	local statusText = TextBox:New {
		x = 20,
		right = 16,
		y = 60,
		height = 50,
		objectOverrideFont = Configuration:GetFont(2),
		text = "",
		parent = window
	}

	local chargesText = TextBox:New {
		x = 20,
		right = 16,
		y = 112,
		height = 50,
		objectOverrideFont = Configuration:GetFont(2),
		text = "",
		parent = window
	}

	local planetStatusText = {}
	local planetStatusNames = {"attackers", "incoming", "neutral"}
	for i = 1, #planetStatusNames do
		planetStatusText[planetStatusNames[i]] = TextBox:New {
			x = 20 + (i - 1) * 180 - math.max(0, i - 2)*35,
			right = 16,
			y = 134,
			height = 50,
			objectOverrideFont = Configuration:GetFont(2),
			text = "",
			parent = window
		}
	end

	local function CheckPlanetwarsRequirements()
		local myUserInfo = lobby:GetMyInfo()
		if not (planetwarsSoon or planetwarsEnabled) then
			statusText:SetText("Planetwars is offline. Check back later.")
			if factionLinkButton then
				factionLinkButton:SetVisibility(false)
			end
			listHolder:SetVisibility(false)
			return false
		end

		if not myUserInfo then
			statusText:SetText(((planetwarsSoon and PW_SOON_TEXT) or "") .. "Error getting user info. Are you fully logged in?")
			if factionLinkButton then
				factionLinkButton:SetVisibility(false)
			end
			listHolder:SetVisibility(false)
			return false
		end

		if planetwarsLevelRequired and ((myUserInfo.level or 0) < planetwarsLevelRequired) then
			statusText:SetText(((planetwarsSoon and PW_SOON_TEXT) or "") .. "You need to be at least level " .. (planetwarsLevelRequired or "??") .. " to participate in Planetwars.")
			if factionLinkButton then
				factionLinkButton:SetVisibility(false)
			end
			listHolder:SetVisibility(false)
			return false
		end

		if not lobby:GetFactionData(myUserInfo.faction) then
			statusText:SetText(((planetwarsSoon and PW_SOON_TEXT) or "") .. "Choose a faction and join the fight.")
			if not factionLinkButton then
				factionLinkButton = MakeFactionSelector(window, 15, 80, nil, nil, 15, 52)
			end
			factionLinkButton:SetVisibility(true)
			listHolder:SetVisibility(false)
			return false
		end

		if factionLinkButton then
			factionLinkButton:Dispose()
			factionLinkButton = nil
		end

		if (not planetwarsEnabled) and planetwarsSoon then
			statusText:SetText(PW_SOON_TEXT)
			if factionLinkButton then
				factionLinkButton:SetVisibility(false)
			end
			listHolder:SetVisibility(false)
			return false
		end

		listHolder:SetVisibility(true)
		return true
	end
	
	local function UpdateChargesText()
		if not CheckPlanetwarsRequirements() or missingResources then
			return
		end
		if not (pwData.maxCharges and charges) then
			return
		end
		local text = "Attack charges: " .. charges .. "/" .. pwData.maxCharges
		if rechargeTime then
			local difference, inTheFuture, isNow = Spring.Utilities.GetTimeDifference(rechargeTime, false, true)
			if inTheFuture then
				text = text.. "  - Gain more by defending or wait for " .. difference
			else
				text = text .. "  - Gain more by defending or wait for 0 seconds"
			end
		elseif charges < pwData.maxCharges then
				text = text .. "  - Gain more by defending"
		end
		chargesText:SetText(text)
	end

	local planetStatusData = {}
	local function UpdatePlanetStatusData(attackPhase, planets)
		local myFaction = lobby:GetMyFaction()
		planetStatusData.myAttackers = 0
		planetStatusData.myIncoming = 0
		planetStatusData.neutralIncoming = 0
		planetStatusData.myDefend = 0
		planetStatusData.myDefendMax = 0
		planetStatusData.neutralDefend = 0
		planetStatusData.neutralDefendMax = 0
		for i = 1, #planets do
			local planet = planets[i]
			if planet.AttackerFaction == myFaction then
				planetStatusData.myAttackers = planetStatusData.myAttackers + planet.Count
			elseif planet.OwnerFaction == myFaction then
				planetStatusData.myIncoming = planetStatusData.myIncoming + planet.Count
			elseif not planet.OwnerFaction then
				planetStatusData.neutralIncoming = planetStatusData.neutralIncoming + planet.Count
			end
			if planet.OwnerFaction == myFaction then
				planetStatusData.myDefend = planetStatusData.myDefend + planet.Count
				planetStatusData.myDefendMax = planetStatusData.myDefendMax + planet.Needed
			elseif not planet.OwnerFaction and planet.AttackerFaction ~= myFaction then
				planetStatusData.neutralDefend = planetStatusData.neutralDefend + planet.Count
				planetStatusData.neutralDefendMax = planetStatusData.neutralDefendMax + planet.Needed
			end
		end
	end
	
	local function UpdateStatusText(attackPhase, defendPhase, currentMode, planets)
		if not CheckPlanetwarsRequirements() or missingResources then
			return
		end

		if attackPhase then
			if charges == 0 then
				statusText:SetText("You are out of attack charges. Gain charges by defending or over time.")
			else
				statusText:SetText("Select a planet to attack. Invasions with enough players are locked at the end of the phase and sent to the defenders.")
			end
			if planets then
				UpdatePlanetStatusData(attackPhase, planets)
				planetStatusText.attackers:SetText("Fellow attackers: " .. planetStatusData.myAttackers)
				planetStatusText.incoming:SetText("To defend: " .. planetStatusData.myIncoming)
				planetStatusText.neutral:SetText("Neutrals to defend: " .. planetStatusData.neutralIncoming)
				for i = 1, #planetStatusNames do
					planetStatusText[planetStatusNames[i]]:SetVisibility(true)
				end
			end
		elseif defendPhase then
			local myAttack, myFactionAttack = GetAttackingPlanet()
			if myAttack then
				statusText:SetText("You are attacking " .. myAttack .. ", the battle will start at the end of the phase.")
			else
				statusText:SetText("Join planets that need defending. Doing so gives you an attack charge.")
			end
			
			if planets then
				UpdatePlanetStatusData(attackPhase, planets)
				if planetStatusData.myDefendMax and planetStatusData.myDefendMax > 0 then
					planetStatusText.attackers:SetText("Defenders: " .. planetStatusData.myDefend .. "/" .. planetStatusData.myDefendMax)
				else
					planetStatusText.attackers:SetText("Defenders: -")
				end
				if planetStatusData.neutralDefendMax and planetStatusData.neutralDefendMax > 0 then
					planetStatusText.incoming:SetText("Neutral Defenders: " .. planetStatusData.neutralDefend .. "/" .. planetStatusData.neutralDefendMax)
				else
					planetStatusText.incoming:SetText("Neutral Defenders: -")
				end
				planetStatusText.attackers:SetVisibility(true)
				planetStatusText.incoming:SetVisibility(true)
				planetStatusText.neutral:SetVisibility(false)
			end
		else
			statusText:SetText("Error fetching Planetwars state. Try logging out then in again.")
			
			for i = 1, #planetStatusNames do
				planetStatusText[planetStatusNames[i]]:SetVisibility(false)
			end
		end
	end

	local function OnPwMatchCommand(listener, attackerFactions, defenderFactions, currentMode, planets, deadlineSeconds, modeSwitched)
		oldAttackerFaction, oldDefenderFactions, oldMode = attackerFactions, defenderFactions, currentMode

		if currentMode == lobby.PW_ATTACK then
			if attackerFactions and #attackerFactions and LIST_PHASE_FRACTIONS then
				title = "Planetwars: " .. ListToString(attackerFactions) .. " attacking - "
			else
				title = "Planetwars: Launch Attacks - "
			end
		else
			if defenderFactions and #defenderFactions and LIST_PHASE_FRACTIONS then
				title = "Planetwars: " .. ListToString(defenderFactions) .. " defending - "
			else
				title = "Planetwars: Prepare Defense - "
			end
		end

		local attackPhase, defendPhase = GetAttackingOrDefending(lobby, attackerFactions, defenderFactions, currentMode)
		UpdateChargesText()
		UpdateStatusText(attackPhase, defendPhase, currentMode, planets)

		planetList.SetPlanetList(planets, attackPhase, defendPhase, modeSwitched)
	end

	lobby:AddListener("OnPwMatchCommand", OnPwMatchCommand)

	local function OnPwattackPhasePlanet()
		local attackPhase, defendPhase = GetAttackingOrDefending(lobby, oldAttackerFaction, oldDefenderFactions, oldMode)
		UpdateChargesText()
		UpdateStatusText(attackPhase, defendPhase, oldMode)
	end
	lobby:AddListener("OnPwattackPhasePlanet", OnPwattackPhasePlanet)

	local function OnUpdateUserStatus(listener, userName, status)
		if lobby:GetMyUserName() == userName then
			local attackPhase, defendPhase = GetAttackingOrDefending(lobby, oldAttackerFaction, oldDefenderFactions, oldMode)
			UpdateChargesText()
			UpdateStatusText(attackPhase, defendPhase, oldMode)
		end
	end
	lobby:AddListener("OnUpdateUserStatus", OnUpdateUserStatus)

	local function OnPwAttackCharges(listener, newCharges, newRechargeTime)
		local attackPhase, defendPhase = GetAttackingOrDefending(lobby, oldAttackerFaction, oldDefenderFactions, oldMode)
		charges, rechargeTime = newCharges, newRechargeTime
		UpdateChargesText()
		UpdateStatusText(attackPhase, defendPhase, oldMode)
		planetList.UpdateJoinCheck()
	end
	lobby:AddListener("OnPwAttackCharges", OnPwAttackCharges)
	
	local externalFunctions = {}

	function externalFunctions.CheckDownloads()
		planetList.UpdateJoinCheck()
		if not HaveRightEngineVersion() then
			if CheckPlanetwarsRequirements() then
				statusText:SetText(MISSING_ENGINE_TEXT)
			end
			missingResources = true
			return
		end
		if not HaveRightGameVersion() then
			if CheckPlanetwarsRequirements() then
				statusText:SetText(MISSING_GAME_TEXT)
			end
			missingResources = true
			return
		end
		missingResources = false
	end

	externalFunctions.CheckPlanetwarsRequirements = CheckPlanetwarsRequirements

	function externalFunctions.UpdateTimer()
		UpdateChargesText()
		local timeRemaining = phaseTimer.GetTimeRemaining()
		if timeRemaining then
			lblTitle:SetCaption(title .. Spring.Utilities.FormatTime(timeRemaining, true))
		end
	end

	function externalFunctions.SetPlanetJoined(planetID)
		planetList.SetPlanetJoined(planetID)
	end

	-- Initialization
	externalFunctions.CheckDownloads()

	local planetwarsData = lobby:GetPlanetwarsData()
	OnPwMatchCommand(_, planetwarsData.attackerFactions, planetwarsData.defenderFactions, planetwarsData.currentMode, planetwarsData.planets, 457)

	return externalFunctions
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- External Interface

local PlanetwarsListWindow = {}

function PlanetwarsListWindow.HaveMatchMakerResources()
	return HaveRightEngineVersion() and HaveRightGameVersion()
end

local queueListWindowControl

function PlanetwarsListWindow.GetControl()
	planetwarsListWindowControl = Control:New {
		name = "planetwarsListWindowControl",
		x = "0%",
		y = "0%",
		width = "100%",
		height = "100%",
		padding = {0, 0, 0, 0},
		OnParent = {
			function(obj)
				if obj:IsEmpty() then
					panelInterface = InitializeControls(obj)
				end
			end
		},
	}

	return planetwarsListWindowControl
end

function DelayedInitialize()
	local Configuration = WG.Chobby.Configuration
	local lobby = WG.LibLobby.lobby

	local statusAndInvitesPanel = WG.Chobby.interfaceRoot.GetStatusAndInvitesPanel()

	phaseTimer = GetPhaseTimer()
	activityPromptHandler = InitializeActivityPromptHandler()

	local function AddQueue(_, queueName, queueDescription, mapNames, maxPartSize, gameNames)
		for i = 1, #gameNames do
			requiredGame = gameNames[i]
		end
		if panelInterface then
			panelInterface.CheckDownloads()
		end
	end
	lobby:AddListener("OnQueueOpened", AddQueue)


	local function UpdateActivity(attackerFactions, defenderFactions, currentMode, planets)
		local planetData, isAttacker, alreadyJoined, waitingForAllies = GetActivityToPrompt(lobby, attackerFactions, defenderFactions, currentMode, planets)
		if planetData then
			activityPromptHandler.SetActivity(planetData, isAttacker, alreadyJoined, waitingForAllies)
			statusAndInvitesPanel.AddControl(activityPromptHandler.GetHolder(), 5)
		else
			activityPromptHandler.NotifyHidden()
			statusAndInvitesPanel.RemoveControl(activityPromptHandler.GetHolder().name)
		end
	end

	local myLevel
	local function CheckFactionPopupCreation(myInfo)
		if not (planetwarsSoon or planetwarsEnabled) then
			return
		end
		if Configuration.alreadySeenFactionPopup4 then
			return
		end
		if planetwarsLevelRequired and (not Configuration.ignoreLevel) and not (myInfo and myInfo.level and myInfo.level >= planetwarsLevelRequired) then
			return
		end
		Configuration.alreadySeenFactionPopup4 = true
		if lobby:GetFactionData(myInfo.faction) then
			return
		end
		MakeFactionSelectionPopup()
	end

	local function OnPwStatus(_, enabledStatus, requiredLevel)
		Spring.Echo("OnPwStatus", enabledStatus, requiredLevel, lobby.PW_PREGAME, lobby.PW_ENABLED)
		local myInfo = lobby:GetMyInfo()
		myLevel = myInfo.level
		planetwarsLevelRequired = requiredLevel
		if enabledStatus == lobby.PW_PREGAME then
			planetwarsSoon = true
		elseif enabledStatus == lobby.PW_ENABLED then
			planetwarsEnabled = true
		end
		if panelInterface then
			panelInterface.CheckPlanetwarsRequirements()
		end
		CheckFactionPopupCreation(myInfo)
		local planetwarsData = lobby:GetPlanetwarsData()
		UpdateActivity(planetwarsData.attackerFactions, planetwarsData.defenderFactions, planetwarsData.currentMode, planetwarsData.planets)
	end
	lobby:AddListener("OnPwStatus", OnPwStatus)

	local function OnUpdateUserStatus(listener, userName, status)
		if (lobby:GetMyUserName() ~= userName) or (myLevel and (myLevel == status.level)) then
			return
		end
		myLevel = status.level
		if panelInterface then
			panelInterface.CheckPlanetwarsRequirements()
		end
		CheckFactionPopupCreation(status)
		local planetwarsData = lobby:GetPlanetwarsData()
		UpdateActivity(planetwarsData.attackerFactions, planetwarsData.defenderFactions, planetwarsData.currentMode, planetwarsData.planets)
	end

	lobby:AddListener("OnUpdateUserStatus", OnUpdateUserStatus)
	-- Test data
	--local TestAttack, TestDefend
	--function TestAttack()
	--	activityPromptHandler.SetActivity({PlanetName = "test", Map = "TitanDuel", Count = 2, Needed = 3, PlanetID = 1, PlanetImage = "12.png"}, true, true, true)
	--	statusAndInvitesPanel.AddControl(activityPromptHandler.GetHolder(), 5)
	--
	--	WG.Delay(TestDefend, 3)
	--end
	--function TestDefend()
	--	activityPromptHandler.SetActivity({PlanetName = "test", Map = "TitanDuel", Count = 2, Needed = 3, PlanetID = 2, PlanetImage = "11.png"}, false, false, false)
	--	statusAndInvitesPanel.AddControl(activityPromptHandler.GetHolder(), 5)
	--
	--	WG.Delay(TestAttack, 3)
	--end
	--WG.Delay(TestAttack, 3)

	local function OnPwMatchCommand(listener, attackerFactions, defenderFactions, currentMode, planets, deadlineSeconds, modeSwitched)
		phaseTimer.SetNewDeadline(deadlineSeconds)
		UpdateActivity(attackerFactions, defenderFactions, currentMode, planets)
	end
	lobby:AddListener("OnPwMatchCommand", OnPwMatchCommand)

	local function UnMatchedActivityUpdate()
		local planetwarsData = lobby:GetPlanetwarsData()
		UpdateActivity(planetwarsData.attackerFactions, planetwarsData.defenderFactions, planetwarsData.currentMode, planetwarsData.planets)
	end
	lobby:AddListener("OnPwJoinPlanetSuccess", UnMatchedActivityUpdate)
	lobby:AddListener("OnPwattackPhasePlanet", UnMatchedActivityUpdate)
	lobby:AddListener("OnPwAttackCharges", UnMatchedActivityUpdate)
	lobby:AddListener("OnLoginInfoEnd", UnMatchedActivityUpdate)

	local function OnDisconnected()
		UpdateActivity({}, {}, false, {})
	end
	lobby:AddListener("OnDisconnected", OnDisconnected)

	DoUnMatchedActivityUpdate = UnMatchedActivityUpdate

	local function OnPwRequestJoinPlanet(listener, joinPlanetID, planetAttacker)
		local planetwarsData = lobby:GetPlanetwarsData()
		local planets = planetwarsData.planets
		for i = 1, #planets do
			if joinPlanetID == planets[i].PlanetID and planetAttacker == planets[i].AttackerFaction then
				TryToJoinPlanet(planets[i])
				break
			end
		end
	end
	lobby:AddListener("OnPwRequestJoinPlanet", OnPwRequestJoinPlanet)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Widget Interface

function widget:Update()
	if not planetwarsEnabled then
		return
	end
	updates = updates + 1 -- Random number
	if panelInterface then
		panelInterface.UpdateTimer()
	end
	if activityPromptHandler then
		activityPromptHandler.UpdateTimer()
	end
	if DoUnMatchedActivityUpdate then
		local newUrgent = IsPhaseUrgent()
		if newUrgent ~= attackUrgent then
			attackUrgent = newUrgent
			DoUnMatchedActivityUpdate()
		end
	end
end

function widget:Initialize()
	CHOBBY_DIR = LUA_DIRNAME .. "widgets/chobby/"
	VFS.Include(LUA_DIRNAME .. "widgets/chobby/headers/exports.lua", nil, VFS.RAW_FIRST)
	WG.Delay(DelayedInitialize, 0.3)

	local function downloadFinished()
		if planetwarsEnabled then
			if panelInterface then
				panelInterface.CheckDownloads()
			end
			if queuePlanetJoin then
				TryToJoinPlanet(queuePlanetJoin)
			end
		end
	end
	WG.DownloadHandler.AddListener("DownloadFinished", downloadFinished)

	WG.PlanetwarsListWindow = PlanetwarsListWindow
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
