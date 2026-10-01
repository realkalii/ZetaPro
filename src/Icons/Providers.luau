return function(import)
	local Capabilities = import("Core/Capabilities")

	-- Built-in icons are original, Lucide-style line drawings on a 24x24 grid
	-- (stroke segments + circles). They are rendered with Frames, so they need
	-- no asset uploads, no network and no external license.
	local Providers = {}

	local function poly(points, closed)
		local out = {}
		for i = 1, #points - 1 do
			out[#out + 1] = { points[i][1], points[i][2], points[i + 1][1], points[i + 1][2] }
		end
		if closed then
			local first, last = points[1], points[#points]
			out[#out + 1] = { last[1], last[2], first[1], first[2] }
		end
		return out
	end

	local function merge(...)
		local out = {}
		for _, list in { ... } do
			for _, segment in list do
				out[#out + 1] = segment
			end
		end
		return out
	end

	local function rect(x1, y1, x2, y2)
		return poly({ { x1, y1 }, { x2, y1 }, { x2, y2 }, { x1, y2 } }, true)
	end

	local DATA = {
		home = { L = merge(poly({ { 3, 11 }, { 12, 3 }, { 21, 11 } }), poly({ { 5, 10 }, { 5, 20 }, { 19, 20 }, { 19, 10 } }), poly({ { 10, 20 }, { 10, 14 }, { 14, 14 }, { 14, 20 } })) },
		settings = { L = { { 4, 7, 20, 7 }, { 4, 17, 20, 17 } }, C = { { 9, 7, 2.5 }, { 15, 17, 2.5 } } },
		search = { L = { { 16, 16, 21, 21 } }, C = { { 11, 11, 7 } } },
		user = { L = poly({ { 4, 21 }, { 5, 17 }, { 9, 15 }, { 15, 15 }, { 19, 17 }, { 20, 21 } }), C = { { 12, 8, 4 } } },
		shield = { L = poly({ { 12, 3 }, { 20, 6 }, { 20, 12 }, { 17, 18 }, { 12, 21 }, { 7, 18 }, { 4, 12 }, { 4, 6 } }, true) },
		code = { L = merge(poly({ { 8, 7 }, { 3, 12 }, { 8, 17 } }), poly({ { 16, 7 }, { 21, 12 }, { 16, 17 } }), { { 14, 5, 10, 19 } }) },
		terminal = { L = merge(poly({ { 4, 7 }, { 10, 12 }, { 4, 17 } }), { { 12, 18, 20, 18 } }) },
		folder = { L = poly({ { 3, 6 }, { 9, 6 }, { 11, 9 }, { 21, 9 }, { 21, 19 }, { 3, 19 } }, true) },
		trash = { L = merge({ { 4, 7, 20, 7 }, { 10, 11, 10, 16 }, { 14, 11, 14, 16 } }, poly({ { 9, 7 }, { 9, 4 }, { 15, 4 }, { 15, 7 } }), poly({ { 6, 7 }, { 7, 20 }, { 17, 20 }, { 18, 7 } })) },
		plus = { L = { { 12, 5, 12, 19 }, { 5, 12, 19, 12 } } },
		minus = { L = { { 5, 12, 19, 12 } } },
		check = { L = poly({ { 4, 12 }, { 10, 18 }, { 20, 6 } }) },
		x = { L = { { 6, 6, 18, 18 }, { 18, 6, 6, 18 } } },
		info = { L = { { 12, 11, 12, 17 }, { 12, 7.5, 12, 8 } }, C = { { 12, 12, 9 } } },
		alert = { L = merge(poly({ { 12, 3 }, { 22, 20 }, { 2, 20 } }, true), { { 12, 9, 12, 14 }, { 12, 17, 12, 17.5 } }) },
		["alert-circle"] = { L = { { 12, 7, 12, 13 }, { 12, 16.5, 12, 17 } }, C = { { 12, 12, 9 } } },
		["check-circle"] = { L = poly({ { 8, 12 }, { 11, 15 }, { 16, 9 } }), C = { { 12, 12, 9 } } },
		["chevron-down"] = { L = poly({ { 6, 9 }, { 12, 15 }, { 18, 9 } }) },
		["chevron-up"] = { L = poly({ { 6, 15 }, { 12, 9 }, { 18, 15 } }) },
		["chevron-right"] = { L = poly({ { 9, 6 }, { 15, 12 }, { 9, 18 } }) },
		copy = { L = merge(rect(8, 8, 20, 20), poly({ { 4, 16 }, { 4, 4 }, { 16, 4 } })) },
		eye = { L = poly({ { 2, 12 }, { 7, 7 }, { 12, 5.5 }, { 17, 7 }, { 22, 12 }, { 17, 17 }, { 12, 18.5 }, { 7, 17 } }, true), C = { { 12, 12, 3 } } },
		keyboard = { L = merge(rect(2, 6, 22, 18), { { 6, 10, 7, 10 }, { 10, 10, 11, 10 }, { 14, 10, 15, 10 }, { 18, 10, 19, 10 }, { 7, 14, 17, 14 } }) },
		bell = { L = merge(poly({ { 6, 16 }, { 6, 10 }, { 8, 6 }, { 12, 4 }, { 16, 6 }, { 18, 10 }, { 18, 16 } }), { { 4, 16, 20, 16 }, { 10, 20, 14, 20 } }) },
		zap = { L = poly({ { 13, 2 }, { 4, 14 }, { 12, 14 }, { 11, 22 }, { 20, 10 }, { 12, 10 } }, true) },
		lock = { L = merge(rect(5, 11, 19, 21), poly({ { 8, 11 }, { 8, 7 }, { 10, 4 }, { 14, 4 }, { 16, 7 }, { 16, 11 } })) },
		menu = { L = { { 4, 6, 20, 6 }, { 4, 12, 20, 12 }, { 4, 18, 20, 18 } } },
		grip = { L = { { 20, 10, 10, 20 }, { 20, 15, 15, 20 } } },
		play = { L = poly({ { 7, 4 }, { 20, 12 }, { 7, 20 } }, true) },
		crosshair = { L = { { 12, 2, 12, 7 }, { 12, 17, 12, 22 }, { 2, 12, 7, 12 }, { 17, 12, 22, 12 } }, C = { { 12, 12, 8 } } },
		help = { L = { { 12, 17, 12, 17.5 }, { 9.5, 9.5, 12, 7 }, { 12, 7, 14.5, 9.5 }, { 14.5, 9.5, 12, 12 }, { 12, 12, 12, 14 } }, C = { { 12, 12, 9 } } },
	}
	local FALLBACK = { L = {}, C = { { 12, 12, 3 } } }

	local names = {}
	for name in DATA do
		table.insert(names, name)
	end
	table.sort(names)

	local function toSpec(name, data)
		return { Type = "Vector", Name = name, L = data.L or {}, C = data.C or {} }
	end

	Providers.Builtin = {
		Name = "Builtin",
		Resolve = function(name)
			local data = DATA[name]
			return data and toSpec(name, data) or nil
		end,
		Names = function()
			return table.clone(names)
		end,
	}
	Providers.Fallback = toSpec("fallback", FALLBACK)

	-- Remote images: only https, PNG only, size-limited, disk-cached and
	-- strictly opt-in via Icon = { Type = "Url" }. Needs Http + FileSystem +
	-- getcustomasset; otherwise the caller falls back gracefully.
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

	return Providers
end
