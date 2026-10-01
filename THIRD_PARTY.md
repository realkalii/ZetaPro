# Third-party notices

ZETA Pro V1.0 is released under the MIT License (see `LICENSE`) and **does not bundle third-party source code, fonts or image assets.**

## Design references (no code copied)
- **Fluent** (`dawid-scripts/Fluent`) was used only as an inspiration for UX, component set and API shape (window, tabs, sections, components, notifications, themes). No source was copied; ZETA Pro is an independent implementation with its own architecture. If you intend to reuse any Fluent code, check its license first.
- **Lucide / Feather** inspired the *style* of the built-in icons (24x24 grid, round-capped strokes). The icon geometry in `src/Icons/Providers.luau` was drawn from scratch as simple line and circle primitives and rendered with Roblox Frames. No Lucide/Feather SVG data is included. If you add icons derived from Lucide (ISC License) or Feather (MIT License), include their copyright notice here.

## Fonts
- The UI uses Roblox's built-in `Gotham` family through `Enum.Font` / `Font`. No font files are distributed.

## Runtime network access
- The library makes **no network requests** while running, except when you explicitly use an `Icon = { Type = "Url" }` icon (https only, PNG only, size-limited, cached under `ZetaPro/icons/`), or when the executor loader downloads the library's own modules from the repository.
