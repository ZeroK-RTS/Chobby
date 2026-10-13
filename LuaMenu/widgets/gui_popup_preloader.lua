function widget:GetInfo()
	return {
		name    = 'Popup Preloader',
		desc    = 'Preloads popups which otherwise take too long to load.',
		author  = 'GoogleFrog',
		date    = '19 October 2016',
		license = 'GNU GPL v2',
		layer   = 0,
		enabled = true,
	}
end

local oldGameName
local oldEngineName
local aiListWindow
local aiPopup

local showOldAiVersions = false
local simpleAiList2 = true

--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- AI List window updating

local function UpdateAiListWindow(gameName, engineName)
	if aiPopup then
		aiPopup:ClosePopup()
	end
	if aiListWindow then
		aiListWindow.window:Dispose()
		aiListWindow:unregister()
	end
	aiListWindow = WG.Chobby.AiListWindow(gameName, engineName)
	aiListWindow.window:Hide()
end

--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Initialization

local function InitializeListeners(battleLobby)
	local function OnUpdateBattleInfo(listener, updatedBattleID, spectatorCount, locked, mapHash, mapName,
			engineVersion, runningSince, gameName, battleMode, disallowCustomTeams, disallowBots, isMatchMaker, newPlayerList, maxPlayers, title)

		if updatedBattleID ~= battleLobby:GetMyBattleID() then
			return
		end
		local newGameName = battleLobby:GetBattle(updatedBattleID).gameName
		local newEngineName = battleLobby:GetBattle(updatedBattleID).engineName
		if newGameName == oldGameName and newEngineName == oldEngineName then
			return
		end
		oldGameName = newGameName
		oldEngineName = newEngineName
		UpdateAiListWindow(newGameName, newEngineName)
	end

	local function OnJoinedBattle(listener, joinedBattleId, userName)
		if userName ~= battleLobby:GetMyUserName() then
			return
		end
		local newGameName = battleLobby:GetBattle(updatedBattleID).gameName
		local newEngineName = battleLobby:GetBattle(updatedBattleID).engineName
		if newGameName == oldGameName and newEngineName == oldEngineName then
			return
		end
		oldGameName = newGameName
		oldEngineName = newEngineName
		UpdateAiListWindow(newGameName, newEngineName)
	end

	battleLobby:AddListener("OnUpdateBattleInfo", OnUpdateBattleInfo)
	battleLobby:AddListener("OnJoinedBattle", OnJoinedBattle)
end

--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- External Functions

local PopupPreloader = {}

function PopupPreloader.ShowAiListWindow(battleLobby, newGameName, newEngineName, teamIndex, quickAddAi)
	local conf = WG.Chobby.Configuration
	if newGameName ~= oldGameName or newEngineName ~= oldEngineName or conf.showOldAiVersions ~= showOldAiVersions or conf.simpleAiList2 ~= simpleAiList2 then
		oldGameName = newGameName
		oldEngineName = newEngineName
		showOldAiVersions = conf.showOldAiVersions
		simpleAiList2 = conf.simpleAiList2
		UpdateAiListWindow(newGameName, newEngineName)
	end

	aiListWindow:SetLobbyAndAllyTeam(battleLobby, teamIndex)
	if quickAddAi and aiListWindow:QuickAdd(quickAddAi) then
		return
	end

	aiListWindow.window:Show()
	aiListWindow.window:SetPos(nil, nil, 500, 700)
	aiPopup = WG.Chobby.PriorityPopup(aiListWindow.window, nil, nil, nil, true)
end

--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Initialization
local function DelayedInitialize()
	--InitializeListeners(WG.LibLobby.localLobby)
	--InitializeListeners(WG.LibLobby.lobby)
end

function widget:Initialize()
	CHOBBY_DIR = LUA_DIRNAME .. "widgets/chobby/"
	VFS.Include(LUA_DIRNAME .. "widgets/chobby/headers/exports.lua", nil, VFS.RAW_FIRST)

	WG.PopupPreloader = PopupPreloader

	WG.Delay(DelayedInitialize, 1)
end
