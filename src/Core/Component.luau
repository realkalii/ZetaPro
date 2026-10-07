return function(import)
	local Utility = import("Core/Utility")
	local Signal = import("Core/Signal")
	local State = import("Core/State")
	local Config = import("Core/Config")
	local Theme = import("Core/Theme")
	local Widgets = import("Core/Widgets")
	local Icons = import("Icons/Icon")
	local Tooltip = import("Services/Tooltip")
	local Animation = import("Services/Animation")

	local Component = { Registry = {} }
	local Base = {}
	Base.__index = Base
	Component.Base = Base

	function Component.Register(name, factory)
		Utility.Check(type(name) == "string" and string.match(name, "^%u%w*$") ~= nil, "Component", name, "Name must be PascalCase and alphanumeric.")
		Utility.Check(type(factory) == "function", "Component", name, "Factory must be a function.")
		Component.Registry[name] = factory
	end

	function Component.NewBare(ctx, class, kind, id, config)
		Utility.Check(type(config) == "table", kind, id, "Config must be a table.")
		local self = setmetatable({}, class)
		self.Kind, self.Id, self.Config = kind, id, config
		self.Window, self.Tab, self.Section = ctx.Window, ctx.Tab, ctx.Section
		self.Cleanup = ctx.Cleanup:Extend()
		self.Changed = Signal.new()
		self.Cleanup:Add(self.Changed)
		self.Enabled, self.Visible, self._destroyed = true, true, false
		self.Cleanup:Add(function()
			self._destroyed = true
			if self._entry then
				self._entry.Remove()
				self._entry = nil
			end
			if self.Id and self.Window.Options[self.Id] == self then
				self.Window.Options[self.Id] = nil
			end
		end)
		ctx.Pending = self
		return self
	end

	function Component.New(ctx, class, kind, id, config, opts)
		opts = opts or {}
		local self = Component.NewBare(ctx, class, kind, id, config)
		local cleanup = self.Cleanup
		local flat = opts.Flat == true

		local frame, stroke = Widgets.Surface(cleanup, {
			Name = kind,
			Parent = ctx.Parent,
			Fill = (not flat) and "SecondaryBackground" or nil,
			Transparency = (not flat) and "ComponentTransparency" or nil,
			Stroke = (not flat) and "Text" or nil,
			Radius = 16,
			Size = UDim2.new(1, 0, 0, opts.MinHeight or 48),
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = ctx.Order(),
		})
		cleanup:Add(frame)
		self.Frame, self.Stroke = frame, stroke
		if stroke then
			Theme.BindFn(function()
				stroke.Transparency = Theme.Get("ComponentStrokeTransparency")
			end, cleanup)
		end

		local rightWidth = opts.RightWidth or 0
		local left = Utility.Create("Frame", {
			Name = "Left",
			BackgroundTransparency = 1,
			AutomaticSize = Enum.AutomaticSize.Y,
			Size = UDim2.new(1, rightWidth > 0 and -(rightWidth + 12) or 0, 0, 0),
			Parent = frame,
		})
		Utility.Create("UIPadding", { PaddingRight = UDim.new(0, 14), PaddingLeft = UDim.new(0, 16), PaddingTop = UDim.new(0, 15), PaddingBottom = UDim.new(0, 15), Parent = left })
		Widgets.List(left, 12, { FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center })

		self._iconHolder = Utility.Create("Frame", {
			Name = "IconHolder",
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(16, 16),
			LayoutOrder = 1,
			Visible = false,
			Parent = left,
		})
		self._textCol = Utility.Create("Frame", {
			Name = "TextColumn",
			BackgroundTransparency = 1,
			AutomaticSize = Enum.AutomaticSize.Y,
			Size = UDim2.new(1, 0, 0, 0),
			LayoutOrder = 2,
			Parent = left,
		})
		Widgets.List(self._textCol, 4)

		local title = config.Title or config.Text or ""
		local description = config.Description or config.Content or ""
		self.TitleLabel = Widgets.Text(cleanup, {
			Name = "Title",
			Parent = self._textCol,
			Text = title,
			Bold = true,
			TextWrapped = true,
			AutomaticSize = Enum.AutomaticSize.Y,
			Size = UDim2.new(1, 0, 0, 0),
			LayoutOrder = 1,
			Visible = title ~= "",
		})
		self.DescriptionLabel = Widgets.Text(cleanup, {
			Name = "Description",
			Parent = self._textCol,
			Text = description,
			Color = "MutedText",
			TextSize = 12,
			TextWrapped = true,
			RichText = config.RichText == true,
			AutomaticSize = Enum.AutomaticSize.Y,
			Size = UDim2.new(1, 0, 0, 0),
			LayoutOrder = 2,
			Visible = description ~= "",
		})

		if rightWidth > 0 then
			self.Right = Utility.Create("Frame", {
				Name = "Right",
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -12, 0.5, 0),
				Size = UDim2.fromOffset(rightWidth, opts.RightHeight or 26),
				Parent = frame,
			})
		end

		self:SetIcon(config.Icon)

		if not opts.NoSearch and (title ~= "" or description ~= "") then
			self._entry = ctx.Window:_IndexAdd({
				Kind = kind,
				Title = title,
				Description = description,
				Tab = ctx.Tab,
				Section = ctx.Section,
				Frame = frame,
				Component = self,
			})
		end
		if config.Tooltip then
			self:SetTooltip(config.Tooltip)
		end
		if config.Visible == false then
			self:SetVisible(false)
		end
		if config.Enabled == false or config.Disabled == true then
			self:SetEnabled(false)
		end
		return self
	end

	function Component.BindValue(self, id, default, render)
		local state
		if id then
			state = Config:Register(id, default)
		else
			state = State.new(default)
			self.Cleanup:Add(state)
		end
		local valid, value = self:_Normalize(state:Get())
		if not valid then
			value = default
		end
		if value ~= state:Get() or type(value) == "table" then
			state:Set(value, true)
		end
		self.State = state
		self.Cleanup:Add(state.Changed:Connect(function(newValue)
			if self._destroyed then
				return
			end
			render(newValue, true)
			self:_Emit(newValue)
		end))
		Theme.BindFn(function()
			render(state:Get(), false)
		end, self.Cleanup)
	end

	function Base:_Normalize(value)
		return true, value
	end

	function Base:_Emit(value)
		if self._destroyed then
			return
		end
		Utility.SafeCall(self.Kind .. " " .. tostring(self.Id or self.Config.Title or "?"), self.Config.Callback, value)
		self.Changed:Fire(value)
	end

	function Base:GetValue()
		return self.State and self.State:Get()
	end

	function Base:SetValue(value)
		if not self.State then
			Utility.Warn(self.Kind .. " does not hold a value.")
			return
		end
		local valid, normalized = self:_Normalize(value)
		if not valid then
			Utility.Warn(string.format('Invalid value for %s "%s".', self.Kind, tostring(self.Id)))
			return
		end
		self.State:Set(normalized)
	end

	function Base:OnChanged(callback)
		return self.Changed:Connect(callback)
	end

	function Base:SetTitle(text)
		text = text or ""
		self.TitleLabel.Text = text
		self.TitleLabel.Visible = text ~= ""
		if self._entry then
			self._entry.Title = text
		end
	end

	function Base:SetDescription(text)
		text = text or ""
		self.DescriptionLabel.Text = text
		self.DescriptionLabel.Visible = text ~= ""
		if self._entry then
			self._entry.Description = text
		end
	end

	function Base:SetIcon(spec)
		local holder = self._iconHolder
		if not holder then
			return
		end
		if spec == nil then
			if self._icon then
				self._icon:Set(nil)
			end
			holder.Visible = false
			self._textCol.Size = UDim2.new(1, 0, 0, 0)
			return
		end
		if self._icon then
			self._icon:Set(spec)
		else
			self._icon = Icons.Create(holder, spec, { Size = 16, Color = "MutedText", Cleanup = self.Cleanup })
		end
		holder.Visible = true
		self._textCol.Size = UDim2.new(1, -24, 0, 0)
	end

	function Base:SetVisible(visible)
		self.Visible = visible
		if self.Frame then
			self.Frame.Visible = visible
		end
	end

	function Base:SetEnabled(enabled)
		self.Enabled = enabled
		if not self.Frame then
			return
		end
		if enabled then
			if self._blocker then
				self._blocker:Destroy()
				self._blocker = nil
			end
		elseif not self._blocker then
			self._blocker = Widgets.Surface(self.Cleanup, {
				Name = "DisabledOverlay",
				Parent = self.Frame,
				Fill = "Background",
				BackgroundTransparency = 0.45,
				Radius = 16,
				Active = true,
				ZIndex = 10,
				Size = UDim2.fromScale(1, 1),
			})
		end
	end

	function Base:SetTooltip(text)
		if not self.Frame then
			return
		end
		if self._tooltip then
			self._tooltip.Text = text
		else
			self._tooltip = Tooltip.Attach(self.Frame, text, self.Cleanup)
		end
	end

	function Base:Destroy()
		if self._destroyed then
			return
		end
		if self.Frame then
			Animation:CancelTree(self.Frame)
		end
		self.Cleanup:Clean()
	end

	function Component.Add(owner, name, first, second)
		local factory = Component.Registry[name]
		local id, config
		if type(first) == "string" then
			id, config = first, second
		else
			config = first
		end
		config = config or {}
		if type(config) ~= "table" then
			Utility.Fail(name, id, "Config must be a table.")
		end
		if id ~= nil and owner.Window.Options[id] then
			Utility.Fail(name, id, "Duplicate id: an option with this id already exists in this window.")
		end
		local ctx = {
			Parent = owner.Container,
			Window = owner.Window,
			Tab = owner.TabRef,
			Section = owner.SectionRef,
			Cleanup = owner.Cleanup,
			Order = owner.NextOrder,
		}
		local ok, result = pcall(factory, ctx, id, config)
		if not ok then
			if ctx.Pending then
				pcall(function()
					ctx.Pending:Destroy()
				end)
			end
			local message = tostring(result)
			if string.sub(message, 1, 6) == "[ZETA]" then
				error(message, 0)
			end
			Utility.Fail(name, id, message)
		end
		if id ~= nil then
			owner.Window.Options[id] = result
		end
		return result
	end

	function Component.MakeContainer(class)
		class.__index = function(object, key)
			local method = rawget(class, key)
			if method ~= nil then
				return method
			end
			local name = type(key) == "string" and string.match(key, "^Add(%u%w*)$")
			if name and Component.Registry[name] then
				return function(self, first, second)
					return Component.Add(self, name, first, second)
				end
			end
			return nil
		end
	end

	return Component
end
