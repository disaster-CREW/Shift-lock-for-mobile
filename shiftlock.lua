--[[
    Mobile Shiftlock Script (Draggable + Kill Switch + Jump Button Positioning + Inverted Colors + Drag Fix)
    Made by Disaster & Copilot
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MobileShiftlockGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

-- MAIN BUTTON (BLUE)
local ButtonFrame = Instance.new("TextButton")
ButtonFrame.Name = "ShiftlockFrame"
ButtonFrame.Parent = ScreenGui
ButtonFrame.Size = UDim2.new(0, 60, 0, 60)
ButtonFrame.AnchorPoint = Vector2.new(0.5, 0.5)
ButtonFrame.Position = UDim2.new(0.85, 0, 0.5, 0)
ButtonFrame.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
ButtonFrame.Text = ""
ButtonFrame.AutoButtonColor = false
ButtonFrame.ZIndex = 3

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = ButtonFrame

-- CLEAN OUTLINE CONTAINER
local Outline = Instance.new("Frame")
Outline.Name = "Outline"
Outline.Parent = ScreenGui
Outline.Size = UDim2.new(0, 70, 0, 70)
Outline.AnchorPoint = Vector2.new(0.5, 0.5)
Outline.Position = ButtonFrame.Position
Outline.BackgroundTransparency = 1
Outline.BorderSizePixel = 0
Outline.ZIndex = 1

local outlineCorner = Instance.new("UICorner")
outlineCorner.CornerRadius = UDim.new(1, 0)
outlineCorner.Parent = Outline

-- NEON GLOW
local Glow = Instance.new("UIStroke")
Glow.Parent = Outline
Glow.Thickness = 3
Glow.Color = Color3.fromRGB(0, 255, 255)
Glow.Transparency = 0.05
Glow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local Aura = Instance.new("Frame")
Aura.Parent = Outline
Aura.Size = UDim2.new(1, 12, 1, 12)
Aura.Position = UDim2.new(0.5, 0, 0.5, 0)
Aura.AnchorPoint = Vector2.new(0.5, 0.5)
Aura.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
Aura.BorderSizePixel = 0
Aura.BackgroundTransparency = 0.9
Aura.ZIndex = 0

local auraCorner = Instance.new("UICorner")
auraCorner.CornerRadius = UDim.new(1, 0)
auraCorner.Parent = Aura

local auraStroke = Instance.new("UIStroke")
auraStroke.Parent = Aura
auraStroke.Thickness = 6
auraStroke.Color = Color3.fromRGB(0, 255, 255)
auraStroke.Transparency = 0.75
auraStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- SHIFTLOCK ICON
local ToggleIcon = Instance.new("ImageLabel")
ToggleIcon.Name = "ShiftlockIcon"
ToggleIcon.Parent = ButtonFrame
ToggleIcon.BackgroundTransparency = 1
ToggleIcon.Size = UDim2.new(0, 40, 0, 40)
ToggleIcon.Position = UDim2.new(0.5, -20, 0.5, -20)
ToggleIcon.Image = "rbxasset://textures/ui/mouseLock_off@2x.png"
ToggleIcon.ZIndex = 4

-- ICON OFF = DARK BLUE
ToggleIcon.ImageColor3 = Color3.fromRGB(30, 60, 255)

-- X BUTTON
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseShiftlock"
CloseButton.Parent = ButtonFrame
CloseButton.Size = UDim2.new(0, 20, 0, 20)
CloseButton.Position = UDim2.new(1, -10, 0, -10)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 14
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.AutoButtonColor = false
CloseButton.ZIndex = 5

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(1, 0)
closeCorner.Parent = CloseButton

---------------------------------------------------------------------
-- POSITION NEXT TO MOBILE JUMP BUTTON
---------------------------------------------------------------------

task.spawn(function()
    local playerGui = Player:WaitForChild("PlayerGui")
    local touchGui = playerGui:WaitForChild("TouchGui", 5)

    if touchGui then
        local touchControlFrame = touchGui:WaitForChild("TouchControlFrame", 5)
        if touchControlFrame then
            local jumpButton = touchControlFrame:FindFirstChild("JumpButton")

            if jumpButton then
                local pos = UDim2.new(
                    jumpButton.Position.X.Scale,
                    jumpButton.Position.X.Offset - 80,
                    jumpButton.Position.Y.Scale,
                    jumpButton.Position.Y.Offset
                )

                ButtonFrame.Position = pos
                Outline.Position = pos
            end
        end
    end
end)

---------------------------------------------------------------------
-- CONNECTION STORAGE
---------------------------------------------------------------------

local connections = {}

local function connect(event, func)
    local c = event:Connect(func)
    table.insert(connections, c)
    return c
end

local function shutdown()
    if Player.Character and Player.Character:FindFirstChild("Humanoid") then
        Player.Character.Humanoid.AutoRotate = true
        Player.Character.Humanoid.CameraOffset = Vector3.new(0, 0, 0)
    end

    ScreenGui.Enabled = false

    for _, c in ipairs(connections) do
        c:Disconnect()
    end

    ButtonFrame.Active = false
    CloseButton.Active = false

    print("Shiftlock script fully shut down.")
end

CloseButton.MouseButton1Click:Connect(shutdown)

---------------------------------------------------------------------
-- DRAGGING SYSTEM
---------------------------------------------------------------------

local dragging = false
local dragStart
local startPos
local draggingTouch = nil

connect(ButtonFrame.InputBegan, function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        draggingTouch = input
        dragStart = input.Position
        startPos = ButtonFrame.Position
    end
end)

connect(ButtonFrame.InputEnded, function(input)
    if input == draggingTouch then
        dragging = false
        draggingTouch = nil
    end
end)

connect(UserInputService.InputChanged, function(input)
    if dragging and input == draggingTouch then
        local delta = input.Position - dragStart

        local newPos = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )

        ButtonFrame.Position = newPos
        Outline.Position = newPos
    end
end)

---------------------------------------------------------------------
-- SHIFTLOCK LOGIC + ICON COLOR LOGIC
---------------------------------------------------------------------

local shiftLockEnabled = false
local CameraOffset = Vector3.new(1.7, 0.5, 0)

connect(ButtonFrame.MouseButton1Click, function()
    shiftLockEnabled = not shiftLockEnabled
    
    if shiftLockEnabled then
        -- ICON ON = RED
        ToggleIcon.ImageColor3 = Color3.fromRGB(255, 60, 60)

        if Player.Character and Player.Character:FindFirstChild("Humanoid") then
            Player.Character.Humanoid.AutoRotate = false
        end

        -- Hide Roblox cursor
        UserInputService.MouseIconEnabled = false
        UserInputService.MouseIcon = ""

    else
        -- ICON OFF = DARK BLUE
        ToggleIcon.ImageColor3 = Color3.fromRGB(30, 60, 255)

        if Player.Character and Player.Character:FindFirstChild("Humanoid") then
            Player.Character.Humanoid.AutoRotate = true
            Player.Character.Humanoid.CameraOffset = Vector3.new(0, 0, 0)
        end

        -- Restore cursor
        UserInputService.MouseIconEnabled = true
    end
end)

connect(RunService.RenderStepped, function()
    if shiftLockEnabled then
        if Player.Character 
        and Player.Character:FindFirstChild("HumanoidRootPart") 
        and Player.Character:FindFirstChild("Humanoid") then
            
            Player.Character.Humanoid.CameraOffset = CameraOffset
            
            local rootPart = Player.Character.HumanoidRootPart
            local lookVector = Camera.CFrame.LookVector
            
            rootPart.CFrame = CFrame.new(
                rootPart.Position, 
                rootPart.Position + Vector3.new(lookVector.X, 0, lookVector.Z)
            )
        end
    end
end)
