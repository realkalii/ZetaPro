# Icons

```lua
Icon = "home"
Icon = Zeta.Icons.Home
Icon = "solar:bomb"
Icon = "geist:code"
Icon = { Type = "Image", Source = "rbxassetid://...", Tint = true }
Icon = { Type = "Url", Source = "https://.../icon.png", Tint = true }
```

Plain names such as `"home"` keep working as before and now use the real Lucide icons. The hand-drawn local set is only a fallback when Lucide cannot be loaded, and any Lucide name also works without a prefix. `Zeta.Icons:Get(name)` returns an icon spec (or nil) and `Zeta.Icons:List()` lists the built-in names without a family prefix.

## Families

`family:name` loads the real icon from that family: `lucide`, `solar`, `geist`, `craft` and `sfsymbols`. The families are provided by [Footagesus/Icons](https://github.com/Footagesus/Icons) (MIT License, Copyright (c) 2025 Footages).

Each family is downloaded once, in the background, and cached in `ZetaPro/icons/<family>.lua`. Delete that file to refresh it. While a family loads, or if it cannot be loaded, a built-in placeholder is shown when one exists, and it is replaced by the real icon as soon as it is ready. Only names that exist in a family resolve: a name the family does not have shows a small fallback dot.

## Solar variants

Solar names end with a variant: `-linear`, `-outline`, `-bold`, `-broken`, `-line-duotone`, `-bold-duotone`. Not every icon has all of them. `solar:bomb` picks the first variant that exists, in that order, and `solar:bomb-bold-duotone` asks for one explicitly.

## Providers

```lua
Zeta:RegisterIconProvider("Mine", function(name) return { Type = "Image", Source = "rbxassetid://..." } end)
Zeta:SetIconProvider("Mine")
```

The active provider receives the full name first. If it returns `nil`, the family resolver and then the built-in set are tried.

## Remote icons

`Type = "Url"` is opt-in. It requires `Http`, `FileSystem` and `getcustomasset`, accepts only https PNG files up to 256 KB, caches them in `ZetaPro/icons/`, and never blocks or breaks the UI: while loading, or if anything fails, a fallback dot is shown.

## Hot swap

`Tab:SetIcon("x")`, `Component:SetIcon("check")`, `Component:SetIcon(nil)` update only the icon element.
