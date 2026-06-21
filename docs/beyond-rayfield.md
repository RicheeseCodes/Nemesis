# Beyond Rayfield

Features Nemesis has that Rayfield does not.

## Command palette (Ctrl+K / Cmd+K)

Every Toggle, Slider, Button, Dropdown, Input, Keybind, and Colorpicker is indexed automatically. Press `Ctrl+K` (or tap the search icon in the header) to open a search overlay. Type any part of a name; pick a row to switch to its tab, flash the card, and fire the action.

```lua
Window:OpenPalette()
```

## Watermark HUD

A small draggable widget with FPS, ping, and time.

```lua
Window:Watermark({
    Title = "Nemesis",
    ShowFPS = true,
    ShowPing = true,
    ShowTime = true,
    Position = UDim2.new(0, 16, 0, 16),
})
```

Pass `false` to any of the show flags to hide that chip.

## Modal prompts

```lua
Window:Prompt({
    Title = "Confirm",
    Content = "Are you sure?",
    Actions = {
        Yes = { Name = "Yes", Callback = function() end },
        No  = { Name = "No",  Callback = function() end },
    },
})
```

## Theme presets

```lua
Nemesis:ListThemes()         -- { "Amethyst", "Citrus", "Crimson", "Default", "Mono", "Ocean" }
Nemesis:UseTheme("Amethyst") -- swap the whole palette
```

Presets are also exposed in the built-in settings flyout (gear icon in the header).

## Lucide-style icon names

Pass a name string instead of an `rbxassetid://...` and Nemesis maps common ones to glyphs.

```lua
Tab:CreateButton({ Icon = "home",     Name = "Home" })
Tab:CreateButton({ Icon = "settings", Name = "Settings" })
Tab:CreateButton({ Icon = "target",   Name = "Aim" })
```

Supported names include `home`, `settings`, `user`, `search`, `plus`, `minus`, `check`, `star`, `heart`, `play`, `pause`, `stop`, `arrow_right`, `arrow_left`, `arrow_up`, `arrow_down`, `eye`, `palette`, `sparkles`, `keyboard`, `target`, `folder`, `file`, `save`, `load`, `shield`, `sword`, `bolt`, `flame`, `bell`, `menu`, `grid`, `edit`. Unknown names render as text glyphs; explicit `rbxassetid://...` works too.

## Animated open

Window scales up from 96% and fades in. Set during `CreateWindow`; no opt-in needed.

## Active section indicator + tracking

Every element you create is tracked in `Window._index` so the palette and any future search-style feature can find it. Tabs remember the most recently created section so Rayfield-style `Tab:CreateButton(...)` after a `Tab:CreateSection("Group")` lands in the right group.

## Built-in settings flyout

Header gear icon opens a panel listing every theme preset. Picking one calls `UseTheme` immediately.

## Notify Actions

Toast notifications support inline action buttons.

```lua
Nemesis:Notify({
    Title = "Saved",
    Content = "Configuration written.",
    Duration = 6,
    Actions = {
        Undo = { Name = "Undo", Callback = function() Nemesis:LoadConfiguration() end },
    },
})
```
