--[[
Fernuim Hub - Advanced UI Library
Default Name: Fernuim Hub
Default Icon: rbxassetid://73689471425704

Features:
• Loading screen with fading image (non-looping once loaded)
• Main window with a draggable top bar containing:
    – Icon and title (with customizable decal)
    – Buttons to minimize, toggle visibility, open settings, and close the UI
• Tab system with buttons that display an icon and label; when switching tabs the old tab’s elements fade/slide out while the new ones slide in from the opposite side
• Built-in UI elements: buttons, toggles, textboxes, sliders, and a simple color picker
• Outlines/separators (white lines) to clearly separate tabs, buttons, and other elements
• A settings window to change the toggle key, theme (accent color), and view user info (with Roblox profile thumbnail, username, user ID, and executor info)
• Fully customizable via the Config table (name, icon, theme colors, keybind, autosave, etc.)
• Supports lower-unc executors (optimized code paths and simple UI creation)
--]]

---------------------------
-- Services & Variables --
---------------------------
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local FernuimHub = {} -- our library table

local Config = {
    Name = "Fernuim Hub",
    Icon = "rbxassetid://73689471425704",
    Theme = {
        Background = Color3.fromRGB(25,25,25),
        Accent = Color3.fromRGB(50,50,50),
        Text = Color3.new(1,1,1),
        Outline = Color3.new(1,1,1)
    },
    ToggleKey = Enum.KeyCode.RightShift,
    Autosave = true
}

---------------------------
-- Create Screen GUI   --
---------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FernuimHub"
ScreenGui.Parent = game:GetService("CoreGui")

---------------------------
-- Loading Screen Setup --
---------------------------
local LoadingFrame = Instance.new("Frame")
LoadingFrame.Size = UDim2.new(1,0,1,0)
LoadingFrame.BackgroundColor3 = Config.Theme.Background
LoadingFrame.Parent = ScreenGui

local LoadingImage = Instance.new("ImageLabel")
LoadingImage.Size = UDim2.new(0.4,0,0.4,0)
LoadingImage.Position = UDim2.new(0.3,0,0.3,0)
LoadingImage.Image = Config.Icon
LoadingImage.BackgroundTransparency = 1
LoadingImage.Parent = LoadingFrame

local loadingDone = false
spawn(function()
    while not loadingDone do
        local fadeOut = TweenService:Create(LoadingImage, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {ImageTransparency = 0.5})
        fadeOut:Play() fadeOut.Completed:Wait()
        local fadeIn = TweenService:Create(LoadingImage, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {ImageTransparency = 0})
        fadeIn:Play() fadeIn.Completed:Wait()
    end
end)

---------------------------
-- Main Window Setup   --
---------------------------
local MainWindow = Instance.new("Frame")
MainWindow.Size = UDim2.new(0,800,0,500)
MainWindow.Position = UDim2.new(0.5,-400,0.5,-250)
MainWindow.BackgroundColor3 = Config.Theme.Background
MainWindow.BorderSizePixel = 0
MainWindow.Visible = false
MainWindow.Parent = ScreenGui

local MainWindowStroke = Instance.new("UIStroke")
MainWindowStroke.Thickness = 2
MainWindowStroke.Color = Config.Theme.Outline
MainWindowStroke.Parent = MainWindow

---------------------------
-- Top Bar (Draggable) --
---------------------------
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1,0,0,40)
TopBar.BackgroundColor3 = Config.Theme.Accent
TopBar.BorderSizePixel = 0
TopBar.Parent = MainWindow

-- Title Icon & Label
local TitleIcon = Instance.new("ImageLabel")
TitleIcon.Size = UDim2.new(0,30,0,30)
TitleIcon.Position = UDim2.new(0,10,0,5)
TitleIcon.Image = Config.Icon
TitleIcon.BackgroundTransparency = 1
TitleIcon.Parent = TopBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0,200,0,40)
TitleLabel.Position = UDim2.new(0,50,0,0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = Config.Name
TitleLabel.TextColor3 = Config.Theme.Text
TitleLabel.TextSize = 20
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopBar

-- Top Bar Control Buttons (Minimize, Toggle, Settings, Close)
local function createTopButton(text, pos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,30,0,30)
    btn.Position = pos
    btn.BackgroundTransparency = 1
    btn.Text = text
    btn.TextColor3 = Config.Theme.Text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 20
    btn.Parent = TopBar
    return btn
end

local MinimizeButton = createTopButton("_", UDim2.new(1,-130,0,5))
local ToggleButton = createTopButton("T", UDim2.new(1,-95,0,5))
local SettingsButton = createTopButton("⚙", UDim2.new(1,-60,0,5))
local CloseButton = createTopButton("X", UDim2.new(1,-30,0,5))

-- Make MainWindow draggable via TopBar
local dragging, dragInput, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainWindow.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainWindow.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

---------------------------
-- Tab System Setup    --
---------------------------
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1,0,0,50)
TabBar.Position = UDim2.new(0,0,0,40)
TabBar.BackgroundColor3 = Config.Theme.Background
TabBar.Parent = MainWindow

local TabContent = Instance.new("Frame")
TabContent.Size = UDim2.new(1,0,1,-90)
TabContent.Position = UDim2.new(0,0,0,90)
TabContent.BackgroundColor3 = Config.Theme.Background
TabContent.Parent = MainWindow

local Tabs = {}       -- container for tab content frames
local TabButtons = {} -- container for tab buttons
local CurrentTab = nil

-- Create a new tab with animated transition and white-outline separators.
function FernuimHub:CreateTab(Name, Icon)
    local TabFrame = Instance.new("Frame")
    TabFrame.Size = UDim2.new(1,0,1,0)
    TabFrame.BackgroundTransparency = 1
    TabFrame.Visible = false
    TabFrame.Parent = TabContent

    local TabButton = Instance.new("TextButton")
    TabButton.Size = UDim2.new(0,120,0,40)
    TabButton.BackgroundColor3 = Config.Theme.Accent
    TabButton.Text = ""
    TabButton.Parent = TabBar

    local IconImage = Instance.new("ImageLabel")
    IconImage.Size = UDim2.new(0,20,0,20)
    IconImage.Position = UDim2.new(0,10,0,10)
    IconImage.BackgroundTransparency = 1
    IconImage.Image = Icon or ""
    IconImage.Parent = TabButton

    local TextLabel = Instance.new("TextLabel")
    TextLabel.Size = UDim2.new(1,-40,1,0)
    TextLabel.Position = UDim2.new(0,40,0,0)
    TextLabel.BackgroundTransparency = 1
    TextLabel.Text = Name
    TextLabel.TextColor3 = Config.Theme.Text
    TextLabel.Font = Enum.Font.Gotham
    TextLabel.TextSize = 18
    TextLabel.Parent = TabButton

    -- White separator line
    local Separator = Instance.new("Frame")
    Separator.Size = UDim2.new(0,1,1,-10)
    Separator.Position = UDim2.new(1,0,0,5)
    Separator.BackgroundColor3 = Config.Theme.Outline
    Separator.Parent = TabButton

    TabButton.MouseButton1Click:Connect(function()
        if CurrentTab == TabFrame then return end
        if CurrentTab then
            -- Slide/fade out current tab’s content
            local tweenOut = TweenService:Create(CurrentTab, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {Position = UDim2.new(0,0,1,0), BackgroundTransparency = 1})
            tweenOut:Play() tweenOut.Completed:Wait()
            CurrentTab.Visible = false
        end
        -- Prepare new tab: position off-screen depending on which side is active
        TabFrame.Position = UDim2.new(0, (CurrentTab and 50 or -50), 0, 0)
        TabFrame.Visible = true
        local tweenIn = TweenService:Create(TabFrame, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = UDim2.new(0,0,0,0), BackgroundTransparency = 0})
        tweenIn:Play()
        CurrentTab = TabFrame
    end)

    table.insert(Tabs, TabFrame)
    table.insert(TabButtons, TabButton)
    if #Tabs == 1 then TabButton:Activate() end

    -- Return a table with functions to add UI elements to this tab
    local UIElements = {}
    function UIElements:CreateButton(Text, Callback)
        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(1, -20, 0, 40)
        Button.Position = UDim2.new(0,10,0,10 + (#TabFrame:GetChildren()-2)*45)
        Button.BackgroundColor3 = Config.Theme.Accent
        Button.Text = Text
        Button.TextColor3 = Config.Theme.Text
        Button.Font = Enum.Font.GothamBold
        Button.TextSize = 18
        Button.Parent = TabFrame
        local stroke = Instance.new("UIStroke")
        stroke.Thickness = 1
        stroke.Color = Config.Theme.Outline
        stroke.Parent = Button
        Button.MouseButton1Click:Connect(Callback)
        return Button
    end

    function UIElements:CreateToggle(Text, Callback)
        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Size = UDim2.new(1, -20, 0, 40)
        ToggleFrame.Position = UDim2.new(0,10,0,10 + (#TabFrame:GetChildren()-2)*45)
        ToggleFrame.BackgroundColor3 = Config.Theme.Accent
        ToggleFrame.Parent = TabFrame
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(0.7,0,1,0)
        Label.BackgroundTransparency = 1
        Label.Text = Text
        Label.TextColor3 = Config.Theme.Text
        Label.Font = Enum.Font.Gotham
        Label.TextSize = 18
        Label.Parent = ToggleFrame
        local ToggleButton = Instance.new("TextButton")
        ToggleButton.Size = UDim2.new(0.3, -10, 0.6,0)
        ToggleButton.Position = UDim2.new(0.7,10,0.2,0)
        ToggleButton.BackgroundColor3 = Config.Theme.Background
        ToggleButton.Text = "Off"
        ToggleButton.TextColor3 = Config.Theme.Text
        ToggleButton.Font = Enum.Font.GothamBold
        ToggleButton.TextSize = 18
        ToggleButton.Parent = ToggleFrame
        local toggled = false
        ToggleButton.MouseButton1Click:Connect(function()
            toggled = not toggled
            ToggleButton.Text = toggled and "On" or "Off"
            Callback(toggled)
            local tween = TweenService:Create(ToggleButton, TweenInfo.new(0.2), {BackgroundColor3 = toggled and Config.Theme.Accent or Config.Theme.Background})
            tween:Play()
        end)
        return ToggleFrame
    end

    function UIElements:CreateTextbox(Text, Placeholder, Callback)
        local Box = Instance.new("TextBox")
        Box.Size = UDim2.new(1, -20, 0, 40)
        Box.Position = UDim2.new(0,10,0,10 + (#TabFrame:GetChildren()-2)*45)
        Box.BackgroundColor3 = Config.Theme.Accent
        Box.Text = Placeholder or ""
        Box.PlaceholderText = Text
        Box.TextColor3 = Config.Theme.Text
        Box.Font = Enum.Font.Gotham
        Box.TextSize = 18
        Box.Parent = TabFrame
        local stroke = Instance.new("UIStroke")
        stroke.Thickness = 1
        stroke.Color = Config.Theme.Outline
        stroke.Parent = Box
        Box.FocusLost:Connect(function(enterPressed)
            if enterPressed then Callback(Box.Text) end
        end)
        return Box
    end

    function UIElements:CreateSlider(Text, min, max, default, Callback)
        local SliderFrame = Instance.new("Frame")
        SliderFrame.Size = UDim2.new(1, -20, 0, 60)
        SliderFrame.Position = UDim2.new(0,10,0,10 + (#TabFrame:GetChildren()-2)*65)
        SliderFrame.BackgroundColor3 = Config.Theme.Accent
        SliderFrame.Parent = TabFrame
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -20, 0, 20)
        Label.Position = UDim2.new(0,10,0,5)
        Label.BackgroundTransparency = 1
        Label.Text = Text .. ": " .. tostring(default)
        Label.TextColor3 = Config.Theme.Text
        Label.Font = Enum.Font.Gotham
        Label.TextSize = 18
        Label.Parent = SliderFrame
        local SliderBar = Instance.new("Frame")
        SliderBar.Size = UDim2.new(1, -20, 0, 10)
        SliderBar.Position = UDim2.new(0,10,0,30)
        SliderBar.BackgroundColor3 = Config.Theme.Background
        SliderBar.Parent = SliderFrame
        local SliderFill = Instance.new("Frame")
        SliderFill.Size = UDim2.new((default - min)/(max - min),0,1,0)
        SliderFill.BackgroundColor3 = Config.Theme.Accent
        SliderFill.Parent = SliderBar
        local draggingSlider = false
        SliderBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingSlider = true end
        end)
        SliderBar.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingSlider = false end
        end)
        SliderBar.InputChanged:Connect(function(input)
            if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
                local pos = math.clamp(input.Position.X - SliderBar.AbsolutePosition.X, 0, SliderBar.AbsoluteSize.X)
                local value = min + (max - min) * (pos / SliderBar.AbsoluteSize.X)
                SliderFill.Size = UDim2.new((value - min)/(max - min),0,1,0)
                Label.Text = Text .. ": " .. string.format("%.2f", value)
                Callback(value)
            end
        end)
        return SliderFrame
    end

    function UIElements:CreateColorPicker(Text, DefaultColor, Callback)
        local PickerFrame = Instance.new("Frame")
        PickerFrame.Size = UDim2.new(1, -20, 0, 60)
        PickerFrame.Position = UDim2.new(0,10,0,10 + (#TabFrame:GetChildren()-2)*65)
        PickerFrame.BackgroundColor3 = Config.Theme.Accent
        PickerFrame.Parent = TabFrame
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -20, 0, 20)
        Label.Position = UDim2.new(0,10,0,5)
        Label.BackgroundTransparency = 1
        Label.Text = Text
        Label.TextColor3 = Config.Theme.Text
        Label.Font = Enum.Font.Gotham
        Label.TextSize = 18
        Label.Parent = PickerFrame
        local ColorDisplay = Instance.new("Frame")
        ColorDisplay.Size = UDim2.new(0,30,0,30)
        ColorDisplay.Position = UDim2.new(0,10,0,25)
        ColorDisplay.BackgroundColor3 = DefaultColor or Color3.new(1,1,1)
        ColorDisplay.Parent = PickerFrame
        local stroke = Instance.new("UIStroke")
        stroke.Thickness = 1
        stroke.Color = Config.Theme.Outline
        stroke.Parent = ColorDisplay
        -- For simplicity, clicking randomly changes color
        ColorDisplay.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local newColor = Color3.fromHSV(math.random(), 1, 1)
                ColorDisplay.BackgroundColor3 = newColor
                Callback(newColor)
            end
        end)
        return PickerFrame
    end

    return UIElements
end

---------------------------
-- UI Toggle & Controls --
---------------------------
local UIVisible = true
ToggleButton.MouseButton1Click:Connect(function()
    UIVisible = not UIVisible
    MainWindow.Visible = UIVisible
end)

MinimizeButton.MouseButton1Click:Connect(function()
    if MainWindow.Size.X.Offset > 200 then
        local tweenMin = TweenService:Create(MainWindow, TweenInfo.new(0.3), {Size = UDim2.new(0,200,0,40)})
        tweenMin:Play()
    else
        local tweenExp = TweenService:Create(MainWindow, TweenInfo.new(0.3), {Size = UDim2.new(0,800,0,500)})
        tweenExp:Play()
    end
end)

CloseButton.MouseButton1Click:Connect(function()
    MainWindow.Visible = false
end)

---------------------------
-- Settings Window Setup --
---------------------------
local SettingsWindow = Instance.new("Frame")
SettingsWindow.Size = UDim2.new(0,400,0,300)
SettingsWindow.Position = UDim2.new(0.5,-200,0.5,-150)
SettingsWindow.BackgroundColor3 = Config.Theme.Background
SettingsWindow.Visible = false
SettingsWindow.Parent = ScreenGui

local SettingsTitle = Instance.new("TextLabel")
SettingsTitle.Size = UDim2.new(1,0,0,40)
SettingsTitle.BackgroundColor3 = Config.Theme.Accent
SettingsTitle.Text = "Settings"
SettingsTitle.TextColor3 = Config.Theme.Text
SettingsTitle.Font = Enum.Font.GothamBold
SettingsTitle.TextSize = 20
SettingsTitle.Parent = SettingsWindow

local CloseSettings = Instance.new("TextButton")
CloseSettings.Size = UDim2.new(0,30,0,30)
CloseSettings.Position = UDim2.new(1,-35,0,5)
CloseSettings.BackgroundTransparency = 1
CloseSettings.Text = "X"
CloseSettings.TextColor3 = Config.Theme.Text
CloseSettings.Font = Enum.Font.GothamBold
CloseSettings.TextSize = 20
CloseSettings.Parent = SettingsWindow
CloseSettings.MouseButton1Click:Connect(function()
    SettingsWindow.Visible = false
end)

local SettingsContent = Instance.new("Frame")
SettingsContent.Size = UDim2.new(1,0,1,-40)
SettingsContent.Position = UDim2.new(0,0,0,40)
SettingsContent.BackgroundTransparency = 1
SettingsContent.Parent = SettingsWindow

-- Keybind Changer
local KeybindLabel = Instance.new("TextLabel")
KeybindLabel.Size = UDim2.new(1,-20,0,30)
KeybindLabel.Position = UDim2.new(0,10,0,10)
KeybindLabel.BackgroundTransparency = 1
KeybindLabel.Text = "Toggle Key: " .. Config.ToggleKey.Name
KeybindLabel.TextColor3 = Config.Theme.Text
KeybindLabel.Font = Enum.Font.Gotham
KeybindLabel.TextSize = 18
KeybindLabel.Parent = SettingsContent

local ChangeKeybind = Instance.new("TextButton")
ChangeKeybind.Size = UDim2.new(0,100,0,30)
ChangeKeybind.Position = UDim2.new(1,-110,0,10)
ChangeKeybind.BackgroundColor3 = Config.Theme.Accent
ChangeKeybind.Text = "Change"
ChangeKeybind.TextColor3 = Config.Theme.Text
ChangeKeybind.Font = Enum.Font.GothamBold
ChangeKeybind.TextSize = 18
ChangeKeybind.Parent = SettingsContent

ChangeKeybind.MouseButton1Click:Connect(function()
    KeybindLabel.Text = "Press a key..."
    local conn
    conn = UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Keyboard then
            Config.ToggleKey = input.KeyCode
            KeybindLabel.Text = "Toggle Key: " .. input.KeyCode.Name
            conn:Disconnect()
        end
    end)
end)

-- Theme Changer (Accent Color)
local ThemeLabel = Instance.new("TextLabel")
ThemeLabel.Size = UDim2.new(1,-20,0,30)
ThemeLabel.Position = UDim2.new(0,10,0,50)
ThemeLabel.BackgroundTransparency = 1
ThemeLabel.Text = "Accent Color"
ThemeLabel.TextColor3 = Config.Theme.Text
ThemeLabel.Font = Enum.Font.Gotham
ThemeLabel.TextSize = 18
ThemeLabel.Parent = SettingsContent

local ChangeThemeButton = Instance.new("TextButton")
ChangeThemeButton.Size = UDim2.new(0,100,0,30)
ChangeThemeButton.Position = UDim2.new(1,-110,0,50)
ChangeThemeButton.BackgroundColor3 = Config.Theme.Accent
ChangeThemeButton.Text = "Randomize"
ChangeThemeButton.TextColor3 = Config.Theme.Text
ChangeThemeButton.Font = Enum.Font.GothamBold
ChangeThemeButton.TextSize = 18
ChangeThemeButton.Parent = SettingsContent

ChangeThemeButton.MouseButton1Click:Connect(function()
    local newAccent = Color3.fromHSV(math.random(), 1, 1)
    Config.Theme.Accent = newAccent
    TopBar.BackgroundColor3 = newAccent
    SettingsTitle.BackgroundColor3 = newAccent
end)

-- User Info Display
local UserFrame = Instance.new("Frame")
UserFrame.Size = UDim2.new(1,-20,0,60)
UserFrame.Position = UDim2.new(0,10,0,90)
UserFrame.BackgroundColor3 = Config.Theme.Accent
UserFrame.Parent = SettingsContent

local UserImage = Instance.new("ImageLabel")
UserImage.Size = UDim2.new(0,50,0,50)
UserImage.Position = UDim2.new(0,5,0,5)
UserImage.BackgroundTransparency = 1
UserImage.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. tostring(LocalPlayer and LocalPlayer.UserId or 0) .. "&width=420&height=420&format=png"
UserImage.Parent = UserFrame

local UserNameLabel = Instance.new("TextLabel")
UserNameLabel.Size = UDim2.new(0.6,0,0,25)
UserNameLabel.Position = UDim2.new(0,60,0,5)
UserNameLabel.BackgroundTransparency = 1
UserNameLabel.Text = "Name: " .. (LocalPlayer and LocalPlayer.Name or "Guest")
UserNameLabel.TextColor3 = Config.Theme.Text
UserNameLabel.Font = Enum.Font.Gotham
UserNameLabel.TextSize = 16
UserNameLabel.Parent = UserFrame

local UserIdLabel = Instance.new("TextLabel")
UserIdLabel.Size = UDim2.new(0.6,0,0,25)
UserIdLabel.Position = UDim2.new(0,60,0,30)
UserIdLabel.BackgroundTransparency = 1
UserIdLabel.Text = "ID: " .. (LocalPlayer and LocalPlayer.UserId or "0")
UserIdLabel.TextColor3 = Config.Theme.Text
UserIdLabel.Font = Enum.Font.Gotham
UserIdLabel.TextSize = 16
UserIdLabel.Parent = UserFrame

local ExecutorLabel = Instance.new("TextLabel")
ExecutorLabel.Size = UDim2.new(0.3,0,1,0)
ExecutorLabel.Position = UDim2.new(0.65,0,0,0)
ExecutorLabel.BackgroundTransparency = 1
ExecutorLabel.Text = "Executor: Unknown"
ExecutorLabel.TextColor3 = Config.Theme.Text
ExecutorLabel.Font = Enum.Font.Gotham
ExecutorLabel.TextSize = 16
ExecutorLabel.Parent = UserFrame

-- Toggle settings window on SettingsButton click
SettingsButton.MouseButton1Click:Connect(function()
    SettingsWindow.Visible = not SettingsWindow.Visible
end)

---------------------------
-- Finalize & Toggle Key --
---------------------------
task.wait(5)
loadingDone = true
LoadingFrame:Destroy()
MainWindow.Visible = true

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Config.ToggleKey then
        MainWindow.Visible = not MainWindow.Visible
    end
end)

return FernuimHub
