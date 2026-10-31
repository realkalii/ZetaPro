local Zeta = loadstring(game:HttpGet("https://raw.githubusercontent.com/realkalii/ZetaPro/beta/src/init.luau"))()

local Window = Zeta:CreateWindow({
	Title = "Settings",
	SubTitle = "Persistence demo",
	MinimizeKey = Enum.KeyCode.RightShift,
})
local Tab = Window:AddTab({ Title = "Settings", Icon = "settings" })

local Interface = Tab:AddSection("Interface")
Interface:AddDropdown("Theme", {
	Title = "Theme",
	Values = Zeta:GetThemes(),
	Default = "Dark",
	Callback = function(name)
		Zeta:SetTheme(name)
	end,
})
Interface:AddSlider("Scale", {
	Title = "Scale",
	Min = 0.7,
	Max = 1.3,
	Default = 1,
	Increment = 0.05,
	Callback = function(value)
		Zeta:SetScale(value)
	end,
})
Interface:AddKeybind("MenuKey", {
	Title = "Status key",
	Default = Enum.KeyCode.F8,
	Callback = function(key)
		Zeta:Notify({ Title = "Status shortcut", Content = key.Name, Type = "Info" })
	end,
	ChangedCallback = function(key)
		Zeta:Notify({ Title = "Status key changed", Content = key.Name, Type = "Info" })
	end,
})
Interface:AddDropdown("WindowKey", {
	Title = "Window shortcut",
	Values = { "RightShift", "RightControl" },
	Default = "RightShift",
	Callback = function(value)
		Window:SetMinimizeKey(Enum.KeyCode[value])
	end,
})
Interface:AddColorpicker("Accent", { Title = "Accent", Default = Color3.fromRGB(240, 240, 242) })

local Profile = Tab:AddSection("Profile")
Profile:AddButton({
	Title = "Save profile",
	Description = Zeta.Capabilities.FileSystem and "Writes ZetaPro/configs/default.json" or "File system unavailable here",
	Callback = function()
		local ok, err = Zeta.Config:Save("default")
		Zeta:Notify({
			Title = ok and "Saved" or "Could not save",
			Content = ok and "Profile written." or tostring(err),
			Type = ok and "Success" or "Warning",
		})
	end,
})
Profile:AddButton({
	Title = "Load profile",
	Callback = function()
		local ok, err = Zeta.Config:Load("default")
		Zeta:Notify({ Title = ok and "Loaded" or "Could not load", Content = ok and "" or tostring(err), Type = ok and "Success" or "Warning" })
	end,
})
Profile:AddButton({
	Title = "Reset to defaults",
	Callback = function()
		Zeta.Config:Reset()
	end,
})
Profile:AddButton({
	Title = "Review saved values",
	Callback = function()
		local values = Zeta.Config:Export()
		local count = 0
		for _ in values do count += 1 end
		Zeta:Notify({ Title = "Current profile", Content = count .. " settings available", Type = "Info" })
	end,
})
