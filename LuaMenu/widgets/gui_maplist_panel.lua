function widget:GetInfo()
	return {
		name    = 'Maplist Panel',
		desc    = 'Implements the map panel.',
		author  = 'GoogleFrog',
		date    = '29 July 2016',
		license = 'GNU GPL v2',
		layer   = 0,
		enabled = true,
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Local Variables

local loadRate = 1
local mapListWindow
local lobby
local wgChobbyConfig
local listFont
local oldOnlyFeaturedMaps = nil
local IMG_READY    = LUA_DIRNAME .. "images/ready.png"
local IMG_UNREADY  = LUA_DIRNAME .. "images/unready.png"

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Utilities

local function CreateMapEntry(mapName, mapData, CloseFunc)--{"ResourceID":7098,"Name":"2_Mountains_Battlefield","SupportLevel":2,"Width":16,"Height":16,"IsAssymetrical":false,"Hills":2,"WaterLevel":1,"Is1v1":false,"IsTeams":true,"IsFFA":false,"IsChickens":false,"FFAMaxTeams":null,"RatingCount":3,"RatingSum":10,"IsSpecial":false},
	local mapButton = Button:New {
		classname = "button_rounded",
		x = 0,
		y = 0,
		width = "100%",
		caption = "",
		resizable = false,
		draggable = false,
		padding = {0, 0, 0, 0},
		OnClick = {
			function()
				if lobby then
					lobby:SelectMap(mapName)
					CloseFunc()
				end
			end
		},
	}

	local mapImageFile, needDownload = wgChobbyConfig:GetMinimapSmallImage(mapName)
	Image:New {
		name = "minimapImage",
		x = 3,
		y = 3,
		width = 52,
		height = 52,
		padding = {1,1,1,1},
		keepAspect = true,
		file = mapImageFile,
		fallbackFile = (needDownload and wgChobbyConfig:GetLoadingImage(2)) or nil,
		checkFileExists = needDownload,
		parent = mapButton,
	}

	Label:New {
		x = 65,
		y = 15,
		width = 200,
		height = 16,
		valign = 'center',
		objectOverrideFont = listFont,
		caption = mapName:gsub("_", " "),
		parent = mapButton,
	}

	local haveMap = VFS.HasArchive(mapName)
	local imHaveGame = Image:New {
		x = 612,
		y = 12,
		width = 20,
		height = 20,
		file = (haveMap and IMG_READY) or IMG_UNREADY,
		parent = mapButton,
	}

	local sortData
	if mapData then
		local mapSizeText = (mapData.Width or " ?") .. "x" .. (mapData.Height or " ?")
		local mapType = mapData.MapType
		local terrainType = mapData.TerrainType

		Label:New {
			x = 274,
			y = 15,
			width = 68,
			height = 16,
			valign = 'center',
			objectOverrideFont = listFont,
			caption = mapSizeText,
			parent = mapButton,
		}
		Label:New {
			x = 356,
			y = 15,
			width = 68,
			height = 16,
			valign = 'center',
			objectOverrideFont = listFont,
			caption = mapType,
			parent = mapButton,
		}
		Label:New {
			x = 438,
			y = 15,
			width = 160,
			height = 16,
			valign = 'center',
			objectOverrideFont = listFont,
			caption = terrainType,
			parent = mapButton,
		}

		sortData = {string.lower(mapName), (mapData.Width or 0)*100 + (mapData.Height or 0), string.lower(mapType), string.lower(terrainType), (haveMap and 1) or 0}
		sortData[6] = sortData[1] .. " " .. mapSizeText .. " " .. sortData[3] .. " " .. sortData[4] -- Used for text filter by name, type, terrain or size.
	else
		sortData = {string.lower(mapName), 0, "", "", (haveMap and 1) or 0}
		sortData[6] = sortData[1]
	end

	local externalFunctions = {}

	function externalFunctions.UpdateHaveMap()
		haveMap = VFS.HasArchive(mapName)
		imHaveGame.file = (haveMap and IMG_READY) or IMG_UNREADY
		imHaveGame:Invalidate()
		sortData[5] = (haveMap and 1) or 0 -- This line is pretty evil.
	end

	return mapButton, sortData, externalFunctions
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Controls

local function InitializeControls()
	-- ghetto profiling to prove the maplist is a memory hog
	--local lmkb, lmalloc, lgkb, lgalloc = Spring.GetLuaMemUsage()
	--Spring.Echo("LuaMenu KB", lmkb, "allocs", lmalloc, "Lua global KB", lgkb, "allocs", lgalloc)

	wgChobbyConfig = WG.Chobby.Configuration

	listFont = wgChobbyConfig:GetFont(2)

	local mapListWindow = Window:New {
		classname = "main_window",
		parent = WG.Chobby.lobbyInterfaceHolder,
		height = 700,
		width = 700,
		resizable = false,
		draggable = false,
		padding = {2, 2, 2, 2},
	}
	mapListWindow:Hide()

	Label:New {
		x = 20,
		right = 5,
		y = WG.TOP_LABEL_Y,
		height = 20,
		parent = mapListWindow,
		objectOverrideFont = wgChobbyConfig:GetFont(3),
		caption = "Select a Map",
	}

	local function CloseFunc()
		mapListWindow:Hide()
	end

	local filterTerms
	local function ItemInFilter(sortData)
		if not filterTerms then
			return true
		end

		local textToSearch = sortData[6]
		for i = 1, #filterTerms do
			if not string.find(textToSearch, filterTerms[i]) then
				return false
			end
		end
		return true
	end
	--local loadingPanel = Panel:New {
	--	classname = "overlay_window",
	--	x = "20%",
	--	y = "45%",
	--	right = "20%",
	--	bottom = "45%",
	--	parent = parentControl,
	--}
	--
	--local loadingLabel = Label:New {
	--	x = "5%",
	--	y = "5%",
	--	width = "90%",
	--	height = "90%",
	--	align = "center",
	--	valign = "center",
	--	parent = loadingPanel,
	--	objectOverrideFont = Configuration:GetFont(3),
	--	caption = "Loading",
	--}

	-------------------------
	-- Map List
	-------------------------

	local listHolder = Control:New {
		x = 12,
		right = 15,
		y = 54,
		bottom = 15,
		parent = mapListWindow,
		resizable = false,
		draggable = false,
		padding = {0, 0, 0, 0},
	}

	local headings = {
		{name = "Name", x = 62, width = 208},
		{name = "Size", x = 272, width = 80},
		{name = "Type", x = 354, width = 80},
		{name = "Terrain", x = 436, width = 172},
		{name = "", tooltip = "Downloaded", x = 610, width = 40, image = "LuaMenu/images/download.png"},
	}

	local featuredMapList = WG.FeaturedMaps and WG.FeaturedMaps.All() or {}
	local mapFuncs = {}
	local mapList = WG.Chobby.SortableList(listHolder, headings, 60, 1, true, false, ItemInFilter)

	local featuredMapIndex = 1
	local function AddTheNextBatchOfMaps()
		local mapItems = {}
		local control, sortData
		for i = 1, loadRate do
			if featuredMapList[featuredMapIndex] then
				local mapName = featuredMapList[featuredMapIndex].Name
				control, sortData, mapFuncs[mapName] = CreateMapEntry(mapName, featuredMapList[featuredMapIndex], CloseFunc)
				mapItems[#mapItems + 1] = {mapName, control, sortData}
				featuredMapIndex = featuredMapIndex + 1
			end
		end
		mapList:AddItems(mapItems)

		if featuredMapList[featuredMapIndex] then
			WG.Delay(AddTheNextBatchOfMaps, 0.1)
		elseif not wgChobbyConfig.onlyShowFeaturedMaps then
			for i, archive in pairs(VFS.GetAllArchives()) do
				local info = VFS.GetArchiveInfo(archive)
				if info and info.modtype == 3 and not mapFuncs[info.name] then
					control, sortData, mapFuncs[info.name] = CreateMapEntry(info.name, nil, CloseFunc)
					mapItems[#mapItems + 1] = {info.name, control, sortData}
				end
			end
			mapList:AddItems(mapItems)
		end
	end

	WG.Delay(AddTheNextBatchOfMaps, 0.5 / loadRate)

	-------------------------
	-- Buttons
	-------------------------

	local btnClose = Button:New {
		right = 11,
		y = WG.TOP_BUTTON_Y,
		width = 80,
		height = WG.BUTTON_HEIGHT,
		caption = i18n("close"),
		objectOverrideFont = wgChobbyConfig:GetFont(3),
		classname = "negative_button",
		parent = mapListWindow,
		OnClick = {
			function()
				CloseFunc()
			end
		},
	}

	if wgChobbyConfig.gameConfig.link_maps ~= nil then
		Button:New {
			right = 98,
			y = WG.TOP_BUTTON_Y,
			width = 180,
			height = WG.BUTTON_HEIGHT,
			caption = i18n("download_maps"),
			objectOverrideFont = wgChobbyConfig:GetFont(3),
			classname = "option_button",
			parent = mapListWindow,
			OnClick = {
				function ()
					WG.BrowserHandler.OpenUrl(wgChobbyConfig.gameConfig.link_maps())
				end
			},
		}
	end

	-------------------------
	-- Filtering
	-------------------------

	local ebFilter = EditBox:New {
		right = 288,
		y = 13,
		width = 180,
		height = 33,
		text = '',
		hint = i18n("type_to_filter"),
		objectOverrideFont = wgChobbyConfig:GetFont(2),
		objectOverrideHintFont = wgChobbyConfig:GetHintFont(2),
		parent = mapListWindow,
		OnKeyPress = {
			function(obj, key, ...)
				if key ~= Spring.GetKeyCode("enter") and key ~= Spring.GetKeyCode("numpad_enter") then
					return
				end
				local visibleItemIds = mapList:GetVisibleItemIds()
				if #visibleItemIds[1] and lobby then
					lobby:SelectMap(visibleItemIds[1])
					CloseFunc()
				end
			end
		},
		OnTextModified = {
			function (self)
				filterTerms = string.lower(self.text):split(" ")
				mapList:RecalculateDisplay()
			end
		}
	}

	-------------------------
	-- External Funcs
	-------------------------

	local externalFunctions = {}

	function externalFunctions.Show(zoomToMap)
		ebFilter:Clear()
		mapList:RecalculateDisplay()

		if not mapListWindow.visible then
			mapListWindow:Show()
		end
		WG.Chobby.PriorityPopup(mapListWindow, CloseFunc)
		if zoomToMap then
			mapList:ScrollToItem(zoomToMap)
		end
		screen0:FocusControl(ebFilter)
	end

	function externalFunctions.UpdateHaveMap(thingName)
		if mapFuncs[thingName] then
			mapFuncs[thingName].UpdateHaveMap()
		elseif not wgChobbyConfig.onlyShowFeaturedMaps and VFS.HasArchive(thingName) then
			local info = VFS.GetArchiveInfo(thingName)
			if info and info.modtype == 3 and not mapFuncs[info.name] then
				local control, sortData
				control, sortData, mapFuncs[info.name] = CreateMapEntry(info.name, nil, CloseFunc)
				mapList:AddItem(info.name, control, sortData)
			end
		end
	end

	return externalFunctions
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- External Interface

local MapListPanel = {}

function MapListPanel.Show(newLobby, zoomToMap)
	lobby = newLobby
	loadRate = 40
	local Configuration = WG.Chobby.Configuration
	if (oldOnlyFeaturedMaps ~= Configuration.onlyShowFeaturedMaps) or not mapListWindow then
		oldOnlyFeaturedMaps = Configuration.onlyShowFeaturedMaps
		mapListWindow = InitializeControls()
	end
	mapListWindow.Show(zoomToMap)
end

function MapListPanel.Preload()
	if not mapListWindow then
		mapListWindow = InitializeControls()
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Widget Interface

function widget:Initialize()
	CHOBBY_DIR = LUA_DIRNAME .. "widgets/chobby/"
	VFS.Include(LUA_DIRNAME .. "widgets/chobby/headers/exports.lua", nil, VFS.RAW_FIRST)

	local function DownloadFinished(_, id, thingName)
		if mapListWindow then
			mapListWindow.UpdateHaveMap(thingName)
		end
	end
	WG.DownloadHandler.AddListener("DownloadFinished", DownloadFinished)

	WG.MapListPanel = MapListPanel
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
