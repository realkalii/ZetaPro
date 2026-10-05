# Icons

ZetaPro supports a few different ways to use icons:

``` lua
Icon = "home"
Icon = Zeta.Icons.Home
Icon = "solar:bomb"
Icon = "geist:code"
Icon = { Type = "Image", Source = "rbxassetid://...", Tint = true }
Icon = { Type = "Url", Source = "https://.../icon.png", Tint = true }
```

# Simple icons

Names like ""home"", ""search"" or ""settings"" use the built-in "icons.rest" (https://www.icons.rest/) catalog. It contains Lucide icons mapped to Roblox asset IDs, so you don't need to download or set anything up yourself.

If the name doesn't exist in the catalog, ZetaPro won't try to replace it with a different icon. The icon simply stays hidden, and a warning is printed once in the console.

You can also access the catalog directly:

``` lua
Zeta.Icons:Get("home")
Zeta.Icons:List()
```

"Get()" returns the icon specification when the icon exists, or "nil" when it doesn't. "List()" returns the available icons.rest names.

Icon Families

For icons from a specific family, use the "family:name" format:

Icon = "lucide:heart"
Icon = "solar:bomb"
Icon = "geist:code"

ZetaPro currently supports:

- "lucide"
- "solar"
- "geist"
- "craft"
- "sfsymbols"

These families are provided by "Footagesus/Icons" (https://github.com/Footagesus/Icons)

Family data is downloaded only when needed and then cached locally in:

ZetaPro/icons/<family>.lua

If the family hasn't loaded yet, its icons stay hidden. Once the data is ready, the icons appear automatically. If a requested icon doesn't exist in that family, it is treated as invalid.

You can delete the cached family file at any time to download a fresh copy.

Solar Variants

Solar icons have several variants, including:

-linear
-outline
-bold
-broken
-line-duotone
-bold-duotone

Not every Solar icon has every variant.

If you use:

Icon = "solar:bomb"

ZetaPro looks for the available variants in this order:

linear → outline → bold → broken → line-duotone → bold-duotone

You can also request a specific variant:

Icon = "solar:bomb-bold-duotone"

Custom Providers

You can register your own icon provider when you need custom icons:
``` lua
Zeta:RegisterIconProvider("Mine", function(name)
    return {
        Type = "Image",
        Source = "rbxassetid://..."
    }
end)
```
Zeta:SetIconProvider("Mine")

The custom provider gets the complete icon name first. If it doesn't recognize the name and returns "nil", ZetaPro continues looking through the family resolver and then the icons.rest catalog.

This makes it possible to add your own icons without changing the built-in catalog.

# Remote Icons

Remote images are supported, but they're intentionally opt-in.
``` lua
Icon = {
    Type = "Url",
    Source = "https://.../icon.png",
    Tint = true
}
```
Remote icons require "Http", "FileSystem" and "getcustomasset".

Only HTTPS PNG files up to 256 KB are accepted. Images are cached in "ZetaPro/icons/" so they don't need to be downloaded every time.

While a remote icon is loading, it stays empty. If the download fails for any reason, the icon is simply hidden instead of interrupting the rest of the UI.

# Changing Icons

Icons can be changed at runtime without recreating the component:
``` lua
Tab:SetIcon("x")
Component:SetIcon("check")
Component:SetIcon(nil)
```
This only updates the icon element, leaving the rest of the component untouched.
