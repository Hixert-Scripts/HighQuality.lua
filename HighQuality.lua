-- TSB Anti-Lag v12.15 - HIGH QUALITY
print("✅ TSB Anti-Lag v12.15 Loaded - HIGH QUALITY")

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")
local UserSettings = game:GetService("UserSettings")
local SoundService = game:GetService("SoundService")
local LocalPlayer = Players.LocalPlayer

local playerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ========== SKY ==========
local function applySky()
    pcall(function()
        local sky = Lighting:FindFirstChild("Sky")
        if sky then
            sky.SunTextureId = ""
            sky.MoonTextureId = ""
            sky.CelestialBodiesShown = false
        end
        Lighting.FogEnd = 100000
        Lighting.FogStart = 100000
    end)
end
applySky()

-- ========== VISUAL GUARDIAN ==========
local function VisualGuardian()
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level03
        settings().Graphics.QualityLevel = Enum.QualityLevel.Level03
    end)
    Lighting.GlobalShadows = false
    Lighting.Brightness = 1.2
end
VisualGuardian()

task.spawn(function()
    while task.wait(2) do
        pcall(VisualGuardian)
        pcall(applySky)
    end
end)

-- ========== ACCESSORY HIDER ==========
local function HideAccessories(character)
    if not character then return
    for _, v in pairs(character:GetDescendants()) do
        if v:IsA("BasePart") and v.Parent and v.Parent:IsA("Accessory") then
            local attachment = v:FindFirstChildOfClass("Attachment")
            if attachment and string.find(attachment.Name or "", "Shoulder") then
                v.Transparency = 0
            else
                v.Transparency = 1
            end
        end
    end
end

if LocalPlayer.Character then HideAccessories(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(function(character)
    task.wait(0.5)
    pcall(function() HideAccessories(character) end)
end)

-- ========== PRESERVE COLLISION ==========
local function PreserveCollision()
    pcall(function()
        for _, part in ipairs(Workspace:GetDescendants()) do
            if part:IsA("BasePart") then
                local name = part.Name:lower()
                if name:find("floor") or name:find("ground") or name:find("terrain") or 
                   name:find("platform") or name:find("baseplate") or part:IsA("Terrain") then
                    part.CanCollide = true
                    part.CanTouch = true
                end
            end
        end
    end)
end
task.spawn(function() while task.wait(5) do pcall(PreserveCollision) end end)

-- ========== THERMAL ==========
local thermalState = "NORMAL"
local lastFPSCheck = os.clock()
local currentFPS = 60
local thermalFPSDrop = 0

local function CheckThermal()
    local now = os.clock()
    if now - lastFPSCheck >= 10 then
        lastFPSCheck = now
        if currentFPS < 25 then
            thermalState = "HOT"
            thermalFPSDrop = 5
        elseif currentFPS < 35 then
            thermalState = "WARM"
            thermalFPSDrop = 3
        else
            thermalState = "NORMAL"
            thermalFPSDrop = 0
        end
    end
end

-- ========== FRAME PACING ==========
local frameHistory = {}
local lastFrameTime = os.clock()
local smoothedDelta = 1/60

RunService.RenderStepped:Connect(function(deltaTime)
    if deltaTime < 0.005 or deltaTime > 0.05 then return
    currentFPS = math.floor(1 / deltaTime)
    CheckThermal()
    local targetDelta = 1/(60 - thermalFPSDrop)
    table.insert(frameHistory, deltaTime)
    if #frameHistory > 5 then table.remove(frameHistory, 1) end
    local sum = 0
    for _, t in ipairs(frameHistory) do sum = sum + t end
    local avgDelta = sum / #frameHistory
    smoothedDelta = (smoothedDelta * 0.8) + (avgDelta * 0.2)
    smoothedDelta = math.min(smoothedDelta, targetDelta)
    local now = os.clock()
    local elapsed = now - lastFrameTime
    if elapsed < smoothedDelta then task.wait(smoothedDelta - elapsed) end
    lastFrameTime = os.clock()
end)

-- ========== SOUND ==========
pcall(function() 
    SoundService.AmbientReverb = Enum.ReverbType.NoReverb
    SoundService.Volume = 0.6
end)

-- ========== MONITOR ==========
local monitorGui = Instance.new("ScreenGui")
monitorGui.ResetOnSpawn = false
monitorGui.Name = "TSB_Monitor"
monitorGui.Parent = playerGui

local monitorFrame = Instance.new("Frame")
monitorFrame.Size = UDim2.new(0, 155, 0, 55)
monitorFrame.Position = UDim2.new(0, 8, 0, 35)
monitorFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
monitorFrame.BackgroundTransparency = 0.5
monitorFrame.BorderSizePixel = 1
monitorFrame.BorderColor3 = Color3.fromRGB(0, 255, 100)
monitorFrame.Parent = monitorGui

local monitorCorner = Instance.new("UICorner")
monitorCorner.CornerRadius = UDim.new(0, 5)
monitorCorner.Parent = monitorFrame

local titleBar = Instance.new("TextLabel")
titleBar.Size = UDim2.new(1, 0, 0, 13)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
titleBar.BackgroundTransparency = 0.2
titleBar.Text = "HIGH QUALITY"
titleBar.TextColor3 = Color3.fromRGB(0, 0, 0)
titleBar.TextSize = 7
titleBar.Font = Enum.Font.GothamBold
titleBar.TextXAlignment = Enum.TextXAlignment.Center
titleBar.Parent = monitorFrame

local FPSLabel = Instance.new("TextLabel")
FPSLabel.Size = UDim2.new(0.33, 0, 1, -30)
FPSLabel.Position = UDim2.new(0, 0, 0, 13)
FPSLabel.BackgroundTransparency = 1
FPSLabel.Text = "F:--"
FPSLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
FPSLabel.TextSize = 12
FPSLabel.Font = Enum.Font.RobotoMono
FPSLabel.TextXAlignment = Enum.TextXAlignment.Center
FPSLabel.Parent = monitorFrame

local PingLabel = Instance.new("TextLabel")
PingLabel.Size = UDim2.new(0.34, 0, 1, -30)
PingLabel.Position = UDim2.new(0.33, 0, 0, 13)
PingLabel.BackgroundTransparency = 1
PingLabel.Text = "P:--"
PingLabel.TextColor3 = Color3.fromRGB(60, 170, 255)
PingLabel.TextSize = 12
PingLabel.Font = Enum.Font.RobotoMono
PingLabel.TextXAlignment = Enum.TextXAlignment.Center
PingLabel.Parent = monitorFrame

local MemLabel = Instance.new("TextLabel")
MemLabel.Size = UDim2.new(0.33, 0, 1, -30)
MemLabel.Position = UDim2.new(0.67, 0, 0, 13)
MemLabel.BackgroundTransparency = 1
MemLabel.Text = "M:--"
MemLabel.TextColor3 = Color3.fromRGB(255, 170, 60)
MemLabel.TextSize = 12
MemLabel.Font = Enum.Font.RobotoMono
MemLabel.TextXAlignment = Enum.TextXAlignment.Center
MemLabel.Parent = monitorFrame

local thermalLabel = Instance.new("TextLabel")
thermalLabel.Size = UDim2.new(1, 0, 0, 10)
thermalLabel.Position = UDim2.new(0, 0, 0, 45)
thermalLabel.BackgroundTransparency = 1
thermalLabel.Text = "🌡️ NORMAL"
thermalLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
thermalLabel.TextSize = 7
thermalLabel.Font = Enum.Font.GothamBold
thermalLabel.TextXAlignment = Enum.TextXAlignment.Center
thermalLabel.Parent = monitorFrame

local fpsCounter = 0
local lastUpdate = os.clock()

RunService.RenderStepped:Connect(function()
    fpsCounter = fpsCounter + 1
    local now = os.clock()
    if now - lastUpdate >= 0.3 then
        local fps = math.floor(fpsCounter / 0.3)
        FPSLabel.Text = string.format("F:%d", fps)
        PingLabel.Text = string.format("P:%d", math.floor(LocalPlayer:GetNetworkPing() * 1000))
        MemLabel.Text = string.format("M:%d", math.floor(Stats:GetTotalMemoryUsageMb()))
        if thermalState == "HOT" then
            thermalLabel.Text = "🌡️ HOT"
            thermalLabel.TextColor3 = Color3.fromRGB(255, 170, 0)
        elseif thermalState == "WARM" then
            thermalLabel.Text = "🌡️ WARM"
            thermalLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
        else
            thermalLabel.Text = "🌡️ NORMAL"
            thermalLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
        end
        fpsCounter = 0
        lastUpdate = now
    end
end)

-- ========== REPLACE THESE WITH YOUR GITHUB GIST RAW URLs ==========
local BALANCED_LOADSTRING = 'loadstring(game:HttpGet("https://gist.githubusercontent.com/YOUR_USERNAME/RAW_ID/raw/Balanced.lua"))()'
local PERFORMANCE_LOADSTRING = 'loadstring(game:HttpGet("https://gist.githubusercontent.com/YOUR_USERNAME/RAW_ID/raw/Performance.lua"))()'

-- ========== H BUTTON ==========
local gui = Instance.new("ScreenGui")
gui.ResetOnSpawn = false
gui.Name = "TSB_AntiLag"
gui.Parent = playerGui

local hButton = Instance.new("TextButton")
hButton.Size = UDim2.new(0, 40, 0, 40)
hButton.Position = UDim2.new(0, 8, 0, 95)
hButton.BackgroundColor3 = Color3.fromRGB(255, 85, 0)
hButton.Text = "H"
hButton.TextColor3 = Color3.fromRGB(255, 255, 255)
hButton.TextSize = 22
hButton.Font = Enum.Font.GothamBold
hButton.Parent = gui

local hCorner = Instance.new("UICorner")
hCorner.CornerRadius = UDim.new(1, 0)
hCorner.Parent = hButton

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 280, 0, 180)
frame.Position = UDim2.new(0.5, -140, 0.5, -90)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BackgroundTransparency = 0.15
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.fromRGB(0, 255, 100)
frame.Visible = false
frame.Parent = gui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 12)
frameCorner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
title.BackgroundTransparency = 0.2
title.Text = "⚡ TSB Anti-Lag v12.15 ⚡"
title.TextColor3 = Color3.fromRGB(0, 0, 0)
title.TextSize = 14
title.Font = Enum.Font.GothamBold
title.Parent = frame

local modeDisplay = Instance.new("TextLabel")
modeDisplay.Size = UDim2.new(1, 0, 0, 25)
modeDisplay.Position = UDim2.new(0, 0, 0, 42)
modeDisplay.BackgroundTransparency = 1
modeDisplay.Text = "📌 CURRENT: HIGH QUALITY"
modeDisplay.TextColor3 = Color3.fromRGB(0, 255, 100)
modeDisplay.TextSize = 11
modeDisplay.Font = Enum.Font.GothamBold
modeDisplay.Parent = frame

local btnBalanced = Instance.new("TextButton")
btnBalanced.Size = UDim2.new(0.85, 0, 0, 35)
btnBalanced.Position = UDim2.new(0.075, 0, 0, 75)
btnBalanced.BackgroundColor3 = Color3.fromRGB(60, 100, 200)
btnBalanced.Text = "📋 COPY BALANCED"
btnBalanced.TextColor3 = Color3.fromRGB(255, 255, 255)
btnBalanced.TextSize = 12
btnBalanced.Font = Enum.Font.GothamBold
btnBalanced.Parent = frame
local btnCorner1 = Instance.new("UICorner")
btnCorner1.CornerRadius = UDim.new(0, 8)
btnCorner1.Parent = btnBalanced

local btnPerf = Instance.new("TextButton")
btnPerf.Size = UDim2.new(0.85, 0, 0, 35)
btnPerf.Position = UDim2.new(0.075, 0, 0, 120)
btnPerf.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
btnPerf.Text = "🔥 COPY PERFORMANCE"
btnPerf.TextColor3 = Color3.fromRGB(255, 255, 255)
btnPerf.TextSize = 12
btnPerf.Font = Enum.Font.GothamBold
btnPerf.Parent = frame
local btnCorner2 = Instance.new("UICorner")
btnCorner2.CornerRadius = UDim.new(0, 8)
btnCorner2.Parent = btnPerf

local panelVisible = false
local function ShowPanel()
    panelVisible = true
    frame.Visible = true
    local tween = TweenService:Create(frame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
        {Position = UDim2.new(0.5, -140, 0.5, -90)})
    tween:Play()
end
local function HidePanel()
    frame.Visible = false
    panelVisible = false
end

hButton.MouseButton1Click:Connect(function()
    if panelVisible then HidePanel() else ShowPanel() end
end)

btnBalanced.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(BALANCED_LOADSTRING)
        task.wait(3)
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end
end)

btnPerf.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(PERFORMANCE_LOADSTRING)
        task.wait(3)
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end
end)

task.spawn(function()
    task.wait(0.5)
    pcall(PreserveCollision)
    pcall(applySky)
end)

print("🌩 TSB Anti-Lag HIGH QUALITY v12.15 - Made by Hixert")