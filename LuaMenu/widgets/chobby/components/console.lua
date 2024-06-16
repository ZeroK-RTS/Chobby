Console = LCS.class{}

function Console:init(channelName, sendMessageListener, noHistoryLoad, onResizeFunc, isBattleChat)
	self.listener = sendMessageListener
	self.showDate = true
	self.dateFormat = "%H:%M"

	self.sentMsgHistory = {}
	self.sentMsgHistoryCount = 0
	self.sentMsgHistoryMax = 500
	self.sentMsgHistoryCursor = 1
	self.currentMsgBuffer = ""

	self.channelName = channelName

	local onResize
	if onResizeFunc then
		onResize = {
			function ()
				onResizeFunc(self)
			end
		}
	end

	-- TODO: currently this is handled by chat windows and battleroom chat separately
	self.unreadMessages = 0

	self.spHistory = ScrollPanel:New {
		name = self.channelName and (self.channelName .. " scroll panel"),
		x = 0,
		right = 2,
		y = 0,
		bottom = 35,
		verticalSmartScroll = true,
	}
	self.tbHistory = TextBox:New {
		x = 0,
		right = 0,
		y = 0,
		agressiveMaxLines = 500,
		agressiveMaxLinesPreserve = 100,
		lineSpacing = 2,
		bottom = 0,
		text = "",
		objectOverrideFont = Configuration:GetFont(Configuration.chatFontSize, "console_" .. Configuration.chatFontSize, false, true),
		parent = self.spHistory,
		selectable = true,
		subTooltips = true,

		_inmousemove = false,
		OnClick = { function(obj)
			if not obj._inmousemove then
				screen0:FocusControl(self.ebInputText)
			end
			obj._inmousemove = false
		end},
		OnMouseMove = { function(obj, x, y, dx, dy, button)
			if button ~= 1 then
				return
			end
			obj._inmousemove = true
		end},
		onResize = onResize
	}

	self.ebInputText = EditBox:New {
		x = 0,
		bottom = 7,
		height = 25,
		right = 2,
		text = "",
		objectOverrideFont = Configuration:GetFont(Configuration.chatFontSize, "console_" .. Configuration.chatFontSize, false, true),
		objectOverrideHintFont = Configuration:GetHintFont(Configuration.chatFontSize, "console_hint_" .. Configuration.chatFontSize, false, true),
		--hint = i18n("type_here_to_chat"),
	}

	local function onConfigurationChange(listener, key, value)
		if key == "chatFontSize" then
			local oldFont = self.ebInputText.font
			-- Relevant settings depend on skin
			local fontSettings = {
				font         = oldFont.font,
				color        = oldFont.color,
				outlineColor = oldFont.outlineColor,
				outline      = oldFont.outline,
				shadow       = oldFont.shadow,
				size         = value,
			}
			self.ebInputText.font = Configuration:GetFont(value, "console_font", fontSettings, true)
			self.ebInputText:UpdateLayout()

			self.tbHistory.font = Configuration:GetFont(value, "console_font", fontSettings, true)
			self.tbHistory:UpdateLayout()
		end
	end
	Configuration:AddListener("OnConfigurationChange", onConfigurationChange)

	local keyUP, keyDOWN, keyENTER, keyKP_ENTER, keyESCAPE, keyTAB = 
		Spring.GetKeyCode("up"),
		Spring.GetKeyCode("down"),
		Spring.GetKeyCode("enter"),
		Spring.GetKeyCode("numpad_enter"),
		Spring.GetKeyCode("escape"),
		Spring.GetKeyCode("tab")

	self.ebInputText.KeyPress = function(something, key, ...)
		if key == keyTAB then
			self:Autocomplete(self.ebInputText.text)
			return false
		else
			self.subword = nil

			local up, down = key == keyUP, key == keyDOWN
			local newtext, block = false, false
			if up or down then
				local cursor = self.sentMsgHistoryCursor
				local count = self.sentMsgHistoryCount
				cursor = cursor + (up and -1 or 1)
				if cursor == count + 2 then
					-- skip, the msg history has not yet be browsed up, nothing to do
				elseif cursor == 0 then
					-- skip, we've already gone to the first msg in history
				else
					if cursor == count + 1 then -- we gone back to the current text
						newtext = self.currentMsgBuffer
						self.currentMsgBuffer = ""
					else
						if up and cursor == count then -- we're starting going into history, saving the current text
							self.currentMsgBuffer = self.ebInputText.text
						end
						newtext = self.sentMsgHistory[cursor]
					end
					self.sentMsgHistoryCursor = cursor
				end
			elseif key == keyESCAPE then
				if self.ebInputText.text ~= "" then
					-- clearing field and resetting cursor pos
					self.sentMsgHistoryCursor = self.sentMsgHistoryCount + 1
					newtext = ""
					block = true -- block the action of escape that would leave the current lobby tab
				end
			end
			if newtext then
				self.ebInputText:SetText(newtext)
				self.ebInputText.cursor = #self.ebInputText.text + 1
				self.ebInputText:Invalidate()
				return block
			end

			return Chili.EditBox.KeyPress(something, key, ...)
		end
	end


	self.ebInputText.OnKeyPress = {
		function(obj, key, mods, ...)
			if key == keyENTER or
				key == keyKP_ENTER then
				self:SendMessage()
				return true
			end
		end
	}

	self.fakeImage = Image:New {
		x = 0, y = 0,
		bottom = 0, right = 0,
		OnClick = { function()
			screen0:FocusControl(self.ebInputText)
		end}
	}

	self.panel = Control:New {
		x = 0,
		y = 0,
		right = 0,
		bottom = 0,
		padding      = {0, 0, 0, 0},
		itemPadding  = {0, 0, 0, 0},
		itemMargin   = {0, 0, 0, 0},
		children = {
			self.spHistory,
			self.ebInputText,
			self.fakeImage,
		},
	}

	if not noHistoryLoad then
		self:LoadHistory(Configuration.lastLoginChatLength)
	end
end

function Console:Autocomplete(textSoFar)
	if not self.subword then
		local start = 0
		for i = 1, 100 do
			local newStart = (string.find(textSoFar, " ", start) or (start - 1)) + 1

			if start ~= newStart then
				start = newStart
			else
				break
			end
		end

		self.subword = string.sub(textSoFar, start)
		self.unmodifiedLength = string.len(textSoFar)
		local length = string.len(self.subword)

		self.suggestion = 0
		self.suggestions = {}

		if length == 0 then
			return
		end

		local users = lobby:GetUsers()
		for name, _ in pairs(users) do
			if name:starts(self.subword) then
				self.suggestions[#self.suggestions + 1] = string.sub(name, length + 1)
			end
		end
	end

	if #self.suggestions == 0 then
		return
	end

	self.suggestion = self.suggestion + 1
	if self.suggestion > #self.suggestions then
		self.suggestion = 1
	end

	self.ebInputText.selStart = self.unmodifiedLength + 1
	self.ebInputText.selEnd = string.len(textSoFar) + 1
	self.ebInputText:ClearSelected()

	self.ebInputText:TextInput(self.suggestions[self.suggestion])
end

function Console:SendMessage()
	if self.ebInputText.text ~= "" then
		message = self.ebInputText.text

		local count = self.sentMsgHistoryCount
		if count == self.sentMsgHistoryMax then
			table.remove(self.sentMsgHistory, 1)
		else
			count = count + 1
			self.sentMsgHistoryCount = count
		end
		self.sentMsgHistory[count] = message
		self.sentMsgHistoryCursor = count + 1

		if self.listener then
			self.listener(message)
		end
		self.ebInputText:SetText("")
	end
end

-- TODO: Refactor method to use an options table
-- if date is not passed, current time is assumed
function Console:AddMessage(message, userName, dateOverride, color, thirdPerson, nameColor, nameTooltip, supressNameClick, suppressLogging)
	nameColor = nameColor or "\255\50\160\255"
	nameTooltip = nameTooltip or (userName and ("user_chat_s_" .. userName))
	local txt = ""
	local whiteText = ""
	if self.showDate then
		local timeOverride
		if dateOverride then
			local utcHour = tonumber(os.date("!%H"))
			local utcMinute = tonumber(os.date("!%M"))
			local localHour = tonumber(os.date("%H"))
			local localMinute = tonumber(os.date("%M"))

			local messageHour = tonumber(string.sub(dateOverride, 12, 13))
			local messageMinute = tonumber(string.sub(dateOverride, 15, 16))

			if messageHour and messageMinute then
				local hour = (localHour - utcHour + messageHour)%24
				if hour < 10 then
					hour = "0" .. hour
				end
				local minute = (localMinute - utcMinute + messageMinute)%60
				if minute < 10 then
					minute = "0" .. minute
				end

				timeOverride = hour .. ":" .. minute
			else
				Spring.Echo("Bad dateOverride", dateOverride, messageHour, messageMinute)
			end
		end
		-- FIXME: the input "date" should ideally be a table so we can coerce the format
		local currentDate = timeOverride or os.date(self.dateFormat)
		txt = txt .. "\255\128\128\128[" .. currentDate .. "] "
		whiteText = whiteText .. "[" .. currentDate .. "] "
		if color ~= nil then
			txt = txt .. color
		end
	end

	local textTooltip, onTextClick
	if userName ~= nil then
		local userStartIndex, userEndIndex
		if thirdPerson then
			userStartIndex = #txt
			txt = txt .. userName .. " "
			userEndIndex = userStartIndex + #userName
		else
			userStartIndex = #txt + 4
			txt = txt .. nameColor .. userName .. ": \255\255\255\255"
			userEndIndex = userStartIndex + #userName
			whiteText = whiteText .. userName .. ": "
			if color ~= nil then
				txt = txt .. color
			end
		end

		textTooltip = {
			{
				startIndex = userStartIndex,
				endIndex = userEndIndex,
				tooltip = nameTooltip
			}
		}
		if supressNameClick then
			onTextClick = {} -- Think about putting discord link here?
		else
			onTextClick = {
				{
					startIndex = userStartIndex,
					endIndex = userEndIndex,
					OnTextClick = {
						function()
							WG.UserHandler.GetUserDropdownMenu(userName, isBattleChat)
							--Spring.Echo("Clicked on " .. userName .. ". TODO: Spawn popup.")
						end
					}
				}
			}
		end
	end

	onTextClick, textTooltip = WG.BattleProposalHandler.AddClickableInvites(userName, txt, message, onTextClick or {}, textTooltip or {})
	
	txt = txt .. message
	onTextClick, textTooltip = WG.BrowserHandler.AddClickableUrls(txt, onTextClick or {}, textTooltip or {})

	whiteText = whiteText .. message
	if self.tbHistory.text == "" then
		self.tbHistory:SetText(txt, textTooltip, onTextClick)
	else
		self.tbHistory:AddLine(txt, textTooltip, onTextClick)
	end

	if self.channelName and not suppressLogging then
		Spring.CreateDir("chatLogs")
		local logFile, errorMessage = io.open('chatLogs/' .. self.channelName .. ".txt", 'a')
		if logFile then
			if dateOverride then
				logFile:write("\n" .. ((string.sub(dateOverride, 0, 19) .. " - ") or "") .. whiteText)
			else
				logFile:write("\n" .. whiteText)
			end
			io.close(logFile)
		end
	end
end

function Console:SetTopic(newTopic)
	if self.currentTopic == nil or newTopic ~= self.currentTopic then
		self.currentTopic = newTopic
		self:AddMessage(newTopic, nil, nil, Configuration.meColor, nil, nil, nil, nil, true)
	end
end

local function lineIterator(s)
	if s:sub(-1)~="\n" then s=s.."\n" end
	return s:gmatch("(.-)\n")
end

-- remove trailing whitespace from string.
local function rtrim(s)
	local n = #s
	while n > 0 and s:find("^%s", n) do n = n - 1 end
	return s:sub(1, n)
end

function Console:LoadHistory(numLines)
	if not self.channelName then
		return
	end
	local path = 'chatLogs/' .. self.channelName .. ".txt"
	if not VFS.FileExists(path) then
		return
	end

	local logfile = VFS.LoadFile(path)
	local lineCount = 0
	for line in lineIterator(logfile) do
		lineCount = lineCount + 1
	end

	local waitToWrite = lineCount - numLines
	for line in lineIterator(logfile) do
		if waitToWrite > 0 then
			waitToWrite = waitToWrite - 1
		else
			line = rtrim(line)
			local start = string.find(line, "%[")
			if start then
				local txt = "\255\128\128\128" .. string.sub(line, start)
				if self.tbHistory.text == "" then
					self.tbHistory:SetText(txt)
				else
					self.tbHistory:AddLine(txt)
				end
			end
		end
	end
	--local logFile, errorMessage = io.open(, 'r')
end

function Console:ClearHistory()
	self.tbHistory:SetText("")
end

function Console:Delete()
	self = nil
end
