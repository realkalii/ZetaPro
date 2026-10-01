-- Icon system: names, Zeta.Icons, custom images and providers.
local Zeta = loadstring(game:HttpGet("https://raw.githubusercontent.com/ZETA-ORG/ZetaPro/main/src/init.luau"))()

local Window = Zeta:CreateWindow({ Title = "Icons", SubTitle = "Showcase" })
local Tab = Window:AddTab({ Title = "Icons", Icon = Zeta.Icons.Home })

print("Built-in icons:", table.concat(Zeta.Icons:List(), ", "))

local Section = Tab:AddSection("Built-in")
for _, name in { "home", "settings", "search", "user", "shield", "code", "terminal", "folder", "trash", "plus", "minus" } do
	Section:AddLabel({ Text = name, Icon = name })
end

local Custom = Tab:AddSection("Custom")

-- Replace rbxassetid://0 with the id of an image you uploaded.
Custom:AddButton({
	Title = "Image icon",
	Icon = { Type = "Image", Source = "rbxassetid://0", Tint = true },
})

-- Remote PNG: https only, size-limited, cached to disk, falls back safely.
Custom:AddButton({
	Title = "Url icon (needs file system + getcustomasset)",
	Icon = { Type = "Url", Source = "https://example.com/icon.png", Tint = true },
})

local Swap = Custom:AddButton({
	Title = "Swap icon at runtime",
	Icon = "check",
	Callback = function() end,
})
local flip = false
Swap:SetCallback(function()
	flip = not flip
	Swap:SetIcon(flip and "x" or "check")
end)
Custom:AddButton({
	Title = "Remove icon",
	Callback = function()
		Swap:SetIcon(nil)
	end,
})

-- Custom provider: return a spec (or nil to fall back to the built-in set).
Zeta:RegisterIconProvider("Mine", function(name)
	if name == "logo" then
		return { Type = "Image", Source = "rbxassetid://0", Tint = true }
	end
	return nil
end)
Zeta:SetIconProvider("Mine")
