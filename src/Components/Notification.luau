return function(import)
	local TweenService = game:GetService("TweenService")
	local Utility = import("Core/Utility")
	local Signal = import("Core/Signal")
	local Widgets = import("Core/Widgets")
	local Theme = import("Core/Theme")
	local Icons = import("Icons/Icon")
	local Animation = import("Services/Animation")
	local Cleanup = import("Services/Cleanup")

	local Toast = {}

	local function tint(kind)
		local name = Theme.GetName()
		if name == "Dark" or name == "Light" then
			return Theme.Get(kind.Token)
		end
		return Theme.Get("Accent") or Theme.Get(kind.Token)
	end
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
		self.Cleanup:Add(self.Closed)
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
			Transparency = "ComponentTransparency",
			Stroke = "Border",
			Radius = 14,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Position = UDim2.fromOffset(40, 0),
			GroupTransparency = 1,
		})
		self.Frame = card
		Theme.BindFn(function()
			card.BackgroundTransparency = math.clamp((Theme.Get("ComponentTransparency") or 0.4) * 0.75, 0.18, 0.45)
		end, cleanup)
		Widgets.List(card, 0)

		local body = Utility.Create("Frame", {
			Name = "Body",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = 1,
			Parent = card,
		})
		Widgets.Padding(body, 11)

		local icon = Icons.Create(body, config.Icon or kind.Icon, { Size = 22, Color = tint(kind), Cleanup = cleanup })
		Theme.BindFn(function() icon:SetColor(tint(kind)) end, cleanup)
		icon.Instance.Position = UDim2.fromOffset(0, 0)

		local column = Utility.Create("Frame", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(34, 0),
			Size = UDim2.new(1, -70, 0, 0),
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
			Color = "Text",
			TextSize = 13,
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
				Position = UDim2.new(1, 3, 0, -3),
				Size = UDim2.fromOffset(30, 30),
				Parent = body,
			})
			Icons.Create(close, "x", { Size = 14, Position = UDim2.fromOffset(8, 8), Cleanup = cleanup })
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
			local track = Widgets.Surface(cleanup, {
				Name = "ProgressTrack", Fill = "TertiaryBackground", Radius = "Full",
				Size = UDim2.new(1, 0, 0, 3),
				LayoutOrder = 2,
				Parent = card,
			})
			local bar = Utility.Create("Frame", { Size = UDim2.fromScale(1, 1), Parent = track })
			Utility.Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = bar })
			Theme.BindFn(function() bar.BackgroundColor3 = tint(kind) end, cleanup)
			local progressTween = TweenService:Create(bar, TweenInfo.new(duration, Enum.EasingStyle.Linear), { Size = UDim2.fromScale(0, 1) })
			self._progressTween = progressTween
			cleanup:Add(progressTween)
			progressTween:Play()
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
		if self._progressTween then self._progressTween:Cancel() end
		self.Closed:Fire()
		if self._onClosed then
			self._onClosed(self)
		end
		Animation:CancelTree(self.Frame)
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
