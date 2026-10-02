-- Minimal ZETA Pro UI.
local Zeta = loadstring(game:HttpGet("https://raw.githubusercontent.com/realkalii/ZetaPro/main/src/init.luau"))()

local Window = Zeta:CreateWindow({
	Title = "ZETA Pro",
	SubTitle = "Basic",
	Size = UDim2.fromOffset(620, 480),
	Theme = "Dark",
	Acrylic = true,
	MinimizeKey = Enum.KeyCode.RightShift,
})

local Main = Window:AddTab({ Title = "Main", Icon = "home" })

Main:AddButton({
	Title = "Execute",
	Description = "Execute the selected action",
	Callback = function()
		print("Executed")
	end,
})

Main:AddToggle("Enabled", {
	Title = "Enabled",
	Default = false,
	Callback = function(value)
		print("Enabled:", value)
	end,
})
