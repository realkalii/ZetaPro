return function(import)
	local Signal = {}
	Signal.__index = Signal

	local Connection = {}
	Connection.__index = Connection

	function Connection:Disconnect()
		if not self.Connected then
			return
		end
		self.Connected = false
		local handlers = self._signal._handlers
		local index = table.find(handlers, self)
		if index then
			table.remove(handlers, index)
		end
	end
	Connection.Destroy = Connection.Disconnect

	function Signal.new()
		return setmetatable({ _handlers = {}, _destroyed = false }, Signal)
	end

	function Signal:Connect(callback)
		assert(type(callback) == "function", "[ZETA] Signal:Connect expects a function")
		local connection = setmetatable({
			Connected = not self._destroyed,
			_callback = callback,
			_signal = self,
		}, Connection)
		if not self._destroyed then
			table.insert(self._handlers, connection)
		end
		return connection
	end

	function Signal:Once(callback)
		local connection
		connection = self:Connect(function(...)
			connection:Disconnect()
			callback(...)
		end)
		return connection
	end

	function Signal:Fire(...)
		if self._destroyed then
			return
		end
		for _, connection in table.clone(self._handlers) do
			if connection.Connected then
				task.spawn(connection._callback, ...)
			end
		end
	end

	function Signal:Destroy()
		self._destroyed = true
		for _, connection in self._handlers do
			connection.Connected = false
		end
		table.clear(self._handlers)
	end

	return Signal
end
