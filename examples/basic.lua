local Zeta = loadstring(game:HttpGet("https://raw.githubusercontent.com/realkalii/ZetaPro/beta/src/init.luau"))()

local Window = Zeta:CreateWindow({
	Title = "ZetaPro",
	SubTitle = "Quick start",
	Size = UDim2.fromOffset(620, 480),
	Theme = "Dark",
	MinimizeKey = Enum.KeyCode.RightShift,
})

local Main = Window:AddTab({ Title = "Workspace", Icon = "layout-dashboard" })

Main:AddButton({
	Title = "Confirm setup",
	Description = "Verify that the interface is responding.",
	Callback = function()
		Zeta:Notify({ Title = "Action executed", Content = "The basic window is ready.", Type = "Success" })
	end,
})

Main:AddToggle("Enabled", {
	Title = "Session alerts",
	Default = false,
	Callback = function(value)
		Zeta:Notify({ Title = value and "Enabled" or "Disabled", Type = "Info" })
	end,
})
