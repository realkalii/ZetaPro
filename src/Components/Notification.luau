return function(import)
	local Utility = import("Core/Utility")
	local Signal = import("Core/Signal")
	local Widgets = import("Core/Widgets")
	local Theme = import("Core/Theme")
	local Icons = import("Icons/Icon")
	local Animation = import("Services/Animation")
	local Cleanup = import("Services/Cleanup")

	local Toast = {}
	Toast.__index = Toast

	local TYPES = {
		Info = { Icon = "info", Token = "Info" },
		Success = { Icon = "check-circle", Token = "Success" },
		Warning = { Icon = "alert-triangle", Token = "Warning" },
		Error = { Icon = "alert-circle", Token = "Error" },
	}

	function Toast.new(holder, config, order, onClosed)
		local kind = TYPES[config.Type or "Info"]
		Utility.Check(kind ~= nil, "Notification", config.Title, "Type must be Info, Success, Warning or Error.")
		local self = setmetatable({}, Toast)
		self.Cleanup = Cleanup.new()
		self.Closed = Signal.new()
		self._closed = false
		local cleanup = self.Cleanup

		local wrapper = Utility.Create("Frame", {
			Name = "Toast",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = order,
			Parent = holder,
		})
		cleanup:Add(wrapper)

		local card = Widgets.Surface(cleanup, {
			Class = "CanvasGroup",
			Parent = wrapper,
			Fill = "SecondaryBackground",
			Stroke = "Border",
			Radius = 20,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Position = UDim2.fromOffset(40, 0),
			GroupTransparency = 1,
		})
		self.Frame = card
		Widgets.List(card, 0)

		local body = Utility.Create("Frame", {
			Name = "Body",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = 1,
			Parent = card,
		})
		Widgets.Padding(body, 14)

		local icon = Icons.Create(body, config.Icon or kind.Icon, { Size = 16, Color = kind.Token, Cleanup = cleanup })
		icon.Instance.Position = UDim2.fromOffset(0, 1)

		local column = Utility.Create("Frame", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(26, 0),
			Size = UDim2.new(1, -52, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Parent = body,
		})
		Widgets.List(column, 3)
		local title = config.Title or ""
		Widgets.Text(cleanup, {
			Parent = column,
			Text = title,
			Bold = true,
			TextWrapped = true,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = 1,
			Visible = title ~= "",
		})
		local content = config.Content or ""
		Widgets.Text(cleanup, {
			Parent = column,
			Text = content,
			Color = "MutedText",
			TextSize = 12,
			TextWrapped = true,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = 2,
			Visible = content ~= "",
		})

		if config.Closable ~= false then
			local close = Utility.Create("TextButton", {
				Name = "Close",
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, 0, 0, 0),
				Size = UDim2.fromOffset(18, 18),
				Parent = body,
			})
			Icons.Create(close, "x", { Size = 12, Position = UDim2.fromOffset(3, 3), Cleanup = cleanup })
			cleanup:Add(close.Activated:Connect(function()
				self:Close()
			end))
		end

		local duration = config.Duration
		if duration == nil then
			duration = 4
		end
		local timed = type(duration) == "number" and duration > 0 and duration < math.huge
		if timed and config.Progress ~= false then
			local track = Utility.Create("Frame", {
				Name = "Progress",
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 2),
				LayoutOrder = 2,
				Parent = card,
			})
			local bar = Utility.Create("Frame", { Size = UDim2.fromScale(1, 1), Parent = track })
			Theme.Bind(bar, { BackgroundColor3 = kind.Token }, cleanup)
			Animation:Play(bar, { Size = UDim2.fromScale(0, 1) }, { Duration = duration, Style = Enum.EasingStyle.Linear })
		end

		Animation:Play(card, { GroupTransparency = 0, Position = UDim2.new() }, { Duration = 0.2 })
		if timed then
			cleanup:Add(task.delay(duration, function()
				self:Close()
			end))
		end

		self._onClosed = onClosed
		return self
	end

	function Toast:Close()
		if self._closed then
			return
		end
		self._closed = true
		self.Closed:Fire()
		if self._onClosed then
			self._onClosed(self)
		end
		Animation:Play(self.Frame, { GroupTransparency = 1, Position = UDim2.fromOffset(40, 0) }, {
			Duration = 0.15,
			OnComplete = function()
				self.Cleanup:Clean()
			end,
		})
		task.delay(0.4, function()
			self.Cleanup:Clean()
		end)
	end

	function Toast:Destroy()
		self._closed = true
		self.Cleanup:Clean()
		self.Closed:Destroy()
	end

	return Toast
end
