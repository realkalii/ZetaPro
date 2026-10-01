-- Demonstrates almost the whole public API.
local Zeta = loadstring(game:HttpGet("https://raw.githubusercontent.com/ZETA-ORG/ZetaPro/main/src/init.luau"))()

local Window = Zeta:CreateWindow({
	Title = "ZETA Pro",
	SubTitle = "Complete",
	Icon = "terminal",
	Size = UDim2.fromOffset(620, 480),
	MinSize = Vector2.new(420, 320),
	MaxSize = Vector2.new(1000, 800),
	Theme = "Dark",
	Acrylic = true,
	Resize = true,
	CloseButton = true,
	MinimizeKey = Enum.KeyCode.RightShift,
})

local Main = Window:AddTab({ Title = "Main", Icon = "home" })
local Visuals = Window:AddTab({ Title = "Visuals", Icon = "eye" })
local Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })

local Movement = Main:AddSection("Movement")

local Execute = Movement:AddButton({
	Title = "Execute",
	Description = "Execute the selected action",
	Icon = "play",
	Callback = function()
		Zeta:Notify({ Title = "ZETA Pro", Content = "Operation completed.", Type = "Success", Duration = 4 })
	end,
})
Execute:SetTooltip("Runs the action once")

local AutoFarm = Movement:AddToggle("AutoFarm", {
	Title = "Auto Farm",
	Description = "Automatically farms resources",
	Default = false,
	Callback = function(value)
		print("AutoFarm:", value)
	end,
})
AutoFarm:OnChanged(function(value)
	print("OnChanged:", value)
end)

Movement:AddSlider("WalkSpeed", {
	Title = "Walk Speed",
	Description = "Change your movement speed",
	Min = 16,
	Max = 250,
	Default = 16,
	Rounding = 0,
	Callback = function(value)
		print("Speed:", value)
	end,
})

Movement:AddDivider({})

local Combat = Main:AddSection("Combat")

Combat:AddDropdown("Mode", {
	Title = "Mode",
	Values = { "Legit", "Rage", "Silent" },
	Multi = false,
	Default = 1,
	Callback = function(value)
		print("Mode:", value)
	end,
})

Combat:AddDropdown("Targets", {
	Title = "Targets",
	Values = { "Players", "NPCs", "Bosses" },
	Multi = true,
	Default = { Players = true },
	Callback = function(map)
		print("Players:", map.Players, "NPCs:", map.NPCs, "Bosses:", map.Bosses)
	end,
})

Combat:AddInput("Username", {
	Title = "Username",
	Description = "Enter a username",
	Default = "",
	Placeholder = "Username...",
	MaxLength = 20,
	Callback = function(value)
		print("Username:", value)
	end,
})

Combat:AddKeybind("ToggleUI", {
	Title = "Toggle UI",
	Default = Enum.KeyCode.RightShift,
	Callback = function()
		Window:Toggle()
	end,
})

Visuals:AddColorpicker("Accent", {
	Title = "Accent Color",
	Default = Color3.fromRGB(255, 255, 255),
	Transparency = 0,
	Callback = function(color, transparency)
		print("Accent:", color, transparency)
	end,
})

Visuals:AddParagraph({
	Title = "Information",
	Content = "This is an informational component.",
	Icon = "info",
})
Visuals:AddLabel({ Text = "Labels are plain, flat text rows." })

Settings:AddButton({
	Title = "Confirm dialog",
	Description = "Opens a confirmation dialog",
	Callback = function()
		local Dialog = Window:CreateDialog({ Title = "Confirm", Content = "Are you sure?" })
		Dialog:AddButton({ Title = "Cancel" })
		Dialog:AddButton({
			Title = "Confirm",
			Primary = true,
			Callback = function()
				Zeta:Notify({ Title = "Confirmed", Type = "Info" })
			end,
		})
	end,
})

Settings:AddDropdown("ThemeName", {
	Title = "Theme",
	Values = Zeta:GetThemes(),
	Default = Zeta:GetTheme(),
	Callback = function(name)
		Zeta:SetTheme(name)
	end,
})

Window:SetSearchEnabled(true)
Window:SelectTab(1)
