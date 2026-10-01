# Tabs and sections

```lua
local Tab = Window:AddTab({ Title = "Main", Icon = "home" })
local Section = Tab:AddSection("Combat")
```

| Method | Description |
|---|---|
| `Tab:Select()` / `Tab:Deselect()` | Selection |
| `Tab:SetTitle(text)` / `Tab:SetIcon(icon)` | Update the tab button |
| `Tab:AddSection(title)` | Returns a Section |
| `Tab:Add<Component>(...)` | `AddButton`, `AddToggle`, `AddSlider`, `AddDropdown`, `AddMultiDropdown`, `AddInput`, `AddKeybind`, `AddColorpicker`, `AddParagraph`, `AddLabel`, `AddDivider` and any registered component |
| `Tab:Destroy()` | Removes the tab, its components and search entries |
| `Section:SetTitle(text)` / `Section:SetVisible(bool)` / `Section:Destroy()` | Section control |

Layout, `CanvasSize`, padding and scrolling are automatic: you never position components manually. Components use `Add<Name>([id], config)`; the id is optional.
