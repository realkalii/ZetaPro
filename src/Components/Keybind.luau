return function(import)
	local Component = import("Core/Component")
	local Utility = import("Core/Utility")
	local Signal = import("Core/Signal")
	local Widgets = import("Core/Widgets")
	local InputService = import("Services/Input")
	local Notification = import("Services/Notification")

	local Keybind = setmetatable({}, { __index = Component.Base })
	Keybind.__index = Keybind

	local MOUSE = {
		[Enum.UserInputType.MouseButton2] = "Mouse 2",
		[Enum.UserInputType.MouseButton3] = "Mouse 3",
	}

	local function display(key)
		if typeof(key) ~= "EnumItem" or key == Enum.KeyCode.Unknown then
			return "None"
		end
		return MOUSE[key] or key.Name
	end

	local function parse(value)
		if typeof(value) == "EnumItem" then
			if value.EnumType == Enum.KeyCode or value.EnumType == Enum.UserInputType then
				return true, value
			end
			return false
		end
		if value == nil or value == "None" then
			return true, Enum.KeyCode.Unknown
		end
		if type(value) == "string" then
			local ok, item = pcall(function()
				return Enum.KeyCode[value]
			end)
			if ok and item then
				return true, item
			end
		end
		return false
	end

	function Keybind:_Normalize(value)
		return parse(value)
	end

	-- Callback = fired when the bound key is pressed.
	-- ChangedCallback / OnChanged = fired when the binding is changed.
	function Keybind:_Emit(value)
		if self._destroyed then
			return
		end
		Utility.SafeCall("Keybind " .. tostring(self.Id), self.Config.ChangedCallback, value)
		self.Changed:Fire(value)
	end

	function Keybind:OnClick(callback)
		return self.Clicked:Connect(callback)
	end

	function Keybind:Reset()
		self.State:Set(self._default)
	end

	return function(ctx, id, config)
		local valid, default = parse(config.Default)
		Utility.Check(valid, "Keybind", id, "Default must be an Enum.KeyCode, a mouse UserInputType or a key name.")
		local self = Component.New(ctx, Keybind, "Keybind", id, config, { RightWidth = 110, RightHeight = 26 })
		local cleanup = self.Cleanup
		self._default = default
		self.Clicked = Signal.new()
		cleanup:Add(self.Clicked)

		local button = Widgets.Surface(cleanup, {
			Class = "TextButton",
			Name = "Key",
			Parent = self.Right,
			Fill = "TertiaryBackground",
			Stroke = "Border",
			Radius = 5,
			Size = UDim2.fromScale(1, 1),
		})
		local label = Widgets.Text(cleanup, {
			Parent = button,
			Size = UDim2.fromScale(1, 1),
			TextXAlignment = Enum.TextXAlignment.Center,
			TextSize = 12,
			TextTruncate = Enum.TextTruncate.AtEnd,
		})
		Widgets.Interactive(cleanup, button, button, { Base = "TertiaryBackground" })

		Component.BindValue(self, id, default, function(value)
			label.Text = display(value)
			if self._bind then
				self._bind:SetKey(value)
			end
		end)

		self._bind = cleanup:Add(InputService.AddBind(self.State:Get(), function(key)
			if self.Enabled and not self._destroyed then
				Utility.SafeCall("Keybind " .. tostring(self.Id), config.Callback, key)
				self.Clicked:Fire(key)
			end
		end, "Keybind " .. tostring(config.Title or id or "?")))

		cleanup:Add(button.Activated:Connect(function()
			if self._capturing then
				return
			end
			self._capturing = true
			label.Text = "..."
			self._cancel = InputService.Capture(function(key, cancelled)
				self._capturing, self._cancel = false, nil
				if self._destroyed then
					return
				end
				if not cancelled then
					local conflict = InputService.FindConflict(key, self._bind)
					if conflict then
						Notification.Notify({
							Type = "Warning",
							Title = "Keybind conflict",
							Content = string.format('%s is also used by "%s".', display(key), conflict.Label),
						})
					end
					self.State:Set(key)
				end
				label.Text = display(self.State:Get())
			end)
		end))
		cleanup:Add(button.MouseButton2Click:Connect(function()
			if not self._capturing then
				self:Reset()
			end
		end))
		cleanup:Add(function()
			if self._cancel then
				self._cancel()
			end
		end)
		return self
	end
end
