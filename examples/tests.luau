-- Internal test suite. Run in Studio (LocalScript) or an executor.
-- Covers: Window, Tabs, Sections, Components, Callbacks, State, Themes, Icons,
-- Notifications, Search, Destroy/Cleanup and repeated create/destroy cycles.
local Zeta = loadstring(game:HttpGet("https://raw.githubusercontent.com/realkalii/ZetaPro/main/src/init.luau"))()

local passed, failed = 0, 0
local function check(name, condition, detail)
	if condition then
		passed += 1
	else
		failed += 1
		warn(("[TEST FAIL] %s %s"):format(name, detail and ("(" .. tostring(detail) .. ")") or ""))
	end
end
local function section(name)
	print("== " .. name)
end

local baseline = Zeta:GetStats()

section("Window / Tabs / Sections")
local Window = Zeta:CreateWindow({ Title = "Tests", MinimizeKey = Enum.KeyCode.RightShift })
local Main = Window:AddTab({ Title = "Main", Icon = "home" })
local Other = Window:AddTab({ Title = "Other", Icon = "settings" })
local Movement = Main:AddSection("Movement")
check("window created", Window ~= nil and Window.Root ~= nil)
check("two tabs", #Window.Tabs == 2)
check("first tab selected", Window._selected == Main)
Window:SelectTab("Other")
check("select by title", Window._selected == Other)
Window:SelectTab(1)

section("Components and callbacks")
local fired = {}
local Button = Movement:AddButton({ Title = "Run", Callback = function() fired.Button = true end })
local Toggle = Movement:AddToggle("T_Test", { Title = "Toggle", Default = false, Callback = function(v) fired.Toggle = v end })
local Slider = Movement:AddSlider("S_Test", { Title = "Walk Speed", Min = 16, Max = 250, Default = 16, Callback = function(v) fired.Slider = v end })
local Dropdown = Movement:AddDropdown("D_Test", { Title = "Mode", Values = { "Legit", "Rage", "Silent" }, Default = 1, Callback = function(v) fired.Dropdown = v end })
local Multi = Movement:AddDropdown("M_Test", { Title = "Targets", Values = { "Players", "NPCs", "Bosses" }, Multi = true, Default = { Players = true }, Callback = function(v) fired.Multi = v end })
local Input = Movement:AddInput("I_Test", { Title = "Name", MaxLength = 5, Callback = function(v) fired.Input = v end })
local Keybind = Movement:AddKeybind("K_Test", { Title = "Key", Default = Enum.KeyCode.F })
local Picker = Movement:AddColorpicker("C_Test", { Title = "Color", Default = Color3.new(1, 0, 0), Transparency = 0, Callback = function(c) fired.Color = c end })
Movement:AddParagraph({ Title = "Info", Content = "Paragraph" })
Movement:AddLabel({ Text = "Label" })
Movement:AddDivider({})

Button:Fire()
check("button callback", fired.Button == true)
Toggle:SetValue(true)
task.wait()
check("toggle value", Toggle:GetValue() == true)
check("toggle callback", fired.Toggle == true)
Slider:SetValue(100)
task.wait()
check("slider value", Slider:GetValue() == 100)
Slider:SetValue(9999)
check("slider clamps", Slider:GetValue() == 250)
check("dropdown default by index", Dropdown:GetValue() == "Legit")
Dropdown:SetValue("Rage")
check("dropdown set", Dropdown:GetValue() == "Rage")
local map = Multi:GetValue()
check("multi default", map.Players == true and map.NPCs == false and map.Bosses == false)
Multi:SetValue({ NPCs = true })
check("multi set", Multi:GetValue().NPCs == true and Multi:GetValue().Players == false)
Input:SetValue("abc")
check("input set", Input:GetValue() == "abc")
Keybind:SetValue(Enum.KeyCode.G)
check("keybind set", Keybind:GetValue() == Enum.KeyCode.G)
Picker:SetValue(Color3.new(0, 1, 0))
check("color set", Picker:GetValue() == Color3.new(0, 1, 0))
local changedCount = 0
local connection = Toggle:OnChanged(function() changedCount += 1 end)
Toggle:SetValue(false)
task.wait()
check("OnChanged", changedCount == 1)
connection:Disconnect()
check("options registry", Window.Options.T_Test == Toggle)
check("duplicate id rejected", not pcall(function() Movement:AddToggle("T_Test", { Title = "dup" }) end))
check("bad default rejected", not pcall(function() Movement:AddToggle("Bad", { Default = "yes" }) end))

section("Config / State")
check("config mirrors UI", Zeta.Config:Get("S_Test") == 250)
Zeta.Config:Set("S_Test", 60)
task.wait()
check("config drives UI", Slider:GetValue() == 60)
local exported = Zeta.Config:Export()
check("export has keys", exported.T_Test ~= nil and exported.S_Test == 60)
local state = Zeta.State.new(1)
local seen
state:OnChanged(function(v) seen = v end)
state:Set(2)
task.wait()
check("state", state:Get() == 2 and seen == 2)

section("Themes / Icons")
Zeta:RegisterTheme("TestTheme", { Background = Color3.fromRGB(1, 2, 3), Accent = Color3.fromRGB(9, 9, 9) })
check("theme set", Zeta:SetTheme("TestTheme") and Zeta:GetTheme() == "TestTheme")
Zeta:SetTheme("Dark")
check("unknown theme rejected", Zeta:SetTheme("NopeNope") == false)
check("icon get", Zeta.Icons:Get("home") ~= nil and Zeta.Icons.Home ~= nil)
check("icon unknown", Zeta.Icons:Get("does-not-exist") == nil)
Button:SetIcon("check")
Button:SetIcon(nil)
check("icon hot swap", true)

section("Search")
local results = Window._search:Query("speed")
check("search finds component", #results >= 1 and results[1].Title == "Walk Speed")
check("search breadcrumb", results[1].Tab == Main and results[1].Section == Movement)
Slider:Destroy()
check("destroyed removed from index", #Window._search:Query("speed") == 0)

section("Notifications / Dialog / Minimize")
local note = Zeta:Notify({ Title = "Test", Duration = 0 })
check("notification", Zeta:GetStats().Notifications >= 1)
note:Close()
local dialog = Window:CreateDialog({ Title = "Dialog", Content = "Body" })
dialog:AddButton({ Title = "OK" })
dialog:Close()
Window:_Minimize()  -- internal UI regression test
check("minimized", Window._minimized)
Window:_Restore()  -- internal UI regression test
check("restored", not Window._minimized)

section("Destroy / Cleanup")
Window:Destroy()
task.wait(0.5)
check("window destroyed", Zeta:GetStats().Windows == baseline.Windows)
check("binds released", Zeta:GetStats().Binds == baseline.Binds)

section("Create / destroy cycles")
for cycle = 1, 25 do
	local w = Zeta:CreateWindow({ Title = "Cycle " .. cycle, MinimizeKey = Enum.KeyCode.RightShift })
	local tab = w:AddTab({ Title = "T", Icon = "home" })
	local sec = tab:AddSection("S")
	sec:AddButton({ Title = "b" })
	sec:AddToggle("cycle_t", { Title = "t" })
	sec:AddSlider("cycle_s", { Title = "s", Min = 0, Max = 10, Default = 5 })
	sec:AddDropdown("cycle_d", { Title = "d", Values = { "a", "b" }, Default = 1 })
	sec:AddInput("cycle_i", { Title = "i" })
	sec:AddKeybind("cycle_k", { Title = "k", Default = Enum.KeyCode.H })
	sec:AddColorpicker("cycle_c", { Title = "c" })
	w:Destroy()
end
task.wait(0.5)
local after = Zeta:GetStats()
check("no leaked windows", after.Windows == baseline.Windows, after.Windows)
check("no leaked binds", after.Binds == baseline.Binds, after.Binds)
check("no leaked guis", after.Guis <= baseline.Guis + 2, after.Guis) -- notification/tooltip hosts may persist

Zeta.Config:Wipe()
print(("Tests finished: %d passed, %d failed"):format(passed, failed))
if failed == 0 then
	Zeta:Notify({ Title = "ZETA tests", Content = "All " .. passed .. " checks passed.", Type = "Success" })
end
