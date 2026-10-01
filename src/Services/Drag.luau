return function(import)
	local Input = import("Services/Input")

	local Drag = {}

	local function isPointer(input)
		return input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch
	end

	local function isMove(input, origin)
		return input.UserInputType == Enum.UserInputType.MouseMovement or input == origin
	end

	-- Calls onMove(position) on press and on every move until release.
	-- Move listeners exist only while the pointer is held down.
	function Drag.Track(handle, cleanup, onMove, onEnd)
		local stopCurrent
		cleanup:Add(function()
			if stopCurrent then
				stopCurrent()
			end
		end)
		cleanup:Add(handle.InputBegan:Connect(function(input)
			if not isPointer(input) then
				return
			end
			if stopCurrent then
				stopCurrent()
			end
			local running = true
			local moveConnection, endConnection
			local function stop()
				if not running then
					return
				end
				running = false
				stopCurrent = nil
				moveConnection:Disconnect()
				endConnection:Disconnect()
				if onEnd then
					onEnd()
				end
			end
			stopCurrent = stop
			onMove(Vector2.new(input.Position.X, input.Position.Y))
			moveConnection = Input.Changed:Connect(function(changed)
				if running and isMove(changed, input) then
					onMove(Vector2.new(changed.Position.X, changed.Position.Y))
				end
			end)
			endConnection = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					stop()
				end
			end)
		end))
	end

	-- Moves `target` while dragging `handle`. Position is clamped so the
	-- anchor point always stays inside the parent.
	function Drag.Attach(handle, target, cleanup, opts)
		opts = opts or {}
		local margin = opts.Margin or 24
		local startPosition, startPointer
		cleanup:Add(handle.InputBegan:Connect(function(input)
			if isPointer(input) then
				startPosition = target.Position
				startPointer = Vector2.new(input.Position.X, input.Position.Y)
			end
		end))
		Drag.Track(handle, cleanup, function(position)
			if not startPosition or not startPointer then
				return
			end
			local delta = position - startPointer
			local x = startPosition.X.Offset + delta.X
			local y = startPosition.Y.Offset + delta.Y
			local parent = target.Parent
			if parent and parent:IsA("GuiBase2d") then
				local size = parent.AbsoluteSize
				local px = math.clamp(startPosition.X.Scale * size.X + x, margin, size.X - margin)
				local py = math.clamp(startPosition.Y.Scale * size.Y + y, margin, size.Y - margin)
				x = px - startPosition.X.Scale * size.X
				y = py - startPosition.Y.Scale * size.Y
			end
			target.Position = UDim2.new(startPosition.X.Scale, x, startPosition.Y.Scale, y)
		end)
	end

	-- Resizes `target` (offset-sized) from a grip handle.
	-- opts: Min, Max (Vector2), GetScale (function), OnResize (function)
	function Drag.Resize(handle, target, cleanup, opts)
		opts = opts or {}
		local minSize = opts.Min or Vector2.new(300, 200)
		local maxSize = opts.Max or Vector2.new(2000, 2000)
		local startSize, startPosition, startPointer
		cleanup:Add(handle.InputBegan:Connect(function(input)
			if isPointer(input) then
				startSize = target.Size
				startPosition = target.Position
				startPointer = Vector2.new(input.Position.X, input.Position.Y)
			end
		end))
		Drag.Track(handle, cleanup, function(position)
			if not startSize or not startPointer then
				return
			end
			local scale = opts.GetScale and opts.GetScale() or 1
			local delta = position - startPointer
			local width = math.clamp(startSize.X.Offset + delta.X / scale, minSize.X, maxSize.X)
			local height = math.clamp(startSize.Y.Offset + delta.Y / scale, minSize.Y, maxSize.Y)
			local appliedX = (width - startSize.X.Offset) * scale
			local appliedY = (height - startSize.Y.Offset) * scale
			target.Size = UDim2.fromOffset(width, height)
			target.Position = UDim2.new(
				startPosition.X.Scale,
				startPosition.X.Offset + appliedX * target.AnchorPoint.X,
				startPosition.Y.Scale,
				startPosition.Y.Offset + appliedY * target.AnchorPoint.Y
			)
			if opts.OnResize then
				opts.OnResize()
			end
		end)
	end

	return Drag
end
