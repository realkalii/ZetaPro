return function(import)
	local Component = import("Core/Component")
	local Utility = import("Core/Utility")
	local Widgets = import("Core/Widgets")
	local Animation = import("Services/Animation")
	local Drag = import("Services/Drag")

	local Slider = setmetatable({}, { __index = Component.Base })
	Slider.__index = Slider

	function Slider:_Snap(value)
		value = math.clamp(value, self._min, self._max)
		if self._increment then
			value = self._min + math.floor((value - self._min) / self._increment + 0.5) * self._increment
		end
		return math.clamp(Utility.Round(value, self._rounding), self._min, self._max)
	end

	function Slider:_Normalize(value)
		if type(value) ~= "number" or value ~= value then
			return false
		end
		return true, self:_Snap(value)
	end

	return function(ctx, id, config)
		local min, max = config.Min, config.Max
		Utility.Check(type(min) == "number" and type(max) == "number" and min < max, "Slider", id, "Min and Max must be numbers with Min < Max.")
		local default = config.Default
		if default == nil then
			default = min
		end
		Utility.Check(type(default) == "number", "Slider", id, "Default must be a number.")
		Utility.Check(config.Increment == nil or (type(config.Increment) == "number" and config.Increment > 0), "Slider", id, "Increment must be a positive number.")

		local self = Component.New(ctx, Slider, "Slider", id, config, { RightWidth = 210, RightHeight = 24 })
		self._min, self._max, self._increment = min, max, config.Increment
		self._rounding = math.clamp(config.Rounding or ((config.Increment and config.Increment % 1 ~= 0) and 2 or 0), 0, 6)
		local cleanup = self.Cleanup
		local _, defaultValue = self:_Normalize(default)

		local bar = Utility.Create("TextButton", {
			Name = "Bar",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -56, 1, 0),
			Parent = self.Right,
		})
		local track = Widgets.Surface(cleanup, {
			Parent = bar,
			Fill = "TertiaryBackground",
			Radius = "Full",
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 6, 0.5, 0),
			Size = UDim2.new(1, -12, 0, 4),
		})
		local fill = Widgets.Surface(cleanup, {
			Parent = track,
			Fill = "Accent",
			Radius = "Full",
			Size = UDim2.fromScale(0, 1),
		})
		local knob = Widgets.Surface(cleanup, {
			Parent = track,
			Fill = "Accent",
			Stroke = "Border",
			Radius = "Full",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0, 0.5),
			Size = UDim2.fromOffset(12, 12),
		})
		local boxFrame = Widgets.Surface(cleanup, {
			Parent = self.Right,
			Fill = "TertiaryBackground",
			Stroke = "Border",
			Radius = 8,
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, 0, 0.5, 0),
			Size = UDim2.fromOffset(48, 22),
		})
		local box = Widgets.Text(cleanup, {
			Class = "TextBox",
			Parent = boxFrame,
			Size = UDim2.fromScale(1, 1),
			TextXAlignment = Enum.TextXAlignment.Center,
			ClearTextOnFocus = false,
			TextSize = 12,
		})

		local format = "%." .. tostring(self._rounding) .. "f"
		local function render(value, animate)
			local alpha = (value - min) / (max - min)
			local fillSize, knobPosition = UDim2.fromScale(alpha, 1), UDim2.fromScale(alpha, 0.5)
			if animate then
				Animation:Play(fill, { Size = fillSize }, { Duration = 0.08 })
				Animation:Play(knob, { Position = knobPosition }, { Duration = 0.08 })
			else
				fill.Size, knob.Position = fillSize, knobPosition
			end
			if not box:IsFocused() then
				box.Text = string.format(format, value)
			end
		end
		Component.BindValue(self, id, defaultValue, render)

		Drag.Track(bar, cleanup, function(position)
			local alpha = math.clamp((position.X - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
			self.State:Set(self:_Snap(min + alpha * (max - min)))
		end)
		cleanup:Add(box.FocusLost:Connect(function()
			local number = tonumber(box.Text)
			if number then
				self:SetValue(number)
			end
			box.Text = string.format(format, self.State:Get())
		end))
		return self
	end
end
