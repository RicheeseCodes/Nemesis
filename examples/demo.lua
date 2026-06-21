-- Nemesis demo: a fake "cheat menu" with many elements per tab, for showcase.
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/RicheeseCodes/Nemesis/main/examples/demo.lua"))()

local Nemesis = loadstring(game:HttpGet("https://raw.githubusercontent.com/RicheeseCodes/Nemesis/main/Nemesis.lua"))()

local Window = Nemesis:CreateWindow({
    Name = "Nemesis",
    Subtitle = "demo",
    LoadingTitle = "Nemesis",
    LoadingSubtitle = "loading interface...",
    Keybind = Enum.KeyCode.RightShift,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "Nemesis/Demo",
        FileName = "Config",
    },
})

Window:Watermark({ Title = "Nemesis", ShowFPS = true, ShowPing = true, ShowTime = true })

------------------------------------------------------------
-- COMBAT
------------------------------------------------------------
local Combat = Window:CreateTab("Combat", "sword")

Combat:CreateSection("Aim")
Combat:CreateToggle ({ Icon = "target",   Name = "Silent Aim",        Flag = "SilentAim",     Default = false, Callback = function() end })
Combat:CreateToggle ({ Icon = "target",   Name = "Aim Assist",        Flag = "AimAssist",     Default = true,  Description = "Subtle aim correction toward the closest target." })
Combat:CreateSlider ({ Icon = "target",   Name = "FOV",               Flag = "AimFOV",        Range = {0, 360}, Increment = 5, CurrentValue = 180, Suffix = "°" })
Combat:CreateSlider ({ Icon = "target",   Name = "Smoothness",        Flag = "AimSmooth",     Range = {1, 20},  Increment = 1, CurrentValue = 6 })
Combat:CreateDropdown({ Icon = "user",    Name = "Target Part",       Flag = "TargetPart",    Options = {"Head","Torso","HumanoidRootPart","Random"}, CurrentOption = {"Head"} })
Combat:CreateDropdown({ Icon = "menu",    Name = "Prediction",        Flag = "Prediction",    Options = {"Off","Light","Medium","Heavy"}, CurrentOption = {"Light"} })
Combat:CreateKeybind ({ Icon = "keyboard",Name = "Aim Key",           Flag = "AimKey",        CurrentKeybind = "E", HoldToInteract = true })

Combat:CreateSection("Triggerbot")
Combat:CreateToggle ({ Icon = "bolt",     Name = "Triggerbot",        Flag = "Trigger",       Default = false })
Combat:CreateSlider ({ Icon = "bolt",     Name = "Trigger Delay",     Flag = "TriggerDelay",  Range = {0, 500}, Increment = 10, CurrentValue = 60, Suffix = " ms" })
Combat:CreateKeybind ({ Icon = "keyboard",Name = "Trigger Key",       Flag = "TriggerKey",    CurrentKeybind = "MouseButton5", HoldToInteract = true })

Combat:CreateSection("Reach")
Combat:CreateToggle ({ Icon = "sword",    Name = "Hitbox Expander",   Flag = "Hitbox",        Default = false })
Combat:CreateSlider ({ Icon = "sword",    Name = "Hitbox Size",       Flag = "HitboxSize",    Range = {1, 20}, Increment = 1, CurrentValue = 5 })
Combat:CreateDropdown({ Icon = "menu",    Name = "Hitbox Shape",      Flag = "HitboxShape",   Options = {"Sphere","Block","Cylinder"}, CurrentOption = {"Sphere"} })

Combat:CreateSection("Panic")
Combat:CreateButton ({ Icon = "flame",    Name = "Panic — Disable All",
    Callback = function()
        Nemesis:Notify({ Title = "Panic", Content = "All combat features disabled.", Duration = 3 })
    end,
})
Combat:CreateKeybind ({ Icon = "keyboard",Name = "Panic Key",         Flag = "PanicKey",      CurrentKeybind = "P" })

------------------------------------------------------------
-- MOVEMENT
------------------------------------------------------------
local Move = Window:CreateTab("Movement", "bolt")

Move:CreateSection("Speed")
Move:CreateToggle ({ Icon = "bolt",     Name = "Walk Speed",         Flag = "WalkSpeedToggle", Default = false })
Move:CreateSlider ({ Icon = "bolt",     Name = "Walk Speed Value",   Flag = "WalkSpeed",     Range = {16, 250}, Increment = 1, CurrentValue = 16, Suffix = " s/s",
    Callback = function(v)
        local char = game.Players.LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum and Nemesis:GetFlag("WalkSpeedToggle") then hum.WalkSpeed = v end
    end,
})
Move:CreateToggle ({ Icon = "bolt",     Name = "Sprint",             Flag = "Sprint",        Default = true })
Move:CreateKeybind ({ Icon = "keyboard",Name = "Sprint Key",         Flag = "SprintKey",     CurrentKeybind = "LeftShift", HoldToInteract = true })

Move:CreateSection("Jump")
Move:CreateToggle ({ Icon = "arrow_up", Name = "Jump Power",         Flag = "JumpToggle",    Default = false })
Move:CreateSlider ({ Icon = "arrow_up", Name = "Jump Height",        Flag = "JumpPower",     Range = {50, 500}, Increment = 5, CurrentValue = 50 })
Move:CreateToggle ({ Icon = "arrow_up", Name = "Infinite Jump",      Flag = "InfJump",       Default = false })
Move:CreateToggle ({ Icon = "arrow_up", Name = "Double Jump",        Flag = "DoubleJump",    Default = false })

Move:CreateSection("Flight")
Move:CreateToggle ({ Icon = "flame",    Name = "Fly",                Flag = "Fly",           Default = false })
Move:CreateSlider ({ Icon = "flame",    Name = "Fly Speed",          Flag = "FlySpeed",      Range = {1, 200}, Increment = 1, CurrentValue = 50 })
Move:CreateToggle ({ Icon = "flame",    Name = "Noclip",             Flag = "Noclip",        Default = false })
Move:CreateKeybind ({ Icon = "keyboard",Name = "Fly Toggle Key",     Flag = "FlyKey",        CurrentKeybind = "F" })

------------------------------------------------------------
-- VISUAL
------------------------------------------------------------
local Visual = Window:CreateTab("Visual", "eye")

Visual:CreateSection("ESP")
Visual:CreateToggle      ({ Icon = "eye",     Name = "Players",           Flag = "ESP_Players",   Default = true })
Visual:CreateToggle      ({ Icon = "eye",     Name = "Boxes",             Flag = "ESP_Boxes",     Default = true })
Visual:CreateToggle      ({ Icon = "eye",     Name = "Names",             Flag = "ESP_Names",     Default = true })
Visual:CreateToggle      ({ Icon = "eye",     Name = "Health",            Flag = "ESP_Health",    Default = false })
Visual:CreateToggle      ({ Icon = "eye",     Name = "Distance",          Flag = "ESP_Distance",  Default = false })
Visual:CreateToggle      ({ Icon = "eye",     Name = "Tracers",           Flag = "ESP_Tracers",   Default = false })
Visual:CreateDropdown    ({ Icon = "menu",    Name = "Tracer Origin",     Flag = "ESP_TracerOrigin", Options = {"Top","Bottom","Center","Mouse"}, CurrentOption = {"Bottom"} })
Visual:CreateColorPicker ({ Icon = "palette", Name = "Friendly Color",    Flag = "ESP_Friendly",  Color = Color3.fromRGB(46, 196, 132) })
Visual:CreateColorPicker ({ Icon = "palette", Name = "Enemy Color",       Flag = "ESP_Enemy",     Color = Color3.fromRGB(232, 76, 92) })
Visual:CreateSlider      ({ Icon = "eye",     Name = "Max Distance",      Flag = "ESP_MaxDist",   Range = {50, 2000}, Increment = 50, CurrentValue = 500, Suffix = " studs" })

Visual:CreateSection("Camera")
Visual:CreateSlider      ({ Icon = "target",  Name = "Field of View",     Flag = "FOV",           Range = {30, 120}, Increment = 1, CurrentValue = 70, Suffix = "°" })
Visual:CreateToggle      ({ Icon = "eye",     Name = "Third Person",      Flag = "ThirdPerson",   Default = false })
Visual:CreateToggle      ({ Icon = "eye",     Name = "Fullbright",        Flag = "Fullbright",    Default = false })
Visual:CreateColorPicker ({ Icon = "palette", Name = "Ambient",           Flag = "Ambient",       Color = Color3.fromRGB(180, 180, 200) })

------------------------------------------------------------
-- WORLD
------------------------------------------------------------
local World = Window:CreateTab("World", "grid")

World:CreateSection("Time of Day")
World:CreateSlider   ({ Icon = "star",   Name = "Time",          Flag = "TimeOfDay",  Range = {0, 24}, Increment = 1, CurrentValue = 12, Suffix = "h" })
World:CreateButton   ({ Icon = "star",   Name = "Set Day",       Callback = function() Nemesis:Notify({ Title = "Time", Content = "Set to 12:00.", Duration = 2 }) end })
World:CreateButton   ({ Icon = "star",   Name = "Set Night",     Callback = function() Nemesis:Notify({ Title = "Time", Content = "Set to 00:00.", Duration = 2 }) end })

World:CreateSection("Gravity & Physics")
World:CreateSlider   ({ Icon = "arrow_down", Name = "Gravity",        Flag = "Gravity",   Range = {0, 196}, Increment = 1, CurrentValue = 196 })
World:CreateSlider   ({ Icon = "bolt",   Name = "Game Speed",          Flag = "GameSpeed", Range = {0.1, 5}, Increment = 0.1, Decimals = 1, CurrentValue = 1, Suffix = "x" })

World:CreateSection("Teleport")
World:CreateInput    ({ Icon = "edit",   Name = "Player Name",       Flag = "TpTarget", Placeholder = "username" })
World:CreateButton   ({ Icon = "arrow_right", Name = "Teleport to Player", Callback = function()
    local target = Nemesis:GetFlag("TpTarget")
    Nemesis:Notify({ Title = "Teleport", Content = "Going to "..tostring(target), Duration = 2 })
end })
World:CreateButton   ({ Icon = "arrow_up",   Name = "Teleport to Spawn",  Callback = function() end })

------------------------------------------------------------
-- MISC
------------------------------------------------------------
local Misc = Window:CreateTab("Misc", "settings")

Misc:CreateSection("Chat")
Misc:CreateToggle ({ Icon = "bell",    Name = "Anti AFK",          Flag = "AntiAFK",    Default = true })
Misc:CreateInput  ({ Icon = "edit",    Name = "Auto-message",      Flag = "AutoMsg",    Placeholder = "spam this on tap", RemoveTextAfterFocusLost = false })
Misc:CreateSlider ({ Icon = "edit",    Name = "Send Interval",     Flag = "MsgInterval",Range = {1, 60}, Increment = 1, CurrentValue = 5, Suffix = " s" })

Misc:CreateSection("Stats")
Misc:CreateStat ({ Icon = "star",      Name = "Session Kills",     Value = "0",   Trend = "+0" })
Misc:CreateStat ({ Icon = "shield",    Name = "Deaths",            Value = "0",   Trend = "+0" })
Misc:CreateStat ({ Icon = "bolt",      Name = "K/D Ratio",         Value = "0.0", Trend = "stable" })

Misc:CreateSection("Notifications")
Misc:CreateButton ({ Icon = "bell",    Name = "Toast (success)",   Callback = function()
    Nemesis:Notify({ Title = "Success", Content = "Action completed.", Duration = 3 })
end })
Misc:CreateButton ({ Icon = "bell",    Name = "Toast (with action)", Callback = function()
    Nemesis:Notify({
        Title = "Update available", Content = "Reload to apply.", Duration = 8,
        Actions = { Reload = { Name = "Reload", Callback = function() end } },
    })
end })

------------------------------------------------------------
-- SETTINGS
------------------------------------------------------------
local Settings = Window:CreateTab("Settings", "settings")

Settings:CreateSection("Interface")
Settings:CreateButton({ Icon = "search", Name = "Open command palette", Description = "Or press Ctrl+K.", Callback = function() Window:OpenPalette() end })
Settings:CreateButton({ Icon = "diamond",Name = "Open settings flyout", Description = "Gear icon in the header opens this too.", Callback = function() end })

Settings:CreateSection("Theme presets")
for _, name in ipairs(Nemesis:ListThemes()) do
    Settings:CreateButton({ Icon = "diamond", Name = name, Callback = function()
        Nemesis:UseTheme(name)
        Nemesis:Notify({ Title = "Theme", Content = name.." applied", Duration = 2 })
    end })
end

Settings:CreateSection("Configs")
Settings:CreateButton({ Icon = "save", Name = "Save now", Callback = function()
    local ok = Nemesis:SaveConfiguration()
    Nemesis:Notify({ Title = ok and "Saved" or "Failed", Content = ok and "Written to disk." or "Saving disabled.", Duration = 2 })
end })
Settings:CreateButton({ Icon = "load", Name = "Load saved", Callback = function()
    local ok = Nemesis:LoadConfiguration()
    Nemesis:Notify({ Title = ok and "Loaded" or "Failed", Content = ok and "Applied to controls." or "Nothing to load.", Duration = 2 })
end })
Settings:CreateButton({ Icon = "flame", Name = "Reset prompt", Callback = function()
    Window:Prompt({
        Title = "Reset?",
        Content = "This will turn off every toggle and reset every value to default. You can't undo this.",
        Actions = {
            Yes = { Name = "Reset",  Callback = function()
                Nemesis:Notify({ Title = "Reset", Content = "Done.", Duration = 2 })
            end },
            No  = { Name = "Cancel", Callback = function() end },
        },
    })
end })

Settings:CreateSection("About")
Settings:CreateParagraph({
    Title = "Nemesis",
    Text  = "A UI library for Roblox executors. Built on top of Rayfield's API with extra features: command palette (Ctrl+K), watermark HUD, modal prompts, theme presets, Lucide icon names.",
})

------------------------------------------------------------
Nemesis:LoadConfiguration()
Nemesis:Notify({
    Title = "Nemesis", Content = "Loaded. Press Ctrl+K to search every control.",
    Duration = 5, Image = 4483362458,
})
