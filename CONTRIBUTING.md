# Contributing to ZETA Pro

Thanks for helping. A few rules keep the library small and consistent.

## Workflow
1. Fork and create a branch (`feature/short-name`).
2. Make focused changes; one concern per pull request.
3. Run `examples/tests.luau` in Studio or an executor and include the result.
4. Open a pull request describing what changed and why.

## Architecture rules
- Every module is `return function(import) ... end`. Resolve dependencies with `import("Folder/Module")` only, and avoid circular imports.
- Colors come from the Theme engine (`Theme.Get`, `Widgets.Surface`, `Theme.BindFn`). Never hardcode colors in components.
- All tweens go through `Services/Animation`. All keyboard/mouse tracking goes through `Services/Input` and `Services/Drag`.
- Everything created by a component must be registered in its `Cleanup`. After `Destroy()` no connection, tween, thread or callback may remain.
- Prefer events over polling. No `RenderStepped` unless unavoidable (and then only while needed).
- Public API stays consistent: `SetValue / GetValue / OnChanged / SetTitle / SetDescription / SetIcon / SetVisible / SetEnabled / Destroy`.
- No third-party code without a compatible license and an entry in `THIRD_PARTY.md`.
- Errors must be actionable: use `Utility.Check` / `Utility.Fail`.

## Style
Tabs for indentation, `PascalCase` for public members, `camelCase` for locals. Keep files small; split by responsibility.

## Adding a component
Create `src/Components/YourComponent.luau`, return a factory `(ctx, id, config) -> component`, build it on `Component.New` and `Component.BindValue`, add it to `MODULES` in `init.luau`, then document it in `docs/`. Third parties can use `Zeta:RegisterComponent("Name", factory)` without touching the library.
