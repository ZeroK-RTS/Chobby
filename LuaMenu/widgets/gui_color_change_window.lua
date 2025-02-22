--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
	return {
		name      = "Color change window",
		desc      = "Displays a color change window popup.",
		author    = "presumed dead",
		date      = "The Olympics",
		license   = "GNU LGPL, v2.1 or later",
		layer     = 0,
		enabled   = true  --  loaded by default?
	}
end

local colors = {
	{{ 0.90, 0.10, 0.29 }, "Red"},
	{{ 0.24, 0.71, 0.29 }, "Green"},
	{{ 1.00, 0.88, 0.10 }, "Yellow"},
	{{ 0.00, 0.51, 0.78 }, "Blue"},
	{{ 0.96, 0.51, 0.19 }, "Orange"},
	{{ 0.57, 0.12, 0.71 }, "Purple"},
	{{ 0.27, 0.94, 0.94 }, "Cyan"},
	{{ 0.94, 0.20, 0.90 }, "Magenta"},
	{{ 0.82, 0.96, 0.24 }, "Lime"},
	{{ 0.98, 0.75, 0.75 }, "Pink"},
	{{ 0.00, 0.50, 0.50 }, "Teal"},
	{{ 0.90, 0.75, 1.00 }, "Lavender"},
	{{ 0.67, 0.43, 0.16 }, "Brown"},
	{{ 1.00, 0.98, 0.78 }, "Beige"},
	{{ 0.50, 0.00, 0.00 }, "Maroon"},
	{{ 0.67, 1.00, 0.76 }, "Mint"},
	{{ 0.50, 0.50, 0.00 }, "Olive"},
	{{ 1.00, 0.84, 0.71 }, "Apricot"},
	{{ 0.00, 0.00, 0.50 }, "Navy"},
	{{ 0.50, 0.50, 0.50 }, "Grey"},
	{{ 1.00, 1.00, 1.00 }, "White"},
	{{ 0.00, 0.00, 0.00 }, "Black"}
}

local colorMap = {}
local colorNames = { '...' }
for _, color in ipairs(colors) do
	colorMap[color[2]] = color[1]
	table.insert(colorNames, color[2])
end

local function CreateColorChangeWindow(opts)
	opts = opts or {}
	local selectedColor = opts.initialColor

	local Configuration = WG.Chobby.Configuration

	local colorChangeWindow = Window:New {
		caption = "",
		name = "colorChangeWindow",
		parent = screen0,
		width = 280,
		height = 330,
		resizable = false,
		draggable = false,
		classname = "main_window",
	}

	local function ChangeAccepted()
		if opts.OnAccepted then
			opts.OnAccepted(selectedColor)
		end
	end
	local function CloseFunction()
		colorChangeWindow:Dispose()
		colorChangeWindow = nil
	end

	local lblTitle = Label:New {
		x = 0,
		y = 15,
		width = colorChangeWindow.width - colorChangeWindow.padding[1] - colorChangeWindow.padding[3],
		height = 35,
		align = "center",
		objectOverrideFont = Configuration:GetFont(4),
		caption = "Choose color",
		parent = colorChangeWindow,
	}

	local btnOK = Button:New {
		x = "10%",
		width = "30%",
		bottom = 1,
		height = 40,
		caption = i18n("ok"),
		objectOverrideFont = Configuration:GetButtonFont(2),
		classname = "action_button",
		OnClick = { CloseFunction, ChangeAccepted },
		parent = colorChangeWindow,
	}

	local btnCancel = Button:New {
		right = "10%",
		width = "30%",
		bottom = 1,
		height = 40,
		caption = i18n("cancel"),
		objectOverrideFont = Configuration:GetButtonFont(2),
		classname = "action_button",
		OnClick = { CloseFunction },
		parent = colorChangeWindow,
	}

	local imTeamColor
	local cmbColors = ComboBox:New {
		x = colorChangeWindow.width * 0.05,
		y = 150,
		width = colorChangeWindow.width * 0.5,
		height = 40,
		items = colorNames,
		parent = colorChangeWindow,
		objectOverrideFont = Configuration:GetFont(2),
		itemHeight = 30,
		selectByName = true,
		OnSelectName = {
			function (obj, name)
				local color = colorMap[name]
				if color == nil then
					return
				end
				selectedColor = color
				imTeamColor.color = color
				imTeamColor:Invalidate()
			end
		},
	}

	imTeamColor = Image:New {
		name = "imTeamColor",
		x = cmbColors.x + cmbColors.width + 20,
		y = 150,
		width = 40,
		height = 40,
		parent = colorChangeWindow,
		keepAspect = false,
		file = "LuaMenu/widgets/chili/skins/Evolved/glassBk.png",
		color = selectedColor,
	}

	WG.Chobby.PriorityPopup(colorChangeWindow, CloseFunction, CloseFunction, screen0)
end

function widget:Initialize()
	VFS.Include(LUA_DIRNAME .. "widgets/chobby/headers/exports.lua", nil, VFS.RAW_FIRST)

	WG.ColorChangeWindow = {
		CreateColorChangeWindow = CreateColorChangeWindow
	}
end
