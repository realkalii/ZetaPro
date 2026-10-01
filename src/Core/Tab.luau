return function(import)
	local Utility = import("Core/Utility")
	local Theme = import("Core/Theme")
	local Widgets = import("Core/Widgets")
	local Component = import("Core/Component")
	local Section = import("Core/Section")
	local Animation = import("Services/Animation")
	local Icons = import("Icons/Icon")

	local Tab = {}
	Component.MakeContainer(Tab)

	function Tab.new(window, config)
		Utility.Check(type(config) == "table" and type(config.Title) == "string", "Tab", config and config.Title, "Title must be a string.")
		local self = setmetatable({}, Tab)
		self.Window, self.Title = window, config.Title
		self.TabRef, self.SectionRef = self, nil
		self.Selected, self._hover, self._compact = false, false, false
		self._order = 0
		self.NextOrder = function()
			self._order += 1
			return self._order
		end
		self.Cleanup = window.Cleanup:Extend()
		local cleanup = self.Cleanup

		local button = Widgets.Surface(cleanup, {
			Class = "TextButton",
			Name = "Tab_" .. config.Title,
			Parent = window._tabList,
			Fill = "SecondaryBackground",
			BackgroundTransparency = 1,
			Radius = 6,
			Size = UDim2.new(1, 0, 0, 34),
			LayoutOrder = #window.Tabs + 1,
		})
		cleanup:Add(button)
		self.Button = button

		self._indicator = Widgets.Surface(cleanup, {
			Parent = button,
			Fill = "Accent",
			Radius = "Full",
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 2, 0.5, 0),
			Size = UDim2.fromOffset(3, 0),
		})
		self._icon = Icons.Create(button, config.Icon, { Size = 16, Cleanup = cleanup })
		self._title = Widgets.Text(cleanup, {
			Parent = button,
			Text = config.Title,
			Color = "MutedText",
			TextTruncate = Enum.TextTruncate.AtEnd,
			Size = UDim2.new(1, -40, 1, 0),
			Position = UDim2.fromOffset(38, 0),
		})

		local page = Utility.Create("ScrollingFrame", {
			Name = "Page_" .. config.Title,
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			CanvasSize = UDim2.new(),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollingDirection = Enum.ScrollingDirection.Y,
			ScrollBarThickness = 3,
			Visible = false,
			Parent = window._pages,
		})
		cleanup:Add(page)
		Theme.BindFn(function()
			page.ScrollBarImageColor3 = Theme.Get("MutedText")
		end, cleanup)
		Widgets.Padding(page, 12)
		Widgets.List(page, 8)
		self.Page, self.Container = page, page

		cleanup:Add(button.MouseEnter:Connect(function()
			self._hover = true
			self:_Visual()
		end))
		cleanup:Add(button.MouseLeave:Connect(function()
			self._hover = false
			self:_Visual()
		end))
		cleanup:Add(button.Activated:Connect(function()
			window:SelectTab(self)
		end))
		Theme.BindFn(function()
			self:_Visual(true)
		end, cleanup)

		self._entry = window:_IndexAdd({ Kind = "Tab", Title = config.Title, Tab = self })
		cleanup:Add(function()
			if self._entry then
				self._entry.Remove()
			end
		end)
		self:_Layout()
		return self
	end

	function Tab:_Layout()
		local hasIcon = self._icon.Instance.Visible
		if self._compact then
			self._icon.Instance.AnchorPoint = Vector2.new(0.5, 0.5)
			self._icon.Instance.Position = UDim2.fromScale(0.5, 0.5)
			self._title.Visible = false
		else
			self._icon.Instance.AnchorPoint = Vector2.zero
			self._icon.Instance.Position = UDim2.new(0, 14, 0.5, -8)
			self._title.Visible = true
			local x = hasIcon and 38 or 14
			self._title.Position = UDim2.fromOffset(x, 0)
			self._title.Size = UDim2.new(1, -(x + 6), 1, 0)
		end
	end

	function Tab:_SetCompact(compact)
		if self._compact ~= compact then
			self._compact = compact
			self:_Layout()
		end
	end

	function Tab:_Visual(instant)
		local selected, hover = self.Selected, self._hover
		local buttonGoal = {
			BackgroundColor3 = Theme.Get(selected and "SecondaryBackground" or "Hover"),
			BackgroundTransparency = selected and 0 or (hover and 0.5 or 1),
		}
		local textColor = Theme.Get(selected and "Text" or "MutedText")
		local indicatorGoal = { Size = UDim2.fromOffset(3, selected and 16 or 0) }
		if instant then
			for property, value in buttonGoal do
				self.Button[property] = value
			end
			self._title.TextColor3 = textColor
			self._indicator.Size = indicatorGoal.Size
		else
			Animation:Play(self.Button, buttonGoal, { Duration = Animation.Duration.Fast })
			Animation:Play(self._title, { TextColor3 = textColor }, { Duration = Animation.Duration.Fast })
			Animation:Play(self._indicator, indicatorGoal, { Duration = Animation.Duration.Fast })
		end
		self._icon:SetColor(selected and "Text" or "MutedText")
	end

	function Tab:_SetSelected(selected)
		self.Selected = selected
		self.Page.Visible = selected
		if selected then
			self.Page.Position = UDim2.fromOffset(0, 8)
			Animation:Play(self.Page, { Position = UDim2.new() }, { Duration = 0.18 })
		end
		self:_Visual()
	end

	function Tab:Select()
		self.Window:SelectTab(self)
	end

	function Tab:Deselect()
		if self.Window._selected == self then
			self.Window._selected = nil
		end
		self:_SetSelected(false)
	end

	function Tab:SetTitle(text)
		self.Title = text
		self._title.Text = text
		self._entry.Title = text
	end

	function Tab:SetIcon(spec)
		self._icon:Set(spec)
		self:_Layout()
	end

	function Tab:AddSection(title)
		return Section.new(self, title)
	end

	function Tab:Destroy()
		local window = self.Window
		local index = table.find(window.Tabs, self)
		if index then
			table.remove(window.Tabs, index)
		end
		local wasSelected = window._selected == self
		if wasSelected then
			window._selected = nil
		end
		Animation:CancelTree(self.Page)
		self.Cleanup:Clean()
		if wasSelected and window.Tabs[1] then
			window:SelectTab(window.Tabs[1])
		end
	end

	return Tab
end
