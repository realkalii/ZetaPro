# Icons

ZETA Pro uses built-in Lucide icon names from [icons.rest](https://www.icons.rest/). External icon family prefixes are no longer supported.

```lua
Window:AddTab({ Title = "Main", Icon = "home" })
Section:AddButton({ Title = "Run", Icon = Zeta.Icons.Home })
```

## Recommended icons for script hubs

The following are suggestions, not predefined categories. Names can be used directly in the `Icon` property.

| Category | Lucide names |
|---|---|
| Main / Home | `home`, `layout-dashboard`, `panels-top-left`, `layout-grid` |
| Auto Farm | `wheat`, `sprout`, `repeat`, `coins` |
| Combat / PvP | `swords`, `crosshair`, `target`, `shield` |
| Player | `user-round`, `users`, `activity`, `heart` |
| Movement / Fly | `zap`, `move`, `wind`, `plane` |
| ESP / Visuals | `eye`, `scan-eye`, `scan`, `focus` |
| Teleport | `map-pin`, `navigation`, `map`, `compass` |
| Inventory | `backpack`, `package`, `gem`, `box` |
| Scripts / Tools | `code`, `terminal`, `wrench`, `file-code` |
| Settings | `settings`, `sliders-horizontal`, `cog`, `sliders` |

## `Zeta.Icons:Get()`

```lua
local Icon = Zeta.Icons:Get("home")
if Icon then
    print(Icon.Type)
end
```

Returns a resolved icon specification or `nil` when the name cannot be resolved. Valid names include `"home"` and `"settings"`.

## `Zeta.Icons:List()`

```lua
local Icons = Zeta.Icons:List()
print("Available icons:", #Icons)
for _, name in ipairs(Icons) do
    print(name)
end
```

Returns built-in Lucide names, sorted alphabetically.

## Custom providers

```lua
Zeta:RegisterIconProvider("Mine", function(name)
    if name == "logo" then
        return { Type = "Image", Source = "rbxassetid://123", Tint = true }
    end
    return nil
end)
Zeta:SetIconProvider("Mine")
```

The active custom provider is tried first; if it returns `nil`, ZETA Pro checks the built-in Lucide catalog.

## Image icons

```lua
Section:AddButton({
    Title = "Custom Icon",
    Icon = { Type = "Image", Source = "rbxassetid://123", Tint = false },
    Callback = function() print("Button clicked") end,
})
```

`Tint = true` uses the current theme color. `Tint = false` keeps the original image colors. Replace `123` with a valid Roblox asset ID.

## Remote icons

```lua
Section:AddButton({
    Title = "Remote Icon",
    Icon = { Type = "Url", Source = "https://example.com/icon.png", Tint = false },
    Callback = function() print("Button clicked") end,
})
```

The example URL is a placeholder. Only HTTPS PNG files up to 256 KB are accepted. HTTP access, filesystem access, and `getcustomasset` (or supported equivalent) are required. Successful images are cached in `ZetaPro/icons/`, and failed images use a built-in fallback icon.

## Hot swap

```lua
Tab:SetIcon("settings")
Component:SetIcon("check")
Component:SetIcon("circle-check")
Component:SetIcon(nil)
```

`SetIcon()` updates existing icons in place without recreating the component.

## Credits and compatibility

ZETA Pro uses Lucide icons through [icons.rest](https://www.icons.rest/), which maps names to Roblox asset IDs. Lucide icons are licensed under the ISC License; see [Lucide](https://github.com/lucide-icons/lucide) for licensing details.

Existing plain Lucide names remain supported. Old prefixed names such as `solar:`, `geist:`, `craft:`, and `sfsymbols:` must be replaced with Lucide names. Custom image icons and registered providers remain supported.
