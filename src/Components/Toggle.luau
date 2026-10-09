return function(import)
	local Component = import("Core/Component")
	local Utility = import("Core/Utility")
	local Widgets = import("Core/Widgets")
	local Theme = import("Core/Theme")
	local Animation = import("Services/Animation")

	local Toggle = setmetatable({}, { __index = Component.Base })
	Toggle.__index = Toggle

	function Toggle:_Normalize(value)
		if type(value) == "boolean" then
			return true, value
		end
		return false
	end

	return function(ctx, id, config)
		Utility.Check(config.Default == nil or type(config.Default) == "boolean", "Toggle", id, "Default value must be boolean.")
		local self = Component.New(ctx, Toggle, "Toggle", id, config, { RightWidth = 40, RightHeight = 20 })
		local cleanup = self.Cleanup

		local track, trackStroke = Widgets.Surface(cleanup, {
			Parent = self.Right,
			Fill = "TertiaryBackground",
			Stroke = "Text",
			Radius = "Full",
			Size = UDim2.fromScale(1, 1),
		})
		local knob = Widgets.Surface(cleanup, {
			Parent = track,
			Fill = "MutedText",
			Radius = "Full",
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 3, 0.5, 0),
			Size = UDim2.fromOffset(14, 14),
		})

		trackStroke.Transparency = 0.8

		local function render(value, animate)
			local trackColor = Theme.Get(value and "Accent" or "TertiaryBackground")
			local knobColor = Theme.Get(value and "AccentText" or "MutedText")
			local position = value and UDim2.new(1, -17, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
			local trackAlpha = value and 0 or Theme.Get("ElementTransparency")
			if animate then
				Animation:Play(track, { BackgroundColor3 = trackColor, BackgroundTransparency = trackAlpha }, { Duration = 0.15 })
				Animation:Play(knob, { BackgroundColor3 = knobColor, Position = position }, { Duration = 0.15 })
			else
				track.BackgroundColor3 = trackColor
				track.BackgroundTransparency = trackAlpha
				knob.BackgroundColor3 = knobColor
				knob.Position = position
			end
		end
		Component.BindValue(self, id, config.Default == true, render)

		local hit = Utility.Create("TextButton", {
			Name = "Hit",
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			ZIndex = 2,
			Parent = self.Frame,
		})
		Widgets.Interactive(cleanup, self.Frame, hit, {})
		cleanup:Add(hit.Activated:Connect(function()
			self.State:Set(not self.State:Get())
		end))
		return self
	end
end
