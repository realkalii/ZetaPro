return function(import)
	local Utility = import("Core/Utility")
	local Widgets = import("Core/Widgets")
	local Theme = import("Core/Theme")
	local Cleanup = import("Services/Cleanup")
	local Toast = import("Components/Notification")

	local Notification = { Max = 5 }

	local root, gui, holder
	local active = {}
	local counter = 0

	local function ensure()
		if gui and gui.Parent then
			return
		end
		root = Cleanup.new()
		gui = root:Add(Utility.NewScreenGui("ZetaPro_Notifications", 1500))
		holder = Utility.Create("Frame", {
			Name = "Holder",
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.new(1, -6, 1, -6),
			Size = UDim2.fromOffset(300, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Parent = gui,
		})
		Widgets.List(holder, 6, { VerticalAlignment = Enum.VerticalAlignment.Bottom })
		local scale = Instance.new("UIScale")
		scale.Parent = holder
		Theme.BindScale(scale, root)
		local function reflow()
			holder.Size = UDim2.new(0, math.max(180, math.min(300, gui.AbsoluteSize.X - 12)), 0, 0)
		end
		root:Add(gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(reflow))
		reflow()
	end

	function Notification.Notify(config)
		Utility.Check(type(config) == "table", "Notification", "?", "Config must be a table.")
		ensure()
		counter += 1
		local toast = Toast.new(holder, config, counter, function(closed)
			local index = table.find(active, closed)
			if index then
				table.remove(active, index)
			end
		end)
		table.insert(active, toast)
		local viewportMax = math.max(2, math.min(Notification.Max, math.floor((gui.AbsoluteSize.Y - 20) / 80)))
		while #active > viewportMax do
			active[1]:Close()
		end
		return toast
	end

	function Notification.Count()
		return #active
	end

	function Notification.Reset()
		for _, toast in table.clone(active) do
			toast:Destroy()
		end
		table.clear(active)
		if root then
			root:Clean()
		end
		root, gui, holder = nil, nil, nil
	end

	return Notification
end
