--[[
    Nemesis UI v0.1
    A UI library for Roblox executors. Mobile and desktop.
    https://github.com/siriusxcontact/Nemesis
]]

local Nemesis = {}
Nemesis.__index = Nemesis
Nemesis._flags = {}
Nemesis._theme = {
    Background = Color3.fromRGB(16, 16, 20),
    Surface    = Color3.fromRGB(22, 22, 28),
    Surface2   = Color3.fromRGB(28, 28, 36),
    Border     = Color3.fromRGB(38, 38, 48),
    Accent     = Color3.fromRGB(138, 92, 246),
    Text       = Color3.fromRGB(235, 235, 240),
    Muted      = Color3.fromRGB(140, 140, 155),
    Danger     = Color3.fromRGB(232, 76, 92),
}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TextService = game:GetService("TextService")

local LocalPlayer = Players.LocalPlayer
local IsMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled

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

local QUICK = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local SMOOTH = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

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

local function corner(parent, radius)
    return new("UICorner", { CornerRadius = UDim.new(0, radius or 6), Parent = parent })
end

local function stroke(parent, color, thickness)
    return new("UIStroke", {
        Color = color or Nemesis._theme.Border,
        Thickness = thickness or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent,
    })
end

local function padding(parent, p)
    return new("UIPadding", {
        PaddingTop = UDim.new(0, p),
        PaddingBottom = UDim.new(0, p),
        PaddingLeft = UDim.new(0, p),
        PaddingRight = UDim.new(0, p),
        Parent = parent,
    })
end

local function listLayout(parent, padPx, align)
    return new("UIListLayout", {
        Padding = UDim.new(0, padPx or 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = align or Enum.HorizontalAlignment.Left,
        Parent = parent,
    })
end

local function autoResize(scrolling, layout)
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrolling.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 8)
    end)
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

    local viewport = workspace.CurrentCamera.ViewportSize
    local defaultW = IsMobile and math.min(viewport.X - 24, 480) or 560
    local defaultH = IsMobile and math.min(viewport.Y - 80, 360) or 400

    local main = new("Frame", {
        Name = "Main",
        Size = UDim2.fromOffset(defaultW, defaultH),
        Position = UDim2.new(0.5, -defaultW/2, 0.5, -defaultH/2),
        BackgroundColor3 = Nemesis._theme.Background,
        BorderSizePixel = 0,
        Parent = screen,
    })
    corner(main, 10)
    stroke(main, Nemesis._theme.Border, 1)

    -- Header
    local header = new("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundTransparency = 1,
        Parent = main,
    })
    new("TextLabel", {
        Text = opts.Name or "Nemesis",
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        TextColor3 = Nemesis._theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 0),
        Size = UDim2.new(0, 200, 1, 0),
        Parent = header,
    })
    if opts.Subtitle then
        new("TextLabel", {
            Text = opts.Subtitle,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextColor3 = Nemesis._theme.Muted,
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 14, 0, 22),
            Size = UDim2.new(0, 200, 0, 14),
            Parent = header,
        })
    end

    -- Close button
    local closeBtn = new("TextButton", {
        Text = "",
        Size = UDim2.fromOffset(24, 24),
        Position = UDim2.new(1, -32, 0, 9),
        BackgroundColor3 = Nemesis._theme.Surface,
        AutoButtonColor = false,
        Parent = header,
    })
    corner(closeBtn, 6)
    new("TextLabel", {
        Text = "x",
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = Nemesis._theme.Muted,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Parent = closeBtn,
    })

    -- Sidebar
    local sidebar = new("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 130, 1, -52),
        Position = UDim2.new(0, 8, 0, 44),
        BackgroundColor3 = Nemesis._theme.Surface,
        BorderSizePixel = 0,
        Parent = main,
    })
    corner(sidebar, 8)
    local tabList = new("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Parent = sidebar,
    })
    padding(tabList, 6)
    listLayout(tabList, 4)

    -- Content area
    local content = new("Frame", {
        Name = "Content",
        Position = UDim2.new(0, 148, 0, 44),
        Size = UDim2.new(1, -156, 1, -52),
        BackgroundTransparency = 1,
        Parent = main,
    })

    -- Drag (desktop only by default, mobile uses dedicated drag bar)
    makeDraggable(main, header)

    -- Mobile toggle pill
    local mobileBtn
    if IsMobile or opts.MobileButton then
        mobileBtn = new("TextButton", {
            Text = "N",
            Font = Enum.Font.GothamBold,
            TextSize = 18,
            TextColor3 = Nemesis._theme.Text,
            BackgroundColor3 = Nemesis._theme.Accent,
            Size = UDim2.fromOffset(46, 46),
            Position = UDim2.new(0, 16, 0, 80),
            AutoButtonColor = false,
            Parent = screen,
        })
        corner(mobileBtn, 23)
        stroke(mobileBtn, Color3.fromRGB(255, 255, 255), 0)
        makeDraggable(mobileBtn)
        local moved = false
        local pressStart
        mobileBtn.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
                pressStart = i.Position
                moved = false
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

    -- Keybind toggle (desktop)
    local toggleKey = opts.Keybind or Enum.KeyCode.RightShift
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == toggleKey then
            main.Visible = not main.Visible
        end
    end)

    closeBtn.MouseButton1Click:Connect(function() main.Visible = false end)
    if IsMobile then
        closeBtn.TouchTap:Connect(function() main.Visible = false end)
    end

    Window._screen = screen
    Window._main = main
    Window._sidebar = tabList
    Window._content = content
    Window._tabs = {}
    Window._activeTab = nil

    function Window:CreateTab(tabOpts)
        tabOpts = tabOpts or {}
        local Tab = setmetatable({}, { __index = self })

        local btn = new("TextButton", {
            Text = "",
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundColor3 = Nemesis._theme.Surface,
            BackgroundTransparency = 1,
            AutoButtonColor = false,
            Parent = Window._sidebar,
        })
        corner(btn, 6)
        new("TextLabel", {
            Text = tabOpts.Name or "Tab",
            Font = Enum.Font.GothamMedium,
            TextSize = 13,
            TextColor3 = Nemesis._theme.Muted,
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 0),
            Size = UDim2.new(1, -10, 1, 0),
            Parent = btn,
        })

        local page = new("ScrollingFrame", {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Nemesis._theme.Accent,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Visible = false,
            Parent = Window._content,
        })
        local cols = new("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Parent = page,
        })
        local colLayout = new("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = cols,
        })

        local leftCol = new("Frame", {
            Size = UDim2.new(0.5, -4, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Parent = cols,
            LayoutOrder = 1,
        })
        local leftLayout = listLayout(leftCol, 6)

        local rightCol = new("Frame", {
            Size = UDim2.new(0.5, -4, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Parent = cols,
            LayoutOrder = 2,
        })
        local rightLayout = listLayout(rightCol, 6)

        colLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            page.CanvasSize = UDim2.new(0, 0, 0, cols.AbsoluteSize.Y + 8)
        end)

        local function activate()
            for _, t in ipairs(Window._tabs) do
                t._page.Visible = false
                tween(t._btn, QUICK, { BackgroundTransparency = 1 })
            end
            page.Visible = true
            tween(btn, QUICK, { BackgroundColor3 = Nemesis._theme.Surface2, BackgroundTransparency = 0 })
            Window._activeTab = Tab
        end
        btn.MouseButton1Click:Connect(activate)
        if IsMobile then btn.TouchTap:Connect(activate) end

        Tab._btn = btn
        Tab._page = page
        Tab._left = leftCol
        Tab._right = rightCol

        function Tab:CreateSection(secOpts)
            secOpts = secOpts or {}
            local side = (secOpts.Side or "Left"):lower()
            local parent = side == "right" and Tab._right or Tab._left

            local sec = new("Frame", {
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = Nemesis._theme.Surface,
                BorderSizePixel = 0,
                Parent = parent,
            })
            corner(sec, 8)
            stroke(sec, Nemesis._theme.Border, 1)

            new("TextLabel", {
                Text = secOpts.Name or "Section",
                Font = Enum.Font.GothamBold,
                TextSize = 12,
                TextColor3 = Nemesis._theme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 8),
                Size = UDim2.new(1, -20, 0, 16),
                Parent = sec,
            })

            local body = new("Frame", {
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                Position = UDim2.new(0, 0, 0, 28),
                BackgroundTransparency = 1,
                Parent = sec,
            })
            padding(body, 8).PaddingTop = UDim.new(0, 0)
            listLayout(body, 6)

            -- spacer for bottom padding
            new("Frame", { Size = UDim2.new(1, 0, 0, 8), BackgroundTransparency = 1, Parent = sec, LayoutOrder = 999 })

            local Section = {}

            local function row(height)
                local f = new("Frame", {
                    Size = UDim2.new(1, 0, 0, height or 28),
                    BackgroundTransparency = 1,
                    Parent = body,
                })
                return f
            end

            local function label(parent, text, sz, color, x, w)
                return new("TextLabel", {
                    Text = text,
                    Font = Enum.Font.GothamMedium,
                    TextSize = sz or 13,
                    TextColor3 = color or Nemesis._theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, x or 0, 0, 0),
                    Size = UDim2.new(0, w or 200, 1, 0),
                    Parent = parent,
                })
            end

            function Section:CreateButton(o)
                o = o or {}
                local r = row(30)
                local b = new("TextButton", {
                    Text = "",
                    Size = UDim2.fromScale(1, 1),
                    BackgroundColor3 = Nemesis._theme.Surface2,
                    AutoButtonColor = false,
                    Parent = r,
                })
                corner(b, 6)
                stroke(b, Nemesis._theme.Border, 1)
                new("TextLabel", {
                    Text = o.Name or "Button",
                    Font = Enum.Font.GothamMedium,
                    TextSize = 13,
                    TextColor3 = Nemesis._theme.Text,
                    BackgroundTransparency = 1,
                    Size = UDim2.fromScale(1, 1),
                    Parent = b,
                })
                local function fire()
                    tween(b, QUICK, { BackgroundColor3 = Nemesis._theme.Accent })
                    task.delay(0.1, function() tween(b, QUICK, { BackgroundColor3 = Nemesis._theme.Surface2 }) end)
                    if o.Callback then task.spawn(o.Callback) end
                end
                b.MouseButton1Click:Connect(fire)
                if IsMobile then b.TouchTap:Connect(fire) end
                return { Set = function() end }
            end

            function Section:CreateToggle(o)
                o = o or {}
                local state = o.Default or false
                local r = row(30)
                local b = new("TextButton", {
                    Text = "",
                    Size = UDim2.fromScale(1, 1),
                    BackgroundColor3 = Nemesis._theme.Surface2,
                    AutoButtonColor = false,
                    Parent = r,
                })
                corner(b, 6)
                stroke(b, Nemesis._theme.Border, 1)
                label(b, o.Name or "Toggle", 13, Nemesis._theme.Text, 10, 160)

                local pill = new("Frame", {
                    Size = UDim2.fromOffset(30, 16),
                    Position = UDim2.new(1, -38, 0.5, -8),
                    BackgroundColor3 = Nemesis._theme.Border,
                    BorderSizePixel = 0,
                    Parent = b,
                })
                corner(pill, 8)
                local dot = new("Frame", {
                    Size = UDim2.fromOffset(12, 12),
                    Position = UDim2.fromOffset(2, 2),
                    BackgroundColor3 = Nemesis._theme.Text,
                    BorderSizePixel = 0,
                    Parent = pill,
                })
                corner(dot, 6)

                local function render()
                    if state then
                        tween(pill, QUICK, { BackgroundColor3 = Nemesis._theme.Accent })
                        tween(dot, QUICK, { Position = UDim2.fromOffset(16, 2) })
                    else
                        tween(pill, QUICK, { BackgroundColor3 = Nemesis._theme.Border })
                        tween(dot, QUICK, { Position = UDim2.fromOffset(2, 2) })
                    end
                end
                render()

                local function fire()
                    state = not state
                    render()
                    if o.Flag then Nemesis._flags[o.Flag] = state end
                    if o.Callback then task.spawn(o.Callback, state) end
                end
                b.MouseButton1Click:Connect(fire)
                if IsMobile then b.TouchTap:Connect(fire) end
                if o.Flag then Nemesis._flags[o.Flag] = state end

                return {
                    Set = function(v) state = v; render(); if o.Callback then task.spawn(o.Callback, state) end end,
                    Get = function() return state end,
                }
            end

            function Section:CreateSlider(o)
                o = o or {}
                local min, max = o.Min or 0, o.Max or 100
                local value = o.Default or min
                local decimals = o.Decimals or 0

                local r = row(48)
                local card = new("Frame", {
                    Size = UDim2.fromScale(1, 1),
                    BackgroundColor3 = Nemesis._theme.Surface2,
                    BorderSizePixel = 0,
                    Parent = r,
                })
                corner(card, 6)
                stroke(card, Nemesis._theme.Border, 1)
                label(card, o.Name or "Slider", 13, Nemesis._theme.Text, 10, 200)
                local valLbl = new("TextLabel", {
                    Text = tostring(value)..(o.Suffix or ""),
                    Font = Enum.Font.GothamMedium,
                    TextSize = 12,
                    TextColor3 = Nemesis._theme.Muted,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -60, 0, 4),
                    Size = UDim2.new(0, 50, 0, 20),
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Parent = card,
                })
                local track = new("Frame", {
                    Position = UDim2.new(0, 10, 1, -18),
                    Size = UDim2.new(1, -20, 0, 6),
                    BackgroundColor3 = Nemesis._theme.Border,
                    BorderSizePixel = 0,
                    Parent = card,
                })
                corner(track, 3)
                local fill = new("Frame", {
                    Size = UDim2.fromScale(0, 1),
                    BackgroundColor3 = Nemesis._theme.Accent,
                    BorderSizePixel = 0,
                    Parent = track,
                })
                corner(fill, 3)

                local function setValue(v, fireCb)
                    v = math.clamp(v, min, max)
                    if decimals == 0 then v = math.floor(v + 0.5)
                    else local m = 10^decimals; v = math.floor(v * m + 0.5) / m end
                    value = v
                    local pct = (v - min) / (max - min)
                    fill.Size = UDim2.fromScale(pct, 1)
                    valLbl.Text = tostring(v)..(o.Suffix or "")
                    if o.Flag then Nemesis._flags[o.Flag] = v end
                    if fireCb and o.Callback then task.spawn(o.Callback, v) end
                end
                setValue(value, false)

                local dragging = false
                local function update(input)
                    local pct = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                    setValue(min + (max - min) * pct, true)
                end
                track.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                        dragging = true; update(i)
                    end
                end)
                track.InputEnded:Connect(function(i)
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

            function Section:CreateDropdown(o)
                o = o or {}
                local options = o.Options or {}
                local value = o.Default or options[1]
                local open = false

                local r = row(30)
                local b = new("TextButton", {
                    Text = "",
                    Size = UDim2.fromScale(1, 1),
                    BackgroundColor3 = Nemesis._theme.Surface2,
                    AutoButtonColor = false,
                    Parent = r,
                })
                corner(b, 6)
                stroke(b, Nemesis._theme.Border, 1)
                label(b, o.Name or "Dropdown", 13, Nemesis._theme.Text, 10, 140)
                local valLbl = new("TextLabel", {
                    Text = tostring(value or ""),
                    Font = Enum.Font.Gotham,
                    TextSize = 12,
                    TextColor3 = Nemesis._theme.Muted,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -80, 0, 0),
                    Size = UDim2.new(0, 70, 1, 0),
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Parent = b,
                })
                local arrow = new("TextLabel", {
                    Text = "v",
                    Font = Enum.Font.GothamBold,
                    TextSize = 12,
                    TextColor3 = Nemesis._theme.Muted,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -16, 0, 0),
                    Size = UDim2.new(0, 12, 1, 0),
                    Parent = b,
                })

                local list = new("Frame", {
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundColor3 = Nemesis._theme.Surface2,
                    BorderSizePixel = 0,
                    Visible = false,
                    Parent = r,
                })
                corner(list, 6)
                stroke(list, Nemesis._theme.Border, 1)
                local layout = listLayout(list, 2)
                padding(list, 4)

                local function rebuild()
                    for _, c in ipairs(list:GetChildren()) do
                        if c:IsA("TextButton") then c:Destroy() end
                    end
                    for _, opt in ipairs(options) do
                        local item = new("TextButton", {
                            Text = tostring(opt),
                            Font = Enum.Font.Gotham,
                            TextSize = 12,
                            TextColor3 = (opt == value) and Nemesis._theme.Accent or Nemesis._theme.Text,
                            BackgroundColor3 = Nemesis._theme.Surface,
                            AutoButtonColor = false,
                            Size = UDim2.new(1, 0, 0, 24),
                            Parent = list,
                        })
                        corner(item, 4)
                        local function pick()
                            value = opt
                            valLbl.Text = tostring(opt)
                            if o.Flag then Nemesis._flags[o.Flag] = value end
                            if o.Callback then task.spawn(o.Callback, value) end
                            open = false
                            list.Visible = false
                            r.Size = UDim2.new(1, 0, 0, 30)
                            rebuild()
                        end
                        item.MouseButton1Click:Connect(pick)
                        if IsMobile then item.TouchTap:Connect(pick) end
                    end
                end
                rebuild()
                if o.Flag then Nemesis._flags[o.Flag] = value end

                local function toggle()
                    open = not open
                    list.Visible = open
                    list.Position = UDim2.new(0, 0, 0, 34)
                    if open then
                        r.Size = UDim2.new(1, 0, 0, 34 + list.AbsoluteSize.Y + 4)
                    else
                        r.Size = UDim2.new(1, 0, 0, 30)
                    end
                    tween(arrow, QUICK, { Rotation = open and 180 or 0 })
                end
                b.MouseButton1Click:Connect(toggle)
                if IsMobile then b.TouchTap:Connect(toggle) end

                return {
                    Set = function(v) value = v; valLbl.Text = tostring(v); if o.Callback then task.spawn(o.Callback, v) end end,
                    Get = function() return value end,
                    Refresh = function(newOpts, newDefault)
                        options = newOpts or {}
                        if newDefault ~= nil then value = newDefault; valLbl.Text = tostring(newDefault) end
                        rebuild()
                    end,
                }
            end

            function Section:CreateInput(o)
                o = o or {}
                local r = row(30)
                local card = new("Frame", {
                    Size = UDim2.fromScale(1, 1),
                    BackgroundColor3 = Nemesis._theme.Surface2,
                    BorderSizePixel = 0,
                    Parent = r,
                })
                corner(card, 6)
                stroke(card, Nemesis._theme.Border, 1)
                label(card, o.Name or "Input", 13, Nemesis._theme.Text, 10, 120)
                local box = new("TextBox", {
                    Text = o.Default or "",
                    PlaceholderText = o.Placeholder or "",
                    Font = Enum.Font.Gotham,
                    TextSize = 12,
                    TextColor3 = Nemesis._theme.Text,
                    PlaceholderColor3 = Nemesis._theme.Muted,
                    BackgroundColor3 = Nemesis._theme.Background,
                    Position = UDim2.new(1, -130, 0.5, -10),
                    Size = UDim2.new(0, 120, 0, 20),
                    ClearTextOnFocus = false,
                    Parent = card,
                })
                corner(box, 4)
                stroke(box, Nemesis._theme.Border, 1)
                padding(box, 6).PaddingTop = UDim.new(0, 0)
                padding(box, 6).PaddingBottom = UDim.new(0, 0)
                box.FocusLost:Connect(function(enter)
                    if o.Flag then Nemesis._flags[o.Flag] = box.Text end
                    if o.Callback then task.spawn(o.Callback, box.Text, enter) end
                end)
                return { Set = function(v) box.Text = v end, Get = function() return box.Text end }
            end

            function Section:CreateKeybind(o)
                o = o or {}
                local key = o.Default or Enum.KeyCode.Unknown
                local listening = false
                local r = row(30)
                local b = new("TextButton", {
                    Text = "",
                    Size = UDim2.fromScale(1, 1),
                    BackgroundColor3 = Nemesis._theme.Surface2,
                    AutoButtonColor = false,
                    Parent = r,
                })
                corner(b, 6)
                stroke(b, Nemesis._theme.Border, 1)
                label(b, o.Name or "Keybind", 13, Nemesis._theme.Text, 10, 160)
                local kbBox = new("TextLabel", {
                    Text = key.Name,
                    Font = Enum.Font.GothamMedium,
                    TextSize = 12,
                    TextColor3 = Nemesis._theme.Muted,
                    BackgroundColor3 = Nemesis._theme.Background,
                    Position = UDim2.new(1, -80, 0.5, -10),
                    Size = UDim2.new(0, 70, 0, 20),
                    Parent = b,
                })
                corner(kbBox, 4)
                stroke(kbBox, Nemesis._theme.Border, 1)

                local function listen()
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
                end
                b.MouseButton1Click:Connect(listen)
                if IsMobile then b.TouchTap:Connect(listen) end

                UserInputService.InputBegan:Connect(function(input, gpe)
                    if gpe or listening then return end
                    if input.KeyCode == key and o.Callback then task.spawn(o.Callback, key) end
                end)

                return { Set = function(k) key = k; kbBox.Text = k.Name end, Get = function() return key end }
            end

            function Section:CreateColorpicker(o)
                o = o or {}
                local color = o.Default or Color3.fromRGB(255, 255, 255)
                local open = false
                local r = row(30)
                local b = new("TextButton", {
                    Text = "",
                    Size = UDim2.fromScale(1, 1),
                    BackgroundColor3 = Nemesis._theme.Surface2,
                    AutoButtonColor = false,
                    Parent = r,
                })
                corner(b, 6)
                stroke(b, Nemesis._theme.Border, 1)
                label(b, o.Name or "Color", 13, Nemesis._theme.Text, 10, 200)
                local swatch = new("Frame", {
                    Size = UDim2.fromOffset(24, 16),
                    Position = UDim2.new(1, -34, 0.5, -8),
                    BackgroundColor3 = color,
                    BorderSizePixel = 0,
                    Parent = b,
                })
                corner(swatch, 4)
                stroke(swatch, Nemesis._theme.Border, 1)

                local panel = new("Frame", {
                    Size = UDim2.new(1, 0, 0, 110),
                    Position = UDim2.new(0, 0, 0, 34),
                    BackgroundColor3 = Nemesis._theme.Surface2,
                    BorderSizePixel = 0,
                    Visible = false,
                    Parent = r,
                })
                corner(panel, 6)
                stroke(panel, Nemesis._theme.Border, 1)
                padding(panel, 8)

                local sat = new("ImageLabel", {
                    Image = "rbxassetid://4155801252",
                    Size = UDim2.new(1, -90, 1, 0),
                    BackgroundColor3 = Color3.new(1, 0, 0),
                    BorderSizePixel = 0,
                    Parent = panel,
                })
                corner(sat, 4)
                local hueBar = new("Frame", {
                    Position = UDim2.new(1, -80, 0, 0),
                    Size = UDim2.new(0, 18, 1, 0),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel = 0,
                    Parent = panel,
                })
                corner(hueBar, 4)
                local hueGrad = new("UIGradient", {
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
                    Position = UDim2.new(1, -56, 0, 0),
                    Size = UDim2.new(0, 50, 1, 0),
                    BackgroundColor3 = color,
                    BorderSizePixel = 0,
                    Parent = panel,
                })
                corner(preview, 4)
                stroke(preview, Nemesis._theme.Border, 1)

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

                local satDrag, hueDrag = false, false
                local function updateSat(input)
                    local x = math.clamp((input.Position.X - sat.AbsolutePosition.X) / sat.AbsoluteSize.X, 0, 1)
                    local y = math.clamp((input.Position.Y - sat.AbsolutePosition.Y) / sat.AbsoluteSize.Y, 0, 1)
                    s, v = x, 1 - y
                    apply()
                end
                local function updateHue(input)
                    local y = math.clamp((input.Position.Y - hueBar.AbsolutePosition.Y) / hueBar.AbsoluteSize.Y, 0, 1)
                    h = y
                    apply()
                end
                sat.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                        satDrag = true; updateSat(i)
                    end
                end)
                sat.InputEnded:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                        satDrag = false
                    end
                end)
                hueBar.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                        hueDrag = true; updateHue(i)
                    end
                end)
                hueBar.InputEnded:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                        hueDrag = false
                    end
                end)
                UserInputService.InputChanged:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
                        if satDrag then updateSat(i) end
                        if hueDrag then updateHue(i) end
                    end
                end)

                local function toggle()
                    open = not open
                    panel.Visible = open
                    r.Size = open and UDim2.new(1, 0, 0, 152) or UDim2.new(1, 0, 0, 30)
                end
                b.MouseButton1Click:Connect(toggle)
                if IsMobile then b.TouchTap:Connect(toggle) end

                return { Set = function(c) color = c; h, s, v = Color3.toHSV(c); apply() end, Get = function() return color end }
            end

            function Section:CreateLabel(o)
                o = o or {}
                local r = row(20)
                new("TextLabel", {
                    Text = o.Text or "Label",
                    Font = Enum.Font.Gotham,
                    TextSize = 12,
                    TextColor3 = Nemesis._theme.Muted,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BackgroundTransparency = 1,
                    Size = UDim2.fromScale(1, 1),
                    Parent = r,
                })
                return { Set = function(t) r:FindFirstChildOfClass("TextLabel").Text = t end }
            end

            function Section:CreateParagraph(o)
                o = o or {}
                local r = row(50)
                local card = new("Frame", {
                    Size = UDim2.fromScale(1, 1),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundColor3 = Nemesis._theme.Surface2,
                    BorderSizePixel = 0,
                    Parent = r,
                })
                corner(card, 6)
                stroke(card, Nemesis._theme.Border, 1)
                padding(card, 8)
                new("TextLabel", {
                    Text = o.Title or "Title",
                    Font = Enum.Font.GothamBold,
                    TextSize = 13,
                    TextColor3 = Nemesis._theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 16),
                    Parent = card,
                })
                new("TextLabel", {
                    Text = o.Text or "",
                    Font = Enum.Font.Gotham,
                    TextSize = 12,
                    TextColor3 = Nemesis._theme.Muted,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Top,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 18),
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    TextWrapped = true,
                    Parent = card,
                })
                return {}
            end

            return Section
        end

        table.insert(Window._tabs, Tab)
        if #Window._tabs == 1 then activate() end
        return Tab
    end

    function Window:Destroy() screen:Destroy() end

    return Window
end

-- ===== Notify =====
local notifyHolder
function Nemesis:Notify(opts)
    opts = opts or {}
    if not notifyHolder then
        local parent = self._lastScreen
        if not parent then
            for _, w in ipairs(getParent():GetChildren()) do
                if w.Name == "NemesisUI" then parent = w; break end
            end
        end
        if not parent then return end
        notifyHolder = new("Frame", {
            Name = "NotifyHolder",
            AnchorPoint = Vector2.new(1, 1),
            Position = UDim2.new(1, -16, 1, -16),
            Size = UDim2.new(0, 280, 1, -32),
            BackgroundTransparency = 1,
            Parent = parent,
        })
        new("UIListLayout", {
            Padding = UDim.new(0, 6),
            VerticalAlignment = Enum.VerticalAlignment.Bottom,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = notifyHolder,
        })
    end

    local n = new("Frame", {
        Size = UDim2.new(1, 0, 0, 56),
        BackgroundColor3 = self._theme.Surface,
        BorderSizePixel = 0,
        Parent = notifyHolder,
    })
    corner(n, 8)
    stroke(n, self._theme.Border, 1)
    new("Frame", {
        Size = UDim2.new(0, 3, 1, -12),
        Position = UDim2.new(0, 6, 0, 6),
        BackgroundColor3 = self._theme.Accent,
        BorderSizePixel = 0,
        Parent = n,
    })
    new("TextLabel", {
        Text = opts.Title or "",
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = self._theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 16, 0, 6),
        Size = UDim2.new(1, -22, 0, 18),
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
        Position = UDim2.new(0, 16, 0, 24),
        Size = UDim2.new(1, -22, 0, 28),
        Parent = n,
    })

    n.BackgroundTransparency = 1
    for _, d in ipairs(n:GetDescendants()) do
        if d:IsA("TextLabel") then d.TextTransparency = 1 end
    end
    tween(n, SMOOTH, { BackgroundTransparency = 0 })

    task.delay(opts.Duration or 3, function()
        tween(n, SMOOTH, { BackgroundTransparency = 1 })
        for _, d in ipairs(n:GetDescendants()) do
            if d:IsA("TextLabel") then tween(d, SMOOTH, { TextTransparency = 1 }) end
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
