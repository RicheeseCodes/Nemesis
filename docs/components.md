# Components

Every element accepts an optional `Icon` (unicode glyph or `rbxassetid://...`), `Description` (muted helper text below the row), and `Flag` (unique key for config save/load and `Nemesis:GetFlag()`). Interactive elements return an object exposing `:Set(value)` and `:Get()`; some also expose `:Refresh`, `:SetTrend`, `:SetTitle`.

## Window

```lua
local Window = Nemesis:CreateWindow({
    Name = "Example",          -- header title
    Subtitle = "v1",           -- muted subtitle under the title
    Keybind = Enum.KeyCode.RightShift, -- toggles window visibility
    MobileButton = true,       -- forces the round mobile toggle even on desktop
})
```

Window methods:
- `Window:CreateTab({ Name, Icon })`
- `Window:Destroy()`

## Tab

```lua
local Tab = Window:CreateTab({ Name = "Main", Icon = "\u{2302}" })
```

Tabs appear in a horizontal scroll bar under the header. The first tab is activated automatically.

## Section

```lua
local Section = Tab:CreateSection({ Name = "Gameplay" })
```

A section adds a muted label and groups all elements created on it.

## Button

```lua
Section:CreateButton({
    Name = "Run",
    Icon = "\u{2192}",
    Description = "Optional helper text.",
    Callback = function() end,
})
```

## Toggle

```lua
Section:CreateToggle({
    Name = "Auto Sprint",
    Icon = "\u{226B}",
    Flag = "AutoSprint",
    Default = false,
    Callback = function(state) end,
})
```

## Slider

```lua
Section:CreateSlider({
    Name = "Walk Speed",
    Flag = "WalkSpeed",
    Min = 16, Max = 200, Default = 16,
    Decimals = 0,              -- 0 for integers, 1 for tenths, ...
    Prefix = "",
    Suffix = " s/s",
    Callback = function(value) end,
})
```

## Dropdown

```lua
Section:CreateDropdown({
    Name = "Mode",
    Flag = "Mode",
    Options = { "Casual", "Ranked", "Custom" },
    Default = "Casual",
    Callback = function(value) end,
})
```

Multi select uses `Multi = true` and an array `Default`:

```lua
Section:CreateDropdown({
    Name = "Targets",
    Multi = true,
    Options = { "Players", "NPCs", "Bosses" },
    Default = { "Players" },
    Callback = function(values) end,
})
```

Refresh options dynamically: `dropdown:Refresh(newOptions, newDefault)`.

## Input

```lua
Section:CreateInput({
    Name = "Tag",
    Flag = "Tag",
    Placeholder = "your name",
    Default = "",
    Callback = function(text, enterPressed) end,
})
```

## Keybind

```lua
Section:CreateKeybind({
    Name = "Panic Key",
    Flag = "PanicKey",
    Default = Enum.KeyCode.P,
    Callback = function(key) end,
})
```

Tap the chip to rebind; press any key to set.

## Colorpicker

```lua
Section:CreateColorpicker({
    Name = "Accent",
    Flag = "Accent",
    Default = Color3.fromRGB(46, 196, 132),
    Callback = function(color) end,
})
```

## Stat

A highlighted accent card with name, icon, value, and trend.

```lua
local stat = Section:CreateStat({
    Name = "Players",
    Icon = "\u{2605}",
    Value = "12",
    Trend = "+2",
})
stat:Set("13")
stat:SetTrend("+1")
```

## Label and Paragraph

```lua
Section:CreateLabel({ Text = "Short muted text." })

Section:CreateParagraph({
    Title = "About",
    Text = "Longer body text inside a surface card.",
})
```

## Notifications

```lua
Nemesis:Notify({ Title = "Saved", Text = "Configuration written.", Duration = 3 })
```

## Theming

```lua
Nemesis:SetTheme({
    Accent = Color3.fromRGB(138, 92, 246),
})
```

Theme keys: `Background`, `Surface`, `Surface2`, `Border`, `Accent`, `AccentDim`, `Text`, `Muted`, `Soft`, `Danger`.

## Configs

Every element with a `Flag` is captured by save/load.

```lua
Nemesis:SetConfigFolder("Nemesis/MyScript")
Nemesis:SaveConfig("default")        -- writes default.json
Nemesis:LoadConfig("default")        -- restores values and fires callbacks
Nemesis:ListConfigs()                -- { "default", ... }
```

Requires executor functions `writefile`, `readfile`, `isfile`, `listfiles`, `makefolder`, `isfolder`. Missing functions degrade gracefully.

## Flags at runtime

```lua
local speed = Nemesis:GetFlag("WalkSpeed")
```
