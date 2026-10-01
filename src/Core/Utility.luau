return function(import)
	local Players = game:GetService("Players")
	local CoreGui = game:GetService("CoreGui")
	local Capabilities = import("Core/Capabilities")

	local Utility = { Debug = false }

	function Utility.Create(class, props, children)
		local instance = Instance.new(class)
		if instance:IsA("GuiObject") then
			instance.BorderSizePixel = 0
		end
		if instance:IsA("GuiButton") then
			instance.AutoButtonColor = false
		end
		if instance:IsA("TextLabel") or instance:IsA("TextButton") then
			instance.Text = ""
		end
		local parent
		for key, value in props or {} do
			if key == "Parent" then
				parent = value
			else
				instance[key] = value
			end
		end
		for _, child in children or {} do
			child.Parent = instance
		end
		instance.Parent = parent
		return instance
	end

	function Utility.Log(...)
		if Utility.Debug then
			print("[ZETA]", ...)
		end
	end

	function Utility.Warn(message)
		warn("[ZETA][WARN] " .. tostring(message))
	end

	function Utility.Format(kind, name, reason)
		return string.format('[ZETA][ERROR]\nFailed to create %s "%s":\n%s', kind, tostring(name or "?"), tostring(reason))
	end

	function Utility.Fail(kind, name, reason)
		error(Utility.Format(kind, name, reason), 0)
	end

	function Utility.Check(condition, kind, name, reason)
		if not condition then
			Utility.Fail(kind, name, reason)
		end
	end

	function Utility.SafeCall(label, callback, ...)
		if type(callback) ~= "function" then
			return false
		end
		local ok = xpcall(callback, function(err)
			warn(string.format("[ZETA][ERROR] Callback error in %s:\n%s", label, Utility.Debug and debug.traceback(tostring(err), 2) or tostring(err)))
		end, ...)
		return ok
	end

	function Utility.Round(value, decimals)
		local m = 10 ^ (decimals or 0)
		return math.floor(value * m + 0.5) / m
	end

	function Utility.DeepCopy(value)
		if type(value) ~= "table" then
			return value
		end
		local out = {}
		for k, v in value do
			out[k] = Utility.DeepCopy(v)
		end
		return out
	end

	function Utility.ToHex(color)
		return string.format(
			"#%02X%02X%02X",
			math.floor(color.R * 255 + 0.5),
			math.floor(color.G * 255 + 0.5),
			math.floor(color.B * 255 + 0.5)
		)
	end

	function Utility.FromHex(text)
		text = string.gsub(tostring(text), "^#", "")
		if #text == 3 then
			text = string.gsub(text, ".", "%0%0")
		end
		if #text ~= 6 or string.find(text, "%X") then
			return nil
		end
		return Color3.fromRGB(
			tonumber(string.sub(text, 1, 2), 16),
			tonumber(string.sub(text, 3, 4), 16),
			tonumber(string.sub(text, 5, 6), 16)
		)
	end

	function Utility.GetGuiParent()
		if Capabilities.GetHui then
			local ok, hui = pcall(Capabilities.GetHui)
			if ok and hui then
				return hui
			end
		end
		local ok = pcall(function()
			local probe = Instance.new("Folder")
			probe.Parent = CoreGui
			probe:Destroy()
		end)
		if ok then
			return CoreGui
		end
		local player = Players.LocalPlayer
		return player and player:FindFirstChildOfClass("PlayerGui")
	end

	function Utility.NewScreenGui(name, order)
		local parent = Utility.GetGuiParent()
		if not parent then
			error("[ZETA][ERROR] No GUI parent available (PlayerGui not found).", 0)
		end
		local gui = Instance.new("ScreenGui")
		gui.Name = name
		gui.ResetOnSpawn = false
		gui.IgnoreGuiInset = false
		gui.DisplayOrder = order or 100
		gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		gui:SetAttribute("ZetaPro", true)
		gui.Parent = parent
		return gui
	end

	return Utility
end
