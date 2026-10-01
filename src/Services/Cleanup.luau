return function(import)
	local Cleanup = {}
	Cleanup.__index = Cleanup

	local function dispose(item)
		local kind = typeof(item)
		if kind == "function" then
			item()
		elseif kind == "RBXScriptConnection" then
			item:Disconnect()
		elseif kind == "Instance" then
			if item:IsA("TweenBase") then
				item:Cancel()
			end
			item:Destroy()
		elseif kind == "thread" then
			pcall(task.cancel, item)
		elseif kind == "table" then
			if type(item.Destroy) == "function" then
				item:Destroy()
			elseif type(item.Disconnect) == "function" then
				item:Disconnect()
			elseif type(item.Clean) == "function" then
				item:Clean()
			end
		end
	end

	function Cleanup.new(parent)
		return setmetatable({ _items = {}, _cleaned = false, _parent = parent }, Cleanup)
	end

	function Cleanup:Add(item)
		if self._cleaned then
			pcall(dispose, item)
			return item
		end
		table.insert(self._items, item)
		return item
	end

	-- Child scope: cleaned with its parent, or earlier on its own.
	function Cleanup:Extend()
		local child = Cleanup.new(self)
		if self._cleaned then
			child._cleaned = true
		else
			table.insert(self._items, child)
		end
		return child
	end

	function Cleanup:IsCleaned()
		return self._cleaned
	end

	function Cleanup:Clean()
		if self._cleaned then
			return
		end
		self._cleaned = true
		local items = self._items
		self._items = {}
		for index = #items, 1, -1 do
			local ok, err = pcall(dispose, items[index])
			if not ok then
				warn("[ZETA][WARN] Cleanup error: " .. tostring(err))
			end
		end
		local parent = self._parent
		if parent and not parent._cleaned then
			local position = table.find(parent._items, self)
			if position then
				table.remove(parent._items, position)
			end
		end
	end
	Cleanup.Destroy = Cleanup.Clean

	return Cleanup
end
