# Nemesis

A UI library for Roblox executors. Mobile and desktop. Drop-in compatible with Rayfield, plus features Rayfield does not have.

![license](https://img.shields.io/badge/license-MIT-black)
![status](https://img.shields.io/badge/status-in_development-black)
![platform](https://img.shields.io/badge/platform-Roblox-black)

## Status

In development. Built with permission from Jenson (Rayfield owner). Accepts Rayfield scripts unchanged. Native API may change before v1.0.

## Beyond Rayfield

- **Command palette** — `Ctrl+K` opens a search overlay across every control in every tab. Pick one to jump and fire it.
- **Watermark HUD** — `Window:Watermark{...}` floats a draggable bar with FPS, ping, and time.
- **Theme presets** — `Nemesis:UseTheme("Amethyst")`. Six built-in, themable from the settings flyout.
- **Modal prompts** — `Window:Prompt{ Title, Content, Actions }` for confirmation dialogs.
- **Lucide icon names** — `Icon = "home"`, `"settings"`, `"target"` resolve to glyphs without asset IDs.
- **Animated open** — window scales and fades into view.
- **Notify actions** — toast notifications can attach action buttons.

Details: [docs/beyond-rayfield.md](docs/beyond-rayfield.md).

## Rayfield drop-in

Existing Rayfield scripts work as-is. Replace the loadstring URL with Nemesis and keep the rest of your code. Field mapping and limitations: [docs/rayfield.md](docs/rayfield.md).

```lua
local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/siriusxcontact/Nemesis/main/Nemesis.lua"))()

local Window = Rayfield:CreateWindow({ Name = "Example", ConfigurationSaving = { Enabled = true, FolderName = "Nemesis/Example", FileName = "Config" } })
local Tab = Window:CreateTab("Main", 4483362458)
Tab:CreateSection("Group")
Tab:CreateToggle({ Name = "On", CurrentValue = false, Flag = "Toggle1", Callback = function(v) end })
Tab:CreateSlider({ Name = "Speed", Range = { 0, 100 }, Increment = 5, CurrentValue = 50, Flag = "Speed", Callback = function(v) end })
Rayfield:LoadConfiguration()
```

## Install

```lua
local Nemesis = loadstring(game:HttpGet("https://raw.githubusercontent.com/siriusxcontact/Nemesis/main/Nemesis.lua"))()
```

## Quick start

```lua
local Window = Nemesis:CreateWindow({
    Name = "Example",
    Subtitle = "v0.3",
    Keybind = Enum.KeyCode.RightShift,
})

local Tab = Window:CreateTab({ Name = "Main" })
local Section = Tab:CreateSection({ Name = "Gameplay" })

Section:CreateToggle({
    Name = "Auto Sprint",
    Flag = "AutoSprint",
    Default = true,
    Callback = function(state) end,
})

Section:CreateSlider({
    Name = "Walk Speed",
    Min = 16, Max = 200, Default = 16,
    Callback = function(v) end,
})
```

## Examples

| File | What it shows |
|------|---------------|
| [examples/basic.lua](examples/basic.lua)       | Smallest working window |
| [examples/full.lua](examples/full.lua)         | Every element, configs, multi-select dropdown |
| [examples/theming.lua](examples/theming.lua)   | Custom theme override |
| [examples/rayfield.lua](examples/rayfield.lua) | Rayfield-compatible script |
| [examples/advanced.lua](examples/advanced.lua) | Palette, watermark, prompts, loading splash, presets |
| [examples/showcase.lua](examples/showcase.lua) | Every element + every advanced feature, one script |

Run any of them directly:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/siriusxcontact/Nemesis/main/examples/full.lua"))()
```

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
| Stat        | `Section:CreateStat`    |
| Label       | `Section:CreateLabel`   |
| Paragraph   | `Section:CreateParagraph` |
| Notify      | `Nemesis:Notify`        |

Every element accepts optional `Icon` (unicode glyph or `rbxassetid://...`), `Description` (muted helper text below the row), and `Flag` (unique key for save/load).

Full reference: [docs/components.md](docs/components.md).

## Mobile

Touch devices get a phone-friendly width, an iOS-style handle indicator, and a round draggable toggle button at the top-left. Every element responds to touch input the same way it responds to mouse.

## Desktop

Drag the header to move. Drag the grip at the bottom-right corner to resize. Press the configured keybind to hide and show.

## Theming

```lua
Nemesis:SetTheme({
    Accent = Color3.fromRGB(138, 92, 246),
})
```

The header gear opens a built-in theme preset picker.

## Configs

```lua
Nemesis:SetConfigFolder("Nemesis/MyScript")
Nemesis:SaveConfig("default")
Nemesis:LoadConfig("default")
```

Every element with a `Flag` is captured. Requires executor functions `writefile`, `readfile`, `isfile`, `listfiles`, `makefolder`, `isfolder`.

## License

MIT. See [LICENSE](LICENSE).
