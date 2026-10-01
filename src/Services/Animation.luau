return function(import)
	local TweenService = game:GetService("TweenService")

	local Animation = {
		Enabled = true,
		Duration = { Fast = 0.12, Normal = 0.2, Slow = 0.3 },
	}

	local active = setmetatable({}, { __mode = "k" })

	-- opts: Duration, Style, Direction, Delay, OnComplete
	function Animation:Play(object, props, opts)
		opts = opts or {}
		if not Animation.Enabled then
			for property, value in props do
				object[property] = value
			end
			if opts.OnComplete then
				task.defer(opts.OnComplete)
			end
			return nil
		end

		local list = active[object]
		if not list then
			list = {}
			active[object] = list
		end
		for index = #list, 1, -1 do
			local entry = list[index]
			for property in props do
				if entry.props[property] then
					entry.tween:Cancel()
					table.remove(list, index)
					break
				end
			end
		end

		local info = TweenInfo.new(
			opts.Duration or Animation.Duration.Normal,
			opts.Style or Enum.EasingStyle.Quad,
			opts.Direction or Enum.EasingDirection.Out,
			0,
			false,
			opts.Delay or 0
		)
		local tween = TweenService:Create(object, info, props)
		local entry = { tween = tween, props = props }
		table.insert(list, entry)
		tween.Completed:Once(function(state)
			local position = table.find(list, entry)
			if position then
				table.remove(list, position)
			end
			if opts.OnComplete and state == Enum.PlaybackState.Completed then
				opts.OnComplete()
			end
		end)
		tween:Play()
		return tween
	end

	function Animation:Tween(object, props, duration, style, direction)
		return Animation:Play(object, props, { Duration = duration, Style = style, Direction = direction })
	end

	function Animation:Cancel(object)
		local list = active[object]
		if list then
			for _, entry in list do
				entry.tween:Cancel()
			end
			table.clear(list)
		end
	end

	function Animation:CancelTree(root)
		if not root then
			return
		end
		Animation:Cancel(root)
		for _, descendant in root:GetDescendants() do
			Animation:Cancel(descendant)
		end
	end

	return Animation
end
