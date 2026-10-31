# Tabs and sections

```lua
local Tab = Window:AddTab({ Title = "Main", Icon = "home" })
local Section = Tab:AddSection("Interface", { Collapsible = true, DefaultExpanded = true })
```

Every window also has an automatic Home tab. `Window:SelectTab("Home")` returns to it.

| Method | Description |
|---|---|
| `Tab:Select()` / `Tab:Deselect()` | Selection |
| `Tab:SetTitle(text)` / `Tab:SetIcon(icon)` | Update the tab button |
| `Tab:AddSection(title, options?)` | Returns a Section; options are `Collapsible` and `DefaultExpanded` |
| `Tab:Add<Component>(...)` | `AddButton`, `AddToggle`, `AddSlider`, `AddDropdown`, `AddMultiDropdown`, `AddInput`, `AddKeybind`, `AddColorpicker`, `AddParagraph`, `AddLabel`, `AddDivider` and any registered component |
| `Tab:Destroy()` | Removes the tab, its components and search entries |
| `Section:SetTitle(text)` / `Section:SetVisible(bool)` / `Section:Destroy()` | Section control |
| `Section:IsExpanded()` / `Expand()` / `Collapse()` / `Toggle()` | Collapsible section control |

Layout, `CanvasSize`, padding and scrolling are automatic: you never position components manually. Components use `Add<Name>([id], config)`; the id is optional.
