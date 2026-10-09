return function(import)
	local Capabilities = import("Core/Capabilities")
	local Catalog = import("Icons/Catalog")

	local Providers = {}

	local memory = {}
	local MAX_BYTES = 262144

	local function hash(text)
		local value = 5381
		for index = 1, #text do
			value = (value * 33 + string.byte(text, index)) % 4294967296
		end
		return string.format("%08x", value)
	end

	function Providers.LoadUrl(url, callback)
		if type(url) ~= "string" or string.sub(url, 1, 8) ~= "https://" then
			callback(nil)
			return
		end
		if memory[url] then
			callback(memory[url])
			return
		end
		if not (Capabilities.Http and Capabilities.FileSystem and Capabilities.GetCustomAsset) then
			callback(nil)
			return
		end
		task.spawn(function()
			local path = "ZetaPro/icons/" .. hash(url) .. ".png"
			local fs = Capabilities.FS
			local ok, asset = pcall(function()
				for _, folder in { "ZetaPro", "ZetaPro/icons" } do
					if not fs.IsFolder(folder) then
						fs.MakeFolder(folder)
					end
				end
				if not fs.IsFile(path) then
					local success, body = Capabilities.HttpGet(url)
					if not success or type(body) ~= "string" or #body > MAX_BYTES or string.sub(body, 2, 4) ~= "PNG" then
						error("invalid icon")
					end
					fs.Write(path, body)
				end
				return Capabilities.GetCustomAsset(path)
			end)
			if ok and asset then
				memory[url] = asset
				callback(asset)
			else
				callback(nil)
			end
		end)
	end

	local names

	Providers.Builtin = {
		Resolve = function(name)
			if type(name) ~= "string" then
				return nil
			end
			local id = Catalog[string.lower(name)]
			if not id then
				return nil
			end
			return { Type = "Image", Source = "rbxassetid://" .. id, Tint = true, Name = name }
		end,
		Names = function()
			if not names then
				names = {}
				for key in Catalog do
					table.insert(names, key)
				end
				table.sort(names)
			end
			return table.clone(names)
		end,
	}

	-- A built-in image shown if a remote PNG cannot be loaded.
	Providers.Fallback = Providers.Builtin.Resolve("circle-help")

	return Providers
end
