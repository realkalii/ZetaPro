return function(import)
	local Capabilities = import("Core/Capabilities")
	local Signal = import("Core/Signal")
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

	local REMOTE_BASE = "https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/"
	local REMOTE = { lucide = true, solar = true, geist = true, craft = true, sfsymbols = true }
	local VARIANTS = { "linear", "outline", "stroke", "bold", "broken", "line-duotone", "bold-duotone" }
	local CACHE_FOLDER = "ZetaPro/icons"
	local MAX_CATALOG = 16777216
	local compile = loadstring

	Providers.CatalogReady = Signal.new()
	local catalogs = {}
	local states = {}

	local function assetId(value)
		if type(value) == "number" then
			return "rbxassetid://" .. tostring(value)
		end
		if type(value) == "string" and string.sub(value, 1, 13) == "rbxassetid://" then
			return value
		end
		return nil
	end

	local function entry(catalog, name)
		local store = type(catalog.Icons) == "table" and catalog.Icons or catalog
		local value = store[name]
		if value == nil then
			return nil
		end
		local direct = assetId(value)
		if direct then
			return { Type = "Image", Source = direct, Tint = true }
		end
		if type(value) ~= "table" then
			return nil
		end
		local sheets = catalog.Spritesheets
		local source = assetId(sheets and sheets[tostring(value.Image)] or value.Image)
		if not source then
			return nil
		end
		local spec = { Type = "Image", Source = source, Tint = true }
		local offset, size = value.ImageRectPosition, value.ImageRectSize
		if typeof(offset) == "Vector2" and typeof(size) == "Vector2" and size.X > 0 and size.Y > 0 then
			spec.RectOffset, spec.RectSize = offset, size
		end
		return spec, value.Parts
	end

	local function build(catalog, name, exact)
		local keys = { name }
		local lower = string.lower(name)
		if lower ~= name then
			table.insert(keys, lower)
		end
		local spec, parts
		for _, key in ipairs(keys) do
			spec, parts = entry(catalog, key)
			if spec then
				break
			end
		end
		if not spec and not exact then
			for _, variant in ipairs(VARIANTS) do
				for _, key in ipairs(keys) do
					spec, parts = entry(catalog, key .. "-" .. variant)
					if spec then
						break
					end
				end
				if spec then
					break
				end
			end
		end
		if spec and type(parts) == "table" then
			local layers = {}
			for _, part in ipairs(parts) do
				if type(part) == "string" then
					local layer = entry(catalog, part)
					if layer then
						table.insert(layers, layer)
					end
				end
			end
			if #layers > 0 then
				spec.Layers = layers
			end
		end
		return spec
	end

	local function install(family, source)
		if type(compile) ~= "function" or type(source) ~= "string" then
			return false
		end
		local ok, catalog = pcall(function()
			local chunk = compile(source)
			return chunk and chunk()
		end)
		if ok and type(catalog) == "table" then
			catalogs[family] = catalog
			return true
		end
		return false
	end

	local function request(family)
		if states[family] then
			return
		end
		if type(compile) ~= "function" or not (Capabilities.Http or Capabilities.FileSystem) then
			states[family] = "failed"
			return
		end
		local fs = Capabilities.FS
		local path = CACHE_FOLDER .. "/" .. family .. ".lua"
		if Capabilities.FileSystem then
			local ok, cached = pcall(function()
				return fs.IsFile(path) and install(family, fs.Read(path))
			end)
			if ok and cached then
				states[family] = "ready"
				return
			end
		end
		if not Capabilities.Http then
			states[family] = "failed"
			return
		end
		states[family] = "loading"
		task.spawn(function()
			local loaded = false
			local success, body = Capabilities.HttpGet(REMOTE_BASE .. family .. "/dist/Icons.lua")
			if success and type(body) == "string" and #body > 0 and #body <= MAX_CATALOG then
				loaded = install(family, body)
				if loaded and Capabilities.FileSystem then
					pcall(function()
						for _, folder in ipairs({ "ZetaPro", CACHE_FOLDER }) do
							if not fs.IsFolder(folder) then
								fs.MakeFolder(folder)
							end
						end
						fs.Write(path, body)
					end)
				end
			end
			states[family] = loaded and "ready" or "failed"
			if loaded then
				Providers.CatalogReady:Fire(family)
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

	function Providers.ResolveFamily(family, name)
		local key = string.lower(family or "")
		if not REMOTE[key] or type(name) ~= "string" then
			return nil
		end
		local ok, real = pcall(function()
			request(key)
			if states[key] == "ready" then
				return build(catalogs[key], name)
			end
			return nil
		end)
		if ok and real then
			real.Name = family .. ":" .. name
			return real
		end
		return nil
	end

	function Providers.PendingFamily(name)
		if type(name) ~= "string" then
			return nil
		end
		local family = string.match(name, "^([%w_-]+):")
		if not family then
			return nil
		end
		family = string.lower(family)
		if REMOTE[family] and states[family] == "loading" then
			return family
		end
		return nil
	end

	function Providers.CatalogState(family)
		return states[string.lower(family or "")]
	end

	return Providers
end
