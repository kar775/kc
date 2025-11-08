-- Kar775 Cheats X v5.0
-- by kar775_6, ChatGPT(AI) and Grok(AI)
-- Features: AimSystem (Aimbot/Trigger/Silent), Binds (single & combos like G+T),
-- Waypoints per-place with automatic migration, Visuals (target highlight + transparency),
-- Theme switch (Dark/Light), soft fade notifications, sound with volume 0..1 default 0.5,
-- custom logo "Kar775X" green text.

-- ===== Load Rayfield safely =====
local ok, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)
if not ok or not Rayfield then
    error("Rayfield failed to load. Make sure executor supports http and URL.")
end

-- ===== Services =====
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

-- ===== Persistence filenames (per-place WP) and migration =====
local PLACE_ID = tostring(game.PlaceId or 0)
local WP_FILE = "Kar775_Waypoints_" .. PLACE_ID .. ".json"
local OLD_WP_FILE = "AggressiveHub_Waypoints.json"
local CFG_FILE = "Kar775_Config.json" -- global config

local function safeWriteFile(name, content)
    if writefile then
        local ok, e = pcall(writefile, name, content)
        return ok
    end
    return false
end
local function safeReadFile(name)
    if readfile then
        local ok, data = pcall(readfile, name)
        if ok then return data end
    end
    return nil
end

-- ===== Global state =====
getgenv().Kar775 = getgenv().Kar775 or {}
local K = getgenv().Kar775

-- defaults
K.Theme = K.Theme or "Dark" -- "Dark" or "Light"
K.Language = K.Language or "RU"
K.BindSoundId = K.BindSoundId or "rbxassetid://138081500"
K.BindSoundVolume = K.BindSoundVolume or 0.5 -- 0..1

-- Aim system defaults
K.Aim = K.Aim or {}
K.Aim.Aimbot = K.Aim.Aimbot or false
K.Aim.Trigger = K.Aim.Trigger or false
K.Aim.Silent = K.Aim.Silent or false
K.Aim.Range = K.Aim.Range or 80
K.Aim.FOV = K.Aim.FOV or 60
K.Aim.Smooth = K.Aim.Smooth or 10 -- 1 means immediate follow
K.Aim.Priority = K.Aim.Priority or "Nearest"
K.Aim.IgnoreWalls = K.Aim.IgnoreWalls or false

-- Movement / misc
K.SpeedHack = K.SpeedHack or false
K.WalkSpeed = K.WalkSpeed or 100
K.DefaultWalkSpeed = K.DefaultWalkSpeed or 16
K.Fly = K.Fly or false
K.FlySpeed = K.FlySpeed or 50
K.InfiniteJump = K.InfiniteJump or false
K.Noclip = K.Noclip or false
K.Spin = K.Spin or false
K.SpinSpeed = K.SpinSpeed or 10

-- Visuals
K.ESP = K.ESP or true
K.ESPColor = K.ESPColor or Color3.fromRGB(0,255,0)
K.ESPTransparency = K.ESPTransparency or 0.5 -- 0..1
K.AimGlowColor = K.AimGlowColor or Color3.fromRGB(0,255,0)
K.AimGlowTransparency = K.AimGlowTransparency or 0.3

-- Third person
K.ThirdPerson = K.ThirdPerson or false
K.ThirdPersonDist = K.ThirdPersonDist or 6

-- Teleport
K.TeleportOffset = K.TeleportOffset or 3

-- Waypoints per place
K.Waypoints = K.Waypoints or {} -- will be loaded from per-place WP_FILE

-- Binds stored as strings like "G" or "G+T"
K.Binds = K.Binds or {}
-- defaults example:
K.Binds.TPNearest = K.Binds.TPNearest or "P"
K.Binds.TPPlayer = K.Binds.TPPlayer or "L"
K.Binds.TPToWP = K.Binds.TPToWP or "k"
K.Binds.CreateWP = K.Binds.CreateWP or "m"
K.Binds.Aimbot = K.Binds.Aimbot or "x"
K.Binds.Trigger = K.Binds.Trigger or ""
K.Binds.Silent = K.Binds.Silent or ""
K.Binds.ToggleESP = K.Binds.ToggleESP or ""
K.Binds.ToggleSpeed = K.Binds.ToggleSpeed or "z"
K.Binds.ToggleNoclip = K.Binds.ToggleNoclip or "n"
K.Binds.ToggleGUI = K.Binds.ToggleGUI or ""

-- ===== Migration of old WP file (silent) =====
do
    local oldTxt = safeReadFile(OLD_WP_FILE)
    local newTxt = safeReadFile(WP_FILE)
    if oldTxt and (not newTxt) then
        local ok, dec = pcall(function() return HttpService:JSONDecode(oldTxt) end)
        if ok and type(dec) == "table" then
            -- migrate
            K.Waypoints = dec
            pcall(function() safeWriteFile(WP_FILE, HttpService:JSONEncode(K.Waypoints)) end)
        end
    else
        -- load per-place if exists
        if newTxt then
            local ok2, dec2 = pcall(function() return HttpService:JSONDecode(newTxt) end)
            if ok2 and type(dec2) == "table" then K.Waypoints = dec2 end
        end
    end
end

local function saveWaypoints()
    pcall(function() safeWriteFile(WP_FILE, HttpService:JSONEncode(K.Waypoints)) end)
end

local function saveConfig()
    local small = {
        Theme = K.Theme, Language = K.Language, BindSoundId = K.BindSoundId, BindSoundVolume = K.BindSoundVolume,
        Aim = K.Aim, SpeedHack = K.SpeedHack, WalkSpeed = K.WalkSpeed, DefaultWalkSpeed = K.DefaultWalkSpeed,
        Fly = K.Fly, FlySpeed = K.FlySpeed, InfiniteJump = K.InfiniteJump, Noclip = K.Noclip,
        ESP = K.ESP, ESPColor = K.ESPColor, ESPTransparency = K.ESPTransparency,
        ThirdPerson = K.ThirdPerson, ThirdPersonDist = K.ThirdPersonDist,
        TeleportOffset = K.TeleportOffset, Binds = K.Binds
    }
    pcall(function() safeWriteFile(CFG_FILE, HttpService:JSONEncode(small)) end)
end

-- ===== Waypoints visual markers =====
local WPFolder = Workspace:FindFirstChild("Kar775_Waypoints")
if WPFolder then WPFolder:Destroy() end
WPFolder = Instance.new("Folder", Workspace); WPFolder.Name = "Kar775_Waypoints"
local markers = {}

local function createMarker(name, pos, color)
    if markers[name] then if markers[name].Part and markers[name].Part.Parent then markers[name].Part:Destroy() end markers[name] = nil end
    local part = Instance.new("Part")
    part.Name = "WP_"..name
    part.Size = Vector3.new(1.2,1.2,1.2)
    part.Shape = Enum.PartType.Ball
    part.Anchored = true
    part.CanCollide = false
    part.Position = pos
    part.Transparency = 0.3
    part.Parent = WPFolder
    part.Color = Color3.new(color[1], color[2], color[3])
    local mesh = Instance.new("SpecialMesh", part); mesh.Scale = Vector3.new(1.2,1.2,1.2)
    local gui = Instance.new("BillboardGui", part); gui.Size = UDim2.new(0,160,0,28); gui.AlwaysOnTop = true; gui.StudsOffset = Vector3.new(0,2,0)
    local label = Instance.new("TextLabel", gui); label.BackgroundTransparency = 1; label.Size = UDim2.fromScale(1,1); label.Text = "WP: "..name; label.TextScaled = true; label.TextColor3 = Color3.new(1,1,1); label.Font = Enum.Font.SourceSansBold
    markers[name] = {Part = part, Gui = gui}
end

local function removeMarker(name)
    if markers[name] then if markers[name].Part and markers[name].Part.Parent then markers[name].Part:Destroy() end markers[name] = nil end
end

local function rebuildMarkers()
    for k,_ in pairs(markers) do removeMarker(k) end
    for name, info in pairs(K.Waypoints) do
        createMarker(name, Vector3.new(info.x, info.y, info.z), info.color or {0,1,0})
    end
end
rebuildMarkers()

-- ===== Utilities =====
local function getCharacter() return LocalPlayer and LocalPlayer.Character end
local function getNearestEnemy()
    local char = getCharacter()
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil, math.huge end
    local myPos = char.HumanoidRootPart.Position
    local nearest, dist = nil, math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            local d = (myPos - p.Character.HumanoidRootPart.Position).Magnitude
            if d < dist then nearest = p; dist = d end
        end
    end
    return nearest, dist
end

local function isVisible(pos)
    if K.Aim.IgnoreWalls then return true end
    local cam = Workspace.CurrentCamera
    if not cam then return true end
    local origin = cam.CFrame.Position
    local rp = RaycastParams.new(); rp.FilterDescendantsInstances = {getCharacter()}; rp.FilterType = Enum.RaycastFilterType.Blacklist
    local res = Workspace:Raycast(origin, (pos - origin), rp)
    if not res then return true end
    return (res.Position - pos).Magnitude < 2
end

-- ===== ESP management =====
local function createESPFor(p)
    if not p or p == LocalPlayer then return end
    if not p.Character then return end
    if p.Character:FindFirstChild("Kar_Highlight") then return end
    local h = Instance.new("Highlight"); h.Name = "Kar_Highlight"; h.Parent = p.Character; h.Adornee = p.Character
    h.FillColor = K.ESPColor; h.FillTransparency = K.ESPTransparency; h.OutlineColor = Color3.new(0,0,0); h.OutlineTransparency = 0.5
end
local function clearESPFrom(p)
    if not p or not p.Character then return end
    for _,c in pairs(p.Character:GetChildren()) do if c:IsA("Highlight") and c.Name=="Kar_Highlight" then c:Destroy() end end
end

RunService.Heartbeat:Connect(function()
    for _, p in pairs(Players:GetPlayers()) do
        if K.ESP and p~=LocalPlayer then createESPFor(p) else clearESPFrom(p) end
    end
end)
Players.PlayerAdded:Connect(function(p) if K.ESP then createESPFor(p) end end)
Players.PlayerRemoving:Connect(function(p) clearESPFrom(p) end)

-- ===== Aim system & target glow =====
local aimAttach = nil
local currentTarget = nil
local function addTargetGlow(p)
    if aimAttach and aimAttach.Parent then pcall(function() aimAttach:Destroy() end) end
    if not p or not p.Character or not p.Character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = p.Character.HumanoidRootPart
    local att = Instance.new("Attachment", hrp); att.Name = "Kar_AimAttach"
    local pe = Instance.new("ParticleEmitter", att)
    pe.LightEmission = 0.8; pe.Rate = 30; pe.Lifetime = NumberRange.new(0.2,0.5); pe.Speed = NumberRange.new(0.1,0.3)
    pe.Size = NumberSequence.new({NumberSequenceKeypoint.new(0,0.6), NumberSequenceKeypoint.new(1,0)})
    pe.Color = ColorSequence.new(K.AimGlowColor or Color3.fromRGB(0,255,0))
    pe.Transparency = NumberSequence.new(K.AimGlowTransparency or 0.3)
    pe.LockedToPart = true
    aimAttach = att
    currentTarget = p
end
local function clearTargetGlow()
    if aimAttach and aimAttach.Parent then pcall(function() aimAttach:Destroy() end) end
    aimAttach = nil; currentTarget = nil
end

local function angleBetween(v1, v2)
    local a = math.acos(math.clamp((v1.Unit:Dot(v2.Unit)), -1, 1))
    return math.deg(a)
end

local function gatherTargets()
    local list = {}
    local cam = Workspace.CurrentCamera
    if not cam then return list end
    local myPos = getCharacter() and getCharacter():FindFirstChild("HumanoidRootPart") and getCharacter().HumanoidRootPart.Position or Vector3.new()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health>0 then
            local pos = p.Character.HumanoidRootPart.Position
            local dist = (myPos - pos).Magnitude
            if dist <= (K.Aim.Range or 80) then
                local dir = pos - cam.CFrame.Position
                local fov = angleBetween(cam.CFrame.LookVector, dir)
                table.insert(list, {player=p, dist=dist, fov=fov})
            end
        end
    end
    return list
end

local function pickTarget(list)
    if #list==0 then return nil end
    table.sort(list, function(a,b)
        if K.Aim.Priority=="Nearest" then return a.dist<b.dist
        elseif K.Aim.Priority=="LowestHP" then
            local ha = a.player.Character and a.player.Character:FindFirstChild("Humanoid") and a.player.Character.Humanoid.Health or 99999
            local hb = b.player.Character and b.player.Character:FindFirstChild("Humanoid") and b.player.Character.Humanoid.Health or 99999
            return ha < hb
        else return a.fov < b.fov end
    end)
    return list[1].player, list[1].dist, list[1].fov
end

-- Aim loop
RunService.RenderStepped:Connect(function()
    if not LocalPlayer or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then clearTargetGlow(); return end
    if K.Aim.Aimbot or K.Aim.Trigger or K.Aim.Silent then
        local list = gatherTargets()
        if #list==0 then clearTargetGlow(); return end
        local target, dist, fov = pickTarget(list)
        if not target then clearTargetGlow(); return end
        if not isVisible(target.Character.HumanoidRootPart.Position) then clearTargetGlow(); return end

        -- Aimbot camera movement
        if K.Aim.Aimbot then
            local cam = Workspace.CurrentCamera
            if cam then
                local targetPos = target.Character.HumanoidRootPart.Position
                local camPos = cam.CFrame.Position
                local desired = CFrame.new(camPos, targetPos)
                local s = K.Aim.Smooth or 10
                if s <= 1 then
                    -- immediate follow: camera set directly (player will feel)
                    cam.CFrame = desired
                else
                    local factor = math.clamp(1 / s, 0.02, 1)
                    cam.CFrame = cam.CFrame:Lerp(desired, factor)
                end
            end
        end

        -- Silent: rotate root only
        if K.Aim.Silent then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local root = char.HumanoidRootPart
                root.CFrame = CFrame.new(root.Position, Vector3.new(target.Character.HumanoidRootPart.Position.X, root.Position.Y, target.Character.HumanoidRootPart.Position.Z))
            end
        end

        -- Trigger: attempt attack when roughly on target
        if K.Aim.Trigger then
            local cam = Workspace.CurrentCamera
            if cam then
                local dir = target.Character.HumanoidRootPart.Position - cam.CFrame.Position
                local ang = angleBetween(cam.CFrame.LookVector, dir)
                if ang <= (K.Aim.FOV or 60) * 0.45 then
                    pcall(function()
                        if target.Character and target.Character:FindFirstChild("Humanoid") then
                            target.Character.Humanoid.Health = 0
                        end
                    end)
                end
            end
        end

        -- add glow to target
        if currentTarget ~= target then addTargetGlow(target) end
    else
        clearTargetGlow()
    end
end)

-- ===== Movement features (Spin, Noclip, Speed, Fly, InfJump) =====
RunService.Heartbeat:Connect(function(dt)
    if K.Spin and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local root = LocalPlayer.Character.HumanoidRootPart
        root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(K.SpinSpeed) * dt * 60, 0)
    end
end)

local noclipConn = nil
local function applyNoClip(val)
    if val then
        if noclipConn then return end
        noclipConn = RunService.Stepped:Connect(function()
            local char = getCharacter()
            if not char then return end
            for _, part in pairs(char:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = false end end
        end)
    else
        if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
        local char = getCharacter()
        if char then for _, part in pairs(char:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = true end end end
    end
end

RunService.Heartbeat:Connect(function()
    local char = getCharacter()
    if char and char:FindFirstChild("Humanoid") then
        local hum = char.Humanoid
        if K.SpeedHack then hum.WalkSpeed = K.WalkSpeed else hum.WalkSpeed = K.DefaultWalkSpeed end
    end
end)

local flyBV, flyBG = nil, nil
local movementKeys = {}
do movementKeys = {} end
UserInputService.InputBegan:Connect(function(inp, processed)
    if processed then return end
    if inp.UserInputType == Enum.UserInputType.Keyboard then
        movementKeys[tostring(inp.KeyCode):gsub("Enum.KeyCode.","")] = true
    end
end)
UserInputService.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.Keyboard then
        movementKeys[tostring(inp.KeyCode):gsub("Enum.KeyCode.","")] = nil
    end
end)

RunService.Heartbeat:Connect(function()
    if K.Fly and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        if not flyBV then
            flyBV = Instance.new("BodyVelocity", hrp)
            flyBG = Instance.new("BodyGyro", hrp)
            flyBV.MaxForce = Vector3.new(1e5,1e5,1e5)
            flyBG.MaxTorque = Vector3.new(1e5,1e5,1e5)
        end
        local cam = Workspace.CurrentCamera
        local dir = Vector3.new(0,0,0)
        if movementKeys["W"] then dir = dir + cam.CFrame.LookVector end
        if movementKeys["S"] then dir = dir - cam.CFrame.LookVector end
        if movementKeys["A"] then dir = dir - cam.CFrame.RightVector end
        if movementKeys["D"] then dir = dir + cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0,1,0) end
        if dir.Magnitude > 0 then dir = dir.Unit * (K.FlySpeed or 50) end
        flyBV.Velocity = dir
        flyBG.CFrame = cam.CFrame
    else
        if flyBV then flyBV:Destroy(); flyBV = nil end
        if flyBG then flyBG:Destroy(); flyBG = nil end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if K.InfiniteJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local h = LocalPlayer.Character.Humanoid
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- Third person helpers
local function enableThirdPerson()
    local char = getCharacter(); if not char then return end
    local humanoid = char:FindFirstChild("Humanoid"); if not humanoid then return end
    if not K._prevCameraOffset then K._prevCameraOffset = humanoid.CameraOffset end
    humanoid.CameraOffset = Vector3.new(0,0,-math.abs(K.ThirdPersonDist))
end
local function disableThirdPerson()
    local char = getCharacter(); if not char then return end
    local humanoid = char:FindFirstChild("Humanoid")
    if humanoid and K._prevCameraOffset then humanoid.CameraOffset = K._prevCameraOffset; K._prevCameraOffset = nil end
end

-- Teleports
local function teleportToNearest()
    local n = getNearestEnemy()
    if n and n.Character and n.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = n.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,K.TeleportOffset)
        return true
    end
    return false
end

local lastPlayerName = ""
local function teleportToName(name)
    if not name or name=="" then return false end
    for _, p in pairs(Players:GetPlayers()) do
        if string.lower(p.Name) == string.lower(name) then
            if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,K.TeleportOffset) + Vector3.new(0,3,0)
                return true
            end
        end
    end
    return false
end

local function teleportToWP(name)
    local info = K.Waypoints[name]
    if not info then return false end
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local pos = Vector3.new(info.x, info.y, info.z)
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0,3,0))
        return true
    end
    return false
end

-- Waypoint CRUD
local function addWaypoint(name, color)
    if not name or name=="" then return false end
    local char = getCharacter(); if not char or not char:FindFirstChild("HumanoidRootPart") then return false end
    local pos = char.HumanoidRootPart.Position
    K.Waypoints[name] = {x=pos.X, y=pos.Y, z=pos.Z, color = color or {0,1,0}}
    createMarker(name, pos, K.Waypoints[name].color)
    pcall(saveWaypoints)
    return true
end
local function deleteWaypoint(name)
    if not name or name=="" then return false end
    if K.Waypoints[name] then K.Waypoints[name] = nil; removeMarker(name); pcall(saveWaypoints); return true end
    return false
end
local function listWaypoints()
    local t = {}
    for name,_ in pairs(K.Waypoints) do table.insert(t, name) end
    return t
end

-- ===== Notifications (soft fade-in/out) =====
local notifGui = nil
local function createNotifGui()
    if not LocalPlayer or not LocalPlayer:FindFirstChild("PlayerGui") then return end
    if notifGui and notifGui.Parent then notifGui:Destroy() end
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    local screen = Instance.new("ScreenGui", pg); screen.Name = "Kar775_Notifs"; screen.ResetOnSpawn = false
    local frame = Instance.new("Frame", screen); frame.Name="Kar775_NotifFrame"; frame.Size=UDim2.new(0,300,0,40); frame.Position = UDim2.new(0.5, -150, 0.05, 0)
    frame.BackgroundTransparency = (K.Theme=="Dark") and 0.25 or 0.6
    frame.BackgroundColor3 = Color3.new(0,0,0)
    frame.AnchorPoint = Vector2.new(0.5,0)
    frame.BorderSizePixel = 0; frame.Visible = false
    local label = Instance.new("TextLabel", frame); label.Name="Kar_Label"; label.Size = UDim2.fromScale(1,1); label.BackgroundTransparency = 1; label.TextScaled = true; label.Font = Enum.Font.GothamBold; label.TextColor3 = Color3.new(1,1,1)
    notifGui = screen
end
createNotifGui()

local notifTween = nil
local function notifySoft(text)
    pcall(function()
        if not notifGui or not notifGui.Parent then createNotifGui() end
        local frame = notifGui:FindFirstChild("Kar775_NotifFrame", true)
        local label = frame and frame:FindFirstChild("Kar_Label", true)
        if not frame or not label then return end
        label.Text = text
        frame.Visible = true
        frame.BackgroundTransparency = 1
        label.TextTransparency = 1
        pcall(function() if notifTween then notifTween:Cancel() end end)
        frame.BackgroundTransparency = (K.Theme=="Dark") and 0.25 or 0.6
        label.TextTransparency = 0
        -- Fade out after 2.2s
        delay(2.2, function()
            pcall(function()
                label.TextTransparency = 1
                frame.Visible = false
            end)
        end)
    end)
end

local function playSoundOnce(volume)
    pcall(function()
        if not LocalPlayer or not LocalPlayer:FindFirstChild("PlayerGui") then return end
        local gui = LocalPlayer:FindFirstChild("PlayerGui")
        local s = Instance.new("Sound", gui)
        s.SoundId = K.BindSoundId
        s.Volume = math.clamp(volume or K.BindSoundVolume or 0.5, 0, 1)
        s:Play()
        Debris:AddItem(s, 3)
    end)
end

-- ===== Bind parsing and checking (supports combos like "G+T") =====
local function parseBindString(s)
    if not s or s=="" then return nil end
    local parts = {}
    for token in s:gmatch("[^%+]+") do
        token = token:gsub("%s+","")
        if token ~= "" then table.insert(parts, token:upper()) end
    end
    return parts
end

local activeKeys = {} -- keys currently down, keyed by name e.g. "G"
UserInputService.InputBegan:Connect(function(inp, processed)
    if processed then return end
    if inp.UserInputType == Enum.UserInputType.Keyboard then
        local kn = tostring(inp.KeyCode):gsub("Enum.KeyCode.","")
        activeKeys[kn] = true
        -- after adding, check binds: if any bind's all keys are present => fire action
        for bindName, bindStr in pairs(K.Binds) do
            if bindStr and bindStr ~= "" then
                local tokens = parseBindString(bindStr)
                if tokens then
                    local all = true
                    for _, tk in ipairs(tokens) do
                        if not activeKeys[tk] then all = false; break end
                    end
                    if all then
                        -- map bindName to action
                        if bindName == "TPNearest" then
                            local ok = teleportToNearest()
                            if ok then playSoundOnce(K.BindSoundVolume); notifySoft((K.Language=="EN" and "Teleport successful!") or "Телепорт выполнен!") end
                        elseif bindName == "TPPlayer" then
                            if lastPlayerName and lastPlayerName ~= "" then local ok = teleportToName(lastPlayerName) if ok then playSoundOnce(K.BindSoundVolume); notifySoft((K.Language=="EN" and "Teleport successful!") or "Телепорт выполнен!") end else notifySoft((K.Language=="EN" and "No player name") or "Имя не введено") end
                        elseif bindName == "TPToWP" then
                            local sel = waypointDropdown and waypointDropdown.CurrentOption
                            if sel and sel ~= "" then local ok = teleportToWP(sel) if ok then playSoundOnce(K.BindSoundVolume); notifySoft((K.Language=="EN" and "Teleport successful!") or "Телепорт выполнен!") end else notifySoft((K.Language=="EN" and "No WP selected") or "WP не выбран") end
                        elseif bindName == "CreateWP" then
                            local name = "WP_"..tostring(os.time())
                            if addWaypoint(name, {0,1,0}) then playSoundOnce(K.BindSoundVolume); notifySoft("WP created: "..name); saveWaypoints(); rebuildMarkers() end
                        elseif bindName == "Aimbot" then
                            K.Aim.Aimbot = not K.Aim.Aimbot; playSoundOnce(K.BindSoundVolume); notifySoft((K.Aim.Aimbot and "Aimbot ON") or "Aimbot OFF"); saveConfig()
                        elseif bindName == "Trigger" then
                            K.Aim.Trigger = not K.Aim.Trigger; playSoundOnce(K.BindSoundVolume); notifySoft((K.Aim.Trigger and "Trigger ON") or "Trigger OFF"); saveConfig()
                        elseif bindName == "Silent" then
                            K.Aim.Silent = not K.Aim.Silent; playSoundOnce(K.BindSoundVolume); notifySoft((K.Aim.Silent and "Silent ON") or "Silent OFF"); saveConfig()
                        elseif bindName == "ToggleESP" then
                            K.ESP = not K.ESP; playSoundOnce(K.BindSoundVolume); notifySoft((K.ESP and "ESP ON") or "ESP OFF"); saveConfig()
                        elseif bindName == "ToggleSpeed" then
                            K.SpeedHack = not K.SpeedHack; playSoundOnce(K.BindSoundVolume); notifySoft((K.SpeedHack and "Speed ON") or "Speed OFF"); saveConfig()
                        elseif bindName == "ToggleNoclip" then
                            K.Noclip = not K.Noclip; applyNoClip(K.Noclip); playSoundOnce(K.BindSoundVolume); notifySoft((K.Noclip and "Noclip ON") or "Noclip OFF"); saveConfig()
                        elseif bindName == "ToggleGUI" then
                            pcall(function() if Window and Window.SetVisibility then Window:SetVisibility(not Window:GetVisibility()) end end)
                        end
                    end
                end
            end
        end
    end
end)
UserInputService.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.Keyboard then
        local kn = tostring(inp.KeyCode):gsub("Enum.KeyCode.","")
        activeKeys[kn] = nil
    end
end)

-- ===== UI & Build (Rayfield) =====
local T = {
    RU = {
        title = "Kar775 Cheats X",
        subtitle = "by kar775_6, ChatGPT(AI) and Grok(AI)",
        combat = "⚔️ Бой",
        movement = "🏃 Движение",
        visuals = "👁️ Визуал",
        teleports = "🧭 Телепорт / WP",
        binds = "🎹 Бинды",
        settings = "⚙️ Настройки",
        aimbot = "Aimbot", trigger = "TriggerBot", silent = "SilentBot",
        aimRange = "Range", aimFOV = "FOV", aimSmooth = "Smooth (1 = immediate)",
        aimPriority = "Priority", aimIgnore = "Aim Ignore Walls",
        tpNearest = "TP к ближайшему", tpPlayer = "TP к игроку (ввести имя)",
        createWP = "Создать WP (имя)", tpWP = "TP к WP (имя)", delWP = "Удалить WP (имя)",
        listWP = "Список WP (консоль)", waypointList = "WP (выбрать)", setMarkerColor = "Цвет маркера",
        tpOffset = "Смещение TP", bindVolume = "Громкость бинда (0..1)", reset = "🔄 Сбросить настройки",
    },
    EN = {
        title = "Kar775 Cheats X",
        subtitle = "by kar775_6, ChatGPT(AI) and Grok(AI)",
        combat = "⚔️ Combat",
        movement = "🏃 Movement",
        visuals = "👁️ Visuals",
        teleports = "🧭 Teleports / WP",
        binds = "🎹 Binds",
        settings = "⚙️ Settings",
        aimbot = "Aimbot", trigger = "TriggerBot", silent = "SilentBot",
        aimRange = "Range", aimFOV = "FOV", aimSmooth = "Smooth (1 = immediate)",
        aimPriority = "Priority", aimIgnore = "Aim Ignore Walls",
        tpNearest = "TP to Nearest", tpPlayer = "TP to Player (type name)",
        createWP = "Create WP (name)", tpWP = "TP to WP (name)", delWP = "Delete WP (name)",
        listWP = "List WP (console)", waypointList = "WP (select)", setMarkerColor = "Set marker color",
        tpOffset = "Teleport offset", bindVolume = "Bind volume (0..1)", reset = "🔄 Reset settings",
    }
}

local Window, waypointDropdown = nil, nil

local function safeRefreshDropdown()
    pcall(function() if waypointDropdown and waypointDropdown.Refresh then waypointDropdown:Refresh(listWaypoints()) end end)
end

local function buildUI()
    if Window then pcall(function() Window:Destroy() end) end
    local tr = (K.Language=="EN") and T.EN or T.RU

    Window = Rayfield:CreateWindow({
        Name = tr.title,
        LoadingTitle = tr.title,
        LoadingSubtitle = tr.subtitle,
        ConfigurationSaving = { Enabled = true },
        Theme = (K.Theme=="Dark") and "Dark" or "Light",
    })

    -- header custom logo (Rayfield may not support custom direct text logo; we add a label)
    pcall(function()
        local headerTab = Window:CreateTab(tr.title)
        headerTab:CreateLabel({Name = "<font color='#00FF33'>Kar775X</font>", Description = tr.subtitle})
    end)

    -- Combat/Aim
    local Combat = Window:CreateTab(tr.combat)
    Combat:CreateToggle({Name = tr.aimbot, CurrentValue = K.Aim.Aimbot, Callback = function(v) K.Aim.Aimbot = v; saveConfig() end})
    Combat:CreateToggle({Name = tr.trigger, CurrentValue = K.Aim.Trigger, Callback = function(v) K.Aim.Trigger = v; saveConfig() end})
    Combat:CreateToggle({Name = tr.silent, CurrentValue = K.Aim.Silent, Callback = function(v) K.Aim.Silent = v; saveConfig() end})
    Combat:CreateSlider({Name = tr.aimRange, Range = {10,500}, Increment = 5, CurrentValue = K.Aim.Range, Callback = function(v) K.Aim.Range = v; saveConfig() end})
    Combat:CreateSlider({Name = tr.aimFOV, Range = {10,180}, Increment = 1, CurrentValue = K.Aim.FOV, Callback = function(v) K.Aim.FOV = v; saveConfig() end})
    Combat:CreateSlider({Name = tr.aimSmooth, Range = {1,50}, Increment = 1, CurrentValue = K.Aim.Smooth, Callback = function(v) K.Aim.Smooth = v; saveConfig() end})
    Combat:CreateDropdown({Name = tr.aimPriority, Options = {"Nearest","LowestHP","SmallestFOV"}, CurrentOption = K.Aim.Priority, Callback = function(opt) K.Aim.Priority = opt; saveConfig() end})
    Combat:CreateToggle({Name = tr.aimIgnore, CurrentValue = K.Aim.IgnoreWalls, Callback = function(v) K.Aim.IgnoreWalls = v; saveConfig() end})

    -- Movement
    local Move = Window:CreateTab(tr.movement)
    Move:CreateToggle({Name = "SpeedHack", CurrentValue = K.SpeedHack, Callback = function(v) K.SpeedHack = v; saveConfig() end})
    Move:CreateSlider({Name = "Speed Value", Range = {16,500}, Increment = 1, CurrentValue = K.WalkSpeed, Callback = function(v) K.WalkSpeed = v; saveConfig() end})
    Move:CreateToggle({Name = "Fly", CurrentValue = K.Fly, Callback = function(v) K.Fly = v; saveConfig() end})
    Move:CreateSlider({Name = "Fly Speed", Range = {10,300}, Increment = 1, CurrentValue = K.FlySpeed, Callback = function(v) K.FlySpeed = v; saveConfig() end})
    Move:CreateToggle({Name = "Infinite Jump", CurrentValue = K.InfiniteJump, Callback = function(v) K.InfiniteJump = v; saveConfig() end})
    Move:CreateToggle({Name = "Spin", CurrentValue = K.Spin, Callback = function(v) K.Spin = v; saveConfig() end})
    Move:CreateSlider({Name = "Spin Speed", Range = {1,200}, Increment = 1, CurrentValue = K.SpinSpeed, Callback = function(v) K.SpinSpeed = v; saveConfig() end})
    Move:CreateToggle({Name = "NoClip", CurrentValue = K.Noclip, Callback = function(v) K.Noclip = v; applyNoClip(v); saveConfig() end})

    -- Visuals
    local Visual = Window:CreateTab(tr.visuals)
    Visual:CreateToggle({Name = "ESP", CurrentValue = K.ESP, Callback = function(v) K.ESP = v; saveConfig() end})
    Visual:CreateColorPicker({Name = "ESP Color", Color = K.ESPColor, Callback = function(c) K.ESPColor = c; saveConfig() end})
    Visual:CreateSlider({Name = "ESP Transparency", Range = {0,1}, Increment = 0.05, CurrentValue = K.ESPTransparency, Callback = function(v) K.ESPTransparency = v; saveConfig() end})
    Visual:CreateColorPicker({Name = "Aim Target Color", Color = K.AimGlowColor, Callback = function(c) K.AimGlowColor = c; saveConfig() end})
    Visual:CreateSlider({Name = "Aim Glow Transparency", Range = {0,1}, Increment = 0.05, CurrentValue = K.AimGlowTransparency, Callback = function(v) K.AimGlowTransparency = v; saveConfig() end})
    Visual:CreateToggle({Name = "3rd Person", CurrentValue = K.ThirdPerson, Callback = function(v) K.ThirdPerson = v; if v then enableThirdPerson() else disableThirdPerson() end; saveConfig() end})
    Visual:CreateSlider({Name = "3rd Person Distance", Range = {2,20}, Increment = 1, CurrentValue = K.ThirdPersonDist, Callback = function(v) K.ThirdPersonDist = v; if K.ThirdPerson then enableThirdPerson() end; saveConfig() end})

    -- Teleports / WP
    local TTab = Window:CreateTab(tr.teleports)
    TTab:CreateButton({Name = tr.tpNearest, Callback = function() local ok = teleportToNearest(); if ok then playSoundOnce(K.BindSoundVolume); notifySoft((K.Language=="EN" and "Teleport successful!") or "Телепорт выполнен!") end end})
    local playerInput = TTab:CreateInput({Name = tr.tpPlayer, PlaceholderText = "PlayerName", RemoveTextAfterFocusLost=false, Callback = function(text) lastPlayerName = text end})
    TTab:CreateInput({Name = tr.createWP, PlaceholderText = "WPName", RemoveTextAfterFocusLost=false, Callback = function(text) if text and text~="" then if addWaypoint(text, {0,1,0}) then playSoundOnce(K.BindSoundVolume); notifySoft("WP saved: "..text); saveWaypoints(); safeRefreshDropdown() end end end})
    TTab:CreateInput({Name = tr.tpWP, PlaceholderText = "WPName", RemoveTextAfterFocusLost=false, Callback = function(text) if text and text~="" then if teleportToWP(text) then playSoundOnce(K.BindSoundVolume); notifySoft((K.Language=="EN" and "Teleport successful!") or "Телепорт выполнен!") end end end})
    TTab:CreateInput({Name = tr.delWP, PlaceholderText = "WPName", RemoveTextAfterFocusLost=false, Callback = function(text) if text and text~="" then if deleteWaypoint(text) then playSoundOnce(K.BindSoundVolume); notifySoft("WP deleted: "..text); safeRefreshDropdown() end end end})
    TTab:CreateButton({Name = tr.listWP, Callback = function() print("Waypoints:"); for n,_ in pairs(K.Waypoints) do print("-", n) end end})
    waypointDropdown = TTab:CreateDropdown({Name = tr.waypointList, Options = listWaypoints(), CurrentOption = nil, Multi = false, Callback = function(option) if not option then return end local info = K.Waypoints[option]; if info then local pos = Vector3.new(info.x, info.y, info.z); local cam = Workspace.CurrentCamera; if cam then cam.CFrame = CFrame.new(pos + Vector3.new(0,5,0), pos) end end end})
    TTab:CreateColorPicker({Name = tr.setMarkerColor, Color = Color3.fromRGB(0,1,0), Callback = function(c) local sel = waypointDropdown.CurrentOption or nil; if sel and K.Waypoints[sel] then K.Waypoints[sel].color = {c.R, c.G, c.B}; removeMarker(sel); createMarker(sel, Vector3.new(K.Waypoints[sel].x, K.Waypoints[sel].y, K.Waypoints[sel].z), K.Waypoints[sel].color); pcall(saveWaypoints); safeRefreshDropdown() end end})
    TTab:CreateSlider({Name = tr.tpOffset, Range = {1,10}, Increment = 1, CurrentValue = K.TeleportOffset, Callback = function(v) K.TeleportOffset = v; saveConfig() end})

    -- Binds tab (text inputs for combos)
    local BTab = Window:CreateTab(tr.binds)
    BTab:CreateLabel({Name = "Enter bind as single key or combo like G+T (case-insensitive)."})
    local function makeBindRow(label, key)
        BTab:CreateInput({Name = label, PlaceholderText = K.Binds[key] or "", RemoveTextAfterFocusLost=false, Callback = function(txt) K.Binds[key] = txt or ""; saveConfig() end})
    end
    makeBindRow("TPNearest", "TPNearest")
    makeBindRow("TPPlayer", "TPPlayer")
    makeBindRow("TPToWP", "TPToWP")
    makeBindRow("CreateWP", "CreateWP")
    makeBindRow("Aimbot", "Aimbot")
    makeBindRow("Trigger", "Trigger")
    makeBindRow("Silent", "Silent")
    makeBindRow("ToggleESP", "ToggleESP")
    makeBindRow("ToggleSpeed", "ToggleSpeed")
    makeBindRow("ToggleNoclip", "ToggleNoclip")
    makeBindRow("ToggleGUI", "ToggleGUI")
    BTab:CreateSlider({Name = tr.bindVolume, Range = {0,1}, Increment = 0.05, CurrentValue = K.BindSoundVolume, Callback = function(v) K.BindSoundVolume = v; saveConfig() end})

    -- Settings
    local STab = Window:CreateTab(tr.settings)
    STab:CreateDropdown({Name = "Theme", Options = {"Dark","Light"}, CurrentOption = K.Theme or "Dark", Multi = false, Callback = function(opt) K.Theme = opt; saveConfig(); buildUI() end})
    STab:CreateDropdown({Name = "Language", Options = {"RU","EN"}, CurrentOption = K.Language or "RU", Multi = false, Callback = function(opt) K.Language = opt; saveConfig(); buildUI() end})
    STab:CreateButton({Name = tr.reset, Callback = function()
        -- reset config & binds but keep current place's WP
        K = {}
        getgenv().Kar775 = nil
        notifySoft("Reset. Re-run script.")
    end})

    pcall(function() Rayfield:LoadConfiguration() end)

    -- save current Bind flags if Rayfield stored them
    pcall(function()
        local flags = Rayfield.Flags or {}
        for k,v in pairs(flags) do
            local key = tostring(k):lower()
            if key:find("bind_volume") and v and v.Value then K.BindSoundVolume = v.Value end
        end
        saveConfig()
    end)
end

-- initial UI
buildUI()
rebuildMarkers()
pcall(function() game:BindToClose(function() pcall(saveWaypoints); pcall(saveConfig) end) end)

print("[Kar775 Cheats X v5.0] loaded. PlaceId:", PLACE_ID, "Waypoints:", (function() local n=0; for _ in pairs(K.Waypoints) do n=n+1 end return n end)())
