return function(import)
	local HttpService = game:GetService("HttpService")
	local Capabilities = import("Core/Capabilities")
	local WindowSize = {}
	local folder = "ZetaPro/window-sizes"

	local function path(config)
		local identity = table.concat({
			tostring(game.GameId),
			tostring(game.PlaceId),
			tostring(config.Title or "ZetaPro"),
			tostring(config.SubTitle or ""),
			type(config.Icon) == "string" and config.Icon or "",
		}, "\0")
		local first, second = 5381, 216613
		for index = 1, #identity do
			local byte = string.byte(identity, index)
			first = (first * 33 + byte) % 2147483647
			second = (second * 131 + byte) % 2147483629
		end
		return string.format("%s/%08x-%08x.json", folder, first, second)
	end

	local function dimension(value, minimum, maximum)
		if type(value) ~= "number" or value ~= value or value == math.huge or value == -math.huge or value <= 0 then
			return nil
		end
		local upper = math.max(1, maximum)
		local lower = math.clamp(minimum, 1, upper)
		return math.clamp(math.floor(value + 0.5), lower, upper)
	end

	function WindowSize.Load(config, minimum, maximum)
		local fs = Capabilities.FS
		if type(fs.Read) ~= "function" then return nil end
		local ok, content = pcall(fs.Read, path(config))
		if not ok or type(content) ~= "string" then return nil end
		local decoded, data = pcall(function()
			return HttpService:JSONDecode(content)
		end)
		if not decoded or type(data) ~= "table" then return nil end
		local width = dimension(data.width, minimum.X, maximum.X)
		local height = dimension(data.height, minimum.Y, maximum.Y)
		if not width or not height then return nil end
		return UDim2.fromOffset(width, height)
	end

	function WindowSize.Save(config, size)
		local fs = Capabilities.FS
		if type(fs.Write) ~= "function" then return false end
		local width, height = size.X.Offset, size.Y.Offset
		if not dimension(width, 1, 100000) or not dimension(height, 1, 100000) then return false end
		local ok = pcall(function()
			if type(fs.MakeFolder) == "function" then
				pcall(fs.MakeFolder, "ZetaPro")
				pcall(fs.MakeFolder, folder)
			end
			fs.Write(path(config), HttpService:JSONEncode({ width = width, height = height }))
		end)
		return ok
	end

	return WindowSize
end
