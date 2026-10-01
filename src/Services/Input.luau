return function(import)
	local UserInputService = game:GetService("UserInputService")
	local GuiService = game:GetService("GuiService")
	local Signal = import("Core/Signal")
	local Utility = import("Core/Utility")

	-- Single, shared input pipeline. Components never create their own
	-- UserInputService connections for keybinds, drag or pointer tracking.
	local Input = {
		Began = Signal.new(),
		Changed = Signal.new(),
		Ended = Signal.new(),
		Capturing = false,
	}

	local binds = {}
	local connections = {}
	local pointer

	local function matches(key, input)
		if typeof(key) ~= "EnumItem" then
			return false
		end
		if key.EnumType == Enum.KeyCode then
			return key ~= Enum.KeyCode.Unknown and input.KeyCode == key
		end
		return input.UserInputType == key
	end

	function Input.Init()
		if #connections > 0 then
			return
		end
		table.insert(
			connections,
			UserInputService.InputBegan:Connect(function(input, processed)
				Input.Began:Fire(input, processed)
				if processed or Input.Capturing then
					return
				end
				for _, bind in table.clone(binds) do
					if bind.Enabled and matches(bind.Key, input) then
						task.spawn(Utility.SafeCall, "Keybind " .. bind.Label, bind.Callback, bind.Key)
					end
				end
			end)
		)
		table.insert(
			connections,
			UserInputService.InputChanged:Connect(function(input, processed)
				local kind = input.UserInputType
				if kind == Enum.UserInputType.MouseMovement or kind == Enum.UserInputType.Touch then
					pointer = Vector2.new(input.Position.X, input.Position.Y)
				end
				Input.Changed:Fire(input, processed)
			end)
		)
		table.insert(
			connections,
			UserInputService.InputEnded:Connect(function(input, processed)
				Input.Ended:Fire(input, processed)
			end)
		)
	end

	-- Pointer position in GUI space (same space as AbsolutePosition).
	function Input.GetPointer()
		if pointer then
			return pointer
		end
		return UserInputService:GetMouseLocation() - GuiService:GetGuiInset()
	end

	function Input.AddBind(key, callback, label)
		Input.Init()
		local bind = { Key = key, Callback = callback, Label = label or "Keybind", Enabled = true }
		function bind:SetKey(newKey)
			self.Key = newKey
		end
		function bind:Destroy()
			local index = table.find(binds, self)
			if index then
				table.remove(binds, index)
			end
		end
		table.insert(binds, bind)
		return bind
	end

	function Input.FindConflict(key, ignore)
		if typeof(key) ~= "EnumItem" or key == Enum.KeyCode.Unknown then
			return nil
		end
		for _, bind in binds do
			if bind ~= ignore and bind.Key == key then
				return bind
			end
		end
		return nil
	end

	function Input.BindCount()
		return #binds
	end

	-- Waits for the next key / mouse button. callback(key, cancelled).
	-- Escape cancels, Backspace clears, left click / touch cancels.
	function Input.Capture(callback)
		Input.Init()
		Input.Capturing = true
		local finished = false
		local connection

		local function finish(key, cancelled)
			if finished then
				return
			end
			finished = true
			if connection then
				connection:Disconnect()
			end
			task.defer(function()
				Input.Capturing = false
			end)
			callback(key, cancelled)
		end

		task.defer(function()
			if finished then
				return
			end
			connection = UserInputService.InputBegan:Connect(function(input)
				local kind = input.UserInputType
				if kind == Enum.UserInputType.Keyboard then
					if input.KeyCode == Enum.KeyCode.Escape then
						finish(nil, true)
					elseif input.KeyCode == Enum.KeyCode.Backspace then
						finish(Enum.KeyCode.Unknown, false)
					else
						finish(input.KeyCode, false)
					end
				elseif kind == Enum.UserInputType.MouseButton2 or kind == Enum.UserInputType.MouseButton3 then
					finish(kind, false)
				elseif kind == Enum.UserInputType.MouseButton1 or kind == Enum.UserInputType.Touch then
					finish(nil, true)
				end
			end)
		end)

		return function()
			finish(nil, true)
		end
	end

	function Input.Reset()
		for _, connection in connections do
			connection:Disconnect()
		end
		table.clear(connections)
		table.clear(binds)
		Input.Capturing = false
		pointer = nil
	end

	return Input
end
