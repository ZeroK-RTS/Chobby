--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
	return {
		name      = "Rogue Handler",
		desc      = "Explore a random galaxy",
		author    = "GoogleFrog",
		date      = "5 Jan 2026",
		license   = "GNU GPL, v2 or later",
		layer     = 0,
		enabled   = true  --  loaded by default?
	}
end

local GALAXY_IMAGE = LUA_DIRNAME .. "images/heic1403aDowngrade_rogue.jpg"
local IMAGE_BOUNDS = {
	x = 810/4000,
	y = 710/2602,
	width = 2400/4000,
	height = 1500/2602,
}

local difficultyNameMap = {
	[0] = "Import",
	[1] = "Easy",
	[2] = "Normal",
	[3] = "Hard",
	[4] = "Brutal",
}

local holderWindow
local difficultyWindow

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local difficultySetting = 4


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local windowX, windowY, windowWidth, windowHeight
local function RepositionBackground(newX, newY, newWidth, newHeight)
	windowX = newX or windowX
	windowY = newY or windowY
	windowWidth = newWidth or windowWidth
	windowHeight = newHeight or windowHeight

	local tX, tY, tScale = -0.023, 0, 0.99800402
	local transformedImageBounds = {
		x = IMAGE_BOUNDS.x + tX*IMAGE_BOUNDS.width,
		y = IMAGE_BOUNDS.y + tY*IMAGE_BOUNDS.height,
		width = IMAGE_BOUNDS.width/tScale,
		height = IMAGE_BOUNDS.height/tScale,
	}
	local background = WG.Chobby.interfaceRoot.GetBackgroundHolder()
	background:SetBoundOverride(transformedImageBounds)
	local x, y, width, height = background:ResizeAspectWindow(windowX, windowY, windowWidth, windowHeight)
end

local function DelayedViewResize()
	local window = holderWindow
	if not (window and window.parent) then
		return
	end
	local x, y = window:LocalToScreen(0, 0)
	RepositionBackground(x, y, window.xSize, window.ySize)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Difficulty Setting


local function InitializeDifficultySetting(parent)
	local Configuration = WG.Chobby.Configuration

	local window = Control:New{
		x = 170,
		y = 170,
		width = 128,
		height = 55,
		padding = {0,0,0,0},
		resizable = false,
		draggable = false,
		parent = parent,
	}
	local freezeSettings = true

	Label:New {
		x = 32,
		y = 1,
		width = 50,
		height = 30,
		valign = "top",
		align = "left",
		objectOverrideFont = Configuration:GetFont(2),
		caption = "Difficulty",
		parent = window,
	}
	local comboDifficulty = ComboBox:New {
		x = 4,
		right = 1,
		bottom = 3,
		height = 28,
		--debugPosition = true,
		items = {"Easy", "Normal", "Hard", "Brutal"},
		selected = difficultySetting,
		objectOverrideFont = Configuration:GetFont(2),
		OnSelect = {
			function (obj)
				if freezeSettings then
					return
				end
				difficultySetting = obj.selected
			end
		},
		parent = window,
	}

	freezeSettings = false
	return window
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Script Generation

local aiConfig = VFS.Include("campaign/sample/aiConfig.lua")

local function StartFreshGame()
	local friendNames = WG.SteamCoopHandler.GetJoinedFriends()

	local allyTeams = {}
	local allyTeamCount = 0
	local teams = {}
	local teamCount = 0
	local players = {}
	local playerCount = 0
	local ais = {}
	local aiCount = 0
	local commanderTypes = {}

	local Configuration = WG.Chobby.Configuration
	local gameName = Configuration:GetDefaultGameName()
	local mapName = "TitanDuel 2.2"
	local missionDifficulty = WG.CampaignData.GetDifficultySetting()
	local bitExtension = (Configuration:GetIsRunning64Bit() and "64") or "32"
	local playerName = Configuration:GetPlayerName()

	-- Add the player, this is to make the player team 0.
	players[playerCount] = {
		Name = playerName,
		Team = teamCount,
		IsFromDemo = 0,
		rank = 0,
	}
	teams[teamCount] = {
		TeamLeader = playerCount,
		AllyTeam = 0,
		rgbcolor = '0 0 0',
	}
	playerCount = playerCount + 1
	teamCount = teamCount + 1
	
	for i = 1, #friendNames do
		players[playerCount] = {
			Name = friendNames[i],
			Team = teamCount,
			IsFromDemo = 0,
			rank = 0,
		}
		teams[teamCount] = {
			TeamLeader = playerCount,
			AllyTeam = 0,
			rgbcolor = '0 0 0',
		}
		playerCount = playerCount + 1
		teamCount = teamCount + 1
	end

	-- Add the AIs
	for i = 1, 3 do
		local shortName = aiConfig.aiLibFunctions.Circuit_difficulty_autofill(difficultySetting) .. bitExtension

		ais[aiCount] = {
			Name = "AI " .. i,
			Team = teamCount,
			IsFromDemo = 0,
			ShortName = shortName,
			comm_merge = 0,
			version = "stable",
			Host = 0,
			Options = {
				comm_merge = 0,
			}
		}
		aiCount = aiCount + 1
		teams[teamCount] = {
			TeamLeader = 0,
			AllyTeam = 1,
			rgbcolor = '0 0 0',
		}
		teamCount = teamCount + 1
	end

	-- Add allyTeams
	for i = 0, 1 do
		allyTeams[i] = {
			numallies = 0,
		}
	end

	local modoptions = {}
	for key, value in pairs(modoptions) do
		modoptions[key] = (type(value) == "table" and TableToBase64(value)) or value
	end

	local script = {
		gametype = gameName,
		mapname = mapName,
		myplayername = playerName,
		nohelperais = 0,
		numplayers = playerCount,
		numusers = playerCount + aiCount,
		startpostype = 2, -- Choose is required to make maps not crash due to undefined start positions.
		GameStartDelay = 0,
		modoptions = modoptions,
	}

	for i, ai in pairs(ais) do
		script["ai" .. i] = ai
	end
	for i, player in pairs(players) do
		script["player" .. i] = player
	end
	for i, team in pairs(teams) do
		script["team" .. i] = team
	end
	for i, allyTeam in pairs(allyTeams) do
		script["allyTeam" .. i] = allyTeam
	end

	WG.SteamCoopHandler.AttemptGameStart("roguek", gameName, mapName, script)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Display

local function InitializeMainDisplay(parent)
	local Configuration = WG.Chobby.Configuration

	local btnStart = Button:New {
		x = 150,
		y = 80,
		width = 178,
		height = 70,
		caption = i18n("start"),
		objectOverrideFont = Configuration:GetButtonFont(4),
		classname = "action_button",
		tooltip = "Starts a new run. Make sure Steam friends have already accepted their invites.",
		parent = parent,
		OnClick = {
			function()
				StartFreshGame()
			end
		},
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Ingame interface

local BATTLE_WON_STRING = "Campaign_PlanetBattleWon"
local BATTLE_LOST_STRING = "Campaign_PlanetBattleLost"
local BATTLE_RESIGN_STRING = "Campaign_PlanetBattleResign"
local LOAD_CAMPAIGN_STRING = "Campaign_LoadCampaign"

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:RecvLuaMsg(msg)
	if not msg then
		Spring.Echo("LUA_ERR", "Bad campaign message", msg)
		return
	end
	if string.find(msg, LOAD_CAMPAIGN_STRING) then
		local encoded = string.sub(msg, string.len(LOAD_CAMPAIGN_STRING) + 1)
		local saveData = Spring.Utilities.CustomKeyToUsefulTable(encoded)
		WG.CampaignData.ApplyCampaignPartialSaveData(saveData)
		WG.Chobby.interfaceRoot.OpenSingleplayerTabByName("campaign")
	elseif string.find(msg, BATTLE_WON_STRING) then
		Spring.Echo("msg", msg)
		local data = msg:split(" ")
		Spring.Utilities.TableEcho(data, "data")
		local planetID = tonumber(data[2])
		local battleFrames = tonumber(data[3])
		local bonusObjectives = data[4]
		local difficulty = tonumber(data[5]) or 0
		local losses = tonumber(data[6]) or 10000000
		if planetID and planetConfig and planetConfig[planetID] then
			ProcessPlanetVictory(planetID, battleFrames, MakeBonusObjectivesList(bonusObjectives), bonusObjectives, difficulty, losses)
		end
	elseif string.find(msg, BATTLE_LOST_STRING) then
		Spring.Echo("msg", msg)
		local data = msg:split(" ")
		Spring.Utilities.TableEcho(data, "data")
		local planetID = tonumber(data[2])
		local battleFrames = tonumber(data[3])
		if planetID and planetConfig and planetConfig[planetID] then
			ProcessPlanetDefeat(planetID, battleFrames)
		end
	elseif string.find(msg, BATTLE_RESIGN_STRING) then
		Spring.Echo("msg", msg)
		local data = msg:split(" ")
		Spring.Utilities.TableEcho(data, "data")
		local planetID = tonumber(data[2])
		local battleFrames = tonumber(data[3])
		if planetID and planetConfig and planetConfig[planetID] then
			ProcessPlanetResign(planetID, battleFrames)
		end
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- External Interface

local externalFunctions = {}

function externalFunctions.GetControl(newLiveTestingMode, newPlanetWhitelist, feedbackLink)
	local window = Control:New {
		name = "rogueHandler",
		x = 0,
		y = 0,
		width = "100%",
		height = "100%",
		padding = {0,0,0,0},
		OnParentPost = {
			function(obj, parent)
				if obj:IsEmpty() then
					InitializeDifficultySetting(obj)
					InitializeMainDisplay(obj)
				end

				local background = WG.Chobby.interfaceRoot.GetBackgroundHolder()
				background:SetImageOverride(GALAXY_IMAGE)
				local x, y = obj:LocalToScreen(0, 0)
				RepositionBackground(x, y, obj.width, obj.height)

				obj:UpdateClientArea()
				WG.Chobby.interfaceRoot.GetRightPanelHandler().CloseTabs()
				WG.Chobby.interfaceRoot.GetMainWindowHandler().CloseTabs()
				if WG.LibLobby.lobby and WG.LibLobby.lobby:GetMyBattleID() then
					WG.LibLobby.lobby:LeaveBattle()
				end
				DelayedViewResize()
				WG.Delay(DelayedViewResize, 0.1)
				WG.Delay(DelayedViewResize, 0.8)
			end
		},
		OnOrphan = {
			function(obj)
				if not obj.disposed then -- AutoDispose
					local background = WG.Chobby.interfaceRoot.GetBackgroundHolder()
					background:RemoveOverride()
				end
			end
		},
		OnResize = {
			function(obj, xSize, ySize)
				if not obj.parent then
					return
				end
				local x, y = obj:LocalToScreen(0, 0)
				RepositionBackground(x, y, xSize, ySize)
			end
		},
	}
	holderWindow = window
	return window
end


--------------------------------------------------------------------------------
-- Callins
--------------------------------------------------------------------------------

function widget:ViewResize(vsx, vsy)
	WG.Delay(DelayedViewResize, 0.1)
	WG.Delay(DelayedViewResize, 0.8)
end

function widget:Initialize()
	CHOBBY_DIR = "LuaMenu/widgets/chobby/"
	VFS.Include("LuaMenu/widgets/chobby/headers/exports.lua", nil, VFS.RAW_FIRST)
	WG.RogueHandler = externalFunctions
end

function widget:Shutdown()
	WG.RogueHandler = nil
end
