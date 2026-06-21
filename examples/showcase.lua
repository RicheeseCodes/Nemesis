-- Nemesis showcase: every element, every advanced feature, in one script.
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/siriusxcontact/Nemesis/main/examples/showcase.lua"))()

local Nemesis = loadstring(game:HttpGet("https://raw.githubusercontent.com/siriusxcontact/Nemesis/main/Nemesis.lua"))()

local Window = Nemesis:CreateWindow({
    Name = "Nemesis",
    Subtitle = "showcase",
    LoadingTitle = "Nemesis",
    LoadingSubtitle = "loading interface...",
    Keybind = Enum.KeyCode.RightShift,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "Nemesis/Showcase",
        FileName = "Config",
    },
})

Window:Watermark({
    Title = "Nemesis",
    ShowFPS = true,
    ShowPing = true,
    ShowTime = true,
})

------------------------------------------------------------
-- Tab 1: Home
------------------------------------------------------------
local Home = Window:CreateTab("Home", "home")

Home:CreateSection("Welcome")
Home:CreateStat({ Icon = "sparkles", Name = "Status",  Value = "Online",   Trend = "stable" })
Home:CreateStat({ Icon = "star",     Name = "Players", Value = "12",       Trend = "+2"    })
Home:CreateParagraph({
    Title = "What this is",
    Text  = "This window demonstrates every element Nemesis ships, plus the advanced features Rayfield does not have. Press Ctrl+K anywhere to open the command palette.",
})

Home:CreateSection("Try the extras")
Home:CreateButton({
    Icon = "search",
    Name = "Open command palette",
    Description = "Or press Ctrl+K / Cmd+K anywhere.",
    Callback = function() Window:OpenPalette() end,
})
Home:CreateButton({
    Icon = "bell",
    Name = "Open prompt",
    Description = "Modal dialog with two actions.",
    Callback = function()
        Window:Prompt({
            Title   = "Confirm",
            Content = "Switch to the Amethyst theme?",
            Actions = {
                Yes = { Name = "Apply",  Callback = function() Nemesis:UseTheme("Amethyst") end },
                No  = { Name = "Cancel", Callback = function() end },
            },
        })
    end,
})
Home:CreateButton({
    Icon = "flame",
    Name = "Send notification",
    Callback = function()
        Nemesis:Notify({
            Title    = "Notification",
            Content  = "This toast has an action button.",
            Duration = 6,
            Image    = 4483362458,
            Actions  = { Undo = { Name = "Undo", Callback = function() end } },
        })
    end,
})

------------------------------------------------------------
-- Tab 2: Controls (every input element)
------------------------------------------------------------
local Controls = Window:CreateTab("Controls", "settings")

Controls:CreateSection("Toggles")
Controls:CreateToggle({
    Icon = "check", Name = "Simple toggle",
    Flag = "Demo_Toggle1", Default = false,
    Callback = function(v) print("Toggle1:", v) end,
})
Controls:CreateToggle({
    Icon = "shield", Name = "Toggle with description",
    Flag = "Demo_Toggle2", Default = true,
    Description = "Optional muted helper text that wraps onto multiple lines if needed.",
    Callback = function(v) print("Toggle2:", v) end,
})

Controls:CreateSection("Sliders")
Controls:CreateSlider({
    Icon = "bolt", Name = "Walk Speed",
    Flag = "Demo_Speed",
    Min = 16, Max = 200, Default = 16, Suffix = " s/s",
    Callback = function(v)
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            char:FindFirstChildOfClass("Humanoid").WalkSpeed = v
        end
    end,
})
Controls:CreateSlider({
    Icon = "target", Name = "FOV",
    Range = { 0, 360 }, Increment = 5, CurrentValue = 180, Suffix = "°",
    Flag = "Demo_FOV",
    Callback = function(v) print("FOV:", v) end,
})

Controls:CreateSection("Dropdowns")
Controls:CreateDropdown({
    Icon = "menu", Name = "Mode (single)",
    Options = { "Casual", "Ranked", "Custom" },
    Default = "Casual",
    Flag = "Demo_Mode",
    Callback = function(v) print("Mode:", v) end,
})
Controls:CreateDropdown({
    Icon = "grid", Name = "Targets (multi)",
    Options = { "Players", "NPCs", "Bosses", "Allies" },
    Multi = true, Default = { "Players", "NPCs" },
    Flag = "Demo_Targets",
    Callback = function(v) print("Targets:", v) end,
})

Controls:CreateSection("Text & keys")
Controls:CreateInput({
    Icon = "edit", Name = "Tag",
    Placeholder = "your name",
    Flag = "Demo_Tag",
    Callback = function(t) print("Tag:", t) end,
})
Controls:CreateInput({
    Icon = "edit", Name = "Chat (clears after send)",
    Placeholder = "type and press enter",
    RemoveTextAfterFocusLost = true,
    Callback = function(t, enter) if enter then print("Sent:", t) end end,
})
Controls:CreateKeybind({
    Icon = "keyboard", Name = "Panic Key",
    Default = Enum.KeyCode.P,
    Flag = "Demo_Panic",
    Callback = function(k) print("Panic:", k.Name) end,
})
Controls:CreateKeybind({
    Icon = "keyboard", Name = "Hold to sprint",
    CurrentKeybind = "LeftShift", HoldToInteract = true,
    Flag = "Demo_Sprint",
    Callback = function(_, held) print("Sprint held:", held) end,
})

Controls:CreateSection("Color")
Controls:CreateColorPicker({
    Icon = "palette", Name = "Accent",
    Color = Color3.fromRGB(46, 196, 132),
    Flag = "Demo_Accent",
    Callback = function(c) Nemesis:SetTheme({ Accent = c }) end,
})

------------------------------------------------------------
-- Tab 3: Visual
------------------------------------------------------------
local Visual = Window:CreateTab("Visual", "eye")

Visual:CreateSection("Stat cards")
Visual:CreateStat({ Icon = "star", Name = "Score",  Value = "1,284", Trend = "+128" })
Visual:CreateStat({ Icon = "bolt", Name = "Streak", Value = "7",     Trend = "best" })

Visual:CreateSection("Text blocks")
Visual:CreateLabel("Plain muted label, single line.")
Visual:CreateParagraph({
    Title = "Paragraph card",
    Text  = "Use Paragraph for blocks of text inside a card. Wraps onto multiple lines automatically.",
})

------------------------------------------------------------
-- Tab 4: Themes
------------------------------------------------------------
local Themes = Window:CreateTab("Themes", "palette")
Themes:CreateSection("Built-in presets")
for _, name in ipairs(Nemesis:ListThemes()) do
    Themes:CreateButton({
        Icon = "diamond",
        Name = name,
        Callback = function()
            Nemesis:UseTheme(name)
            Nemesis:Notify({ Title = "Theme", Content = name.." applied", Duration = 2 })
        end,
    })
end

------------------------------------------------------------
-- Tab 5: Configs
------------------------------------------------------------
local Configs = Window:CreateTab("Configs", "folder")
Configs:CreateSection("Persistence")
Configs:CreateParagraph({
    Title = "How it works",
    Text  = "Every element with a Flag is captured automatically. Changes autosave to disk after a short debounce. Manual save / load also available.",
})
Configs:CreateButton({
    Icon = "save", Name = "Save now",
    Callback = function()
        local ok, err = Nemesis:SaveConfiguration()
        Nemesis:Notify({
            Title    = ok and "Saved" or "Save failed",
            Content  = ok and "Written to disk." or tostring(err),
            Duration = 3,
        })
    end,
})
Configs:CreateButton({
    Icon = "load", Name = "Load saved",
    Callback = function()
        local ok, err = Nemesis:LoadConfiguration()
        Nemesis:Notify({
            Title    = ok and "Loaded" or "Load failed",
            Content  = ok and "Applied to controls." or tostring(err),
            Duration = 3,
        })
    end,
})

------------------------------------------------------------
-- Restore previous session + welcome toast
------------------------------------------------------------
Nemesis:LoadConfiguration()

Nemesis:Notify({
    Title    = "Nemesis",
    Content  = "Loaded. Press Ctrl+K to search every control.",
    Duration = 5,
    Image    = 4483362458,
})
