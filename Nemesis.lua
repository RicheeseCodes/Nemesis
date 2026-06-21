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
                main.Visible = not main.Visible
            end
            pressStart = nil
        end)
    end

    -- Keybind toggle
    local toggleKey = opts.Keybind or Enum.KeyCode.RightShift
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == toggleKey then main.Visible = not main.Visible end
    end)

    Window._screen = screen
    Window._main = main
    Window._tabBar = tabBar
    Window._content = contentWrap
    Window._tabs = {}
    Window._isPhone = isPhone

    function Window:CreateTab(tabOpts)
        tabOpts = tabOpts or {}
        local Tab = setmetatable({}, { __index = self })

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
            secOpts = secOpts or {}
            local Section = {}

            if secOpts.Name then
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
                o = o or {}
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
                return { Set = function() end }
            end

            -- ===== Toggle =====
            function Section:CreateToggle(o)
                o = o or {}
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
                    if o.Flag then Nemesis._flags[o.Flag] = state end
                    if o.Callback then task.spawn(o.Callback, state) end
                end
                bindTap(hit, function() setVal(not state) end)
                registerFlag(o.Flag, setVal, state)
                return { Set = setVal, Get = function() return state end }
            end

            -- ===== Slider =====
            function Section:CreateSlider(o)
                o = o or {}
                local min, max = o.Min or 0, o.Max or 100
                local value = o.Default or min
                local decimals = o.Decimals or 0
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
                    if decimals == 0 then v = math.floor(v + 0.5)
                    else local m = 10^decimals; v = math.floor(v * m + 0.5) / m end
                    value = v
                    local pct = (v - min) / (max - min)
                    fill.Size = UDim2.fromScale(pct, 1)
                    valLbl.Text = (o.Prefix or "")..tostring(v)..(o.Suffix or "")
                    if o.Flag then Nemesis._flags[o.Flag] = v end
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
                return { Set = function(v) setValue(v, true) end, Get = function() return value end }
            end

            -- ===== Dropdown =====
            function Section:CreateDropdown(o)
                o = o or {}
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
                            if o.Flag then Nemesis._flags[o.Flag] = value end
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
                o = o or {}
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
                    if o.Flag then Nemesis._flags[o.Flag] = box.Text end
                    if o.Callback then task.spawn(o.Callback, box.Text, enter) end
                end)
                registerFlag(o.Flag, function(v)
                    box.Text = tostring(v)
                    if o.Callback then task.spawn(o.Callback, box.Text, false) end
                end, box.Text)
                return { Set = function(v) box.Text = v end, Get = function() return box.Text end }
            end

            -- ===== Keybind =====
            function Section:CreateKeybind(o)
                o = o or {}
                local key = o.Default or Enum.KeyCode.Unknown
                local listening = false
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
                            if o.Flag then Nemesis._flags[o.Flag] = key end
                            if o.Callback then task.spawn(o.Callback, key) end
                            conn:Disconnect()
                        end
                    end)
                end)

                UserInputService.InputBegan:Connect(function(input, gpe)
                    if gpe or listening then return end
                    if input.KeyCode == key and o.Callback then task.spawn(o.Callback, key) end
                end)
                registerFlag(o.Flag, function(k)
                    key = k; kbBox.Text = k.Name
                    if o.Callback then task.spawn(o.Callback, k) end
                end, key)
                return { Set = function(k) key = k; kbBox.Text = k.Name end, Get = function() return key end }
            end

            -- ===== Colorpicker =====
            function Section:CreateColorpicker(o)
                o = o or {}
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
                    if o.Flag then Nemesis._flags[o.Flag] = color end
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
                o = o or {}
                local lbl = new("TextLabel", {
                    Text = o.Text or "",
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
                o = o or {}
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

            return Section
        end

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
                Text = "Theme accent",
                Font = Enum.Font.Gotham,
                TextSize = 13,
                TextColor3 = Nemesis._theme.Muted,
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 18),
                Parent = stack,
            })
            local row = new("Frame", {
                Size = UDim2.new(1, 0, 0, 36),
                BackgroundTransparency = 1,
                Parent = stack,
            })
            new("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                Padding = UDim.new(0, 8),
                Parent = row,
            })
            local presets = {
                Color3.fromRGB(46, 196, 132),
                Color3.fromRGB(138, 92, 246),
                Color3.fromRGB(232, 76, 92),
                Color3.fromRGB(70, 130, 240),
                Color3.fromRGB(240, 168, 60),
            }
            for _, col in ipairs(presets) do
                local sw = new("TextButton", {
                    Text = "",
                    BackgroundColor3 = col,
                    AutoButtonColor = false,
                    Size = UDim2.fromOffset(36, 36),
                    Parent = row,
                })
                corner(sw, 8)
                stroke(sw, Nemesis._theme.Border, 1, 0.4)
                bindTap(sw, function() Nemesis:SetTheme({ Accent = col }) end)
            end
        end
        settingsPage.Visible = true
    end)

    function Window:Destroy() screen:Destroy() end
    return Window
end

-- ===== Notify =====
local notifyHolder
function Nemesis:Notify(opts)
    opts = opts or {}
    local parent = self._lastScreen
    if not parent then return end
    if not notifyHolder or notifyHolder.Parent ~= parent then
        notifyHolder = new("Frame", {
            Name = "NotifyHolder",
            AnchorPoint = Vector2.new(1, 1),
            Position = UDim2.new(1, -16, 1, -16),
            Size = UDim2.new(0, 300, 1, -32),
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
    local n = new("Frame", {
        Size = UDim2.new(1, 0, 0, 60),
        BackgroundColor3 = self._theme.Surface,
        BorderSizePixel = 0,
        Parent = notifyHolder,
    })
    corner(n, 12)
    stroke(n, self._theme.Border, 1, 0.4)
    new("Frame", {
        Size = UDim2.new(0, 3, 1, -16),
        Position = UDim2.new(0, 8, 0, 8),
        BackgroundColor3 = self._theme.Accent,
        BorderSizePixel = 0,
        Parent = n,
    })
    new("TextLabel", {
        Text = opts.Title or "",
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = self._theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 20, 0, 8),
        Size = UDim2.new(1, -28, 0, 18),
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
        Position = UDim2.new(0, 20, 0, 28),
        Size = UDim2.new(1, -28, 0, 28),
        Parent = n,
    })
    task.delay(opts.Duration or 3, function()
        tween(n, SMOOTH, { BackgroundTransparency = 1 })
        for _, d in ipairs(n:GetDescendants()) do
            if d:IsA("TextLabel") then tween(d, SMOOTH, { TextTransparency = 1 }) end
            if d:IsA("UIStroke") then tween(d, SMOOTH, { Transparency = 1 }) end
        end
        task.wait(0.3)
        n:Destroy()
    end)
end

function Nemesis:SetTheme(t)
    for k, v in pairs(t) do self._theme[k] = v end
end

function Nemesis:GetFlag(name)
    return self._flags[name]
end

return Nemesis
