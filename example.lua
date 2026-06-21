-- Nemesis example (v0.2 Rayfield-style)
local Nemesis = loadstring(game:HttpGet("https://raw.githubusercontent.com/siriusxcontact/Nemesis/main/Nemesis.lua"))()

local Window = Nemesis:CreateWindow({
    Name = "Example",
    Subtitle = "Nemesis Gen 1",
    Keybind = Enum.KeyCode.RightShift,
})

local General = Window:CreateTab({ Name = "General", Icon = "\u{2302}" })
local Stats = Window:CreateTab({ Name = "Statistics", Icon = "\u{2261}" })

local Gameplay = General:CreateSection({ Name = "Gameplay" })

Gameplay:CreateStat({
    Name = "Stat",
    Icon = "\u{272A}",
    Value = "Value",
    Trend = "+0%",
})

Gameplay:CreateButton({
    Name = "Button",
    Icon = "\u{2192}",
    Callback = function()
        Nemesis:Notify({ Title = "Tapped", Text = "Button works.", Duration = 2 })
    end,
})

Gameplay:CreateToggle({
    Name = "Auto Sprint",
    Icon = "\u{226B}",
    Flag = "AutoSprint",
    Default = true,
    Callback = function(v) print("Auto Sprint:", v) end,
})

Gameplay:CreateToggle({
    Name = "Reduced Motion",
    Icon = "\u{29B5}",
    Default = false,
    Description = "Disables screen shake and camera effects for a smoother experience.",
    Callback = function(v) print("Reduced Motion:", v) end,
})

Gameplay:CreateSlider({
    Name = "Slider",
    Icon = "\u{2261}",
    Min = 0, Max = 100, Default = 50, Suffix = "x",
    Callback = function(v) print("Slider:", v) end,
})

Gameplay:CreateKeybind({
    Name = "Keybind",
    Icon = "\u{2328}",
    Default = Enum.KeyCode.E,
    Callback = function(k) print("Bound to:", k.Name) end,
})

local More = General:CreateSection({ Name = "More" })
More:CreateDropdown({
    Name = "Mode",
    Icon = "\u{25BE}",
    Options = { "Casual", "Ranked", "Custom" },
    Default = "Casual",
    Callback = function(v) print("Mode:", v) end,
})
More:CreateInput({
    Name = "Tag",
    Icon = "\u{270E}",
    Placeholder = "your name",
    Callback = function(t) print("Tag:", t) end,
})
More:CreateColorpicker({
    Name = "Accent",
    Icon = "\u{25C6}",
    Default = Color3.fromRGB(46, 196, 132),
    Callback = function(c) Nemesis:SetTheme({ Accent = c }) end,
})
More:CreateParagraph({
    Title = "About",
    Text = "Nemesis is a UI library for Roblox executors. Mobile and desktop.",
})

local Live = Stats:CreateSection({ Name = "Live" })
Live:CreateStat({ Name = "Players", Icon = "\u{2605}", Value = "12", Trend = "+2" })
Live:CreateStat({ Name = "Ping", Icon = "\u{2300}", Value = "48 ms", Trend = "-3 ms" })
