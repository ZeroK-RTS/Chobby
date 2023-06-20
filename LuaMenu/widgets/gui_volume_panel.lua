--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
	return {
		name      = "Chobby Volume Panel",
		desc      = "Ports the EpicMenu volume/clock panel to chobby",
		author    = "Birdulon",
		date      = "2020-10-07",
		license   = "GNU GPL, v2 or later",
		layer     = 0,
-- 		handler   = true,
		enabled   = true,
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local IMAGE_DIR          = LUA_DIRNAME .. "images/"
local IMAGE_VOLUME       = IMAGE_DIR .. "vol.png"
local IMAGE_VOL_MUSIC    = IMAGE_DIR .. "vol_music.png"
local IMAGE_CLOCK        = IMAGE_DIR .. "clock.png"

local INVISIBLE_COLOR = {0, 0, 0, 0}
local TEXT_COLOR = {1, 1, 1, 1}

local spGetConfigInt = Spring.GetConfigInt
local spSetConfigInt = Spring.SetConfigInt
local spEcho = Spring.Echo
local Configuration

local VolumePanel = {}
local trackbarVolume
local trackbarMusic
local lblClock


local function InitializeControls(window)
	local sliderWidth = 96

	--------------------------------------------------------------------------------
	-- Make Widgets
	local imageVolume = Image:New{tooltip = 'Volume', file = IMAGE_VOLUME, width = 16, height = 16}
	local imageMusic = Image:New{tooltip = 'Music', file = IMAGE_VOL_MUSIC, width = 16, height = 16}
	local imageClock = Image:New{file = IMAGE_CLOCK, width = 20, height = 26}

	lblClock = Label:New{name = 'lblClock', caption = 'Clock', width = 45, height = 26, textColor = TEXT_COLOR}
	trackbarVolume = Trackbar:New{
		tooltip = 'Volume',
		height = 16,
		width = sliderWidth,
		trackColor = TEXT_COLOR,
		value = spGetConfigInt("snd_volmaster", 50),
		OnChange = {
			function(self)
					spSetConfigInt("snd_volmaster", self.value)
			end
		},
	}
	trackbarMusic = Trackbar:New{
		tooltip = 'Music',
		height = 16,
		width = sliderWidth,
		min = 0,
		max = 1,
		step = 0.01,
		trackColor = TEXT_COLOR,
		value = WG.Chobby.Configuration.menuMusicVolume or 0.0,
		OnChange = {
			function(self)
				WG.Chobby.Configuration:SetConfigValue("menuMusicVolume", self.value)
			end
		},
	}

	--------------------------------------------------------------------------------
	-- Make Sublayouts
	local stackClock = StackPanel:New{
		orientation = 'horizontal',
		width = 62,
		height = '100%',
		resizeItems = false,
		autoArrangeV = false,
		autoArrangeH = false,
		padding = {0, 2, 0, 0},
		itemMargin = {1, 0, 0, 0},
		children = {imageClock, lblClock},
-- 		parent = window,
	}
	local gridVolume = Grid:New{
		height = '100%',
		width = sliderWidth + 25,
		columns = 2,
		rows = 2,
		resizeItems = false,
		margin = {0, 0, 0, 0},
		padding = {0, 0, 0, 0},
		itemPadding = {0, 0, 0, 0},
		itemMargin = {0, 0, 0, 0},
		children = {imageVolume, trackbarVolume, imageMusic, trackbarMusic},
-- 		parent = window,
	}

	--------------------------------------------------------------------------------
	-- Make Layout
	local stackFull = StackPanel:New{
		orientation = 'horizontal',
		width = '100%',
		height = 32,
		resizeItems = false,
		autoArrangeV = false,
		autoArrangeH = false,
		padding = {0, 0, 0, 0},
		itemMargin = {0, 0, 0, 0},
		children = {gridVolume, stackClock},
		parent = window,
	}
end


function VolumePanel.GetControl()
	local window = Control:New {
		x = 0,
		y = 0,
		right = 0,
		bottom = 0,
		padding = {0, 0, 0, 0},
		OnParent = {
			function(obj)
				if obj:IsEmpty() then
					InitializeControls(obj)
				end
			end
		},
	}
	-- Other setup that we can only do once Chobby has loaded stuff
	--Configuration = WG.Chobby.Configuration
	--Configuration:AddListener("OnConfigurationChange", onConfigurationChange)
	return window
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Widget Updates
local function updateTrackbarVolume(value)
	if value then
		trackbarVolume.value = value
		trackbarVolume.tooltip = string.format("Volume (%d%%)", value)
	end
end

local function updateTrackbarMusic(value)
	if value then
		trackbarMusic.value = value
		trackbarMusic.tooltip = string.format("Music (%d%%)", math.floor(value*100))
	end
end

-- local function onConfigurationChange(listener, key, value)
-- 	if key == "menuMusicVolume" then
-- 		updateTrackbarMusic(value)
-- 	end
-- end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Widget Interface
local dLastSync = 0
function widget:Update()
	dLastSync = dLastSync + 1
	if dLastSync < 10 then -- Only run this stuff every 10 updates
		return
	end
	dLastSync = 0

	if lblClock then
		lblClock:SetCaption(os.date("%H:%M"))
	end

	updateTrackbarVolume(spGetConfigInt("snd_volmaster"))
	updateTrackbarMusic(WG.Chobby.Configuration.menuMusicVolume)
end

function widget:Initialize()
	-- Very limited initialization as many things aren't available until GetControl()
	VFS.Include(LUA_DIRNAME .. "widgets/chobby/headers/exports.lua", nil, VFS.RAW_FIRST)
	WG.VolumePanel = VolumePanel
end

function widget:Shutdown()
-- 	if Configuration then
-- 		Configuration:RemoveListener("OnConfigurationChange", onConfigurationChange)
-- 	end
end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
