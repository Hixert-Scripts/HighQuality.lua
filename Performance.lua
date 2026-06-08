-- Fixes v12.14 - Performance: Maximum Elimination + Korblox + Crater Annihilator
local function ShowNotif(msg, color)
    pcall(function()
        local player = game.Players.LocalPlayer
        if not player then return end
        local playerGui = player:FindFirstChild("PlayerGui")
        if not playerGui then
            playerGui = player:WaitForChild("PlayerGui", 5)
        end
        if not playerGui then return end
        
        local existingGui = playerGui:FindFirstChild("TSB_Notif")
        if existingGui then existingGui:Destroy() end
        
        local gui = Instance.new("ScreenGui")
        gui.ResetOnSpawn = false
        gui.Name = "TSB_Notif"
        gui.Parent = playerGui
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0, 320, 0, 40)
        label.Position = UDim2.new(0.5, -160, 0.85, 0)
        label.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        label.BackgroundTransparency = 0.25
        label.Text = msg
        label.TextColor3 = color or Color3.fromRGB(255, 255, 255)
        label.TextSize = 12
        label.Font = Enum.Font.GothamBold
        label.Parent = gui
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 10)
        corner.Parent = label
        
        task.wait(2.5)
        gui:Destroy()
    end)
end

ShowNotif("✅ TSB Anti-Lag v12.15 Loaded - PERFORMANCE", Color3.fromRGB(255, 50, 50))

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

-- ========== DARK GRAY SKY ==========
local GRAY_ASSET = "rbxassetid://106578051"
local function applyPerformanceSky()
    pcall(function()
        for _, child in ipairs(Lighting:GetChildren()) do
            if child:IsA("Sky") or child:IsA("Atmosphere") then
                child:Destroy()
            end
        end
        
        local workspaceClouds = workspace:FindFirstChildOfClass("Clouds")
        if workspaceClouds then
            workspaceClouds:Destroy()
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
        
        Lighting.Ambient = Color3.fromRGB(30, 30, 30)
        Lighting.OutdoorAmbient = Color3.fromRGB(30, 30, 30)
        Lighting.FogEnd = 100000
        Lighting.FogStart = 100000
    end)
end
applyPerformanceSky()

Lighting.ChildAdded:Connect(function(child)
    if (child:IsA("Sky") and child.Name ~= "FFlagGraySky_Client") or child:IsA("Atmosphere") or child:IsA("Clouds") then
        task.defer(function() applyPerformanceSky() end)
    end
end)
workspace.ChildAdded:Connect(function(child)
    if child:IsA("Clouds") then
        task.defer(function() child:Destroy() end)
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.3)
    pcall(applyPerformanceSky)
end)

-- ========== SPOTLIGHT: MAXIMUM ELIMINATION ==========
local function MaximumElimination()
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        settings().Graphics.QualityLevel = Enum.QualityLevel.Level01
        if UserSettings:GetSetting("RenderQuality") then
            UserSettings:GetSetting("RenderQuality").Value = 0
        end
        if UserSettings:GetSetting("TextureQuality") then
            UserSettings:GetSetting("TextureQuality").Value = 0
        end
        if UserSettings:GetSetting("ShadowQuality") then
            UserSettings:GetSetting("ShadowQuality").Value = 0
        end
    end)
    Lighting.GlobalShadows = false
    Lighting.Brightness = 1.0
    Lighting.ClockTime = 12
end
MaximumElimination()
task.spawn(function()
    while task.wait(2) do
        pcall(MaximumElimination)
        pcall(applyPerformanceSky)
    end
end)

-- ========== 1ST ABILITY: CRATER ANNIHILATOR ==========
local craterKeywords = {
    "crater", "chunk", "rubble", "fragment", "shatter", "crack",
    "groundbreak", "impact", "broken", "ruin", "smash", "punch",
    "shockwave", "blast", "explosion", "hole", "dirt", "clod"
}
local function CraterAnnihilator(obj)
    if not obj then return
    local name = obj.Name:lower()
    if name:find("hitbox") or name:find("hurtbox") or name:find("m1") then
        return
    end
    if name:find("floor") or name:find("ground") or name:find("terrain") then
        return
    end
    for _, keyword in ipairs(craterKeywords) do
        if string.find(name, keyword) then
            pcall(function() obj:Destroy() end)
            return
        end
    end
end
Workspace.DescendantAdded:Connect(function(obj)
    task.spawn(CraterAnnihilator, obj)
end)

-- ========== 2ND ABILITY: KORBLOX + HEADLESS ==========
local function ApplyKorblox(character)
    if not character then return
    for _, v in pairs(character:GetDescendants()) do
        if v:IsA("BasePart") and v.Name == "Right Leg" then
            v:Destroy()
        end
        if v:IsA("BasePart") and v.Name == "Head" then
            v.Transparency = 1
        end
        if v:IsA("BasePart") and v.Parent and v.Parent:IsA("Accessory") then
            local attachment = v:FindFirstChildOfClass("Attachment")
            if attachment and string.find(attachment.Name or "", "Shoulder") then
                v.Transparency = 0
            else
                v.Transparency = 1
            end
        end
        if v:IsA("Decal") and v.Name == "face" then
            v.Transparency = 1
        end
    end
end

if LocalPlayer.Character then
    ApplyKorblox(LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:Connect(function(character)
    task.wait(0.5)
    pcall(function() ApplyKorblox(character) end)
end)

-- Apply to other players
local function SetupPlayer(player)
    if player == LocalPlayer then return
    player.CharacterAdded:Connect(function(character)
        task.wait(0.5)
        pcall(function() ApplyKorblox(character) end)
    end)
    if player.Character then
        pcall(function() ApplyKorblox(player.Character) end)
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    SetupPlayer(player)
end
Players.PlayerAdded:Connect(SetupPlayer)

-- ========== DESTROY ALL LAG ==========
local function DestroyAllLag(obj)
    if not obj then return
    local name = obj.Name:lower()
    if name:find("hitbox") or name:find("hurtbox") or name:find("m1") then
        return
    end
    if name:find("floor") or name:find("ground") or name:find("terrain") or 
       name:find("platform") or name:find("baseplate") then
        return
    end
    
    if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
        pcall(function() obj:Destroy() end)
    elseif obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
        pcall(function() obj:Destroy() end)
    elseif obj:IsA("Decal") or obj:IsA("Texture") then
        if not name:find("face") then
            pcall(function() obj:Destroy() end)
        end
    elseif obj:IsA("BasePart") and (name:find("debris") or name:find("grass") or name:find("rock") or 
       name:find("stone") or name:find("pebble") or name:find("rubble") or
       name:find("crate") or name:find("barrel") or name:find("leaf")) then
        pcall(function() obj:Destroy() end)
    elseif obj:IsA("PointLight") or obj:IsA("SpotLight") then
        pcall(function() obj:Destroy() end)
    end
end
Workspace.DescendantAdded:Connect(function(obj)
    task.spawn(DestroyAllLag, obj)
end)

-- ========== PRESERVE FLOOR COLLISION ==========
local function PreserveFloorCollision()
    pcall(function()
        for _, part in ipairs(Workspace:GetDescendants()) do
            if part:IsA("BasePart") then
                local name = part.Name:lower()
                if name:find("floor") or name:find("ground") or name:find("terrain") or 
                   name:find("platform") or name:find("baseplate") or part:IsA("Terrain") then
                    part.CanCollide = true
                    part.CanTouch = true
                    part.Transparency = 0
                end
            end
        end
    end)
end
task.spawn(function()
    while task.wait(5) do
        pcall(PreserveFloorCollision)
    end
end)

-- ========== THERMAL DETECTION ==========
local thermalState = "NORMAL"
local lastFPSCheck = os.clock()
local currentFPS = 60
local thermalFPSDrop = 0

local function CheckThermal()
    local now = os.clock()
    if now - lastFPSCheck >= 5 then
        lastFPSCheck = now
        if currentFPS < 20 then
            thermalState = "CRITICAL"
            thermalFPSDrop = 20
        elseif currentFPS < 28 then
            thermalState = "HOT"
            thermalFPSDrop = 15
        elseif currentFPS < 38 then
            thermalState = "WARM"
            thermalFPSDrop = 8
        else
            thermalState = "NORMAL"
            thermalFPSDrop = 0
        end
        
        if thermalState == "CRITICAL" then
            pcall(function()
                SoundService.Volume = 0.05
            end)
        elseif thermalState == "HOT" then
            pcall(function()
                SoundService.Volume = 0.08
            end)
        end
    end
end

-- ========== EXTREME FRAME PACING ==========
local frameHistory = {}
local historySize = 15
local lastFrameTime = os.clock()
local smoothedDelta = 1/60
local frameVariance = 0

RunService.RenderStepped:Connect(function(deltaTime)
    if deltaTime < 0.005 or deltaTime > 0.05 then return
    currentFPS = math.floor(1 / deltaTime)
    CheckThermal()
    
    local targetFPS = math.max(20, 60 - thermalFPSDrop)
    local targetFrameTime = 1 / targetFPS
    
    table.insert(frameHistory, deltaTime)
    if #frameHistory > historySize then
        table.remove(frameHistory, 1)
    end
    
    local sum = 0
    for _, t in ipairs(frameHistory) do
        sum = sum + t
    end
    local mean = sum / #frameHistory
    
    local varianceSum = 0
    for _, t in ipairs(frameHistory) do
        varianceSum = varianceSum + (t - mean) ^ 2
    end
    frameVariance = varianceSum / #frameHistory
    
    local weightedSum, weightTotal = 0, 0
    for i, t in ipairs(frameHistory) do
        local weight = (i / #frameHistory) ^ 2
        weightedSum = weightedSum + (t * weight)
        weightTotal = weightTotal + weight
    end
    local avgDelta = weightedSum / weightTotal
    
    local smoothStrength = math.clamp(1 - (frameVariance * 30), 0.3, 0.7)
    smoothedDelta = (smoothedDelta * smoothStrength) + (avgDelta * (1 - smoothStrength))
    smoothedDelta = math.clamp(smoothedDelta, 0.016, targetFrameTime)
    
    local now = os.clock()
    local elapsed = now - lastFrameTime
    
    if elapsed < smoothedDelta then
        task.wait(smoothedDelta - elapsed)
    end
    
    lastFrameTime = os.clock()
end)

-- ========== SOUND ==========
pcall(function()
    SoundService.AmbientReverb = Enum.ReverbType.NoReverb
    SoundService.Volume = 0.08
    SoundService.DistanceFactor = 12
end)

-- ========== MEMORY MANAGEMENT ==========
task.spawn(function()
    while task.wait(10) do
        collectgarbage("collect")
        if Stats:GetTotalMemoryUsageMb() > 2000 then
            collectgarbage("collect")
            collectgarbage("collect")
        end
    end
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
monitorFrame.BorderColor3 = Color3.fromRGB(255, 50, 50)
monitorFrame.Parent = monitorGui

local monitorCorner = Instance.new("UICorner")
monitorCorner.CornerRadius = UDim.new(0, 5)
monitorCorner.Parent = monitorFrame

local titleBar = Instance.new("TextLabel")
titleBar.Size = UDim2.new(1, 0, 0, 13)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
titleBar.BackgroundTransparency = 0.2
titleBar.Text = "PERFORMANCE"
titleBar.TextColor3 = Color3.fromRGB(255, 255, 255)
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

-- ========== FPS COUNTER ==========
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
        
        if thermalState == "CRITICAL" then
            thermalLabel.Text = "🌡️ CRITICAL!"
            thermalLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        elseif thermalState == "HOT" then
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

-- ========== REAL LOADSTRINGS ==========
local HIGHQUALITY_LOADSTRING = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/Hixert-Scripts/HighQuality.lua/main/HighQuality.lua"))()'
local BALANCED_LOADSTRING = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/Hixert-Scripts/HighQuality.lua/main/Balanced.lua"))()'

-- ========== H BUTTON AND GUI ==========
local gui = Instance.new("ScreenGui")
gui.ResetOnSpawn = false
gui.Name = "TSB_AntiLag"
gui.Parent = playerGui

local hButton = Instance.new("TextButton")
hButton.Size = UDim2.new(0, 40, 0, 40)
hButton.Position = UDim2.new(0, 8, 0, 95)
hButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
hButton.Text = "H"
hButton.TextColor3 = Color3.fromRGB(255, 255, 255)
hButton.TextSize = 22
hButton.Font = Enum.Font.GothamBold
hButton.Parent = gui

local hCorner = Instance.new("UICorner")
hCorner.CornerRadius = UDim.new(1, 0)
hCorner.Parent = hButton

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 280, 0, 200)
frame.Position = UDim2.new(0.5, -140, 0.5, -100)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BackgroundTransparency = 0.15
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.fromRGB(255, 50, 50)
frame.Visible = false
frame.Parent = gui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 12)
frameCorner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
title.BackgroundTransparency = 0.2
title.Text = "⚡ TSB Anti-Lag v12.15 ⚡"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 14
title.Font = Enum.Font.GothamBold
title.Parent = frame

local modeDisplay = Instance.new("TextLabel")
modeDisplay.Size = UDim2.new(1, 0, 0, 25)
modeDisplay.Position = UDim2.new(0, 0, 0, 42)
modeDisplay.BackgroundTransparency = 1
modeDisplay.Text = "📌 CURRENT: PERFORMANCE"
modeDisplay.TextColor3 = Color3.fromRGB(255, 50, 50)
modeDisplay.TextSize = 11
modeDisplay.Font = Enum.Font.GothamBold
modeDisplay.Parent = frame

local instruction = Instance.new("TextLabel")
instruction.Size = UDim2.new(1, -20, 0, 20)
instruction.Position = UDim2.new(0, 10, 0, 70)
instruction.BackgroundTransparency = 1
instruction.Text = "👇 COPY LOADSTRING:"
instruction.TextColor3 = Color3.fromRGB(200, 200, 200)
instruction.TextSize = 10
instruction.Font = Enum.Font.GothamBold
instruction.Parent = frame

local btnHQ = Instance.new("TextButton")
btnHQ.Size = UDim2.new(0.85, 0, 0, 35)
btnHQ.Position = UDim2.new(0.075, 0, 0, 95)
btnHQ.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
btnHQ.Text = "🎨 COPY HIGH QUALITY"
btnHQ.TextColor3 = Color3.fromRGB(255, 255, 255)
btnHQ.TextSize = 12
btnHQ.Font = Enum.Font.GothamBold
btnHQ.Parent = frame

local btnCorner1 = Instance.new("UICorner")
btnCorner1.CornerRadius = UDim.new(0, 8)
btnCorner1.Parent = btnHQ

local btnBalanced = Instance.new("TextButton")
btnBalanced.Size = UDim2.new(0.85, 0, 0, 35)
btnBalanced.Position = UDim2.new(0.075, 0, 0, 140)
btnBalanced.BackgroundColor3 = Color3.fromRGB(60, 100, 200)
btnBalanced.Text = "📋 COPY BALANCED"
btnBalanced.TextColor3 = Color3.fromRGB(255, 255, 255)
btnBalanced.TextSize = 12
btnBalanced.Font = Enum.Font.GothamBold
btnBalanced.Parent = frame

local btnCorner2 = Instance.new("UICorner")
btnCorner2.CornerRadius = UDim.new(0, 8)
btnCorner2.Parent = btnBalanced

local panelVisible = false
local function ShowPanel()
    panelVisible = true
    frame.Visible = true
    local tween = TweenService:Create(frame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
        {Position = UDim2.new(0.5, -140, 0.5, -100)})
    tween:Play()
end
local function HidePanel()
    frame.Visible = false
    panelVisible = false
end

hButton.MouseButton1Click:Connect(function()
    if panelVisible then HidePanel() else ShowPanel() end
end)

btnHQ.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(HIGHQUALITY_LOADSTRING)
        task.wait(3)
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end
end)

btnBalanced.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(BALANCED_LOADSTRING)
        task.wait(3)
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end
end)

task.spawn(function()
    task.wait(0.5)
    pcall(PreserveFloorCollision)
    pcall(applyPerformanceSky)
    collectgarbage("collect")
end)

print("🌩 TSB Anti-Lag PERFORMANCE v12.15 - Made by Hixert")