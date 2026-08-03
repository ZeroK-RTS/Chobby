function widget:GetInfo()
	return {
		name    = 'Modoptions Panel',
		desc    = 'Implements the modoptions panel.',
		author  = 'GoogleFrog',
		date    = '29 July 2016',
		license = 'GNU GPL v2',
		layer   = 0,
		enabled = true,
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Structure
local modoptionDefaults = {}
local modoptionStructure = {}

-- Variables
local battleLobby
local localModoptions = {}
local modoptionControlNames = {}
local modoptionsCache = {}
local currentGameName = false

local hostedModeName
local wantedGameResponse = false

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Utility Function

local function UpdateControlValue(key, value)
	if not modoptionControlNames then
		return
	end
	local control = modoptionControlNames[key]
	if control then
		if control.SetText then -- editbox
			control:SetText(value)
			control:FocusUpdate()
		elseif control.Select and control.itemKeyToName then -- combobox
			control:Select(control.itemKeyToName[value])
		elseif control.SetToggle then -- checkbox
			control:SetToggle(value == true or value == 1 or value == "1")
		end
	else
		localModoptions[key] = value
	end
end

local function TextFromNum(num, step)
	-- remove excess accuracy
	local places = 0
	if step < 0.01  then
		places = 3
	elseif step < 0.1 then
		places = 2
	elseif step < 1 then
		places = 1
	end
	local text = string.format("%." .. places .. "f", num)

	-- remove trailing 0s
	while text:find("%.") and (text:find("0", text:len()) or text:find("%.", text:len())) do
		text = text:sub(0, text:len() - 1)
	end

	return text
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Option Control Handling

local function ProcessListOption(data, index)
	local label = Label:New {
		x = 5,
		y = 0,
		width = 350,
		height = 26,
		valign = "center",
		align = "left",
		caption = data.name,
		objectOverrideFont = WG.Chobby.Configuration:GetFont(2),
		tooltip = data.desc,
	}

	local defaultItem = 1
	local defaultKey = localModoptions[data.key] or data.def

	local items = {}
	local itemNameToKey = {}
	local itemKeyToName = {}
	for i, itemData in pairs(data.items) do
		items[i] = itemData.name
		itemNameToKey[itemData.name] = itemData.key
		itemKeyToName[itemData.key] = itemData.name

		if itemData.key == defaultKey then
			defaultItem = i
		end
	end

	local list = ComboBox:New {
		x = 340,
		y = 1,
		width = 180,
		height = 30,
		items = items,
		objectOverrideFont = WG.Chobby.Configuration:GetFont(2),
		tooltip = data.desc,
		selectByName = true,
		selected = defaultItem,
		OnSelectName = {
			function (obj, selectedName)
				localModoptions[data.key] = itemNameToKey[selectedName]
			end
		},
		itemKeyToName = itemKeyToName -- Not a chili key
	}
	modoptionControlNames[data.key] = list

	return Control:New {
		x = 0,
		y = index*32,
		width = 600,
		height = 32,
		padding = {0, 0, 0, 0},
		children = {
			label,
			list
		}
	}
end

local function ProcessBoolOption(data, index)
	local checked = false
	if localModoptions[data.key] == nil then
		if modoptionDefaults[data.key] == "1" then
			checked = true
		end
	elseif localModoptions[data.key] == "1" then
		checked = true
	end

	local checkBox = Checkbox:New {
		x = 5,
		y = index*32,
		width = 355,
		height = 28,
		boxalign = "right",
		boxsize = 20,
		caption = data.name,
		checked = checked,
		objectOverrideFont = WG.Chobby.Configuration:GetFont(2),
		tooltip = data.desc,

		OnChange = {
			function (obj, newState)
				localModoptions[data.key] = tostring((newState and 1) or 0)
			end
		},
	}
	modoptionControlNames[data.key] = checkBox

	return checkBox
end

local function ProcessNumberOption(data, index)

	local label = Label:New {
		x = 5,
		y = 0,
		width = 350,
		height = 26,
		valign = "center",
		align = "left",
		caption = data.name,
		objectOverrideFont = WG.Chobby.Configuration:GetFont(2),
		tooltip = data.desc,
	}

	local oldText = localModoptions[data.key] or modoptionDefaults[data.key]

	local numberBox = EditBox:New {
		x = 340,
		y = 1,
		width = 180,
		height = 30,
		text   = oldText,
		useIME = false,
		objectOverrideFont = WG.Chobby.Configuration:GetFont(2),
		objectOverrideHintFont = WG.Chobby.Configuration:GetHintFont(2),
		tooltip = data.desc,
		OnFocusUpdate = {
			function (obj)
				if obj.focused then
					return
				end

				local newValue = tonumber(obj.text)

				if not newValue then
					obj:SetText(oldText)
					return
				end

				-- Bound the number
				newValue = math.min(data.max, math.max(data.min, newValue))
				-- Round to step size
				newValue = math.floor(newValue/data.step + 0.49)*data.step + 0.01*data.step

				oldText = TextFromNum(newValue, data.step)
				localModoptions[data.key] = oldText
				obj:SetText(oldText)
			end
		}
	}
	modoptionControlNames[data.key] = numberBox

	return Control:New {
		x = 0,
		y = index*32,
		width = 600,
		height = 32,
		padding = {0, 0, 0, 0},
		children = {
			label,
			numberBox
		}
	}
end

local function ProcessStringOption(data, index)

	local label = Label:New {
		x = 5,
		y = 0,
		width = 350,
		height = 26,
		valign = "center",
		align = "left",
		caption = data.name,
		objectOverrideFont = WG.Chobby.Configuration:GetFont(2),
		tooltip = data.desc,
	}

	local oldText = localModoptions[data.key] or modoptionDefaults[data.key]

	local textBox = EditBox:New {
		x = 340,
		y = 1,
		width = 180,
		height = 30,
		text   = oldText,
		useIME = false,
		tooltip = data.desc,
		objectOverrideFont = WG.Chobby.Configuration:GetFont(2),
		objectOverrideHintFont = WG.Chobby.Configuration:GetHintFont(2),
		OnFocusUpdate = {
			function (obj)
				if obj.focused then
					return
				end
				localModoptions[data.key] = obj.text
			end
		}
	}
	modoptionControlNames[data.key] = textBox

	return Control:New {
		x = 0,
		y = index*32,
		width = 600,
		height = 32,
		padding = {0, 0, 0, 0},
		children = {
			label,
			textBox
		}
	}
end

local function PopulateTab(options)
	-- list = combobox
	-- bool = tickbox
	-- number = sliderbar (with label)
	-- string = editBox

	local contentsPanel = ScrollPanel:New {
		x = 6,
		right = 5,
		y = 10,
		bottom = 8,
		horizontalScrollbar = false,
	}

	for i = 1, #options do
		local data = options[i]
		if data.type == "list" then
			contentsPanel:AddChild(ProcessListOption(data, #contentsPanel.children))
		elseif data.type == "bool" then
			contentsPanel:AddChild(ProcessBoolOption(data, #contentsPanel.children))
		elseif data.type == "number" then
			contentsPanel:AddChild(ProcessNumberOption(data, #contentsPanel.children))
		elseif data.type == "string" then
			contentsPanel:AddChild(ProcessStringOption(data, #contentsPanel.children))
		end
	end
	return {contentsPanel}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Game Mode Handler

local function OnCustomGameMode(_, shortName, displayName, gameModeJson)
	if not (shortName and displayName and gameModeJson) then
		Spring.Echo("Missing shortName", shortName)
		Spring.Echo("Missing displayName", displayName)
		Spring.Echo("Missing gameModeJson", gameModeJson)
		return
	end
	
	local fileName = "CustomModes/" .. shortName .. ".json"
	local modeDataOld = Spring.Utilities.json.loadFile(fileName)
	local modeData = Spring.Utilities.json.decode(gameModeJson)
	Spring.Utilities.TableEcho(modeData, "modeData")
	
	if hostedModeName and modeDataOld
			and modeDataOld.shortName == modeData.shortName
			and modeDataOld.name == modeData.name
			and modeDataOld.game == modeData.game
			and modeDataOld.map == modeData.map then
		-- The mode is already being hosted and the version matches (name should be updated),
		-- so don't rehost.
		hostedModeName = false
		return
	end
	hostedModeName = false
	
	-- Write (or overwrite) the mode json locally.
	local modeFile, errorMessage = io.open(fileName, 'w')
	if not modeFile then
		Spring.Echo("Error writing file", fileName)
		return
	end
	modeFile:write(gameModeJson)
	modeFile:close()
	
	-- Host or change the room to match the mode.
	local lobby = WG.LibLobby.lobby
	if lobby:GetMyBattleID() then
		if modeData.game then
			lobby:SelectGame(modeData.game, true)
		end
		if modeData.rapidTag then
			lobby:SelectGame(modeData.rapidTag, true, true)
		end
		if modeData.roomType then
			lobby:SetBattleType(modeData.roomType)
		end
		if modeData.map then
			lobby:SelectMap(modeData.map)
		end
		if modeData.options then
			lobby:SetModOptions(modeData.options)
		end
	else
		lobby:HostBattle(
			(lobby:GetMyUserName() or "Player") .. "'s Battle", nil,
			modeData.roomType or "Custom",
			modeData.map,
			modeData.game,
			modeData.options
		)
	end
end

local function DelayedCustomModeUpdate(modeName)
	local lobby = WG.LibLobby.lobby
	local function ModeUpdate()
		lobby:GetCustomGameMode(modeName)
	end
	WG.Delay(ModeUpdate, 3)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Modoptions Window Handler

local function CreateModoptionWindow()
	local modoptionsSelectionWindow = Window:New {
		caption = "",
		name = "modoptionsSelectionWindow",
		parent = WG.Chobby.lobbyInterfaceHolder,
		width = 920,
		height = 504,
		resizable = false,
		draggable = false,
		classname = "main_window",
	}

	localModoptions = Spring.Utilities.CopyTable(battleLobby:GetMyBattleModoptions() or {})
	modoptionControlNames = {}

	local tabs = {}

	local tabWidth = 120

	for key, data in pairs(modoptionStructure.sections) do
		local caption = modoptionStructure.sectionTitles[data.title] or data.title
		local fontSize = 2
		local tooltip = nil
		local origCaption = caption
		caption = StringUtilities.GetTruncatedStringWithDotDot(caption, WG.Chobby.Configuration:GetFont(fontSize), tabWidth)
		if origCaption ~= caption then
			tooltip = origCaption
		end
		tabs[#tabs + 1] = {
			name = key,
			caption = caption,
			tooltip = tooltip,
			objectOverrideFont = WG.Chobby.Configuration:GetFont(fontSize),
			children = PopulateTab(data.options)
		}
	end

	local tabPanel = Chili.DetachableTabPanel:New {
		x = 4,
		right = 4,
		y = 49,
		bottom = 75,
		padding = {0, 0, 0, 0},
		minTabWidth = tabWidth,
		tabs = tabs,
		parent = modoptionsSelectionWindow,
		OnTabChange = {
		}
	}

	local tabBarHolder = Control:New {
		name = "tabBarHolder",
		x = 0,
		y = 0,
		right = 0,
		height = 60,
		resizable = false,
		draggable = false,
		padding = {18, 6, 18, 0},
		parent = modoptionsSelectionWindow,
		children = {
			Line:New {
				classname = "line_solid",
				x = 0,
				y = 52,
				right = 0,
				bottom = 0,
			},
			tabPanel.tabBar
		}
	}
	local function CancelFunc()
		modoptionsSelectionWindow:Dispose()
	end

	local buttonAccept, buttonMods, modSelection, isRapid
	local buttonCustom, customModeSelection, mapSelection, typeSelection

	function GetModSelection()
		local function SetGameSucess(name)
			buttonMods.caption = name
			modSelection = name
		end

		local Configuration = WG.Chobby.Configuration
		WG.Chobby.GameListWindow(false, SetGameSucess, Configuration and Configuration.gameConfig.modBlacklist, i18n("select_mod"))
	end

	function GetCustomModeSelection()
		local function SetCustomModeSuccess(modeData)
			if not modeData then
				return
			end
			if modeData.shortName then
				DelayedCustomModeUpdate(modeData.shortName)
			end
			buttonCustom.caption = modeData.name
			if modeData.map then
				mapSelection = modeData.map
			end
			if modeData.game then
				modSelection = modeData.game
				isRapid = false
			end
			if modeData.rapidTag then
				modSelection = modeData.rapidTag
				isRapid = true
			end
			if modeData.roomType then
				typeSelection = modeData.roomType
			end
			if modeData.options then
				for key, value in pairs(modeData.options) do
					UpdateControlValue(key, value)
				end
			end
		end

		local Configuration = WG.Chobby.Configuration
		WG.Chobby.ModeListWindow(false, SetCustomModeSuccess, false, i18n("select_custom_mode"))
	end

	local function AcceptFunc()
		screen0:FocusControl(buttonAccept) -- Defocus the text entry
		battleLobby:SetModOptions(localModoptions)
		if modSelection then
			battleLobby:SelectGame(modSelection, true, isRapid)
		end
		if typeSelection then
			battleLobby:SetBattleType(typeSelection)
		end
		if mapSelection then
			battleLobby:SelectMap(mapSelection)
		end
		modoptionsSelectionWindow:Dispose()
	end

	local function ResetFunc()
		for key, value in pairs(modoptionDefaults) do
			UpdateControlValue(key, value)
		end
		localModoptions = {}
		
		mapSelection = false
		modSelection = false
		tpyeSelection = false
		
		buttonCustom.caption = i18n("select_custom_mode")
		if buttonMods then
			buttonMods.caption = i18n("select_mod")
		end
	end

	buttonCustom = Button:New {
		x = 10,
		width = 250,
		bottom = 1,
		height = 70,
		caption = i18n("select_custom_mode"),
		objectOverrideFont = WG.Chobby.Configuration:GetButtonFont(3),
		parent = modoptionsSelectionWindow,
		classname = "option_button",
		OnClick = {
			function()
				GetCustomModeSelection()
			end
		},
	}

	if WG.Chobby.Configuration.showFullModList then
		buttonMods = Button:New {
			x = 269,
			width = 187,
			bottom = 1,
			height = 70,
			caption = i18n("select_mod"),
			objectOverrideFont = WG.Chobby.Configuration:GetButtonFont(3),
			parent = modoptionsSelectionWindow,
			classname = "option_button",
			OnClick = {
				function()
					GetModSelection()
				end
			},
		}
	end

	Button:New {
		right = 294,
		width = 135,
		bottom = 1,
		height = 70,
		caption = i18n("reset"),
		objectOverrideFont = WG.Chobby.Configuration:GetButtonFont(3),
		parent = modoptionsSelectionWindow,
		classname = "option_button",
		OnClick = {
			function()
				ResetFunc()
			end
		},
	}

	buttonAccept = Button:New {
		right = 150,
		width = 135,
		bottom = 1,
		height = 70,
		caption = i18n("apply"),
		objectOverrideFont = WG.Chobby.Configuration:GetButtonFont(3),
		parent = modoptionsSelectionWindow,
		classname = "action_button",
		OnClick = {
			function()
				AcceptFunc()
			end
		},
	}

	local buttonCancel = Button:New {
		right = 6,
		width = 135,
		bottom = 1,
		height = 70,
		caption = i18n("cancel"),
		objectOverrideFont = WG.Chobby.Configuration:GetButtonFont(3),
		parent = modoptionsSelectionWindow,
		classname = "negative_button",
		OnClick = {
			function()
				CancelFunc()
			end
		},
	}

	local popupHolder = WG.Chobby.PriorityPopup(modoptionsSelectionWindow, CancelFunc, AcceptFunc)
end

local function InitializeModoptionsDisplay()
	local currentLobby = battleLobby

	local mainScrollPanel = ScrollPanel:New {
		x = 0,
		right = 0,
		y = 0,
		bottom = 0,
		horizontalScrollbar = false,
	}

	local lblText = TextBox:New {
		x = 1,
		right = 1,
		y = 1,
		autoresize = true,
		objectOverrideFont = WG.Chobby.Configuration:GetFont(8),
		text = "",
		parent = mainScrollPanel,
	}

	local function OnSetModOptions(listener, modoptions)
		local text = ""
		local empty = true
		modoptions = modoptions or {}
		for key, value in pairs(modoptions) do
			if modoptionDefaults[key] == nil or modoptionDefaults[key] ~= value then
				text = text .. "\255\160\160\160" .. tostring(key) .. " = \255\255\255\255" .. tostring(value) .. "\n"
				empty = false
			end
		end
		lblText:SetText(text)

		if mainScrollPanel.parent then
			if empty and mainScrollPanel.visible then
				mainScrollPanel:Hide()
			end
			if (not empty) and (not mainScrollPanel.visible) then
				mainScrollPanel:Show()
			end
		end
	end
	battleLobby:AddListener("OnSetModOptions", OnSetModOptions)
	battleLobby:AddListener("OnResetModOptions", OnSetModOptions)

	local externalFunctions = {}

	function externalFunctions.Update()
		if currentLobby then
			currentLobby:RemoveListener("OnSetModOptions", OnSetModOptions)
			currentLobby:RemoveListener("OnResetModOptions", OnSetModOptions)
		end
		battleLobby:AddListener("OnSetModOptions", OnSetModOptions)
		battleLobby:RemoveListener("OnResetModOptions", OnSetModOptions)
		currentLobby = battleLobby

		OnSetModOptions()
	end

	function externalFunctions.GetControl()
		return mainScrollPanel
	end

	return externalFunctions
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- External Interface

local modoptionsDisplay

local ModoptionsPanel = {}

function ModoptionsPanel.LoadModoptions(gameName, newBattleLobby)
	battleLobby = newBattleLobby

	local subName = string.sub(gameName, 1, 8)
	if subName == "Zero-K v" or subName == "Zero-K $" then
		gameName = "ZK Default"
	end
	if gameName == currentGameName then
		return
	end
	currentGameName = gameName

	if not modoptionsCache[gameName] then
		if gameName == "ZK Default" then
			-- Don't make the functioning of the base game depend on the VFS within
			-- GetModoptions working correctly.
			modoptionsCache[gameName] = WG.Chobby.Configuration.gameConfig.defaultModoptions
		else
			modoptionsCache[gameName] = WG.Chobby.Configuration:GetModoptions(gameName)
		end
	end

	modoptions = modoptionsCache[gameName] or {}
	modoptionDefaults = {}
	modoptionStructure = {
		sectionTitles = {},
		sections = {}
	}
	
	--if WG.WrapperLoopback then
	--	WG.WrapperLoopback.GetResourceInfo(gameName)
	--	wantedGameResponse = gameName
	--	local function StopWaiting()
	--		wantedGameResponse = false
	--	end
	--	WG.Delay(StopWaiting, 5)
	--end
	
	if not modoptions then
		return
	end

	-- Set modoptionDefaults
	for i = 1, #modoptions do
		local data = modoptions[i]
		if data.key and (not data.noLobby) and (data.def ~= nil) then
			if type(data.def) == "boolean" then
				modoptionDefaults[data.key] = tostring((data.def and 1) or 0)
			elseif type(data.def) == "number" then
				-- can't use tostring because of float inaccuracy, eg. 0.6 ends up as "0.6000000002"
				modoptionDefaults[data.key] = TextFromNum(data.def, data.step)
			else
				modoptionDefaults[data.key] = tostring(data.def)
			end
		end
	end

	-- Populate the sections
	for i = 1, #modoptions do
		local data = modoptions[i]
		if data.type == "section" then
			modoptionStructure.sectionTitles[data.key] = data.name
		elseif not data.noLobby then
			if data.section then
				modoptionStructure.sections[data.section] = modoptionStructure.sections[data.section] or {
					title = data.section,
					options = {}
				}

				local options = modoptionStructure.sections[data.section].options
				options[#options + 1] = data
			end
		end
	end
end

local function ProcessWrapperModoptions(responseName, responseData)
	--Spring.Echo("responseName", responseName, wantedGameResponse)
	--Spring.Utilities.TableEcho(responseData, "responseData")
	if responseName ~= wantedGameResponse then
		return
	end
	--CreateModoptionWindow()
end

function ModoptionsPanel.WrapperModoptionResponse(responseName, responseData)
	ProcessWrapperModoptions(responseName, responseData)
end

function ModoptionsPanel.ShowModoptions()
	CreateModoptionWindow()
end

function ModoptionsPanel.GetModoptionsControl()
	if not modoptionsDisplay then
		modoptionsDisplay = InitializeModoptionsDisplay()
	else
		modoptionsDisplay.Update()
	end
	return modoptionsDisplay.GetControl()
end

function ModoptionsPanel.GetCustomModes(modeList, excludeHostMenuHide)
	local files = VFS.DirList("CustomModes")
	local modeMap = {}
	for i = 1, #files do
		local modeFile, success = Spring.Utilities.json.loadFile(files[i])
		if success then
			if modeFile.name then
				if not (excludeHostMenuHide and modeFile.hideFromHostMenu) then
					modeMap[modeFile.name] = modeFile
					modeList[#modeList + 1] = modeFile.name
				end
			else
				Spring.Echo("CustomModeError", "Mode file missing field 'name'", files[i], "Index", i)
			end
		else
			Spring.Echo("CustomModeError", "Unable to load file", files[i], "Index", i)
		end
	end
	
	--Spring.Utilities.TableEcho(modeList, "modeListmodeList")
	--Spring.Utilities.TableEcho(modeMap, "modeMapmodeMap")
	return modeList, modeMap
end

function ModoptionsPanel.UpdateCustomMode(modeName, isHostingAlready)
	local lobby = WG.LibLobby.lobby
	if isHostingAlready then
		DelayedCustomModeUpdate(modeName)
		return
	end
	
	lobby:GetCustomGameMode(modeName)
end

--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Initialization

function DelayedInitialize()
	local lobby = WG.LibLobby.lobby
	lobby:AddListener("OnCustomGameMode", OnCustomGameMode)
end

function widget:Initialize()
	CHOBBY_DIR = LUA_DIRNAME .. "widgets/chobby/"
	VFS.Include(LUA_DIRNAME .. "widgets/chobby/headers/exports.lua", nil, VFS.RAW_FIRST)

	WG.ModoptionsPanel = ModoptionsPanel
	WG.Delay(DelayedInitialize, 0.1)
end
