--[[
    Mobile Shiftlock Script (Draggable + Kill Switch + Jump Button Positioning + Thin Blue Outline)
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

-- MAIN BUTTON
local ButtonFrame = Instance.new("TextButton")
ButtonFrame.Name = "ShiftlockFrame"
ButtonFrame.Parent = ScreenGui
ButtonFrame.Size = UDim2.new(0, 60, 0, 60)
ButtonFrame.AnchorPoint = Vector2.new(0.5, 0.5)
ButtonFrame.Position = UDim2.new(0.85, 0, 0.5, 0)
ButtonFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ButtonFrame.Text = ""
ButtonFrame.AutoButtonColor = false
ButtonFrame.ZIndex = 3

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = ButtonFrame

-- BLUE OUTLINE (THINNER)
local Outline = Instance.new("Frame")
Outline.Name = "Outline"
Outline.Parent = ScreenGui
Outline.Size = UDim2.new(0, 66, 0, 66) -- 3px outline around 60px button
Outline.AnchorPoint = Vector2.new(0.5, 0.5)
Outline.Position = ButtonFrame.Position
Outline.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
Outline.BorderSizePixel = 0
Outline.ZIndex = 2

local outlineCorner = Instance.new("UICorner")
outlineCorner.CornerRadius = UDim.new(1, 0)
outlineCorner.Parent = Outline

-- SHIFTLOCK ICON
local ToggleIcon = Instance.new("ImageLabel")
ToggleIcon.Name = "ShiftlockIcon"
ToggleIcon.Parent = ButtonFrame
ToggleIcon.BackgroundTransparency = 1
ToggleIcon.Size = UDim2.new(0, 40, 0, 40)
ToggleIcon.Position = UDim2.new(0.5, -20, 0.5, -20)
ToggleIcon.Image = "rbxasset://textures/ui/mouseLock_off@2x.png"
ToggleIcon.ZIndex = 4

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
-- CONNECTION STORAGE (for kill switch)
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
-- DRAGGING SYSTEM (OUTLINE FOLLOWS PERFECTLY)
---------------------------------------------------------------------

local dragging = false
local dragStart
local startPos

connect(ButtonFrame.InputBegan, function(input)
    if input.UserInputType == Enum.UserInputType.Touch 
    or input.UserInputType == Enum.UserInputType.MouseButton1 then
        
        dragging = true
        dragStart = input.Position
        startPos = ButtonFrame.Position

        connect(input.Changed, function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

connect(UserInputService.InputChanged, function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch 
    or input.UserInputType == Enum.UserInputType.MouseMovement) then
        
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
-- CROSSHAIR
---------------------------------------------------------------------

local Crosshair = Instance.new("ImageLabel")
Crosshair.Name = "ShiftlockCursor"
Crosshair.Parent = ScreenGui
Crosshair.BackgroundTransparency = 1
Crosshair.Position = UDim2.new(0.5, 0, 0.5, 0)
Crosshair.AnchorPoint = Vector2.new(0.5, 0.5)
Crosshair.Size = UDim2.new(0, 32, 0, 32)
Crosshair.Image = "rbxasset://textures/MouseLockedCursor.png"
Crosshair.Visible = false
Crosshair.ZIndex = 10

---------------------------------------------------------------------
-- SHIFTLOCK LOGIC
---------------------------------------------------------------------

local shiftLockEnabled = false
local CameraOffset = Vector3.new(1.7, 0.5, 0)

connect(ButtonFrame.MouseButton1Click, function()
    shiftLockEnabled = not shiftLockEnabled
    
    if shiftLockEnabled then
        ToggleIcon.Image = "rbxasset://textures/ui/mouseLock_on@2x.png"
        Crosshair.Visible = true
        if Player.Character and Player.Character:FindFirstChild("Humanoid") then
            Player.Character.Humanoid.AutoRotate = false
        end
    else
        ToggleIcon.Image = "rbxasset://textures/ui/mouseLock_off@2x.png"
        Crosshair.Visible = false
        if Player.Character and Player.Character:FindFirstChild("Humanoid") then
            Player.Character.Humanoid.AutoRotate = true
            Player.Character.Humanoid.CameraOffset = Vector3.new(0, 0, 0)
        end
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
