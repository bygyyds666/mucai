local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/bygyyds666/QJ/refs/heads/main/ui.lua"))()

local Window = WindUI:CreateWindow({
    Title = "你的脚本",
    Size = UDim2.new(0, 600, 0, 400),
    Theme = "Dark"
})
            
            local Players = game:GetService("Players")
            local Workspace = game:GetService("Workspace")
            local RunService = game:GetService("RunService")
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            local LocalPlayer = Players.LocalPlayer
            local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local rootPart = character:WaitForChild("HumanoidRootPart")

            LocalPlayer.CharacterAdded:Connect(function(char)
                character = char
                rootPart = char:WaitForChild("HumanoidRootPart")
            end)

            local function isSkinwalker(npc)
                if not npc then return false end
                if string.find(string.lower(npc.Name), "skinwalker") then return true end
                if npc:GetAttribute("Skinwalker") == true or npc:GetAttribute("IsSkinwalker") == true or npc:GetAttribute("Cursed") == true then return true end
                local face = npc:FindFirstChild("Face") or npc:FindFirstChild("Head.002")
                if face and face:IsA("Decal") then
                    local texture = face.TextureID or ""
                    if string.find(texture, "Skinwalker") or string.find(texture, "Cursed") then return true end
                end
                return false
            end

            local function getPosition(obj)
                if not obj then return nil end
                if obj:IsA("BasePart") then return obj.Position end
                if obj:IsA("Model") then
                    local hrp = obj.PrimaryPart or obj:FindFirstChild("HumanoidRootPart")
                    if hrp then return hrp.Position end
                end
                return nil
            end

            local function hasEnabledPrompt(obj)
                if not obj then return false end
                if obj:IsA("ProximityPrompt") and obj.Enabled then return true end
                for _, desc in pairs(obj:GetDescendants()) do
                    if desc:IsA("ProximityPrompt") and desc.Enabled then
                        return true
                    end
                end
                return false
            end

            local function safeTeleport(pos)
                if not pos then return end
                local char = LocalPlayer.Character
                if not char then return end
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local hum = char:FindFirstChildOfClass("Humanoid")
                if not hrp then return end
                
                local direction = (hrp.Position - pos).Unit
                local checkPos = pos + direction * 3
                local rayParams = RaycastParams.new()
                rayParams.FilterDescendantsInstances = {char}
                rayParams.FilterType = Enum.RaycastFilterType.Exclude
                
                local result = Workspace:Raycast(checkPos, Vector3.new(0, -5, 0), rayParams)
                if result then
                    checkPos = result.Position + Vector3.new(0, 3, 0)
                end
                
                hrp.CFrame = CFrame.new(checkPos)
                task.wait(0.05)
                hrp.Velocity = Vector3.new(0, 0, 0)
                if hum then
                    hum:ChangeState(Enum.HumanoidStateType.Running)
                end
            end

            local function firePrompt(prompt, maxRetries)
                maxRetries = maxRetries or 3
                local retryCount = 0
                while retryCount < maxRetries do
                    if not prompt or not prompt:IsA("ProximityPrompt") or not prompt.Enabled then 
                        return false 
                    end
                    local success = false
                    local s1 = pcall(function() fireproximityprompt(prompt) end)
                    if s1 then success = true end
                    if not success then
                        pcall(function()
                            prompt:InputHoldStart(LocalPlayer)
                            task.wait(prompt.HoldDuration > 0 and (prompt.HoldDuration + 0.1) or 0.1)
                            prompt:InputHoldEnd(LocalPlayer)
                        end)
                        success = true
                    end
                    if success then
                        task.wait(0.75)
                        return true
                    end
                    retryCount = retryCount + 1
                    if retryCount < maxRetries then
                        task.wait(2)
                    end
                end
                return false
            end

            local function interactWithObject(obj)
                if not obj then return false end
                if obj:IsA("ProximityPrompt") and obj.Enabled then
                    return firePrompt(obj)
                end
                for _, desc in pairs(obj:GetDescendants()) do
                    if desc:IsA("ProximityPrompt") and desc.Enabled then
                        if firePrompt(desc) then return true end
                    end
                end
                return false
            end

            local animalTab = Window:Tab({
                Title = "绘制",
                Icon = "brain",
                Locked = false,
            })

            animalTab:Toggle({
                Title = "动物绘制(区分异常)",
                Default = false,
                Callback = function(state)
                    _G.ESP = state
                    WindUI:Notify({Title = "绘制", Content = state and "已开启" or "已关闭", Duration = 2})
                    if state then
                        task.spawn(function()
                            while _G.ESP do
                                local npcs = Workspace:FindFirstChild("NPCs")
                                if npcs then
                                    for _, child in pairs(npcs:GetChildren()) do
                                        if child:IsA("Model") then
                                            local rPart = child:FindFirstChild("HumanoidRootPart")
                                            if rPart then
                                                local highlight = child:FindFirstChild("ESP_Highlight")
                                                if not highlight then
                                                    highlight = Instance.new("Highlight")
                                                    highlight.Name = "ESP_Highlight"
                                                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                                    highlight.Parent = child
                                                end
                                                local billboard = child:FindFirstChild("ESP_Billboard")
                                                if child:GetAttribute("Skinwalker") == true then
                                                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                                                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                                                    if not billboard then
                                                        billboard = Instance.new("BillboardGui")
                                                        billboard.Name = "ESP_Billboard"
                                                        billboard.Size = UDim2.new(0, 100, 0, 30)
                                                        billboard.StudsOffset = Vector3.new(0, 3, 0)
                                                        billboard.AlwaysOnTop = true
                                                        billboard.Parent = child
                                                        local label = Instance.new("TextLabel")
                                                        label.Size = UDim2.fromScale(1, 1)
                                                        label.BackgroundTransparency = 1
                                                        label.TextScaled = true
                                                        label.Font = Enum.Font.SourceSansBold
                                                        label.TextStrokeTransparency = 0
                                                        label.TextColor3 = Color3.fromRGB(255, 0, 0)
                                                        label.Text = "异常动物"
                                                        label.Parent = billboard
                                                    end
                                                else
                                                    highlight.FillColor = Color3.fromRGB(0, 255, 0)
                                                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                                                    if billboard then billboard:Destroy() end
                                                end
                                            end
                                        end
                                    end
                                end
                                task.wait(1)
                            end
                        end)
                    else
                        local npcs = Workspace:FindFirstChild("NPCs")
                        if npcs then
                            for _, child in pairs(npcs:GetChildren()) do
                                local highlight = child:FindFirstChild("ESP_Highlight")
                                if highlight then highlight:Destroy() end
                                local billboard = child:FindFirstChild("ESP_Billboard")
                                if billboard then billboard:Destroy() end
                            end
                        end
                    end
                end
            })

            local espTable = {}

            local function createESP(target)
                if not target or espTable[target] then return end
                local highlight = Instance.new("Highlight")
                highlight.Name = "PatientESP"
                highlight.FillColor = Color3.fromRGB(128, 0, 255)
                highlight.FillTransparency = 0.5
                highlight.OutlineColor = Color3.fromRGB(170, 0, 255)
                highlight.OutlineTransparency = 0
                highlight.Adornee = target
                highlight.Parent = target
                espTable[target] = highlight
            end

            local function removeESP(target)
                if espTable[target] then
                    espTable[target]:Destroy()
                    espTable[target] = nil
                end
            end

            local function clearAllESP()
                for target, highlight in pairs(espTable) do
                    highlight:Destroy()
                end
                espTable = {}
            end

            local function scanPatients()
                local containers = {
                    Workspace:FindFirstChild("NPCs"),
                    Workspace:FindFirstChild("Rooms") and Workspace.Rooms:FindFirstChild("Medical"),
                    Workspace:FindFirstChild("Rooms") and Workspace.Rooms:FindFirstChild("Emergency"),
                }
                local foundPatients = {}
                for _, container in ipairs(containers) do
                    if container then
                        for _, descendant in pairs(container:GetDescendants()) do
                            if descendant.Name == "PatientHighlight" then
                                local parent = descendant.Parent
                                if parent and (parent:IsA("Model") or parent:IsA("BasePart")) then
                                    foundPatients[parent] = true
                                end
                            end
                        end
                    end
                end
                for target in pairs(espTable) do
                    if not foundPatients[target] then removeESP(target) end
                end
                for target in pairs(foundPatients) do
                    createESP(target)
                end
            end

            local patientEspEnabled = false
            local patientEspConnection

            local function startPatientESP()
                patientEspEnabled = true
                scanPatients()
                patientEspConnection = RunService.Heartbeat:Connect(scanPatients)
            end

            local function stopPatientESP()
                patientEspEnabled = false
                if patientEspConnection then
                    patientEspConnection:Disconnect()
                    patientEspConnection = nil
                end
                clearAllESP()
            end

            animalTab:Toggle({
                Title = "病人绘制",
                Default = false,
                Callback = function(state)
                    WindUI:Notify({Title = "绘制", Content = state and "已开启" or "已关闭", Duration = 2})
                    if state then startPatientESP() else stopPatientESP() end
                end
            })

            animalTab:Toggle({
                Title = "玩家绘制",
                Default = false,
                Callback = function(state)
                    _G.PlayerESP = state
                    WindUI:Notify({Title = "绘制", Content = state and "已开启" or "已关闭", Duration = 2})
                    if state then
                        task.spawn(function()
                            while _G.PlayerESP do
                                for _, player in pairs(Players:GetPlayers()) do
                                    if player ~= LocalPlayer and player.Character then
                                        local highlight = player.Character:FindFirstChild("PlayerESP_Highlight")
                                        if not highlight then
                                            highlight = Instance.new("Highlight")
                                            highlight.Name = "PlayerESP_Highlight"
                                            highlight.FillColor = Color3.fromRGB(255, 255, 255)
                                            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                                            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                            highlight.Parent = player.Character
                                        end
                                    end
                                end
                                task.wait(1)
                            end
                        end)
                    else
                        for _, player in pairs(Players:GetPlayers()) do
                            if player.Character then
                                local highlight = player.Character:FindFirstChild("PlayerESP_Highlight")
                                if highlight then highlight:Destroy() end
                            end
                        end
                    end
                end
            })

            local APQTab = Window:Tab({
                Title = "理智",
                Icon = "brain",
                Locked = false,
            })

            APQTab:Section({Title = "服务器端", TextXAlignment = "Left", TextSize = 17})

            APQTab:Section({Title = "注意 俩个不要一起开", TextXAlignment = "Left", TextSize = 17})

            local Library = require(ReplicatedStorage:WaitForChild("Lib"))

            APQTab:Button({
                Title = "无限理智(服务器端)",
                Callback = function()
                    local args = {
                        [1] = math.huge * 2 - math.huge,
                        [2] = "Job Stress",
                        [3] = true
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("Util"):WaitForChild("Net"):WaitForChild("RE/PlayerLostSanity"):FireServer(unpack(args))
                end
            })

            APQTab:Section({Title = "客户端", TextXAlignment = "Left", TextSize = 17})

            local Library = require(ReplicatedStorage:WaitForChild("Lib"))
            local sanityEnabled = false
            local isCustomMode = false
            local customSanityValue = 100
            local sanityConnections = {}

            local function keepSanityFull()
                if not sanityEnabled or not LocalPlayer then return end
                local targetValue = isCustomMode and customSanityValue or 100
                pcall(function() 
                    LocalPlayer:SetAttribute("Sanity", targetValue) 
                end)
            end

            local function enableSanity(customMode)
                for _, connection in ipairs(sanityConnections) do
                    pcall(function() connection:Disconnect() end)
                end
                sanityConnections = {}

                sanityEnabled = true
                isCustomMode = customMode
                
                pcall(function()
                    local remote = ReplicatedStorage:WaitForChild("Util"):WaitForChild("Net"):FindFirstChild("RE/PlayerLostSanity")
                    if remote then 
                        remote:Destroy() 
                    end
                    Library.Inject("PlayerLostSanity", keepSanityFull)
                end)
                
                table.insert(sanityConnections, RunService.Heartbeat:Connect(keepSanityFull))
                table.insert(sanityConnections, LocalPlayer:GetAttributeChangedSignal("Sanity"):Connect(keepSanityFull))
                
                keepSanityFull()
            end

            local function disableSanity()
                sanityEnabled = false
                isCustomMode = false
                for _, connection in ipairs(sanityConnections) do
                    pcall(function() connection:Disconnect() end)
                end
                sanityConnections = {}
            end

            APQTab:Toggle({
                Title = "无限理智(客户端)",
                Default = false,
                Callback = function(state)
                    if state then
                        enableSanity(false)
                    else
                        if not isCustomMode then disableSanity() end
                    end
                end
            })

            APQTab:Slider({
                Title = "自定义理智度",
                Value = {Min = 0, Max = 100, Default = 100},
                Increment = 1,
                Callback = function(value)
                    customSanityValue = value
                    if sanityEnabled and isCustomMode then
                        keepSanityFull()
                    end
                end
            })

            APQTab:Toggle({
                Title = "启用自定义理智",
                Default = false,
                Callback = function(state)
                    if state then
                        enableSanity(true)
                    else
                        if isCustomMode then disableSanity() end
                    end
                end
            })

            APQTab:Section({Title = "恶趣", TextXAlignment = "Left", TextSize = 17})

            APQTab:Button({
                Title = "扣100理智",
                Callback = function()
                    local args = {[1] = 100, [2] = "Job Stress", [3] = true}
                    local net = ReplicatedStorage:FindFirstChild("Util")
                    if net then
                        local rem = net:FindFirstChild("Net")
                        if rem then
                            local event = rem:FindFirstChild("RE/PlayerLostSanity")
                            if event then
                                event:FireServer(unpack(args))
                                WindUI:Notify({Title = "已扣除100理智 (你疯了？)", Content = "", Duration = 5})
                            end
                        end
                    end
                end
            })

            local APWTab = Window:Tab({
                Title = "工作",
                Icon = "brain",
                Locked = false,
            })

            local RunService = game:GetService("RunService")
            local Players = game:GetService("Players")

            local player = Players.LocalPlayer
            local toggleState = false
            local connection = nil
            local lastUpdate = 0
            local UPDATE_INTERVAL = 0.2

            local function CheckScreenBeep(screen)
                if not screen then return false end
                local beep = screen:FindFirstChild("beep-1")
                return beep and beep:IsA("Sound") and beep.IsPlaying
            end

            local function ScanRoom(room, targets, isEmergency)
                if not room then return end
                local minigame = room:FindFirstChild("Minigame")
                if not minigame then return end
                
                for _, descendant in ipairs(minigame:GetDescendants()) do
                    if descendant.Name == "Screen" and CheckScreenBeep(descendant) then
                        local actualMonitor = descendant.Parent
                        if actualMonitor then
                            table.insert(targets, actualMonitor)
                        end
                    end
                end
                
                local analyzer = minigame:FindFirstChild("Analyzer")
                if analyzer then
                    local screen = analyzer:FindFirstChild("Screen")
                    if screen and CheckScreenBeep(screen) then
                        table.insert(targets, analyzer)
                    else
                        local hasPrompt = false
                        for _, desc in ipairs(analyzer:GetDescendants()) do
                            if (desc:IsA("ProximityPrompt") and desc.Enabled) or desc:IsA("ClickDetector") then
                                hasPrompt = true
                                break
                            end
                        end
                        if hasPrompt then
                            table.insert(targets, analyzer)
                        end
                    end
                end

                if isEmergency then
                    local emergencyObjects = {"StandIV", "HeartMonitor", "Machine", "Printer"}
                    for _, objName in ipairs(emergencyObjects) do
                        local obj = minigame:FindFirstChild(objName)
                        if obj then
                            local hasPrompt = false
                            for _, desc in ipairs(obj:GetDescendants()) do
                                if (desc:IsA("ProximityPrompt") and desc.Enabled) or desc:IsA("ClickDetector") then
                                    hasPrompt = true
                                    break
                                end
                            end
                            if hasPrompt then
                                table.insert(targets, obj)
                            end
                        end
                    end
                end
            end

            local function FindAllTargets()
                local targets = {}
                local rooms = workspace:FindFirstChild("Rooms")
                if not rooms then return targets end
                
                local medical = rooms:FindFirstChild("Medical")
                local emergency = rooms:FindFirstChild("Emergency")
                
                if medical then
                    for i = 1, 5 do
                        local room = medical:FindFirstChild("Room" .. i)
                        if room then
                            ScanRoom(room, targets, false)
                        end
                    end
                end
                
                if emergency then
                    for i = 6, 8 do
                        local room = emergency:FindFirstChild("Room" .. i)
                        if room then
                            ScanRoom(room, targets, true)
                        end
                    end
                end
                
                return targets
            end

            local function FindNearestValidTarget(rootPart)
                local targets = FindAllTargets()
                local nearest = nil
                local nearestDist = math.huge
                
                for _, target in ipairs(targets) do
                    local basePart = target:FindFirstChild("Screen") or target:FindFirstChild("Ink Receiver Cover") or target:FindFirstChildOfClass("Part") or target:FindFirstChildOfClass("MeshPart")
                    if basePart and basePart:IsA("BasePart") then
                        local dist = (rootPart.Position - basePart.Position).Magnitude
                        if dist < nearestDist then
                            nearestDist = dist
                            nearest = target
                        end
                    end
                end
                
                return nearest
            end

            APWTab:Toggle({
                Title = "自动房间",
                Default = false,
                Callback = function(state)
                    toggleState = state
                    
                    if WindUI and WindUI.Notify then
                        WindUI:Notify({Title = "自动房间", Content = state and "已开启" or "已关闭", Duration = 3})
                    end
                    
                    if connection then
                        connection:Disconnect()
                        connection = nil
                    end
                    
                    if state then
                        connection = RunService.Stepped:Connect(function()
                            if not toggleState then
                                if connection then connection:Disconnect() connection = nil end
                                return
                            end
                            
                            local success, err = pcall(function()
                                local playerGui = player:FindFirstChild("PlayerGui")
                                if playerGui then
                                    local mainGui = playerGui:FindFirstChild("MainGui") or playerGui:FindFirstChild("ScreenGui")
                                    if mainGui and mainGui:FindFirstChild("BoKi") then
                                        return
                                    end
                                end
                                
                                local now = os.clock()
                                if now - lastUpdate < UPDATE_INTERVAL then return end
                                lastUpdate = now
                                
                                local character = player.Character
                                if not character then return end
                                local rootPart = character:FindFirstChild("HumanoidRootPart")
                                if not rootPart or not rootPart:IsA("BasePart") then return end
                                
                                local target = FindNearestValidTarget(rootPart)
                                if not target then return end
                                
                                local basePart = target:FindFirstChild("Screen") or target:FindFirstChild("Ink Receiver Cover") or target:FindFirstChildOfClass("Part") or target:FindFirstChildOfClass("MeshPart")
                                if not basePart or not basePart:IsA("BasePart") then return end
                                
                                local dist = (rootPart.Position - basePart.Position).Magnitude
                                if dist > 5 then
                                    local targetCFrame = CFrame.new(basePart.Position + Vector3.new(0, 0, 2.5), basePart.Position)
                                    rootPart.CFrame = targetCFrame
                                    task.wait(0.1)
                                end
                                
                                local descendants = target:GetDescendants()
                                local blacklistedText = {"view", "watch", "look", "focus"}
                                
                                for _, descendant in ipairs(descendants) do
                                    if not descendant then continue end
                                    
                                    local isPrompt = descendant:IsA("ProximityPrompt")
                                    local isClicker = descendant:IsA("ClickDetector")
                                    
                                    if isPrompt or isClicker then
                                        local name = descendant.Name:lower()
                                        local isBlacklisted = false
                                        
                                        if isPrompt then
                                            local actionText = descendant.ActionText:lower()
                                            local objectText = descendant.ObjectText:lower()
                                            for _, text in ipairs(blacklistedText) do
                                                if string.find(name, text) or string.find(actionText, text) or string.find(objectText, text) then
                                                    isBlacklisted = true
                                                    break
                                                end
                                            end
                                        end
                                        
                                        if not isBlacklisted then
                                            if isPrompt and descendant.Enabled then
                                                task.spawn(function()
                                                    fireproximityprompt(descendant)
                                                end)
                                                break
                                            elseif isClicker then
                                                task.spawn(function()
                                                    fireclickdetector(descendant)
                                                end)
                                                break
                                            end
                                        end
                                    end
                                end
                            end)
                            
                            if not success then
                                return
                            end
                        end)
                    end
                end
            })

            local function findNearestTarget(container)
                if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or not container then return nil end
                local char = LocalPlayer.Character
                local hrp = char.HumanoidRootPart
                local nearestDistance = math.huge
                local nearestTarget = nil
                
                local function checkContainer(folder)
                    if not folder then return end
                    for _, descendant in pairs(folder:GetDescendants()) do
                        if descendant.Name == "PatientHighlight" then
                            local parent = descendant.Parent
                            if parent and not isSkinwalker(parent) then
                                local position = getPosition(parent)
                                if position then
                                    local distance = (hrp.Position - position).Magnitude
                                    if distance < nearestDistance then
                                        nearestDistance = distance
                                        nearestTarget = descendant
                                    end
                                end
                            end
                        end
                    end
                end

                checkContainer(container)
                
                local rooms = Workspace:FindFirstChild("Rooms")
                if rooms then
                    local emergency = rooms:FindFirstChild("Emergency")
                    if emergency then
                        for i = 6, 7 do
                            local room = emergency:FindFirstChild("Room" .. i)
                            if room then
                                checkContainer(room:FindFirstChild("Minigame") or room)
                            end
                        end
                    end
                end
                
                return nearestTarget
            end

            APWTab:Toggle({
                Title = "自动处理",
                Default = false,
                Callback = function(state)
                    _G.APW_AutoProcess = state
                    WindUI:Notify({Title = "自动处理", Content = state and "已开启" or "已关闭", Duration = 3})
                    if state then
                        task.spawn(function()
                            while _G.APW_AutoProcess do
                                task.wait(0.1)
                                pcall(function()
                                    local lChar = LocalPlayer.Character
                                    local lRoot = lChar and lChar:FindFirstChild("HumanoidRootPart")
                                    if not lChar or not lRoot then return end
                                    
                                    local npcsFolder = Workspace:FindFirstChild("NPCs")
                                    if not npcsFolder then return end
                                    
                                    local target = findNearestTarget(npcsFolder)
                                    local processedTarget = false
                                    
                                    if target then
                                        local targetParent = target.Parent
                                        if targetParent and not isSkinwalker(targetParent) and hasEnabledPrompt(targetParent) then
                                            local pos = getPosition(targetParent)
                                            if pos then
                                                safeTeleport(pos)
                                                for _, descendant in pairs(targetParent:GetDescendants()) do
                                                    if descendant:IsA("ProximityPrompt") and descendant.Enabled then
                                                        if firePrompt(descendant) then 
                                                            processedTarget = true
                                                            break 
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                    
                                    if processedTarget then return end
                                    
                                    local scanList = {}
                                    for _, npc in pairs(npcsFolder:GetChildren()) do
                                        table.insert(scanList, npc)
                                    end
                                    
                                    local rooms = Workspace:FindFirstChild("Rooms")
                                    if rooms then
                                        local emergency = rooms:FindFirstChild("Emergency")
                                        if emergency then
                                            for i = 6, 8 do
                                                local room = emergency:FindFirstChild("Room" .. i)
                                                local minigame = room and room:FindFirstChild("Minigame")
                                                if minigame then
                                                    for _, obj in pairs(minigame:GetChildren()) do
                                                        table.insert(scanList, obj)
                                                    end
                                                end
                                            end
                                        end
                                    end
                                    
                                    for _, npc in pairs(scanList) do
                                        if not _G.APW_AutoProcess then break end
                                        if (npc:IsA("Model") or npc:IsA("Part") or npc:IsA("MeshPart")) and not isSkinwalker(npc) and hasEnabledPrompt(npc) then
                                            local pos = getPosition(npc)
                                            if pos then
                                                safeTeleport(pos)
                                                local interacted = false
                                                for _, desc in pairs(npc:GetDescendants()) do
                                                    if desc:IsA("ProximityPrompt") and desc.Enabled then
                                                        if firePrompt(desc) then interacted = true; break end
                                                    end
                                                end
                                                if not interacted then
                                                    local clickDetector = npc:FindFirstChildOfClass("ClickDetector")
                                                    if clickDetector then fireclickdetector(clickDetector); interacted = true end
                                                end
                                                if interacted then break end
                                            end
                                        end
                                    end
                                end)
                            end
                        end)
                    end
                end
            })

            local Players = game:GetService("Players")
            local Workspace = game:GetService("Workspace")
            local LocalPlayer = Players.LocalPlayer

            _G.SkinwalkerDetected = false

            local function GetCharacter()
                return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            end

            local function GetRootPart()
                local char = GetCharacter()
                return char and char:FindFirstChild("HumanoidRootPart")
            end

            local function IsAnimalSkinwalker(animal)
                if not animal then return false end
                local name = string.lower(animal.Name)
                if string.find(name, "skinwalker") or string.find(name, "infected") or string.find(name, "cursed") then return true end
                
                for attrName, attrValue in pairs(animal:GetAttributes()) do
                    if (string.lower(attrName):find("skinwalker") or string.lower(attrName):find("infected")) and attrValue == true then
                        return true
                    end
                end
                
                local humanoid = animal:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    local disp = string.lower(humanoid.DisplayName or "")
                    if string.find(disp, "skinwalker") or string.find(disp, "infected") then return true end
                end
                
                for _, desc in ipairs(animal:GetChildren()) do
                    if (desc:IsA("BillboardGui") or desc:IsA("SelectionBox")) and string.find(string.lower(desc.Name or ""), "skinwalker") then
                        return true
                    end
                    if desc:IsA("ObjectValue") and desc.Name == "Skinwalker" then return true end
                end
                return false
            end

            local function UpdateSkinwalkerStatus()
                local npcs = Workspace:FindFirstChild("NPCs")
                if npcs then
                    for _, animal in ipairs(npcs:GetChildren()) do
                        if animal:IsA("Model") and IsAnimalSkinwalker(animal) then
                            _G.SkinwalkerDetected = true
                            return
                        end
                    end
                end
                
                local playersFolder = Workspace:FindFirstChild("Players") or Players
                for _, p in ipairs(playersFolder:GetChildren()) do
                    if p:IsA("Player") and p.Character then
                        local char = p.Character
                        if char:FindFirstChild("Skinwalker") or char:GetAttribute("Skinwalker") then
                            _G.SkinwalkerDetected = true
                            return
                        end
                    end
                end
                
                _G.SkinwalkerDetected = false
            end

            local function StartSkinwalkerMonitor()
                task.spawn(function()
                    while _G.APW_AutoFrontDesk do
                        pcall(UpdateSkinwalkerStatus)
                        task.wait(0.5)
                    end
                    _G.SkinwalkerDetected = false
                end)
            end

            local function APW_AutoFrontDeskLoop()
                StartSkinwalkerMonitor()
                
                task.spawn(function()
                    while _G.APW_AutoFrontDesk do
                        task.wait(0.1)
                        pcall(function()
                            local character = GetCharacter()
                            local rootPart = GetRootPart()
                            if not character or not rootPart then return end
                            if _G.SkinwalkerDetected then return end
                            
                            local checkIn = Workspace:FindFirstChild("Misc") and Workspace.Misc:FindFirstChild("CheckIn")
                            if not checkIn then return end
                            
                            local computer = checkIn:FindFirstChild("Computer")
                            if computer and hasEnabledPrompt(computer) then
                                local pos = getPosition(computer)
                                if pos then
                                    if _G.SkinwalkerDetected then return end
                                    safeTeleport(pos)
                                    if interactWithObject(computer) then return end
                                end
                            end
                            
                            local objects = {"PrintedBadge", "Printer", "Camera", "Form"}
                            for _, name in ipairs(objects) do
                                if not _G.APW_AutoFrontDesk then break end
                                if _G.SkinwalkerDetected then break end
                                
                                local obj = checkIn:FindFirstChild(name)
                                if obj and hasEnabledPrompt(obj) then
                                    local pos = getPosition(obj)
                                    if pos then
                                        if _G.SkinwalkerDetected then break end
                                        safeTeleport(pos)
                                        if interactWithObject(obj) then return end
                                    end
                                end
                            end
                        end)
                    end
                end)
            end

            APWTab:Toggle({
                Title = "自动前台",
                Default = false,
                Callback = function(state)
                    _G.APW_AutoFrontDesk = state
                    WindUI:Notify({Title = "自动前台", Content = state and "已开启" or "已关闭", Duration = 3})
                    if state then APW_AutoFrontDeskLoop() end
                end
            })

            local Players = game:GetService("Players")
            local Workspace = game:GetService("Workspace")
            local RunService = game:GetService("RunService")
            local LocalPlayer = Players.LocalPlayer

            local Config = { AutoClearExtra = false }
            local clearThread = nil
            local ProtectedKeywords = { "gun", "pistol", "revolver", "rifle", "taser", "stun", "coffee", "drink", "food" }

            local function GetCharacter()
                return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            end

            local function GetHumanoid()
                local char = GetCharacter()
                return char and char:FindFirstChildOfClass("Humanoid")
            end

            local function GetRootPart()
                local char = GetCharacter()
                return char and char:FindFirstChild("HumanoidRootPart")
            end

            local function FindBasePartInObject(obj)
                if not obj then return nil end
                if obj:IsA("BasePart") then return obj end
                for _, child in ipairs(obj:GetChildren()) do
                    if child:IsA("BasePart") then return child end
                    if child:IsA("Model") then
                        local part = FindBasePartInObject(child)
                        if part then return part end
                    end
                end
                return nil
            end

            local function SafeTeleport(targetPart)
                local root = GetRootPart()
                if not root or not targetPart then return end
                
                pcall(function()
                    root.Velocity = Vector3.new(0, 0, 0)
                    root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                    
                    local targetPos = targetPart.Position
                    local safeOffsetPos = targetPos + Vector3.new(4, 2, 0)
                    
                    root.CFrame = CFrame.lookAt(safeOffsetPos, targetPos)
                    root.Anchored = true
                    
                    task.wait(0.05)
                    
                    root.Velocity = Vector3.new(0, 0, 0)
                    root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    root.Anchored = false
                    
                    local hum = GetHumanoid()
                    if hum then 
                        hum:ChangeState(Enum.HumanoidStateType.Running) 
                    end
                end)
                task.wait(0.25)
            end

            local function FirePromptDirect(prompt)
                if not prompt or not prompt:IsA("ProximityPrompt") or not prompt.Enabled then return false end
                
                local success = false
                local s1 = pcall(function() fireproximityprompt(prompt) end)
                if s1 then success = true end
                
                if not success then
                    local s2 = pcall(function()
                        prompt:InputHoldStart(LocalPlayer)
                        task.wait(0.08)
                        prompt:InputHoldEnd(LocalPlayer)
                    end)
                    if s2 then success = true end
                end
                return success
            end

            local function FindInvInRoom(room)
                if not room then return nil end
                local minigame = room:FindFirstChild("Minigame")
                if minigame then
                    local tv = minigame:FindFirstChild("TV")
                    if tv then
                        local screen = tv:FindFirstChild("Screen")
                        if screen then
                            local ui = screen:FindFirstChild("UI")
                            if ui then
                                local report = ui:FindFirstChild("Report")
                                if report then return report:FindFirstChild("inv") end
                            end
                        end
                    end
                end
                return room:FindFirstChild("inv", true)
            end

            local function HasCheck(item)
                if not item then return false end
                local check = item:FindFirstChild("check")
                if check and check:IsA("ImageLabel") then return check.Visible == true end
                return false
            end

            local function GetAllRoomsDemands()
                local allDemands = {}
                local roomsFolder = Workspace:FindFirstChild("Rooms")
                if not roomsFolder then return allDemands end
                
                for roomNum = 1, 8 do
                    local room = nil
                    if roomNum >= 1 and roomNum <= 5 then
                        local medical = roomsFolder:FindFirstChild("Medical")
                        if medical then room = medical:FindFirstChild("Room" .. roomNum) end
                    elseif roomNum >= 6 and roomNum <= 8 then
                        local emergency = roomsFolder:FindFirstChild("Emergency")
                        if emergency then room = emergency:FindFirstChild("Room" .. roomNum) end
                    end
                    
                    if room then
                        local invPath = FindInvInRoom(room)
                        if invPath then
                            for _, child in ipairs(invPath:GetChildren()) do
                                if not child:IsA("UIGridLayout") and not child:IsA("UIListLayout") then
                                    if child.Name and child.Name ~= "" and not HasCheck(child) then
                                        allDemands[string.lower(child.Name)] = true
                                    end
                                end
                            end
                        end
                    end
                end
                return allDemands
            end

            local function GetExtraTools()
                local extraTools = {}
                local backpack = LocalPlayer:FindFirstChild("Backpack")
                local char = GetCharacter()
                local currentDemands = GetAllRoomsDemands()
                
                local function checkFolder(folder)
                    if not folder then return end
                    for _, tool in ipairs(folder:GetChildren()) do
                        if tool:IsA("Tool") then
                            local toolNameLower = string.lower(tool.Name)
                            local isProtected = false
                            
                            for _, keyword in ipairs(ProtectedKeywords) do
                                if string.find(toolNameLower, keyword) then
                                    isProtected = true
                                    break
                                end
                            end
                            
                            if not isProtected then
                                local isNeeded = false
                                for demandName, _ in pairs(currentDemands) do
                                    if string.find(toolNameLower, demandName) or string.find(demandName, toolNameLower) then
                                        isNeeded = true
                                        break
                                    end
                                end
                                
                                if not isNeeded then
                                    table.insert(extraTools, tool)
                                end
                            end
                        end
                    end
                end
                
                checkFolder(backpack)
                checkFolder(char)
                return extraTools
            end

            local function ClearExtraItemsLoop()
                local trash = Workspace:FindFirstChild("Trash")
                if not trash then return end
                
                local extraTools = GetExtraTools()
                if #extraTools == 0 then return end
                
                local prompt = trash:FindFirstChildWhichIsA("ProximityPrompt", true)
                local part = FindBasePartInObject(trash)
                
                if prompt and part then
                    for _, tool in ipairs(extraTools) do
                        if not Config.AutoClearExtra then break end
                        if not tool.Parent then continue end
                        
                        local backpack = LocalPlayer:FindFirstChild("Backpack")
                        local char = GetCharacter()
                        local hum = GetHumanoid()

                        SafeTeleport(part)
                        if hum and tool.Parent == backpack then
                            hum:EquipTool(tool)
                            task.wait(0.2)
                        end
                        
                        FirePromptDirect(prompt)
                        task.wait(0.8)
                        
                        if tool.Parent == backpack or tool.Parent == char then
                            SafeTeleport(part)
                            if hum and tool.Parent == backpack then
                                hum:EquipTool(tool)
                                task.wait(0.2)
                            end
                            FirePromptDirect(prompt)
                            task.wait(0.8)
                        end
                    end
                end
            end

            APWTab:Toggle({
                Title = "自动清理多余药物",
                Default = false,
                Callback = function(state)
                    Config.AutoClearExtra = state
                    
                    if clearThread then
                        task.cancel(clearThread)
                        clearThread = nil
                    end
                    
                    if state then
                        clearThread = task.spawn(function()
                            while Config.AutoClearExtra do
                                ClearExtraItemsLoop()
                                task.wait(1)
                            end
                        end)
                    end
                end
            })

            local Players = game:GetService("Players")
            local Workspace = game:GetService("Workspace")
            local RunService = game:GetService("RunService")
            local LocalPlayer = Players.LocalPlayer

            local Config = { AutoHeal = false }
            local ItemDebounce = {}
            local ItemCache = {}
            local CACHE_TIME = 0.5

            local ITEM_PICKUP_COOLDOWN = 1.2
            local TELEPORT_DELAY = 0.8
            local INTERACT_DELAY_NORMAL = 0.3
            local INTERACT_DELAY_HIGH = 0.5

            local isLoopRunning = false

            local ITEM_ALIAS_MAP = {
                ["ointment"] = {"ointment", "burn cream", "cream", "膏药", "烫伤膏", "药膏"},
                ["膏药"] = {"ointment", "burn cream", "cream", "膏药", "烫伤膏", "药膏"},
                ["烫伤膏"] = {"ointment", "burn cream", "cream", "膏药", "烫伤膏", "药膏"}
            }

            local function GetCharacter()
                return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            end

            local function GetHumanoid()
                local char = GetCharacter()
                return char and char:FindFirstChildOfClass("Humanoid")
            end

            local function GetRootPart()
                local char = GetCharacter()
                return char and char:FindFirstChild("HumanoidRootPart")
            end

            local function SetCharacterCollision(enabled)
                local char = GetCharacter()
                if not char then return end
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = enabled
                    end
                end
            end

            local function FindBasePartInObject(obj)
                if not obj then return nil end
                if obj:IsA("BasePart") then return obj end
                for _, child in ipairs(obj:GetChildren()) do
                    if child:IsA("BasePart") then return child end
                    if child:IsA("Model") then
                        local part = FindBasePartInObject(child)
                        if part then return part end
                    end
                end
                return nil
            end

            local function SafeTeleport(position)
                local root = GetRootPart()
                if not root then return end
                pcall(function()
                    SetCharacterCollision(false)
                    
                    root.Velocity = Vector3.new(0, 0, 0)
                    root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                    
                    root.CFrame = CFrame.new(position + Vector3.new(0, 2.2, 0))
                    root.Anchored = true
                    
                    RunService.Heartbeat:Wait()
                    
                    root.Velocity = Vector3.new(0, 0, 0)
                    root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    root.Anchored = false
                    
                    local hum = GetHumanoid()
                    if hum then 
                        hum:ChangeState(Enum.HumanoidStateType.Running) 
                    end
                    
                    task.wait(0.1)
                    SetCharacterCollision(true)
                end)
                task.wait(TELEPORT_DELAY)
            end

            local function FirePromptDirect(prompt)
                if not prompt or not prompt:IsA("ProximityPrompt") or not prompt.Enabled then return false end
                local targetPart = FindBasePartInObject(prompt.Parent)
                if targetPart then
                    pcall(function()
                        local root = GetRootPart()
                        if root then root.CFrame = CFrame.lookAt(root.Position, targetPart.Position) end
                    end)
                end
                local success = false
                local s1 = pcall(function() fireproximityprompt(prompt) end)
                if s1 then success = true end
                if not success then
                    local s2 = pcall(function()
                        prompt:InputHoldStart(LocalPlayer)
                        task.wait(0.08)
                        prompt:InputHoldEnd(LocalPlayer)
                    end)
                    if s2 then success = true end
                end
                return success
            end

            local function ForceClearCache()
                ItemCache = { Items = {}, Time = 0 }
            end

            local function GetPlayerItems()
                local items = {}
                local currentTime = tick()
                
                if ItemCache.Time and (currentTime - ItemCache.Time) < CACHE_TIME then
                    return ItemCache.Items
                end
                
                local backpack = LocalPlayer:FindFirstChild("Backpack")
                if backpack then
                    for _, tool in ipairs(backpack:GetChildren()) do
                        if tool:IsA("Tool") then
                            items[string.lower(tool.Name)] = true
                        end
                    end
                end
                
                local char = GetCharacter()
                if char then
                    for _, tool in ipairs(char:GetChildren()) do
                        if tool:IsA("Tool") then
                            items[string.lower(tool.Name)] = true
                        end
                    end
                end
                
                ItemCache.Items = items
                ItemCache.Time = currentTime
                
                return items
            end

            local function HasItem(itemName)
                if not itemName or itemName == "" then return false end
                ForceClearCache()
                local items = GetPlayerItems()
                local targetLower = string.lower(itemName)
                
                if items[targetLower] then return true end
                
                local aliases = ITEM_ALIAS_MAP[targetLower]
                if aliases then
                    for _, alias in ipairs(aliases) do
                        if items[alias] then return true end
                    end
                end
                
                for itemKey, _ in pairs(items) do
                    if string.find(itemKey, targetLower) or string.find(targetLower, itemKey) then
                        return true
                    end
                end
                
                return false
            end

            local function EquipToolFast(itemName)
                local itemNameLower = string.lower(itemName)
                local backpack = LocalPlayer:FindFirstChild("Backpack")
                local hum = GetHumanoid()
                
                local searchList = {itemNameLower}
                if ITEM_ALIAS_MAP[itemNameLower] then
                    for _, alias in ipairs(ITEM_ALIAS_MAP[itemNameLower]) do
                        table.insert(searchList, alias)
                    end
                end
                
                if backpack and hum then
                    for _, tool in ipairs(backpack:GetChildren()) do
                        if tool:IsA("Tool") then
                            local toolName = string.lower(tool.Name)
                            for _, searchStr in ipairs(searchList) do
                                if string.find(toolName, searchStr) then
                                    hum:EquipTool(tool)
                                    task.wait(0.15)
                                    return true
                                end
                            end
                        end
                    end
                end
                return false
            end

            local function FindInvInRoom(room)
                if not room then return nil end
                local minigame = room:FindFirstChild("Minigame")
                if minigame then
                    local tv = minigame:FindFirstChild("TV")
                    if tv then
                        local screen = tv:FindFirstChild("Screen")
                        if screen then
                            local ui = screen:FindFirstChild("UI")
                            if ui then
                                local report = ui:FindFirstChild("Report")
                                if report then return report:FindFirstChild("inv") end
                            end
                        end
                    end
                end
                return room:FindFirstChild("inv", true)
            end

            local function FindInBedInRoom(room)
                if not room then return nil end
                local minigame = room:FindFirstChild("Minigame")
                if minigame then
                    local bed = minigame:FindFirstChild("Bed")
                    if bed then return bed:FindFirstChild("InBed") end
                end
                return room:FindFirstChild("InBed")
            end

            local function HasCheck(item)
                if not item then return false end
                local check = item:FindFirstChild("check")
                if check and check:IsA("ImageLabel") then return check.Visible == true end
                return false
            end

            local function GetItemsFromInv(invFolder)
                local itemsNeeded = {}
                if not invFolder then return itemsNeeded end
                for _, child in ipairs(invFolder:GetChildren()) do
                    if not child:IsA("UIGridLayout") and not child:IsA("UIListLayout") then
                        if child.Name and child.Name ~= "" and not HasCheck(child) then
                            table.insert(itemsNeeded, string.lower(child.Name))
                        end
                    end
                end
                return itemsNeeded
            end

            local function GetCachedItemPrompt(itemName)
                if not itemName or itemName == "" then return nil end
                local target = string.lower(itemName)
                
                local searchTerms = {target}
                if ITEM_ALIAS_MAP[target] then
                    for _, alias in ipairs(ITEM_ALIAS_MAP[target]) do
                        table.insert(searchTerms, alias)
                    end
                end
                
                for _, desc in ipairs(Workspace:GetDescendants()) do
                    if desc:IsA("ProximityPrompt") and desc.Enabled then
                        local actionText = desc.ActionText and string.lower(desc.ActionText) or ""
                        local objectText = desc.ObjectText and string.lower(desc.ObjectText) or ""
                        local parentName = desc.Parent and string.lower(desc.Parent.Name) or ""
                        
                        for _, term in ipairs(searchTerms) do
                            if string.find(actionText, term) or string.find(objectText, term) or string.find(parentName, term) then
                                return desc
                            end
                        end
                    end
                end
                return nil
            end

            local function GetRoomFolder(roomNum)
                local roomsFolder = Workspace:FindFirstChild("Rooms")
                if not roomsFolder then return nil end
                
                if roomNum >= 1 and roomNum <= 5 then
                    local medical = roomsFolder:FindFirstChild("Medical")
                    if medical then return medical:FindFirstChild("Room" .. roomNum) end
                elseif roomNum >= 6 and roomNum <= 8 then
                    local emergency = roomsFolder:FindFirstChild("Emergency")
                    if emergency then return emergency:FindFirstChild("Room" .. roomNum) end
                end
                return nil
            end

            local function GetDeliverPrompt(room, roomNum)
                local promptToDeliver = nil
                local deliverPosition = nil
                
                if roomNum >= 1 and roomNum <= 5 then
                    local bedPath = FindInBedInRoom(room)
                    if bedPath then
                        for _, desc in ipairs(bedPath:GetDescendants()) do
                            if desc:IsA("ProximityPrompt") and desc.Enabled then
                                promptToDeliver = desc
                                break
                            end
                        end
                        if not promptToDeliver then
                            for _, desc in ipairs(bedPath.Parent:GetDescendants()) do
                                if desc:IsA("ProximityPrompt") and desc.Enabled then
                                    promptToDeliver = desc
                                    break
                                end
                            end
                        end
                        deliverPosition = bedPath.Position
                    end
                elseif roomNum >= 6 and roomNum <= 8 then
                    for _, desc in ipairs(room:GetDescendants()) do
                        if desc:IsA("ProximityPrompt") and desc.Enabled and desc.Parent.Name == "InBed" then
                            promptToDeliver = desc
                            deliverPosition = desc.Parent.Position
                            break
                        end
                    end
                    if not promptToDeliver then
                        local npcsFolder = Workspace:FindFirstChild("NPCs")
                        if npcsFolder then
                            for _, npc in ipairs(npcsFolder:GetChildren()) do
                                local pp = npc:FindFirstChild("PP")
                                if pp and pp:IsA("ProximityPrompt") and pp.Enabled and string.find(string.lower(pp.ActionText or ""), "treatment") then
                                    promptToDeliver = pp
                                    local bp = FindBasePartInObject(npc)
                                    deliverPosition = bp and bp.Position
                                    break
                                end
                            end
                        end
                    end
                end
                
                return promptToDeliver, deliverPosition
            end

            local function CollectItem(itemName, isHighRiskRoom)
                if HasItem(itemName) then return true end

                local prompt = GetCachedItemPrompt(itemName)
                if not prompt or not prompt.Enabled then return false end
                
                local lastPickup = ItemDebounce[prompt] or 0
                if os.clock() - lastPickup < ITEM_PICKUP_COOLDOWN then return false end
                
                local part = FindBasePartInObject(prompt.Parent)
                if not part then return false end
                
                ItemDebounce[prompt] = os.clock()
                SafeTeleport(part.Position)
                FirePromptDirect(prompt)
                
                local delay = isHighRiskRoom and INTERACT_DELAY_HIGH or INTERACT_DELAY_NORMAL
                task.wait(delay)
                
                return HasItem(itemName)
            end

            local function DeliverItem(itemName, promptToDeliver, isHighRiskRoom)
                if not HasItem(itemName) then return false end
                
                EquipToolFast(itemName)
                task.wait(0.1)
                
                for i = 1, 2 do
                    if FirePromptDirect(promptToDeliver) then
                        local delay = isHighRiskRoom and INTERACT_DELAY_HIGH or INTERACT_DELAY_NORMAL
                        task.wait(delay)
                        return true
                    end
                    task.wait(0.08)
                end
                return false
            end

            local function HealRoomFast(roomNum)
                local room = GetRoomFolder(roomNum)
                if not room then return false end
                
                local invPath = FindInvInRoom(room)
                if not invPath then return false end
                
                local itemsNeeded = GetItemsFromInv(invPath)
                if #itemsNeeded == 0 then return false end
                
                local promptToDeliver, deliverPosition = GetDeliverPrompt(room, roomNum)
                if not promptToDeliver or not deliverPosition then return false end
                
                local isHighRiskRoom = (roomNum >= 6 and roomNum <= 8)
                
                ForceClearCache()
                local playerItems = GetPlayerItems()
                
                for _, itemName in ipairs(itemsNeeded) do
                    if not HasItem(itemName) then
                        CollectItem(itemName, isHighRiskRoom)
                        task.wait(0.1)
                    end
                end
                
                SafeTeleport(deliverPosition)
                
                local finalDemands = GetItemsFromInv(invPath)
                if #finalDemands == 0 then return false end
                
                for _, itemName in ipairs(finalDemands) do
                    if HasItem(itemName) then
                        DeliverItem(itemName, promptToDeliver, isHighRiskRoom)
                    end
                end
                
                return true
            end

            local function StartAutoHealLoop()
                if isLoopRunning then return end
                isLoopRunning = true
                
                task.spawn(function()
                    while Config.AutoHeal do
                        for roomNum = 1, 7 do
                            if not Config.AutoHeal then break end
                            HealRoomFast(roomNum)
                            task.wait(0.1)
                        end
                        task.wait(0.2)
                    end
                    isLoopRunning = false
                end)
            end

            APWTab:Toggle({
                Title = "自动治疗1-7",
                Default = false,
                Callback = function(state)
                    Config.AutoHeal = state
                    if state then
                        ForceClearCache()
                        StartAutoHealLoop()
                    end
                end
            })

            local Workspace = game:GetService("Workspace")
            local RunService = game:GetService("RunService")
            local LocalPlayer = game:GetService("Players").LocalPlayer

            local HealConfig = { AutoHeal = false }
            local HealDebounce = {}
            local HealCache = { Items = {}, Time = 0 }

            local function HealGetItems()
                local items = {}
                if (tick() - HealCache.Time) < 0.5 then return HealCache.Items end
                local bp = LocalPlayer:FindFirstChild("Backpack")
                if bp then
                    for _, t in ipairs(bp:GetChildren()) do if t:IsA("Tool") then items[string.lower(t.Name)] = true end end
                end
                local char = LocalPlayer.Character
                if char then
                    for _, t in ipairs(char:GetChildren()) do if t:IsA("Tool") then items[string.lower(t.Name)] = true end end
                end
                HealCache.Items = items; HealCache.Time = tick()
                return items
            end

            local function HealHasItem(name)
                HealCache = { Items = {}, Time = 0 }
                return HealGetItems()[string.lower(name)] == true
            end

            local function HealSafeTP(pos)
                local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if not root then return end
                pcall(function()
                    for _, p in ipairs(LocalPlayer.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
                    root.Velocity = Vector3.zero; root.AssemblyLinearVelocity = Vector3.zero
                    root.CFrame = CFrame.new(pos + Vector3.new(0, 2.2, 0))
                    root.Anchored = true; RunService.Heartbeat:Wait()
                    root.Anchored = false
                    local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                    if hum then hum:ChangeState(Enum.HumanoidStateType.Running) end
                    task.wait(0.1)
                    for _, p in ipairs(LocalPlayer.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = true end end
                end)
                task.wait(0.6)
            end

            local function HealFire(prompt)
                if not prompt or not prompt.Enabled then return false end
                pcall(function()
                    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if root and prompt.Parent:IsA("BasePart") then root.CFrame = CFrame.lookAt(root.Position, prompt.Parent.Position) end
                end)
                local s = pcall(function() fireproximityprompt(prompt) end)
                if not s then
                    pcall(function()
                        prompt:InputHoldStart(LocalPlayer)
                        task.wait(0.08)
                        prompt:InputHoldEnd(LocalPlayer)
                    end)
                end
                return true
            end

            local function HealGetPrompt(name)
                local t = string.lower(name)
                for _, d in ipairs(Workspace:GetDescendants()) do
                    if d:IsA("ProximityPrompt") and d.Enabled and d.ActionText and (string.find(string.lower(d.ActionText), t) or string.find(t, string.lower(d.ActionText))) then
                        return d
                    end
                end
                return nil
            end

            local function HealRoom8()
                local rf = Workspace:FindFirstChild("Rooms")
                local em = rf and rf:FindFirstChild("Emergency")
                local room = em and em:FindFirstChild("Room8")
                if not room then return end
                
                local mg = room:FindFirstChild("Minigame")
                local tv = mg and mg:FindFirstChild("TV")
                local scr = tv and tv:FindFirstChild("Screen")
                local ui = scr and scr:FindFirstChild("UI")
                local rep = ui and ui:FindFirstChild("Report")
                local inv = rep and rep:FindFirstChild("inv") or room:FindFirstChild("inv", true)
                if not inv then return end
                
                local needed = {}
                for _, c in ipairs(inv:GetChildren()) do
                    if not c:IsA("UIGridLayout") and not c:IsA("UIListLayout") and c.Name ~= "" then
                        local chk = c:FindFirstChild("check")
                        if not (chk and chk:IsA("ImageLabel") and chk.Visible) then table.insert(needed, string.lower(c.Name)) end
                    end
                end
                if #needed == 0 then return end
                
                local pd, dp = nil, nil
                local bed = mg and mg:FindFirstChild("Bed") or room:FindFirstChild("Bed", true)
                local ib = bed and bed:FindFirstChild("InBed") or room:FindFirstChild("InBed", true)
                if ib then
                    for _, d in ipairs(ib:GetDescendants()) do if d:IsA("ProximityPrompt") and d.Enabled then pd = d; dp = ib.Position; break end end
                end
                if not pd or not dp then return end
                
                for _, item in ipairs(needed) do
                    if not HealConfig.AutoHeal then return end
                    if not HealHasItem(item) then
                        local p = HealGetPrompt(item)
                        if p and p.Enabled and (os.clock() - (HealDebounce[p] or 0) > 1.0) and p.Parent:IsA("BasePart") then
                            HealDebounce[p] = os.clock()
                            HealSafeTP(p.Parent.Position)
                            task.wait(0.2); HealFire(p); task.wait(0.4)
                            if not HealHasItem(item) then HealSafeTP(p.Parent.Position); task.wait(0.2); HealFire(p); task.wait(0.6) end
                        end
                    end
                end
                
                if not HealConfig.AutoHeal then return end
                HealSafeTP(dp); task.wait(0.3)
                
                for _, item in ipairs(needed) do
                    if not HealConfig.AutoHeal then return end
                    if HealHasItem(item) then
                        local bp = LocalPlayer:FindFirstChild("Backpack")
                        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                        if bp and hum then
                            for _, tool in ipairs(bp:GetChildren()) do
                                if tool:IsA("Tool") and string.find(string.lower(tool.Name), item) then hum:EquipTool(tool); task.wait(0.15); break end
                            end
                        end
                        HealFire(pd); task.wait(0.4)
                    end
                end
            end

            APWTab:Toggle({
                Title = "自动手术",
                Default = false,
                Callback = function(state)
                    HealConfig.AutoHeal = state
                    if state then
                        task.spawn(function()
                            while HealConfig.AutoHeal do
                                pcall(HealRoom8)
                                task.wait(0.5)
                            end
                        end)
                    end
                end
            })

            task.spawn(function()
                local Players = game:GetService("Players")
                local Workspace = game:GetService("Workspace")
                local RunService = game:GetService("RunService")
                local LocalPlayer = Players.LocalPlayer

                local KillConfig = { AutoKillSkinwalker = false }
                local KillDebounce = {}
                local KillCache = { Items = {}, Time = 0 }

                local function KillGetItems()
                    local items = {}
                    if (tick() - KillCache.Time) < 0.5 then return KillCache.Items end
                    local bp = LocalPlayer:FindFirstChild("Backpack")
                    if bp then
                        for _, t in ipairs(bp:GetChildren()) do if t:IsA("Tool") then items[string.lower(t.Name)] = true end end
                    end
                    local char = LocalPlayer.Character
                    if char then
                        for _, t in ipairs(char:GetChildren()) do if t:IsA("Tool") then items[string.lower(t.Name)] = true end end
                    end
                    KillCache.Items = items; KillCache.Time = tick()
                    return items
                end

                local function KillHasItem(name)
                    KillCache = { Items = {}, Time = 0 }
                    return KillGetItems()[string.lower(name)] == true
                end

                local function KillSafeTP(pos)
                    local char = LocalPlayer.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    if not root then return end
                    pcall(function()
                        for _, p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
                        root.Velocity = Vector3.zero; root.AssemblyLinearVelocity = Vector3.zero
                        root.CFrame = CFrame.new(pos + Vector3.new(0, 2.2, 0))
                        root.Anchored = true; RunService.Heartbeat:Wait()
                        root.Anchored = false
                        local hum = char:FindFirstChildOfClass("Humanoid")
                        if hum then hum:ChangeState(Enum.HumanoidStateType.Running) end
                        task.wait(0.1)
                        for _, p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = true end end
                    end)
                    task.wait(0.8)
                end

                local function KillFire(prompt)
                    if not prompt or not prompt.Enabled then return false end
                    pcall(function()
                        local char = LocalPlayer.Character
                        local root = char and char:FindFirstChild("HumanoidRootPart")
                        if root and prompt.Parent:IsA("BasePart") then root.CFrame = CFrame.lookAt(root.Position, prompt.Parent.Position) end
                    end)
                    local s = pcall(function() fireproximityprompt(prompt) end)
                    if not s then
                        pcall(function()
                            prompt:InputHoldStart(LocalPlayer)
                            task.wait(0.08)
                            prompt:InputHoldEnd(LocalPlayer)
                        end)
                    end
                    return true
                end

                local function FindBasePartInObject(obj)
                    if not obj then return nil end
                    if obj:IsA("BasePart") then return obj end
                    for _, child in ipairs(obj:GetChildren()) do
                        if child:IsA("BasePart") then return child end
                        local res = FindBasePartInObject(child)
                        if res then return res end
                    end
                    return nil
                end

                local function FindInvInRoom(room)
                    if not room then return nil end
                    local mg = room:FindFirstChild("Minigame")
                    local tv = mg and mg:FindFirstChild("TV")
                    local scr = tv and tv:FindFirstChild("Screen")
                    local ui = scr and scr:FindFirstChild("UI")
                    local rep = ui and ui:FindFirstChild("Report")
                    return rep and rep:FindFirstChild("inv") or room:FindFirstChild("inv", true)
                end

                local function FindInBedInRoom(room)
                    if not room then return nil end
                    local mg = room:FindFirstChild("Minigame")
                    local bed = mg and mg:FindFirstChild("Bed")
                    return bed and bed:FindFirstChild("InBed") or room:FindFirstChild("InBed", true)
                end

                local function IsAnimalSkinwalker(animal)
                    if not animal then return false end
                    local name = string.lower(animal.Name)
                    if string.find(name, "skinwalker") or string.find(name, "infected") or string.find(name, "cursed") then return true end
                    for k, v in pairs(animal:GetAttributes()) do
                        if (string.lower(k):find("skinwalker") or string.lower(k):find("infected")) and v == true then return true end
                    end
                    local hum = animal:FindFirstChildOfClass("Humanoid")
                    if hum and (string.find(string.lower(hum.DisplayName or ""), "skinwalker") or string.find(string.lower(hum.DisplayName or ""), "infected")) then return true end
                    for _, d in ipairs(animal:GetDescendants()) do
                        if (d:IsA("BillboardGui") or d:IsA("SelectionBox")) and string.find(string.lower(d.Name or ""), "skinwalker") then return true end
                        if d:IsA("ObjectValue") and d.Name == "Skinwalker" then return true end
                    end
                    return false
                end

                local function GetRoomSkinwalkerNPC(room, roomNum)
                    if roomNum >= 1 and roomNum <= 5 then
                        local ib = FindInBedInRoom(room)
                        if ib and ib.Parent and IsAnimalSkinwalker(ib.Parent) then return ib.Parent end
                    elseif roomNum >= 6 and roomNum <= 8 then
                        local mg = room:FindFirstChild("Minigame")
                        if mg then
                            for _, c in ipairs(mg:GetChildren()) do
                                if c:IsA("Model") and c:FindFirstChildOfClass("Humanoid") and IsAnimalSkinwalker(c) then return c end
                            end
                        end
                        local npcs = Workspace:FindFirstChild("NPCs")
                        if npcs then
                            for _, npc in ipairs(npcs:GetChildren()) do
                                local pp = npc:FindFirstChild("PP")
                                if pp and pp:IsA("ProximityPrompt") and pp.Enabled and string.find(string.lower(pp.ActionText or ""), "treatment") and IsAnimalSkinwalker(npc) then
                                    return npc
                                end
                            end
                        end
                    end
                    return nil
                end

                local function GetCachedWrongPrompt(correctName)
                    local list = {"pill", "bandage", "medkit", "injection", "splint", "blood"}
                    local wrong = nil
                    for _, v in ipairs(list) do if v ~= string.lower(correctName) then wrong = v; break end end
                    if not wrong then return nil, nil end
                    for _, d in ipairs(Workspace:GetDescendants()) do
                        if d:IsA("ProximityPrompt") and d.Enabled and d.ActionText and string.find(string.lower(d.ActionText), wrong) then
                            return d, wrong
                        end
                    end
                    return nil, nil
                end

                local function CollectWrongItem(correctName, risk)
                    local p, wrongName = GetCachedWrongPrompt(correctName)
                    if not p or not p.Enabled then return nil end
                    if KillHasItem(wrongName) then return wrongName end
                    if os.clock() - (KillDebounce[p] or 0) < 1.2 then return nil end
                    local part = FindBasePartInObject(p.Parent)
                    if not part then return nil end
                    KillDebounce[p] = os.clock()
                    KillSafeTP(part.Position)
                    KillFire(p)
                    task.wait(risk and 0.5 or 0.3)
                    return KillHasItem(wrongName) and wrongName or nil
                end

                local function GetRoomFolder(roomNum)
                    local rf = Workspace:FindFirstChild("Rooms")
                    if not rf then return nil end
                    if roomNum >= 1 and roomNum <= 5 then
                        local md = rf:FindFirstChild("Medical")
                        return md and md:FindFirstChild("Room" .. roomNum)
                    elseif roomNum >= 6 and roomNum <= 8 then
                        local em = rf:FindFirstChild("Emergency")
                        return em and em:FindFirstChild("Room" .. roomNum)
                    end
                    return nil
                end

                local function GetDeliverPrompt(room, roomNum, npc)
                    local pd, dp = nil, nil
                    if roomNum >= 1 and roomNum <= 5 then
                        local ib = FindInBedInRoom(room)
                        if ib then
                            for _, d in ipairs(ib:GetDescendants()) do if d:IsA("ProximityPrompt") and d.Enabled then pd = d; break end end
                            dp = ib.Position
                        end
                    elseif roomNum >= 6 and roomNum <= 8 then
                        if npc then
                            local pp = npc:FindFirstChild("PP") or npc:FindFirstChildOfClass("ProximityPrompt")
                            if pp and pp.Enabled then
                                pd = pp
                                local bp = FindBasePartInObject(npc)
                                dp = bp and bp.Position
                            end
                        end
                        if not pd then
                            for _, d in ipairs(room:GetDescendants()) do
                                if d:IsA("ProximityPrompt") and d.Enabled and d.Parent.Name == "InBed" then
                                    pd = d; dp = d.Parent.Position; break
                                end
                            end
                        end
                    end
                    return pd, dp
                end

                local function DeliverItem(itemName, pd, risk)
                    if not KillHasItem(itemName) then return false end
                    local bp = LocalPlayer:FindFirstChild("Backpack")
                    local char = LocalPlayer.Character
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    if bp and hum then
                        for _, t in ipairs(bp:GetChildren()) do
                            if t:IsA("Tool") and string.find(string.lower(t.Name), string.lower(itemName)) then hum:EquipTool(t); task.wait(0.1); break end
                        end
                    end
                    for i = 1, 2 do
                        if KillFire(pd) then
                            task.wait(risk and 0.5 or 0.3)
                            return true
                        end
                        task.wait(0.08)
                    end
                    return false
                end

                local function KillSkinwalkerInRoom(roomNum)
                    local room = GetRoomFolder(roomNum)
                    if not room then return false end
                    local npc = GetRoomSkinwalkerNPC(room, roomNum)
                    if not npc then return false end
                    local inv = FindInvInRoom(room)
                    if not inv then return false end
                    local needed = {}
                    for _, c in ipairs(inv:GetChildren()) do
                        if not c:IsA("UIGridLayout") and not c:IsA("UIListLayout") and c.Name ~= "" then
                            local chk = c:FindFirstChild("check")
                            if not (chk and chk:IsA("ImageLabel") and chk.Visible) then table.insert(needed, string.lower(c.Name)) end
                        end
                    end
                    if #needed == 0 then return false end
                    local pd, dp = GetDeliverPrompt(room, roomNum, npc)
                    if not pd or not dp then return false end
                    local risk = (roomNum >= 6 and roomNum <= 8)
                    local wrongItem = CollectWrongItem(needed[1], risk)
                    if not wrongItem then return false end
                    KillSafeTP(dp)
                    DeliverItem(wrongItem, pd, risk)
                    return true
                end

                APWTab:Toggle({
                    Title = "自动杀异常[治疗杀]",
                    Default = false,
                    Callback = function(state)
                        KillConfig.AutoKillSkinwalker = state
                        if state then
                            task.spawn(function()
                                while KillConfig.AutoKillSkinwalker do
                                    for roomNum = 1, 8 do
                                        if not KillConfig.AutoKillSkinwalker then break end
                                        pcall(KillSkinwalkerInRoom, roomNum)
                                        task.wait(0.1)
                                    end
                                    task.wait(0.2)
                                end
                            end)
                        end
                    end
                })
            end)

            local Players = game:GetService("Players")
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            local Config = { AutoVoteOnShift = false, TargetShift = 2 }
            local attributeConnection = nil

            local function TriggerPlayAgainVote()
                pcall(function()
                    local util = ReplicatedStorage:FindFirstChild("Util")
                    local net = util and util:FindFirstChild("Net")
                    local remote = net and net:FindFirstChild("RE/PlayAgainVote")
                    if remote and remote:IsA("RemoteEvent") then
                        remote:FireServer()
                    end
                end)
            end

            local function StartShiftMonitoring()
                if attributeConnection then
                    attributeConnection:Disconnect()
                    attributeConnection = nil
                end

                attributeConnection = Players:GetAttributeChangedSignal("Night"):Connect(function()
                    local currentNight = Players:GetAttribute("Night")
                    if currentNight == Config.TargetShift then
                        task.wait(1.5)
                        TriggerPlayAgainVote()
                    end
                end)

                local initialNight = Players:GetAttribute("Night")
                if initialNight == Config.TargetShift then
                    TriggerPlayAgainVote()
                end
            end

            local function StopShiftMonitoring()
                if attributeConnection then
                    attributeConnection:Disconnect()
                    attributeConnection = nil
                end
            end

            APWTab:Toggle({
                Title = "自动轮班",
                Default = false,
                Callback = function(state)
                    Config.AutoVoteOnShift = state
                    if state then
                        StartShiftMonitoring()
                    else
                        StopShiftMonitoring()
                    end
                end
            })

            APWTab:Slider({
                Title = "自定义轮班",
                Value = {
                    Min = 2,
                    Max = 100,
                    Default = 10,
                },
                Increment = 1,
                Callback = function(value)
                    Config.TargetShift = value
                    if Config.AutoVoteOnShift then
                        StopShiftMonitoring()
                        StartShiftMonitoring()
                    end
                end
            })

            local skinwalkerCheckEnabled = false
            local checkThread = nil
            local isInteracting = false
            local currentShutterState = false

            local function FindShutterPrompt()
                for _, desc in ipairs(Workspace:GetDescendants()) do
                    if desc:IsA("ProximityPrompt") and desc.Enabled and string.find(string.lower(desc.Parent.Name), "shutter") then
                        return desc, desc.Parent
                    end
                end
                local misc = Workspace:FindFirstChild("Misc")
                local button = misc and misc:FindFirstChild("ShutterButton")
                if button then
                    for _, desc in ipairs(button:GetDescendants()) do
                        if desc:IsA("ProximityPrompt") and desc.Enabled then 
                            return desc, button 
                        end
                    end
                end
                return nil, nil
            end

            local function InteractWithShutter()
                if isInteracting then return false end
                isInteracting = true
                
                local prompt, button = FindShutterPrompt()
                if not prompt or not button then 
                    isInteracting = false
                    return false 
                end
                
                local targetPos = button:IsA("BasePart") and button.Position or (button:GetPivot() and button:GetPivot().Position)
                if targetPos then
                    safeTeleport(targetPos)
                    task.wait(0.15)
                    local success = FirePromptDirect(prompt)
                    task.wait(0.5)
                    isInteracting = false
                    return success
                end
                
                isInteracting = false
                return false
            end

            local function IsAnimalSkinwalker(animal)
                if not animal then return false end
                local name = string.lower(animal.Name)
                if string.find(name, "skinwalker") or string.find(name, "infected") or string.find(name, "cursed") then return true end
                
                for attrName, attrValue in pairs(animal:GetAttributes()) do
                    if (string.lower(attrName):find("skinwalker") or string.lower(attrName):find("infected")) and attrValue == true then
                        return true
                    end
                end
                
                local humanoid = animal:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    local disp = string.lower(humanoid.DisplayName or "")
                    if string.find(disp, "skinwalker") or string.find(disp, "infected") then return true end
                end
                
                for _, desc in ipairs(animal:GetDescendants()) do
                    if (desc:IsA("BillboardGui") or desc:IsA("SelectionBox")) and string.find(string.lower(desc.Name or ""), "skinwalker") then
                        return true
                    end
                    if desc:IsA("ObjectValue") and desc.Name == "Skinwalker" then return true end
                end
                return false
            end

            local function CheckForSkinwalkersAtBell()
                if isInteracting then return end
                
                local misc = Workspace:FindFirstChild("Misc")
                local checkIn = misc and misc:FindFirstChild("CheckIn")
                local bell = checkIn and checkIn:FindFirstChild("Bell")
                if not bell then return end
                
                local bellPos = bell:IsA("BasePart") and bell.Position or bell:GetPivot().Position
                local isNearBell = false
                local maxDistance = 12
                
                local scanTargets = {}
                local npcs = Workspace:FindFirstChild("NPCs")
                if npcs then
                    for _, v in ipairs(npcs:GetChildren()) do table.insert(scanTargets, v) end
                end
                for _, v in ipairs(Workspace:GetDescendants()) do
                    if v:IsA("Model") and v:FindFirstChildOfClass("Humanoid") then table.insert(scanTargets, v) end
                end
                
                for _, animal in ipairs(scanTargets) do
                    if IsAnimalSkinwalker(animal) then
                        local animalPos = animal:IsA("BasePart") and animal.Position or animal:GetPivot().Position
                        if animalPos and (animalPos - bellPos).Magnitude <= maxDistance then
                            isNearBell = true
                            break
                        end
                    end
                end
                
                if isNearBell and not currentShutterState then
                    if InteractWithShutter() then
                        currentShutterState = true
                    end
                elseif not isNearBell and currentShutterState then
                    if InteractWithShutter() then
                        currentShutterState = false
                    end
                end
            end

            local function EnableSkinwalkerCheck()
                if not skinwalkerCheckEnabled then
                    skinwalkerCheckEnabled = true
                    isInteracting = false
                    currentShutterState = false
                    
                    checkThread = task.spawn(function()
                        while skinwalkerCheckEnabled do
                            pcall(CheckForSkinwalkersAtBell)
                            task.wait(0.3)
                        end
                    end)
                end
            end

            local function DisableSkinwalkerCheck()
                if skinwalkerCheckEnabled then
                    skinwalkerCheckEnabled = false
                    if checkThread then checkThread = nil end
                    isInteracting = false
                    currentShutterState = false
                end
            end

            APWTab:Toggle({
                Title = "自动百叶窗",
                Default = false,
                Callback = function(state)
                    if state then EnableSkinwalkerCheck() else DisableSkinwalkerCheck() end
                end
            })

            local localPlayer = game.Players.LocalPlayer
            local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
            local rootPart = character:WaitForChild("HumanoidRootPart")

            localPlayer.CharacterAdded:Connect(function(char)
                character = char
                rootPart = char:WaitForChild("HumanoidRootPart")
            end)

            local function firePrompt(prompt)
                if not prompt or not prompt:IsA("ProximityPrompt") or not prompt.Enabled then return false end
                local targetPart = prompt.Parent:IsA("BasePart") and prompt.Parent or prompt.Parent:FindFirstChildOfClass("BasePart")
                if not targetPart and prompt.Parent:IsA("Model") then targetPart = prompt.Parent.PrimaryPart end
                
                if targetPart then
                    rootPart.CFrame = CFrame.new(targetPart.Position + Vector3.new(0, 1, 2))
                    task.wait(0.4)
                    
                    local success = false
                    local s1 = pcall(function() fireproximityprompt(prompt) end)
                    if s1 then success = true end
                    
                    if not success then
                        pcall(function()
                            prompt:InputHoldStart(localPlayer)
                            task.wait(prompt.HoldDuration > 0 and (prompt.HoldDuration + 0.1) or 0.1)
                            prompt:InputHoldEnd(localPlayer)
                        end)
                        success = true
                    end
                    task.wait(0.3)
                    return success
                end
                return false
            end

            local function interactWithObject(obj)
                if not obj then return false end
                if obj:IsA("ProximityPrompt") and obj.Enabled then
                    return firePrompt(obj)
                end
                for _, desc in pairs(obj:GetDescendants()) do
                    if desc:IsA("ProximityPrompt") and desc.Enabled then
                        if firePrompt(desc) then return true end
                    end
                end
                return false
            end

            local function handleSpecificRoomFire()
                local roomsFolder = workspace:FindFirstChild("Rooms")
                if not roomsFolder then return false end
                
                local targetRoom = nil
                
                for i = 1, 8 do
                    local roomName = "Room" .. i
                    local room = nil
                    
                    local medical = roomsFolder:FindFirstChild("Medical")
                    if medical then
                        room = medical:FindFirstChild(roomName)
                    end
                    
                    if not room then
                        local emergency = roomsFolder:FindFirstChild("Emergency")
                        if emergency then
                            room = emergency:FindFirstChild(roomName)
                        end
                    end
                    
                    if room then
                        for _, desc in pairs(room:GetDescendants()) do
                            if desc:IsA("ProximityPrompt") and desc.Enabled then
                                local actText = string.lower(desc.ActionText or "")
                                local objText = string.lower(desc.ObjectText or "")
                                if string.find(actText, "extinguish") or string.find(actText, "fire") or string.find(actText, "灭火") or string.find(objText, "fire") then
                                    targetRoom = room
                                    break
                                end
                            end
                        end
                    end
                    if targetRoom then break end
                end
                
                if targetRoom then
                    local extinguisher = workspace:FindFirstChild("FireExtinguisher") or workspace:FindFirstChild("Extinguisher")
                    if extinguisher then
                        interactWithObject(extinguisher)
                        task.wait(0.5)
                    end
                    
                    for _, desc in pairs(targetRoom:GetDescendants()) do
                        if desc:IsA("ProximityPrompt") and desc.Enabled then
                            local actText = string.lower(desc.ActionText or "")
                            local objText = string.lower(desc.ObjectText or "")
                            if string.find(actText, "extinguish") or string.find(actText, "fire") or string.find(actText, "灭火") or string.find(objText, "fire") then
                                return firePrompt(desc)
                            end
                        end
                    end
                end
                return false
            end

            APWTab:Toggle({
                Title = "自动灭火",
                Default = false,
                Callback = function(state)
                    _G.RoomAutoExtinguish = state
                    if state then
                        task.spawn(function()
                            while _G.RoomAutoExtinguish do
                                task.wait(0.1)
                                pcall(function()
                                    if character and rootPart then
                                        handleSpecificRoomFire()
                                    end
                                end)
                            end
                        end)
                    end
                end
            })

            local Players = game:GetService("Players")
            local Workspace = game:GetService("Workspace")
            local RunService = game:GetService("RunService")
            local LocalPlayer = Players.LocalPlayer

            local Config = {
                AutoCleanSlime = false,
                AutoRepairCameras = false
            }

            local isProcessing = false

            local function getCharacter()
                return LocalPlayer.Character
            end

            local function getRootPart()
                local char = getCharacter()
                return char and char:FindFirstChild("HumanoidRootPart")
            end

            local function getHumanoid()
                local char = getCharacter()
                return char and char:FindFirstChildOfClass("Humanoid")
            end

            local function findBasePartInObject(obj)
                if not obj then return nil end
                if obj:IsA("BasePart") then return obj end
                for _, child in ipairs(obj:GetChildren()) do
                    if child:IsA("BasePart") then return child end
                    if child:IsA("Model") then
                        local part = findBasePartInObject(child)
                        if part then return part end
                    end
                end
                return nil
            end

            local function safeTeleportAndInteract(part, prompt)
                local root = getRootPart()
                if not root or not part or not prompt or not prompt.Enabled then return false end
                
                local success = false
                pcall(function()
                    root.AssemblyLinearVelocity = Vector3.zero
                    root.AssemblyAngularVelocity = Vector3.zero
                    
                    local safeCFrame = part.CFrame * CFrame.new(0, 2, 2.5)
                    root.CFrame = CFrame.lookAt(safeCFrame.Position, part.Position)
                    
                    root.Anchored = true
                    task.wait(0.05)
                    root.Anchored = false
                    
                    if fireproximityprompt then
                        fireproximityprompt(prompt)
                        success = true
                    else
                        prompt:InputHoldStart(LocalPlayer)
                        task.wait(0.08)
                        prompt:InputHoldEnd(LocalPlayer)
                        success = true
                    end
                end)
                
                if root then
                    root.Anchored = false
                end
                
                return success
            end

            local function getSlime()
                local misc = Workspace:FindFirstChild("Misc")
                if not misc then return nil, nil end

                for _, v in ipairs(misc:GetChildren()) do
                    if v.Name == "Slime" then
                        local prompt = v:FindFirstChildOfClass("ProximityPrompt") or v:FindFirstChild("ProximityPrompt", true)
                        if prompt and prompt.Enabled then
                            return v, prompt
                        end
                    end
                end
                return nil, nil
            end

            local function cleanSlimeOnce()
                local slimeModel, prompt = getSlime()
                if not slimeModel or not prompt then return false end
                
                local basePart = findBasePartInObject(slimeModel)
                if not basePart then return false end
                
                return safeTeleportAndInteract(basePart, prompt)
            end

            local function getCameraFolders()
                local folders = {}
                local misc = Workspace:FindFirstChild("Misc")
                if misc then
                    local cameras = misc:FindFirstChild("Cameras")
                    if cameras then
                        table.insert(folders, cameras:FindFirstChild("Check-In"))
                        table.insert(folders, cameras:FindFirstChild("Medical"))
                        table.insert(folders, cameras:FindFirstChild("Lobby"))
                    end
                end
                local cameras2 = Workspace:FindFirstChild("Cameras2")
                if cameras2 then
                    table.insert(folders, cameras2:FindFirstChild("Emergency"))
                end
                return folders
            end

            local function repairCamerasOnce()
                local targetFolders = getCameraFolders()
                for _, folder in ipairs(targetFolders) do
                    if not folder or not Config.AutoRepairCameras then continue end
                    
                    for _, camera in ipairs(folder:GetChildren()) do
                        if not Config.AutoRepairCameras then break end
                        
                        local prompt = camera:FindFirstChildWhichIsA("ProximityPrompt", true)
                        if prompt and prompt.Enabled then
                            local part = findBasePartInObject(camera)
                            if part then
                                local done = safeTeleportAndInteract(part, prompt)
                                if done then
                                    task.wait(0.2)
                                    return true
                                end
                            end
                        end
                    end
                end
                return false
            end

            task.spawn(function()
                while true do
                    task.wait(0.1)
                    
                    if not isProcessing then
                        if Config.AutoCleanSlime then
                            isProcessing = true
                            cleanSlimeOnce()
                            isProcessing = false
                            task.wait(0.1)
                        elseif Config.AutoRepairCameras then
                            isProcessing = true
                            repairCamerasOnce()
                            isProcessing = false
                            task.wait(0.1)
                        end
                    end
                end
            end)

            APWTab:Toggle({
                Title = "自动清理粘液",
                Default = false,
                Callback = function(state)
                    Config.AutoCleanSlime = state
                end
            })

            APWTab:Toggle({
                Title = "自动修监控",
                Default = false,
                Callback = function(state)
                    Config.AutoRepairCameras = state
                end
            })

            APWTab:Section({Title = "小游戏", TextXAlignment = "Left", TextSize = 17})

            local heartbeatThread = nil

            local function AutoHeartbeat()
                local rooms = Workspace:FindFirstChild("Rooms")
                local emergency = rooms and rooms:FindFirstChild("Emergency")
                if not emergency then return end
                
                for roomNum = 6, 8 do
                    local room = emergency:FindFirstChild("Room" .. roomNum)
                    if room then
                        local minigame = room:FindFirstChild("Minigame")
                        local heartbeatGame = minigame and minigame:FindFirstChild("Heartbeat")
                        
                        if heartbeatGame or (minigame and #minigame:GetChildren() > 0) then
                            local args = {room, true}
                            pcall(function()
                                local util = ReplicatedStorage:WaitForChild("Util")
                                local net = util:WaitForChild("Net")
                                local remote = net:FindFirstChild("RE/HeartbeatMinigameComplete")
                                if remote then
                                    remote:FireServer(unpack(args))
                                end
                            end)
                        end
                    end
                end
            end

            APWTab:Button({
                Title = "跳过心跳小游戏",
                Callback = function()
                    AutoHeartbeat()
                    WindUI:Notify({Title = "已跳过", Content = "", Duration = 3})
                end
            })

            local Workspace = game:GetService("Workspace")

            local function SkipColorsMinigame()
                local emergency = Workspace:FindFirstChild("Rooms") and Workspace.Rooms:FindFirstChild("Emergency")
                if not emergency then return end
                
                local room6 = emergency:FindFirstChild("Room6")
                if not room6 then return end
                
                local minigame = room6:FindFirstChild("Minigame")
                if not minigame then return end
                
                local colors = minigame:FindFirstChild("Colors")
                if colors then
                    for _, child in ipairs(colors:GetChildren()) do
                        if child:IsA("Model") then
                            for _, desc in ipairs(child:GetDescendants()) do
                                if desc:IsA("ProximityPrompt") and desc.Enabled then
                                    pcall(function() fireproximityprompt(desc) end)
                                elseif desc:IsA("ClickDetector") then
                                    pcall(function() fireclickdetector(desc) end)
                                end
                            end
                        end
                    end
                end
            end

            APWTab:Button({
                Title = "跳过记忆力小游戏",
                Callback = function()
                    SkipColorsMinigame()
                end
            })

            local APRTab = Window:Tab({
                Title = "传送",
                Icon = "brain",
                Locked = false,
            })

            APRTab:Button({
                Title = "传送前台",
                Callback = function()
                    if rootPart then rootPart.CFrame = CFrame.new(-107.70, 3.41, 8.09) end
                end
            })

            APRTab:Button({
                Title = "传送 Room 1",
                Callback = function()
                    if rootPart then rootPart.CFrame = CFrame.new(-168.59, 3.46, -50.13) end
                end
            })

            APRTab:Button({
                Title = "传送 Room 2",
                Callback = function() 
                    if rootPart then rootPart.CFrame = CFrame.new(-119.84, 3.46, 49.73) end
                end
            })

            APRTab:Button({
                Title = "传送 Room 3",
                Callback = function() 
                    if rootPart then rootPart.CFrame = CFrame.new(-168.93, 3.46, -89.89) end
                end
            })

            APRTab:Button({
                Title = "传送 Room 4",
                Callback = function() 
                    if rootPart then rootPart.CFrame = CFrame.new(-121.29, 3.46, -87.60) end
                end
            })

            APRTab:Button({
                Title = "传送 Room 5",
                Callback = function() 
                    if rootPart then rootPart.CFrame = CFrame.new(-142.80, 3.46, -116.14) end
                end
            })

            APRTab:Button({
                Title = "传送 Room 6",
                Callback = function() 
                    if rootPart then rootPart.CFrame = CFrame.new(-166.62, 3.46, 52.85) end
                end
            })

            APRTab:Button({
                Title = "传送 Room 7",
                Callback = function() 
                    if rootPart then rootPart.CFrame = CFrame.new(-119.16, 3.46, 51.33) end
                end
            })

            APRTab:Button({
                Title = "传送 Room 8",
                Callback = function() 
                    if rootPart then rootPart.CFrame = CFrame.new(-144.83, 3.46, 88.17) end
                end
            })

            APRTab:Button({
                Title = "传送商店",
                Callback = function() 
                    if rootPart then rootPart.CFrame = CFrame.new(-164.48, 3.46, -13.32) end
                end
            })

            local APRTab = Window:Tab({
                Title = "购买",
                Icon = "brain",
                Locked = false,
            })

            APRTab:Section({Title = "选项里面会多出来一个 无视即可", TextXAlignment = "Left", TextSize = 17})
            
            local selectedShopItem = ""
            local shopDropdown

            local function GetShopItems()
                local items = {}
                local misc = Workspace:FindFirstChild("Misc")
                local shopModels = misc and misc:FindFirstChild("ShopItemModels")
                
                if shopModels then
                    for _, item in ipairs(shopModels:GetChildren()) do
                        if item.Name and item.Name ~= "" then
                            table.insert(items, item.Name)
                        end
                    end
                end
                
                if #items == 0 then
                    table.insert(items, "无物品")
                end
                
                return items
            end

            local function BuyItem(item)
                local prompt = item:FindFirstChildWhichIsA("ProximityPrompt", true)
                local part = FindBasePartInObject(item)
                
                if prompt and part then
                    SafeTeleport(part)
                    task.wait(0.3)
                    FirePromptDirect(prompt)
                end
            end

            shopDropdown = APRTab:Dropdown({
                Title = "要购买的物品",
                Values = GetShopItems(),
                Value = "",
                Callback = function(value)
                    selectedShopItem = value
                end
            })

            APRTab:Button({
                Title = "刷新物品列表",
                Callback = function()
                    local newItems = GetShopItems()
                    if shopDropdown then
                        if shopDropdown.Refresh then
                            shopDropdown:Refresh(newItems)
                        elseif shopDropdown.SetValues then
                            shopDropdown:SetValues(newItems)
                        end
                    end
                end
            })

            APRTab:Button({
                Title = "购买选中物品",
                Callback = function()
                    if selectedShopItem == "" or selectedShopItem == "无物品" then return end
                    
                    local misc = Workspace:FindFirstChild("Misc")
                    local shopModels = misc and misc:FindFirstChild("ShopItemModels")
                    if not shopModels then return end
                    
                    local targetItem = shopModels:FindFirstChild(selectedShopItem)
                    if targetItem then
                        BuyItem(targetItem)
                    end
                end
            })

            APRTab:Button({
                Title = "购买全部物品",
                Callback = function()
                    local misc = Workspace:FindFirstChild("Misc")
                    local shopModels = misc and misc:FindFirstChild("ShopItemModels")
                    
                    if not shopModels then return end
                    
                    for _, item in ipairs(shopModels:GetChildren()) do
                        BuyItem(item)
                        task.wait(0.5)
                    end
                end
            })

            local APETab = Window:Tab({
                Title = "杂项",
                Icon = "brain",
                Locked = false,
            })

            APETab:Section({Title = "开了秒互动就不要开工作TAB里的功能了", TextXAlignment = "Left", TextSize = 17})

            APETab:Button({
                Title = "反挂机",
                Callback = function()
                    local vu = game:GetService("VirtualUser")
                    game:GetService("Players").LocalPlayer.Idled:Connect(function()
                        vu:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                        task.wait(1)
                        vu:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                    end)
                    
                    task.wait(1)
                    
                    WindUI:Notify({
                        Title = "反挂机",
                        Content = "已开启",
                        Duration = 3
                    })
                end
            })

            APETab:Button({
                Title = "获取咖啡机二",
                Callback = function()
                    local ReplicatedStorage = game:GetService("ReplicatedStorage")
                    local Workspace = game:GetService("Workspace")

                    local coffeeMachine = ReplicatedStorage.Misc.CoffeeMachine2
                    local targetFolder = Workspace:FindFirstChild("Misc")

                    if coffeeMachine and targetFolder then
                        coffeeMachine.Parent = targetFolder
                    end
                end
            })

            APETab:Toggle({
                Title = "启动第三人称",
                Default = false,
                Callback = function(state)
                    local player = game.Players.LocalPlayer
                    if player then
                        if state then
                            player.CameraMode = Enum.CameraMode.Classic
                        else
                            player.CameraMode = Enum.CameraMode.LockFirstPerson
                        end
                    end
                    WindUI:Notify({
                        Title = "第三人称",
                        Content = state and "已开启" or "已关闭",
                        Duration = 2
                    })
                end
            })

            local RunService = game:GetService("RunService")
            local Players = game:GetService("Players")

            local player = Players.LocalPlayer
            local toggleState = false
            local connection = nil
            local lastUpdate = 0
            local UPDATE_INTERVAL = 0.1

            local function GetPromptPosition(prompt)
                local parent = prompt.Parent
                if not parent then return nil end
                if parent:IsA("BasePart") then
                    return parent.Position
                elseif parent:IsA("Model") then
                    local primary = parent.PrimaryPart or parent:FindFirstChildOfClass("Part") or parent:FindFirstChildOfClass("MeshPart")
                    if primary then return primary.Position end
                end
                return nil
            end

            APETab:Toggle({
                Title = "自动秒互动",
                Default = false,
                Callback = function(state)
                    toggleState = state
                    
                    if connection then
                        connection:Disconnect()
                        connection = nil
                    end
                    
                    if state then
                        connection = RunService.Stepped:Connect(function()
                            if not toggleState then 
                                if connection then connection:Disconnect() connection = nil end
                                return 
                            end
                            
                            local now = os.clock()
                            if now - lastUpdate < UPDATE_INTERVAL then return end
                            lastUpdate = now
                            
                            local character = player.Character
                            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
                            if not rootPart then return end
                            
                            local playerGui = player:FindFirstChild("PlayerGui")
                            if playerGui then
                                local mainGui = playerGui:FindFirstChild("MainGui") or playerGui:FindFirstChild("ScreenGui")
                                if mainGui and mainGui:FindFirstChild("BoKi") then
                                    return
                                end
                            end
                            
                            local nearestPrompt = nil
                            local nearestDist = math.huge
                            local blacklistedText = {"view", "watch", "look", "focus"}
                            
                            for _, prompt in ipairs(workspace:GetDescendants()) do
                                if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                                    local name = prompt.Name:lower()
                                    local actionText = prompt.ActionText:lower()
                                    local objectText = prompt.ObjectText:lower()
                                    
                                    local isBlacklisted = false
                                    for _, text in ipairs(blacklistedText) do
                                        if string.find(name, text) or string.find(actionText, text) or string.find(objectText, text) then
                                            isBlacklisted = true
                                            break
                                        end
                                    end
                                    
                                    if not isBlacklisted then
                                        local pos = GetPromptPosition(prompt)
                                        if pos then
                                            local dist = (rootPart.Position - pos).Magnitude
                                            if dist < nearestDist and dist <= prompt.MaxActivationDistance then
                                                nearestDist = dist
                                                nearestPrompt = prompt
                                            end
                                        end
                                    end
                                end
                            end
                            
                            if nearestPrompt then
                                task.spawn(function()
                                    fireproximityprompt(nearestPrompt)
                                end)
                            end
                        end)
                    end
                end
            })

getgenv().InstantInteractEnabled = false

local ProximityPromptService = game:GetService("ProximityPromptService")

if getgenv().InstantInteractConnection then
    getgenv().InstantInteractConnection:Disconnect()
end

local debounce = false

getgenv().InstantInteractConnection = ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt)
    if getgenv().InstantInteractEnabled and not debounce then
        local pName = string.lower(prompt.Name)
        local pAction = prompt.ActionText and string.lower(prompt.ActionText) or ""
        
        if string.find(pName, "report") or string.find(pAction, "report") or string.find(pAction, "报告") then
            return
        end

        debounce = true
        task.spawn(function()
            pcall(function()
                fireproximityprompt(prompt)
            end)
        end)
        task.wait(0.1)
        debounce = false
    end
end)

APETab:Toggle({
    Title = "手动秒互动",
    Default = false,
    Callback = function(state)
        getgenv().InstantInteractEnabled = state
    end
})

            local noAnomalyEnabled = false
            local anomalyThread = nil

            local function CleanAnomaly(npc)
                if not npc:IsA("Model") then return false end
                
                local isCursed = npc:GetAttribute("Cursed") == true
                local isSkinwalker = npc:GetAttribute("Skinwalker") == true
                
                if isCursed or isSkinwalker then
                    local originalFace = npc:GetAttribute("OriginalFace")
                    if originalFace then
                        if npc:FindFirstChild("Head.002") then
                            npc["Head.002"].TextureID = originalFace
                            if npc:FindFirstChild("Head.004") then npc["Head.004"].TextureID = originalFace end
                        elseif npc:FindFirstChild("Face") then
                            npc.Face.TextureID = originalFace
                        elseif npc:FindFirstChild("Head") and npc.Head:FindFirstChild("Face") then
                            npc.Head.Face.TextureID = originalFace
                        else
                            for _, child in pairs(npc:GetDescendants()) do
                                if child:IsA("BasePart") and string.find(string.lower(child.Name), "face") then
                                    child.TextureID = originalFace
                                    break
                                end
                            end
                        end
                    end
                    npc:SetAttribute("Cursed", false)
                    npc:SetAttribute("Skinwalker", false)
                    return true
                end
                return false
            end

            local function StartNoAnomalyLoop()
                if noAnomalyEnabled then return end
                noAnomalyEnabled = true
                
                anomalyThread = task.spawn(function()
                    while noAnomalyEnabled do
                        pcall(function()
                            local npcs = Workspace:FindFirstChild("NPCs")
                            if npcs then
                                for _, npc in pairs(npcs:GetChildren()) do
                                    if not noAnomalyEnabled then break end
                                    CleanAnomaly(npc)
                                end
                            end
                        end)
                        task.wait(0.3)
                    end
                end)
            end

            local function StopNoAnomalyLoop()
                noAnomalyEnabled = false
                if anomalyThread then
                    anomalyThread = nil
                end
            end

            APETab:Toggle({
                Title = "无异常动物",
                Default = false,
                Callback = function(state)
                    if state then
                        StartNoAnomalyLoop()
                        WindUI:Notify({Title = "无异常", Content = "已开启", Duration = 3})
                    else
                        StopNoAnomalyLoop()
                        WindUI:Notify({Title = "无异常", Content = "已关闭", Duration = 3})
                    end
                end
            })

            local TeleportService = game:GetService("TeleportService")
            local Players = game:GetService("Players")
            local LocalPlayer = Players.LocalPlayer

            local confirmState = false
            local confirmTimer = 0

            APETab:Button({
                Title = "重进服务器",
                Callback = function()
                    local currentTime = tick()
                    if not confirmState or (currentTime - confirmTimer > 3) then
                        confirmState = true
                        confirmTimer = currentTime
                        pcall(function()
                            game:GetService("StarterGui"):SetCore("SendNotification", {
                                Title = "确认吗",
                                Text = "再点一次确认重进（3秒内有效）",
                                Duration = 3
                            })
                        end)
                    else
                        confirmState = false
                        pcall(function()
                            game:GetService("ReplicatedStorage"):WaitForChild("Util"):WaitForChild("Net"):WaitForChild("RE/PlayAgainVote"):FireServer()
                        end)
                    end
                end
            })

            APETab:Section({Title = "屏蔽游戏结束UI 恢复控制", TextXAlignment = "Left", TextSize = 17})

            local Players = game:GetService("Players")
            local RunService = game:GetService("RunService")
            local ProximityPromptService = game:GetService("ProximityPromptService")
            local LocalPlayer = Players.LocalPlayer

            local Config = { AntiDeath = false }
            local antiDeathConnection = nil

            pcall(function()
                local rawnamecall
                rawnamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
                    local method = getnamecallmethod()
                    if Config.AntiDeath and (method == "FireServer" or method == "fireServer") then
                        if self and self.Name == "RE/TeleportToLobby" then
                            return nil
                        end
                    end
                    return rawnamecall(self, ...)
                end))
            end)

            local function RestoreProInteraction()
                pcall(function()
                    ProximityPromptService.Enabled = true
                end)

                pcall(function()
                    for _, prompt in ipairs(workspace:GetDescendants()) do
                        if prompt:IsA("ProximityPrompt") then
                            prompt.Enabled = true
                        end
                    end
                end)
            end

            local function RestorePlayerControls()
                pcall(function()
                    local PlayerScripts = LocalPlayer:FindFirstChildOfClass("PlayerScripts")
                    if PlayerScripts then
                        local PlayerModule = PlayerScripts:FindFirstChild("PlayerModule")
                        if PlayerModule then
                            local controls = require(PlayerModule):GetControls()
                            if controls then
                                controls:Enable()
                            end
                        end
                    end
                end)

                local char = LocalPlayer.Character
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then
                        hum.WalkSpeed = hum.WalkSpeed == 0 and 16 or hum.WalkSpeed
                        hum.JumpPower = hum.JumpPower == 0 and 50 or hum.JumpPower
                        hum.AutoRotate = true
                    end

                    for _, part in ipairs(char:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.Anchored = false
                        end
                    end
                end

                local camera = workspace.CurrentCamera
                if camera and char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum and camera.CameraSubject ~= hum then
                        camera.CameraSubject = hum
                        camera.CameraType = Enum.CameraType.Custom
                    end
                end
            end

            local function CleanUpDeathUIAndScripts()
                local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
                if playerGui then
                    for _, gui in ipairs(playerGui:GetChildren()) do
                        local nameLower = string.lower(gui.Name)
                        if string.find(nameLower, "died") 
                           or string.find(nameLower, "death") 
                           or string.find(nameLower, "gameover") 
                           or string.find(nameLower, "end") 
                           or string.find(nameLower, "result") 
                           or string.find(nameLower, "restart") 
                           or string.find(nameLower, "retry") 
                           or string.find(nameLower, "spectate")
                           or string.find(nameLower, "lobby") then
                            
                            if gui:IsA("ScreenGui") then gui.Enabled = false end
                            for _, desc in ipairs(gui:GetDescendants()) do
                                if desc:IsA("LocalScript") or desc:IsA("Script") then
                                    desc.Disabled = true
                                    pcall(function() desc:Destroy() end)
                                elseif desc:IsA("GuiObject") then
                                    desc.Visible = false
                                end
                            end
                        end
                    end
                end
            end

            local function FixJointsAndPhysics(char)
                for _, desc in ipairs(char:GetDescendants()) do
                    if desc:IsA("BallSocketConstraint") or desc:IsA("RopeConstraint") or (desc:IsA("Constraint") and string.find(desc.Name, "Ragdoll")) then
                        pcall(function() desc:Destroy() end)
                    end
                    if desc:IsA("Motor6D") then
                        desc.Enabled = true
                        desc.CurrentAngle = 0
                    end
                    if desc:IsA("BasePart") then
                        desc.CanCollide = (desc.Name == "HumanoidRootPart") and false or true
                    end
                end
            end

            local function MaintainHumanoidState()
                local char = LocalPlayer.Character
                if not char then return end
                
                local hum = char:FindFirstChildOfClass("Humanoid")
                if not hum then return end

                if hum.Health < hum.MaxHealth then
                    hum.Health = hum.MaxHealth
                end

                hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
                
                if hum:GetState() == Enum.HumanoidStateType.Dead or hum:GetState() == Enum.HumanoidStateType.Ragdoll then
                    FixJointsAndPhysics(char)
                    hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                    task.wait(0.02)
                    hum:ChangeState(Enum.HumanoidStateType.Running)
                end
                
                hum.PlatformStand = false
                hum.Sit = false
            end

            local function EnableAntiDeath()
                if not Config.AntiDeath then
                    Config.AntiDeath = true
                    
                    antiDeathConnection = RunService.Stepped:Connect(function()
                        if not Config.AntiDeath then
                            if antiDeathConnection then
                                antiDeathConnection:Disconnect()
                                antiDeathConnection = nil
                            end
                            return
                        end
                        
                        pcall(MaintainHumanoidState)
                        pcall(CleanUpDeathUIAndScripts)
                        pcall(RestorePlayerControls)
                        pcall(RestoreProInteraction)
                    end)
                end
            end

            local function DisableAntiDeath()
                Config.AntiDeath = false
                if antiDeathConnection then
                    antiDeathConnection:Disconnect()
                    antiDeathConnection = nil
                end
            end

            APETab:Toggle({
                Title = "反死亡",
                Default = false,
                Callback = function(state)
                    if state then 
                        EnableAntiDeath() 
                    else 
                        DisableAntiDeath() 
                    end
                end
            })

            APETab:Section({Title = "转换", TextXAlignment = "Left", TextSize = 17})

            local function MakeAllSkinwalker()
                local npcs = Workspace:FindFirstChild("NPCs")
                if not npcs then return end
                local skinwalkerModule = ReplicatedStorage:FindFirstChild("NPCs") and ReplicatedStorage.NPCs:FindFirstChild("SkinwalkerPhotoFaces")
                if not skinwalkerModule then
                    WindUI:Notify({Title = "未找到皮肤模块", Duration = 2})
                    return
                end
                local faces = skinwalkerModule:GetChildren()
                if #faces == 0 then
                    WindUI:Notify({Title = "未找到面部贴图", Duration = 2})
                    return
                end
                local count = 0
                for _, npc in pairs(npcs:GetChildren()) do
                    if npc:IsA("Model") then
                        local randomFace = faces[math.random(1, #faces)].TextureID
                        if npc:FindFirstChild("Head.002") then
                            npc["Head.002"].TextureID = randomFace
                            if npc:FindFirstChild("Head.004") then npc["Head.004"].TextureID = randomFace end
                        elseif npc:FindFirstChild("Face") then
                            npc.Face.TextureID = randomFace
                        elseif npc:FindFirstChild("Head") and npc.Head:FindFirstChild("Face") then
                            npc.Head.Face.TextureID = randomFace
                        else
                            for _, child in pairs(npc:GetDescendants()) do
                                if child:IsA("BasePart") and string.find(string.lower(child.Name), "face") then
                                    child.TextureID = randomFace
                                    break
                                end
                            end
                        end
                        npc:SetAttribute("Cursed", true)
                        npc:SetAttribute("Skinwalker", true)
                        count = count + 1
                    end
                end
                WindUI:Notify({Title = "异常转化", Content = "已转换 " .. count .. " 个动物为异常", Duration = 3})
            end

            APETab:Button({
                Title = "转化正常为异常",
                Callback = function() MakeAllSkinwalker() end
            })

            local function MakeAllNormal()
                local npcs = Workspace:FindFirstChild("NPCs")
                if not npcs then return end
                local count = 0
                for _, npc in pairs(npcs:GetChildren()) do
                    if npc:IsA("Model") then
                        if npc:GetAttribute("Cursed") == true or npc:GetAttribute("Skinwalker") == true then
                            local originalFace = npc:GetAttribute("OriginalFace")
                            if originalFace then
                                if npc:FindFirstChild("Head.002") then
                                    npc["Head.002"].TextureID = originalFace
                                    if npc:FindFirstChild("Head.004") then npc["Head.004"].TextureID = originalFace end
                                elseif npc:FindFirstChild("Face") then
                                    npc.Face.TextureID = originalFace
                                elseif npc:FindFirstChild("Head") and npc.Head:FindFirstChild("Face") then
                                    npc.Head.Face.TextureID = originalFace
                                else
                                    for _, child in pairs(npc:GetDescendants()) do
                                        if child:IsA("BasePart") and string.find(string.lower(child.Name), "face") then
                                            child.TextureID = originalFace
                                            break
                                        end
                                    end
                                end
                            end
                            npc:SetAttribute("Cursed", false)
                            npc:SetAttribute("Skinwalker", false)
                            count = count + 1
                        end
                    end
                end
                WindUI:Notify({Title = "异常还原", Content = "已还原 " .. count .. " 个异常为正常", Duration = 3})
            end

            APETab:Button({
                Title = "转换异常为正常",
                Callback = function() MakeAllNormal() end
            })

            APETab:Section({Title = "防止", TextXAlignment = "Left", TextSize = 17})

            local curseProtection = false
            local curseConnections = {}

            local function SetupCurseProtection()
                local lib = ReplicatedStorage:FindFirstChild("Lib")
                if not lib then return end
                local success, module = pcall(function() return require(lib) end)
                if not success or not module then return end
                if module.Network and module.Network.BindEvents then
                    local oldBind = module.Network.BindEvents
                    module.Network.BindEvents = function(self, events)
                        if events and events.RevealPhoto then
                            local oldReveal = events.RevealPhoto
                            events.RevealPhoto = function(p_u_7, p8, p9)
                                if curseProtection then
                                    p8:SetAttribute("Cursed", false)
                                    p8:SetAttribute("Skinwalker", false)
                                end
                                if oldReveal then oldReveal(p_u_7, p8, p9) end
                            end
                        end
                        return oldBind(self, events)
                    end
                end
                local function onPhotoChildAdded(child)
                    if child.Name == "PhotoVisitor" then
                        task.wait(0.1)
                        if curseProtection then
                            child:SetAttribute("Cursed", false)
                            child:SetAttribute("Skinwalker", false)
                        end
                    end
                end
                local photoUI = module.UI and module.UI.Get and module.UI.Get("PhotoUI")
                local photoUI2 = module.UI and module.UI.Get and module.UI.Get("PhotoUI2")
                if photoUI and photoUI:FindFirstChild("ViewportFrame") and photoUI.ViewportFrame:FindFirstChild("WorldModel") then
                    table.insert(curseConnections, photoUI.ViewportFrame.WorldModel.ChildAdded:Connect(onPhotoChildAdded))
                end
                if photoUI2 and photoUI2:FindFirstChild("ViewportFrame") and photoUI2.ViewportFrame:FindFirstChild("WorldModel") then
                    table.insert(curseConnections, photoUI2.ViewportFrame.WorldModel.ChildAdded:Connect(onPhotoChildAdded))
                end
            end

            SetupCurseProtection()

            APETab:Toggle({
                Title = "防止诅咒照片",
                Default = false,
                Callback = function(state)
                    curseProtection = state
                    if state then
                        for _, npc in pairs(Workspace:GetDescendants()) do
                            if npc:IsA("Model") and npc.Name == "PhotoVisitor" then
                                npc:SetAttribute("Cursed", false)
                                npc:SetAttribute("Skinwalker", false)
                            end
                        end
                    end
                    WindUI:Notify({Title = "防诅咒", Content = state and "已开启" or "已关闭", Duration = 3})
                end
            })