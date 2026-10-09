return function(import)
	local Utility = import("Core/Utility")
	local Signal = import("Core/Signal")
	local Widgets = import("Core/Widgets")
	local Animation = import("Services/Animation")

	local Dialog = {}
	Dialog.__index = Dialog

	-- Window:CreateDialog({ Title, Content, Buttons = { { Title, Callback, Primary } } })
	function Dialog.new(window, config)
		Utility.Check(type(config) == "table" and type(config.Title) == "string", "Dialog", config and config.Title, "Title must be a string.")
		local self = setmetatable({}, Dialog)
		self.Window = window
		self.Closed = Signal.new()
		self._closed = false
		self.Cleanup = window.Cleanup:Extend()
		local cleanup = self.Cleanup
		cleanup:Add(self.Closed)

		local overlay = Widgets.Surface(cleanup, {
			Name = "DialogOverlay",
			Parent = window._dialogLayer,
			Fill = "Overlay",
			BackgroundTransparency = 1,
			Radius = 0,
			Active = true,
			Size = UDim2.fromScale(1, 1),
		})
		cleanup:Add(overlay)
		self._overlay = overlay

		local box = Widgets.Surface(cleanup, {
			Class = "CanvasGroup",
			Name = "Dialog",
			Parent = overlay,
			Fill = "SecondaryBackground",
			Stroke = "Border",
			Radius = 20,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.new(0, 320, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			GroupTransparency = 1,
		})
		self._box = box
		Widgets.Padding(box, 16)
		Widgets.List(box, 10)
		local limit = Instance.new("UISizeConstraint")
		limit.MaxSize = Vector2.new(360, math.huge)
		limit.Parent = box

		Widgets.Text(cleanup, {
			Parent = box,
			Text = config.Title,
			Bold = true,
			TextSize = 15,
			Size = UDim2.new(1, 0, 0, 20),
			LayoutOrder = 1,
		})
		if config.Content and config.Content ~= "" then
			Widgets.Text(cleanup, {
				Parent = box,
				Text = config.Content,
				Color = "MutedText",
				TextWrapped = true,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				LayoutOrder = 2,
			})
		end
		self._buttons = Utility.Create("Frame", {
			Name = "Buttons",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 32),
			LayoutOrder = 3,
			Parent = box,
		})
		Widgets.List(self._buttons, 8, {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		})

		Animation:Play(overlay, { BackgroundTransparency = 0.45 }, { Duration = 0.15 })
		Animation:Play(box, { GroupTransparency = 0 }, { Duration = 0.15 })

		for _, buttonConfig in config.Buttons or {} do
			self:AddButton(buttonConfig)
		end
		return self
	end

	function Dialog:AddButton(config)
		Utility.Check(type(config) == "table" and type(config.Title) == "string", "Dialog button", config and config.Title, "Title must be a string.")
		self._count = (self._count or 0) + 1
		local primary = config.Primary == true
		local cleanup = self.Cleanup
		local strokeToken = "Border"
		if primary then
			strokeToken = nil
		end
		local button = Widgets.Surface(cleanup, {
			Class = "TextButton",
			Name = "Button_" .. config.Title,
			Parent = self._buttons,
			Fill = primary and "Accent" or "TertiaryBackground",
			Stroke = strokeToken,
			Radius = 14,
			Size = UDim2.new(0, 0, 1, 0),
			AutomaticSize = Enum.AutomaticSize.X,
			LayoutOrder = self._count,
			Text = config.Title,
		})
		Widgets.Padding(button, 16, 0)
		local theme = import("Core/Theme")
		theme.BindFn(function()
			button.TextColor3 = theme.Get(primary and "AccentText" or "Text")
			button.FontFace = theme.FontBold
			button.TextSize = 13
		end, cleanup)
		Widgets.Interactive(cleanup, button, button, {
			Base = primary and "Accent" or "TertiaryBackground",
			Hover = primary and "Accent" or "Hover",
			Pressed = primary and "Accent" or "Pressed",
			Alpha = primary and { 0, 0.12, 0.25 } or nil,
		})
		cleanup:Add(button.Activated:Connect(function()
			if self._closed then
				return
			end
			Utility.SafeCall("Dialog button " .. config.Title, config.Callback)
			self:Close()
		end))
		return self
	end

	function Dialog:Close()
		if self._closed then
			return
		end
		self._closed = true
		self.Closed:Fire()
		Animation:Play(self._box, { GroupTransparency = 1 }, { Duration = 0.12 })
		Animation:Play(self._overlay, { BackgroundTransparency = 1 }, {
			Duration = 0.12,
			OnComplete = function()
				self.Cleanup:Clean()
			end,
		})
		task.delay(0.4, function()
			self.Cleanup:Clean()
		end)
	end

	return Dialog
end
