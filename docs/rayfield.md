# Rayfield compatibility

Nemesis runs Rayfield scripts unchanged. Replace the `loadstring` URL with Nemesis and your existing Rayfield script keeps working.

```lua
local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/siriusxcontact/Nemesis/main/Nemesis.lua"))()

local Window = Rayfield:CreateWindow({
    Name = "Rayfield Example",
    LoadingTitle = "Rayfield Interface Suite",
    LoadingSubtitle = "by Sirius",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "Nemesis/Example",
        FileName = "BigHub",
    },
    KeySystem = false,
})

local Tab = Window:CreateTab("Main", 4483362458)

Tab:CreateSection("Buttons")
Tab:CreateButton({ Name = "Click", Callback = function() end })
Tab:CreateToggle({ Name = "On", CurrentValue = false, Flag = "Toggle1", Callback = function() end })
Tab:CreateSlider({ Name = "Speed", Range = { 0, 100 }, Increment = 5, CurrentValue = 50, Flag = "Speed", Callback = function() end })
Tab:CreateDropdown({ Name = "Mode", Options = { "A", "B" }, CurrentOption = { "A" }, Flag = "Mode", Callback = function() end })
Tab:CreateInput({ Name = "Tag", PlaceholderText = "name", Flag = "Tag", Callback = function() end })
Tab:CreateKeybind({ Name = "Bind", CurrentKeybind = "Q", Flag = "Bind", Callback = function() end })
Tab:CreateColorPicker({ Name = "Color", Color = Color3.new(1,1,1), Flag = "Col", Callback = function() end })
Tab:CreateLabel("Static label")
Tab:CreateParagraph({ Title = "About", Content = "Body text" })

Rayfield:Notify({ Title = "Hi", Content = "Notification body", Duration = 3, Image = 4483362458 })
Rayfield:LoadConfiguration()
```

## What is mapped

| Rayfield                    | Nemesis                       |
|-----------------------------|-------------------------------|
| `Window:CreateTab(name, id)`| also accepts `{ Name, Icon }` |
| `Tab:CreateSection("name")` | also accepts `{ Name }`       |
| `CurrentValue`              | `Default`                     |
| `Range = {min, max}`        | `Min`, `Max`                  |
| `Increment`                 | `Step`                        |
| `PlaceholderText`           | `Placeholder`                 |
| `RemoveTextAfterFocusLost`  | clears input on focus lost    |
| `CurrentOption = {arr}`     | `Default` (multi or single)   |
| `MultipleOptions = true`    | `Multi = true`                |
| `CurrentKeybind = "Q"`      | `Default = Enum.KeyCode.Q`    |
| `HoldToInteract = true`     | callback fires on press and release |
| `Color`                     | `Default` for ColorPicker     |
| `Content` (Paragraph/Notify)| `Text`                        |
| `Image` (Notify) number     | `rbxassetid://N`              |
| `ConfigurationSaving`       | folder + file + autosave      |
| `Rayfield:LoadConfiguration()` | restores saved flags       |
| `Rayfield:SaveConfiguration()` | writes current flags       |

## Not implemented

- `LoadingTitle` / `LoadingSubtitle`: the loading screen is skipped. Values are accepted but ignored.
- `KeySystem` / `KeySettings`: passed through with no enforcement. Add your own gate before `CreateWindow` if you need one.
- `Discord` invite popup: ignored.

## Mixing APIs

You can keep using the Nemesis-native style on the same window. `Tab:CreateSection({ Name = "x" })` returns a Section object so you can call `Section:CreateButton(...)` on it directly. Tab-level calls go to the most recently created section.
