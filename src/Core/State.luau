return function(import)
	local Signal = import("Core/Signal")

	local State = {}
	State.__index = State

	function State.new(value)
		return setmetatable({ _value = value, Changed = Signal.new() }, State)
	end

	function State:Get()
		return self._value
	end

	-- Tables always notify (they are treated as new values).
	function State:Set(value, silent)
		if self._value == value and type(value) ~= "table" then
			return
		end
		self._value = value
		if not silent then
			self.Changed:Fire(value)
		end
	end

	function State:OnChanged(callback)
		return self.Changed:Connect(callback)
	end

	function State:Destroy()
		self.Changed:Destroy()
	end

	return State
end
