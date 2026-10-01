# Getting started

## 1. Load the library
```lua
local Zeta = loadstring(game:HttpGet("https://raw.githubusercontent.com/ZETA-ORG/ZetaPro/main/src/init.luau"))()
```
In Studio use Rojo and `require` the `src` folder.

## 2. Create a window and a tab
```lua
local Window = Zeta:CreateWindow({ Title = "My UI", SubTitle = "V1", Theme = "Dark" })
local Main = Window:AddTab({ Title = "Main", Icon = "home" })
```

## 3. Add components
```lua
local Section = Main:AddSection("Movement")
Section:AddToggle("Fly", { Title = "Fly", Default = false, Callback = function(on) print(on) end })
Section:AddSlider("Speed", { Title = "Speed", Min = 16, Max = 250, Default = 16, Callback = print })
```
Components added to a Tab or a Section behave the same. The optional first argument is a unique id; with an id the component is available at `Window.Options[id]` and its value lives in `Zeta.Config`.

## 4. Read state, react to changes
```lua
local Fly = Window.Options.Fly
print(Fly:GetValue())
Fly:OnChanged(function(value) end)
Fly:SetValue(true)
```
Callbacks do not run at creation, only on value changes.

## 5. Clean up
```lua
Window:Destroy()   -- or Zeta:Unload() to remove everything
```

## Debugging
`Zeta:SetDebug(true)` enables verbose logs and full tracebacks for callback errors. With debug off the console stays quiet except for errors and warnings.
