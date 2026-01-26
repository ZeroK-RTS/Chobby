--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function widget:GetInfo()
	return {
		name      = "Ingame Interface",
		desc      = "Contains the interface between ingame and luaMenu",
		author    = "GoogleFrog",
		date      = "18 November 2016",
		license   = "GPL-v2",
		layer     = -0,
		handler   = true,
		api       = true,
		enabled   = true,
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

VFS.Include("libs/liblobby/lobby/json.lua")

local SEND_USER_CHANGE_MESSAGE = false

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Externals Functions

local externalFunctions = {}

function externalFunctions.SetLobbyOverlayActive(newActive)
	if Spring.SendLuaUIMsg then
		Spring.SendLuaUIMsg("LobbyOverlayActive" .. ((newActive and "1") or "0"))
	else
		Spring.Echo("Spring.SendLuaUIMsg does not exist in LuaMenu")
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Patterns to send

local LOBBY_CHAT_UPDATE = "LobbyChatUpdate_"

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Patterns to match

local TTT_SAY = "textToSpeechSay_"
local TTS_VOLUME = "textToSpeechVolume_"
local REMOVE_BUTTON = "disableLobbyButton"
local ENABLE_OVERLAY = "showLobby"
local LUAMENU_SETTING = "changeSetting "
local OPEN_SETTINGS_TAB = "openSettingsTab "
local LOAD_FILENAME = "loadFilename "
local RESTART_GAME = "restartGame"
local START_FROM_SCRIPT = "startFromScript_"
local GAME_INIT = "ingameInfoInit"
local GAME_START = "ingameInfoStart"
local REPORT_USER = "reportUser"
local AUTOSAVE_COMPLETE = "autosaveComplete"

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Utilities

local function ConvertString(str)
	if str == "true" then
		return true
	elseif str == "false" then
		return false
	elseif tonumber(str) then
		return tonumber(str)
	end
	return str
end

local function StringToDataTable(msg)
	local data = msg:split("_")
	local dataTable = {}
	local index = 3
	while data[index] do
		dataTable[data[index - 1]] = ConvertString(data[index])
		index = index + 2
	end
	return dataTable
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Text To Speech

local function HandleTextToSpeech(msg)
	local Configuration = WG.Chobby.Configuration
	if not Configuration.enableTextToSpeech then
		return false
	end

	if string.find(msg, TTT_SAY) == 1 then
		msg = string.sub(msg, 17)
		local nameEnd = string.find(msg, "%s")
		local name = string.sub(msg, 0, nameEnd)
		msg = string.sub(msg, nameEnd + 1)
		WG.WrapperLoopback.TtsSay(name, msg)
		return true
	end

	if string.find(msg, TTS_VOLUME) == 1 then
		msg = string.sub(msg, 20)
		WG.WrapperLoopback.TtsVolume(tonumber(msg) or 0)
		return true
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Lobby Overlay

local function HandleLobbyOverlay(msg)
	local Chobby = WG.Chobby
	--Spring.Echo("HandleLobbyOverlay", msg)
	local interfaceRoot = Chobby and Chobby.interfaceRoot
	if interfaceRoot then
		if msg == REMOVE_BUTTON then
			interfaceRoot.SetLobbyButtonEnabled(false)
			return true
		elseif msg == ENABLE_OVERLAY then
			Spring.Echo("HandleLobbyOverlay SetMainInterfaceVisibley")
			interfaceRoot.SetMainInterfaceVisible(true)
			return true
		end
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Settings

local function HandleSettingsChange(msg)
	if string.find(msg, LUAMENU_SETTING) ~= 1 then
		return
	end
	local Configuration = WG.Chobby.Configuration
	if Configuration then
		local data = msg:split(" ")
		if data[2] and data[3] then
			Configuration:SetSettingsConfigOption(data[2], tonumber(data[3]) or data[3])
		end
	end
end

local function HandleSettingsOpenTab(msg)
	if string.find(msg, OPEN_SETTINGS_TAB) ~= 1 then
		return
	end
	local data = msg:split(" ")
	if WG.Chobby.interfaceRoot then
		WG.Chobby.interfaceRoot.OpenRightPanelTab("settings")
		WG.Chobby.interfaceRoot.SetMainInterfaceVisible(true)
		if data[2] and WG.SettingsWindow then
			WG.SettingsWindow.OpenTab(data[2])
		end
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Load and Restart

local function HandleLoadGame(msg)
	if string.find(msg, LOAD_FILENAME) ~= 1 then
		return
	end
	local data = msg:split(" ")
	if WG.LoadGame and data and data[2] then
		WG.LoadGame.LoadGameByFilename(data[2])
	end
end

local function HandleRestartGame(msg)
	if string.find(msg, RESTART_GAME) ~= 1 then
		return
	end
	WG.SteamCoopHandler.RestartGame()
end

local function HandleStartFromScript(msg)
	if string.find(msg, START_FROM_SCRIPT) ~= 1 then
		return
	end
	msg = string.sub(msg, 17)
	Spring.Echo("msg", msg)
	local script = Spring.Utilities.CustomKeyToUsefulTable(msg)
	WG.SteamCoopHandler.AttemptGameStart("script", script.gametype, script.mapname, script)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Ingame Info

local function MsgToIngameData(msg)
	local data = msg:split("_")
	if tonumber(data[2]) then
		return {
			isPlayer = (data[2] == "1"),
			playerCount = tonumber(data[3]) or 0,
			teamOnePlayers = tonumber(data[4]) or 0,
			teamTwoPlayers = tonumber(data[5]) or 0,
			teamPlayers = tonumber(data[3]) or 0,
			isFFA = (data[6] == "1"),
			isReplay = (data[7] == "1"),
			isAI = (data[8] == "1"),
			isChicken = (data[9] == "1"),
			isCampaign = (data[10] == "1"),
			planetName = data[11],
		}
	end

	return StringToDataTable(msg)
end

local function HandleGameInfoInit(msg)
	if string.find(msg, GAME_INIT) ~= 1 then
		return
	end
	if WG.DiscordHandler then
		WG.DiscordHandler.SetIngameInfo(MsgToIngameData(msg))
	end
end

local function HandleGameInfoStart(msg)
	if string.find(msg, GAME_START) ~= 1 then
		return
	end
	local ingameData = MsgToIngameData(msg)
	if WG.DiscordHandler then
		WG.DiscordHandler.SetIngameInfo(ingameData)
	end
	if WG.QueueStatusPanel then
		WG.QueueStatusPanel.SetWantAutosaveFromGameData(ingameData)
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Reporting

local function HandleReport(msg)
	if string.find(msg, REPORT_USER) ~= 1 then
		return
	end
	local data = msg:split(";")
	if not (data and data[3]) then
		return
	end
	
	WG.ReportPanel.OpenReportWindow(data[2], data[3], true)
	return true
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Autosave

local function HandleAutosaveComplete(msg)
	if string.find(msg, AUTOSAVE_COMPLETE) ~= 1 then
		return
	end
	local data = msg:split("_")
	if not (data and data[2]) then
		return
	end

	if WG.QueueStatusPanel then
		local saveName = data[2]
		local delayAutosave = function ()
			WG.QueueStatusPanel.OnAutosaveComplete(saveName)
		end
		WG.Delay(delayAutosave, 1)
	end

	return true
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Battle room chat

local function ShouldSendLobbyUpdatesIngame()
	local Conf = WG.Chobby.Configuration
	if Conf.enableDebugBuffer then
		if Conf.debugLobbyGameChat then
			Spring.Echo("ShouldSendLobbyUpdatesIngame", "debug buffer")
		end
		return true
	end
	if Spring.GetGameName() == "" then
		if Conf.debugLobbyGameChat then
			Spring.Echo("ShouldSendLobbyUpdatesIngame", "GameName")
		end
		return false
	end
	local lobby = WG.LibLobby.lobby
	local myBattleID = lobby and lobby:GetMyBattleID()
	if not myBattleID then
		if Conf.debugLobbyGameChat then
			Spring.Echo("ShouldSendLobbyUpdatesIngame", "myBattleID")
		end
		return false
	end
	if Conf:IsLobbyVisible() then
		if Conf.debugLobbyGameChat then
			Spring.Echo("ShouldSendLobbyUpdatesIngame", "lobbyVisible")
		end
		return false
	end
	local battleIngame = lobby:GetBattle(myBattleID) and lobby:GetBattle(myBattleID).isRunning
	if Conf.debugLobbyGameChat then
		Spring.Echo("ShouldSendLobbyUpdatesIngame", "battleIngame", battleIngame)
	end
	return not battleIngame
end

local oldPlayerCount = false
local oldUsers = false

local function IsNewUserList(newUsers)
	if not oldUsers then
		oldUsers = Spring.Utilities.ShallowCopy(newUsers)
		return true
	end
	for i = 1, math.max(#newUsers, #oldUsers) do
		if newUsers[i] ~= oldUsers[i] then
			oldUsers = Spring.Utilities.ShallowCopy(newUsers)
			return true
		end
	end
	return false
end

local function PlayersUpdate(listeners, updatedBattleID)
	if not ShouldSendLobbyUpdatesIngame() then
		return
	end
	local lobby = WG.LibLobby.lobby
	if updatedBattleID ~= lobby:GetMyBattleID() then
		return
	end
	local battle = lobby:GetBattle(lobby:GetMyBattleID()) or {}
	local newPlayerCount = (lobby:GetBattlePlayerCount(updatedBattleID) or "??")
	local haveNewUsers = SEND_USER_CHANGE_MESSAGE and IsNewUserList(battle.users)
	if newPlayerCount == oldPlayerCount and not haveNewUsers then
		return
	end
	oldPlayerCount = newPlayerCount
	--Spring.Echo(LOBBY_CHAT_UPDATE .. " Players waiting " .. (lobby:GetBattlePlayerCount(updatedBattleID) or "??") .. "/" .. (battle.maxPlayers or "??"))
	if Spring.SendLuaUIMsg then
		if battle.users and #battle.users > 0 then
			Spring.SendLuaUIMsg(LOBBY_CHAT_UPDATE .. "Players waiting: " .. newPlayerCount .. "/" .. (battle.maxPlayers or "??"))
			if haveNewUsers then
				local userString = ""
				for i = 1, (#battle.users) - 1 do
					userString = userString .. (battle.users[i] or "??") .. ", "
				end
				userString = userString .. (battle.users[#battle.users] or "??")
				Spring.SendLuaUIMsg(LOBBY_CHAT_UPDATE .. userString)
			end
		end
	else
		Spring.Echo("Spring.SendLuaUIMsg does not exist in LuaMenu")
	end
end

local function HandleLobbySay(command, argumentsPos)
	if not argumentsPos then
		return
	end
	if (string.find(command, [["Place":1]]) or 0) < 1 then
		return
	end
	arguments = command:sub(argumentsPos + 1)
	local Conf = WG.Chobby.Configuration
	local success, cmdData = pcall(json.decode, arguments)
	if not success then
		Spring.Log(LOG_SECTION, LOG.ERROR, "Failed to parse JSON: " .. tostring(arguments))
		if Conf.debugLobbyGameChat then
			Spring.Echo("HandleLobbySay", "json fail")
		end
		return false
	end
	if cmdData.Place ~= 1 then
		if Conf.debugLobbyGameChat then
			Spring.Echo("HandleLobbySay", "Place ~= 1")
		end
		return false -- Not battle text
	end
	--Spring.Echo(LOBBY_CHAT_UPDATE .. "<" .. (cmdData.User or "unknown") .. "> " .. (cmdData.Text or ""))
	if Spring.SendLuaUIMsg then
		Spring.SendLuaUIMsg(LOBBY_CHAT_UPDATE .. (cmdData.User or "unknown") .. ": " .. (cmdData.Text or ""))
	else
		Spring.Echo("Spring.SendLuaUIMsg does not exist in LuaMenu")
	end
end

local function OnCommandBuffered(_, cmdName, command, argumentsPos)
	if not ShouldSendLobbyUpdatesIngame() then
		return
	end
	local Conf = WG.Chobby.Configuration
	if Conf.debugLobbyGameChat then
		Spring.Echo("OnCommandBuffered")
	end
	if cmdName == "Say" then
		HandleLobbySay(command, argumentsPos)
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Callins

function widget:RecvLuaMsg(msg)
	if HandleLobbyOverlay(msg) then
		return
	end
	if HandleTextToSpeech(msg) then
		return
	end
	if HandleSettingsChange(msg) then
		return
	end
	if HandleSettingsOpenTab(msg) then
		return
	end
	if HandleLoadGame(msg) then
		return
	end
	if HandleRestartGame(msg) then
		return
	end
	if HandleStartFromScript(msg) then
		return
	end
	if HandleGameInfoInit(msg) then
		return
	end
	if HandleGameInfoStart(msg) then
		return
	end
	if HandleReport(msg) then
		return
	end
	if HandleAutosaveComplete(msg) then
		return
	end
end


function widget:ActivateMenu()
	local Chobby = WG.Chobby
	local interfaceRoot = Chobby and Chobby.interfaceRoot

	-- Another game might be started without the ability to display lobby button.
	if interfaceRoot then
		interfaceRoot.SetLobbyButtonEnabled(true)
	end
end


function widget:ActivateGame()
end


function widget:Initialize()
	WG.IngameInterface = externalFunctions
	
	local lobby = WG.LibLobby.lobby
	lobby:AddListener("OnBattleAboutToStart", OnBattleStartMultiplayer)
	lobby:AddListener("OnCommandBuffered", OnCommandBuffered)
	lobby:AddListener("OnLeftBattle", PlayersUpdate)
	lobby:AddListener("OnJoinedBattle", PlayersUpdate)
	lobby:AddListener("OnUpdateBattleInfo", PlayersUpdate)
end
