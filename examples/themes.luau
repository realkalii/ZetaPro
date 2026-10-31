local Zeta = loadstring(game:HttpGet("https://raw.githubusercontent.com/realkalii/ZetaPro/main/src/init.luau"))()

Zeta:RegisterTheme("MyRedTheme", {
	Background = Color3.fromRGB(13, 9, 10),
	Secondary = Color3.fromRGB(22, 14, 16),
	Tertiary = Color3.fromRGB(32, 20, 23),
	Text = Color3.fromRGB(240, 232, 233),
	MutedText = Color3.fromRGB(150, 128, 131),
	Accent = Color3.fromRGB(239, 68, 90),
	AccentText = Color3.fromRGB(255, 255, 255),
	Border = Color3.fromRGB(48, 30, 34),
})

Zeta:RegisterTheme("MyRedLight", {
	Base = "MyRedTheme",
	Text = Color3.fromRGB(255, 255, 255),
})

local Window = Zeta:CreateWindow({ Title = "Themes", SubTitle = "Hot swap", Theme = "Pure Red" })
local Tab = Window:AddTab({ Title = "Themes", Icon = "settings" })

Tab:AddDropdown("Theme", {
	Title = "Theme",
	Values = Zeta:GetThemes(),
	Default = "Pure Red",
	Callback = function(name)
		Zeta:SetTheme(name)
	end,
})

Tab:AddSlider("Scale", {
	Title = "UI Scale",
	Min = 0.7,
	Max = 1.3,
	Default = 1,
	Increment = 0.05,
	Callback = function(value)
		Zeta:SetScale(value)
	end,
})

Tab:AddParagraph({
	Title = "Acrylic",
	Content = "Translucent surfaces stay enabled. Blur is optional in the window configuration.",
})

Tab:AddButton({
	Title = "Use Gotham SemiBold font",
	Callback = function()
		Zeta:SetFont(Enum.Font.GothamMedium)
	end,
})
