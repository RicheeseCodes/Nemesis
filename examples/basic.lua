-- Minimal Nemesis example
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/siriusxcontact/Nemesis/main/examples/basic.lua"))()

local Nemesis = loadstring(game:HttpGet("https://raw.githubusercontent.com/siriusxcontact/Nemesis/main/Nemesis.lua"))()

local Window = Nemesis:CreateWindow({
    Name = "Example",
    Subtitle = "Basic",
    Keybind = Enum.KeyCode.RightShift,
})

local Tab = Window:CreateTab({ Name = "Main" })
local Group = Tab:CreateSection({ Name = "Gameplay" })

Group:CreateToggle({
    Name = "Auto Sprint",
    Flag = "AutoSprint",
    Default = true,
    Callback = function(v) print("Auto Sprint:", v) end,
})

Group:CreateSlider({
    Name = "Walk Speed",
    Flag = "WalkSpeed",
    Min = 16, Max = 100, Default = 16,
    Callback = function(v)
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            char:FindFirstChildOfClass("Humanoid").WalkSpeed = v
        end
    end,
})
