-- Full Nemesis showcase
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/siriusxcontact/Nemesis/main/examples/full.lua"))()

local Nemesis = loadstring(game:HttpGet("https://raw.githubusercontent.com/siriusxcontact/Nemesis/main/Nemesis.lua"))()
Nemesis:SetConfigFolder("Nemesis/Example")

local Window = Nemesis:CreateWindow({
    Name = "Example",
    Subtitle = "Nemesis Gen 1",
    Keybind = Enum.KeyCode.RightShift,
})

local General = Window:CreateTab({ Name = "General", Icon = "\u{2302}" })
local Stats = Window:CreateTab({ Name = "Statistics", Icon = "\u{2261}" })
local Configs = Window:CreateTab({ Name = "Configs", Icon = "\u{229E}" })

local Gameplay = General:CreateSection({ Name = "Gameplay" })

Gameplay:CreateStat({
    Name = "Status",
    Icon = "\u{272A}",
    Value = "Active",
    Trend = "+0%",
})

Gameplay:CreateButton({
    Name = "Notify",
    Icon = "\u{2192}",
    Description = "Fires a notification toast.",
    Callback = function()
        Nemesis:Notify({ Title = "Hi", Text = "Notify works.", Duration = 2 })
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
    Flag = "ReducedMotion",
    Description = "Disables screen shake and camera effects for a smoother experience.",
    Default = false,
})

Gameplay:CreateSlider({
    Name = "Walk Speed",
    Icon = "\u{2261}",
    Flag = "WalkSpeed",
    Min = 16, Max = 200, Default = 16, Suffix = " s/s",
    Callback = function(v) print("WS:", v) end,
})

Gameplay:CreateKeybind({
    Name = "Panic Key",
    Icon = "\u{2328}",
    Flag = "PanicKey",
    Default = Enum.KeyCode.P,
})

local More = General:CreateSection({ Name = "More" })
More:CreateDropdown({
    Name = "Game Mode",
    Icon = "\u{25BE}",
    Flag = "GameMode",
    Options = { "Casual", "Ranked", "Custom" },
    Default = "Casual",
})
More:CreateDropdown({
    Name = "Targets",
    Icon = "\u{2261}",
    Flag = "Targets",
    Multi = true,
    Options = { "Players", "NPCs", "Bosses", "Allies" },
    Default = { "Players" },
})
More:CreateInput({
    Name = "Tag",
    Icon = "\u{270E}",
    Flag = "Tag",
    Placeholder = "your name",
})
More:CreateColorpicker({
    Name = "Accent",
    Icon = "\u{25C6}",
    Flag = "Accent",
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

local Cfg = Configs:CreateSection({ Name = "Save and Load" })
Cfg:CreateButton({
    Name = "Save current",
    Icon = "\u{2193}",
    Callback = function()
        local ok, err = Nemesis:SaveConfig("default")
        Nemesis:Notify({ Title = ok and "Saved" or "Save failed", Text = ok and "default.json written" or tostring(err) })
    end,
})
Cfg:CreateButton({
    Name = "Load saved",
    Icon = "\u{2191}",
    Callback = function()
        local ok, err = Nemesis:LoadConfig("default")
        Nemesis:Notify({ Title = ok and "Loaded" or "Load failed", Text = ok and "default.json applied" or tostring(err) })
    end,
})
