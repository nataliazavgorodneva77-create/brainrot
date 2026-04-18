-- DESYNC SCRIPT
local players = game:GetService("Players")
local userInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")

local player = players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- UI SETUP
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DesyncGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = game:GetService("CoreGui")

-- Enable Button
local enableBtn = Instance.new("TextButton")
enableBtn.Name = "EnableDesync"
enableBtn.Size = UDim2.new(0, 150, 0, 50)
enableBtn.Position = UDim2.new(0.5, -160, 0, 10)
enableBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
enableBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
enableBtn.TextSize = 14
enableBtn.Font = Enum.Font.GothamBold
enableBtn.Text = "Enable Desync"
enableBtn.Parent = screenGui

-- Disable Button
local disableBtn = Instance.new("TextButton")
disableBtn.Name = "DisableDesync"
disableBtn.Size = UDim2.new(0, 150, 0, 50)
disableBtn.Position = UDim2.new(0.5, 10, 0, 10)
disableBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
disableBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
disableBtn.TextSize = 14
disableBtn.Font = Enum.Font.GothamBold
disableBtn.Text = "Disable Desync"
disableBtn.Parent = screenGui

-- Function to respawn character
local function respawnCharacter()
    if character and character:FindFirstChild("Humanoid") then
        character.Humanoid.Health = 0
        wait(0.5)
    end
end

-- Enable Desync Button Click
enableBtn.MouseButton1Click:Connect(function()
    pcall(function()
        raknet.desync(true)
        respawnCharacter()
        enableBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        wait(0.2)
        enableBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    end)
end)

-- Disable Desync Button Click
disableBtn.MouseButton1Click:Connect(function()
    pcall(function()
        raknet.desync(false)
        disableBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        wait(0.2)
        disableBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    end)
end)

-- Handle character respawn
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
end)

print("Desync script loaded. Buttons ready.")
