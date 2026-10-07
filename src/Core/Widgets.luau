return function(import)
	local Theme = import("Core/Theme")
	local Utility = import("Core/Utility")
	local Animation = import("Services/Animation")

	-- Small themed building blocks shared by every component.
	local Widgets = {}

	local TEXT_KEYS = { Color = true, Bold = true, Class = true }
	local SURFACE_KEYS = { Fill = true, Stroke = true, Radius = true, Class = true }

	local function without(props, keys)
		local out = {}
		for key, value in props do
			if not keys[key] then
				out[key] = value
			end
		end
		return out
	end

	-- props: Color (theme token), Bold, Class, plus any property of the class.
	function Widgets.Text(cleanup, props)
		props = props or {}
		local class = props.Class or "TextLabel"
		local raw = without(props, TEXT_KEYS)
		raw.BackgroundTransparency = 1
		raw.TextSize = raw.TextSize or 13
		raw.TextXAlignment = raw.TextXAlignment or Enum.TextXAlignment.Left
		if raw.Text == nil then
			raw.Text = ""
		end
		local label = Utility.Create(class, raw)
		local colorToken = props.Color or "Text"
		Theme.BindFn(function()
			label.TextColor3 = Theme.Get(colorToken)
			label.FontFace = props.Bold and Theme.FontBold or Theme.Font
			if class == "TextBox" then
				label.PlaceholderColor3 = Theme.Get("MutedText")
			end
		end, cleanup)
		return label
	end

	-- props: Fill, Stroke (theme tokens), Radius (number | "Full"), Class.
	function Widgets.Surface(cleanup, props)
		local raw = without(props, SURFACE_KEYS)
		local fill, strokeToken, radius = props.Fill, props.Stroke, props.Radius
		if radius == nil then
			radius = 10
		end
		if fill == nil and raw.BackgroundTransparency == nil then
			raw.BackgroundTransparency = 1
		end
		local instance = Utility.Create(props.Class or "Frame", raw)
		if radius ~= 0 then
			Utility.Create("UICorner", {
				CornerRadius = radius == "Full" and UDim.new(1, 0) or UDim.new(0, radius),
				Parent = instance,
			})
		end
		local stroke
		if strokeToken then
			stroke = Utility.Create("UIStroke", {
				Thickness = 1,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Parent = instance,
			})
		end
		Theme.BindFn(function()
			if fill then
				instance.BackgroundColor3 = Theme.Get(fill)
			end
			if stroke then
				stroke.Color = Theme.Get(strokeToken)
			end
		end, cleanup)
		return instance, stroke
	end

	-- Hover / pressed feedback. opts: Base, Hover, Pressed (tokens),
	-- Alpha = { base, hover, pressed } background transparencies.
	function Widgets.Interactive(cleanup, target, trigger, opts)
		opts = opts or {}
		local base = opts.Base or "SecondaryBackground"
		local hoverToken = opts.Hover or "Hover"
		local pressedToken = opts.Pressed or "Pressed"
		local hover, down, enabled = false, false, true
		local handle = {}

		local function apply(instant)
			local color = Theme.Get(base)
			local alpha = opts.Alpha and opts.Alpha[1]
			if enabled and down then
				color = Theme.Get(pressedToken)
				alpha = opts.Alpha and opts.Alpha[3]
			elseif enabled and hover then
				color = Theme.Get(hoverToken)
				alpha = opts.Alpha and opts.Alpha[2]
			end
			local goal = { BackgroundColor3 = color }
			if alpha then
				goal.BackgroundTransparency = alpha
			end
			if instant then
				for property, value in goal do
					target[property] = value
				end
			else
				Animation:Play(target, goal, { Duration = Animation.Duration.Fast })
			end
		end

		local function isPress(input)
			return input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch
		end

		cleanup:Add(trigger.MouseEnter:Connect(function()
			hover = true
			apply()
		end))
		cleanup:Add(trigger.MouseLeave:Connect(function()
			hover = false
			down = false
			apply()
		end))
		cleanup:Add(trigger.InputBegan:Connect(function(input)
			if isPress(input) then
				down = true
				apply()
			end
		end))
		cleanup:Add(trigger.InputEnded:Connect(function(input)
			if isPress(input) then
				down = false
				if input.UserInputType == Enum.UserInputType.Touch then
					hover = false
				end
				apply()
			end
		end))
		Theme.BindFn(function()
			apply(true)
		end, cleanup)

		function handle.SetEnabled(value)
			enabled = value
			if not value then
				hover, down = false, false
			end
			apply()
		end
		handle.Refresh = apply
		return handle
	end

	function Widgets.Padding(parent, left, top, right, bottom)
		top = top or left
		return Utility.Create("UIPadding", {
			PaddingLeft = UDim.new(0, left),
			PaddingTop = UDim.new(0, top),
			PaddingRight = UDim.new(0, right or left),
			PaddingBottom = UDim.new(0, bottom or top),
			Parent = parent,
		})
	end

	function Widgets.List(parent, gap, extra)
		local props = {
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, gap or 0),
			Parent = parent,
		}
		for key, value in extra or {} do
			props[key] = value
		end
		return Utility.Create("UIListLayout", props)
	end

	return Widgets
end
