-- Nemesis example
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/siriusxcontact/Nemesis/main/Nemesis.lua"))()

local Nemesis = loadstring(game:HttpGet("https://raw.githubusercontent.com/siriusxcontact/Nemesis/main/Nemesis.lua"))()

local Window = Nemesis:CreateWindow({
    Name = "Nemesis",
    Subtitle = "v0.1",
    Keybind = Enum.KeyCode.RightShift,
})

local Main = Window:CreateTab({ Name = "Main" })
local Combat = Main:CreateSection({ Name = "Combat", Side = "Left" })
local Visual = Main:CreateSection({ Name = "Visual", Side = "Right" })

Combat:CreateButton({
    Name = "Notify",
    Callback = function()
        Nemesis:Notify({ Title = "Hello", Text = "Nemesis is working.", Duration = 3 })
    end,
})

Combat:CreateToggle({
    Name = "Auto Parry",
    Flag = "AutoParry",
    Default = false,
    Callback = function(v) print("AutoParry:", v) end,
})

Combat:CreateSlider({
    Name = "Reach",
    Flag = "Reach",
    Min = 1, Max = 20, Default = 8, Decimals = 0, Suffix = " studs",
    Callback = function(v) print("Reach:", v) end,
})

Combat:CreateKeybind({
    Name = "Panic Key",
    Default = Enum.KeyCode.P,
    Callback = function(k) print("Panic:", k.Name) end,
})

Visual:CreateDropdown({
    Name = "Target Mode",
    Options = { "Closest", "Lowest HP", "Furthest" },
    Default = "Closest",
    Callback = function(v) print("Mode:", v) end,
})

Visual:CreateInput({
    Name = "Name Tag",
    Placeholder = "your name",
    Callback = function(t) print("Tag:", t) end,
})

Visual:CreateColorpicker({
    Name = "ESP Color",
    Default = Color3.fromRGB(138, 92, 246),
    Callback = function(c) print("Color:", c) end,
})

Visual:CreateLabel({ Text = "Build 0.1 - in development" })
Visual:CreateParagraph({
    Title = "About",
    Text = "Nemesis is a UI library for Roblox executors. Mobile and desktop supported.",
})

local Settings = Window:CreateTab({ Name = "Settings" })
local Theme = Settings:CreateSection({ Name = "Theme", Side = "Left" })
Theme:CreateColorpicker({
    Name = "Accent",
    Default = Color3.fromRGB(138, 92, 246),
    Callback = function(c) Nemesis:SetTheme({ Accent = c }) end,
})
