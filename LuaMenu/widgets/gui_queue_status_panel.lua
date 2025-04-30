--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
	return {
		name      = "Queue status panel",
		desc      = "Displays queue status.",
		author    = "GoogleFrog",
		date      = "11 September 2016",
		license   = "GNU LGPL, v2.1 or later",
		layer     = 0,
		enabled   = true  --  loaded by default?
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Variables
local statusQueueLobby -- global for timer update
local statusQueueIngame
local readyCheckPopup

local findingMatch = false
local wantAutosave = false

local ALLOW_REJECT_QUICKPLAY = true
local ALLOW_REJECT_REGULAR = false

local SEND_AUTOSAVE = "MatchmakerAutosaveRequired"

local queueNameOverride = {
	["1v1 Narrow"] = "1v1",
	["1v1"] = "1v1 Handicap",
	["1v1 Wide"] = "1v1 Wide",
	["Sortie"] = "2v2-3v3",
	["Battle"] = "4v4-6v6",
}

local subQueueListName = {
	["1v1"] = "Handicap",
	["1v1 Wide"] = "Wide",
	["Sortie Wide"] = "Wide",
	["Battle Wide"] = "Wide",
}

local alwaysParen = {
	["1v1 Narrow"] = true,
}

local subQueues = {
	["1v1"] = "1v1 Narrow",
	["1v1 Wide"] = "1v1 Narrow",
	["Sortie Wide"] = "Sortie",
	["Battle Wide"] = "Battle",
}

local extraCount = {}
for child, parent in pairs(subQueues) do
	extraCount[parent] = (extraCount[parent] or 0) + 1
end

local function GetQueueStartPriority()
	local Configuration = WG.Chobby.Configuration
	if Configuration.queue_handicap or not Configuration.queue_wide then
		return {
			["Battle"] = 5,
			["Sortie"] = 4,
			["Teams"] = 3,
			["1v1 Narrow"] = 2.5,
			["1v1"] = 2,
			["1v1 Wide"] = 1.5,
			["Battle Wide"] = 1.2,
			["Sortie Wide"] = 1.1,
			["Coop"] = 1,
		}
	end
	return {
		["Battle Wide"] = 7,
		["Sortie Wide"] = 6,
		["Battle"] = 5,
		["Sortie"] = 4,
		["Teams"] = 3,
		["1v1 Narrow"] = 2.5,
		["1v1 Wide"] = 2,
		["1v1"] = 1.5,
		["Coop"] = 1,
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Utilities

local function SecondsToMinutes(seconds)
	if seconds < 60 then
		return seconds .. "s"
	end
	local modSeconds = (seconds%60)
	return math.floor(seconds/60) .. ":" .. ((modSeconds < 10 and "0") or "") .. modSeconds
end

local function SetBanFrom(fromTime, increment)
	local conf = WG.Chobby.Configuration
	fromTime = fromTime or Spring.Utilities.GetCurrentUtc()
	local count = (conf.matchmakerRejectCount or 0) + (increment or 0)

	-- Order is important due to event listeners triggering on changes to matchmakerRejectTime
	conf:SetConfigValue("matchmakerRejectCount", count)
	conf:SetConfigValue("matchmakerRejectTime", fromTime)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Initialization

local function InitializeQueueStatusHandler(name, ControlType, parent, pos)
	local lobby = WG.LibLobby.lobby

	ControlType = ControlType or Panel

	local queuePanel = ControlType:New {
		name = name,
		x = (pos and pos.x) or ((not pos) and 0),
		y = (pos and pos.y) or ((not pos) and 0),
		right = (pos and pos.right) or ((not pos) and 0),
		bottom = (pos and pos.bottom) or ((not pos) and 0),
		classname = "button",
		width = pos and pos.width,
		height = pos and pos.height,
		padding = {0,0,0,0},
		caption = "",
		resizable = false,
		draggable = false,
		parent = parent
	}

	local button = Button:New {
		name = "cancel",
		x = "70%",
		right = 4,
		y = 4,
		bottom = 4,
		padding = {0,0,0,0},
		caption = "Cancel",
		objectOverrideFont = WG.Chobby.Configuration:GetButtonFont(3),
		classname = "action_button",
		OnClick = {
			function()
				lobby:LeaveMatchMakingAll()
			end
		},
		parent = queuePanel,
	}

	local rightBound = "33%"
	local bottomBound = 12
	local bigMode = true
	local queueTimer = Spring.GetTimer()

	local timeWaiting = 0
	local queueString = ""
	local playersString = ""
	local timeString = ""

	local queueStatusText = TextBox:New {
		x = 12,
		y = 16,
		right = rightBound,
		bottom = bottomBound,
		objectOverrideFont = WG.Chobby.Configuration:GetFont(2),
		text = "",
		parent = queuePanel
	}

	local function UpdateTimer(forceUpdate)
		if not queueTimer then
			return
		end
		local newTimeWaiting = math.floor(Spring.DiffTimers(Spring.GetTimer(),queueTimer))
		if (not forceUpdate) and timeWaiting == newTimeWaiting then
			return
		end
		timeWaiting = newTimeWaiting
		timeString = SecondsToMinutes(timeWaiting)
		local doAutosave = wantAutosave and WG.Chobby.Configuration.autosaveOnMatchmaker
		local thirdLine = (wantAutosave and "\nAutosave Enabled") or (((bigMode and  "\nPlayers: ") or "\nPlay: ") .. playersString)
		local truncatedQueueString = StringUtilities.GetTruncatedStringWithDotDot(queueString or "", queueStatusText.font, 195) or queueString
		queueStatusText:SetText("Finding Match - " .. timeString .. "\n" .. truncatedQueueString .. thirdLine)
	end

	local function UpdateQueueText()
		UpdateTimer(true)
	end

	local function Resize(obj, xSize, ySize)
		queueStatusText._relativeBounds.right = rightBound
		queueStatusText._relativeBounds.bottom = bottomBound
		queueStatusText:UpdateClientArea()
		if ySize < 60 then
			queueStatusText:SetPos(6, 3)
			bigMode = false
		else
			queueStatusText:SetPos(8, 13)
			bigMode = true
		end
		UpdateQueueText()
	end

	queuePanel.OnResize = {Resize}

	local externalFunctions = {}

	function externalFunctions.ResetTimer()
		queueTimer = Spring.GetTimer()
	end

	function externalFunctions.UpdateTimer(forceUpdate)
		UpdateTimer(forceUpdate)
	end

	function externalFunctions.UpdateMatches(joinedQueueList, queueCounts, currentEloWidth, joinedTime)
		local firstQueue = true
		playersString = ""
		queueString = ""
		
		local joinedQueues = {}
		for i = 1, #joinedQueueList do
			joinedQueues[joinedQueueList[i]] = true
		end
		local extraInfoList = {}
		for i = 1, #joinedQueueList do
			local queueName = joinedQueueList[i]
			if subQueues[queueName] and joinedQueues[subQueues[queueName]] then
				local extraData = extraInfoList[subQueues[queueName]] or {}
				extraData[#extraData + 1] = queueName
				extraInfoList[subQueues[queueName]] = extraData
			end
		end
		--local abbreviate = (#joinedQueueList >= 3)
		for i = 1, #joinedQueueList do
			local queueName = joinedQueueList[i]
			if not (subQueues[queueName] and joinedQueues[subQueues[queueName]]) then
				if not firstQueue then
					queueString = queueString .. ", "
					playersString = playersString .. ", "
				end
				playersString = playersString .. ((queueCounts and queueCounts[queueName]) or 0)
				firstQueue = false
				
				queueString = queueString .. (queueNameOverride[queueName] or queueName)
				if extraInfoList[queueName] then
					local extra = extraInfoList[queueName]
					if #extra == extraCount[queueName] then
						queueString = queueString .. " (All"
					else
						queueString = queueString .. " (Normal"
						for j = 1, #extra do
							queueString = queueString .. ", "
							queueString = queueString .. (subQueueListName[extra[j]] or extra[j])
						end
					end
					queueString = queueString .. ")"
				elseif alwaysParen[queueName] then
					queueString = queueString .. " (Normal)"
				end
			end
		end

		UpdateQueueText()
	end

	function externalFunctions.GetHolder()
		return queuePanel
	end

	return externalFunctions
end

local function InitializeInstantQueueHandler()
	local lobby = WG.LibLobby.lobby
	local queueName

	local queuePanel = Panel:New {
		x = 0,
		y = 0,
		right = 0,
		bottom = 0,
		classname = "button",
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
		caption = "Play",
		objectOverrideFont = WG.Chobby.Configuration:GetButtonFont(3),
		classname = "action_button",
		OnClick = {
			function()
				lobby:JoinMatchMaking(queueName)
			end
		},
		parent = queuePanel,
	}

	local rightBound = "50%"
	local bottomBound = 12
	local bigMode = true

	local queueStatusText = TextBox:New {
		x = 22,
		y = 18,
		right = rightBound,
		bottom = bottomBound,
		objectOverrideFont = WG.Chobby.Configuration:GetFont(2),
		text = "",
		parent = queuePanel
	}

	local function UpdateQueueText()
		if queueName then
			queueStatusText:SetText("Match Available\n" .. (queueNameOverride[queueName] or queueName))
		end
	end

	local function Resize(obj, xSize, ySize)
		queueStatusText._relativeBounds.right = rightBound
		queueStatusText._relativeBounds.bottom = bottomBound
		queueStatusText:UpdateClientArea()
		if ySize < 60 then
			queueStatusText:SetPos(math.floor(xSize/4) - 52, 2)
			queueStatusText.font = WG.Chobby.Configuration:GetFont(2)
			queueStatusText:Invalidate()
			bigMode = false
		else
			queueStatusText:SetPos(math.floor(xSize/4) - 62, 18)
			queueStatusText.font = WG.Chobby.Configuration:GetFont(3)
			queueStatusText:Invalidate()
			bigMode = true
		end
		UpdateQueueText()
	end

	queuePanel.OnResize = {Resize}

	local externalFunctions = {}

	function externalFunctions.UpdateQueueName(newQueueName)
		queueName = newQueueName
		UpdateQueueText()
	end

	function externalFunctions.ProcessInstantStartQueue(instantStartQueues)
		if lobby.planetwarsData.attackingPlanet then
			-- Don't show instant start when player is actively invading a planet and waiting for defenders.
			return false
		end
		if instantStartQueues and #instantStartQueues > 0 then
			local instantQueueName
			local instantStartQueuePriority = GetQueueStartPriority()
			local bestPriority = -1
			for i = 1, #instantStartQueues do
				local queueName = instantStartQueues[i]
				if (instantStartQueuePriority[queueName] or 0) > bestPriority then
					instantQueueName = queueName
					bestPriority = (instantStartQueuePriority[queueName] or 0)
				end
			end
			if instantQueueName then
				externalFunctions.UpdateQueueName(instantQueueName)
				return true
			end
		end
		return false
	end

	function externalFunctions.GetHolder()
		return queuePanel
	end

	return externalFunctions
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Ready Check Popup

local function CreateReadyCheckWindow(DestroyFunc, secondsRemaining, minWinChance, isQuickPlay)
	local Configuration = WG.Chobby.Configuration
	local waitingForAutosave = wantAutosave and Configuration.autosaveOnMatchmaker and Spring.SendLuaUIMsg
	if waitingForAutosave then
		Spring.SendLuaUIMsg(SEND_AUTOSAVE)
	end

	local snd_volui = Spring.GetConfigString("snd_volui")
	local snd_volmaster = Spring.GetConfigString("snd_volmaster")

	-- These are defaults. Should be audible enough.
	Spring.SetConfigString("snd_volui", 100)
	Spring.SetConfigString("snd_volmaster", 60)
	if Configuration.menuNotificationVolume ~= 0 then
		Spring.PlaySoundFile("sounds/matchFound.wav", Configuration.menuNotificationVolume or 1, "ui")
	end
	WG.Delay(function()
		Spring.SetConfigString("snd_volui", snd_volui)
		Spring.SetConfigString("snd_volmaster", snd_volmaster)
	end, 10)

	Configuration:SetConfigValue("matchmakerPopupTime", Spring.Utilities.GetCurrentUtc())
	if WG.WrapperLoopback then
		WG.WrapperLoopback.Alert("Match found")
	end

	local allowReject = (isQuickPlay and ALLOW_REJECT_QUICKPLAY) or (not isQuickPlay and ALLOW_REJECT_REGULAR)

	local readyCheckWindow = Window:New {
		caption = "",
		name = "readyCheckWindow",
		parent = screen0,
		width = 310,
		height = waitingForAutosave and 330 or 280,
		resizable = false,
		draggable = false,
		classname = "main_window",
	}

	local invitationText = i18n("match_found")
	if isQuickPlay then
		invitationText = i18n("match_found_quickplay")
	end

	local title = Label:New {
		x = 40,
		right = 0,
		y = 15,
		height = 35,
		caption = invitationText,
		objectOverrideFont = Configuration:GetFont(4),
		parent = readyCheckWindow,
	}

	local statusLabel = TextBox:New {
		x = 15,
		width = 250,
		y = 70,
		height = 35,
		text = "",
		objectOverrideFont = Configuration:GetFont(3),
		parent = readyCheckWindow,
	}

	local playersAcceptedLabel = Label:New {
		x = 15,
		width = 250,
		y = 115,
		height = 35,
		caption = "Players accepted: 0",
		objectOverrideFont = Configuration:GetFont(3),
		parent = readyCheckWindow,
	}

	local autosaveLabel = Label:New {
		x = 15,
		width = 250,
		y = 155,
		height = 35,
		caption = "",
		objectOverrideFont = Configuration:GetFont(3),
		parent = readyCheckWindow,
	}

	local acceptAcknowledged = false
	local acceptClicked = false
	local rejectedMatch = false
	local displayTimer = true
	local startTimer = Spring.GetTimer()
	local timeRemaining = secondsRemaining

	local function DoDispose()
		if readyCheckWindow then
			readyCheckWindow:Dispose()
			readyCheckWindow = nil
			DestroyFunc()
		end
	end

	local function CancelFunc()
		lobby:RejectMatchMakingMatch()
		statusLabel:SetText(Configuration:GetErrorColor() .. "Rejected match")
		rejectedMatch = true
		displayTimer = false
		WG.Delay(DoDispose, 1)
	end

	local function AcceptFunc()
		acceptClicked = true
		Configuration:SetConfigValue("matchmakerPopupTime", nil)
		lobby:AcceptMatchMakingMatch()
	end

	local buttonAccept = Button:New {
		x = (not allowReject) and "20%",
		right = (allowReject and 150) or "20%",
		width = (allowReject and 135),
		bottom = 1,
		height = 70,
		caption = (allowReject and i18n("accept")) or i18n("ready"),
		objectOverrideFont = Configuration:GetButtonFont((allowReject and 3) or 4),
		parent = readyCheckWindow,
		classname = "action_button",
		OnClick = {
			function()
				AcceptFunc()
			end
		},
	}

	local buttonReject = allowReject and Button:New {
		right = 1,
		width = 135,
		bottom = 1,
		height = 70,
		caption = i18n("reject"),
		objectOverrideFont = Configuration:GetButtonFont(3),
		parent = readyCheckWindow,
		classname = "option_button",
		OnClick = {
			function()
				CancelFunc()
			end
		},
	}

	local banChecked = false
	local function CheckBan()
		if acceptAcknowledged or banChecked or acceptClicked then
			return
		end
		SetBanFrom(Configuration.matchmakerPopupTime, 1)
		banChecked = true
	end

	local function SetAutosaveStatus(stillWaiting, saveName)
		if stillWaiting then
			autosaveLabel:SetCaption(Configuration:GetWarningColor() .. "Saving Game")
		else
			autosaveLabel:SetCaption(Configuration:GetSuccessColor() .. "Autosave Complete:\n" .. saveName)
		end
	end
	if waitingForAutosave then
		SetAutosaveStatus(true)
	end

	local popupHolder = WG.Chobby.PriorityPopup(readyCheckWindow, allowReject and CancelFunc, AcceptFunc, screen0)
	local externalFunctions = {}

	function externalFunctions.UpdateTimer()
		local newTimeRemaining = secondsRemaining - math.ceil(Spring.DiffTimers(Spring.GetTimer(), startTimer))
		if newTimeRemaining < 0 then
			CheckBan()
			WG.Delay(DoDispose, 0.1)
		end
		if not displayTimer then
			return
		end
		if timeRemaining == newTimeRemaining then
			return
		end
		timeRemaining = newTimeRemaining
		statusLabel:SetText(((acceptAcknowledged and "Waiting for players ") or "Accept in ") .. SecondsToMinutes(timeRemaining))
	end

	function externalFunctions.UpdatePlayerCount(readyPlayers)
		-- queueReadyCounts is not a useful number.
		playersAcceptedLabel:SetCaption("Players accepted: " .. readyPlayers)
	end

	function externalFunctions.AcceptRegistered()
		if acceptAcknowledged then
			return
		end
		acceptAcknowledged = true
		Configuration:SetConfigValue("matchmakerPopupTime", nil)
		statusLabel:SetText("Waiting for players " .. (timeRemaining or "time error") .. "s")

		buttonAccept:Hide()

		if allowReject then
			buttonReject:SetPos(nil, nil, 90, 60)
			buttonReject._relativeBounds.right = 1
			buttonReject._relativeBounds.bottom = 1
			buttonReject:UpdateClientArea()
		end
	end

	function externalFunctions.DisconnectedRudely()
		CheckBan()
	end

	function externalFunctions.OnAutosaveComplete(saveName)
		waitingForAutosave = false
		SetAutosaveStatus(false, saveName)
	end

	function externalFunctions.MatchMakingComplete(success)
		if success then
			statusLabel:SetText(Configuration:GetSuccessColor() .. "Battle starting")
		else
			CheckBan()
			if acceptAcknowledged and not rejectedMatch then
				-- If we rejected the match then this message is not useful.
				statusLabel:SetText(Configuration:GetWarningColor() .. "Match rejected by another player")
			end
		end
		Spring.Echo("MatchMakingComplete", success)
		displayTimer = false
		WG.Delay(DoDispose, 3)
	end

	function externalFunctions.Destroy()
		acceptAcknowledged = true
		Configuration:SetConfigValue("matchmakerPopupTime", nil)
		DoDispose()
	end

	return externalFunctions
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Disable matchmaker while loading
local savedQueues

local function SaveQueues(isSpectator)
	local lobby = WG.LibLobby.lobby
	local config = WG.Chobby.Configuration
	if isSpectator and (config and config.rememberQueuesOnStart2) then
		savedQueues = isSpectator and lobby:GetJoinedQueues()
	else
		savedQueues = false
	end
	lobby:LeaveMatchMakingAll()
end

function widget:ActivateGame()
	if not savedQueues then
		return
	end

	for queueName, _ in pairs(savedQueues) do
		WG.LibLobby.lobby:JoinMatchMaking(queueName)
	end

	savedQueues = nil
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- External functions

local QueueStatusPanel = {}

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Widget Interface

function QueueStatusPanel.SetWantAutosaveFromGameData(ingameData)
	if not ingameData then
		wantAutosave = false
		return
	end
	if ingameData.isReplay then
		wantAutosave = false
		return
	end
	wantAutosave = (ingameData.isPlayer and ingameData.playerCount == 1) or (not ingameData.isPlayer and ingameData.playerCount == 0)
end

function QueueStatusPanel.OnAutosaveComplete(saveName)
	if readyCheckPopup then
		readyCheckPopup.OnAutosaveComplete(saveName)
	end
end

function DelayedInitialize()
	local lobby = WG.LibLobby.lobby

	local statusAndInvitesPanel = WG.Chobby.interfaceRoot.GetStatusAndInvitesPanel()

	statusQueueLobby = InitializeQueueStatusHandler("lobbyQueue")
	instantQueueHandler = InitializeInstantQueueHandler()

	if WG.Chobby.Configuration.matchmakerPopupTime then
		SetBanFrom(WG.Chobby.Configuration.matchmakerPopupTime)
	end

	local previouslyInMatchMaking = false
	local previousInstantStart = false
	local function OnMatchMakerStatus(listener, inMatchMaking, joinedQueueList, queueCounts, ingameCounts, instantStartQueues, currentEloWidth, joinedTime, bannedTime)
		findingMatch = inMatchMaking

		if not statusQueueIngame then
			local pos = {right = 2, y = 52, width = 300, height = 75}
			statusQueueIngame = InitializeQueueStatusHandler("ingameQueue", Window, WG.Chobby.interfaceRoot.GetIngameInterfaceHolder(), pos)
			statusQueueIngame.GetHolder():SetVisibility(inMatchMaking)
		end

		if inMatchMaking then
			if not previouslyInMatchMaking then
				statusQueueIngame.ResetTimer()
				statusQueueLobby.ResetTimer()
				statusAndInvitesPanel.AddControl(statusQueueLobby.GetHolder(), 9)
				statusQueueIngame.GetHolder():SetVisibility(inMatchMaking)
			end
			statusQueueIngame.UpdateMatches(joinedQueueList, queueCounts, currentEloWidth, joinedTime)
			statusQueueLobby.UpdateMatches(joinedQueueList, queueCounts, currentEloWidth, joinedTime)
		elseif previouslyInMatchMaking then
			statusAndInvitesPanel.RemoveControl(statusQueueLobby.GetHolder().name)
			statusQueueIngame.GetHolder():SetVisibility(inMatchMaking)
		end
		previouslyInMatchMaking = inMatchMaking

		local instantStart = ((not WG.GetCombinedBannedTime(bannedTime)) and WG.QueueListWindow.HaveMatchMakerResources() and instantQueueHandler.ProcessInstantStartQueue(instantStartQueues))
		if previousInstantStart then
			if not instantStart then
				statusAndInvitesPanel.RemoveControl(instantQueueHandler.GetHolder().name)
			end
		elseif instantStart then
			statusAndInvitesPanel.AddControl(instantQueueHandler.GetHolder(), 3)
		end
		previousInstantStart = instantStart
	end

	local function DestroyReadyCheckPopup()
		readyCheckPopup = nil
	end

	local function OnMatchMakerReadyCheck(_, secondsRemaining, minWinChance, isQuickPlay)
		if isQuickPlay then
			return -- Handled in battle room.
		end
		if readyCheckPopup then
			readyCheckPopup.Destroy()
		end
		readyCheckPopup = CreateReadyCheckWindow(DestroyReadyCheckPopup, secondsRemaining, minWinChance, isQuickPlay)
	end

	local function OnMatchMakerReadyUpdate(_, readyAccepted, likelyToPlay, queueReadyCounts, battleSize, readyPlayers)
		if not readyCheckPopup then
			return
		end
		if readyAccepted then
			readyCheckPopup.AcceptRegistered()
		end
		if readyPlayers then
			readyCheckPopup.UpdatePlayerCount(readyPlayers)
		end
	end

	local function OnMatchMakerReadyResult(_, isBattleStarting, areYouBanned)
		if not readyCheckPopup then
			return
		end
		readyCheckPopup.MatchMakingComplete(isBattleStarting)
	end

	local function OnBattleAboutToStart(listener, battleType, isSpectator)
		SaveQueues(isSpectator)
		-- If the battle is starting while popup is active then assume success.
		if not readyCheckPopup then
			return
		end
		readyCheckPopup.MatchMakingComplete(true)
	end

	local function OnBattleAboutToStartSingleplayer(listener)
		SaveQueues(true)
	end

	local function OnDisconnected()
		if readyCheckPopup then
			-- Safety
			readyCheckPopup.DisconnectedRudely()
		end
		OnMatchMakerStatus(false, false)
	end

	lobby:AddListener("OnMatchMakerStatus", OnMatchMakerStatus)
	lobby:AddListener("OnMatchMakerReadyCheck", OnMatchMakerReadyCheck)
	lobby:AddListener("OnMatchMakerReadyUpdate", OnMatchMakerReadyUpdate)
	lobby:AddListener("OnMatchMakerReadyResult", OnMatchMakerReadyResult)
	lobby:AddListener("OnBattleAboutToStart", OnBattleAboutToStart)
	lobby:AddListener("OnDisconnected", OnDisconnected)

	WG.LibLobby.localLobby:AddListener("OnBattleAboutToStart", OnBattleAboutToStartSingleplayer)
end

function widget:Update()
	if findingMatch then
		if statusQueueLobby then
			statusQueueLobby.UpdateTimer()
		end
		if statusQueueIngame then
			statusQueueIngame.UpdateTimer()
		end
	end
	if readyCheckPopup then
		readyCheckPopup.UpdateTimer()
	end
end

function widget:ActivateMenu()
	wantAutosave = false
end

function widget:Initialize()
	VFS.Include(LUA_DIRNAME .. "widgets/chobby/headers/exports.lua", nil, VFS.RAW_FIRST)

	WG.QueueStatusPanel = QueueStatusPanel
	WG.Delay(DelayedInitialize, 1)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
