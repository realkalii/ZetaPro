return function(import)
	local UserInputService = game:GetService("UserInputService")

	local env = {}
	pcall(function()
		env = getfenv(1)
	end)

	local function lookup(name)
		local value = env[name]
		if type(value) == "function" then
			return value
		end
		return nil
	end

	local Capabilities = {}

	Capabilities.GetHui = lookup("gethui")
	Capabilities.GetCustomAsset = lookup("getcustomasset") or lookup("getsynasset")

	local requestFn = lookup("request") or lookup("http_request")
	if not requestFn and type(env.syn) == "table" then
		requestFn = env.syn.request
	end
	Capabilities.Request = requestFn

	local okGet, httpGet = pcall(function()
		return game.HttpGet
	end)
	local hasHttpGet = okGet and httpGet ~= nil
	Capabilities.Http = hasHttpGet or requestFn ~= nil

	local fs = {
		Write = lookup("writefile"),
		Read = lookup("readfile"),
		IsFile = lookup("isfile"),
		MakeFolder = lookup("makefolder"),
		IsFolder = lookup("isfolder"),
	}
	Capabilities.FS = fs
	Capabilities.FileSystem = (fs.Write ~= nil and fs.Read ~= nil and fs.IsFile ~= nil and fs.MakeFolder ~= nil and fs.IsFolder ~= nil)

	local clipboard = lookup("setclipboard") or lookup("toclipboard")
	Capabilities.Clipboard = clipboard ~= nil
	Capabilities.Drawing = env.Drawing ~= nil
	Capabilities.Touch = UserInputService.TouchEnabled
	Capabilities.Keyboard = UserInputService.KeyboardEnabled

	function Capabilities.SetClipboard(text)
		if not clipboard then
			return false
		end
		return (pcall(clipboard, text))
	end

	function Capabilities.HttpGet(url)
		if hasHttpGet then
			local ok, body = pcall(function()
				return game:HttpGet(url)
			end)
			if ok then
				return true, body
			end
			return false, tostring(body)
		end
		if requestFn then
			local ok, response = pcall(requestFn, { Url = url, Method = "GET" })
			if ok and type(response) == "table" and (response.Success or response.StatusCode == 200) then
				return true, response.Body
			end
			return false, "request failed"
		end
		return false, "no http capability"
	end

	return Capabilities
end
