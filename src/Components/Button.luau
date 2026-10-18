return function(import)
	local Component = import("Core/Component")
	local Utility = import("Core/Utility")
	local Widgets = import("Core/Widgets")

	local Button = setmetatable({}, { __index = Component.Base })
	Button.__index = Button

	function Button:Fire()
		if self._destroyed or not self.Enabled then
			return
		end
		Utility.SafeCall("Button " .. tostring(self.Config.Title), self.Config.Callback)
		self.Changed:Fire()
	end

	function Button:SetButtonText(value)
		if self._actionLabel then self._actionLabel.Text = tostring(value) end
	end

	function Button:SetCallback(callback)
		Utility.Check(type(callback) == "function", "Button", self.Config.Title, "Callback must be a function.")
		self.Config.Callback = callback
	end

	return function(ctx, id, config)
		Utility.Check(config.Callback == nil or type(config.Callback) == "function", "Button", config.Title, "Callback must be a function.")
		local self = Component.New(ctx, Button, "Button", id, config, { RightWidth = 82, RightHeight = 30 })
		local cleanup = self.Cleanup
		local action = Widgets.Surface(cleanup, {
			Name = "Action", Parent = self.Right, Fill = "TertiaryBackground",
			Stroke = "Border", Radius = 10, Size = UDim2.fromScale(1, 1),
		})
		self._actionLabel = Widgets.Text(cleanup, {
			Parent = action, Text = config.ButtonText or "Run", Bold = true,
			TextSize = 12, TextXAlignment = Enum.TextXAlignment.Center,
			Size = UDim2.fromScale(1, 1),
		})
		local hit = Utility.Create("TextButton", {
			Name = "Hit",
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			ZIndex = 2,
			Parent = self.Frame,
		})
		Widgets.Interactive(cleanup, self.Frame, hit, {})
		cleanup:Add(hit.Activated:Connect(function()
			self:Fire()
		end))
		return self
	end
end
