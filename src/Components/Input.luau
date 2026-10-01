return function(import)
	local Component = import("Core/Component")
	local Utility = import("Core/Utility")
	local Widgets = import("Core/Widgets")
	local Theme = import("Core/Theme")
	local Icons = import("Icons/Icon")
	local Animation = import("Services/Animation")

	local TextInput = setmetatable({}, { __index = Component.Base })
	TextInput.__index = TextInput

	function TextInput:_Normalize(value)
		if type(value) == "string" then
			return true, value
		elseif type(value) == "number" then
			return true, tostring(value)
		elseif value == nil then
			return true, ""
		end
		return false
	end

	function TextInput:SetPlaceholder(text)
		self._box.PlaceholderText = text or ""
	end

	function TextInput:Focus()
		self._box:CaptureFocus()
	end

	-- config: Default, Placeholder, MaxLength, Numeric, Validate(text)->boolean, Live, Callback
	return function(ctx, id, config)
		Utility.Check(config.Default == nil or type(config.Default) == "string", "Input", id, "Default must be a string.")
		Utility.Check(config.MaxLength == nil or type(config.MaxLength) == "number", "Input", id, "MaxLength must be a number.")
		Utility.Check(config.Validate == nil or type(config.Validate) == "function", "Input", id, "Validate must be a function.")
		local self = Component.New(ctx, TextInput, "Input", id, config, { RightWidth = 190, RightHeight = 26 })
		local cleanup = self.Cleanup

		local holder, stroke = Widgets.Surface(cleanup, {
			Parent = self.Right,
			Fill = "TertiaryBackground",
			Stroke = "Border",
			Radius = 5,
			Size = UDim2.fromScale(1, 1),
		})
		local box = Widgets.Text(cleanup, {
			Class = "TextBox",
			Name = "Box",
			Parent = holder,
			Position = UDim2.fromOffset(8, 0),
			Size = UDim2.new(1, -32, 1, 0),
			PlaceholderText = config.Placeholder or "",
			ClearTextOnFocus = false,
			TextSize = 12,
			TextTruncate = Enum.TextTruncate.AtEnd,
		})
		self._box = box
		local clear = Utility.Create("TextButton", {
			Name = "Clear",
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -4, 0.5, 0),
			Size = UDim2.fromOffset(20, 20),
			Visible = false,
			Parent = holder,
		})
		Icons.Create(clear, "x", { Size = 12, Position = UDim2.fromOffset(4, 4), Cleanup = cleanup })

		local focused = false
		local function strokeColor()
			return Theme.Get(focused and "Accent" or "Border")
		end
		local function validate(text)
			if config.MaxLength and #text > config.MaxLength then
				return false
			end
			if config.Numeric and text ~= "" and tonumber(text) == nil then
				return false
			end
			if config.Validate then
				local ok, result = pcall(config.Validate, text)
				if not ok or result == false then
					return false
				end
			end
			return true
		end

		Component.BindValue(self, id, config.Default or "", function(value)
			if box.Text ~= value then
				box.Text = value
			end
		end)

		cleanup:Add(box:GetPropertyChangedSignal("Text"):Connect(function()
			local text = box.Text
			if config.MaxLength and #text > config.MaxLength then
				box.Text = string.sub(text, 1, config.MaxLength)
				return
			end
			clear.Visible = text ~= ""
			if config.Live and validate(text) then
				self.State:Set(text)
			end
		end))
		cleanup:Add(box.Focused:Connect(function()
			focused = true
			Animation:Play(stroke, { Color = strokeColor() }, { Duration = 0.12 })
		end))
		cleanup:Add(box.FocusLost:Connect(function()
			focused = false
			if validate(box.Text) then
				self.State:Set(box.Text)
			else
				box.Text = self.State:Get()
				Animation:Play(stroke, { Color = Theme.Get("Error") }, { Duration = 0.1 })
				task.delay(0.5, function()
					if not self._destroyed then
						Animation:Play(stroke, { Color = strokeColor() }, { Duration = 0.2 })
					end
				end)
				return
			end
			Animation:Play(stroke, { Color = strokeColor() }, { Duration = 0.12 })
		end))
		cleanup:Add(clear.Activated:Connect(function()
			box.Text = ""
			self.State:Set("")
		end))
		clear.Visible = box.Text ~= ""
		return self
	end
end
