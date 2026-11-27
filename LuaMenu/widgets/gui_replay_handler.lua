--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
	return {
		name      = "Replays window",
		desc      = "Handles local replays.",
		author    = "GoogleFrog",
		date      = "20 October 2016",
		license   = "GNU LGPL, v2.1 or later",
		layer     = -100000,
		enabled   = true  --  loaded by default?
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Local Variables

local PARTIAL_ADD_NUMBER = 50

local replayListWindow

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Utilities

local function CreateReplayEntry(replayPath, engineName, gameName, mapName)
	local Configuration = WG.Chobby.Configuration

	local fileName = string.sub(replayPath, 7)
	if string.sub(fileName, 0, 4) == "hide" then
		return
	end

	fileName = string.gsub(string.gsub(string.gsub(string.gsub(fileName, " BAR105", ""), " BAR", ""), " maintenance", ""), " develop", "")
	fileName = string.gsub(fileName, "%.sdfz", "")

	local t1, t2, t3, t4, t5 = string.match(fileName, "(%d%d%d%d)-?(%d%d)-?(%d%d)_(%d%d)-?(%d%d)")
	local replayTime = ((t1 and t2 and t3 and t4 and t5) and string.format("%s-%s-%s %s:%s", t1, t2, t3, t4, t5)) or fileName

	local replayPanel = Panel:New {
		x = 0,
		y = 0,
		width = "100%",
		resizable = false,
		draggable = false,
		padding = {0, 0, 0, 0},
	}

	local startButton = Button:New {
		x = 3,
		y = 3,
		bottom = 3,
		width = 65,
		caption = i18n("start"),
		classname = "small_action_button",
		objectOverrideFont = Configuration:GetButtonFont(2),
		OnClick = {
			function()
				if not replayPath then
					return
				end
				local offEngine = not WG.Chobby.Configuration:IsValidEngineVersion(engineName)
				WG.SteamCoopHandler.AttemptGameStart("replay", gameName, mapName, nil, nil, replayPath, offEngine and engineName)
			end
		},
		parent = replayPanel,
	}

	local replayDate = Label:New {
		name = "replayDate",
		x = 85,
		y = 15,
		right = 0,
		height = 16,
		valign = 'center',
		objectOverrideFont = Configuration:GetFont(2),
		caption = replayTime,
		parent = replayPanel,
	}
	local replayMap = Label:New {
		name = "replayMap",
		x = 305,
		y = 15,
		right = 0,
		height = 16,
		valign = 'center',
		objectOverrideFont = Configuration:GetFont(2),
		caption = mapName,
		parent = replayPanel,
	}
	local replayVersion = Label:New {
		name = "replayVersion",
		x = 535,
		y = 15,
		width = 400,
		height = 16,
		valign = 'center',
		objectOverrideFont = Configuration:GetFont(2),
		caption = gameName,
		parent = replayPanel,
	}
	--local replayEngine = TextBox:New {
	--	name = "replayEngine",
	--	x = 535,
	--	y = 16,
	--	width = 400,
	--	height = 20,
	--	valign = 'center',
	--	objectOverrideFont = Configuration:GetFont(2),
	--	text = engineName,
	--	parent = replayPanel,
	--}

	return replayPanel, {replayTime, string.lower(mapName), gameName}
end

local function RawReplaySort(a, b)
	local goodFormatA = (string.sub(a, 0, 8) == "demos\2")
	local goodFormatB = (string.sub(b, 0, 8) == "demos\2")
	if goodFormatA ~= goodFormatB then
		return goodFormatA
	end
	local newFormatA = (string.sub(a, 11, 11) == "-")
	local newFormatB = (string.sub(b, 11, 11) == "-")
	if newFormatA ~= newFormatB then
		return newFormatA
	end
	return a > b
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Controls

local function InitializeControls(parentControl)
	local Configuration = WG.Chobby.Configuration

	Label:New {
		x = 15,
		y = 11,
		width = 180,
		height = 30,
		parent = parentControl,
		objectOverrideFont = Configuration:GetFont(3),
		caption = "Replays",
	}

	local loadingPanel = Panel:New {
		classname = "overlay_window",
		x = "20%",
		y = "45%",
		right = "20%",
		bottom = "45%",
		parent = parentControl,
	}

	local loadingLabel = Label:New {
		x = "5%",
		y = "5%",
		width = "90%",
		height = "90%",
		align = "center",
		valign = "center",
		parent = loadingPanel,
		objectOverrideFont = Configuration:GetFont(3),
		caption = "Loading",
	}

	-------------------------
	-- Replay List
	-------------------------

	local listHolder = Control:New {
		x = 12,
		right = 15,
		y = 60,
		bottom = 15,
		parent = parentControl,
		resizable = false,
		draggable = false,
		padding = {0, 0, 0, 0},
	}

	local headings = {
		{name = "Time", x = 88, width = 207},
		{name = "Map", x = 300, width = 225},
		{name = "Version", x = 530, right = 5},
	}

	local replayList = WG.Chobby.SortableList(listHolder, headings, nil, nil, false)

	local PartialAddReplays, moreButton

	local function AddReplays()
		local replays = VFS.DirList("demos")
		table.sort(replays, RawReplaySort)
		Spring.Utilities.TableEcho(replays, "replaysList")

		replayList:Clear()

		if moreButton then
			moreButton:SetVisibility(true)
		end

		local index = 1
		PartialAddReplays = function()
			loadingPanel:SetVisibility(true)
			loadingPanel:BringToFront()
			local items = {}
			for i = 1, PARTIAL_ADD_NUMBER do
				if index >= #replays then
					if moreButton then
						moreButton:SetVisibility(false)
					end
					loadingPanel:SetVisibility(false)
					return
				end
				local replayPath = replays[index]
				WG.WrapperLoopback.ReadReplayInfo(replayPath)
				index = index + 1
			end

			loadingPanel:SetVisibility(false)
		end

		PartialAddReplays()
	end

	AddReplays()

	-------------------------
	-- Buttons
	-------------------------

	Button:New {
		right = 126,
		y = WG.TOP_BUTTON_Y,
		width = 110,
		height = WG.BUTTON_HEIGHT,
		caption = i18n("refresh"),
		objectOverrideFont = Configuration:GetButtonFont(3),
		classname = "option_button",
		parent = parentControl,
		OnClick = {
			function ()
				AddReplays()
			end
		},
	}

	moreButton = Button:New {
		right = 8,
		y = WG.TOP_BUTTON_Y,
		width = 110,
		height = WG.BUTTON_HEIGHT,
		caption = i18n("more"),
		objectOverrideFont = Configuration:GetButtonFont(3),
		classname = "option_button",
		parent = parentControl,
		OnClick = {
			function ()
				if PartialAddReplays then
					PartialAddReplays()
				end
			end
		},
	}
	--local btnClose = Button:New {
	--	right = 11,
	--	y = WG.TOP_BUTTON_Y,
	--	width = 80,
	--	height = WG.BUTTON_HEIGHT,
	--	caption = i18n("close"),
	--	objectOverrideFont = Configuration:GetButtonFont(3),
	--	classname = "negative_button",
	--	OnClick = {
	--		function()
	--			parentControl:Hide()
	--		end
	--	},
	--	parent = parentControl
	--}

	if WG.BrowserHandler and Configuration.gameConfig.link_replays ~= nil then
		Button:New {
			right = 244,
			y = WG.TOP_BUTTON_Y,
			width = 120,
			height = WG.BUTTON_HEIGHT,
			caption = i18n("download"),
			objectOverrideFont = Configuration:GetButtonFont(3),
			classname = "option_button",
			parent = parentControl,
			OnClick = {
				function ()
					WG.BrowserHandler.OpenUrl(Configuration.gameConfig.link_replays())
				end
			},
		}
	end

	local externalFunctions = {}

	function externalFunctions.AddReplay(replayPath, engine, game, map, script)
		local control, sortData = CreateReplayEntry(replayPath, engine, game, map)
		if control then
			replayList:AddItem(replayPath, control, sortData)
		end
	end

	return externalFunctions
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- External Interface

local ReplayHandler = {}

function ReplayHandler.GetControl()

	local window = Control:New {
		name = "replayHandler",
		x = "0%",
		y = "0%",
		width = "100%",
		height = "100%",
		OnParent = {
			function(obj)
				if obj:IsEmpty() then
					replayListWindow = InitializeControls(obj)
				end
			end
		},
	}
	return window
end

function ReplayHandler.ReadReplayInfoDone(path, engine, game, map, script)
	if not replayListWindow then
		return
	end
	replayListWindow.AddReplay(path, engine, game, map, script)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Widget Interface

local function DelayedInitialize()
	local Configuration = WG.Chobby.Configuration
	battleStartDisplay = Configuration.game_fullscree
end

function widget:Initialize()
	CHOBBY_DIR = LUA_DIRNAME .. "widgets/chobby/"
	VFS.Include(LUA_DIRNAME .. "widgets/chobby/headers/exports.lua", nil, VFS.RAW_FIRST)

	WG.Delay(DelayedInitialize, 1)

	WG.ReplayHandler = ReplayHandler
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
