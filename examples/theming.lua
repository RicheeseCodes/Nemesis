-- Nemesis theming example
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/siriusxcontact/Nemesis/main/examples/theming.lua"))()

local Nemesis = loadstring(game:HttpGet("https://raw.githubusercontent.com/siriusxcontact/Nemesis/main/Nemesis.lua"))()

Nemesis:SetTheme({
    Background = Color3.fromRGB(14, 14, 18),
    Surface    = Color3.fromRGB(22, 22, 28),
    Surface2   = Color3.fromRGB(30, 30, 38),
    Border     = Color3.fromRGB(48, 48, 60),
    Accent     = Color3.fromRGB(138, 92, 246),
    AccentDim  = Color3.fromRGB(70, 46, 128),
    Text       = Color3.fromRGB(238, 238, 242),
    Muted      = Color3.fromRGB(140, 140, 152),
})

local Window = Nemesis:CreateWindow({
    Name = "Violet",
    Subtitle = "custom theme",
    Keybind = Enum.KeyCode.RightShift,
})

local Tab = Window:CreateTab({ Name = "Demo", Icon = "\u{25C6}" })
local S = Tab:CreateSection({ Name = "Theme preview" })
S:CreateStat({ Name = "Looks", Icon = "\u{272A}", Value = "Themed", Trend = "+100%" })
S:CreateToggle({ Name = "Switch", Default = true })
S:CreateSlider({ Name = "Slider", Min = 0, Max = 100, Default = 60 })
