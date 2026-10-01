--[[
	ZETA Pro V1.0 — Modern Luau UI Library
	Entry point and public API.

	Executor:
		local Zeta = loadstring(game:HttpGet("https://raw.githubusercontent.com/ZETA-ORG/ZetaPro/main/src/init.luau"))()

	Roblox Studio / Rojo:
		local Zeta = require(path.to.ZetaPro)

	Every module is `return function(import) ... end`. In Studio, `import`
	resolves ModuleScripts under this script; in executors it downloads each
	module from the repository (all in parallel, cached for the session) and
	compiles it with loadstring. Override the source with
	getgenv().ZETA_BASE = "https://.../src/".
]]

local VERSION = "1.0.0"
local DEFAULT_BASE = "https://raw.githubusercontent.com/ZETA-ORG/ZetaPro/main/src/"

local MODULES = {
	"Core/Signal", "Core/State", "Core/Capabilities", "Core/Utility", "Core/Config", "Core/Theme",
	"Core/Widgets", "Core/Search", "Core/Component", "Core/Section", "Core/Tab", "Core/Window",
	"Themes/Default", "Themes/Dark", "Themes/Light", "Themes/Midnight", "Themes/Zeta",
	"Services/Cleanup", "Services/Animation", "Services/Input", "Services/Drag", "Services/Acrylic",
	"Services/Tooltip", "Services/Notification",
	"Icons/Icon", "Icons/Registry", "Icons/Providers",
	"Components/Button", "Components/Toggle", "Components/Slider", "Components/Dropdown",
	"Components/MultiDropdown", "Components/Input", "Components/Keybind", "Components/Colorpicker",
	"Components/Paragraph", "Components/Label", "Components/Divider", "Components/Notification",
	"Components/Dialog",
}

local globalEnv
do
	local ok, env = pcall(function()
		return getgenv()
	end)
	globalEnv = ok and env or _G
end

-- Re-executing the script replaces the previous instance cleanly.
if type(globalEnv.__ZetaPro) == "table" and type(globalEnv.__ZetaPro.Unload) == "function" then
	pcall(function()
		globalEnv.__ZetaPro:Unload()
	end)
end

local isStudio = typeof(script) == "Instance" and script:IsA("ModuleScript")
local sources, loaded = {}, {}
local import

local function fetch(path)
	local url = (globalEnv.ZETA_BASE or DEFAULT_BASE) .. path .. ".luau"
	local ok, body = pcall(function()
		return game:HttpGet(url)
	end)
	if not ok or type(body) ~= "string" or body == "" then
		error(string.format("[ZETA][ERROR] Failed to download module %s\nURL: %s\nReason: %s", path, url, tostring(body)), 0)
	end
	sources[path] = body
end

local function prefetch()
	local pending, failure = #MODULES, nil
	for _, path in MODULES do
		task.spawn(function()
			local ok, err = pcall(fetch, path)
			if not ok then
				failure = failure or err
			end
			pending -= 1
		end)
	end
	local started = os.clock()
	while pending > 0 and os.clock() - started < 30 do
		task.wait()
	end
	if failure then
		error(failure, 0)
	end
	if pending > 0 then
		error("[ZETA][ERROR] Timed out while downloading modules.", 0)
	end
end

function import(path)
	local cached = loaded[path]
	if cached ~= nil then
		return cached
	end
	local factory
	if isStudio then
		local instance = script
		for _, part in string.split(path, "/") do
			instance = instance:FindFirstChild(part)
			if not instance then
				error("[ZETA][ERROR] Missing module: " .. path, 0)
			end
		end
		factory = require(instance)
	else
		if not sources[path] then
			fetch(path)
		end
		local compiled, err = loadstring(sources[path], "=ZetaPro/" .. path)
		if not compiled then
			error(string.format("[ZETA][ERROR] Syntax error in module %s:\n%s", path, tostring(err)), 0)
		end
		factory = compiled()
	end
	local module = factory
	if type(factory) == "function" then
		module = factory(import)
	end
	loaded[path] = module
	return module
end

if not isStudio then
	prefetch()
end

local Utility = import("Core/Utility")
local Signal = import("Core/Signal")
local State = import("Core/State")
local Config = import("Core/Config")
local Capabilities = import("Core/Capabilities")
local Theme = import("Core/Theme")
local Component = import("Core/Component")
local Window = import("Core/Window")
local Icons = import("Icons/Icon")
local IconRegistry = import("Icons/Registry")
local Input = import("Services/Input")
local Tooltip = import("Services/Tooltip")
local Notification = import("Services/Notification")

for _, name in { "Dark", "Light", "Midnight", "Zeta" } do
	Theme.Register(name, import("Themes/" .. name))
end
Theme.Set("Dark")

for _, name in {
	"Button", "Toggle", "Slider", "Dropdown", "MultiDropdown", "Input",
	"Keybind", "Colorpicker", "Paragraph", "Label", "Divider",
} do
	Component.Register(name, import("Components/" .. name))
end

local Zeta = {
	Icons = Icons,
	Config = Config,
	State = State,
	Signal = Signal,
	Capabilities = Capabilities,
	Component = Component,
}

local windows = {}

function Zeta:CreateWindow(config)
	local window = Window.new(config or {})
	table.insert(windows, window)
	window.OnDestroy:Connect(function()
		local index = table.find(windows, window)
		if index then
			table.remove(windows, index)
		end
	end)
	return window
end

function Zeta:SetTheme(name)
	return Theme.Set(name)
end

function Zeta:GetTheme()
	return Theme.GetName()
end

function Zeta:GetThemes()
	return Theme.Names()
end

function Zeta:RegisterTheme(name, definition)
	Theme.Register(name, definition)
end

function Zeta:SetIconProvider(name)
	return IconRegistry.SetProvider(name)
end

function Zeta:RegisterIconProvider(name, resolve)
	IconRegistry.Register(name, resolve)
end

function Zeta:Notify(config)
	return Notification.Notify(config)
end

function Zeta:SetFont(font)
	Theme.SetFont(font)
end

function Zeta:SetScale(scale)
	Theme.SetScale(scale)
end

function Zeta:RegisterComponent(name, factory)
	Component.Register(name, factory)
end

function Zeta:SetDebug(enabled)
	Utility.Debug = enabled == true
end

function Zeta:GetVersion()
	return VERSION
end

function Zeta:GetStats()
	local guis = 0
	local parent = Utility.GetGuiParent()
	if parent then
		for _, child in parent:GetChildren() do
			if child:GetAttribute("ZetaPro") then
				guis += 1
			end
		end
	end
	return { Windows = #windows, Binds = Input.BindCount(), Guis = guis, Notifications = Notification.Count() }
end

function Zeta:Unload()
	for _, window in table.clone(windows) do
		window:Destroy()
	end
	Notification.Reset()
	Tooltip.Reset()
	Input.Reset()
	if globalEnv.__ZetaPro == self then
		globalEnv.__ZetaPro = nil
	end
end

globalEnv.__ZetaPro = Zeta
return Zeta
