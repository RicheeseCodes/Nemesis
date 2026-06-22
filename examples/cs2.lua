-- Nemesis CS2 demo. Multiple sections so the two-column layout fills out.
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/RicheeseCodes/Nemesis/main/examples/cs2.lua"))()

local Nemesis = loadstring(game:HttpGet("https://raw.githubusercontent.com/RicheeseCodes/Nemesis/main/Nemesis.lua"))()

local Window = Nemesis:CreateWindow({
	Name = "Nemesis | CS2",
	LoadingTitle = "Nemesis",
	LoadingSubtitle = "CS2 interface",
	ConfigurationSaving = { Enabled = true, FolderName = "Nemesis/CS2", FileName = "Config" },
})

----------------------------------------------------------------
-- AIMBOT TAB
----------------------------------------------------------------
local Aim = Window:CreateTab("Aimbot", 4483362458)

local Aimbot = Aim:CreateSection("Aimbot")
Aimbot:CreateToggle({ Name = "Enable Aimbot", CurrentValue = true, Flag = "aim_enable", Callback = function() end })
Aim:CreateDropdown({ Name = "Aimbot Type", Options = { "Rage", "Legit", "Mid" }, CurrentOption = "Rage", Flag = "aim_type", Callback = function() end })
Aim:CreateDropdown({ Name = "Target Selection", Options = { "FOV", "Distance", "Health" }, CurrentOption = "FOV", Flag = "aim_target", Callback = function() end })
Aim:CreateSlider({ Name = "FOV", Range = { 0, 30 }, Increment = 0.5, CurrentValue = 5, Suffix = "°", Flag = "aim_fov", Callback = function() end })
Aim:CreateSlider({ Name = "Smooth", Range = { 0, 100 }, Increment = 1, CurrentValue = 35, Suffix = "%", Flag = "aim_smooth", Callback = function() end })
Aim:CreateToggle({ Name = "Silent Aim", CurrentValue = true, Flag = "aim_silent", Callback = function() end })
Aim:CreateToggle({ Name = "Auto Shot", CurrentValue = true, Flag = "aim_autoshot", Callback = function() end })

local Accuracy = Aim:CreateSection("Accuracy")
Accuracy:CreateSlider({ Name = "Hitchance", Range = { 0, 100 }, Increment = 1, CurrentValue = 75, Suffix = "%", Flag = "acc_hit", Callback = function() end })
Aim:CreateSlider({ Name = "Min Damage", Range = { 0, 100 }, Increment = 1, CurrentValue = 20, Flag = "acc_dmg", Callback = function() end })
Aim:CreateToggle({ Name = "Auto Wall", CurrentValue = true, Flag = "acc_wall", Callback = function() end })
Aim:CreateToggle({ Name = "Auto Stop", CurrentValue = true, Flag = "acc_stop", Callback = function() end })
Aim:CreateToggle({ Name = "Auto Crouch", CurrentValue = false, Flag = "acc_crouch", Callback = function() end })

local Target = Aim:CreateSection("Target")
Target:CreateDropdown({ Name = "Hitbox", Options = { "Head", "Chest", "Stomach", "Pelvis" }, CurrentOption = "Head", Flag = "tgt_hitbox", Callback = function() end })
Aim:CreateDropdown({ Name = "Multi-Point", Options = { "Head", "Body", "Off" }, CurrentOption = "Head", Flag = "tgt_multi", Callback = function() end })
Aim:CreateSlider({ Name = "Minimum Damage", Range = { 0, 100 }, Increment = 1, CurrentValue = 20, Flag = "tgt_dmg", Callback = function() end })
Aim:CreateToggle({ Name = "Health Based", CurrentValue = false, Flag = "tgt_health", Callback = function() end })

local AntiAim = Aim:CreateSection("Anti-Aim")
AntiAim:CreateToggle({ Name = "Enable Anti-Aim", CurrentValue = true, Flag = "aa_enable", Callback = function() end })
Aim:CreateDropdown({ Name = "Pitch", Options = { "Down", "Up", "Zero", "Jitter" }, CurrentOption = "Down", Flag = "aa_pitch", Callback = function() end })
Aim:CreateDropdown({ Name = "Yaw", Options = { "Jitter", "Spin", "Static" }, CurrentOption = "Jitter", Flag = "aa_yaw", Callback = function() end })
Aim:CreateDropdown({ Name = "Yaw Base", Options = { "At Targets", "Forward", "Backward" }, CurrentOption = "At Targets", Flag = "aa_base", Callback = function() end })
Aim:CreateSlider({ Name = "Fake Lag", Range = { 0, 20 }, Increment = 1, CurrentValue = 14, Flag = "aa_lag", Callback = function() end })

local Resolver = Aim:CreateSection("Resolver")
Resolver:CreateToggle({ Name = "Enable Resolver", CurrentValue = true, Flag = "res_enable", Callback = function() end })
Aim:CreateDropdown({ Name = "Resolver Type", Options = { "Basic", "Advanced", "Experimental" }, CurrentOption = "Advanced", Flag = "res_type", Callback = function() end })
Aim:CreateToggle({ Name = "Override", CurrentValue = false, Flag = "res_override", Callback = function() end })

----------------------------------------------------------------
-- VISUALS TAB
----------------------------------------------------------------
local Vis = Window:CreateTab("Visuals", 4483362458)

local ESP = Vis:CreateSection("Player ESP")
ESP:CreateToggle({ Name = "Enabled", CurrentValue = true, Flag = "esp_on", Callback = function() end })
Vis:CreateToggle({ Name = "Boxes", CurrentValue = true, Flag = "esp_box", Callback = function() end })
Vis:CreateToggle({ Name = "Skeleton", CurrentValue = false, Flag = "esp_skel", Callback = function() end })
Vis:CreateToggle({ Name = "Health Bar", CurrentValue = true, Flag = "esp_hp", Callback = function() end })
Vis:CreateColorPicker({ Name = "Visible Color", Color = Color3.fromRGB(139, 102, 247), Flag = "esp_vis", Callback = function() end })
Vis:CreateColorPicker({ Name = "Occluded Color", Color = Color3.fromRGB(232, 76, 92), Flag = "esp_occ", Callback = function() end })

local World = Vis:CreateSection("World")
World:CreateToggle({ Name = "Fullbright", CurrentValue = false, Flag = "w_bright", Callback = function() end })
Vis:CreateSlider({ Name = "FOV", Range = { 70, 120 }, Increment = 1, CurrentValue = 90, Suffix = "°", Flag = "w_fov", Callback = function() end })
Vis:CreateToggle({ Name = "Remove Smoke", CurrentValue = true, Flag = "w_smoke", Callback = function() end })

local Misc = Vis:CreateSection("Misc")
Misc:CreateToggle({ Name = "Bunny Hop", CurrentValue = true, Flag = "m_bhop", Callback = function() end })
Vis:CreateToggle({ Name = "Auto Strafe", CurrentValue = false, Flag = "m_strafe", Callback = function() end })
Vis:CreateKeybind({ Name = "Panic Key", CurrentKeybind = "End", Flag = "m_panic", Callback = function() end })

Nemesis:LoadConfiguration()
