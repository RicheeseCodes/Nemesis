--[[
    Nemesis UI v0.3
    A UI library for Roblox executors. Mobile and desktop.
    https://github.com/siriusxcontact/Nemesis
]]

local Nemesis = {}
Nemesis.__index = Nemesis
Nemesis._flags = {}
Nemesis._configFolder = "Nemesis"
Nemesis._theme = {
    Background = Color3.fromRGB(18, 18, 22),
    Surface    = Color3.fromRGB(26, 26, 32),
    Surface2   = Color3.fromRGB(34, 34, 42),
    Border     = Color3.fromRGB(44, 44, 54),
    Accent     = Color3.fromRGB(46, 196, 132),
    AccentDim  = Color3.fromRGB(26, 110, 76),
    Text       = Color3.fromRGB(238, 238, 242),
    Muted      = Color3.fromRGB(140, 140, 152),
    Soft       = Color3.fromRGB(90, 90, 102),
    Danger     = Color3.fromRGB(232, 76, 92),
}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local IsTouch = UserInputService.TouchEnabled
local IsMobile = IsTouch and not UserInputService.MouseEnabled

local QUICK = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local SMOOTH = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

local function getParent()
    if gethui then return gethui() end
    if syn and syn.protect_gui then
        local g = Instance.new("ScreenGui")
        syn.protect_gui(g)
        g.Parent = game:GetService("CoreGui")
        return g.Parent
    end
    local ok, core = pcall(function() return game:GetService("CoreGui") end)
    if ok and core then return core end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local function new(class, props, children)
    local inst = Instance.new(class)
    if props then for k, v in pairs(props) do inst[k] = v end end
    if children then for _, c in ipairs(children) do c.Parent = inst end end
    return inst
end

local function tween(inst, info, props)
    local t = TweenService:Create(inst, info, props)
    t:Play()
    return t
end

local function corner(parent, radius)
    return new("UICorner", { CornerRadius = UDim.new(0, radius or 10), Parent = parent })
end

local function stroke(parent, color, thickness, transparency)
    return new("UIStroke", {
        Color = color or Nemesis._theme.Border,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent,
    })
end

local function padding(parent, t, r, b, l)
    return new("UIPadding", {
        PaddingTop = UDim.new(0, t or 0),
        PaddingRight = UDim.new(0, r or t or 0),
        PaddingBottom = UDim.new(0, b or t or 0),
        PaddingLeft = UDim.new(0, l or r or t or 0),
        Parent = parent,
    })
end

local function listLayout(parent, padPx)
    return new("UIListLayout", {
        Padding = UDim.new(0, padPx or 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = parent,
    })
end

local function makeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    handle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

local function bindTap(button, fn)
    button.MouseButton1Click:Connect(fn)
    if IsTouch then button.TouchTap:Connect(fn) end
end

local function iconNode(parent, icon, size, color)
    icon = resolveIcon(icon)
    if not icon or icon == "" then return nil end
    if typeof(icon) == "string" and icon:match("^rbxassetid://") then
        return new("ImageLabel", {
            Image = icon,
            BackgroundTransparency = 1,
            Size = UDim2.fromOffset(size or 16, size or 16),
            ImageColor3 = color or Nemesis._theme.Text,
            Parent = parent,
        })
    end
    return new("TextLabel", {
        Text = tostring(icon),
        Font = Enum.Font.GothamBold,
        TextSize = size or 14,
        TextColor3 = color or Nemesis._theme.Text,
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset((size or 16) + 4, size or 16),
        Parent = parent,
    })
end

local function setIconColor(inst, color)
    if not inst then return end
    if inst:IsA("ImageLabel") then tween(inst, QUICK, { ImageColor3 = color })
    else tween(inst, QUICK, { TextColor3 = color }) end
end

-- ===== Lucide-style icon name map (common names → glyphs) =====
local ICON_MAP = {
    home = "\u{2302}", house = "\u{2302}",
    settings = "\u{2699}", gear = "\u{2699}", cog = "\u{2699}",
    user = "\u{25CB}", person = "\u{25CB}",
    search = "\u{2315}",
    plus = "+", add = "+",
    minus = "-",
    close = "\u{2715}", x = "\u{2715}",
    check = "\u{2713}", tick = "\u{2713}",
    star = "\u{2605}",
    heart = "\u{2665}",
    arrow_right = "\u{2192}", right = "\u{2192}",
    arrow_left = "\u{2190}", left = "\u{2190}",
    arrow_up = "\u{2191}", up = "\u{2191}",
    arrow_down = "\u{2193}", down = "\u{2193}",
    menu = "\u{2261}", list = "\u{2261}",
    grid = "\u{229E}",
    bell = "\u{2407}", notification = "\u{2407}",
    eye = "\u{25C9}",
    play = "\u{25B6}",
    pause = "\u{2759}\u{2759}",
    stop = "\u{25A0}",
    skip = "\u{226B}",
    music = "\u{266B}", note = "\u{266B}",
    edit = "\u{270E}", pen = "\u{270E}", pencil = "\u{270E}",
    palette = "\u{25C6}", color = "\u{25C6}",
    chart = "\u{2261}", stats = "\u{2261}",
    sparkles = "\u{272A}", magic = "\u{272A}",
    keyboard = "\u{2328}",
    target = "\u{2300}", crosshair = "\u{2300}",
    folder = "\u{229A}",
    file = "\u{229E}",
    save = "\u{2193}",
    load = "\u{2191}",
    shield = "\u{29B5}",
    sword = "\u{2694}",
    bolt = "\u{26A1}", lightning = "\u{26A1}", flash = "\u{26A1}",
    flame = "\u{1F525}", fire = "\u{1F525}",
    diamond = "\u{25C6}",
    circle = "\u{25CF}",
    square = "\u{25A0}",
    triangle = "\u{25B2}",
}
local function resolveIcon(icon)
    if not icon then return nil end
    if type(icon) == "number" then return "rbxassetid://"..tostring(icon) end
    if type(icon) == "string" then
        if icon:match("^rbxassetid://") then return icon end
        local mapped = ICON_MAP[icon:lower()]
        if mapped then return mapped end
    end
    return icon
end

-- ===== Theme presets =====
local THEME_PRESETS = {
    Default = {
        Background = Color3.fromRGB(18, 18, 22),
        Surface    = Color3.fromRGB(26, 26, 32),
        Surface2   = Color3.fromRGB(34, 34, 42),
        Border     = Color3.fromRGB(44, 44, 54),
        Accent     = Color3.fromRGB(46, 196, 132),
        AccentDim  = Color3.fromRGB(26, 110, 76),
        Text       = Color3.fromRGB(238, 238, 242),
        Muted      = Color3.fromRGB(140, 140, 152),
        Soft       = Color3.fromRGB(90, 90, 102),
    },
    Amethyst = {
        Background = Color3.fromRGB(18, 16, 24),
        Surface    = Color3.fromRGB(26, 22, 36),
        Surface2   = Color3.fromRGB(34, 28, 48),
        Border     = Color3.fromRGB(60, 48, 84),
        Accent     = Color3.fromRGB(138, 92, 246),
        AccentDim  = Color3.fromRGB(70, 46, 128),
    },
    Ocean = {
        Background = Color3.fromRGB(14, 18, 26),
        Surface    = Color3.fromRGB(20, 26, 38),
        Surface2   = Color3.fromRGB(28, 36, 52),
        Border     = Color3.fromRGB(40, 52, 76),
        Accent     = Color3.fromRGB(64, 156, 240),
        AccentDim  = Color3.fromRGB(32, 78, 132),
    },
    Crimson = {
        Background = Color3.fromRGB(20, 14, 16),
        Surface    = Color3.fromRGB(28, 20, 24),
        Surface2   = Color3.fromRGB(38, 26, 32),
        Border     = Color3.fromRGB(70, 40, 50),
        Accent     = Color3.fromRGB(232, 76, 92),
        AccentDim  = Color3.fromRGB(120, 36, 52),
    },
    Citrus = {
        Background = Color3.fromRGB(22, 20, 14),
        Surface    = Color3.fromRGB(32, 28, 20),
        Surface2   = Color3.fromRGB(42, 36, 26),
        Border     = Color3.fromRGB(82, 64, 30),
        Accent     = Color3.fromRGB(240, 168, 60),
        AccentDim  = Color3.fromRGB(140, 96, 30),
    },
    Mono = {
        Background = Color3.fromRGB(16, 16, 16),
        Surface    = Color3.fromRGB(24, 24, 24),
        Surface2   = Color3.fromRGB(34, 34, 34),
        Border     = Color3.fromRGB(60, 60, 60),
        Accent     = Color3.fromRGB(220, 220, 220),
        AccentDim  = Color3.fromRGB(100, 100, 100),
    },
}

-- ===== Rayfield-compat normalizers =====
local function normalize(o, kind)
    o = o or {}
    if o.Default == nil then o.Default = o.CurrentValue end
    o.Placeholder = o.Placeholder or o.PlaceholderText
    if o.Range then o.Min = o.Min or o.Range[1]; o.Max = o.Max or o.Range[2] end
    if o.Increment and not o.Step then o.Step = o.Increment end
    if kind == "Dropdown" then
        if o.CurrentOption ~= nil and o.Default == nil then
            if o.MultipleOptions then
                o.Default = o.CurrentOption
            elseif type(o.CurrentOption) == "table" then
                o.Default = o.CurrentOption[1]
            else
                o.Default = o.CurrentOption
            end
        end
        if o.MultipleOptions and o.Multi == nil then o.Multi = true end
    elseif kind == "ColorPicker" then
        if o.Default == nil then o.Default = o.Color end
    elseif kind == "Keybind" then
        local k = o.Default
        if k == nil then k = o.CurrentKeybind end
        if type(k) == "string" and Enum.KeyCode[k] then o.Default = Enum.KeyCode[k]
        elseif typeof(k) == "EnumItem" then o.Default = k end
    elseif kind == "Paragraph" then
        o.Text = o.Text or o.Content
    elseif kind == "Notify" then
        o.Text = o.Text or o.Content
        if type(o.Image) == "number" then o.Image = "rbxassetid://" .. tostring(o.Image) end
    end
    return o
end

local _saveDebounce = false
local function autoSave()
    if not (Nemesis._configOpts and Nemesis._configOpts.Enabled) then return end
    if _saveDebounce then return end
    _saveDebounce = true
    task.spawn(function()
        task.wait(0.5)
        _saveDebounce = false
        pcall(function() Nemesis:SaveConfiguration() end)
    end)
end

local function setFlag(name, value)
    if not name then return end
    Nemesis._flags[name] = value
    autoSave()
end

-- ===== Config =====
local function executor()
    return identifyexecutor and identifyexecutor() or "unknown"
end

local function writeFile(path, data)
    if writefile then return pcall(writefile, path, data) end
    return false, "writefile unavailable"
end
local function readFile(path)
    if readfile and isfile and isfile(path) then return readfile(path) end
end
local function listFiles(folder)
    if listfiles then return listfiles(folder) end
    return {}
end
local function makeFolder(folder)
    if makefolder and isfolder and not isfolder(folder) then makefolder(folder) end
end

function Nemesis:SetConfigFolder(name)
    self._configFolder = name
    makeFolder(name)
end

function Nemesis:SaveConfig(name)
    makeFolder(self._configFolder)
    local serialized = {}
    for k, v in pairs(self._flags) do
        if typeof(v) == "Color3" then
            serialized[k] = { __t = "Color3", r = v.R, g = v.G, b = v.B }
        elseif typeof(v) == "EnumItem" then
            serialized[k] = { __t = "Enum", n = tostring(v) }
        elseif type(v) == "table" or type(v) == "number" or type(v) == "boolean" or type(v) == "string" then
            serialized[k] = v
        end
    end
    local ok, encoded = pcall(HttpService.JSONEncode, HttpService, serialized)
    if not ok then return false, encoded end
    return writeFile(self._configFolder .. "/" .. name .. ".json", encoded)
end

function Nemesis:LoadConfig(name)
    local raw = readFile(self._configFolder .. "/" .. name .. ".json")
    if not raw then return false, "missing" end
    local ok, decoded = pcall(HttpService.JSONDecode, HttpService, raw)
    if not ok then return false, decoded end
    for k, v in pairs(decoded) do
        if type(v) == "table" and v.__t == "Color3" then
            self._flags[k] = Color3.new(v.r, v.g, v.b)
        elseif type(v) == "table" and v.__t == "Enum" then
            local segs = string.split(v.n, ".")
            if segs[1] == "Enum" and segs[2] and segs[3] then
                local enumType = Enum[segs[2]]
                local item = enumType and enumType[segs[3]]
                if item then self._flags[k] = item end
            end
        else
            self._flags[k] = v
        end
        if self._setters and self._setters[k] then
            pcall(self._setters[k], self._flags[k])
        end
    end
    return true
end

function Nemesis:ListConfigs()
    local out = {}
    for _, p in ipairs(listFiles(self._configFolder)) do
        local name = p:match("([^/\\]+)%.json$")
        if name then table.insert(out, name) end
    end
    return out
end

Nemesis._setters = {}
local function registerFlag(flag, setter, value)
    if not flag then return end
    Nemesis._flags[flag] = value
    Nemesis._setters[flag] = setter
end

-- ===== Key system + loading splash =====
local function validateKey(entered, ks)
    local keys = ks.Key or {}
    if type(keys) == "string" then keys = { keys } end
    if ks.GrabKeyFromSite and keys[1] then
        local ok, res = pcall(function() return game:HttpGet(keys[1]) end)
        if ok and res then keys = { (res:gsub("%s+$", "")) } end
    end
    for _, k in ipairs(keys) do
        if entered == k then return true end
    end
    return false
end

local function runKeyPrompt(screen, ks)
    ks = ks or {}
    local folder = ks.FolderName or Nemesis._configFolder
    local fname = (ks.FileName or "Key") .. ".txt"
    if ks.SaveKey then
        local saved = readFile(folder .. "/" .. fname)
        if saved and validateKey(saved, ks) then return true end
    end

    local overlay = new("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        Parent = screen,
        ZIndex = 100,
    })
    local panel = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(380, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Nemesis._theme.Surface,
        BorderSizePixel = 0,
        Parent = overlay,
        ZIndex = 101,
    })
    corner(panel, 14)
    stroke(panel, Nemesis._theme.Border, 1, 0.4)
    padding(panel, 20)
    listLayout(panel, 10)

    new("TextLabel", {
        Text = ks.Title or "Key required",
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        TextColor3 = Nemesis._theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 22),
        Parent = panel,
    })
    new("TextLabel", {
        Text = ks.Subtitle or "Enter your key to continue.",
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextColor3 = Nemesis._theme.Muted,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 18),
        Parent = panel,
    })
    if ks.Note then
        new("TextLabel", {
            Text = ks.Note,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextColor3 = Nemesis._theme.Muted,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextWrapped = true,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Parent = panel,
        })
    end

    local box = new("TextBox", {
        Text = "",
        PlaceholderText = "key",
        Font = Enum.Font.GothamMedium,
        TextSize = 14,
        TextColor3 = Nemesis._theme.Text,
        PlaceholderColor3 = Nemesis._theme.Muted,
        BackgroundColor3 = Nemesis._theme.Surface2,
        ClearTextOnFocus = false,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, 0, 0, 36),
        Parent = panel,
    })
    corner(box, 8)
    stroke(box, Nemesis._theme.Border, 1, 0.4)
    padding(box, 0, 12, 0, 12)

    local err = new("TextLabel", {
        Text = "",
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        TextColor3 = Nemesis._theme.Danger,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 16),
        Parent = panel,
    })

    local submit = new("TextButton", {
        Text = "Continue",
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = Color3.new(1, 1, 1),
        BackgroundColor3 = Nemesis._theme.Accent,
        AutoButtonColor = false,
        Size = UDim2.new(1, 0, 0, 32),
        Parent = panel,
    })
    corner(submit, 8)

    local done, result = false, false
    local function try()
        local entered = box.Text
        if validateKey(entered, ks) then
            if ks.SaveKey then
                makeFolder(folder)
                writeFile(folder .. "/" .. fname, entered)
            end
            done, result = true, true
        else
            err.Text = "Invalid key"
            tween(box, QUICK, { BackgroundColor3 = Nemesis._theme.Danger })
            task.delay(0.4, function() tween(box, QUICK, { BackgroundColor3 = Nemesis._theme.Surface2 }) end)
        end
    end
    bindTap(submit, try)
    box.FocusLost:Connect(function(enter) if enter then try() end end)

    while not done do task.wait(0.05) end
    tween(overlay, SMOOTH, { BackgroundTransparency = 1 })
    task.wait(0.25)
    overlay:Destroy()
    return result
end

local function runLoadingSplash(screen, title, subtitle)
    local overlay = new("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Nemesis._theme.Background,
        BorderSizePixel = 0,
        Parent = screen,
        ZIndex = 50,
    })
    local center = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(320, 90),
        BackgroundTransparency = 1,
        Parent = overlay,
    })
    new("TextLabel", {
        Text = title or "Nemesis",
        Font = Enum.Font.GothamBold,
        TextSize = 22,
        TextColor3 = Nemesis._theme.Text,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 26),
        Parent = center,
    })
    if subtitle then
        new("TextLabel", {
            Text = subtitle,
            Font = Enum.Font.Gotham,
            TextSize = 13,
            TextColor3 = Nemesis._theme.Muted,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 28),
            Size = UDim2.new(1, 0, 0, 18),
            Parent = center,
        })
    end
    local barBg = new("Frame", {
        Position = UDim2.new(0, 0, 0, 64),
        Size = UDim2.new(1, 0, 0, 4),
        BackgroundColor3 = Nemesis._theme.Surface2,
        BorderSizePixel = 0,
        Parent = center,
    })
    corner(barBg, 2)
    local barFill = new("Frame", {
        Size = UDim2.fromScale(0, 1),
        BackgroundColor3 = Nemesis._theme.Accent,
        BorderSizePixel = 0,
        Parent = barBg,
    })
    corner(barFill, 2)
    tween(barFill, TweenInfo.new(1.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.fromScale(1, 1) })
    task.wait(1.3)
    tween(overlay, SMOOTH, { BackgroundTransparency = 1 })
    for _, d in ipairs(overlay:GetDescendants()) do
        if d:IsA("TextLabel") then tween(d, SMOOTH, { TextTransparency = 1 }) end
        if d:IsA("Frame") then tween(d, SMOOTH, { BackgroundTransparency = 1 }) end
    end
    task.wait(0.3)
    overlay:Destroy()
end

-- ===== Window =====
function Nemesis:CreateWindow(opts)
    opts = opts or {}
    local Window = setmetatable({}, { __index = self })

    local screen = new("ScreenGui", {
        Name = "NemesisUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
        DisplayOrder = 999,
    })
    pcall(function() screen.Parent = getParent() end)
    if not screen.Parent then screen.Parent = LocalPlayer:WaitForChild("PlayerGui") end
    Nemesis._lastScreen = screen

    if opts.ConfigurationSaving then
        Nemesis._configOpts = opts.ConfigurationSaving
        if opts.ConfigurationSaving.FolderName then
            Nemesis:SetConfigFolder(opts.ConfigurationSaving.FolderName)
        end
    end

    local viewport = workspace.CurrentCamera.ViewportSize
    local isPhone = IsMobile or viewport.X < 600
    local defaultW = isPhone and math.min(viewport.X - 24, 480) or 580
    local defaultH = isPhone and math.min(viewport.Y - 100, 540) or 480

    local main = new("Frame", {
        Name = "Main",
        Size = UDim2.fromOffset(defaultW, defaultH),
        Position = UDim2.new(0.5, -defaultW/2, 0.5, -defaultH/2),
        BackgroundColor3 = Nemesis._theme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = screen,
    })
    corner(main, 18)
    stroke(main, Nemesis._theme.Border, 1, 0.4)
    local mainScale = new("UIScale", { Scale = 0.96, Parent = main })
    main.BackgroundTransparency = 1
    main.Visible = false

    local ready = false
    task.spawn(function()
        if opts.KeySystem then
            local ok = runKeyPrompt(screen, opts.KeySettings or {})
            if not ok then screen:Destroy(); return end
        end
        if opts.LoadingTitle or opts.LoadingSubtitle then
            runLoadingSplash(screen, opts.LoadingTitle or opts.Name, opts.LoadingSubtitle)
        end
        main.Visible = true
        tween(main, SMOOTH, { BackgroundTransparency = 0 })
        tween(mainScale, SMOOTH, { Scale = 1 })
        ready = true
    end)

    local function isReady() return ready end

    -- Header
    local header = new("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 56),
        BackgroundTransparency = 1,
        Parent = main,
    })

    new("TextLabel", {
        Text = opts.Name or "Nemesis",
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        TextColor3 = Nemesis._theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 18, 0, 8),
        Size = UDim2.new(0, 280, 0, 22),
        Parent = header,
    })
    if opts.Subtitle then
        new("TextLabel", {
            Text = opts.Subtitle,
            Font = Enum.Font.Gotham,
            TextSize = 13,
            TextColor3 = Nemesis._theme.Muted,
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 18, 0, 30),
            Size = UDim2.new(0, 280, 0, 16),
            Parent = header,
        })
    end

    -- Header action icons
    local actions = new("Frame", {
        Name = "Actions",
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -12, 0, 14),
        Size = UDim2.new(0, 160, 0, 28),
        BackgroundTransparency = 1,
        Parent = header,
    })
    new("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = actions,
    })

    local function actionBtn(glyph, order)
        local b = new("TextButton", {
            Text = glyph,
            Font = Enum.Font.GothamBold,
            TextSize = 16,
            TextColor3 = Nemesis._theme.Muted,
            BackgroundTransparency = 1,
            Size = UDim2.fromOffset(28, 28),
            AutoButtonColor = false,
            LayoutOrder = order,
            Parent = actions,
        })
        b.MouseEnter:Connect(function() tween(b, QUICK, { TextColor3 = Nemesis._theme.Text }) end)
        b.MouseLeave:Connect(function() tween(b, QUICK, { TextColor3 = Nemesis._theme.Muted }) end)
        return b
    end

    local searchBtn = actionBtn("\u{2315}", 1)
    local settingsBtn = actionBtn("\u{2699}", 2)
    local minBtn = actionBtn("\u{2212}", 3)
    local closeBtn = actionBtn("\u{2715}", 4)

    -- Divider
    new("Frame", {
        Size = UDim2.new(1, -32, 0, 1),
        Position = UDim2.new(0, 16, 0, 56),
        BackgroundColor3 = Nemesis._theme.Border,
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        Parent = main,
    })

    -- Tab bar
    local tabBar = new("ScrollingFrame", {
        Name = "TabBar",
        Position = UDim2.new(0, 0, 0, 62),
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 0,
        ScrollingDirection = Enum.ScrollingDirection.X,
        AutomaticCanvasSize = Enum.AutomaticSize.X,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Parent = main,
    })
    new("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = tabBar,
    })
    padding(tabBar, 0, 16, 0, 16)

    -- Content
    local contentWrap = new("Frame", {
        Name = "Content",
        Position = UDim2.new(0, 0, 0, 110),
        Size = UDim2.new(1, 0, 1, -118),
        BackgroundTransparency = 1,
        Parent = main,
    })

    -- iOS handle
    if isPhone then
        local handle = new("Frame", {
            AnchorPoint = Vector2.new(0.5, 1),
            Position = UDim2.new(0.5, 0, 1, -6),
            Size = UDim2.fromOffset(60, 4),
            BackgroundColor3 = Nemesis._theme.Soft,
            BackgroundTransparency = 0.3,
            BorderSizePixel = 0,
            Parent = main,
        })
        corner(handle, 2)
    end

    makeDraggable(main, header)

    -- Desktop resize grip
    if not isPhone then
        local grip = new("ImageButton", {
            AnchorPoint = Vector2.new(1, 1),
            Position = UDim2.new(1, -4, 1, -4),
            Size = UDim2.fromOffset(16, 16),
            BackgroundTransparency = 1,
            Image = "",
            AutoButtonColor = false,
            Parent = main,
        })
        for i = 0, 2 do
            new("Frame", {
                AnchorPoint = Vector2.new(1, 1),
                Position = UDim2.new(1, -i*4, 1, 0),
                Size = UDim2.fromOffset(2, 2 + i*4),
                BackgroundColor3 = Nemesis._theme.Soft,
                BorderSizePixel = 0,
                Parent = grip,
            })
        end
        local resizing, startSize, startInput
        grip.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                resizing = true; startSize = main.AbsoluteSize; startInput = i.Position
            end
        end)
        grip.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                resizing = false
            end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if resizing and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                local d = i.Position - startInput
                local w = math.clamp(startSize.X + d.X, 380, viewport.X - 32)
                local h = math.clamp(startSize.Y + d.Y, 280, viewport.Y - 32)
                main.Size = UDim2.fromOffset(w, h)
            end
        end)
    end

    -- Minimize
    local minimized = false
    local restoreSize
    bindTap(minBtn, function()
        if not minimized then
            restoreSize = main.Size
            minimized = true
            tween(main, SMOOTH, { Size = UDim2.fromOffset(main.AbsoluteSize.X, 56) })
        else
            minimized = false
            tween(main, SMOOTH, { Size = restoreSize })
        end
    end)

    bindTap(closeBtn, function() main.Visible = false end)

    -- Mobile pill
    local mobileBtn
    if isPhone or opts.MobileButton then
        mobileBtn = new("TextButton", {
            Text = (opts.Name or "N"):sub(1, 1):upper(),
            Font = Enum.Font.GothamBold,
            TextSize = 18,
            TextColor3 = Color3.new(1, 1, 1),
            BackgroundColor3 = Nemesis._theme.Accent,
            Size = UDim2.fromOffset(48, 48),
            Position = UDim2.new(0, 16, 0, 80),
            AutoButtonColor = false,
            Parent = screen,
        })
        corner(mobileBtn, 24)
        stroke(mobileBtn, Color3.new(1, 1, 1), 0, 1)
        makeDraggable(mobileBtn)
        local moved, pressStart = false, nil
        mobileBtn.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
                pressStart = i.Position; moved = false
            end
        end)
        mobileBtn.InputChanged:Connect(function(i)
            if pressStart and (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement) then
                if (i.Position - pressStart).Magnitude > 6 then moved = true end
            end
        end)
        mobileBtn.InputEnded:Connect(function(i)
            if (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1) and not moved then
                if isReady() then main.Visible = not main.Visible end
            end
            pressStart = nil
        end)
    end

    -- Keybind toggle
    local toggleKey = opts.Keybind or Enum.KeyCode.RightShift
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe or not isReady() then return end
        if input.KeyCode == toggleKey then main.Visible = not main.Visible end
    end)

    Window._screen = screen
    Window._main = main
    Window._tabBar = tabBar
    Window._content = contentWrap
    Window._tabs = {}
    Window._index = {}
    Window._isPhone = isPhone

    function Window:_findTabIndex(tab)
        for i, t in ipairs(self._tabs) do
            if t == tab then return i end
        end
    end

    function Window:_activateTab(tab)
        if tab and tab._btn then
            for _, t in ipairs(self._tabs) do
                t._page.Visible = false
                tween(t._lbl, QUICK, { TextColor3 = Nemesis._theme.Muted })
                setIconColor(t._icon, Nemesis._theme.Muted)
            end
            tab._page.Visible = true
            tween(tab._lbl, QUICK, { TextColor3 = Nemesis._theme.Text })
            setIconColor(tab._icon, Nemesis._theme.Text)
        end
    end

    function Window:_flashCard(card)
        if not card then return end
        local orig = card.BackgroundColor3
        tween(card, QUICK, { BackgroundColor3 = Nemesis._theme.AccentDim })
        task.delay(0.7, function()
            if card.Parent then tween(card, SMOOTH, { BackgroundColor3 = orig }) end
        end)
    end

    local palette
    function Window:OpenPalette()
        if palette and palette.Parent then return end
        palette = new("Frame", {
            Size = UDim2.fromScale(1, 1),
            BackgroundColor3 = Color3.new(0, 0, 0),
            BackgroundTransparency = 0.5,
            BorderSizePixel = 0,
            Parent = Window._screen,
            ZIndex = 150,
        })
        local panel = new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0),
            Position = UDim2.new(0.5, 0, 0, 80),
            Size = UDim2.fromOffset(420, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = Nemesis._theme.Surface,
            BorderSizePixel = 0,
            Parent = palette,
            ZIndex = 151,
        })
        corner(panel, 14)
        stroke(panel, Nemesis._theme.Border, 1, 0.4)
        padding(panel, 10)
        listLayout(panel, 6)

        local box = new("TextBox", {
            Text = "",
            PlaceholderText = "Search controls...",
            Font = Enum.Font.GothamMedium,
            TextSize = 14,
            TextColor3 = Nemesis._theme.Text,
            PlaceholderColor3 = Nemesis._theme.Muted,
            BackgroundColor3 = Nemesis._theme.Surface2,
            ClearTextOnFocus = false,
            Size = UDim2.new(1, 0, 0, 36),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = panel,
        })
        corner(box, 8)
        stroke(box, Nemesis._theme.Border, 1, 0.4)
        padding(box, 0, 12, 0, 12)

        local list = new("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Parent = panel,
        })
        listLayout(list, 2)

        local function render(query)
            for _, c in ipairs(list:GetChildren()) do
                if c:IsA("TextButton") then c:Destroy() end
            end
            query = (query or ""):lower()
            local shown = 0
            for _, entry in ipairs(Window._index) do
                local hay = (entry.name .. " " .. entry.kind .. " " .. (entry.section or "") .. " " .. entry.tab._name):lower()
                if query == "" or hay:find(query, 1, true) then
                    shown = shown + 1
                    if shown > 30 then break end
                    local row = new("TextButton", {
                        Text = "",
                        BackgroundColor3 = Nemesis._theme.Surface2,
                        AutoButtonColor = false,
                        Size = UDim2.new(1, 0, 0, 40),
                        Parent = list,
                    })
                    corner(row, 8)
                    new("TextLabel", {
                        Text = entry.kind,
                        Font = Enum.Font.GothamMedium,
                        TextSize = 10,
                        TextColor3 = Nemesis._theme.Accent,
                        BackgroundColor3 = Nemesis._theme.Surface,
                        TextXAlignment = Enum.TextXAlignment.Center,
                        Position = UDim2.new(0, 10, 0.5, -8),
                        Size = UDim2.fromOffset(64, 16),
                        Parent = row,
                    })
                    new("TextLabel", {
                        Text = entry.name,
                        Font = Enum.Font.GothamMedium,
                        TextSize = 13,
                        TextColor3 = Nemesis._theme.Text,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 84, 0, 4),
                        Size = UDim2.new(1, -94, 0, 18),
                        Parent = row,
                    })
                    new("TextLabel", {
                        Text = (entry.tab._name or "")..(entry.section and " / "..entry.section or ""),
                        Font = Enum.Font.Gotham,
                        TextSize = 11,
                        TextColor3 = Nemesis._theme.Muted,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 84, 0, 22),
                        Size = UDim2.new(1, -94, 0, 14),
                        Parent = row,
                    })
                    bindTap(row, function()
                        Window:_activateTab(entry.tab)
                        Window:_flashCard(entry.card)
                        if entry.fire then task.spawn(entry.fire) end
                        if palette then palette:Destroy(); palette = nil end
                    end)
                end
            end
            if shown == 0 then
                new("TextLabel", {
                    Text = "No matches",
                    Font = Enum.Font.Gotham,
                    TextSize = 12,
                    TextColor3 = Nemesis._theme.Muted,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 24),
                    Parent = list,
                })
            end
        end
        render("")
        box:GetPropertyChangedSignal("Text"):Connect(function() render(box.Text) end)
        box:CaptureFocus()
        palette.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                local mp = i.Position
                local pp = panel.AbsolutePosition
                local ps = panel.AbsoluteSize
                if mp.X < pp.X or mp.X > pp.X + ps.X or mp.Y < pp.Y or mp.Y > pp.Y + ps.Y then
                    palette:Destroy(); palette = nil
                end
            end
        end)
    end

    bindTap(searchBtn, function() Window:OpenPalette() end)
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe or not isReady() then return end
        if (input.KeyCode == Enum.KeyCode.K) and (UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
            or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
            or UserInputService:IsKeyDown(Enum.KeyCode.LeftMeta)
            or UserInputService:IsKeyDown(Enum.KeyCode.RightMeta)) then
            Window:OpenPalette()
        end
    end)

    function Window:Prompt(promptOpts)
        promptOpts = promptOpts or {}
        local overlay = new("Frame", {
            Size = UDim2.fromScale(1, 1),
            BackgroundColor3 = Color3.new(0, 0, 0),
            BackgroundTransparency = 0.5,
            BorderSizePixel = 0,
            Parent = Window._screen,
            ZIndex = 200,
        })
        local panel = new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(360, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = Nemesis._theme.Surface,
            BorderSizePixel = 0,
            Parent = overlay,
            ZIndex = 201,
        })
        corner(panel, 14)
        stroke(panel, Nemesis._theme.Border, 1, 0.4)
        padding(panel, 18)
        listLayout(panel, 8)
        new("TextLabel", {
            Text = promptOpts.Title or "",
            Font = Enum.Font.GothamBold,
            TextSize = 16,
            TextColor3 = Nemesis._theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 20),
            Parent = panel,
        })
        new("TextLabel", {
            Text = promptOpts.Content or promptOpts.Text or "",
            Font = Enum.Font.Gotham,
            TextSize = 13,
            TextColor3 = Nemesis._theme.Muted,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextWrapped = true,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Parent = panel,
        })
        local actions = new("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 32),
            Parent = panel,
        })
        new("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            Padding = UDim.new(0, 8),
            Parent = actions,
        })
        for _, a in pairs(promptOpts.Actions or {}) do
            local b = new("TextButton", {
                Text = a.Name or "OK",
                Font = Enum.Font.GothamMedium,
                TextSize = 13,
                TextColor3 = Nemesis._theme.Text,
                BackgroundColor3 = Nemesis._theme.Surface2,
                AutoButtonColor = false,
                Size = UDim2.fromOffset(96, 30),
                Parent = actions,
            })
            corner(b, 8)
            stroke(b, Nemesis._theme.Border, 1, 0.4)
            bindTap(b, function()
                if a.Callback then task.spawn(a.Callback) end
                overlay:Destroy()
            end)
        end
    end

    function Window:CreateTab(arg1, arg2)
        local tabOpts
        if type(arg1) == "table" then tabOpts = arg1
        else tabOpts = { Name = arg1, Icon = arg2 } end
        if type(tabOpts.Icon) == "number" then
            tabOpts.Icon = "rbxassetid://" .. tostring(tabOpts.Icon)
        end
        local Tab = setmetatable({}, { __index = self })
        Tab._window = Window
        Tab._name = tabOpts.Name or "Tab"

        local btn = new("TextButton", {
            Text = "",
            BackgroundTransparency = 1,
            AutoButtonColor = false,
            Size = UDim2.fromOffset(0, 40),
            AutomaticSize = Enum.AutomaticSize.X,
            Parent = Window._tabBar,
        })
        local inner = new("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromOffset(0, 40),
            AutomaticSize = Enum.AutomaticSize.X,
            Parent = btn,
        })
        new("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = inner,
        })
        padding(inner, 0, 10, 0, 10)

        local tabIcon = iconNode(inner, tabOpts.Icon, 16, Nemesis._theme.Muted)
        local tabLbl = new("TextLabel", {
            Text = tabOpts.Name or "Tab",
            Font = Enum.Font.GothamMedium,
            TextSize = 14,
            TextColor3 = Nemesis._theme.Muted,
            BackgroundTransparency = 1,
            Size = UDim2.fromOffset(0, 40),
            AutomaticSize = Enum.AutomaticSize.X,
            Parent = inner,
        })

        local page = new("ScrollingFrame", {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Nemesis._theme.Soft,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Visible = false,
            Parent = Window._content,
        })
        padding(page, 4, 16, 16, 16)
        local stack = new("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Parent = page,
        })
        local stackLayout = listLayout(stack, 10)
        stackLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            page.CanvasSize = UDim2.new(0, 0, 0, stackLayout.AbsoluteContentSize.Y + 24)
        end)

        local function activate()
            for _, t in ipairs(Window._tabs) do
                t._page.Visible = false
                tween(t._lbl, QUICK, { TextColor3 = Nemesis._theme.Muted })
                setIconColor(t._icon, Nemesis._theme.Muted)
            end
            page.Visible = true
            tween(tabLbl, QUICK, { TextColor3 = Nemesis._theme.Text })
            setIconColor(tabIcon, Nemesis._theme.Text)
        end
        bindTap(btn, activate)

        Tab._btn = btn
        Tab._lbl = tabLbl
        Tab._icon = tabIcon
        Tab._page = page
        Tab._stack = stack

        function Tab:CreateSection(secOpts)
            if type(secOpts) == "string" then secOpts = { Name = secOpts } end
            secOpts = secOpts or {}
            local Section = {}

            if secOpts.Name and secOpts.Name ~= "" then
                new("TextLabel", {
                    Text = secOpts.Name,
                    Font = Enum.Font.GothamMedium,
                    TextSize = 13,
                    TextColor3 = Nemesis._theme.Muted,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 18),
                    Parent = Tab._stack,
                })
            end

            local group = new("Frame", {
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Parent = Tab._stack,
            })
            listLayout(group, 8)

            local function track(kind, name, card, fire)
                local w = Tab._window
                if not w or not name or name == "" then return end
                table.insert(w._index, {
                    kind = kind, name = name, section = secOpts.Name,
                    tab = Tab, card = card, fire = fire,
                })
            end

            local function card()
                local c = new("Frame", {
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundColor3 = Nemesis._theme.Surface,
                    BorderSizePixel = 0,
                    Parent = group,
                })
                corner(c, 12)
                stroke(c, Nemesis._theme.Border, 1, 0.5)
                local body = new("Frame", {
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    Parent = c,
                })
                listLayout(body, 0)
                return c, body
            end

            local function rowHead(parent, icon, name, height)
                local h = new("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, height or 56),
                    Parent = parent,
                    LayoutOrder = 1,
                })
                local left = new("Frame", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 18, 0, 0),
                    Size = UDim2.new(0.55, -18, 1, 0),
                    Parent = h,
                })
                new("UIListLayout", {
                    FillDirection = Enum.FillDirection.Horizontal,
                    VerticalAlignment = Enum.VerticalAlignment.Center,
                    Padding = UDim.new(0, 10),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = left,
                })
                iconNode(left, icon, 16, Nemesis._theme.Text)
                new("TextLabel", {
                    Text = name or "",
                    Font = Enum.Font.GothamMedium,
                    TextSize = 15,
                    TextColor3 = Nemesis._theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BackgroundTransparency = 1,
                    Size = UDim2.fromOffset(0, 20),
                    AutomaticSize = Enum.AutomaticSize.X,
                    Parent = left,
                })
                return h
            end

            local function description(parent, text)
                if not text or text == "" then return end
                local d = new("TextLabel", {
                    Text = text,
                    Font = Enum.Font.Gotham,
                    TextSize = 12,
                    TextColor3 = Nemesis._theme.Muted,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Top,
                    TextWrapped = true,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Parent = parent,
                    LayoutOrder = 2,
                })
                padding(d, 0, 18, 14, 18)
            end

            -- ===== Button =====
            function Section:CreateButton(o)
                o = normalize(o, "Button")
                local c, body = card()
                rowHead(body, o.Icon, o.Name or "Button")
                description(body, o.Description)
                local hit = new("TextButton", {
                    Text = "",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 56),
                    Parent = c,
                    ZIndex = 2,
                })
                bindTap(hit, function()
                    tween(c, QUICK, { BackgroundColor3 = Nemesis._theme.Surface2 })
                    task.delay(0.12, function() tween(c, QUICK, { BackgroundColor3 = Nemesis._theme.Surface }) end)
                    if o.Callback then task.spawn(o.Callback) end
                end)
                track("Button", o.Name, c, function() if o.Callback then task.spawn(o.Callback) end end)
                return { Set = function() end }
            end

            -- ===== Toggle =====
            function Section:CreateToggle(o)
                o = normalize(o, "Toggle")
                local state = o.Default or false
                local c, body = card()
                local head = rowHead(body, o.Icon, o.Name or "Toggle")
                description(body, o.Description)

                local pill = new("Frame", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    Size = UDim2.fromOffset(40, 22),
                    Position = UDim2.new(1, -18, 0.5, 0),
                    BackgroundColor3 = Nemesis._theme.Surface2,
                    BorderSizePixel = 0,
                    Parent = head,
                })
                corner(pill, 11)
                stroke(pill, Nemesis._theme.Border, 1, 0.4)
                local dot = new("Frame", {
                    Size = UDim2.fromOffset(16, 16),
                    Position = UDim2.fromOffset(3, 3),
                    BackgroundColor3 = Nemesis._theme.Soft,
                    BorderSizePixel = 0,
                    Parent = pill,
                })
                corner(dot, 8)

                local hit = new("TextButton", {
                    Text = "", BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 56),
                    Parent = c, ZIndex = 2,
                })

                local function render()
                    if state then
                        tween(pill, QUICK, { BackgroundColor3 = Nemesis._theme.Accent })
                        tween(dot, QUICK, { Position = UDim2.fromOffset(21, 3), BackgroundColor3 = Color3.new(1, 1, 1) })
                    else
                        tween(pill, QUICK, { BackgroundColor3 = Nemesis._theme.Surface2 })
                        tween(dot, QUICK, { Position = UDim2.fromOffset(3, 3), BackgroundColor3 = Nemesis._theme.Soft })
                    end
                end
                render()
                local function setVal(v)
                    state = v; render()
                    setFlag(o.Flag, state)
                    if o.Callback then task.spawn(o.Callback, state) end
                end
                bindTap(hit, function() setVal(not state) end)
                registerFlag(o.Flag, setVal, state)
                track("Toggle", o.Name, c, function() setVal(not state) end)
                return { Set = setVal, Get = function() return state end }
            end

            -- ===== Slider =====
            function Section:CreateSlider(o)
                o = normalize(o, "Slider")
                local min, max = o.Min or 0, o.Max or 100
                local value = o.Default or min
                local decimals = o.Decimals or 0
                local step = o.Step
                local c, body = card()
                local head = rowHead(body, o.Icon, o.Name or "Slider")
                description(body, o.Description)

                local pill = new("Frame", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    Size = UDim2.fromOffset(150, 28),
                    Position = UDim2.new(1, -18, 0.5, 0),
                    BackgroundColor3 = Nemesis._theme.Surface2,
                    BorderSizePixel = 0,
                    Parent = head,
                })
                corner(pill, 14)
                stroke(pill, Nemesis._theme.Border, 1, 0.4)
                local fill = new("Frame", {
                    Size = UDim2.fromScale(0, 1),
                    BackgroundColor3 = Nemesis._theme.AccentDim,
                    BorderSizePixel = 0,
                    Parent = pill,
                })
                corner(fill, 14)
                local valLbl = new("TextLabel", {
                    Text = tostring(value)..(o.Suffix or ""),
                    Font = Enum.Font.GothamMedium,
                    TextSize = 13,
                    TextColor3 = Nemesis._theme.Text,
                    BackgroundTransparency = 1,
                    Size = UDim2.fromScale(1, 1),
                    Parent = pill, ZIndex = 2,
                })

                local function setValue(v, fireCb)
                    v = math.clamp(v, min, max)
                    if step then
                        v = math.floor((v - min) / step + 0.5) * step + min
                        v = math.clamp(v, min, max)
                    elseif decimals == 0 then v = math.floor(v + 0.5)
                    else local m = 10^decimals; v = math.floor(v * m + 0.5) / m end
                    value = v
                    local pct = (v - min) / (max - min)
                    fill.Size = UDim2.fromScale(pct, 1)
                    valLbl.Text = (o.Prefix or "")..tostring(v)..(o.Suffix or "")
                    setFlag(o.Flag, v)
                    if fireCb and o.Callback then task.spawn(o.Callback, v) end
                end
                setValue(value, false)
                registerFlag(o.Flag, function(v) setValue(v, true) end, value)

                local dragging = false
                local function update(input)
                    local pct = math.clamp((input.Position.X - pill.AbsolutePosition.X) / pill.AbsoluteSize.X, 0, 1)
                    setValue(min + (max - min) * pct, true)
                end
                pill.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                        dragging = true; update(i)
                    end
                end)
                pill.InputEnded:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)
                UserInputService.InputChanged:Connect(function(i)
                    if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                        update(i)
                    end
                end)
                track("Slider", o.Name, c)
                return { Set = function(v) setValue(v, true) end, Get = function() return value end }
            end

            -- ===== Dropdown =====
            function Section:CreateDropdown(o)
                o = normalize(o, "Dropdown")
                local options = o.Options or {}
                local multi = o.Multi == true
                local value = o.Default or (multi and {} or options[1])
                local open = false
                local c, body = card()
                local head = rowHead(body, o.Icon, o.Name or "Dropdown")
                description(body, o.Description)

                local pill = new("Frame", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    Size = UDim2.fromOffset(140, 28),
                    Position = UDim2.new(1, -18, 0.5, 0),
                    BackgroundColor3 = Nemesis._theme.Surface2,
                    BorderSizePixel = 0,
                    Parent = head,
                })
                corner(pill, 14)
                stroke(pill, Nemesis._theme.Border, 1, 0.4)
                local valLbl = new("TextLabel", {
                    Text = multi and ("("..#value..")") or tostring(value or ""),
                    Font = Enum.Font.GothamMedium,
                    TextSize = 13,
                    TextColor3 = Nemesis._theme.Text,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 12, 0, 0),
                    Size = UDim2.new(1, -28, 1, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    Parent = pill,
                })
                local arrow = new("TextLabel", {
                    Text = "\u{25BE}",
                    Font = Enum.Font.GothamBold,
                    TextSize = 12,
                    TextColor3 = Nemesis._theme.Muted,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -16, 0, 0),
                    Size = UDim2.new(0, 12, 1, 0),
                    Parent = pill,
                })

                local listHolder = new("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Parent = body,
                    Visible = false,
                    LayoutOrder = 10,
                })
                padding(listHolder, 0, 18, 14, 18)
                local list = new("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Parent = listHolder,
                })
                listLayout(list, 4)

                local function isSelected(opt)
                    if multi then
                        for _, v in ipairs(value) do if v == opt then return true end end
                        return false
                    end
                    return value == opt
                end

                local function refreshLabel()
                    if multi then
                        valLbl.Text = #value == 0 and "None" or ("("..#value..")")
                    else
                        valLbl.Text = tostring(value or "")
                    end
                end

                local function rebuild()
                    for _, ch in ipairs(list:GetChildren()) do
                        if ch:IsA("TextButton") then ch:Destroy() end
                    end
                    for _, opt in ipairs(options) do
                        local sel = isSelected(opt)
                        local item = new("TextButton", {
                            Text = "",
                            BackgroundColor3 = sel and Nemesis._theme.AccentDim or Nemesis._theme.Surface2,
                            AutoButtonColor = false,
                            Size = UDim2.new(1, 0, 0, 30),
                            Parent = list,
                        })
                        corner(item, 8)
                        new("TextLabel", {
                            Text = tostring(opt),
                            Font = Enum.Font.GothamMedium,
                            TextSize = 13,
                            TextColor3 = Nemesis._theme.Text,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            BackgroundTransparency = 1,
                            Position = UDim2.new(0, 12, 0, 0),
                            Size = UDim2.new(1, -24, 1, 0),
                            Parent = item,
                        })
                        if sel and multi then
                            new("TextLabel", {
                                Text = "\u{2713}",
                                Font = Enum.Font.GothamBold,
                                TextSize = 13,
                                TextColor3 = Color3.new(1, 1, 1),
                                BackgroundTransparency = 1,
                                Position = UDim2.new(1, -24, 0, 0),
                                Size = UDim2.fromOffset(16, 30),
                                Parent = item,
                            })
                        end
                        bindTap(item, function()
                            if multi then
                                local removed = false
                                for i, v in ipairs(value) do
                                    if v == opt then table.remove(value, i); removed = true; break end
                                end
                                if not removed then table.insert(value, opt) end
                            else
                                value = opt
                                open = false
                                listHolder.Visible = false
                                tween(arrow, QUICK, { Rotation = 0 })
                            end
                            refreshLabel()
                            setFlag(o.Flag, value)
                            if o.Callback then task.spawn(o.Callback, value) end
                            rebuild()
                        end)
                    end
                end
                rebuild()
                refreshLabel()
                registerFlag(o.Flag, function(v)
                    value = v; refreshLabel(); rebuild()
                    if o.Callback then task.spawn(o.Callback, v) end
                end, value)

                local hit = new("TextButton", {
                    Text = "", BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 56),
                    Parent = c, ZIndex = 2,
                })
                bindTap(hit, function()
                    open = not open
                    listHolder.Visible = open
                    tween(arrow, QUICK, { Rotation = open and 180 or 0 })
                end)

                track("Dropdown", o.Name, c)
                return {
                    Set = function(v) value = v; refreshLabel(); rebuild()
                        if o.Callback then task.spawn(o.Callback, v) end end,
                    Get = function() return value end,
                    Refresh = function(newOpts, newDefault)
                        options = newOpts or {}
                        if newDefault ~= nil then value = newDefault end
                        refreshLabel(); rebuild()
                    end,
                }
            end

            -- ===== Input =====
            function Section:CreateInput(o)
                o = normalize(o, "Input")
                local c, body = card()
                local head = rowHead(body, o.Icon, o.Name or "Input")
                description(body, o.Description)
                local pill = new("Frame", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    Size = UDim2.fromOffset(160, 28),
                    Position = UDim2.new(1, -18, 0.5, 0),
                    BackgroundColor3 = Nemesis._theme.Surface2,
                    BorderSizePixel = 0,
                    Parent = head,
                })
                corner(pill, 14)
                stroke(pill, Nemesis._theme.Border, 1, 0.4)
                local box = new("TextBox", {
                    Text = o.Default or "",
                    PlaceholderText = o.Placeholder or "",
                    Font = Enum.Font.GothamMedium,
                    TextSize = 13,
                    TextColor3 = Nemesis._theme.Text,
                    PlaceholderColor3 = Nemesis._theme.Muted,
                    BackgroundTransparency = 1,
                    ClearTextOnFocus = false,
                    Position = UDim2.new(0, 12, 0, 0),
                    Size = UDim2.new(1, -24, 1, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = pill,
                })
                box.FocusLost:Connect(function(enter)
                    setFlag(o.Flag, box.Text)
                    if o.Callback then task.spawn(o.Callback, box.Text, enter) end
                    if o.RemoveTextAfterFocusLost then box.Text = "" end
                end)
                registerFlag(o.Flag, function(v)
                    box.Text = tostring(v)
                    if o.Callback then task.spawn(o.Callback, box.Text, false) end
                end, box.Text)
                track("Input", o.Name, c)
                return { Set = function(v) box.Text = v end, Get = function() return box.Text end }
            end

            -- ===== Keybind =====
            function Section:CreateKeybind(o)
                o = normalize(o, "Keybind")
                local key = o.Default or Enum.KeyCode.Unknown
                local listening = false
                local holdMode = o.HoldToInteract or o.Mode == "Hold"
                local c, body = card()
                local head = rowHead(body, o.Icon, o.Name or "Keybind")
                description(body, o.Description)

                local kbBox = new("TextLabel", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    Text = key.Name,
                    Font = Enum.Font.GothamMedium,
                    TextSize = 13,
                    TextColor3 = Nemesis._theme.Text,
                    BackgroundColor3 = Nemesis._theme.Surface2,
                    Position = UDim2.new(1, -18, 0.5, 0),
                    Size = UDim2.fromOffset(80, 28),
                    Parent = head,
                })
                corner(kbBox, 14)
                stroke(kbBox, Nemesis._theme.Border, 1, 0.4)

                local hit = new("TextButton", {
                    Text = "", BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 56),
                    Parent = c, ZIndex = 2,
                })
                bindTap(hit, function()
                    listening = true
                    kbBox.Text = "..."
                    local conn
                    conn = UserInputService.InputBegan:Connect(function(input, gpe)
                        if gpe then return end
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            key = input.KeyCode
                            kbBox.Text = key.Name
                            listening = false
                            setFlag(o.Flag, key)
                            if o.Callback then task.spawn(o.Callback, key) end
                            conn:Disconnect()
                        end
                    end)
                end)

                UserInputService.InputBegan:Connect(function(input, gpe)
                    if gpe or listening then return end
                    if input.KeyCode == key and o.Callback then
                        task.spawn(o.Callback, key, holdMode and true or nil)
                    end
                end)
                if holdMode then
                    UserInputService.InputEnded:Connect(function(input, gpe)
                        if gpe or listening then return end
                        if input.KeyCode == key and o.Callback then
                            task.spawn(o.Callback, key, false)
                        end
                    end)
                end
                registerFlag(o.Flag, function(k)
                    key = k; kbBox.Text = k.Name
                    if o.Callback then task.spawn(o.Callback, k) end
                end, key)
                track("Keybind", o.Name, c)
                return { Set = function(k) key = k; kbBox.Text = k.Name end, Get = function() return key end }
            end

            -- ===== Colorpicker =====
            function Section:CreateColorpicker(o)
                o = normalize(o, "ColorPicker")
                local color = o.Default or Color3.fromRGB(255, 255, 255)
                local open = false
                local c, body = card()
                local head = rowHead(body, o.Icon, o.Name or "Color")
                description(body, o.Description)

                local swatch = new("Frame", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    Size = UDim2.fromOffset(40, 28),
                    Position = UDim2.new(1, -18, 0.5, 0),
                    BackgroundColor3 = color,
                    BorderSizePixel = 0,
                    Parent = head,
                })
                corner(swatch, 14)
                stroke(swatch, Nemesis._theme.Border, 1, 0.4)

                local panelHolder = new("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Parent = body,
                    Visible = false,
                    LayoutOrder = 10,
                })
                padding(panelHolder, 0, 18, 14, 18)
                local panel = new("Frame", {
                    Size = UDim2.new(1, 0, 0, 130),
                    BackgroundColor3 = Nemesis._theme.Surface2,
                    BorderSizePixel = 0,
                    Parent = panelHolder,
                })
                corner(panel, 10)
                padding(panel, 10)

                local sat = new("ImageLabel", {
                    Image = "rbxassetid://4155801252",
                    Size = UDim2.new(1, -90, 1, 0),
                    BackgroundColor3 = Color3.new(1, 0, 0),
                    BorderSizePixel = 0,
                    Parent = panel,
                })
                corner(sat, 6)
                local hueBar = new("Frame", {
                    Position = UDim2.new(1, -78, 0, 0),
                    Size = UDim2.new(0, 18, 1, 0),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel = 0,
                    Parent = panel,
                })
                corner(hueBar, 6)
                new("UIGradient", {
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255,0,0)),
                        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255,255,0)),
                        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0,255,0)),
                        ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0,255,255)),
                        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0,0,255)),
                        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255,0,255)),
                        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255,0,0)),
                    }),
                    Rotation = 90,
                    Parent = hueBar,
                })
                local preview = new("Frame", {
                    Position = UDim2.new(1, -52, 0, 0),
                    Size = UDim2.new(0, 52, 1, 0),
                    BackgroundColor3 = color,
                    BorderSizePixel = 0,
                    Parent = panel,
                })
                corner(preview, 6)

                local h, s, v = Color3.toHSV(color)
                local function apply()
                    color = Color3.fromHSV(h, s, v)
                    sat.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                    preview.BackgroundColor3 = color
                    swatch.BackgroundColor3 = color
                    setFlag(o.Flag, color)
                    if o.Callback then task.spawn(o.Callback, color) end
                end
                apply()
                registerFlag(o.Flag, function(col) color = col; h, s, v = Color3.toHSV(col); apply() end, color)

                local satDrag, hueDrag = false, false
                sat.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then satDrag = true end
                end)
                sat.InputEnded:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then satDrag = false end
                end)
                hueBar.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then hueDrag = true end
                end)
                hueBar.InputEnded:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then hueDrag = false end
                end)
                UserInputService.InputChanged:Connect(function(i)
                    if i.UserInputType ~= Enum.UserInputType.MouseMovement and i.UserInputType ~= Enum.UserInputType.Touch then return end
                    if satDrag then
                        local x = math.clamp((i.Position.X - sat.AbsolutePosition.X) / sat.AbsoluteSize.X, 0, 1)
                        local y = math.clamp((i.Position.Y - sat.AbsolutePosition.Y) / sat.AbsoluteSize.Y, 0, 1)
                        s, v = x, 1 - y; apply()
                    elseif hueDrag then
                        local y = math.clamp((i.Position.Y - hueBar.AbsolutePosition.Y) / hueBar.AbsoluteSize.Y, 0, 1)
                        h = y; apply()
                    end
                end)

                local hit = new("TextButton", {
                    Text = "", BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 56),
                    Parent = c, ZIndex = 2,
                })
                bindTap(hit, function()
                    open = not open
                    panelHolder.Visible = open
                end)
                track("Color", o.Name, c)
                return { Set = function(col) color = col; h, s, v = Color3.toHSV(col); apply() end, Get = function() return color end }
            end

            -- ===== Stat =====
            function Section:CreateStat(o)
                o = o or {}
                local c = new("Frame", {
                    Size = UDim2.new(1, 0, 0, 80),
                    BackgroundColor3 = Nemesis._theme.AccentDim,
                    BorderSizePixel = 0,
                    Parent = group,
                })
                corner(c, 12)
                stroke(c, Nemesis._theme.Accent, 1, 0.3)
                new("UIGradient", {
                    Color = ColorSequence.new(Nemesis._theme.Accent, Nemesis._theme.AccentDim),
                    Transparency = NumberSequence.new(0.15, 0.55),
                    Rotation = 90,
                    Parent = c,
                })
                local left = new("Frame", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 18, 0, 10),
                    Size = UDim2.new(1, -36, 0, 22),
                    Parent = c,
                })
                new("UIListLayout", {
                    FillDirection = Enum.FillDirection.Horizontal,
                    VerticalAlignment = Enum.VerticalAlignment.Center,
                    Padding = UDim.new(0, 10),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = left,
                })
                iconNode(left, o.Icon, 18, Color3.new(1, 1, 1))
                new("TextLabel", {
                    Text = o.Name or "Stat",
                    Font = Enum.Font.GothamBold,
                    TextSize = 16,
                    TextColor3 = Color3.new(1, 1, 1),
                    BackgroundTransparency = 1,
                    Size = UDim2.fromOffset(0, 22),
                    AutomaticSize = Enum.AutomaticSize.X,
                    Parent = left,
                })
                local valueLbl = new("TextLabel", {
                    Text = tostring(o.Value or ""),
                    Font = Enum.Font.GothamBold,
                    TextSize = 22,
                    TextColor3 = Color3.new(1, 1, 1),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 18, 0, 40),
                    Size = UDim2.new(1, -130, 0, 28),
                    Parent = c,
                })
                local trendLbl = new("TextLabel", {
                    Text = tostring(o.Trend or ""),
                    Font = Enum.Font.GothamBold,
                    TextSize = 14,
                    TextColor3 = Color3.new(1, 1, 1),
                    TextXAlignment = Enum.TextXAlignment.Right,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -110, 0, 44),
                    Size = UDim2.new(0, 92, 0, 20),
                    Parent = c,
                })
                return {
                    Set = function(v) valueLbl.Text = tostring(v) end,
                    SetTrend = function(t) trendLbl.Text = tostring(t) end,
                }
            end

            -- ===== Label =====
            function Section:CreateLabel(o)
                if type(o) == "string" then o = { Text = o } end
                o = o or {}
                local lbl = new("TextLabel", {
                    Text = o.Text or o.Content or "",
                    Font = Enum.Font.Gotham,
                    TextSize = 12,
                    TextColor3 = Nemesis._theme.Muted,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Top,
                    TextWrapped = true,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Parent = group,
                })
                return { Set = function(t) lbl.Text = t end }
            end

            -- ===== Paragraph =====
            function Section:CreateParagraph(o)
                o = normalize(o, "Paragraph")
                local c = new("Frame", {
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundColor3 = Nemesis._theme.Surface,
                    BorderSizePixel = 0,
                    Parent = group,
                })
                corner(c, 12)
                stroke(c, Nemesis._theme.Border, 1, 0.5)
                padding(c, 14, 18, 14, 18)
                local title = new("TextLabel", {
                    Text = o.Title or "",
                    Font = Enum.Font.GothamBold,
                    TextSize = 14,
                    TextColor3 = Nemesis._theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 18),
                    Parent = c,
                })
                local body = new("TextLabel", {
                    Text = o.Text or "",
                    Font = Enum.Font.Gotham,
                    TextSize = 12,
                    TextColor3 = Nemesis._theme.Muted,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Top,
                    TextWrapped = true,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 22),
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Parent = c,
                })
                return {
                    Set = function(t) body.Text = t end,
                    SetTitle = function(t) title.Text = t end,
                }
            end

            Section.CreateColorPicker = Section.CreateColorpicker
            Tab._activeSection = Section
            return Section
        end

        local function proxy(name)
            return function(self, opts)
                local sec = self._activeSection or self:CreateSection("")
                return sec[name](sec, opts)
            end
        end
        Tab.CreateButton      = proxy("CreateButton")
        Tab.CreateToggle      = proxy("CreateToggle")
        Tab.CreateSlider      = proxy("CreateSlider")
        Tab.CreateDropdown    = proxy("CreateDropdown")
        Tab.CreateInput       = proxy("CreateInput")
        Tab.CreateKeybind     = proxy("CreateKeybind")
        Tab.CreateColorpicker = proxy("CreateColorpicker")
        Tab.CreateColorPicker = Tab.CreateColorpicker
        Tab.CreateStat        = proxy("CreateStat")
        Tab.CreateLabel       = proxy("CreateLabel")
        Tab.CreateParagraph   = proxy("CreateParagraph")

        table.insert(Window._tabs, Tab)
        if #Window._tabs == 1 then activate() end
        return Tab
    end

    -- Built-in settings flyout
    local settingsPage
    bindTap(settingsBtn, function()
        if settingsPage and settingsPage.Visible then settingsPage.Visible = false; return end
        if not settingsPage then
            settingsPage = new("Frame", {
                Position = UDim2.new(0, 0, 0, 110),
                Size = UDim2.new(1, 0, 1, -118),
                BackgroundColor3 = Nemesis._theme.Background,
                BorderSizePixel = 0,
                Parent = Window._main,
                ZIndex = 5,
            })
            padding(settingsPage, 16)
            local stack = new("Frame", {
                Size = UDim2.fromScale(1, 1),
                BackgroundTransparency = 1,
                Parent = settingsPage,
            })
            listLayout(stack, 8)
            new("TextLabel", {
                Text = "Settings",
                Font = Enum.Font.GothamBold,
                TextSize = 18,
                TextColor3 = Nemesis._theme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 26),
                Parent = stack,
            })
            new("TextLabel", {
                Text = "Theme presets",
                Font = Enum.Font.Gotham,
                TextSize = 13,
                TextColor3 = Nemesis._theme.Muted,
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 18),
                Parent = stack,
            })
            for _, name in ipairs(Nemesis:ListThemes()) do
                local preset = THEME_PRESETS[name]
                local r = new("TextButton", {
                    Text = "",
                    BackgroundColor3 = Nemesis._theme.Surface,
                    AutoButtonColor = false,
                    Size = UDim2.new(1, 0, 0, 44),
                    Parent = stack,
                })
                corner(r, 10)
                stroke(r, Nemesis._theme.Border, 1, 0.5)
                local sw = new("Frame", {
                    BackgroundColor3 = preset.Accent,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 12, 0.5, -10),
                    Size = UDim2.fromOffset(20, 20),
                    Parent = r,
                })
                corner(sw, 10)
                new("TextLabel", {
                    Text = name,
                    Font = Enum.Font.GothamMedium,
                    TextSize = 14,
                    TextColor3 = Nemesis._theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 42, 0, 0),
                    Size = UDim2.new(1, -52, 1, 0),
                    Parent = r,
                })
                bindTap(r, function() Nemesis:UseTheme(name) end)
            end
        end
        settingsPage.Visible = true
    end)

    function Window:Watermark(wmOpts)
        wmOpts = wmOpts or {}
        if Window._watermark then Window._watermark:Destroy() end
        local wm = new("Frame", {
            Position = wmOpts.Position or UDim2.new(0, 16, 0, 16),
            Size = UDim2.fromOffset(0, 30),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundColor3 = Nemesis._theme.Surface,
            BorderSizePixel = 0,
            Parent = Window._screen,
        })
        corner(wm, 8)
        stroke(wm, Nemesis._theme.Border, 1, 0.4)
        new("Frame", {
            Size = UDim2.new(0, 2, 1, -10),
            Position = UDim2.new(0, 6, 0, 5),
            BackgroundColor3 = Nemesis._theme.Accent,
            BorderSizePixel = 0,
            Parent = wm,
        })
        local row = new("Frame", {
            Position = UDim2.new(0, 14, 0, 0),
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 0, 1, 0),
            AutomaticSize = Enum.AutomaticSize.X,
            Parent = wm,
        })
        new("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = row,
        })
        padding(row, 0, 12, 0, 0)
        local function chip(text, order)
            return new("TextLabel", {
                Text = text,
                Font = Enum.Font.GothamMedium,
                TextSize = 12,
                TextColor3 = Nemesis._theme.Text,
                BackgroundTransparency = 1,
                Size = UDim2.fromOffset(0, 30),
                AutomaticSize = Enum.AutomaticSize.X,
                LayoutOrder = order,
                Parent = row,
            })
        end
        chip(wmOpts.Title or wmOpts.Name or "Nemesis", 1)
        local fpsLbl = wmOpts.ShowFPS ~= false and chip("FPS 0", 2) or nil
        local pingLbl = wmOpts.ShowPing ~= false and chip("PING 0", 3) or nil
        local timeLbl = wmOpts.ShowTime ~= false and chip("00:00:00", 4) or nil
        makeDraggable(wm)

        Window._watermark = wm
        local frames, last = 0, tick()
        local conn = RunService.RenderStepped:Connect(function()
            frames = frames + 1
            local now = tick()
            if now - last >= 0.5 then
                if fpsLbl then fpsLbl.Text = string.format("FPS %d", math.floor(frames / (now - last))) end
                frames, last = 0, now
                if pingLbl then
                    local stats = game:FindService("Stats")
                    local p = stats and stats.Network and stats.Network.ServerStatsItem["Data Ping"]
                    if p then pingLbl.Text = string.format("PING %d", math.floor(p:GetValue())) end
                end
                if timeLbl then timeLbl.Text = os.date("%H:%M:%S") end
            end
        end)
        wm.AncestryChanged:Connect(function(_, parent) if not parent then conn:Disconnect() end end)

        return {
            Set = function(t) row:FindFirstChildOfClass("TextLabel").Text = t end,
            Destroy = function() wm:Destroy() end,
        }
    end

    function Window:Destroy() screen:Destroy() end
    return Window
end

-- ===== Notify =====
local notifyHolder
function Nemesis:Notify(opts)
    opts = normalize(opts, "Notify")
    local parent = self._lastScreen
    if not parent then return end
    if not notifyHolder or notifyHolder.Parent ~= parent then
        notifyHolder = new("Frame", {
            Name = "NotifyHolder",
            AnchorPoint = Vector2.new(1, 1),
            Position = UDim2.new(1, -16, 1, -16),
            Size = UDim2.new(0, 320, 1, -32),
            BackgroundTransparency = 1,
            Parent = parent,
        })
        new("UIListLayout", {
            Padding = UDim.new(0, 8),
            VerticalAlignment = Enum.VerticalAlignment.Bottom,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = notifyHolder,
        })
    end
    local hasActions = opts.Actions and next(opts.Actions) ~= nil
    local n = new("Frame", {
        Size = UDim2.new(1, 0, 0, hasActions and 96 or 64),
        BackgroundColor3 = self._theme.Surface,
        BorderSizePixel = 0,
        Parent = notifyHolder,
    })
    corner(n, 12)
    stroke(n, self._theme.Border, 1, 0.4)
    new("Frame", {
        Size = UDim2.new(0, 3, 0, 40),
        Position = UDim2.new(0, 8, 0, 12),
        BackgroundColor3 = self._theme.Accent,
        BorderSizePixel = 0,
        Parent = n,
    })
    local leftPad = 20
    if opts.Image then
        local img = new("ImageLabel", {
            Image = opts.Image,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 18, 0, 14),
            Size = UDim2.fromOffset(28, 28),
            ImageColor3 = self._theme.Accent,
            Parent = n,
        })
        corner(img, 6)
        leftPad = 56
    end
    new("TextLabel", {
        Text = opts.Title or "",
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = self._theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, leftPad, 0, 10),
        Size = UDim2.new(1, -leftPad - 12, 0, 18),
        Parent = n,
    })
    new("TextLabel", {
        Text = opts.Text or "",
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = self._theme.Muted,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, leftPad, 0, 30),
        Size = UDim2.new(1, -leftPad - 12, 0, hasActions and 22 or 28),
        Parent = n,
    })
    if hasActions then
        local row = new("Frame", {
            Position = UDim2.new(0, leftPad, 1, -30),
            Size = UDim2.new(1, -leftPad - 12, 0, 24),
            BackgroundTransparency = 1,
            Parent = n,
        })
        new("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            Padding = UDim.new(0, 6),
            Parent = row,
        })
        for _, action in pairs(opts.Actions) do
            local b = new("TextButton", {
                Text = action.Name or "OK",
                Font = Enum.Font.GothamMedium,
                TextSize = 12,
                TextColor3 = self._theme.Text,
                BackgroundColor3 = self._theme.Surface2,
                AutoButtonColor = false,
                Size = UDim2.fromOffset(72, 24),
                Parent = row,
            })
            corner(b, 6)
            stroke(b, self._theme.Border, 1, 0.4)
            bindTap(b, function()
                if action.Callback then task.spawn(action.Callback) end
                n:Destroy()
            end)
        end
    end
    task.delay(opts.Duration or 3, function()
        if not n.Parent then return end
        tween(n, SMOOTH, { BackgroundTransparency = 1 })
        for _, d in ipairs(n:GetDescendants()) do
            if d:IsA("TextLabel") then tween(d, SMOOTH, { TextTransparency = 1 }) end
            if d:IsA("UIStroke") then tween(d, SMOOTH, { Transparency = 1 }) end
            if d:IsA("ImageLabel") then tween(d, SMOOTH, { ImageTransparency = 1 }) end
        end
        task.wait(0.3)
        if n.Parent then n:Destroy() end
    end)
end

function Nemesis:SetTheme(t)
    for k, v in pairs(t) do self._theme[k] = v end
end

function Nemesis:UseTheme(name)
    local preset = THEME_PRESETS[name]
    if not preset then return false end
    self:SetTheme(preset)
    return true
end

function Nemesis:ListThemes()
    local names = {}
    for k in pairs(THEME_PRESETS) do table.insert(names, k) end
    table.sort(names)
    return names
end

function Nemesis:GetFlag(name)
    return self._flags[name]
end

function Nemesis:LoadConfiguration()
    local cfg = self._configOpts
    if not cfg or not cfg.Enabled then return false, "configuration saving disabled" end
    return self:LoadConfig(cfg.FileName or "config")
end

function Nemesis:SaveConfiguration()
    local cfg = self._configOpts
    if not cfg or not cfg.Enabled then return false, "configuration saving disabled" end
    return self:SaveConfig(cfg.FileName or "config")
end

return Nemesis
