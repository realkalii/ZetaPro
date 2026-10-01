return function(import)
	local HttpService = game:GetService("HttpService")
	local State = import("Core/State")
	local Signal = import("Core/Signal")
	local Utility = import("Core/Utility")
	local Capabilities = import("Core/Capabilities")

	-- Application state. UI components bind to these states by id, so values
	-- survive UI destruction and can be exported/imported independently.
	local Config = {
		Folder = "ZetaPro/configs",
		Changed = Signal.new(),
		_states = {},
		_defaults = {},
		_connections = {},
	}

	function Config:Register(key, default)
		local state = self._states[key]
		if not state then
			state = State.new(default)
			self._states[key] = state
			self._connections[key] = state.Changed:Connect(function(value)
				self.Changed:Fire(key, value)
			end)
		end
		if self._defaults[key] == nil then
			self._defaults[key] = Utility.DeepCopy(default)
		end
		return state
	end

	function Config:Set(key, value)
		assert(type(key) == "string", "[ZETA] Config key must be a string")
		local state = self._states[key]
		if not state then
			state = self:Register(key, nil)
		end
		state:Set(value)
	end

	function Config:Get(key)
		local state = self._states[key]
		return state and state:Get()
	end

	function Config:Has(key)
		return self._states[key] ~= nil
	end

	function Config:Export()
		local out = {}
		for key, state in self._states do
			out[key] = Utility.DeepCopy(state:Get())
		end
		return out
	end

	function Config:Import(data)
		assert(type(data) == "table", "[ZETA] Config:Import expects a table")
		for key, value in data do
			self:Set(key, Utility.DeepCopy(value))
		end
	end

	function Config:Reset()
		for key, state in self._states do
			state:Set(Utility.DeepCopy(self._defaults[key]))
		end
	end

	function Config:Wipe()
		for _, connection in self._connections do
			connection:Disconnect()
		end
		table.clear(self._connections)
		for _, state in self._states do
			state:Destroy()
		end
		table.clear(self._states)
		table.clear(self._defaults)
	end

	local function encode(value)
		local kind = typeof(value)
		if kind == "Color3" then
			return { __t = "Color3", R = value.R, G = value.G, B = value.B }
		elseif kind == "EnumItem" then
			return { __t = "Enum", Type = tostring(value.EnumType), Name = value.Name }
		elseif kind == "table" then
			local out = {}
			for k, v in value do
				out[k] = encode(v)
			end
			return out
		end
		return value
	end

	local function decode(value)
		if type(value) ~= "table" then
			return value
		end
		if value.__t == "Color3" then
			return Color3.new(value.R, value.G, value.B)
		elseif value.__t == "Enum" then
			local ok, item = pcall(function()
				return Enum[value.Type][value.Name]
			end)
			return ok and item or nil
		end
		local out = {}
		for k, v in value do
			out[k] = decode(v)
		end
		return out
	end

	function Config:Serialize()
		return HttpService:JSONEncode(encode(self:Export()))
	end

	function Config:Deserialize(json)
		local ok, data = pcall(function()
			return decode(HttpService:JSONDecode(json))
		end)
		if not ok then
			return false, "invalid JSON"
		end
		self:Import(data)
		return true
	end

	local function ensureFolder(path)
		local fs = Capabilities.FS
		local built = ""
		for part in string.gmatch(path, "[^/]+") do
			built = built == "" and part or (built .. "/" .. part)
			if not fs.IsFolder(built) then
				fs.MakeFolder(built)
			end
		end
	end

	function Config:Save(name)
		if not Capabilities.FileSystem then
			return false, "FileSystem capability unavailable"
		end
		local ok, err = pcall(function()
			ensureFolder(self.Folder)
			Capabilities.FS.Write(self.Folder .. "/" .. name .. ".json", self:Serialize())
		end)
		return ok, not ok and tostring(err) or nil
	end

	function Config:Load(name)
		if not Capabilities.FileSystem then
			return false, "FileSystem capability unavailable"
		end
		local path = self.Folder .. "/" .. name .. ".json"
		if not Capabilities.FS.IsFile(path) then
			return false, "file not found"
		end
		local ok, content = pcall(Capabilities.FS.Read, path)
		if not ok then
			return false, tostring(content)
		end
		return self:Deserialize(content)
	end

	return Config
end
