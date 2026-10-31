# Getting started

## 1. Load the library
```lua
local Zeta = loadstring(game:HttpGet("https://raw.githubusercontent.com/realkalii/ZetaPro/main/src/init.luau"))()
```
In Studio use Rojo and `require` the `src` folder.

## 2. Create a window and a tab
```lua
local Window = Zeta:CreateWindow({
    Title = "My Hub",
    SubTitle = "v1.0.3",
    Theme = "Dark",
    Discord = { Invite = "https://discord.gg/HCE8KHzzDn" },
})
local Main = Window:AddTab({ Title = "Main", Icon = "home" })
```

Home is added automatically before your custom tabs. The Discord card appears when `Discord.Invite` is a valid invite URL.

## 3. Add components
```lua
local Section = Main:AddSection("Interface")
Section:AddToggle("Preview", { Title = "Live preview", Default = false })
Section:AddSlider("Intensity", { Title = "Intensity", Min = 0, Max = 100, Default = 50 })
```
Components added to a Tab or a Section behave the same. The optional first argument is a unique id; with an id the component is available at `Window.Options[id]` and its value lives in `Zeta.Config`.

## 4. Read state, react to changes
```lua
local Preview = Window.Options.Preview
Preview:OnChanged(function(value)
    Zeta:Notify({ Title = value and "Preview on" or "Preview off", Type = "Info" })
end)
Preview:SetValue(true)
```
Callbacks do not run at creation, only on value changes.

## 5. Clean up
```lua
Window:Destroy()   -- or Zeta:Unload() to remove everything
```

## Debugging
`Zeta:SetDebug(true)` enables verbose logs and full tracebacks for callback errors. With debug off the console stays quiet except for errors and warnings.
