local Zeta = loadstring(game:HttpGet("https://raw.githubusercontent.com/realkalii/ZetaPro/beta/src/init.luau"))()

local Window = Zeta:CreateWindow({ Title = "Components", SubTitle = "v1.0.3" })
local Tab = Window:AddTab({ Title = "Components", Icon = "code" })
local Status = Tab:AddLabel({ Text = "Component gallery ready", Icon = "activity" })
Tab:AddParagraph({
	Title = "Live component gallery",
	Content = "Change a value or apply the preset to see component callbacks and runtime setters.",
	Icon = "layout-grid",
})
Tab:AddDivider()

local Toggle = Tab:AddToggle("Preview", {
	Title = "Live preview",
	Default = true,
	Callback = function(value)
		Status:SetText(value and "Preview active" or "Preview paused")
	end,
})
local Slider = Tab:AddSlider("Opacity", {
	Title = "Opacity",
	Min = 0,
	Max = 1,
	Default = 0.5,
	Increment = 0.05,
	Callback = function(value)
		Status:SetText("Opacity " .. math.floor(value * 100 + 0.5) .. "%")
	end,
})
local Dropdown = Tab:AddDropdown("Mode", {
	Title = "Display mode",
	Values = { "Compact", "Balanced", "Expanded" },
	Default = "Balanced",
	Callback = function(value)
		Status:SetText(value .. " mode")
	end,
})
local Multi = Tab:AddMultiDropdown("Channels", {
	Title = "Output channels",
	Values = { "Visual", "Audio", "Alerts" },
	Default = { Visual = true, Alerts = true },
	Callback = function(values)
		local count = 0
		for _, selected in values do
			if selected then count += 1 end
		end
		Status:SetText(count .. " channels active")
	end,
})
local Input = Tab:AddInput("Label", {
	Title = "Display label",
	Placeholder = "Profile label",
	MaxLength = 32,
	Callback = function(value)
		if value ~= "" then Status:SetText("Label: " .. value) end
	end,
})
local Keybind = Tab:AddKeybind("Shortcut", {
	Title = "Status shortcut",
	Default = Enum.KeyCode.F6,
	Callback = function(key)
		Status:SetText("Shortcut used: " .. key.Name)
	end,
})
local Picker = Tab:AddColorpicker("Accent", {
	Title = "Accent color",
	Default = Color3.fromRGB(120, 200, 255),
	Transparency = 0.2,
	Callback = function(color)
		Status:SetText("Color " .. string.format("#%02X%02X%02X", math.floor(color.R * 255 + 0.5), math.floor(color.G * 255 + 0.5), math.floor(color.B * 255 + 0.5)))
	end,
})

Tab:AddButton({
	Title = "Apply reference preset",
	Icon = "zap",
	Callback = function()
		Toggle:SetValue(not Toggle:GetValue())
		Slider:SetValue(0.8)
		Dropdown:SetValues({ "Compact", "Balanced", "Expanded", "Presentation" })
		Dropdown:SetValue("Presentation")
		Multi:SetValue({ Visual = true, Audio = true, Alerts = true })
		Input:SetValue("Reference preset")
		Keybind:SetValue(Enum.KeyCode.F7)
		Picker:SetValue(Color3.fromRGB(192, 192, 192))
		Picker:SetTransparency(0.5)
		Zeta:Notify({ Title = "Preset applied", Type = "Success" })
	end,
})

Toggle:SetDescription("Updates when the preset is applied")
Toggle:SetIcon("check")
Toggle:SetTooltip("This setting can be changed at runtime")
Input:SetPlaceholder("Profile label")
