# Nemesis

A UI library for Roblox executors. Mobile and desktop.

![license](https://img.shields.io/badge/license-MIT-black)
![status](https://img.shields.io/badge/status-in_development-black)
![platform](https://img.shields.io/badge/platform-Roblox-black)

## Status

In development. The first build is up and usable. API may change before v1.0.

## Install

```lua
local Nemesis = loadstring(game:HttpGet("https://raw.githubusercontent.com/siriusxcontact/Nemesis/main/Nemesis.lua"))()
```

## Quick start

```lua
local Window = Nemesis:CreateWindow({
    Name = "Nemesis",
    Subtitle = "v0.1",
    Keybind = Enum.KeyCode.RightShift,
})

local Tab = Window:CreateTab({ Name = "Main" })
local Section = Tab:CreateSection({ Name = "Combat", Side = "Left" })

Section:CreateToggle({
    Name = "Auto Parry",
    Flag = "AutoParry",
    Default = false,
    Callback = function(state) end,
})

Section:CreateSlider({
    Name = "Reach",
    Min = 1, Max = 20, Default = 8,
    Callback = function(value) end,
})
```

A full example lives in [example.lua](example.lua).

## Elements

| Element     | Method                  |
|-------------|-------------------------|
| Window      | `Nemesis:CreateWindow`  |
| Tab         | `Window:CreateTab`      |
| Section     | `Tab:CreateSection`     |
| Button      | `Section:CreateButton`  |
| Toggle      | `Section:CreateToggle`  |
| Slider      | `Section:CreateSlider`  |
| Dropdown    | `Section:CreateDropdown`|
| Input       | `Section:CreateInput`   |
| Keybind     | `Section:CreateKeybind` |
| Colorpicker | `Section:CreateColorpicker` |
| Label       | `Section:CreateLabel`   |
| Paragraph   | `Section:CreateParagraph` |
| Stat        | `Section:CreateStat`    |
| Notify      | `Nemesis:Notify`        |

Every interactive element returns an object with `:Set(value)` and `:Get()`. Every element accepts an optional `Icon` (unicode glyph or `rbxassetid://...`) and `Description` (muted helper text beneath the row).

## Mobile

On touch devices the window opens at a phone-friendly width and shows a draggable round toggle button. All elements respond to touch input the same way they respond to mouse input.

## Theming

```lua
Nemesis:SetTheme({
    Accent = Color3.fromRGB(138, 92, 246),
    Background = Color3.fromRGB(16, 16, 20),
    Surface = Color3.fromRGB(22, 22, 28),
    Text = Color3.fromRGB(235, 235, 240),
})
```

## License

MIT.
