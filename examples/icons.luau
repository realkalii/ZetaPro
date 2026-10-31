local Zeta = loadstring(game:HttpGet("https://raw.githubusercontent.com/realkalii/ZetaPro/main/src/init.luau"))()

local Window = Zeta:CreateWindow({ Title = "Icons", SubTitle = "Showcase" })
local Tab = Window:AddTab({ Title = "Icons", Icon = Zeta.Icons.Home })

local Section = Tab:AddSection("Built-in")
for _, name in { "home", "settings", "search", "user", "shield", "code", "terminal", "folder", "trash", "plus", "minus" } do
	Section:AddLabel({ Text = name, Icon = name })
end

local Custom = Tab:AddSection("Custom")

Custom:AddLabel({
	Text = "Roblox image asset",
	Icon = { Type = "Image", Source = "rbxassetid://18505728250", Tint = false },
})

Custom:AddParagraph({
	Title = "Remote PNG icons",
	Content = "HTTPS PNG icons can be loaded when the executor supports HTTP, files and custom assets.",
})

local Swap = Custom:AddButton({
	Title = "Change icon at runtime",
	Icon = "check",
})
local flip = false
Swap:SetCallback(function()
	flip = not flip
	Swap:SetIcon(flip and "x" or "check")
end)
Custom:AddButton({
	Title = "Hide the action icon",
	Callback = function()
		Swap:SetIcon(nil)
	end,
})

Zeta:RegisterIconProvider("Reference", function(name)
	if name == "discord-mark" then
		return { Type = "Image", Source = "rbxassetid://18505728250", Tint = false }
	end
	return nil
end)
Zeta:SetIconProvider("Reference")
Custom:AddLabel({ Text = "Custom provider", Icon = "discord-mark" })
