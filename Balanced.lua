-- TSB Anti-Lag v12.15 - BALANCED
print("✅ TSB Anti-Lag v12.15 Loaded - BALANCED")

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")
local UserSettings = game:GetService("UserSettings")
local SoundService = game:GetService("SoundService")
local LocalPlayer = Players.LocalPlayer
local playerGui = LocalPlayer:WaitForChild("PlayerGui")

local GRAY_ASSET = "rbxassetid://106578051"
local function applyGraySky()
    pcall(function()
        for _, child in ipairs(Lighting:GetChildren()) do
            if child:IsA("Sky") or child:IsA("Atmosphere") then child:Destroy() end
        end
        local graySky = Instance.new("Sky")
        graySky.Name = "FFlagGraySky_Client"
        graySky.SkyboxBk = GRAY_ASSET
        graySky.SkyboxDn = GRAY_ASSET
        graySky.SkyboxFt = GRAY_ASSET
        graySky.SkyboxLf = GRAY_ASSET
        graySky.SkyboxRt = GRAY_ASSET
        graySky.SkyboxUp = GRAY_ASSET
        graySky.SunTextureId = ""
        graySky.MoonTextureId = ""
        graySky.StarCount = 0
        graySky.CelestialBodiesShown = false
        graySky.Parent = Lighting
        Lighting.FogEnd = 100000
        Lighting.FogStart = 100000
    end)
end
applyGraySky()

local adaptationLevel = 0
local adaptFPSHistory = {}
local currentFPS = 60
local function SmartAdaptation()
    table.insert(adaptFPSHistory, currentFPS)
    if #adaptFPSHistory > 10 then table.remove(adaptFPSHistory, 1) end
    local sum = 0
    for _, v in ipairs(adaptFPSHistory) do sum = sum + v end
    local avgFPS = sum / #adaptFPSHistory
    if avgFPS < 30 then adaptationLevel = 2
    elseif avgFPS < 45 then adaptationLevel = 1
    else adaptationLevel = 0 end
    if adaptationLevel == 2 then
        pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01; settings().Graphics.QualityLevel = Enum.QualityLevel.Level01 end)
    elseif adaptationLevel == 1 then
        pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level02; settings().Graphics.QualityLevel = Enum.QualityLevel.Level02 end)
    else
        pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level02; settings().Graphics.QualityLevel = Enum.QualityLevel.Level02 end)
    end
end
task.spawn(function() while task.wait(1) do pcall(SmartAdaptation) end end)

local function AdaptivePurge(obj)
    if not obj then return
    local name = obj.Name:lower()
    if name:find("hitbox") or name:find("hurtbox") or name:find("m1") then return
    if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
        pcall(function() obj:Destroy() end)
    elseif obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
        pcall(function() obj:Destroy() end)
    elseif obj:IsA("Decal") or obj:IsA("Texture") then
        pcall(function() obj:Destroy() end)
    end
end
Workspace.DescendantAdded:Connect(function(obj) task.spawn(AdaptivePurge, obj) end)

local function MakeHeadless(character)
    if not character then return
    for _, v in pairs(character:GetDescendants()) do
        if v:IsA("BasePart") and v.Name == "Head" then v.Transparency = 1 end
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
if LocalPlayer.Character then MakeHeadless(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(function(character) task.wait(0.5); pcall(function() MakeHeadless(character) end) end)

local pendingDebris = {}
local function MarkDebrisForPurge(obj)
    if not obj then return
    local name = obj.Name:lower()
    if name:find("hitbox") or name:find("hurtbox") or name:find("m1") then return
    if obj:IsA("BasePart") and (name:find("debris") or name:find("grass") or name:find("rock") or 
       name:find("stone") or name:find("pebble") or name:find("rubble")) then
        pendingDebris[obj] = true
    end
end
local function PurgeDebris()
    for obj, _ in pairs(pendingDebris) do
        if obj and obj.Parent then pcall(function() obj:Destroy() end) end
        pendingDebris[obj] = nil
    end
end
task.spawn(function() while task.wait(1) do pcall(PurgeDebris) end end)
Workspace.DescendantAdded:Connect(function(obj) task.spawn(MarkDebrisForPurge, obj) end)

local function LockGraphicsSettings()
    pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level02; settings().Graphics.QualityLevel = Enum.QualityLevel.Level02 end)
end
LockGraphicsSettings()
task.spawn(function() while task.wait(1) do pcall(LockGraphicsSettings) end end)

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

local thermalState = "NORMAL"
local lastFPSCheck = os.clock()
local thermalFPSDrop = 0
local function CheckThermal()
    local now = os.clock()
    if now - lastFPSCheck >= 8 then
        lastFPSCheck = now
        if currentFPS < 22 then
            thermalState = "HOT"
            thermalFPSDrop = 10
        elseif currentFPS < 32 then
            thermalState = "WARM"
            thermalFPSDrop = 5
        else
            thermalState = "NORMAL"
            thermalFPSDrop = 0
        end
    end
end

local frameHistory = {}
local lastFrameTime = os.clock()
local smoothedDelta = 1/60
RunService.RenderStepped:Connect(function(deltaTime)
    if deltaTime < 0.005 or deltaTime > 0.05 then return
    currentFPS = math.floor(1 / deltaTime)
    CheckThermal()
    SmartAdaptation()
    local targetDelta = 1/(60 - thermalFPSDrop)
    table.insert(frameHistory, deltaTime)
    if #frameHistory > 10 then table.remove(frameHistory, 1) end
    local weightedSum, weightTotal = 0, 0
    for i, t in ipairs(frameHistory) do
        local weight = i / #frameHistory
        weightedSum = weightedSum + (t * weight)
        weightTotal = weightTotal + weight
    end
    local avgDelta = weightedSum / weightTotal
    smoothedDelta = (smoothedDelta * 0.6) + (avgDelta * 0.4)
    smoothedDelta = math.clamp(smoothedDelta, 0.012, targetDelta)
    local now = os.clock()
    local elapsed = now - lastFrameTime
    if elapsed < smoothedDelta then task.wait(smoothedDelta - elapsed) end
    lastFrameTime = os.clock()
end)

pcall(function() SoundService.AmbientReverb = Enum.ReverbType.NoReverb; SoundService.Volume = 0.3 end)

-- MONITOR
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
monitorFrame.BorderColor3 = Color3.fromRGB(255, 170, 0)
monitorFrame.Parent = monitorGui
local monitorCorner = Instance.new("UICorner")
monitorCorner.CornerRadius = UDim.new(0, 5)
monitorCorner.Parent = monitorFrame
local titleBar = Instance.new("TextLabel")
titleBar.Size = UDim2.new(1, 0, 0, 13)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
titleBar.BackgroundTransparency = 0.2
titleBar.Text = "BALANCED"
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
local adaptLabel = Instance.new("TextLabel")
adaptLabel.Size = UDim2.new(0.5, 0, 0, 10)
adaptLabel.Position = UDim2.new(0, 0, 0, 45)
adaptLabel.BackgroundTransparency = 1
adaptLabel.Text = "ADAPT:NORM"
adaptLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
adaptLabel.TextSize = 6
adaptLabel.Font = Enum.Font.GothamBold
adaptLabel.TextXAlignment = Enum.TextXAlignment.Left
adaptLabel.Parent = monitorFrame
local thermalLabel = Instance.new("TextLabel")
thermalLabel.Size = UDim2.new(0.5, 0, 0, 10)
thermalLabel.Position = UDim2.new(0.5, 0, 0, 45)
thermalLabel.BackgroundTransparency = 1
thermalLabel.Text = "🌡️ NORM"
thermalLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
thermalLabel.TextSize = 6
thermalLabel.Font = Enum.Font.GothamBold
thermalLabel.TextXAlignment = Enum.TextXAlignment.Right
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
        if adaptationLevel == 2 then
            adaptLabel.Text = "ADAPT:MAX"
            adaptLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        elseif adaptationLevel == 1 then
            adaptLabel.Text = "ADAPT:MED"
            adaptLabel.TextColor3 = Color3.fromRGB(255, 170, 0)
        else
            adaptLabel.Text = "ADAPT:NORM"
            adaptLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
        end
        if thermalState == "HOT" then
            thermalLabel.Text = "🌡️ HOT"
            thermalLabel.TextColor3 = Color3.fromRGB(255, 170, 0)
        elseif thermalState == "WARM" then
            thermalLabel.Text = "🌡️ WARM"
            thermalLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
        else
            thermalLabel.Text = "🌡️ NORM"
            thermalLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
        end
        fpsCounter = 0
        lastUpdate = now
    end
end)

-- H BUTTON
local gui = Instance.new("ScreenGui")
gui.ResetOnSpawn = false
gui.Name = "TSB_AntiLag"
gui.Parent = playerGui
local hButton = Instance.new("TextButton")
hButton.Size = UDim2.new(0, 40, 0, 40)
hButton.Position = UDim2.new(0, 8, 0, 95)
hButton.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
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
frame.BorderColor3 = Color3.fromRGB(255, 170, 0)
frame.Visible = false
frame.Parent = gui
local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 12)
frameCorner.Parent = frame
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
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
modeDisplay.Text = "📌 CURRENT: BALANCED"
modeDisplay.TextColor3 = Color3.fromRGB(255, 170, 0)
modeDisplay.TextSize = 11
modeDisplay.Font = Enum.Font.GothamBold
modeDisplay.Parent = frame
local btnHQ = Instance.new("TextButton")
btnHQ.Size = UDim2.new(0.85, 0, 0, 35)
btnHQ.Position = UDim2.new(0.075, 0, 0, 75)
btnHQ.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
btnHQ.Text = "🎨 COPY HIGH QUALITY"
btnHQ.TextColor3 = Color3.fromRGB(255, 255, 255)
btnHQ.TextSize = 12
btnHQ.Font = Enum.Font.GothamBold
btnHQ.Parent = frame
local btnCorner1 = Instance.new("UICorner")
btnCorner1.CornerRadius = UDim.new(0, 8)
btnCorner1.Parent = btnHQ
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

-- REAL LOADSTRINGS
local HIGHQUALITY_LOADSTRING = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/Hixert-Scripts/HighQuality.lua/main/HighQuality.lua"))()'
local PERFORMANCE_LOADSTRING = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/Hixert-Scripts/HighQuality.lua/main/Performance.lua"))()'

btnHQ.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(HIGHQUALITY_LOADSTRING)
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
    task.wait(1)
    pcall(PreserveCollision)
    pcall(applyGraySky)
end)

print("🌩 TSB Anti-Lag BALANCED v12.15 - Made by Hixert")