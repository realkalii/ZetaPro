local Zeta = loadstring(game:HttpGet("https://raw.githubusercontent.com/realkalii/ZetaPro/main/src/init.luau"))()

Zeta:RegisterTheme("Studio Silver", {
	Base = "Zeta",
	Accent = Color3.fromRGB(210, 218, 235),
})
Zeta:RegisterIconProvider("Community", function(name)
	if name == "discord-mark" then
		return { Type = "Image", Source = "rbxassetid://18505728250", Tint = false }
	end
end)
Zeta:SetIconProvider("Community")

local Window = Zeta:CreateWindow({
	Title = "ZetaPro",
	SubTitle = "Complete showcase",
	Icon = "layers",
	Theme = "Zeta",
	Size = UDim2.fromOffset(720, 510),
	SearchEnabled = true,
	CloseButton = true,
	MinimizeKey = Enum.KeyCode.RightControl,
	Discord = { Invite = "https://discord.gg/HCE8KHzzDn" },
})
local Controls = Window:AddTab({ Title = "Controls", Icon = "sliders-horizontal" })
local Appearance = Window:AddTab({ Title = "Appearance", Icon = "palette" })
local Workspace = Window:AddTab({ Title = "Workspace", Icon = "folder-cog" })

local function notify(kind, title, content)
	Zeta:Notify({ Type = kind, Title = title, Content = content, Duration = 4 })
end

local Overview = Controls:AddSection("Overview")
local Activity = Overview:AddLabel({ Text = "Ready", Icon = "activity" })
local activity = Zeta.State.new("Ready")
activity:OnChanged(function(value) Activity:SetText(value) end)
Overview:AddParagraph({ Title = "Current session", Content = "Home shows live player information and the official Discord invite.", Icon = "home" })
Overview:AddButton({ Title = "Open Home", Icon = "home", Callback = function() Window:SelectTab("Home") end })
Overview:AddLabel({ Text = "Official community", Icon = "discord-mark" })
Overview:AddDivider()

local Inputs = Controls:AddSection("Inputs", { Collapsible = true })
Inputs:AddToggle("LivePreview", {
	Title = "Live preview", Default = true, Icon = "eye", Tooltip = "Updates the session status",
	Callback = function(value) activity:Set(value and "Preview active" or "Preview paused") end,
})
Inputs:AddSlider("Intensity", {
	Title = "Intensity", Min = 0, Max = 100, Default = 50, Increment = 5, Icon = "gauge",
	Callback = function(value) activity:Set("Intensity " .. value .. "%") end,
})
Inputs:AddDropdown("Mode", {
	Title = "Display mode", Values = { "Balanced", "Compact", "Expanded" }, Default = "Balanced",
	Callback = function(value) Activity:SetText(value .. " mode") end,
})
Inputs:AddMultiDropdown("Channels", {
	Title = "Output channels", Values = { "Visual", "Audio", "Alerts" },
	Default = { Visual = true, Alerts = true },
	Callback = function(values)
		local count = 0
		for _, selected in values do if selected then count += 1 end end
		activity:Set(count .. " channels selected")
	end,
})
Inputs:AddInput("ProfileName", {
	Title = "Profile name", Placeholder = "Profile name", Default = "ZetaPro", MaxLength = 32,
	Callback = function(value) if value ~= "" then Window:SetSubtitle(value) end end,
})
Inputs:AddKeybind("ActionKey", {
	Title = "Status shortcut", Default = Enum.KeyCode.F6,
	Callback = function(key) notify("Info", "Shortcut used", key.Name) end,
	ChangedCallback = function(key) activity:Set("Shortcut: " .. key.Name) end,
})
local Accent
Accent = Inputs:AddColorpicker("Accent", {
	Title = "Selected color", Default = Color3.fromRGB(192, 192, 192), Transparency = 0,
	Callback = function() activity:Set("Color " .. Accent:GetHex()) end,
})

local Themes = Appearance:AddSection("Themes")
Themes:AddDropdown("Theme", {
	Title = "Built-in theme", Values = Zeta:GetThemes(), Default = "Zeta",
	Callback = function(name) Zeta:SetTheme(name) end,
})
Themes:AddSlider("Scale", {
	Title = "Interface scale", Min = 0.75, Max = 1.3, Default = 1, Increment = 0.05, Rounding = 2,
	Callback = function(value) Zeta:SetScale(value) end,
})
Themes:AddButton({
	Title = "Use Gotham", Icon = "type",
	Callback = function()
		Zeta:SetFont(Enum.Font.Gotham)
		notify("Info", "Font applied", "Gotham")
	end,
})
local WindowControls = Appearance:AddSection("Window", { Collapsible = true })
WindowControls:AddParagraph({
	Title = "Glass and resizing",
	Content = "Acrylic is always on. Drag the lower-right handle to resize; size persists when file access is available.",
})
local searchEnabled = true
WindowControls:AddButton({
	Title = "Toggle search", Icon = "search",
	Callback = function()
		searchEnabled = not searchEnabled
		Window:SetSearchEnabled(searchEnabled)
	end,
})
WindowControls:AddButton({ Title = "Minimize window", Icon = "minus", Callback = function() Window:Minimize() end })

local Notifications = Workspace:AddSection("Notifications")
for _, kind in { "Info", "Success", "Warning", "Error" } do
	Notifications:AddButton({
		Title = kind .. " notification", Icon = "bell",
		Callback = function() notify(kind, kind .. " status", "Notification styling follows the active theme.") end,
	})
end
Notifications:AddButton({
	Title = "Open dialog", Icon = "panel-top",
	Callback = function()
		local dialog = Window:CreateDialog({ Title = "Confirm reset", Content = "Reset registered component values?" })
		dialog:AddButton({ Title = "Keep values" })
		dialog:AddButton({
			Title = "Reset", Primary = true,
			Callback = function()
				Zeta.Config:Reset()
				notify("Success", "Values reset", "Registered defaults are active.")
			end,
		})
	end,
})

local Storage = Workspace:AddSection("Configuration", { Collapsible = true })
Storage:AddButton({
	Title = "Save configuration", Icon = "save",
	Callback = function()
		local ok, reason = Zeta.Config:Save("complete-showcase")
		notify(ok and "Success" or "Warning", ok and "Configuration saved" or "Save unavailable", ok and "complete-showcase" or tostring(reason))
	end,
})
Storage:AddButton({
	Title = "Load configuration", Icon = "folder-open",
	Callback = function()
		local ok, reason = Zeta.Config:Load("complete-showcase")
		notify(ok and "Success" or "Warning", ok and "Configuration loaded" or "Load unavailable", ok and "complete-showcase" or tostring(reason))
	end,
})
Storage:AddButton({
	Title = "Inspect configuration", Icon = "database",
	Callback = function()
		local count = 0
		for _ in Zeta.Config:Export() do count += 1 end
		notify("Info", "Registered values", count .. " settings")
	end,
})
