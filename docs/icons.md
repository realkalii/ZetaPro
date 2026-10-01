# Icons

```lua
Icon = "home"                                   -- name
Icon = Zeta.Icons.Home                          -- same thing, via the registry
Icon = { Type = "Image", Source = "rbxassetid://...", Tint = true }
Icon = { Type = "Url", Source = "https://.../icon.png", Tint = true }
```

`Zeta.Icons:Get(name)` returns an icon spec (or nil). `Zeta.Icons:List()` lists the built-in names:
`home, settings, search, user, shield, code, terminal, folder, trash, plus, minus, check, x, info, alert, alert-circle, check-circle, chevron-down, chevron-up, chevron-right, copy, eye, keyboard, bell, zap, lock, menu, grip, play, crosshair, help`.

## Origin and license
Built-in icons are original Lucide-*style* line drawings (24x24 grid) rendered with Frames. No SVG data or assets from Lucide/Feather are included (see `THIRD_PARTY.md`).

## Providers
```lua
Zeta:RegisterIconProvider("Mine", function(name) return { Type = "Image", Source = "rbxassetid://..." } end)
Zeta:SetIconProvider("Mine")    -- unresolved names fall back to the built-in set
```

## Remote icons
`Type = "Url"` is opt-in. It requires `Http`, `FileSystem` and `getcustomasset`, accepts only https PNG files up to 256 KB, caches them in `ZetaPro/icons/`, and never blocks or breaks the UI: while loading, or if anything fails, a fallback dot is shown.

## Hot swap
`Tab:SetIcon("x")`, `Component:SetIcon("check")`, `Component:SetIcon(nil)` update only the icon element.
