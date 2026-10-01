return function(import)
	local Component = import("Core/Component")
	local Utility = import("Core/Utility")
	local Widgets = import("Core/Widgets")
	local Icons = import("Icons/Icon")

	local Button = setmetatable({}, { __index = Component.Base })
	Button.__index = Button

	-- Triggers the callback programmatically.
	function Button:Fire()
		if self._destroyed or not self.Enabled then
			return
		end
		Utility.SafeCall("Button " .. tostring(self.Config.Title), self.Config.Callback)
		self.Changed:Fire()
	end

	function Button:SetCallback(callback)
		Utility.Check(type(callback) == "function", "Button", self.Config.Title, "Callback must be a function.")
		self.Config.Callback = callback
	end

	return function(ctx, id, config)
		Utility.Check(config.Callback == nil or type(config.Callback) == "function", "Button", config.Title, "Callback must be a function.")
		local self = Component.New(ctx, Button, "Button", id, config, { RightWidth = 16, RightHeight = 16 })
		local cleanup = self.Cleanup
		Icons.Create(self.Right, "chevron-right", { Size = 16, Cleanup = cleanup })
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
