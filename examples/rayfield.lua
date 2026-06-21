-- Rayfield-compatible script running on Nemesis.
-- Drop-in: change the loadstring URL and the rest works unchanged.
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/siriusxcontact/Nemesis/main/examples/rayfield.lua"))()

local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/siriusxcontact/Nemesis/main/Nemesis.lua"))()

local Window = Rayfield:CreateWindow({
    Name = "Rayfield Example",
    LoadingTitle = "Rayfield Interface Suite",
    LoadingSubtitle = "by Sirius",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "Nemesis/RayfieldExample",
        FileName = "BigHub",
    },
    KeySystem = false,
})

local Tab = Window:CreateTab("Main", 4483362458)

Tab:CreateSection("Buttons and Toggles")

local Button = Tab:CreateButton({
    Name = "Button Example",
    Callback = function()
        Rayfield:Notify({
            Title = "Button",
            Content = "You pressed the button.",
            Duration = 3,
            Image = 4483362458,
        })
    end,
})

local Toggle = Tab:CreateToggle({
    Name = "Toggle Example",
    CurrentValue = false,
    Flag = "Toggle1",
    Callback = function(Value) print("Toggle1:", Value) end,
})

local ColorPicker = Tab:CreateColorPicker({
    Name = "Color Picker",
    Color = Color3.fromRGB(255, 255, 255),
    Flag = "ColorPicker1",
    Callback = function(Value) print("Color:", Value) end,
})

Tab:CreateSection("Sliders and Inputs")

local Slider = Tab:CreateSlider({
    Name = "Slider Example",
    Range = { 0, 100 },
    Increment = 10,
    Suffix = " bananas",
    CurrentValue = 40,
    Flag = "Slider1",
    Callback = function(Value) print("Slider1:", Value) end,
})

local Input = Tab:CreateInput({
    Name = "Input Example",
    CurrentValue = "",
    PlaceholderText = "Type here",
    RemoveTextAfterFocusLost = false,
    Flag = "Input1",
    Callback = function(Text) print("Input1:", Text) end,
})

local Dropdown = Tab:CreateDropdown({
    Name = "Dropdown Example",
    Options = { "Option 1", "Option 2", "Option 3" },
    CurrentOption = { "Option 1" },
    MultipleOptions = false,
    Flag = "Dropdown1",
    Callback = function(Options) print("Dropdown1:", Options) end,
})

local Keybind = Tab:CreateKeybind({
    Name = "Keybind Example",
    CurrentKeybind = "Q",
    HoldToInteract = false,
    Flag = "Keybind1",
    Callback = function() print("Keybind1 pressed") end,
})

Tab:CreateSection("Static")

local Label = Tab:CreateLabel("Label Example")
local Paragraph = Tab:CreateParagraph({
    Title = "Paragraph Example",
    Content = "This is a paragraph with multiple lines of muted body text inside a card.",
})

Rayfield:Notify({
    Title = "Notification Title",
    Content = "Notification Content",
    Duration = 6.5,
    Image = 4483362458,
    Actions = {
        Ignore = { Name = "Okay", Callback = function() end },
    },
})

Rayfield:LoadConfiguration()
