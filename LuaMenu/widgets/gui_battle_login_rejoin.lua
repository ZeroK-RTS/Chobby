--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
	return {
		name      = "Battle Login Rejoin",
		desc      = "Handles battle rejoin popup.",
		author    = "GoogleFrog",
		date      = "8 March 2017",
		license   = "GNU LGPL, v2.1 or later",
		layer     = 0,
		enabled   = true  --  loaded by default?
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local function DelayedInitialize()
	local lobby = WG.LibLobby.lobby

	local function OnRejoinOption(listener, battleID)
		local function RejoinBattleFunc()
			lobby:RejoinBattle(battleID)
		end

		WG.Chobby.ConfirmationPopup(RejoinBattleFunc, i18n("still_in_game_rejoin"), nil, 315, 200, i18n("rejoin"), i18n("abandon"))
	end

	lobby:AddListener("OnRejoinOption", OnRejoinOption)
end

function widget:Initialize()
	CHOBBY_DIR = LUA_DIRNAME .. "widgets/chobby/"
	VFS.Include(LUA_DIRNAME .. "widgets/chobby/headers/exports.lua", nil, VFS.RAW_FIRST)
	WG.Delay(DelayedInitialize, 1)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
