return function(import)
	local Utility = import("Core/Utility")
	local Signal = import("Core/Signal")
	local Theme = import("Core/Theme")
	local Widgets = import("Core/Widgets")
	local Search = import("Core/Search")
	local Capabilities = import("Core/Capabilities")
	local Tab = import("Core/Tab")
	local Cleanup = import("Services/Cleanup")
	local Animation = import("Services/Animation")
	local Input = import("Services/Input")
	local Drag = import("Services/Drag")
	local Acrylic = import("Services/Acrylic")
	local Icons = import("Icons/Icon")
	local Dialog = import("Components/Dialog")
	local Design = import("Core/Design")
	local Home = import("Core/Home")
	local WindowSize = import("Core/WindowSize")

	local Window = {}
	Window.__index = Window

	local TOPBAR = Design.Topbar

	function Window.new(config)
		Utility.Check(type(config) == "table", "Window", "?", "Config must be a table.")
		Utility.Check(config.Title == nil or type(config.Title) == "string", "Window", config.Title, "Title must be a string.")
		local self = setmetatable({}, Window)
		self.Options, self.Tabs = {}, {}
		self._search = Search.new()
		self.Cleanup = Cleanup.new()
		self.Cleanup:Add(self._search.Changed)
		self.OnDestroy = Signal.new()
		self.MinimizedChanged = Signal.new()
		self.TabWidth = config.TabWidth or Design.Sidebar
		self.MinSize = config.MinSize or Vector2.new(560, 360)
		self.MaxSize = config.MaxSize or Vector2.new(1000, 800)
		self.Acrylic = true
		self._searchEnabled = config.SearchEnabled ~= false
		self._minimized, self._destroyed, self._compact = false, false, false
		local cleanup = self.Cleanup

		if config.Theme then
			Theme.Set(config.Theme)
		end
		Input.Init()

		local gui = cleanup:Add(Utility.NewScreenGui("ZetaPro_Window", 100))
		self.Gui = gui
		local size = WindowSize.Load(config, self.MinSize, self.MaxSize) or config.Size or UDim2.fromOffset(650, 455)

		local root = Widgets.Surface(cleanup, {
			Class = "CanvasGroup",
			Name = "Window",
			Parent = gui,
			Fill = "Background",
			Stroke = "Border",
			Radius = Design.Radius.Window,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(size.X.Offset, size.Y.Offset),
			GroupTransparency = 1,
		})
		self.Root = root
		Theme.BindFn(function()
			root.BackgroundTransparency = math.clamp(Theme.Get("AcrylicTransparency") or 0.38, 0.18, 0.65)
		end, cleanup)
		local uiScale = Instance.new("UIScale")
		uiScale.Parent = root
		Theme.BindScale(uiScale, cleanup)

		local topbar = Utility.Create("Frame", {
			Name = "Topbar",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, TOPBAR),
			Parent = root,
		})
		Widgets.Surface(cleanup, {
			Name = "TopbarLine",
			Parent = root,
			Fill = "Border",
			Radius = 0,
			Position = UDim2.fromOffset(0, TOPBAR),
			Size = UDim2.new(1, 0, 0, 1),
		})

		local titles = Utility.Create("Frame", {
			Name = "Titles",
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(18, 0),
			Size = UDim2.new(0, 0, 1, 0),
			AutomaticSize = Enum.AutomaticSize.X,
			Parent = topbar,
		})
		Widgets.List(titles, 10, {
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		})
		local brand = Utility.Create("Frame", {
			Name = "ZetaLogo", BackgroundTransparency = 1,
			Size = UDim2.fromOffset(32, 32), LayoutOrder = -2, Parent = titles,
		})
		local brandFallback = Widgets.Text(cleanup, {
			Parent = brand, Text = "ZΞ", Bold = true, TextSize = 20,
			TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromScale(1, 1),
		})
		local brandImage = Utility.Create("ImageLabel", {
			Name = "OriginalLogo", BackgroundTransparency = 1,
			Image = Design.Logo, ImageTransparency = 1, ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromScale(1, 1), Parent = brand,
		})
		cleanup:Add(task.spawn(function()
			local loaded = false
			local ok = pcall(function()
				game:GetService("ContentProvider"):PreloadAsync({ brandImage }, function(_, status)
					if status == Enum.AssetFetchStatus.Success then loaded = true end
				end)
			end)
			if ok and loaded and brandImage.Parent then
				brandImage.ImageTransparency = 0
				brandFallback.Visible = false
			end
		end))
		if config.Icon then
			local icon = Icons.Create(titles, config.Icon, { Size = 16, Color = "Text", Cleanup = cleanup })
			icon.Instance.LayoutOrder = 0
		end
		self._titleLabel = Widgets.Text(cleanup, {
			Name = "Title",
			Parent = titles,
			Text = config.Title or "ZetaPro",
			Bold = true,
			TextSize = 13,
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.new(0, 0, 1, 0),
			LayoutOrder = 1,
		})
		self._subtitleLabel = Widgets.Text(cleanup, {
			Name = "Subtitle",
			Parent = titles,
			Text = config.SubTitle or "v1.0.3",
			Color = "MutedText",
			TextSize = 11,
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.new(0, 0, 1, 0),
			LayoutOrder = 2,
			Visible = (config.SubTitle or "v1.0.3") ~= "",
		})

		local controls = Utility.Create("Frame", {
			Name = "Controls",
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -12, 0.5, 0),
			Size = UDim2.new(0, 0, 0, 28),
			AutomaticSize = Enum.AutomaticSize.X,
			Parent = topbar,
		})
		Widgets.List(controls, 6, {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		})
		local function control(iconName, order, callback)
			local button = Widgets.Surface(cleanup, {
				Class = "TextButton",
				Name = "Control_" .. iconName,
				Parent = controls,
				Fill = "SecondaryBackground",
				Transparency = "ElementTransparency",
				Radius = "Full",
				Size = UDim2.fromOffset(32, 32),
				LayoutOrder = order,
			})
			Icons.Create(button, iconName, { Size = 13, Position = UDim2.fromOffset(9.5, 9.5), Cleanup = cleanup })
			Widgets.Interactive(cleanup, button, button, {})
			cleanup:Add(button.Activated:Connect(callback))
			return button
		end
		control("minus", 1, function()
			self:Minimize()
		end)
		local controlsWidth = 32
		if config.CloseButton ~= false then
			controlsWidth = 70
			control("x", 2, function()
				Utility.SafeCall("Window OnClose", config.OnClose)
				self:Destroy()
			end)
		end

		local searchBox = Widgets.Surface(cleanup, {
			Name = "Search",
			Parent = topbar,
			Fill = "TertiaryBackground",
			Stroke = "Border",
			Radius = 14,
			Transparency = "ElementTransparency",
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -(controlsWidth + 20), 0.5, 0),
			Size = UDim2.fromOffset(170, 32),
		})
		self._searchBox = searchBox
		Icons.Create(searchBox, "search", { Size = 15, Position = UDim2.fromOffset(10, 8.5), Cleanup = cleanup })
		local searchInput = Widgets.Text(cleanup, {
			Class = "TextBox",
			Name = "SearchInput",
			Parent = searchBox,
			PlaceholderText = "Search...",
			ClearTextOnFocus = false,
			Position = UDim2.fromOffset(30, 0),
			Size = UDim2.new(1, -38, 1, 0),
		})
		self._searchInput = searchInput

		local sidebar = Utility.Create("Frame", {
			Name = "Sidebar",
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(0, TOPBAR + 1),
			Size = UDim2.new(0, self.TabWidth, 1, -(TOPBAR + 1)),
			Parent = root,
		})
		self._sidebar = sidebar
		Theme.BindFn(function()
			sidebar.BackgroundColor3 = Theme.Get("Sidebar") or Theme.Get("Background")
			sidebar.BackgroundTransparency = math.clamp(Theme.Get("SidebarTransparency") or 0.46, 0.18, 0.65)
		end, cleanup)
		Widgets.Surface(cleanup, {
			Name = "SidebarLine",
			Parent = sidebar,
			Fill = "Border",
			Radius = 0,
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.fromScale(1, 0),
			Size = UDim2.new(0, 1, 1, 0),
		})
		local tabList = Utility.Create("ScrollingFrame", {
			Name = "Tabs",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -1, 1, 0),
			CanvasSize = UDim2.new(),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollBarThickness = 0,
			ScrollingDirection = Enum.ScrollingDirection.Y,
			Parent = sidebar,
		})
		Widgets.Padding(tabList, 5)
		Widgets.List(tabList, 6)
		self._tabList = tabList

		self._pages = Utility.Create("Frame", {
			Name = "Content",
			BackgroundTransparency = 1,
			ClipsDescendants = true,
			Position = UDim2.fromOffset(self.TabWidth, TOPBAR + 1),
			Size = UDim2.new(1, -self.TabWidth, 1, -(TOPBAR + 1)),
			Parent = root,
		})
		self._content = self._pages

		local function layer(name, order)
			return Utility.Create("Frame", {
				Name = name,
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
				ZIndex = order,
				Parent = root,
			})
		end
		self._popupLayer = layer("Popups", 20)
		local searchLayer = layer("SearchLayer", 30)
		self._dialogLayer = layer("Dialogs", 40)

		local results = Widgets.Surface(cleanup, {
			Class = "ScrollingFrame",
			Name = "Results",
			Parent = searchLayer,
			Fill = "SecondaryBackground",
			Transparency = "ComponentTransparency",
			Stroke = "Border",
			Radius = 14,
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -10, 0, TOPBAR + 6),
			Size = UDim2.fromOffset(300, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			CanvasSize = UDim2.new(),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollBarThickness = 3,
			ScrollingDirection = Enum.ScrollingDirection.Y,
			Visible = false,
		})
		self._resultsFrame = results
		Utility.Create("UISizeConstraint", { MaxSize = Vector2.new(300, 260), Parent = results })
		Widgets.Padding(results, 4)
		Widgets.List(results, 2)

		local function showResults(text)
			if self._results then
				self._results:Clean()
			end
			local rc = cleanup:Extend()
			self._results = rc
			if text == "" then
				results.Visible = false
				return
			end
			results.Visible = true
			local list = self._search:Query(text)
			if #list == 0 then
				rc:Add(Widgets.Text(rc, {
					Parent = results,
					Text = "No results",
					Color = "MutedText",
					Size = UDim2.new(1, 0, 0, 32),
					TextXAlignment = Enum.TextXAlignment.Center,
				}))
				return
			end
			for index, entry in list do
				local row = Widgets.Surface(rc, {
					Class = "TextButton",
					Name = "Result",
					Parent = results,
					Fill = "SecondaryBackground",
					Radius = 12,
					Size = UDim2.new(1, 0, 0, 42),
					LayoutOrder = index,
				})
				rc:Add(row)
				local crumb = { entry.Tab.Title }
				if entry.Section and entry.Kind ~= "Section" then
					table.insert(crumb, entry.Section.Title)
				end
				if entry.Kind ~= "Tab" and entry.Kind ~= "Section" then
					table.insert(crumb, entry.Kind)
				end
				Widgets.Text(rc, {
					Parent = row,
					Text = entry.Title,
					Bold = true,
					Position = UDim2.fromOffset(10, 5),
					Size = UDim2.new(1, -20, 0, 16),
					TextTruncate = Enum.TextTruncate.AtEnd,
				})
				Widgets.Text(rc, {
					Parent = row,
					Text = table.concat(crumb, "  >  "),
					Color = "MutedText",
					TextSize = 11,
					Position = UDim2.fromOffset(10, 22),
					Size = UDim2.new(1, -20, 0, 14),
					TextTruncate = Enum.TextTruncate.AtEnd,
				})
				Widgets.Interactive(rc, row, row, {})
				rc:Add(row.Activated:Connect(function()
					searchInput.Text = ""
					self:_GoTo(entry)
				end))
			end
		end

		cleanup:Add(searchInput:GetPropertyChangedSignal("Text"):Connect(function()
			showResults(searchInput.Text)
		end))
		cleanup:Add(self._search.Changed:Connect(function()
			if not self._destroyed and searchInput.Text ~= "" then showResults(searchInput.Text) end
		end))
		cleanup:Add(searchInput.Focused:Connect(function()
			if searchInput.Text ~= "" then
				results.Visible = true
			end
		end))
		cleanup:Add(searchInput.FocusLost:Connect(function()
			task.delay(0.2, function()
				if not self._destroyed and not searchInput:IsFocused() then
					results.Visible = false
				end
			end)
		end))

		Drag.Attach(topbar, root, cleanup)
		do
			local grip = Utility.Create("TextButton", {
				Name = "ResizeGrip",
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(1, 1),
				Position = UDim2.new(1, -2, 1, -2),
				Size = UDim2.fromOffset(16, 16),
				ZIndex = 5,
				Parent = root,
			})
			Icons.Create(grip, "grip", { Size = 14, Position = UDim2.fromOffset(1, 1), Cleanup = cleanup })
			Drag.Resize(grip, root, cleanup, {
				Min = self.MinSize,
				Max = self.MaxSize,
				GetBounds = function()
					return self:_SizeBounds()
				end,
				GetScale = function()
					return Theme.Scale
				end,
				OnResize = function()
					self:_Clamp()
				end,
				OnEnd = function()
					if not self._destroyed then WindowSize.Save(config, root.Size) end
				end,
			})
		end

		local showRestore = config.RestoreButton
		if showRestore == nil then
			showRestore = true
		end
		if showRestore then
			local pillGui = cleanup:Add(Utility.NewScreenGui("ZetaPro_Restore", 101))
			pillGui.IgnoreGuiInset = true
			local control = Widgets.Surface(cleanup, {
				Class = "CanvasGroup",
				Name = "MinimizeControl",
				Parent = pillGui,
				Fill = "SecondaryBackground",
				Transparency = "ElementTransparency",
				Stroke = "Border",
				Radius = "Full",
				AnchorPoint = Vector2.new(0.5, 0),
				Position = UDim2.new(0.5, 0, 0, 10),
				Size = UDim2.fromOffset(76, 32),
				GroupTransparency = 0,
				Visible = false,
			})
			local controlScale = Instance.new("UIScale")
			controlScale.Scale = 0.92
			controlScale.Parent = control
			Widgets.Text(cleanup, {
				Name = "Brand",
				Parent = control,
				Text = "ZΞ",
				Bold = true,
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Center,
				Size = UDim2.new(0, 42, 1, 0),
			})
			Widgets.Surface(cleanup, {
				Name = "Separator",
				Parent = control,
				Fill = "Border",
				Radius = 0,
				BackgroundTransparency = 0.25,
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, 42, 0.5, 0),
				Size = UDim2.fromOffset(1, 14),
			})
			local chevron = Icons.Create(control, "chevron-down", {
				Size = 14,
				Position = UDim2.new(0, 50, 0.5, -7),
				Color = "MutedText",
				Cleanup = cleanup,
			})
			local hit = Utility.Create("TextButton", {
				Name = "Hit",
				BackgroundTransparency = 1,
				Text = "",
				Size = UDim2.fromScale(1, 1),
				ZIndex = 5,
				Parent = control,
			})
			Widgets.Interactive(cleanup, control, hit, {})
			cleanup:Add(hit.Activated:Connect(function()
				self:Restore()
			end))

			self._control = { Frame = control, Scale = controlScale, Chevron = chevron.Instance }
		end

		if Acrylic.Supported() then
			self._blur = Acrylic.new(cleanup, 10)
		end

		local cameraConnection
		local function hookCamera()
			if cameraConnection then
				cameraConnection:Disconnect()
				cameraConnection = nil
			end
			local camera = workspace.CurrentCamera
			if camera then
				cameraConnection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
					self:_Clamp()
				end)
			end
		end
		hookCamera()
		cleanup:Add(function()
			if cameraConnection then
				cameraConnection:Disconnect()
			end
		end)
		cleanup:Add(workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
			hookCamera()
			self:_Clamp()
		end))
		cleanup:Add(Theme.ScaleChanged:Connect(function()
			self:_Clamp()
		end))
		cleanup:Add(root:GetPropertyChangedSignal("Size"):Connect(function()
			self:_UpdateLayout()
		end))
		cleanup:Add(self.OnDestroy)
		cleanup:Add(self.MinimizedChanged)

		self:SetMinimizeKey(config.MinimizeKey)
		self:_Clamp()
		self:_UpdateLayout()
		self.Home = Home.Create(self, config)
		Animation:Play(root, { GroupTransparency = 0 }, { Duration = 0.2 })
		if self._blur then
			self._blur.SetActive(true)
		end
		return self
	end

	function Window:_SizeBounds()
		local camera = workspace.CurrentCamera
		local maxW, maxH = self.MaxSize.X, self.MaxSize.Y
		if camera then
			local viewport = camera.ViewportSize
			local scale = Theme.Scale
			maxW = math.max(1, math.min(maxW, viewport.X / scale - 24))
			maxH = math.max(1, math.min(maxH, viewport.Y / scale - 24))
		end
		local minW = math.min(self.MinSize.X, maxW)
		local minH = math.min(self.MinSize.Y, maxH)
		return Vector2.new(minW, minH), Vector2.new(maxW, maxH)
	end

	function Window:_Clamp()
		if self._destroyed then
			return
		end
		local minimum, maximum = self:_SizeBounds()
		local size = self.Root.Size
		local width = math.clamp(size.X.Offset, minimum.X, maximum.X)
		local height = math.clamp(size.Y.Offset, minimum.Y, maximum.Y)
		if width ~= size.X.Offset or height ~= size.Y.Offset then
			self.Root.Size = UDim2.fromOffset(width, height)
		end
	end

	function Window:_UpdateLayout()
		if self._destroyed then
			return
		end
		local width = self.Root.Size.X.Offset
		local compact = width < 540 or self.TabWidth < 120
		local sidebar = compact and 52 or math.min(self.TabWidth, math.floor(width * 0.4))
		self._compact = compact
		self._sidebar.Size = UDim2.new(0, sidebar, 1, -(TOPBAR + 1))
		self._content.Position = UDim2.fromOffset(sidebar, TOPBAR + 1)
		self._content.Size = UDim2.new(1, -sidebar, 1, -(TOPBAR + 1))
		for _, tab in self.Tabs do
			tab:_SetCompact(compact)
		end
		if self.Home then self.Home:_SetCompact(compact) end
		self._searchBox.Visible = self._searchEnabled
		self._titleLabel.Visible = width >= 390
		self._subtitleLabel.Visible = self._subtitleLabel.Text ~= "" and width >= 560
		self._titleLabel.AutomaticSize = Enum.AutomaticSize.None
		self._titleLabel.TextTruncate = Enum.TextTruncate.AtEnd
		self._titleLabel.Size = UDim2.fromOffset(math.clamp(width - (self._searchBox.Visible and 300 or 100), 60, 140), TOPBAR)
		self._searchBox.Size = UDim2.fromOffset(math.clamp(width - 255, 120, 170), 32)
		self._resultsFrame.Size = UDim2.fromOffset(math.min(300, width - 20), 0)
	end

	function Window:_IndexAdd(entry)
		return self._search:Add(entry)
	end

	function Window:_GoTo(entry)
		local tab = entry.Tab
		if self._destroyed or not tab or tab.Cleanup:IsCleaned() then
			return
		end
		if self._minimized then
			self:Restore()
		end
		self:SelectTab(tab)
		if entry.Section and entry.Section.IsExpanded and not entry.Section:IsExpanded() then
			entry.Section:Expand()
		end
		if entry.Kind == "Tab" then
			return
		end
		task.delay(0.22, function()
			if self._destroyed then
				return
			end
			local frame = entry.Frame
			if not frame or not frame.Parent then
				return
			end
			local page = tab.Page
			local offset = (frame.AbsolutePosition.Y - page.AbsolutePosition.Y) / Theme.Scale + page.CanvasPosition.Y - 8
			Animation:Play(page, { CanvasPosition = Vector2.new(0, math.max(0, offset)) }, { Duration = 0.25 })
			local stroke = entry.Component and entry.Component.Stroke
			if stroke then
				Animation:Play(stroke, { Color = Theme.Get("Accent"), Transparency = 0 }, { Duration = 0.15 })
				task.delay(0.9, function()
					if stroke.Parent and not self._destroyed then
						Animation:Play(stroke, { Color = Theme.Get("Border"), Transparency = 0.9 }, { Duration = 0.3 })
					end
				end)
			end
		end)
	end

	function Window:AddTab(config)
		Utility.Check(not self._destroyed, "Tab", config and config.Title, "Window is destroyed.")
		local tab = Tab.new(self, config)
		table.insert(self.Tabs, tab)
		tab:_SetCompact(self._compact)
		if not self._selected then
			self:SelectTab(tab)
		end
		return tab
	end

	function Window:SelectTab(target)
		if self._destroyed then
			return
		end
		local tab = target
		if type(target) == "number" then
			tab = self.Tabs[target]
		elseif type(target) == "string" then
			if target == "Home" and self.Home then
				tab = self.Home
			else
				tab = nil
				for _, candidate in self.Tabs do
					if candidate.Title == target then
						tab = candidate
						break
					end
				end
			end
		end
		if not tab or tab == self._selected then
			return
		end
		self:ClosePopup()
		if self._selected then
			self._selected:_SetSelected(false)
		end
		self._selected = tab
		tab:_SetSelected(true)
	end

	function Window:SetTitle(text)
		self._titleLabel.Text = text
	end

	function Window:SetSubtitle(text)
		text = text or ""
		self._subtitleLabel.Text = text
		self:_UpdateLayout()
	end

	function Window:SetTheme(name)
		return Theme.Set(name)
	end

	function Window:SetSearchEnabled(enabled)
		self._searchEnabled = enabled == true
		if not self._searchEnabled then
			self._searchInput.Text = ""
		end
		self:_UpdateLayout()
	end

	function Window:SetAcrylic(enabled)
		self.Acrylic = true
		Theme.Changed:Fire(Theme.GetName())
		if self._blur then
			self._blur.SetActive(not self._minimized)
		end
	end

	function Window:SetMinimizeKey(key)
		if self._minimizeBind then
			self._minimizeBind:Destroy()
			self._minimizeBind = nil
		end
		if key ~= nil then
			Utility.Check(typeof(key) == "EnumItem", "Window", "MinimizeKey", "MinimizeKey must be an Enum.KeyCode.")
			self._minimizeBind = self.Cleanup:Add(Input.AddBind(key, function()
				self:Toggle()
			end, "Window toggle"))
		end
	end

	function Window:_Control(show)
		local control = self._control
		if not control then
			return
		end
		local frame, scale, chevron = control.Frame, control.Scale, control.Chevron
		if show then
			frame.Visible = true
			chevron.Rotation = 180
			scale.Scale = 0.92
			Animation:Play(scale, { Scale = 1 }, { Duration = Animation.Duration.Normal })
			Animation:Play(chevron, { Rotation = 0 }, { Duration = Animation.Duration.Normal })
		else
			Animation:Play(chevron, { Rotation = 180 }, { Duration = Animation.Duration.Fast })
			Animation:Play(scale, { Scale = 0.92 }, {
				Duration = Animation.Duration.Fast,
				OnComplete = function()
					if not self._minimized and not self._destroyed then
						frame.Visible = false
					end
				end,
			})
		end
	end

	function Window:Minimize()
		if self._minimized or self._destroyed then
			return
		end
		self._minimized = true
		self:ClosePopup()
		if self._blur then
			self._blur.SetActive(false)
		end
		self:_Control(true)
		self.Root.Visible = false
		self.MinimizedChanged:Fire(true)
	end

	function Window:Restore()
		if not self._minimized or self._destroyed then
			return
		end
		self._minimized = false
		self.Root.Position = UDim2.fromScale(0.5, 0.5)
		self:_Clamp()
		self.Root.Visible = true
		self:_Control(false)
		if self._blur and self.Acrylic then
			self._blur.SetActive(true)
		end
		self.MinimizedChanged:Fire(false)
	end

	function Window:ToggleMinimize()
		if self._minimized then
			self:Restore()
		else
			self:Minimize()
		end
	end

	function Window:Toggle()
		self:ToggleMinimize()
	end

	function Window:IsMinimized()
		return self._minimized
	end

	function Window:CreateDialog(config)
		Utility.Check(not self._destroyed, "Dialog", config and config.Title, "Window is destroyed.")
		return Dialog.new(self, config)
	end

	function Window:OpenPopup(anchor, width, height)
		self:ClosePopup()
		local layer = self._popupLayer
		local cleanup = self.Cleanup:Extend()
		local closed = Signal.new()
		cleanup:Add(closed)

		local catcher = Utility.Create("TextButton", {
			Name = "PopupCatcher",
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			Parent = layer,
		})
		cleanup:Add(catcher)
		local frame = Widgets.Surface(cleanup, {
			Class = "CanvasGroup",
			Name = "Popup",
			Parent = layer,
			Fill = "SecondaryBackground",
			Transparency = "ComponentTransparency",
			Stroke = "Border",
			Radius = 14,
			Size = UDim2.fromOffset(width, height),
			GroupTransparency = 1,
			ZIndex = 2,
		})
		cleanup:Add(frame)

		local scale = Theme.Scale
		local rootPosition, rootSize = self.Root.AbsolutePosition, self.Root.Size
		local anchorPosition, anchorSize = anchor.AbsolutePosition, anchor.AbsoluteSize
		local x = (anchorPosition.X - rootPosition.X + anchorSize.X) / scale - width
		local y = (anchorPosition.Y - rootPosition.Y + anchorSize.Y) / scale + 4
		if y + height > rootSize.Y.Offset - 8 then
			y = (anchorPosition.Y - rootPosition.Y) / scale - height - 4
		end
		x = math.clamp(x, 8, math.max(8, rootSize.X.Offset - width - 8))
		y = math.clamp(y, 8, math.max(8, rootSize.Y.Offset - height - 8))
		frame.Position = UDim2.fromOffset(x, y)
		Animation:Play(frame, { GroupTransparency = 0 }, { Duration = 0.12 })

		local popup = { Frame = frame, Cleanup = cleanup, Closed = closed }
		local isClosed = false
		function popup.Close()
			if isClosed then
				return
			end
			isClosed = true
			if self._popup == popup then
				self._popup = nil
			end
			closed:Fire()
			catcher:Destroy()
			Animation:Play(frame, { GroupTransparency = 1 }, {
				Duration = 0.1,
				OnComplete = function()
					cleanup:Clean()
				end,
			})
			task.delay(0.3, function()
				cleanup:Clean()
			end)
		end
		cleanup:Add(catcher.Activated:Connect(popup.Close))
		self._popup = popup
		return popup
	end

	function Window:ClosePopup()
		if self._popup then
			self._popup.Close()
		end
	end

	function Window:Destroy()
		if self._destroyed then
			return
		end
		self._destroyed = true
		if self._popup then
			self._popup.Close()
		end
		self.OnDestroy:Fire()
		Animation:CancelTree(self.Gui)
		self.Cleanup:Clean()
		table.clear(self.Options)
		table.clear(self.Tabs)
	end

	return Window
end
