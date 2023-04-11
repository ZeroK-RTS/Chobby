
function widget:GetInfo()
	return {
		name    = "ZK replay downloader",
		desc    = "Downloads and launches ZK replays",
		author  = "Anarchid, abma (http demo)",
		date    = "July 2016",
		license = "GNU GPL, v2 or later",
		layer   = 0,
		enabled = true,
	}
end

local url

function onLaunchReplay(wtf, replay, game, map, engine)
	local parsed = url.parse(replay)
	local localpath = parsed.path
	local replayFile = localpath:match("([^/]*)$")
	local restartEngine = (not WG.Chobby.Configuration:IsValidEngineVersion(engine)) and engine

	WG.SteamCoopHandler.AttemptGameStart("replay", game, map, nil, nil, replayFile, restartEngine, true)
end

function widget:Initialize()
	CHOBBY_DIR = LUA_DIRNAME .. "widgets/chobby/"
	VFS.Include(LUA_DIRNAME .. "widgets/chobby/headers/exports.lua", nil, VFS.RAW_FIRST)
	url = VFS.Include("libs/neturl/url.lua")
	lobby:AddListener("OnLaunchRemoteReplay", onLaunchReplay)
end
