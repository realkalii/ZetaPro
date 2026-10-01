return function(import)
	local Component = import("Core/Component")
	local Utility = import("Core/Utility")
	local Widgets = import("Core/Widgets")

	local Divider = setmetatable({}, { __index = Component.Base })
	Divider.__index = Divider

	return function(ctx, id, config)
		local self = Component.NewBare(ctx, Divider, "Divider", id, config)
		local frame = Utility.Create("Frame", {
			Name = "Divider",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 9),
			LayoutOrder = ctx.Order(),
			Parent = ctx.Parent,
		})
		self.Cleanup:Add(frame)
		Widgets.Surface(self.Cleanup, {
			Parent = frame,
			Fill = "Border",
			Radius = 0,
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.fromScale(0, 0.5),
			Size = UDim2.new(1, 0, 0, 1),
		})
		self.Frame = frame
		return self
	end
end
