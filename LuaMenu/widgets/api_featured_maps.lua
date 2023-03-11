--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
	return {
		name      = "Featured Maps API",
		desc      = "Access to featured maps (community.json > .MapItems).",
		author    = "moreginger",
		date      = "07 February 2021",
		license   = "GNU LGPL, v2.1 or later",
		layer     = -100000,
		enabled   = true
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local mapItems

local function ToMapType(mapItem)
	if mapItem.IsSpecial then
		return "Special"
	elseif mapItem.IsChickens then
		return "Chicken"
	elseif mapItem.IsFFA then
		return "FFA"
	elseif mapItem.Is1v1 then
		return "1v1"
	elseif mapItem.IsTeams then
		return "Team"
	end
	return "Special"
end

local function ToTerrainType(mapItem)
	if mapItem.WaterLevel == 3 then
		return "Sea"
	end
	local first
	if mapItem.Hills == 1 then
		first = "Flat "
	elseif mapItem.Hills == 2 then
		first = "Hilly "
	else
		first = "Mountainous "
	end
	local second
	if mapItem.WaterLevel == 1 then
		second = "land"
	else
		second = "mixed"
	end

	return first .. second
end

local function InitMapItems()
	if not mapItems then
		mapItems = WG.CommunityWindow and WG.CommunityWindow.LoadStaticCommunityData().MapItems or {}
		for i = 1, #mapItems do
			mapItems[i].MapType = ToMapType(mapItems[i])
			mapItems[i].TerrainType = ToTerrainType(mapItems[i])
		end
	end
end

local function All()
	InitMapItems()
	return mapItems
end

local function Get(name)
	InitMapItems()
	for i = 1, #mapItems do
		if mapItems[i].Name == name then
			return mapItems[i]
		end
	end
	return false
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- External Interface

local FeaturedMaps = {}
FeaturedMaps.All = All
FeaturedMaps.Get = Get

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Widget Interface

function widget:Initialize()
	WG.FeaturedMaps = FeaturedMaps
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
