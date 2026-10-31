local Zeta = loadstring(game:HttpGet("https://raw.githubusercontent.com/realkalii/ZetaPro/main/src/init.luau"))()

local Window = Zeta:CreateWindow({ Title = "Components", SubTitle = "v1.0.3" })
local Tab = Window:AddTab({ Title = "All", Icon = "code" })

local Toggle = Tab:AddToggle("Preview", { Title = "Live preview", Default = true })
local Slider = Tab:AddSlider("Opacity", { Title = "Opacity", Min = 0, Max = 1, Default = 0.5, Increment = 0.05 })
local Dropdown = Tab:AddDropdown("Mode", { Title = "Display mode", Values = { "Compact", "Balanced", "Expanded" }, Default = "Balanced" })
local Input = Tab:AddInput("Label", { Title = "Display label", Placeholder = "Label" })
local Keybind = Tab:AddKeybind("Shortcut", { Title = "Shortcut", Default = Enum.KeyCode.F6 })
local Picker = Tab:AddColorpicker("Accent", { Title = "Accent color", Default = Color3.fromRGB(120, 200, 255), Transparency = 0.2 })

Tab:AddButton({
	Title = "Apply reference preset",
	Icon = "zap",
	Callback = function()
		Toggle:SetValue(not Toggle:GetValue())
		Slider:SetValue(math.random())
		Dropdown:SetValues({ "Compact", "Balanced", "Expanded" })
		Dropdown:SetValue("Expanded")
		Input:SetValue("Reference preset")
		Keybind:SetValue(Enum.KeyCode.F7)
		Picker:SetValue(Color3.fromHSV(math.random(), 0.7, 1))
		Picker:SetTransparency(0.5)
		Zeta:Notify({ Title = "Preset applied", Type = "Success" })
	end,
})

Toggle:SetTitle("Live preview")
Toggle:SetDescription("Updates when the preset is applied")
Toggle:SetIcon("check")
Toggle:SetTooltip("This setting can be changed at runtime")
Input:SetVisible(true)
