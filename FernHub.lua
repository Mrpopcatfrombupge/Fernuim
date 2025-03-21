-- // SERVICES
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- // UI LIBRARY TABLE
local FluentHub = {}

-- // CREATE SCREEN GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game:GetService("CoreGui")

-- // LOADING SCREEN
local LoadingFrame = Instance.new("Frame")
LoadingFrame.Size = UDim2.new(1, 0, 1, 0)
LoadingFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
LoadingFrame.Parent = ScreenGui

local LoadingImage = Instance.new("ImageLabel")
LoadingImage.Size = UDim2.new(0.4, 0, 0.4, 0)
LoadingImage.Position = UDim2.new(0.3, 0, 0.3, 0)
LoadingImage.Image = "rbxassetid://137380030228719"
LoadingImage.BackgroundTransparency = 1
LoadingImage.Parent = LoadingFrame

-- // FADING ANIMATION
local function FadeLoop()
    while LoadingFrame.Parent do
        local FadeOut = TweenService:Create(LoadingImage, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {ImageTransparency = 0.5})
        FadeOut:Play()
        FadeOut.Completed:Wait()

        local FadeIn = TweenService:Create(LoadingImage, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {ImageTransparency = 0})
        FadeIn:Play()
        FadeIn.Completed:Wait()
    end
end
spawn(FadeLoop)

-- // MAIN UI WINDOW
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 600, 0, 400)
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 2
UIStroke.Color = Color3.fromRGB(80, 80, 80)
UIStroke.Parent = MainFrame

-- // TOP BAR (DRAGGABLE)
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 30)
TopBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TopBar.Parent = MainFrame

local function Dragify(frame)
    local dragging, dragInput, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end
Dragify(MainFrame)

-- // UI EXPANSION ANIMATION
local function ShowUI()
    MainFrame.Visible = true
    MainFrame.Size = UDim2.new(0, 0, 0, 0)

    local Expand = TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, 600, 0, 400)})
    Expand:Play()
end

-- // DESTROY LOADING SCREEN & SHOW UI
task.wait(5)
LoadingFrame:Destroy()
ShowUI()

-- // TABS SYSTEM
local TabsHolder = Instance.new("Frame")
TabsHolder.Size = UDim2.new(1, 0, 0, 30)
TabsHolder.Position = UDim2.new(0, 0, 0, 30)
TabsHolder.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TabsHolder.Parent = MainFrame

local Tabs = {}

function FluentHub:CreateTab(Name)
    local TabButton = Instance.new("TextButton")
    TabButton.Size = UDim2.new(0, 100, 0, 30)
    TabButton.Text = Name
    TabButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    TabButton.Parent = TabsHolder
    
    local TabFrame = Instance.new("Frame")
    TabFrame.Size = UDim2.new(1, 0, 1, -60)
    TabFrame.Position = UDim2.new(0, 0, 0, 60)
    TabFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    TabFrame.Visible = false
    TabFrame.Parent = MainFrame
    
    Tabs[Name] = TabFrame
    
    TabButton.MouseButton1Click:Connect(function()
        for _, Tab in pairs(Tabs) do
            Tab.Visible = false
        end
        TabFrame.Visible = true
    end)
    
    return TabFrame
end

-- // BUTTON SYSTEM
function FluentHub:CreateButton(Parent, Text, Callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -10, 0, 40)
    Button.Position = UDim2.new(0, 5, 0, 5)
    Button.Text = Text
    Button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    Button.Parent = Parent
    
    Button.MouseButton1Click:Connect(Callback)
end

-- // NOTIFICATIONS
local NotificationFrame = Instance.new("Frame")
NotificationFrame.Size = UDim2.new(0, 300, 0, 50)
NotificationFrame.Position = UDim2.new(1, -320, 0, 20)
NotificationFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
NotificationFrame.Visible = false
NotificationFrame.Parent = ScreenGui

local NotificationText = Instance.new("TextLabel")
NotificationText.Size = UDim2.new(1, 0, 1, 0)
NotificationText.TextColor3 = Color3.fromRGB(255, 255, 255)
NotificationText.BackgroundTransparency = 1
NotificationText.Parent = NotificationFrame

function FluentHub:Notify(Text)
    NotificationText.Text = Text
    NotificationFrame.Visible = true
    
    local FadeOut = TweenService:Create(NotificationFrame, TweenInfo.new(2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundTransparency = 1})
    task.wait(3)
    FadeOut:Play()
    FadeOut.Completed:Wait()
    NotificationFrame.Visible = false
    NotificationFrame.BackgroundTransparency = 0
end

return FluentHub
