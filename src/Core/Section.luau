return function(import)
	local Utility = import("Core/Utility")
	local Widgets = import("Core/Widgets")
	local Component = import("Core/Component")
	local Animation = import("Services/Animation")
	local Icons = import("Icons/Icon")

	local Section = {}
	Component.MakeContainer(Section)

	function Section.new(tab, title, options)
		Utility.Check(type(title) == "string", "Section", title, "Title must be a string.")
		options = options or {}
		Utility.Check(type(options) == "table", "Section", title, "Options must be a table.")
		local self = setmetatable({}, Section)
		local window = tab.Window
		self.Window, self.Title, self.TabRef, self.SectionRef = window, title, tab, self
		self.Cleanup = tab.Cleanup:Extend()
		self.Collapsible = options.Collapsible == true
		self._expanded = not self.Collapsible or options.DefaultExpanded ~= false
		self._order = 0
		self.NextOrder = function()
			self._order += 1
			return self._order
		end
		local cleanup = self.Cleanup

		local frame = Utility.Create("Frame", {
			Name = "Section_" .. title, BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = tab.NextOrder(), Parent = tab.Container,
		})
		cleanup:Add(frame)
		Widgets.List(frame, 6)
		self.Frame = frame

		local header = Utility.Create("Frame", {
			Name = "Header", BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 28), LayoutOrder = 0, Parent = frame,
		})
		self._label = Widgets.Text(cleanup, {
			Parent = header, Text = title, Color = "MutedText", Bold = true,
			TextSize = 12, Size = UDim2.new(1, self.Collapsible and -24 or 0, 1, -4),
		})
		Widgets.Surface(cleanup, {
			Parent = header, Fill = "Border", Radius = 0,
			Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1),
		})
		self.Header = header

		local clip = Utility.Create("Frame", {
			Name = "BodyClip", BackgroundTransparency = 1, ClipsDescendants = true,
			Size = UDim2.new(1, 0, 0, 0), LayoutOrder = 1,
			Visible = self._expanded, Parent = frame,
		})
		self._clip = clip
		self.Container = Utility.Create("Frame", {
			Name = "Body", BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
			Parent = clip,
		})
		Widgets.List(self.Container, 8)
		local function resize()
			if self._expanded and not cleanup:IsCleaned() then
				local height = self.Container.AbsoluteSize.Y
				if clip.Size.Y.Offset ~= height then
					Animation:Play(clip, { Size = UDim2.new(1, 0, 0, height) }, { Duration = Animation.Duration.Normal })
				end
			end
		end
		cleanup:Add(self.Container:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize))
		task.defer(resize)

		if self.Collapsible then
			local toggle = Utility.Create("TextButton", {
				Name = "CollapseSection", BackgroundTransparency = 1, Text = "",
				Size = UDim2.fromScale(1, 1), Parent = header,
			})
			local chevron = Icons.Create(header, "chevron-down", {
				Size = 15, Color = "MutedText", Cleanup = cleanup,
				Position = UDim2.new(1, -19, 0.5, -7.5),
			})
			self._chevron = chevron.Instance
			self._chevron.Rotation = self._expanded and 0 or -90
			cleanup:Add(toggle.Activated:Connect(function() self:Toggle() end))
		end

		self._entry = window:_IndexAdd({ Kind = "Section", Title = title, Tab = tab, Section = self, Frame = header })
		cleanup:Add(function()
			if self._entry then self._entry.Remove() end
		end)
		return self
	end

	function Section:IsExpanded()
		return self._expanded
	end

	function Section:Expand()
		if self._expanded or self.Cleanup:IsCleaned() then return end
		self._expanded = true
		self._clip.Visible = true
		local height = self.Container.AbsoluteSize.Y
		Animation:Play(self._clip, { Size = UDim2.new(1, 0, 0, height) }, { Duration = Animation.Duration.Normal })
		if self._chevron then Animation:Play(self._chevron, { Rotation = 0 }, { Duration = Animation.Duration.Normal }) end
	end

	function Section:Collapse()
		if not self._expanded or self.Cleanup:IsCleaned() then return end
		self._expanded = false
		self.Window:ClosePopup()
		Animation:Play(self._clip, { Size = UDim2.new(1, 0, 0, 0) }, {
			Duration = Animation.Duration.Normal,
			OnComplete = function()
				if not self._expanded and not self.Cleanup:IsCleaned() then self._clip.Visible = false end
			end,
		})
		if self._chevron then Animation:Play(self._chevron, { Rotation = -90 }, { Duration = Animation.Duration.Normal }) end
	end

	function Section:Toggle()
		if self._expanded then self:Collapse() else self:Expand() end
	end

	function Section:SetTitle(value)
		self.Title = value
		self._label.Text = value
		self._entry.Title = value
	end

	function Section:SetVisible(visible)
		self.Frame.Visible = visible
		self.Window._search.Changed:Fire()
	end

	function Section:Destroy()
		Animation:CancelTree(self.Frame)
		self.Cleanup:Clean()
	end

	return Section
end
