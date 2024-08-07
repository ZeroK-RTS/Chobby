--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function widget:GetInfo()
	return {
		name      = "Limit FPS",
		desc      = "Limits FPS to save idle CPU cycles",
		author    = "Licho",
		date      = "-306210.1318053026",
		license   = "GPL-v2",
		layer     = -3000,
		handler   = true,
		api       = true, -- Makes KeyPress occur before chili
		enabled   = true,
	}
end

local MAX_FPS = 5
local FAST_FPS = 40
local oldX, oldY

local lastTimer
local forceRedraw = false
local constantRedrawSeconds = false
local fastRedraw = false
local steamFastRedraw = false
local framesInBuffer = 0

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Externals Functions

local LimitFps = {}

function LimitFps.ForceRedraw()
	forceRedraw = true
end

function LimitFps.ForceRedrawPeriod(seconds)
	constantRedrawSeconds = math.max(seconds, constantRedrawSeconds or 0)
end

function LimitFps.SetSteamFastUpdate(enabled)
	steamFastRedraw = enabled
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Initialization

function widget:Initialize()
	lastTimer = Spring.GetTimer();
	LimitFps.ForceRedrawPeriod(4)

	WG.LimitFps = LimitFps
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Allow redraw handling and logic

local function IsMousePressed()
	local x,y, lmb, mmb, rmb = Spring.GetMouseState()
	return lmb or mmb or rmb
end

function widget:AllowDraw()
	local oldFramesInBuffer = framesInBuffer
	framesInBuffer = 1
	local config = WG.Chobby.Configuration
	if config.drawAtFullSpeed or steamFastRedraw then
		return true
	end
	if forceRedraw then
		forceRedraw = false
		fastRedraw = false
		return true
	end
	local timer = Spring.GetTimer()
	local diff = Spring.DiffTimers(timer, lastTimer)
	if constantRedrawSeconds and not IsMousePressed() then
		constantRedrawSeconds = constantRedrawSeconds - diff
		if constantRedrawSeconds <= 0 then
			constantRedrawSeconds = false
		end
	end
	if (fastRedraw or constantRedrawSeconds) and (diff >= 1/FAST_FPS) then
		fastRedraw = false
		lastTimer = timer
		return true
	elseif (diff >= 1/MAX_FPS) then
		lastTimer = timer
		return true
	end

	if (config.lobbyIdleSleep) then
		if (fastRedraw or constantRedrawSeconds) and oldFramesInBuffer < 3 then
			framesInBuffer = oldFramesInBuffer + 1
			return true
		end
	elseif oldFramesInBuffer < 3 then
		framesInBuffer = oldFramesInBuffer + 1
		return true
	end
	
	return false
end


local basememlimit = 200000
local garbagelimit = basememlimit -- in kilobytes, will adjust upwards as needed
local lastGCchecktime = Spring.GetTimer()

local function StrictGarbageCleanup()
	if Spring.DiffTimers(Spring.GetTimer(), lastGCchecktime) > 1 then
		lastGCchecktime = Spring.GetTimer()
		local ramuse = gcinfo()
		--Spring.Echo("RAMUSE",ramuse)
		if ramuse > garbagelimit then 
			collectgarbage("collect")
			collectgarbage("collect")
			local notgarbagemem = gcinfo()
			local newgarbagelimit = math.min(1000000, notgarbagemem + basememlimit) -- peak 1 GB
			Spring.Echo(string.format("Chobby Using %d MB RAM > %d MB limit, performing garbage collection to %d MB and adjusting limit to %d MB",
				math.floor(ramuse/1000), 
				math.floor(garbagelimit/1000), 
				math.floor(notgarbagemem/1000),
				math.floor(newgarbagelimit/1000) ) 
			)
			garbagelimit = newgarbagelimit
		end
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Force redraw on input or screen resize

function widget:Update()
	local x, y = Spring.GetMouseState()
	--Spring.Echo("Mouse", x, oldX, y, oldY)
	if x ~= oldX or y ~= oldY then
		fastRedraw = true
	end
	oldX, oldY = x, y
	StrictGarbageCleanup()
end

function widget:MousePress()
	forceRedraw = true
	LimitFps.ForceRedrawPeriod(2)
	return false
end

function widget:MouseRelease()
	forceRedraw = true
	LimitFps.ForceRedrawPeriod(2)
	return false
end

function widget:MouseWheel()
	forceRedraw = true
	return false
end

function widget:KeyPress()
	forceRedraw = true
	return false
end

function widget:ViewResize(vsx, vsy)
	forceRedraw = true
	LimitFps.ForceRedrawPeriod(0.5)
end
