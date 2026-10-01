-- One of each component, including programmatic control.
local Zeta = loadstring(game:HttpGet("https://raw.githubusercontent.com/ZETA-ORG/ZetaPro/main/src/init.luau"))()

local Window = Zeta:CreateWindow({ Title = "Components", SubTitle = "Reference" })
local Tab = Window:AddTab({ Title = "All", Icon = "code" })

local Toggle = Tab:AddToggle("T", { Title = "Toggle", Default = true })
local Slider = Tab:AddSlider("S", { Title = "Slider", Min = 0, Max = 1, Default = 0.5, Increment = 0.05 })
local Dropdown = Tab:AddDropdown("D", { Title = "Dropdown", Values = { "A", "B", "C" }, Default = "B" })
local Input = Tab:AddInput("I", { Title = "Input", Placeholder = "Type...", Numeric = true })
local Keybind = Tab:AddKeybind("K", { Title = "Keybind", Default = Enum.KeyCode.F })
local Picker = Tab:AddColorpicker("C", { Title = "Color", Default = Color3.fromRGB(120, 200, 255), Transparency = 0.2 })

Tab:AddButton({
	Title = "Drive everything from code",
	Icon = "zap",
	Callback = function()
		Toggle:SetValue(not Toggle:GetValue())
		Slider:SetValue(math.random())
		Dropdown:SetValues({ "X", "Y", "Z" })
		Dropdown:SetValue("Y")
		Input:SetValue("42")
		Keybind:SetValue(Enum.KeyCode.G)
		Picker:SetValue(Color3.fromHSV(math.random(), 0.7, 1))
		Picker:SetTransparency(0.5)
	end,
})

-- Lifecycle: every component supports the same methods.
Toggle:SetTitle("Renamed toggle")
Toggle:SetDescription("Description updated at runtime")
Toggle:SetIcon("check")
Toggle:SetTooltip("Hover tooltip")
Slider:SetEnabled(false)
Input:SetVisible(true)
