-- AEZY HUB RAZ (Paid)
-- Gold Theme Edition | Optimized Graphics | FPS & Ping Display | Minimize System
-- Integrated with Anti-Ragdoll, Effects Logic & Auto X-Ray (No X-Ray GUI)

-- WHITELIST
local whitelist = {
    "Zxyplo213",
    "poulet123445",
    "itznotrealreal",
    "Mongralcba321",
    "RANE1167840",
    "Alessandro_The8svc",
    "soul_reaper0746",
    "naimplays2016",
    " jdp_jan6",
}

local function isWhitelisted(name)
    for _, v in ipairs(whitelist) do
        if v:lower() == name:lower() then
            return true
        end
    end
    return false
end

-- SERVICES
local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local StatsService = game:GetService("Stats")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

if not isWhitelisted(LocalPlayer.Name) then
    LocalPlayer:Kick("Not Whitelisted")
    return
end

if _G.RyxxInstantStealLoaded then return end
_G.RyxxInstantStealLoaded = true

-- ================================
-- ANTI-RAGDOLL & EFFECTS LOGIC
-- ================================
local PlayerModule = require(LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"))
local Controls = PlayerModule:GetControls()
local ENABLE_ANTI_RAGDOLL = true
local ENABLE_ANTI_ITEM = true
local Frozen = false
local DisabledRemotes = {}
local BlockedStates = {
	[Enum.HumanoidStateType.Ragdoll] = true,
	[Enum.HumanoidStateType.FallingDown] = true,
	[Enum.HumanoidStateType.Physics] = true,
	[Enum.HumanoidStateType.Dead] = true
}
local RemoteKeywords = { "useitem", "combatservice", "ragdoll" }

local function ForceNormal(character)
	local hum = character:FindFirstChildOfClass("Humanoid")
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hum or not hrp then return end
	hum.Health = hum.MaxHealth
	hum:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
	if not Frozen then
		Frozen = true
		hrp.Anchored = true
		hrp.AssemblyLinearVelocity = Vector3.zero
		hrp.AssemblyAngularVelocity = Vector3.zero
		hrp.CFrame += Vector3.new(0, 1.5, 0)
	end
end

local function Release(character)
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if hrp and Frozen then
		hrp.Anchored = false
		Frozen = false
	end
end

local function RestoreMotors(character)
	for _, v in ipairs(character:GetDescendants()) do
		if v:IsA("Motor6D") then
			v.Enabled = true
		elseif v:IsA("Constraint") then
			v.Enabled = false
		end
	end
end

local function InitAntiRagdoll(character)
	local hum = character:WaitForChild("Humanoid", 10)
	if not hum then return end
	for state in pairs(BlockedStates) do
		hum:SetStateEnabled(state, false)
	end
	hum.StateChanged:Connect(function(_, new)
		if ENABLE_ANTI_RAGDOLL and BlockedStates[new] then
			ForceNormal(character)
			RestoreMotors(character)
		end
	end)
	RunService.Stepped:Connect(function()
		if not ENABLE_ANTI_RAGDOLL then
			Release(character)
			return
		end
		if BlockedStates[hum:GetState()] then
			ForceNormal(character)
		else
			Release(character)
		end
		hum.Health = hum.MaxHealth
	end)
end

local function KillRemote(remote)
	if not getconnections or not remote:IsA("RemoteEvent") then return end
	if DisabledRemotes[remote] then return end
	local name = remote.Name:lower()
	for _, key in ipairs(RemoteKeywords) do
		if name:find(key) then
			DisabledRemotes[remote] = {}
			for _, c in ipairs(getconnections(remote.OnClientEvent)) do
				if c.Disable then
					c:Disable()
					table.insert(DisabledRemotes[remote], c)
				end
			end
			break
		end
	end
end

local function InitAntiItem()
	Controls:Enable()
	for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
		KillRemote(obj)
	end
	ReplicatedStorage.DescendantAdded:Connect(KillRemote)
end

-- ================================
-- FPS & PING DISPLAY (GOLD)
-- ================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "StatsDisplay"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local StatsLabel = Instance.new("TextLabel")
StatsLabel.Size = UDim2.new(0, 300, 0, 70)
StatsLabel.Position = UDim2.new(0.5, -150, 0.1, -35)
StatsLabel.BackgroundTransparency = 1
StatsLabel.Font = Enum.Font.FredokaOne
StatsLabel.TextSize = 30
StatsLabel.TextColor3 = Color3.fromRGB(255, 215, 0) -- Gold
StatsLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
StatsLabel.TextStrokeTransparency = 0
StatsLabel.Text = "0 | 0"
StatsLabel.Parent = ScreenGui

RunService.Heartbeat:Connect(function()
    local ping = math.floor(StatsService.Network.ServerStatsItem["Data Ping"]:GetValue())
    local fps = math.floor(1 / RunService.RenderStepped:Wait())
    StatsLabel.Text = ping .. " | " .. fps
end)

-- ================================
-- AUTO X-RAY LOGIC
-- ================================
local function autoXRay()
    RunService.Heartbeat:Connect(function()
        local Plots = Workspace:FindFirstChild("Plots")
        if Plots then
            for _, Plot in ipairs(Plots:GetChildren()) do
                if Plot:IsA("Model") and Plot:FindFirstChild("Decorations") then
                    for _, Part in ipairs(Plot.Decorations:GetDescendants()) do
                        if Part:IsA("BasePart") then Part.Transparency = 0.8 end
                    end
                end
            end
        end
    end)
end

-- ================================
-- GOLD ESP LOGIC
-- ================================
local Plots = Workspace:WaitForChild("Plots")
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local ownBasePos
local GOLD_COLOR = Color3.fromRGB(255, 215, 0)

local function getOwnBasePosition()
    for _, plot in ipairs(Plots:GetChildren()) do
        local sign = plot:FindFirstChild("PlotSign")
        local base = plot:FindFirstChild("DeliveryHitbox")
        if sign and sign:FindFirstChild("YourBase") and sign.YourBase.Enabled and base then
            return base.Position
        end
    end
    return nil
end

local ESPFolder = PlayerGui:FindFirstChild("PlayerESP") or Instance.new("Folder")
ESPFolder.Name = "PlayerESP"
ESPFolder.Parent = PlayerGui

local function createOrUpdatePlayerESP(player)
    if player == LocalPlayer then return end
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = player.Character.HumanoidRootPart
    local highlight = ESPFolder:FindFirstChild(player.Name.."_Highlight") or Instance.new("Highlight", ESPFolder)
    highlight.Name = player.Name.."_Highlight"
    highlight.FillColor, highlight.FillTransparency = GOLD_COLOR, 0.6
    highlight.OutlineColor, highlight.Adornee = Color3.fromRGB(255, 255, 255), player.Character

    local billboard = ESPFolder:FindFirstChild(player.Name) or Instance.new("BillboardGui", ESPFolder)
    billboard.Name = player.Name
    billboard.Adornee, billboard.AlwaysOnTop = hrp, true
    billboard.Size, billboard.StudsOffset = UDim2.new(0, 200, 0, 50), Vector3.new(0, 3, 0)

    local label = billboard:FindFirstChild("Label") or Instance.new("TextLabel", billboard)
    label.Name = "Label"
    label.Size, label.BackgroundTransparency = UDim2.new(1, 0, 1, 0), 1
    label.TextColor3, label.Font, label.TextScaled = GOLD_COLOR, Enum.Font.GothamBold, true
    label.Text = player.DisplayName or player.Name
end

local function createOrUpdatePlotESP(plot)
    local purchases = plot:FindFirstChild("Purchases")
    if not purchases or not purchases:FindFirstChild("PlotBlock") then return end
    local main = purchases.PlotBlock:FindFirstChild("Main")
    if not main then return end
    local base = plot:FindFirstChild("DeliveryHitbox")
    if base and ownBasePos and (base.Position - ownBasePos).Magnitude < 1 then return end

    local billboard = main:FindFirstChild("ESP_Billboard") or Instance.new("BillboardGui", main)
    billboard.Name = "ESP_Billboard"
    billboard.Adornee, billboard.Size, billboard.AlwaysOnTop = main, UDim2.new(0, 200, 0, 50), true
    billboard.StudsOffset = Vector3.new(0, 5, 0)

    local label = billboard:FindFirstChild("Label") or Instance.new("TextLabel", billboard)
    label.Name = "Label"
    label.Size, label.BackgroundTransparency = UDim2.new(1, 0, 1, 0), 1
    label.TextColor3, label.Font, label.TextScaled = GOLD_COLOR, Enum.Font.GothamBold, true

    local remainingTimeGui = main:FindFirstChild("BillboardGui") and main.BillboardGui:FindFirstChild("RemainingTime")
    if remainingTimeGui then
        local text = remainingTimeGui:IsA("TextLabel") and remainingTimeGui.Text or tostring(remainingTimeGui.Value)
        if text == "0s" or text == "0" then label.Text = "[ UNLOCKED ]" label.TextColor3 = Color3.fromRGB(0, 255, 0)
        else label.Text = "Time: " .. text label.TextColor3 = GOLD_COLOR end
    end
end

task.spawn(function()
    while true do
        ownBasePos = getOwnBasePosition()
        for _, plot in pairs(Plots:GetChildren()) do pcall(function() createOrUpdatePlotESP(plot) end) end
        for _, player in pairs(Players:GetPlayers()) do pcall(function() createOrUpdatePlayerESP(player) end) end
        task.wait(0.5)
    end
end)

-- ================================
-- DESYNC & GUI
-- ================================
local FFlags = {
    GameNetPVHeaderRotationalVelocityZeroCutoffExponent = -5000,
    LargeReplicatorWrite5 = true, LargeReplicatorEnabled9 = true,
    AngularVelociryLimit = 360, TimestepArbiterVelocityCriteriaThresholdTwoDt = 2147483646,
    S2PhysicsSenderRate = 15000, DisableDPIScale = true,
    MaxDataPacketPerSend = 2147483647, PhysicsSenderMaxBandwidthBps = 20000,
    TimestepArbiterHumanoidLinearVelThreshold = 21, MaxMissedWorldStepsRemembered = -2147483648,
    PlayerHumanoidPropertyUpdateRestrict = true, SimDefaultHumanoidTimestepMultiplier = 0,
    StreamJobNOUVolumeLengthCap = 2147483647, DebugSendDistInSteps = -2147483648,
    GameNetDontSendRedundantNumTimes = 1, CheckPVLinearVelocityIntegrateVsDeltaPositionThresholdPercent = 1,
    CheckPVDifferencesForInterpolationMinVelThresholdStudsPerSecHundredth = 1,
    LargeReplicatorSerializeRead3 = true, ReplicationFocusNouExtentsSizeCutoffForPauseStuds = 2147483647,
    CheckPVCachedVelThresholdPercent = 10, CheckPVDifferencesForInterpolationMinRotVelThresholdRadsPerSecHundredth = 1,
    GameNetDontSendRedundantDeltaPositionMillionth = 1, InterpolationFrameVelocityThresholdMillionth = 5,
    StreamJobNOUVolumeCap = 2147483647, InterpolationFrameRotVelocityThresholdMillionth = 5,
    CheckPVCachedRotVelThresholdPercent = 10, WorldStepMax = 30,
    InterpolationFramePositionThresholdMillionth = 5, TimestepArbiterHumanoidTurningVelThreshold = 1,
    SimOwnedNOUCountThresholdMillionth = 2147483647, GameNetPVHeaderLinearVelocityZeroCutoffExponent = -5000,
    NextGenReplicatorEnabledWrite4 = true, TimestepArbiterOmegaThou = 1073741823,
    MaxAcceptableUpdateDelay = 1, LargeReplicatorSerializeWrite4 = true
}

local function ApplyFFlags()
    for name, value in pairs(FFlags) do pcall(function() setfflag(tostring(name), tostring(value)) end) end
end

local DesyncESPFolder, ServerESP, serverPosition, positionConn

local function RespawnPlayer()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then hum:ChangeState(Enum.HumanoidStateType.Dead) end
    char:ClearAllChildren()
    local temp = Instance.new("Model", Workspace)
    LocalPlayer.Character = temp
    task.wait()
    LocalPlayer.Character = char
    temp:Destroy()
end

local function SetServerESP()
    if positionConn then positionConn:Disconnect() end
    if DesyncESPFolder then DesyncESPFolder:Destroy() end
    DesyncESPFolder = Instance.new("Folder", Workspace)
    DesyncESPFolder.Name = "DesyncESP"
    ServerESP = Instance.new("Part", DesyncESPFolder)
    ServerESP.Size, ServerESP.Anchored, ServerESP.CanCollide = Vector3.new(2, 5, 2), true, false
    ServerESP.Material, ServerESP.Color, ServerESP.Transparency = Enum.Material.Neon, GOLD_COLOR, 0.25
    Instance.new("Highlight", ServerESP).FillColor = GOLD_COLOR
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        positionConn = hrp:GetPropertyChangedSignal("Position"):Connect(function()
            task.wait(0.15) if hrp then ServerESP.CFrame = CFrame.new(hrp.Position) end
        end)
    end
end

-- TARGETS
local targetPositions = {
    Vector3.new(-481.88, -3.79, 138.02), Vector3.new(-481.75, -3.79, 89.18),
    Vector3.new(-481.82, -3.79, 30.95), Vector3.new(-481.75, -3.79, -17.79),
    Vector3.new(-481.80, -3.79, -76.06), Vector3.new(-481.72, -3.79, -124.70),
    Vector3.new(-337.45, -3.85, -124.72), Vector3.new(-337.37, -3.85, -76.07),
    Vector3.new(-337.46, -3.79, -17.72), Vector3.new(-337.41, -3.79, 30.92),
    Vector3.new(-337.32, -3.79, 89.02), Vector3.new(-337.27, -3.79, 137.90),
    Vector3.new(-337.45, -3.79, 196.29), Vector3.new(-337.37, -3.79, 244.91),
    Vector3.new(-481.72, -3.79, 196.21), Vector3.new(-481.76, -3.79, 244.92)
}

-- MAIN GUI
local mainGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
mainGui.Name = "AezyInstantStealUI"
mainGui.ResetOnSpawn = false

local frame = Instance.new("Frame", mainGui)
frame.Size, frame.Position = UDim2.fromOffset(250, 235), UDim2.fromScale(0.5, 0.5) -- Height increased for Discord text
frame.AnchorPoint, frame.BackgroundColor3 = Vector2.new(0.5, 0.5), Color3.fromRGB(25, 20, 10)
frame.Active, frame.Draggable, frame.ClipsDescendants = true, true, true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", frame).Color = GOLD_COLOR

local title = Instance.new("TextLabel", frame)
title.Size, title.Position = UDim2.new(1, -10, 0, 34), UDim2.fromOffset(5, 5)
title.BackgroundTransparency, title.Text, title.TextColor3 = 1, "AEZY INSTANT STEAL", GOLD_COLOR
title.Font, title.TextSize = Enum.Font.GothamBold, 18

local status = Instance.new("TextLabel", frame)
status.Size, status.Position = UDim2.new(1, -10, 0, 24), UDim2.fromOffset(5, 42)
status.BackgroundTransparency, status.Text, status.TextColor3 = 1, "Status: Ready", Color3.fromRGB(218, 165, 32)
status.Font, status.TextSize = Enum.Font.GothamMedium, 14

local setBtn = Instance.new("TextButton", frame)
setBtn.Size, setBtn.Position = UDim2.new(1, -24, 0, 38), UDim2.fromOffset(12, 80)
setBtn.BackgroundColor3, setBtn.Text, setBtn.TextColor3 = GOLD_COLOR, "SET POSITION", Color3.fromRGB(40, 30, 0)
setBtn.Font, setBtn.TextSize = Enum.Font.GothamBold, 16
Instance.new("UICorner", setBtn).CornerRadius = UDim.new(0, 8)

local desyncBtn = Instance.new("TextButton", frame)
desyncBtn.Size, desyncBtn.Position = UDim2.new(1, -24, 0, 38), UDim2.fromOffset(12, 126)
desyncBtn.BackgroundColor3, desyncBtn.Text, desyncBtn.TextColor3 = GOLD_COLOR, "ENABLE DESYNC", Color3.fromRGB(40, 30, 0)
desyncBtn.Font, desyncBtn.TextSize = Enum.Font.GothamBold, 16
Instance.new("UICorner", desyncBtn).CornerRadius = UDim.new(0, 8)

-- DISCORD TEXT
local discordText = Instance.new("TextLabel", frame)
discordText.Size, discordText.Position = UDim2.new(1, -20, 0, 30), UDim2.fromOffset(10, 175)
discordText.BackgroundTransparency, discordText.Text = 1, "https://discord.gg/9ENmbaey"
discordText.TextColor3, discordText.Font, discordText.TextSize = GOLD_COLOR, Enum.Font.GothamMedium, 13
discordText.TextXAlignment = Enum.TextXAlignment.Center

local minBtn = Instance.new("TextButton", frame)
minBtn.Size, minBtn.Position = UDim2.fromOffset(14, 14), UDim2.new(1, -22, 0, 10)
minBtn.BackgroundColor3, minBtn.Text = Color3.fromRGB(255, 60, 60), ""
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(1, 0)

local minimized = false
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    local ts = minimized and UDim2.fromOffset(250, 40) or UDim2.fromOffset(250, 235)
    TweenService:Create(frame, TweenInfo.new(0.3), {Size = ts}):Play()
end)

-- BEAMS & BUTTON LOGIC
local pos1, pos2, beam1, beam2, part1, part2
local function createBeam(pos, idx)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local p = Instance.new("Part", Workspace)
    p.Anchored, p.CanCollide, p.Transparency = true, false, 1 p.CFrame = CFrame.new(pos)
    local b = Instance.new("Beam", Workspace)
    b.Attachment0, b.Attachment1 = Instance.new("Attachment", p), Instance.new("Attachment", char.HumanoidRootPart)
    b.Width0, b.Width1, b.Color = 0.7, 0.7, ColorSequence.new(GOLD_COLOR)
    if idx == 1 then if beam1 then beam1:Destroy() end if part1 then part1:Destroy() end beam1, part1 = b, p
    else if beam2 then beam2:Destroy() end if part2 then part2:Destroy() end beam2, part2 = b, p end
end

setBtn.MouseButton1Click:Connect(function()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then pos1 = hrp.CFrame createBeam(pos1.Position, 1) status.Text = "Status: Position Set" end
end)

desyncBtn.MouseButton1Click:Connect(function()
    desyncBtn.Text, desyncBtn.BackgroundColor3 = "DESYNC ENABLED", Color3.fromRGB(184, 134, 11)
    status.Text = "Status: Desync Active"
    ApplyFFlags() RespawnPlayer() task.wait(0.6) SetServerESP()
end)

task.spawn(function()
    while task.wait(1) do
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local closest, dist = nil, math.huge
            for _, v in ipairs(targetPositions) do
                local d = (hrp.Position - v).Magnitude
                if d < dist then dist = d closest = v end
            end
            if closest then pos2 = CFrame.new(closest) createBeam(pos2.Position, 2) end
        end
    end
end)

ProximityPromptService.PromptButtonHoldEnded:Connect(function(prompt, who)
    if who ~= LocalPlayer or (prompt.Name ~= "Steal" and prompt.ActionText ~= "Steal") then return end
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        if pos1 then hrp.CFrame = pos1 end
        if pos2 then task.wait(0.05); hrp.CFrame = pos2 end
        status.Text = "Status: Steal Executed"
    end
end)

-- INITIALIZE EVERYTHING
autoXRay()
LocalPlayer.CharacterAdded:Connect(function(c) task.wait(0.4) InitAntiRagdoll(c) end)
if LocalPlayer.Character then InitAntiRagdoll(LocalPlayer.Character) end
if ENABLE_ANTI_ITEM then task.delay(0.25, InitAntiItem) end
