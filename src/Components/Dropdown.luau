return function(import)
	local Component = import("Core/Component")
	local Utility = import("Core/Utility")
	local Widgets = import("Core/Widgets")
	local Theme = import("Core/Theme")
	local Icons = import("Icons/Icon")

	local Dropdown = setmetatable({}, { __index = Component.Base })
	Dropdown.__index = Dropdown

	-- Single: value is a string (or an index). Multi: value is { [name] = boolean }.
	function Dropdown:_Normalize(value)
		if self.Multi then
			if type(value) ~= "table" then
				return false
			end
			local isArray = value[1] ~= nil
			local map = {}
			for _, name in self.Values do
				if isArray then
					map[name] = table.find(value, name) ~= nil
				else
					map[name] = value[name] == true
				end
			end
			return true, map
		end
		if value == nil then
			return true, nil
		end
		if type(value) == "number" then
			local name = self.Values[value]
			if name == nil then
				return false
			end
			return true, name
		end
		if type(value) == "string" and table.find(self.Values, value) then
			return true, value
		end
		return false
	end

	local function display(self, value)
		if self.Multi then
			local picked = {}
			for _, name in self.Values do
				if value and value[name] then
					table.insert(picked, name)
				end
			end
			return #picked > 0 and table.concat(picked, ", ") or "None"
		end
		return value or "None"
	end

	function Dropdown:SetValues(values)
		Utility.Check(type(values) == "table", self.Kind, self.Id, "Values must be an array of strings.")
		for _, name in values do
			Utility.Check(type(name) == "string", self.Kind, self.Id, "Values must be strings.")
		end
		if self._popup then
			self._popup.Close()
		end
		self.Values = table.clone(values)
		local valid, normalized = self:_Normalize(self.State:Get())
		if not valid then
			normalized = self.Multi and {} or nil
			if self.Multi then
				_, normalized = self:_Normalize({})
			end
		end
		self.State:Set(normalized)
		self._render(self.State:Get())
	end

	function Dropdown:_Open()
		if self._destroyed or not self.Enabled then
			return
		end
		local button = self._button
		local count = #self.Values
		local width = math.max(160, button.AbsoluteSize.X / Theme.Scale)
		local popup = self.Window:OpenPopup(button, width, math.max(36, math.min(count * 28 + 8, 208)))
		self._popup = popup
		local cleanup = popup.Cleanup
		cleanup:Add(popup.Closed:Connect(function()
			if self._popup == popup then
				self._popup = nil
			end
		end))

		local list = Utility.Create("ScrollingFrame", {
			Name = "Options",
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			CanvasSize = UDim2.new(),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollBarThickness = 3,
			ScrollingDirection = Enum.ScrollingDirection.Y,
			Parent = popup.Frame,
		})
		Widgets.Padding(list, 4)
		Widgets.List(list, 2)

		local checks = {}
		for index, name in self.Values do
			local row = Widgets.Surface(cleanup, {
				Class = "TextButton",
				Name = name,
				Parent = list,
				Fill = "SecondaryBackground",
				Radius = 10,
				Size = UDim2.new(1, 0, 0, 26),
				LayoutOrder = index,
			})
			Widgets.Text(cleanup, {
				Parent = row,
				Text = name,
				Position = UDim2.fromOffset(8, 0),
				Size = UDim2.new(1, -30, 1, 0),
				TextTruncate = Enum.TextTruncate.AtEnd,
			})
			local check = Icons.Create(row, "check", {
				Size = 14,
				Color = "Text",
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -8, 0.5, 0),
				Cleanup = cleanup,
			})
			checks[name] = check
			Widgets.Interactive(cleanup, row, row, {})
			cleanup:Add(row.Activated:Connect(function()
				if self.Multi then
					local value = table.clone(self.State:Get() or {})
					value[name] = not value[name]
					self.State:Set(value)
				else
					self.State:Set(name)
					popup.Close()
				end
			end))
		end

		local function refresh()
			local value = self.State:Get()
			for name, check in checks do
				local selected
				if self.Multi then
					selected = value ~= nil and value[name] == true
				else
					selected = value == name
				end
				check.Instance.Visible = selected
			end
		end
		cleanup:Add(self.State.Changed:Connect(refresh))
		refresh()
	end

	return function(ctx, id, config)
		local values = config.Values
		Utility.Check(type(values) == "table", "Dropdown", id, "Values must be an array of strings.")
		for _, name in values do
			Utility.Check(type(name) == "string", "Dropdown", id, "Values must be strings.")
		end
		local multi = config.Multi == true
		local self = Component.New(ctx, Dropdown, multi and "MultiDropdown" or "Dropdown", id, config, { RightWidth = 160, RightHeight = 26 })
		self.Values, self.Multi = table.clone(values), multi
		local cleanup = self.Cleanup

		local valid, default = self:_Normalize(multi and (config.Default or {}) or config.Default)
		Utility.Check(valid, self.Kind, id, multi and "Default must be a table ({ Name = true } or an array of names)." or "Default must be a value (or index) from Values.")

		local button = Widgets.Surface(cleanup, {
			Class = "TextButton",
			Name = "Select",
			Parent = self.Right,
			Fill = "TertiaryBackground",
			Stroke = "Border",
			Radius = 12,
			Size = UDim2.fromScale(1, 1),
		})
		self._button = button
		local label = Widgets.Text(cleanup, {
			Parent = button,
			Position = UDim2.fromOffset(10, 0),
			Size = UDim2.new(1, -34, 1, 0),
			TextSize = 12,
			TextTruncate = Enum.TextTruncate.AtEnd,
		})
		Icons.Create(button, "chevron-down", {
			Size = 14,
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -8, 0.5, 0),
			Cleanup = cleanup,
		})
		Widgets.Interactive(cleanup, button, button, { Base = "TertiaryBackground" })

		self._render = function(value)
			label.Text = display(self, value)
		end
		Component.BindValue(self, id, default, function(value)
			self._render(value)
		end)
		cleanup:Add(button.Activated:Connect(function()
			self:_Open()
		end))
		cleanup:Add(function()
			if self._popup then
				self._popup.Close()
			end
		end)
		return self
	end
end
