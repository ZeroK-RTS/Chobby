
ButtonUtilities = ButtonUtilities or {}

local VOTE_CLASS = {
	option_button = true,
	yes_button = true,
	no_button = true,
}

local STATE_CLASS = {
	button_highlight = true,
}

function ButtonUtilities.SetButtonSelected(button)
	if button.selected then
		return
	end

	local Configuration = WG.Chobby.Configuration
	if not button.highlighted then
		button.oldCaption = button.oldCaption or button.caption
		button.oldBackgroundColor = button.oldBackgroundColor or button.backgroundColor
		button.oldBorderColor = button.oldBorderColor or button.borderColor
		button.oldFont = button.oldFont or button.font
	end

	button.selected = true
	button.highlighted = false

	button:SetCaption(Configuration:GetSelectedColor() .. button.oldCaption .. "\b")
	button.font = Configuration:GetFont(button.oldFont.size, "button_highlight", {
		--outlineWidth = 10,
		--outlineHeight = 10,
		--outline = true,
		--outlineColor = {0,0,0,0.8},
		--outlineColor = {1,1,1,.03},
		autoOutlineColor = false,
	}, true)

	local selected_color = Configuration:GetButtonSelectedColor()
	if VOTE_CLASS[button.classname] then
		button.borderColor = button.focusColor
	elseif STATE_CLASS[button.classname] then
		button.borderColor = {selected_color[1] * (4/3), selected_color[2] * (4/3), selected_color[3] * (4/3), selected_color[4]}
	else
		button.borderColor = selected_color
	end
	button:Invalidate()
end

function ButtonUtilities.SetButtonHighlighted(button)
	if button.highlighted then
		return
	end

	local Configuration = WG.Chobby.Configuration
	if not button.selected then
		button.oldCaption = button.oldCaption or button.caption
		button.oldBorderColor = button.oldBorderColor or button.borderColor
		button.oldFont = button.oldFont or button.font
	end

	button.selected = false
	button.highlighted = true

	button:SetCaption(Configuration:GetHighlightedColor() .. button.oldCaption .. "\b")
	button.font = Configuration:GetFont(button.oldFont.size, "button_highlight", {
		outlineWidth = 6,
		outlineHeight = 6,
		outline = true,
		outlineColor = {0,0,0,0.8},
		autoOutlineColor = false,
	}, true)

	--button.backgroundColor = Configuration:GetButtonSelectedColor()
	button:Invalidate()
end

function ButtonUtilities.SetButtonDeselected(button)
	if not button.selected then
		return
	end

	button.oldCaption = button.oldCaption or button.caption
	button.oldBorderColor = button.oldBorderColor or button.borderColor
	button.oldFont = button.oldFont or button.font

	button.selected = false
	button.selected = false

	button:SetCaption(button.oldCaption)
	button.font = button.oldFont
	button.borderColor = button.oldBorderColor
	button:Invalidate()
end

function ButtonUtilities.SetCaption(button, newCaption)
	button:SetCaption(newCaption)
	button.oldCaption = newCaption
	if button.selected then
		button.selected = false -- force redo
		ButtonUtilities.SetButtonSelected(button)
	end
	if button.highlighted then
		button.highlighted = false -- force redo
		ButtonUtilities.SetButtonHighlighted(button)
	end
end

function ButtonUtilities.SetFontSizeScale(button, sizeScale)
	button.font = WG.Chobby.Configuration:GetFont(sizeScale)
	button:Invalidate()
	button.oldFont = button.font
	if button.selected then
		button.selected = false -- force redo
		ButtonUtilities.SetButtonSelected(button)
	end
	if button.highlighted then
		button.highlighted = false -- force redo
		ButtonUtilities.SetButtonHighlighted(button)
	end
end
