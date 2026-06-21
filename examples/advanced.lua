-- Nemesis advanced showcase: things Rayfield does not have.
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/siriusxcontact/Nemesis/main/examples/advanced.lua"))()

local Nemesis = loadstring(game:HttpGet("https://raw.githubusercontent.com/siriusxcontact/Nemesis/main/Nemesis.lua"))()

local Window = Nemesis:CreateWindow({
    Name = "Nemesis",
    Subtitle = "advanced demo",
    LoadingTitle = "Nemesis",
    LoadingSubtitle = "loading interface...",
    Keybind = Enum.KeyCode.RightShift,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "Nemesis/Advanced",
        FileName = "Config",
    },
})

Window:Watermark({
    Title = "Nemesis",
    ShowFPS = true,
    ShowPing = true,
    ShowTime = true,
})

local Home = Window:CreateTab("Home", "home")
Home:CreateSection("Welcome")
Home:CreateStat({ Icon = "sparkles", Name = "Status", Value = "Online", Trend = "stable" })
Home:CreateButton({
    Icon = "bell",
    Name = "Open prompt",
    Description = "Modal dialog with Yes/No.",
    Callback = function()
        Window:Prompt({
            Title = "Confirm",
            Content = "Apply preset and overwrite current theme?",
            Actions = {
                Yes = { Name = "Apply", Callback = function() Nemesis:UseTheme("Amethyst") end },
                No  = { Name = "Cancel", Callback = function() end },
            },
        })
    end,
})
Home:CreateButton({
    Icon = "search",
    Name = "Open command palette",
    Description = "Or press Ctrl+K anywhere.",
    Callback = function() Window:OpenPalette() end,
})

local Combat = Window:CreateTab("Combat", "sword")
Combat:CreateSection("Aim")
Combat:CreateToggle({ Icon = "target", Name = "Silent Aim", Flag = "SilentAim", Default = false })
Combat:CreateSlider({ Icon = "target", Name = "FOV", Flag = "FOV", Min = 0, Max = 360, Default = 180, Suffix = "°" })
Combat:CreateDropdown({ Icon = "user", Name = "Target Part", Options = { "Head", "Torso", "Random" }, CurrentOption = { "Head" }, Flag = "TargetPart" })
Combat:CreateKeybind({ Icon = "keyboard", Name = "Panic", CurrentKeybind = "P", HoldToInteract = false, Flag = "Panic" })

local Visual = Window:CreateTab("Visual", "eye")
Visual:CreateSection("Esp")
Visual:CreateToggle({ Icon = "eye", Name = "Box ESP", Flag = "BoxESP", Default = true })
Visual:CreateColorPicker({ Icon = "palette", Name = "Box Color", Color = Color3.fromRGB(46, 196, 132), Flag = "BoxColor" })

local Themes = Window:CreateTab("Themes", "palette")
Themes:CreateSection("Presets (try them)")
for _, name in ipairs(Nemesis:ListThemes()) do
    Themes:CreateButton({
        Icon = "diamond",
        Name = name,
        Callback = function() Nemesis:UseTheme(name) end,
    })
end

local Configs = Window:CreateTab("Configs", "folder")
Configs:CreateSection("Persistence")
Configs:CreateButton({
    Icon = "save",
    Name = "Save now",
    Callback = function()
        local ok = Nemesis:SaveConfiguration()
        Nemesis:Notify({ Title = ok and "Saved" or "Failed", Content = "Config written to disk.", Duration = 2 })
    end,
})
Configs:CreateButton({
    Icon = "load",
    Name = "Load now",
    Callback = function()
        local ok = Nemesis:LoadConfiguration()
        Nemesis:Notify({ Title = ok and "Loaded" or "Failed", Content = "Config applied.", Duration = 2 })
    end,
})

Nemesis:LoadConfiguration()
Nemesis:Notify({
    Title = "Nemesis",
    Content = "Press Ctrl+K to search every control.",
    Duration = 5,
    Image = 4483362458,
})
