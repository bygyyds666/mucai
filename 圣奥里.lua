local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/bygyyds666/QJ/refs/heads/main/ui.lua"))()

function gradient(text, startColor, endColor)
    local result = ""
    local chars = {}
    for uchar in text:gmatch("[%z\1-\127\194-\244][\128-\191]*") do
        table.insert(chars, uchar)
    end
    local length = #chars
    for i = 1, length do
        local t = (i - 1) / math.max(length - 1, 1)
        local r = startColor.R + (endColor.R - startColor.R) * t
        local g = startColor.G + (endColor.G - startColor.G) * t
        local b = startColor.B + (endColor.B - startColor.B) * t
        result = result .. string.format('<font color="rgb(%d,%d,%d)">%s</font>',
            math.floor(r * 255), math.floor(g * 255), math.floor(b * 255), chars[i])
    end
    return result
end

local LocalPlayer = game:GetService("Players").LocalPlayer

local function getDevType()
    if game:GetService("UserInputService").TouchEnabled then
        return game:GetService("UserInputService").KeyboardEnabled and "平板" or "手机"
    end
    return "电脑"
end

local Window = WindUI:CreateWindow({
        Title = "QJ脚本-圣奥里",
        Icon = "crown",
        IconThemed = true,
        Author = "作者：琼玖",
        Folder = "CloudHub",
        Size = UDim2.fromOffset(300, 200),
        Transparent = true,
        Theme = "Midnight",
        HideSearchBar = false,
        ScrollBarEnabled = true,
        Resizable = true,
        BackgroundImageTransparency = 0.5,
        User = {
            Enabled = true,
            Callback = function()
                WindUI:Notify({
                    Title = "点击了自己",
                    Content = "没什么",
                    Duration = 1,
                    Icon = "4483362748"
                })
            end,
            Anonymous = false
        },
        SideBarWidth = 250,
        Search = {
            Enabled = true,
            Placeholder = "搜索...",
            Callback = function(searchText) end
        },
        SidePanel = {
            Enabled = true,
            Content = {
                {
                    Type = "Button",
                    Text = "",
                    Style = "Subtle",
                    Size = UDim2.new(1, -20, 0, 30),
                    Callback = function() end
                }
            }
        }
    })

Window:SetToggleKey(Enum.KeyCode.N)
Window:SetUIScale(0.75)

local MT = Window:Tab({ Title = "主要", Icon = "crown" })

Window:SelectTab(1)
WindUI:SetNotificationLower(true)

local g = game
local P = g.GetService
local rs = P(g, "ReplicatedStorage")
local ws = g.Workspace
local run = g:GetService("RunService")
local plrs = g:GetService("Players")
local uis = g:GetService("UserInputService")
local deb = g:GetService("Debris")
local lp = plrs.LocalPlayer
if not lp then plrs:GetPropertyChangedSignal("LocalPlayer"):Wait() lp = plrs.LocalPlayer end
local vim = g:GetService("VirtualInputManager")

pcall(function()
    local RS = g:GetService("ReplicatedStorage")
    local tr = nil
    for _, v in pairs(getgc(true)) do
        if type(v) == "table" and rawget(v, "exploitDetected") then
            if typeof(rawget(v, "exploitDetected")) == "Instance" then
                tr = v["exploitDetected"]
                break
            end
        end
    end
    if tr then
        local oNC = hookmetamethod(g, "__namecall", function(s, ...)
            local m = getnamecallmethod()
            if s == tr and (m == "FireServer" or m == "InvokeServer") then return nil end
            return oNC(s, ...)
        end)
        local oFS = hookfunction(Instance.new("RemoteEvent").FireServer, function(s, ...)
            if s == tr then return nil end
            return oFS(s, ...)
        end)
        local oIS = hookfunction(Instance.new("RemoteFunction").InvokeServer, function(s, ...)
            if s == tr then return nil end
            return oIS(s, ...)
        end)
    end
end)

pcall(function() local si = setidentity or setthreadidentity if si then si(8) end end)
local rmt = rs:WaitForChild("Remote", 30)
if not rmt then return end
local pe = rmt:WaitForChild("PlayerEvent", 30)
local pf = rmt:WaitForChild("PlayerFunc", 30)
if not pe or not pf then return end
local ga = rs:FindFirstChild("ReportGoogleAnalyticsEvent")
local bf = {
    ["121"]=true, ["14"]=true, ["429"]=true, ["46"]=true,
    ["772"]=true, ["DEBUG2"]=true, ["violation"]=true,
    ["exploitDetected"]=true, ["flag"]=true, ["report"]=true,
    ["ban"]=true, ["anticheat"]=true, ["detection"]=true,
    ["speedHack"]=true, ["teleportDetect"]=true,
    ["flyDetect"]=true, ["noclipDetect"]=true,
}
local bi = {
    ["letKnowAboutHardHackHackCounter"]=true,
    ["checkExploit"]=true, ["verifyClient"]=true,
}
local hm = hookmetamethod
local gn = getnamecallmethod
local nc = newcclosure or function(x) return x end

local C = {
    ab = false, sAB = false, rB = false, infAmmo = false, fireRate = false, spin = false, wc = false, sh = false, wsV = 16, st = false,
    aM = false, aI = false, qI = false, qD = 25,
    ka = false, kaR = 2000, hb = false, hbS = 30,
    esp = false, espJob = "全部", eTc = false, eL = false, aE = false, sF = false, aF = 80, aS = 0.12,
    fly = false, fS = 50, nc = false,
    tpT = "无",
    fB = false,
    doATM = false, doATMFull = false,
    carFly = false, carSpeed = 100
}

local whitelist = {}

local JobColors = {
    ["警察"] = Color3.fromRGB(0, 100, 255),
    ["医生"] = Color3.fromRGB(0, 200, 0),
    ["消防员"] = Color3.fromRGB(255, 50, 0),
    ["平民"] = Color3.fromRGB(200, 200, 200),
    ["黑帮"] = Color3.fromRGB(150, 0, 150),
    ["司机"] = Color3.fromRGB(100, 200, 255),
    ["厨师"] = Color3.fromRGB(255, 100, 0),
    ["农民"] = Color3.fromRGB(50, 200, 50),
    ["建筑工"] = Color3.fromRGB(255, 200, 50),
    ["囚犯"] = Color3.fromRGB(255, 150, 0),
    ["狱警"] = Color3.fromRGB(0, 150, 255),
    ["快递员"] = Color3.fromRGB(255, 180, 0),
    ["学生"] = Color3.fromRGB(100, 100, 255),
    ["老师"] = Color3.fromRGB(200, 100, 50),
    ["工程师"] = Color3.fromRGB(255, 100, 100),
}

local coreMod
pcall(function()
    local fw = lp:WaitForChild("PlayerScripts", 15):WaitForChild("Framework", 15)
    if fw then pcall(function() coreMod = require(fw:WaitForChild("Core", 15)) end) end
end)

local o
local function h(s, ...)
    if not o then return end
    local ok, m = pcall(gn)
    if not ok then return o(s, ...) end
    if m == "FireServer" then
        if s == ga then return end
        if s == pe then
            local a = (...)
            if type(a) == "string" and bf[a] then return end
        end
    elseif m == "InvokeServer" then
        if s == pf then
            local a = (...)
            if type(a) == "string" and bi[a] then return end
        end
    end
    return o(s, ...)
end
pcall(function() o = hm(g, "__namecall", nc(h)) end)

local function gc(p)
    if not p then return end
    local c = p.Character
    if not c then return end
    local hu = c:FindFirstChildOfClass("Humanoid")
    if not hu or hu.Health <= 0 then return end
    local r = c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso") or c:FindFirstChild("UpperTorso")
    if not r then return end
    return c, hu, r
end
local function gmp() local _, _, r = gc(lp) return r and r.Position end
local function ew()
    local c, hu = gc(lp)
    if not c then return end
    local t = c:FindFirstChildOfClass("Tool")
    if t then return t end
    local bp = lp:FindFirstChild("Backpack")
    if not bp then return end
    for _, v in ipairs(bp:GetChildren()) do
        if v:IsA("Tool") then hu:EquipTool(v) task.wait(0.15) return c:FindFirstChildOfClass("Tool") end
    end
end
local function tp(pos)
    pcall(function()
        local c, hu, r = gc(lp)
        if not c or not r then return end
        local id = ((c:GetAttribute("CharPivotToId") or 0) + 1) % 100
        c:SetAttribute("CharPivotToId", id)
        c:PivotTo(CFrame.new(pos + Vector3.new(0, 3, 0)))
        pe:FireServer("charPivotTo", CFrame.new(pos + Vector3.new(0, 3, 0)), c, id)
    end)
end
local function fp(p)
    if not p or not p.Parent then return end
    pcall(function() if fireproximityprompt then fireproximityprompt(p, 0) return end end)
    pcall(function()
        p.HoldDuration = 0 p.Enabled = true p.RequiresLineOfSight = false p.MaxActivationDistance = 9999
        p:InputHoldBegin() task.wait(0.15) p:InputHoldEnd()
    end)
end
local function gpp(p)
    if not p then return end
    local pp = p.Parent
    if not pp then return end
    if pp:IsA("BasePart") then return pp.Position end
    if pp:IsA("Model") then
        local cp = pp.PrimaryPart or pp:FindFirstChildWhichIsA("BasePart")
        if cp then return cp.Position end
    end
    if pp:IsA("Attachment") then return pp.WorldPosition end
end

local aP = {}; local aM = {}; local ls = 0
local function sc()
    if tick() - ls < 3 then return end
    ls = tick(); aP = {}; aM = {}
    pcall(function()
        for _, d in ipairs(ws:GetDescendants()) do
            if d:IsA("ProximityPrompt") then
                local pos = gpp(d)
                if pos then table.insert(aP, {p = d, n = d.Name, ps = pos, pr = d.Parent, at = d.ActionText or "", ot = d.ObjectText or ""}) end
            elseif d:IsA("Model") and d.Name then
                local n = d.Name
                if n == "Vending Machine" or n == "Vendor" or n == "VendingMachine" or n == "ATM" then
                    local cp = d.PrimaryPart or d:FindFirstChildWhichIsA("BasePart")
                    if cp then table.insert(aM, {m = d, n = n, ps = cp.Position}) end
                end
            end
        end
    end)
end
local function fnp(pred, mp)
    local b, bD = nil, math.huge
    for _, m in ipairs(aP) do if pred(m) then local d = (m.ps - mp).Magnitude if d < bD then bD = d b = m end end end
    return b, bD
end

local fc, fbg, fbv, fat
local function sF()
    if fc then fc:Disconnect() fc = nil end
    local c, hu, r = gc(lp)
    if not c or not r then return end
    local ac = c:FindFirstChildOfClass("Humanoid") or c:FindFirstChildOfClass("AnimationController")
    if ac then
        fat = {}
        for _, t in ipairs(ac:GetPlayingAnimationTracks()) do
            t:AdjustSpeed(0)
            table.insert(fat, t)
        end
    end
    c.Animate.Disabled = true
    local sts = {Enum.HumanoidStateType.Climbing, Enum.HumanoidStateType.FallingDown, Enum.HumanoidStateType.Flying, Enum.HumanoidStateType.Freefall, Enum.HumanoidStateType.GettingUp, Enum.HumanoidStateType.Jumping, Enum.HumanoidStateType.Landed, Enum.HumanoidStateType.Physics, Enum.HumanoidStateType.PlatformStanding, Enum.HumanoidStateType.Ragdoll, Enum.HumanoidStateType.Running, Enum.HumanoidStateType.RunningNoPhysics, Enum.HumanoidStateType.Seated, Enum.HumanoidStateType.StrafingNoPhysics, Enum.HumanoidStateType.Swimming}
    for _, st in ipairs(sts) do pcall(function() hu:SetStateEnabled(st, false) end) end
    pcall(function() hu:ChangeState(Enum.HumanoidStateType.Swimming) end)
    hu.PlatformStand = true
    local ap
    if hu.RigType == Enum.HumanoidRigType.R6 then ap = c:FindFirstChild("Torso") else ap = c:FindFirstChild("UpperTorso") end
    if not ap then ap = r end
    fbg = Instance.new("BodyGyro")
    fbg.P = 9e4
    fbg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    fbg.CFrame = ap.CFrame
    fbg.Parent = ap
    fbv = Instance.new("BodyVelocity")
    fbv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    fbv.Velocity = Vector3.new(0, 0.1, 0)
    fbv.Parent = ap
    local ms = C.fS
    local sm = math.floor(C.fS / 10) + 1
    fc = run.RenderStepped:Connect(function()
        if not C.fly then eF() return end
        if not r or not r.Parent or not c or not c.Parent then eF() return end
        local cam = ws.CurrentCamera
        if not cam then return end
        local md = Vector3.new(0, 0, 0)
        if uis:IsKeyDown(Enum.KeyCode.W) then md += cam.CFrame.LookVector end
        if uis:IsKeyDown(Enum.KeyCode.S) then md -= cam.CFrame.LookVector end
        if uis:IsKeyDown(Enum.KeyCode.A) then md -= cam.CFrame.RightVector end
        if uis:IsKeyDown(Enum.KeyCode.D) then md += cam.CFrame.RightVector end
        if uis:IsKeyDown(Enum.KeyCode.Space) then md += Vector3.new(0, 1, 0) end
        if uis:IsKeyDown(Enum.KeyCode.LeftShift) then md -= Vector3.new(0, 1, 0) end
        if md.Magnitude > 0 then fbv.Velocity = md.Unit * ms else fbv.Velocity = Vector3.new(0, 0, 0) end
        local hm = hu.MoveDirection
        if hm.Magnitude > 0 then for _ = 1, sm do pcall(function() c:TranslateBy(hm) end) end end
        fbg.CFrame = cam.CFrame * CFrame.Angles(-math.rad(md.Y * 0), 0, 0)
    end)
end

local function eF()
    C.fly = false
    if fc then fc:Disconnect() fc = nil end
    if fbg then fbg:Destroy() fbg = nil end
    if fbv then fbv:Destroy() fbv = nil end
    local c, hu, r = gc(lp)
    if not c then return end
    if hu and hu.Parent then
        local sts = {Enum.HumanoidStateType.Climbing, Enum.HumanoidStateType.FallingDown, Enum.HumanoidStateType.Flying, Enum.HumanoidStateType.Freefall, Enum.HumanoidStateType.GettingUp, Enum.HumanoidStateType.Jumping, Enum.HumanoidStateType.Landed, Enum.HumanoidStateType.Physics, Enum.HumanoidStateType.PlatformStanding, Enum.HumanoidStateType.Ragdoll, Enum.HumanoidStateType.Running, Enum.HumanoidStateType.RunningNoPhysics, Enum.HumanoidStateType.Seated, Enum.HumanoidStateType.StrafingNoPhysics, Enum.HumanoidStateType.Swimming}
        for _, st in ipairs(sts) do pcall(function() hu:SetStateEnabled(st, true) end) end
        hu.PlatformStand = false
        pcall(function() hu:ChangeState(Enum.HumanoidStateType.RunningNoPhysics) end)
    end
    if c.Animate then c.Animate.Disabled = false end
    if fat then for _, t in ipairs(fat) do pcall(function() t:AdjustSpeed(1) end) end fat = nil end
end

task.spawn(function()
    for _, tbl in pairs(getgc(true)) do
        if type(tbl) == "table" then
            if rawget(tbl, "SHOOT_MODE") then rawset(tbl, "SHOOT_MODE", 2) end
            if rawget(tbl, "RPM") then rawset(tbl, "RPM", math.huge) end
            if rawget(tbl, "DAMAGE") then rawset(tbl, "DAMAGE", math.huge) end
        end
    end
    while task.wait(0.1) do
        if not C.fireRate then continue end
        for _, tbl in pairs(getgc(true)) do
            if type(tbl) == "table" then
                if rawget(tbl, "RPM") then rawset(tbl, "RPM", math.huge) end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.1) do
        if not C.infAmmo then continue end
        pcall(function()
            local characterFolder = workspace:FindFirstChild("Characters") and workspace.Characters:FindFirstChild(lp.Name)
            if not characterFolder then return end
            for _, gun in ipairs(characterFolder:GetChildren()) do
                local config = gun:FindFirstChild("Config")
                if config then
                    local ammo = config:FindFirstChild("Ammo")
                    local total = config:FindFirstChild("TotalAmmo")
                    if ammo then ammo.Value = math.huge end
                    if total then total.Value = math.huge end
                end
            end
        end)
    end
end)

local spinConn
local function startSpin()
    if spinConn then return end
    spinConn = run.RenderStepped:Connect(function(dt)
        local c = lp.Character
        if not c then return end
        local r = c:FindFirstChild("HumanoidRootPart")
        if r then r.CFrame = r.CFrame * CFrame.Angles(0, math.rad(7200) * dt, 0) end
    end)
end
local function stopSpin()
    if spinConn then spinConn:Disconnect() spinConn = nil end
end

task.spawn(function()
    while task.wait(0.1) do
        if C.nc then
            local c = lp.Character
            if c then
                for _, v in ipairs(c:GetDescendants()) do
                    if v:IsA("BasePart") then v.CanCollide = false end
                end
            end
        end
    end
end)

local function getVehicle()
    local c = lp.Character
    if not c then return end
    local hu = c:FindFirstChildOfClass("Humanoid")
    if not hu or not hu.Sit then return end
    for _, seat in ipairs(ws:GetDescendants()) do
        if (seat:IsA("VehicleSeat") or seat:IsA("Seat")) and seat.Occupant and seat.Occupant.Parent == c then
            return seat.Parent
        end
    end
end

local carFC, carFBG, carFBV
local function startCarFly()
    local veh = getVehicle()
    if not veh then return end
    local pp = veh.PrimaryPart or veh:FindFirstChildWhichIsA("BasePart")
    if not pp then return end
    if carFC then carFC:Disconnect() end
    if carFBG then carFBG:Destroy() end
    if carFBV then carFBV:Destroy() end

    carFBG = Instance.new("BodyGyro")
    carFBG.P = 9e4
    carFBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    carFBG.CFrame = pp.CFrame
    carFBG.Parent = pp

    carFBV = Instance.new("BodyVelocity")
    carFBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    carFBV.Velocity = Vector3.new(0, 0.1, 0)
    carFBV.Parent = pp

    carFC = run.RenderStepped:Connect(function()
        if not C.carFly then stopCarFly() return end
        local v = getVehicle()
        if not v then stopCarFly() return end
        local p = v.PrimaryPart or v:FindFirstChildWhichIsA("BasePart")
        if not p then stopCarFly() return end

        local cam = ws.CurrentCamera
        if not cam then return end
        local md = Vector3.new(0, 0, 0)
        local c, hu = gc(lp)
        if c and hu then md = hu.MoveDirection * (hu.WalkSpeed > 0 and 1 or 0) end
        if md.Magnitude == 0 then
            if uis:IsKeyDown(Enum.KeyCode.W) then md += cam.CFrame.LookVector end
            if uis:IsKeyDown(Enum.KeyCode.S) then md -= cam.CFrame.LookVector end
            if uis:IsKeyDown(Enum.KeyCode.A) then md -= cam.CFrame.RightVector end
            if uis:IsKeyDown(Enum.KeyCode.D) then md += cam.CFrame.RightVector end
        end
        if uis:IsKeyDown(Enum.KeyCode.Space) then md += Vector3.new(0, 1, 0) end
        if uis:IsKeyDown(Enum.KeyCode.LeftShift) then md -= Vector3.new(0, 1, 0) end
        if md.Magnitude > 0 then carFBV.Velocity = md.Unit * C.carSpeed else carFBV.Velocity = Vector3.new(0, 0, 0) end
        carFBG.CFrame = cam.CFrame
    end)
end

local function stopCarFly()
    if carFC then carFC:Disconnect() carFC = nil end
    if carFBG then carFBG:Destroy() carFBG = nil end
    if carFBV then carFBV:Destroy() carFBV = nil end
end

local Fr, aL
local eLns = {}
local sNT, sC

local function gTFOV(pn)
    local cam = ws.CurrentCamera
    if not cam then return end
    local ct = cam.ViewportSize / 2
    local bD = C.aF + 1
    local bC, bP = nil, nil
    for _, p in ipairs(plrs:GetPlayers()) do
        if p == lp then continue end
        local c, hu, r = gc(p)
        if not c or not r or hu.Health <= 0 then continue end
        if C.eTc and p.Team == lp.Team then continue end
        local pt = c:FindFirstChild(pn)
        if pt then
            local sp, on = cam:WorldToViewportPoint(pt.Position)
            if on then
                local d = (Vector2.new(sp.X, sp.Y) - ct).Magnitude
                if d <= C.aF and d < bD then bD = d bC = c bP = pt end
            end
        end
    end
    return bC, bP
end

local function cT(o, tp)
    local part = Instance.new("Part")
    part.Size = Vector3.new(0.2, 0.2, 0.2)
    part.Anchored = true
    part.CanCollide = false
    part.Transparency = 1
    part.CFrame = CFrame.new(o)
    part.Parent = ws
    local a0 = Instance.new("Attachment", part)
    local a1 = Instance.new("Attachment", ws.Terrain)
    a1.WorldPosition = tp
    local bm = Instance.new("Beam", part)
    bm.Attachment0 = a0
    bm.Attachment1 = a1
    bm.Color = ColorSequence.new(Color3.fromRGB(255, 0, 0))
    bm.Width0 = 0.3
    bm.Width1 = 0.3
    bm.FaceCamera = true
    bm.LightEmission = 1
    deb:AddItem(part, 0.2)
end

local function pS()
    pcall(function()
        local snd = Instance.new("Sound", ws)
        snd.SoundId = "rbxassetid://9116483270"
        snd.Volume = 1
        snd.PlayOnRemove = true
        snd:Destroy()
    end)
end

local sT, sO
task.spawn(function()
    pcall(function()
        local old = pe.FireServer
        pe.FireServer = function(s, ...)
            local a = {...}
            if C.sAB and sT then
                local hd = sT:FindFirstChild("Head")
                if hd then
                    if a[1] == "bullet" then
                        a[2] = a[2] or {}
                        a[2].pos = hd.Position
                        a[2].posDestroyX = hd.Position.X
                    elseif a[1] == "damage" then
                        a[2] = a[2] or {}
                        a[2].bodyParts = {{"Head", 1}}
                        a[2].pos = hd.Position
                        if sO then a[2].shotCode = {sO.Position, (hd.Position - sO.Position).Unit} end
                    end
                end
            end
            return old(s, unpack(a))
        end
    end)
end)

run.RenderStepped:Connect(function()
    local cam = ws.CurrentCamera
    if not cam then return end
    if C.sF then
        if not Fr then Fr = Drawing.new("Circle") Fr.Thickness = 2 Fr.Color = Color3.fromRGB(255, 255, 255) Fr.Filled = false end
        Fr.Visible = true Fr.Radius = C.aF Fr.Position = cam.ViewportSize / 2
    elseif Fr then Fr.Visible = false end
    if C.ab then
        local tC, tP = gTFOV("Head")
        if tC and tP then
            if not aL then aL = Drawing.new("Line") aL.Thickness = 1 aL.Color = Color3.fromRGB(255, 50, 50) end
            local sp, on = cam:WorldToViewportPoint(tP.Position)
            aL.Visible = on aL.From = cam.ViewportSize / 2 aL.To = Vector2.new(sp.X, sp.Y)
            cam.CFrame = cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position, tP.Position), C.aS)
        else
            if aL then aL.Visible = false end
        end
    elseif aL then aL.Visible = false end

    pcall(function()
        if C.sAB then
            local c, _, r = gc(lp)
            if c and r then
                sO = r
                local bD = C.aF + 1
                local bC, bP
                for _, p in ipairs(plrs:GetPlayers()) do
                    if p == lp then continue end
                    local pc, phu, pr = gc(p)
                    if pc and pr and phu and phu.Health > 0 then
                        local hd = pc:FindFirstChild("Head")
                        if hd then
                            local sp, on = cam:WorldToViewportPoint(hd.Position)
                            if on then
                                local d = (Vector2.new(sp.X, sp.Y) - cam.ViewportSize / 2).Magnitude
                                if d < bD then bD = d bC = pc bP = p end
                            end
                        end
                    end
                end
                sT = bC
                if bC and bP then
                    local hd = bC:FindFirstChild("Head")
                    if hd then
                        local sp, on = cam:WorldToViewportPoint(hd.Position)
                        if on then
                            if not sNT then sNT = Drawing.new("Text") sNT.Size = 16 sNT.Center = true sNT.Outline = true sNT.Color = Color3.fromRGB(255, 255, 0) end
                            sNT.Visible = true
                            sNT.Text = "锁定: " .. bP.Name
                            sNT.Position = Vector2.new(sp.X, sp.Y - 30)
                            if not sC then sC = Drawing.new("Circle") sC.Thickness = 2 sC.Filled = false sC.Color = Color3.fromRGB(255, 255, 0) sC.Radius = 20 end
                            sC.Visible = true
                            sC.Position = Vector2.new(sp.X, sp.Y)
                        end
                    end
                else
                    if sNT then sNT.Visible = false end
                    if sC then sC.Visible = false end
                end
            end
        else
            sT = nil
            if sNT then sNT.Visible = false end
            if sC then sC.Visible = false end
        end
    end)

    local ptd = {}
    for _, p in ipairs(plrs:GetPlayers()) do
        if p == lp then continue end
        if C.eTc and p.Team == lp.Team then continue end
        local c = gc(p)
        if c then
            local rt = c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso") or c:FindFirstChild("UpperTorso")
            if rt then
                local sp, on = cam:WorldToViewportPoint(rt.Position)
                if on then table.insert(ptd, sp) end
            end
        end
    end
    for i = 1, math.max(#ptd, #eLns) do
        if i <= #ptd then
            if not eLns[i] then eLns[i] = Drawing.new("Line") eLns[i].Thickness = 1 eLns[i].Color = Color3.fromRGB(255, 0, 0) end
            if C.eL then eLns[i].Visible = true eLns[i].From = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y) eLns[i].To = Vector2.new(ptd[i].X, ptd[i].Y)
            else eLns[i].Visible = false end
        else
            if eLns[i] then eLns[i]:Remove() eLns[i] = nil end
        end
    end
    if not C.eL then for i, ln in ipairs(eLns) do ln:Remove() end eLns = {} end
end)

local function GetPlayerJob(player)
    if player.Team then return player.Team.Name end
    return "平民"
end

local hls = {}
local function uE()
    for _, p in ipairs(plrs:GetPlayers()) do
        if p == lp then continue end
        if C.eTc and p.Team == lp.Team then if hls[p] then hls[p]:Destroy() hls[p] = nil end continue end
        if C.espJob ~= "全部" then
            local job = GetPlayerJob(p)
            if job ~= C.espJob then if hls[p] then hls[p]:Destroy() hls[p] = nil end continue end
        end
        local c = p.Character
        if not c then if hls[p] then hls[p]:Destroy() hls[p] = nil end continue end
        if C.esp then
            if not hls[p] or not hls[p].Parent then
                local hl = Instance.new("Highlight")
                local jobColor = JobColors[GetPlayerJob(p)] or Color3.fromRGB(255, 0, 0)
                hl.FillColor = C.espJob ~= "全部" and jobColor or Color3.fromRGB(255, 0, 0)
                hl.OutlineColor = hl.FillColor
                hl.FillTransparency = 0.5
                hl.OutlineTransparency = 0
                hl.Adornee = c
                hl.Parent = c
                hls[p] = hl
            end
        elseif hls[p] then hls[p]:Destroy() hls[p] = nil end
    end
end

local atmH = {}
local function uA()
    local ex = {}
    sc()
    for _, d in ipairs(aM) do
        if d.n == "ATM" and d.m and d.m.Parent then
            ex[d.m] = true
            if C.aE then
                if not atmH[d.m] or not atmH[d.m].Parent then
                    local hl = Instance.new("Highlight")
                    hl.FillColor = Color3.fromRGB(0, 255, 255)
                    hl.OutlineColor = Color3.fromRGB(0, 255, 255)
                    hl.FillTransparency = 0.5
                    hl.OutlineTransparency = 0
                    hl.Adornee = d.m
                    hl.Parent = d.m
                    atmH[d.m] = hl
                end
            else
                if atmH[d.m] then atmH[d.m]:Destroy() atmH[d.m] = nil end
            end
        end
    end
    for m, hl in pairs(atmH) do if not ex[m] then hl:Destroy() atmH[m] = nil end end
end

for _, p in ipairs(plrs:GetPlayers()) do if p ~= lp then p.CharacterAdded:Connect(function() if C.esp then task.wait(0.1) uE() end end) end end
plrs.PlayerAdded:Connect(function(p) if p ~= lp then p.CharacterAdded:Connect(function() if C.esp then task.wait(0.1) uE() end end) end end)
task.spawn(function() while task.wait(1) do uE() uA() end end)

task.spawn(function()
    local lR = 0
    while task.wait(0.01) do
        if not C.rB then continue end
        local nw = tick()
        if nw - lR < 0.05 then continue end
        lR = nw
        local c, hu, r = gc(lp)
        if not c or not r then continue end
        local my = r.Position
        local bestDist = math.huge
        local bT
        for _, p in ipairs(plrs:GetPlayers()) do
            if p == lp then continue end
            if whitelist[p.Name] then continue end
            local pc, phu, pr = gc(p)
            if not pc or not pr or phu.Health <= 0 then continue end
            local hd = pc:FindFirstChild("Head")
            if not hd then continue end
            local d = (hd.Position - my).Magnitude
            if d < bestDist then bestDist = d bT = p end
        end
        if bT and bT.Character then
            local hd = bT.Character:FindFirstChild("Head")
            if hd then
                pcall(function()
                    pe:FireServer("damage", {bodyParts = {{"Head", 1}}, shotCode = {my, (hd.Position - my).Unit}, pos = hd.Position, target = bT, damageFactor = 1.5, bulletProofTool = false})
                    cT(my, hd.Position)
                    pS()
                end)
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.01) do
        if not C.ka then continue end
        local mc, mh, mr = gc(lp)
        if not mr then continue end
        ew()
        local mp = mr.Position
        for _, p in ipairs(plrs:GetPlayers()) do
            if p == lp then continue end
            if whitelist[p.Name] then continue end
            local c, hu, r = gc(p)
            if c and r and hu.Health > 0 and (r.Position - mp).Magnitude <= C.kaR then
                pcall(function()
                    pe:FireServer("damage", {bodyParts = {{"Head", 1}}, shotCode = {mr.Position, (r.Position - mr.Position).Unit}, pos = r.Position, target = p, damageFactor = 1.5, bulletProofTool = false})
                end)
            end
        end
    end
end)

local dSz = {}
task.spawn(function()
    while task.wait(0.2) do
        if C.hb then
            for _, p in ipairs(plrs:GetPlayers()) do
                if p == lp then continue end
                local c = gc(p)
                if c and c:FindFirstChild("HumanoidRootPart") then
                    local rt = c.HumanoidRootPart
                    if not dSz[rt] then dSz[rt] = rt.Size end
                    rt.Size = Vector3.new(C.hbS, C.hbS, C.hbS)
                    rt.CanCollide = true
                end
            end
        else
            for rt, sz in pairs(dSz) do if rt and rt.Parent then rt.Size = sz end end
            dSz = {}
        end
    end
end)

task.spawn(function()
    while task.wait(0.2) do
        local c, hu = gc(lp)
        if c and hu then hu.WalkSpeed = C.sh and C.wsV or 16 end
    end
end)

task.spawn(function()
    while task.wait(0.05) do
        pcall(function()
            if coreMod and C.st then
                if coreMod.setCoreStaminaOrFood then coreMod.setCoreStaminaOrFood(100, 100) end
                coreMod.stamina = 100
                coreMod.food = 100
            end
        end)
    end
end)

local mN = {["CashDrop"] = true, ["GetItem"] = true}
task.spawn(function()
    while task.wait(0.3) do
        if not C.aM then continue end
        local mp = gmp(); if not mp then continue end
        sc()
        local t, d = fnp(function(m) return mN[m.n] end, mp)
        if t and d < 60 then
            if d > 8 then tp(t.ps) task.wait(0.4) end
            if t.n == "CashDrop" then pf:InvokeServer("cashDrop", t.p) else pf:InvokeServer("getItem", t.p) end
            task.wait(0.2)
        end
    end
end)

local function qI(p)
    if not p then return end
    pcall(function() if fireproximityprompt then fireproximityprompt(p, 0) return end end)
    pcall(function() p:InputHoldBegin() task.wait(0.15) p:InputHoldEnd() end)
end

task.spawn(function()
    while task.wait(0.05) do
        if not C.aI then continue end
        local mp = gmp(); if not mp then continue end
        sc()
        local nr = nil
        local nD = math.huge
        for _, m in ipairs(aP) do
            local d = (m.ps - mp).Magnitude
            if d < nD and d < 10 then nD = d nr = m end
        end
        if nr then
            if nD > 4 then tp(nr.ps) task.wait(0.1) end
            if C.qI then qI(nr.p) else fp(nr.p) end
        end
    end
end)

task.spawn(function()
    while task.wait(0.1) do
        if not C.tpT or C.tpT == "无" then continue end
        local t = plrs:FindFirstChild(C.tpT)
        if not t then continue end
        local c, hu, r = gc(t)
        if not c or not r then continue end
        local bh = r.Position - r.CFrame.LookVector * 3
        tp(bh)
    end
end)

local function buyStuffItem(fn, sn, inn)
    pcall(function()
        local item = rs:FindFirstChild("Stuff") and rs.Stuff:FindFirstChild(fn) and rs.Stuff[fn]:FindFirstChild(sn) and rs.Stuff[fn][sn]:FindFirstChild(inn)
        if item then pf:InvokeServer("purchase", {isRestaurant = false, item = item}) end
    end)
end

local function buyItemsItem(itemName)
    pcall(function()
        local item = rs:FindFirstChild("Stuff") and rs.Stuff:FindFirstChild("Items") and rs.Stuff.Items:FindFirstChild(itemName)
        if item then pf:InvokeServer("purchase", {isRestaurant = false, item = item}) end
    end)
end

local function hasDC()
    local c = lp.Character
    if c then for _, t in ipairs(c:GetChildren()) do if t:IsA("Tool") and t.Name == "Decryption Circuit" then return true end end end
    local bp = lp:FindFirstChild("Backpack")
    if bp then for _, t in ipairs(bp:GetChildren()) do if t.Name == "Decryption Circuit" then return true end end end
    return false
end

local vA = {}
local function tNA()
    local aM = {}
    pcall(function()
        for _, d in ipairs(ws:GetDescendants()) do
            if d:IsA("Model") and d.Name == "ATM" then
                local cp = d.PrimaryPart or d:FindFirstChildWhichIsA("BasePart")
                if cp then table.insert(aM, {m = d, n = d.Name, ps = cp.Position}) end
            end
        end
    end)
    local mp = gmp() if not mp then return end
    local en = ws:FindFirstChild("Gameplay") and ws.Gameplay:FindFirstChild("Entities")
    local sH = en and en:FindFirstChild("StartHack")
    if not sH or not sH:IsA("BasePart") then return end
    local hP = sH.Position
    local nr, nD = nil, math.huge
    for _, m in ipairs(aM) do
        if m.n == "ATM" then
            if vA[m.ps] then continue end
            if (m.ps - hP).Magnitude > 30 then continue end
            local hasPrompt = false
            for _, v in ipairs(ws:GetDescendants()) do
                if v:IsA("ProximityPrompt") and v.Enabled then
                    local pp = v.Parent
                    local pos
                    if pp and pp:IsA("BasePart") then pos = pp.Position
                    elseif pp and pp:IsA("Model") then
                        local cp = pp.PrimaryPart or pp:FindFirstChildWhichIsA("BasePart")
                        if cp then pos = cp.Position end
                    end
                    if pos and (pos - m.ps).Magnitude < 15 then hasPrompt = true break end
                end
            end
            if not hasPrompt then continue end
            local pD = (m.ps - mp).Magnitude
            if pD < nD then nD = pD nr = m end
        end
    end
    if nr then vA[nr.ps] = true; tp(nr.ps); return true end
    return false
end

local AtmGui = lp.PlayerGui.ScreenGui.Center.Middle.HackingMinigames["ATM Hack"]
local BlockedColor = Color3.fromRGB(74, 75, 93)
local ClickedButtons = {}

local function GetCodes()
    return string.split(AtmGui.Sequence1.Text, " ")
end

local function ClickButton(Button)
    local Pos = Button.AbsolutePosition
    local Size = Button.AbsoluteSize
    vim:SendMouseButtonEvent(Pos.X + Size.X/2, Pos.Y + Size.Y/2, 0, true, game, 0)
    vim:SendMouseButtonEvent(Pos.X + Size.X/2, Pos.Y + Size.Y/2, 0, false, game, 0)
end

task.spawn(function()
    while task.wait() do
        if AtmGui and AtmGui.Sequence1.Text ~= "" then
            local Codes = GetCodes()
            for _, Button in ipairs(AtmGui.List:GetDescendants()) do
                if Button:IsA("ImageButton") and not ClickedButtons[Button] and Button.ImageColor3 ~= BlockedColor then
                    for _, Label in ipairs(Button:GetDescendants()) do
                        if Label:IsA("TextLabel") then
                            for _, Code in ipairs(Codes) do
                                if Label.Text == Code then
                                    ClickButton(Button)
                                    ClickedButtons[Button] = true
                                    break
                                end
                            end
                        end
                        if ClickedButtons[Button] then break end
                    end
                end
            end
        else
            ClickedButtons = {}
        end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if C.doATM then
            C.doATM = false
            pcall(function()
                local en = ws:FindFirstChild("Gameplay") and ws.Gameplay:FindFirstChild("Entities")
                local sH = en and en:FindFirstChild("StartHack")
                if sH and sH:IsA("BasePart") then
                    if not hasDC() then
                        buyStuffItem("Black Market", "1", "Decryption Circuit")
                        task.wait(0.3)
                    end
                    pf:InvokeServer("talkToMission", sH)
                end
            end)
        end
        if C.doATMFull then
            C.doATMFull = false
            pcall(function()
                local en = ws:FindFirstChild("Gameplay") and ws.Gameplay:FindFirstChild("Entities")
                local sH = en and en:FindFirstChild("StartHack")
                if not sH or not sH:IsA("BasePart") then return end
                tNA()
                task.wait(1.5)
                if not hasDC() then
                    buyStuffItem("Black Market", "1", "Decryption Circuit")
                    task.wait(0.3)
                end
                pf:InvokeServer("talkToMission", sH)
                task.wait(0.5)
                repeat task.wait(1)
                until not (AtmGui and AtmGui.Sequence1.Text ~= "")
                task.wait(5)
            end)
        end
    end
end)

local WEAPON_ITEMS = {
    {shop = "1", name = "Knife", display = "小刀", price = 150},
    {shop = "2", name = "Battle Axe", display = "战斧", price = 250},
    {shop = "3", name = "Bat", display = "棒球棍", price = 600},
    {shop = "4", name = "Machete", display = "砍刀", price = 1200},
    {shop = "5", name = "Glock 17", display = "格洛克17", price = 700},
    {shop = "6", name = "M19", display = "M19手枪", price = 800},
    {shop = "7", name = "Deagle 44", display = "沙漠之鹰44", price = 950},
    {shop = "8", name = "MAC-11", display = "MAC-11冲锋枪", price = 1100},
    {shop = "9", name = "MP5", display = "MP5冲锋枪", price = 1200},
    {shop = "10", name = "P90", display = "P90冲锋枪", price = 1450},
    {shop = "11", name = "Galil", display = "加利尔步枪", price = 1700},
    {shop = "12", name = "Famas", display = "法玛斯步枪", price = 2050},
    {shop = "13", name = "SLR36C", display = "SLR36C步枪", price = 2400},
    {shop = "14", name = "Sawed-Off", display = "短管霰弹枪", price = 2750},
    {shop = "15", name = "MPX", display = "MPX冲锋枪", price = 3200},
    {shop = "16", name = "M4A1", display = "M4A1步枪", price = 3700},
    {shop = "17", name = "ACC Honey Badger", display = "蜜獾步枪", price = 4400},
    {shop = "18", name = "AK-47", display = "AK-47步枪", price = 5400},
}

local BM_ITEMS = {
    {shop = "1", name = "Decryption Circuit", display = "解密电路", price = 150},
    {shop = "2", name = "Lockpick Device", display = "开锁器", price = 400},
    {shop = "3", name = "Hacking Tool", display = "黑客工具", price = 600},
    {shop = "4", name = "C4", display = "C4炸药", price = 800},
    {shop = "5", name = "Green USB", display = "绿色U盘", price = 750},
    {shop = "8", name = "Crew Graffiti", display = "帮派涂鸦", price = 250},
}

local MARKET_ITEMS = {
    {name = "Binoculars", display = "望远镜", price = 200},
    {name = "Black Parachute", display = "黑色降落伞", price = 400},
    {name = "Blue Parachute", display = "蓝色降落伞", price = 400},
    {name = "Orange Parachute", display = "橙色降落伞", price = 400},
    {name = "Metal Detector", display = "金属探测仪", price = 750},
    {name = "Trowel", display = "铲子", price = 38},
    {name = "News Camera", display = "新闻摄像头", price = 80},
    {name = "News Microphone", display = "新闻麦克风", price = 50},
    {name = "Pocket", display = "口袋", price = 13000},
    {name = "Red Umbrella", display = "红色雨伞", price = 250},
    {name = "Blue Umbrella", display = "蓝色雨伞", price = 250},
    {name = "Repair Kit", display = "维修工具包", price = 1000},
    {name = "Fishing Rod", display = "钓鱼竿", price = 150},
    {name = "Enhanced Fishing Rod", display = "升级版钓竿", price = 600},
    {name = "Apple", display = "苹果", price = 23},
    {name = "Croissant", display = "松饼卷", price = 24},
    {name = "Box Of Milk", display = "一箱牛奶", price = 28},
    {name = "Soda Can", display = "汽水罐", price = 14},
}

local weaponNames = {}
for _, item in ipairs(WEAPON_ITEMS) do table.insert(weaponNames, item.display .. " ($" .. item.price .. ")") end
local bmNames = {}
for _, item in ipairs(BM_ITEMS) do table.insert(bmNames, item.display .. " ($" .. item.price .. ")") end
local marketNames = {}
for _, item in ipairs(MARKET_ITEMS) do table.insert(marketNames, item.display .. " ($" .. item.price .. ")") end

local selectedWeapon = weaponNames[1]
local selectedBM = bmNames[1]
local selectedMarket = marketNames[1]

local function gDO()
    local gp = rs:FindFirstChild("Gameplay")
    local ms = gp and gp:FindFirstChild("Missions")
    local ac = ms and ms:FindFirstChild("Active")
    if ac then
        for _, m in ipairs(ac:GetChildren()) do
            if m.Name and m.Name:find("^Farmer") then
                for _, p in ipairs({m:FindFirstChild("DropOff"), m:FindFirstChild("Target"), m:FindFirstChild("Goal")}) do
                    if p and p:IsA("BasePart") then return p.Position end
                    if p and p:IsA("ObjectValue") and p.Value and p.Value:IsA("BasePart") then return p.Value.Position end
                end
            end
        end
    end
    local en = ws:FindFirstChild("Gameplay") and ws.Gameplay:FindFirstChild("Entities")
    if en then
        local d = en:FindFirstChild("DropOff")
        if d and d:IsA("BasePart") then return d.Position end
        if d and d:IsA("Model") then local pp = d.PrimaryPart or d:FindFirstChildWhichIsA("BasePart") if pp then return pp.Position end end
    end
end

local function fT(pos)
    local c = lp.Character if not c then return end
    local r = c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso") if not r then return end
    pcall(function() pf:InvokeServer("dropItem") end)
    task.wait(0.1)
    local cf = CFrame.new(pos + Vector3.new(0, 3, 0))
    local id = ((c:GetAttribute("CharPivotToId") or 0) + 1) % 100
    c:SetAttribute("CharPivotToId", id)
    c:PivotTo(cf)
    pe:FireServer("charPivotTo", cf, c, id)
    local st = tick()
    local cn = run.Heartbeat:Connect(function()
        if tick() - st > 0.4 then cn:Disconnect() return end
        pcall(function() r.CFrame = cf r.Velocity = Vector3.zero end)
    end)
    task.wait(0.45)
end

local function iDO()
    local pos = gDO()
    if not pos then return false end
    local c = lp.Character if not c then return false end
    local r = c:FindFirstChild("HumanoidRootPart") if not r then return false end
    return (r.Position - pos).Magnitude < 10
end

local function nPP()
    local c = lp.Character if not c then return end
    local r = c:FindFirstChild("HumanoidRootPart") if not r then return end
    local mp = r.Position
    local b, bD
    for _, v in ipairs(ws:GetDescendants()) do
        if v:IsA("ProximityPrompt") and v.ActionText == "Pick Up" then
            v.HoldDuration = 0
            v.MaxActivationDistance = 200
            v.RequiresLineOfSight = false
            local pp = v.Parent
            local pos
            if pp:IsA("BasePart") then pos = pp.Position
            elseif pp:IsA("Model") then
                local cp = pp.PrimaryPart or pp:FindFirstChildWhichIsA("BasePart")
                if cp then pos = cp.Position end
            end
            if pos then
                local d = (pos - mp).Magnitude
                if not bD or d < bD then bD = d b = v end
            end
        end
    end
    return b
end

local function fI(p) qI(p) end

local fR = false
local fI2 = false
task.spawn(function()
    while task.wait(0.3) do
        if not C.fB then fR = false fI2 = false continue end
        fR = true
        if not fI2 then
            local dp = gDO()
            if dp then fT(dp) fI2 = true task.wait(0.5) end
        end
        if not iDO() then
            local dp = gDO()
            if dp then fT(dp) task.wait(0.5) end
        else
            local pr = nPP()
            if pr then fI(pr) end
        end
    end
end)

local function pP(p)
    if not p or not p.Parent then return end
    p.HoldDuration = 0
    p.RequiresLineOfSight = false
end

task.spawn(function()
    while task.wait(0.3) do
        if C.qI then
            for _, v in ipairs(ws:GetDescendants()) do
                if v:IsA("ProximityPrompt") then
                    pP(v)
                    v.MaxActivationDistance = C.qD
                end
            end
        end
    end
end)

workspace.DescendantAdded:Connect(function(obj)
    if C.qI and obj:IsA("ProximityPrompt") then
        task.wait(0.1)
        pP(obj)
        obj.MaxActivationDistance = C.qD
    end
end)

local TP_DATA = {
    {n = "车辆经销商", p = Vector3.new(3719.95, 3.02, -333.31), r = "圣奥里"},
    {n = "医院", p = Vector3.new(3980.09, 2.88, -138.79), r = "圣奥里"},
    {n = "警察局", p = Vector3.new(3364.27, 3.92, -394.72), r = "圣奥里"},
    {n = "修车店", p = Vector3.new(2782.47, 2.63, -418.60), r = "圣奥里"},
    {n = "银行", p = Vector3.new(3134.05, 6.12, -171.37), r = "圣奥里"},
    {n = "服装店", p = Vector3.new(3617.91, 3.11, -452.82), r = "圣奥里"},
    {n = "平民重生", p = Vector3.new(3741.11, 3.72, -438.11), r = "圣奥里"},
    {n = "码头", p = Vector3.new(4527.66, -23.97, -280.59), r = "圣奥里"},
    {n = "餐饮店", p = Vector3.new(3182.42, 3.02, 426.52), r = "圣奥里"},
    {n = "消防部门", p = Vector3.new(3578.68, 8.41, 579.66), r = "圣奥里"},
    {n = "宠物店", p = Vector3.new(3678.24, 3.02, 693.11), r = "圣奥里"},
    {n = "大码头", p = Vector3.new(2736.31, 2.63, -1120.33), r = "圣奥里"},
    {n = "海滩桥下(消星点)", p = Vector3.new(3964.50, -25.07, -854.06), r = "圣奥里"},
    {n = "超级超市", p = Vector3.new(3936.58, 3.04, 1136.33), r = "大景"},
    {n = "转镜中心", p = Vector3.new(4152.92, 2.63, 941.45), r = "大景"},
    {n = "道路服务", p = Vector3.new(4271.33, 2.63, 1200.09), r = "大景"},
    {n = "餐饮店", p = Vector3.new(4477.00, 3.04, 906.80), r = "大景"},
    {n = "送货中心", p = Vector3.new(4399.42, 3.04, 1609.46), r = "大景"},
    {n = "卖车店", p = Vector3.new(3434.38, 42.93, 2688.00), r = "大景"},
    {n = "餐饮店", p = Vector3.new(753.76, 3.04, 998.13), r = "莱斯维尔"},
    {n = "服装店", p = Vector3.new(820.75, 2.77, 1047.45), r = "莱斯维尔"},
    {n = "自由广场", p = Vector3.new(926.52, 2.63, 865.76), r = "莱斯维尔"},
    {n = "码头(游艇)", p = Vector3.new(947.84, -22.53, 1216.09), r = "莱斯维尔"},
    {n = "左上加油站", p = Vector3.new(1145.64, 2.63, -864.27), r = "米尔顿"},
    {n = "右下加油站", p = Vector3.new(-1646.80, 2.63, 1812.89), r = "米尔顿"},
    {n = "上方加油站", p = Vector3.new(-900.70, 2.63, 1124.68), r = "米尔顿"},
    {n = "居民区", p = Vector3.new(-528.57, 2.63, 1331.98), r = "米尔顿"},
    {n = "小银行", p = Vector3.new(-668.22, 2.63, -65.35), r = "约克镇"},
    {n = "修车厂", p = Vector3.new(-407.16, 3.08, -6.10), r = "约克镇"},
    {n = "枪店", p = Vector3.new(-323.87, 3.04, 37.15), r = "约克镇"},
    {n = "重生点", p = Vector3.new(-219.56, 3.04, -85.73), r = "约克镇"},
    {n = "当铺", p = Vector3.new(-168.51, 3.04, -106.93), r = "约克镇"},
    {n = "卫星车", p = Vector3.new(-302.09, 3.04, -167.62), r = "约克镇"},
    {n = "中心点", p = Vector3.new(-275.99, 2.63, -139.99), r = "约克镇"},
    {n = "黑色市场", p = Vector3.new(1038.97, -22.73, 895.43), r = "其他"},
    {n = "鱼夫码头", p = Vector3.new(-50.15, -24.56, 1462.15), r = "其他"},
    {n = "农场", p = Vector3.new(-1268.34, 2.57, 2560.06), r = "其他"},
    {n = "监狱门口", p = Vector3.new(-1697.93, 2.63, 1284.57), r = "其他"},
    {n = "监狱广场", p = Vector3.new(-1600.60, 2.63, 1268.06), r = "其他"},
    {n = "代尔山", p = Vector3.new(847.06, 194.12, -326.21), r = "其他"},
    {n = "水帘洞(消星点)", p = Vector3.new(3040.96, 109.69, 2711.07), r = "其他"},
    {n = "大桥", p = Vector3.new(949.01, 25.22, 2897.65), r = "其他"},
    {n = "地图右下(消星点)", p = Vector3.new(-1651.39, 2.41, 3225.28), r = "其他"},
    {n = "下部加油站", p = Vector3.new(2270.38, 2.63, 154.16), r = "其他"},
    {n = "游戏厅", p = Vector3.new(2934.89, 2.96, 1693.66), r = "其他"},
    {n = "高尔夫", p = Vector3.new(2280.77, 3.04, 1982.36), r = "其他"},
    {n = "修船厂", p = Vector3.new(4096.41, -30.40, 2865.05), r = "其他"},
}

local tpNames = {}
local tpPositions = {}
for _, d in ipairs(TP_DATA) do
    table.insert(tpNames, d.r .. " - " .. d.n)
    table.insert(tpPositions, d.p)
end

local selectedTP = tpNames[1]

local function updatePlayerLists()
    local pn = {"无"}
    for _, p in ipairs(plrs:GetPlayers()) do if p ~= lp then table.insert(pn, p.Name) end end
    return pn
end

local playerNames = updatePlayerLists()
local whitelistNames = {"无"}
for _, p in ipairs(plrs:GetPlayers()) do if p ~= lp then table.insert(whitelistNames, p.Name) end end

local selectedPlayer = playerNames[1]
local selectedWhitelist = whitelistNames[1]

local jobList = {"全部"}
for jobName, _ in pairs(JobColors) do table.insert(jobList, jobName) end
local selectedJob = "全部"

plrs.PlayerAdded:Connect(function()
    playerNames = updatePlayerLists()
    whitelistNames = {"无"}
    for _, p in ipairs(plrs:GetPlayers()) do if p ~= lp then table.insert(whitelistNames, p.Name) end end
end)

plrs.PlayerRemoving:Connect(function()
    playerNames = updatePlayerLists()
    whitelistNames = {"无"}
    for _, p in ipairs(plrs:GetPlayers()) do if p ~= lp then table.insert(whitelistNames, p.Name) end end
end)

MT:Toggle({ Title = "无限体力", Value = C.st, Callback = function(s) C.st = s end })
MT:Toggle({ Title = "无限饥饿", Value = C.st, Callback = function(s) C.st = s end })
MT:Toggle({ Title = "自动捡钱", Value = C.aM, Callback = function(s) C.aM = s end })
MT:Toggle({ Title = "无限子弹", Value = C.infAmmo, Callback = function(s) C.infAmmo = s end })
MT:Toggle({ Title = "射速增快", Value = C.fireRate, Callback = function(s) C.fireRate = s end })

local PT = Window:Tab({ Title = "玩家", Icon = "user" })
PT:Toggle({ Title = "加速", Value = C.sh, Callback = function(s) C.sh = s end })
PT:Slider({ Title = "速度值", Value = { Min = 16, Max = 500, Default = C.wsV }, Step = 1, Callback = function(v) C.wsV = v end })
PT:Toggle({ Title = "飞行", Value = C.fly, Callback = function(s) C.fly = s if s then sF() else eF() end end })
PT:Slider({ Title = "飞行速度", Value = { Min = 10, Max = 500, Default = C.fS }, Step = 1, Callback = function(v) C.fS = v end })
PT:Toggle({ Title = "穿墙", Value = C.nc, Callback = function(s) C.nc = s end })
PT:Toggle({ Title = "自动互动", Value = C.aI, Callback = function(s) C.aI = s end })
PT:Toggle({ Title = "快速互动", Value = C.qI, Callback = function(s) C.qI = s end })
PT:Slider({ Title = "触发距离", Value = { Min = 5, Max = 150, Default = C.qD }, Step = 1, Callback = function(v) C.qD = v end })
PT:Toggle({ Title = "旋转", Value = C.spin, Callback = function(s) C.spin = s if s then startSpin() else stopSpin() end end })

local CT = Window:Tab({ Title = "战斗", Icon = "crosshair" })
CT:Toggle({ Title = "自瞄", Value = C.ab, Callback = function(s) C.ab = s end })
CT:Toggle({ Title = "静默自瞄", Value = C.sAB, Callback = function(s) C.sAB = s end })
CT:Toggle({ Title = "RageBot", Value = C.rB, Callback = function(s) C.rB = s end })
CT:Slider({ Title = "自瞄平滑度", Value = { Min = 0.01, Max = 1, Default = C.aS }, Step = 0.01, Callback = function(v) C.aS = v end })
CT:Toggle({ Title = "杀戮光环", Value = C.ka, Callback = function(s) C.ka = s end })
CT:Slider({ Title = "光环范围", Value = { Min = 5, Max = 5000, Default = C.kaR }, Step = 10, Callback = function(v) C.kaR = v end })
CT:Toggle({ Title = "Hitbox扩大", Value = C.hb, Callback = function(s) C.hb = s end })
CT:Slider({ Title = "Hitbox大小", Value = { Min = 5, Max = 100, Default = C.hbS }, Step = 1, Callback = function(v) C.hbS = v end })
CT:Toggle({ Title = "FOV圈", Value = C.sF, Callback = function(s) C.sF = s end })
CT:Slider({ Title = "FOV大小", Value = { Min = 10, Max = 300, Default = C.aF }, Step = 1, Callback = function(v) C.aF = v end })
CT:Dropdown({ Title = "白名单(不受伤害)", Values = whitelistNames, Value = selectedWhitelist, Callback = function(n)
    selectedWhitelist = n
    whitelist = {}
    if n ~= "无" then whitelist[n] = true end
end })

local VT = Window:Tab({ Title = "汽车", Icon = "car" })
VT:Toggle({ Title = "汽车飞行", Value = C.carFly, Callback = function(s) C.carFly = s if s then startCarFly() else stopCarFly() end end })
VT:Slider({ Title = "飞行速度", Value = { Min = 50, Max = 500, Default = C.carSpeed }, Step = 10, Callback = function(v) C.carSpeed = v end })

local ET = Window:Tab({ Title = "ESP", Icon = "eye" })
ET:Toggle({ Title = "玩家高亮", Value = C.esp, Callback = function(s) C.esp = s end })
ET:Toggle({ Title = "忽略队友", Value = C.eTc, Callback = function(s) C.eTc = s end })
ET:Toggle({ Title = "ESP天线", Value = C.eL, Callback = function(s) C.eL = s end })
ET:Toggle({ Title = "ATM高亮", Value = C.aE, Callback = function(s) C.aE = s end })
ET:Dropdown({ Title = "职业透视", Values = jobList, Value = selectedJob, Callback = function(n)
    selectedJob = n
    C.espJob = n
end })

local FT = Window:Tab({ Title = "刷钱", Icon = "dollar-sign" })
FT:Toggle({ Title = "农民刷钱", Value = C.fB, Callback = function(s) C.fB = s end })
FT:Button({ Title = "自动破解(站在原地)", Icon = "unlock", Callback = function()
    C.doATM = true
end })
FT:Button({ Title = "传送+全自动破解", Icon = "truck", Callback = function()
    C.doATMFull = true
end })

local AUT = Window:Tab({ Title = "自动购买", Icon = "shopping-cart" })
AUT:Dropdown({ Title = "武器商店", Values = weaponNames, Value = selectedWeapon, Callback = function(name) selectedWeapon = name end })
AUT:Button({ Title = "购买武器", Icon = "crosshair", Callback = function()
    for _, item in ipairs(WEAPON_ITEMS) do
        if item.display .. " ($" .. item.price .. ")" == selectedWeapon then
            buyStuffItem("Weapons", item.shop, item.name)
            break
        end
    end
end })
AUT:Dropdown({ Title = "黑商", Values = bmNames, Value = selectedBM, Callback = function(name) selectedBM = name end })
AUT:Button({ Title = "购买黑商物品", Icon = "shopping-cart", Callback = function()
    for _, item in ipairs(BM_ITEMS) do
        if item.display .. " ($" .. item.price .. ")" == selectedBM then
            buyStuffItem("Black Market", item.shop, item.name)
            break
        end
    end
end })
AUT:Dropdown({ Title = "超市", Values = marketNames, Value = selectedMarket, Callback = function(name) selectedMarket = name end })
AUT:Button({ Title = "购买超市物品", Icon = "basket", Callback = function()
    for _, item in ipairs(MARKET_ITEMS) do
        if item.display .. " ($" .. item.price .. ")" == selectedMarket then
            buyItemsItem(item.name)
            break
        end
    end
end })

local TT = Window:Tab({ Title = "传送", Icon = "map-pin" })
TT:Button({ Title = "最近ATM", Icon = "dollar-sign", Callback = function() tNA() end })
TT:Dropdown({ Title = "传送点", Values = tpNames, Value = selectedTP, Callback = function(name) selectedTP = name end })
TT:Button({ Title = "传送", Icon = "map-pin", Callback = function()
    for i, name in ipairs(tpNames) do
        if name == selectedTP then tp(tpPositions[i]) break end
    end
end })
TT:Dropdown({ Title = "玩家传送", Values = playerNames, Value = selectedPlayer, Callback = function(n)
    selectedPlayer = n
    C.tpT = n
end })  
