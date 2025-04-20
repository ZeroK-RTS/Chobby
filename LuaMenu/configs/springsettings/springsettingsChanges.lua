local settings = {
	FontOutlineWidth = 2,
	FontSize = 18,
	SmallFontSize = 14,
	OverheadMaxHeightFactor = 1.4,
	HangTimeout = 30,
	ROAM = 1,
	SplashScreenDir = "./MenuLoadscreens",
	UseDistToGroundForIcons = 1.1,
	
	UseLuaMemPools = 0,
	VFSCacheArchiveFiles = 0,
	UnitLodDist = 999999,
	
	-- Remove when desync bug is sorted.
	-- If there is no memory of such a thing, it is time.
	AnimationMT = 0,
	UpdateBoundingVolumeMT = 0,
	UpdateWeaponVectorsMT = 0,
}

local onlyIfMissingSettings = {
	FeatureDrawDistance = 600000,
	FeatureFadeDistance = 600000,
}

local onlyIfOutdated = {
	LuaGarbageCollectionMemLoadMult = 2.5,
	LuaGarbageCollectionRunTimeMult = 1.5,
}

local onlyIfValueBelow = {
	MaxTextureAtlasSizeX = 4096,
	MaxTextureAtlasSizeY = 4096,
}

local settingsVersion = 1

return settings, onlyIfMissingSettings, onlyIfOutdated, onlyIfValueBelow, settingsVersion
