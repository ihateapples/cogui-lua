-- cogui is licensed under MIT
-- https://github.com/ihateapples/cogui-lua

local cogui = { flags = {}, items = {} }

local services = {
    players = game:GetService("Players"),
    uis = game:GetService("UserInputService"),
    runservice = game:GetService("RunService"),
    coregui = game:GetService("CoreGui")
}

local player = services.players.LocalPlayer

-- executor compatibility
local function protect(gui)
    if gethui then
        gui.Parent = gethui()
    else
        gui.Parent = services.coregui
    end
end

cogui.theme = {
    background = Color3.fromRGB(24, 24, 24),
    sector = Color3.fromRGB(30, 30, 30),
    accent = Color3.fromRGB(80, 180, 255),
    outline = Color3.fromRGB(55, 55, 55),
    outline2 = Color3.fromRGB(0, 0, 0),
    text = Color3.fromRGB(255, 255, 255),
    font = Enum.Font.GothamSemibold,
    fontsize = 14
}

function cogui:CreateWindow(title, size)
    local window = {}
    window.size = size or UDim2.fromOffset(680, 720)

    local gui = Instance.new("ScreenGui")
    protect(gui)

    local main = Instance.new("Frame", gui)
    main.Size = window.size
    main.Position = UDim2.new(0.5, -window.size.X.Offset/2, 0.5, -window.size.Y.Offset/2)
    main.BackgroundColor3 = cogui.theme.background
    main.BorderSizePixel = 0

    -- outlines
    for i = 1, 2 do
        local outline = Instance.new("Frame", main)
        local thick = i == 1 and 2 or 4
        outline.Size = main.Size + UDim2.new(0, thick*2, 0, thick*2)
        outline.Position = UDim2.new(0, -thick, 0, -thick)
        outline.BackgroundColor3 = i == 1 and cogui.theme.outline or cogui.theme.outline2
        outline.BorderSizePixel = 0
        outline.ZIndex = -i
    end

    -- top bar
    local topbar = Instance.new("Frame", main)
    topbar.Size = UDim2.new(1, 0, 0, 50)
    topbar.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    topbar.BorderSizePixel = 0

    local titleLabel = Instance.new("TextLabel", topbar)
    titleLabel.Size = UDim2.new(1, -20, 1, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title or "cogui"
    titleLabel.TextColor3 = cogui.theme.text
    titleLabel.Font = cogui.theme.font
    titleLabel.TextSize = 16
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Position = UDim2.new(0, 15, 0, 0)

    -- dragging
    local dragging = false
    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            local startPos = main.Position
            local startMouse = services.uis:GetMouseLocation()

            services.runservice.RenderStepped:Connect(function()
                if not dragging then return end
                local delta = services.uis:GetMouseLocation() - startMouse
                main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end)
        end
    end)

    services.uis.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    window.Main = main
    window.Tabs = {}

    function window:CreateTab(name)
        local tab = {}

        local container = Instance.new("ScrollingFrame", main)
        container.Size = UDim2.new(1, -20, 1, -70)
        container.Position = UDim2.new(0, 10, 0, 60)
        container.BackgroundTransparency = 1
        container.ScrollBarThickness = 6
        container.Visible = #window.Tabs == 0

        local left = Instance.new("Frame", container)
        left.Size = UDim2.new(0.48, 0, 1, 0)
        left.BackgroundTransparency = 1

        local right = Instance.new("Frame", container)
        right.Size = UDim2.new(0.48, 0, 1, 0)
        right.Position = UDim2.new(0.52, 0, 0, 0)
        right.BackgroundTransparency = 1

        function tab:CreateSector(sectorName, side)
            local sector = Instance.new("Frame", side == "left" and left or right)
            sector.BackgroundColor3 = cogui.theme.sector
            sector.BorderSizePixel = 0
            sector.AutomaticSize = Enum.AutomaticSize.Y
            sector.Size = UDim2.new(1, 0, 0, 40)

            local title = Instance.new("TextLabel", sector)
            title.Size = UDim2.new(1, 0, 0, 26)
            title.BackgroundTransparency = 1
            title.Text = "  " .. sectorName
            title.TextColor3 = cogui.theme.accent
            title.Font = cogui.theme.font
            title.TextSize = 15
            title.TextXAlignment = Enum.TextXAlignment.Left

            local content = Instance.new("Frame", sector)
            content.Position = UDim2.new(0, 8, 0, 28)
            content.Size = UDim2.new(1, -16, 0, 0)
            content.BackgroundTransparency = 1
            content.AutomaticSize = Enum.AutomaticSize.Y

            local layout = Instance.new("UIListLayout", content)
            layout.Padding = UDim.new(0, 6)
            layout.SortOrder = Enum.SortOrder.LayoutOrder

            local sectorAPI = {}

            function sectorAPI:AddButton(text, callback)
                local btn = Instance.new("TextButton", content)
                btn.Size = UDim2.new(1, 0, 0, 34)
                btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                btn.Text = text
                btn.TextColor3 = cogui.theme.text
                btn.Font = cogui.theme.font
                btn.TextSize = cogui.theme.fontsize
                btn.MouseButton1Click:Connect(callback or function() end)
                return btn
            end

            function sectorAPI:AddToggle(text, default, callback)
                local toggle = Instance.new("TextButton", content)
                toggle.Size = UDim2.new(1, 0, 0, 34)
                toggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                toggle.Text = "  " .. text
                toggle.TextColor3 = cogui.theme.text
                toggle.TextXAlignment = Enum.TextXAlignment.Left
                toggle.Font = cogui.theme.font
                toggle.TextSize = cogui.theme.fontsize

                local state = default or false

                toggle.MouseButton1Click:Connect(function()
                    state = not state
                    toggle.TextColor3 = state and cogui.theme.accent or cogui.theme.text
                    if callback then callback(state) end
                end)

                return toggle
            end

            return sectorAPI
        end

        table.insert(window.Tabs, tab)
        return tab
    end

    print("cogui loaded - " .. (title or "Window"))
    return window
end

return cogui