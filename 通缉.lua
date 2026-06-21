loadstring(game:HttpGet("https://pastefy.app/pDhoQmem/raw"))()

local WindUI
do
	local ok, result = pcall(function()
		return require("./src/Init")
	end)
	if ok and result then
		WindUI = result
	else
		ok, result = pcall(function()
			return loadstring(game:HttpGet("https://raw.githubusercontent.com/bygyyds666/QJ/refs/heads/main/ui.lua"))()
		end)
		if ok and result then
			WindUI = result
		else
			warn("WindUI 加载失败: " .. tostring(result))
			return
		end
	end
end
if not WindUI or not WindUI.CreateWindow then
	warn("WindUI 未正确加载, 缺少 CreateWindow 方法")
	return
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local RepStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local GN_S = RepStorage.Events.GNX_S
local ZF_H = RepStorage.Events.ZFKLF__H
local GN_R = RepStorage.Events.GNX_R

local DoTweak_fn
task.defer(function()
	for _, v in getgc(true) do
		if typeof(v) == "function" then
			local info = debug.getinfo(v)
			if info and info.name == "DoTweak" and info.numparams == 11 then
				DoTweak_fn = v
				break
			end
		end
	end
end)

local RB_State, RF_State, AutoReload, DownCheck = false, false, false, false
local Debug_Rays, TargetMode, HitSoundSelection = false, "Near", "None"
local Origin_Radius, Hit_Radius = 18.50, 23.50
local Origin_Scans, Hit_Scans = 24, 24
local ScanRate = 14
local Last_Shot, Valid_Pair, Locked_Path = 0, nil, nil
local WB = { LastScan = 0, Cached = false, Toggle = false, Threshold = 0.5, Round = 0 }
local NoFallEnabled = false
local NR = { Enabled = false, Conns = {}, OrigVals = {}, Cache = {}, RecoilVal = 0 }

local WV = {
	LightingModeEnabled = false,
	LightingMode = "ShadowMap",
	WorldTimeEnabled = false,
	WorldTime = 12,
	AmbientEnabled = false,
	AmbientColor = Color3.fromRGB(255, 255, 255),
	OutdoorAmbientColor = Color3.fromRGB(255, 255, 255),
	AtmosphereEnabled = false,
	AtmoColor = Color3.fromRGB(255, 255, 255),
	AtmoDecay = Color3.fromRGB(120, 120, 120),
	AtmoHaze = 1,
	AtmoGlare = 10,
	AtmoDensity = 0.35,
	AtmoOffset = 0,
	WeatherEnabled = false,
	WeatherType = "Rain",
	WeatherColor = Color3.fromRGB(255, 255, 255),
	WeatherRate = 600,
	SkyboxEnabled = false,
	SkyboxType = "Black Storm",
	BGSoundEnabled = false,
	BGSoundTrack = "Night",
	BGSoundVolume = 25,
}
local WV_Lit = game:GetService("Lighting")
local WV_Atmo = WV_Lit:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere", WV_Lit)
local WV_Sky = WV_Lit:FindFirstChildOfClass("Sky") or Instance.new("Sky", WV_Lit)
local WV_OrigSky = {
	Bk = WV_Sky.SkyboxBk,
	Dn = WV_Sky.SkyboxDn,
	Ft = WV_Sky.SkyboxFt,
	Lf = WV_Sky.SkyboxLf,
	Rt = WV_Sky.SkyboxRt,
	Up = WV_Sky.SkyboxUp,
}
local WV_Skyboxes = {
	["Stormy"] = { Up = "18703232671", Bk = "18703245834", Lf = "18703237556", Dn = "18703243349", Ft = "18703240532", Rt = "18703235430" },
	["Blue Space"] = { Up = "15536117282", Bk = "15536110634", Lf = "15536114370", Dn = "15536112543", Ft = "15536116141", Rt = "15536118762" },
	["Pink"] = { Up = "12216108877", Bk = "12216109205", Lf = "12216110170", Dn = "12216109875", Ft = "12216109489", Rt = "12216110471" },
	["Black Storm"] = { Up = "15502511911", Bk = "15502511288", Lf = "15502507918", Dn = "15502508460", Ft = "15502510289", Rt = "15502509398" },
	["Realistic"] = { Up = "653719321", Bk = "653719502", Lf = "653719190", Dn = "653718790", Ft = "653719067", Rt = "653718931" },
}
local WV_Sounds = {
	["Windy Winter"] = "rbxassetid://6046340391",
	["Light Rain"] = "rbxassetid://18862087062",
	["Thunderstorm"] = "rbxassetid://4305545740",
	["Night"] = "rbxassetid://179507208",
	["Day"] = "rbxassetid://6189453706",
}
local WV_BGSound = Instance.new("Sound", CoreGui)
WV_BGSound.Looped = true
local WV_WeatherPart = Instance.new("Part")
WV_WeatherPart.Size = Vector3.new(40, 40, 85)
WV_WeatherPart.Anchored = true
WV_WeatherPart.CanCollide = false
WV_WeatherPart.Transparency = 1
local WV_Emitter = Instance.new("ParticleEmitter", WV_WeatherPart)
WV_Emitter.EmissionDirection = Enum.NormalId.Bottom
WV_Emitter.Orientation = Enum.ParticleOrientation.FacingCameraWorldUp

local SA = {
	Enabled = false,
	HitChance = 100,
	WallCheck = true,
	TargetPart = "Head",
	IsRandom = false,
	RandomParts = { "Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg" },
	RandomIdx = 1,
	RandomTimer = 0,
	VisualizeEvent = nil,
	DamageEvent = nil,
	FOV_Visible = false,
	FOV_Radius = 100,
	FOV_Sides = 16,
	FOV_Color = Color3.fromRGB(255, 0, 0),
	FOV_PositionMode = "Center",
	FOV_SpinEnabled = false,
	FOV_SpinSpeed = 50,
	FOV_Rotation = 0,
}

local SilkscreenFont = Font.new("rbxassetid://12187371840")
local CONFIG = {
	Rate_Active = 1 / 12,
	Rate_Idle = 1,
	ContentRate = 1 / 14,
	StrokeThickness = 0.8,
	DistOffset = Vector3.new(0, -5.5, 0),
	NameOffset = Vector3.new(0, 5, 0),
}

local NametagEnabled, DistanceEnabled, HealthEnabled = false, false, false
local LastVisualUpdate, LastContentUpdate = 0, 0
local InfStaminaEnabled, InfStaminaConnection = false, nil
local TR = { Enabled = false, Size = 1, Color = Color3.fromRGB(255, 255, 255), Alpha = 0 }
local HitLogEnabled = false

local HeadMode, HandsModSelection = nil, nil
local OriginalNeckC0, OriginalNeckC1 = nil, nil
local HeadYaw, HeadRotSpeed, HeadYawTime = 0, 30, 0
local HeadCustomYaw = 0

local Invis_Enabled, Invis_Track, Invis_SavedCF = false, nil, nil
local Invis_Anim = Instance.new("Animation")
Invis_Anim.AnimationId = "rbxassetid://282574440"

local DS = {
	Enabled = false,
	Visualize = true,
	TPRate = 60,
	X = 8.5,
	Y = 3,
	Z = 8.5,
	LastTPTime = 0,
	LastFFlagTime = 0,
	CurrentOffset = Vector3.zero,
	Y_Toggle = false,
	AppliedOffset = Vector3.zero,
	Model = nil,
}

local LF = {
	Enabled = false,
	SpinSpeed = 100,
	TimePosRatio = 0.5,
	Track1 = nil,
	Track2 = nil,
	Angle = 0,
	Anim1 = Instance.new("Animation"),
	Anim2 = Instance.new("Animation"),
}
LF.Anim1.AnimationId = "rbxassetid://215384594"
LF.Anim2.AnimationId = "rbxassetid://68339848"

local SafeChamsEnabled, SafeChamsLoop = false, nil
local SC = { APM_Enabled = false, APM_Loop = nil, AUS_Enabled = false, AUS_Loop = nil }

DS.Model = Instance.new("Model")
DS.Model.Name = "FakePosVisual"
do
	local outer = Instance.new("Part")
	outer.Name = "Outer"
	outer.Shape = Enum.PartType.Ball
	outer.Size = Vector3.new(1.5, 1.5, 1.5)
	outer.Color = Color3.fromRGB(150, 150, 150)
	outer.Transparency = 0.6
	outer.Material = Enum.Material.SmoothPlastic
	outer.Anchored = true
	outer.CanCollide = false
	outer.CanQuery = false
	outer.CanTouch = false
	outer.Parent = DS.Model

	local inner = Instance.new("Part")
	inner.Name = "Inner"
	inner.Shape = Enum.PartType.Ball
	inner.Size = Vector3.new(0.6, 0.6, 0.6)
	inner.Color = Color3.fromRGB(0, 255, 0)
	inner.Transparency = 0
	inner.Material = Enum.Material.Neon
	inner.Anchored = true
	inner.CanCollide = false
	inner.CanQuery = false
	inner.CanTouch = false
	inner.CFrame = outer.CFrame
	inner.Parent = DS.Model

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = outer
	weld.Part1 = inner
	weld.Parent = outer
	DS.Model.PrimaryPart = outer

	local hl = Instance.new("Highlight")
	hl.FillTransparency = 1
	hl.OutlineColor = Color3.fromRGB(255, 255, 255)
	hl.OutlineTransparency = 0.2
	hl.Parent = DS.Model
end

local FF_S = { BodyEnabled = false, ToolEnabled = false, Color = Color3.fromRGB(255, 255, 255), LastSkin = 0, BodyProps = {}, ToolProps = {} }
local TargetList, WhiteList = {}, {}

local HitSounds = {
	["Skeet"] = "rbxassetid://5633695679",
	["Neverlose"] = "rbxassetid://8726881116",
	["Gamesense"] = "rbxassetid://4817809188",
}

local SpeedState, JumpState, SpeedValue, JumpValue = false, false, 33.5, 73
local CurrentHum = nil

local MC = { AntiShift = false, ShiftDelay = 0.05, SmoothCam = false, LerpSpeed = 6, SmoothPos = nil }
local AMB = { Enabled = false, Color = Color3.fromRGB(190, 220, 255), Density = 0.45, Brightness = 0.15, Gui = nil }
local CAM_FOV
local CAM_FOV_Conn

local FLY = {
	Enabled = false,
	Active = false,
	Speed = 60,
	LastSafeCF = nil,
	AnimTrack = nil,
	SpeedLabel = nil,
	PM = nil,
	PC = nil,
	CurrentYaw = nil,
	OffTime = nil,
	Gui = nil,
	Btn = nil,
	RZDONL = nil,
	NextSend = 0,
	AnimObj = nil,
	AnimId = "rbxassetid://",
	Joints = { "Left Hip", "Right Hip", "Left Shoulder", "Right Shoulder", "Neck" },
	EvArgs = { "-r__r3" },
	MobileMode = false,
}
local function FlyRefreshBtn()
	if not FLY.Btn then return end
	FLY.Btn.Text = if FLY.Active then "ON" else "OFF"
	FLY.Btn.BackgroundColor3 = if FLY.Active then Color3.fromRGB(30, 165, 60) else Color3.fromRGB(185, 45, 45)
end

local CL = {
	Enabled = false,
	DownCheck = false,
	TargetOnly = false,
	AutoPrediction = false,
	FOV = 170,
	Power = 1,
	Shake = 0.2,
	Delay = 0.1,
	TargetParts = { "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg" },
	CurrentTarget = nil,
	LockedPart = nil,
	LastSwitchTime = 0,
	ScanTimer = 0,
	CachedTool = nil,
	CachedVel = 1100,
}

local MA = {
	Enabled = false,
	DownCheck = false,
	TargetOnly = false,
	ShowAnim = true,
	Distance = 20,
	TargetPart = "Random",
	LastHit = 0,
	Loop = nil,
	Parts = { "Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg" },
	Remote1 = RepStorage:WaitForChild("Events"):WaitForChild("XMHH.2"),
	Remote2 = RepStorage:WaitForChild("Events"):WaitForChild("XMHH2.2"),
}

local AC = {
	NeckC0 = CFrame.new(0, 0.4, 0.3),
	NeckC1 = CFrame.new(0, -0.1, 0.4) * CFrame.Angles(math.rad(90), math.rad(-180), 0),
	LShoulder = CFrame.new(-1, 0.5, 0, 0.020794034, -7.74860382e-07, -0.999783635, -0.98459357, 0.173654854, -0.0204781592, 0.173617214, 0.984806538, 0.00361025333),
	RShoulder = CFrame.new(1, 0.5, 0, 0.020793736, 1.07288361e-06, 0.999783933, 0.984594166, 0.173652649, -0.0204781592, -0.173615277, 0.984807134, 0.00360971689),
	Mag6D = CFrame.new(0.00922322646, 0.729015231, -1.10657895, 0.999783754, -6.51925802e-09, -0.0207949243, -0.0204789862, 0.173652411, -0.984594107, 0.00361109618, 0.984807014, 0.17361486),
	Tool6D = CFrame.new(0.00922359806, 0.729012489, -1.10657847, 0.999783754, -2.79396772e-09, -0.0207949281, -0.0204789862, 0.173653483, -0.984593868, 0.00361111294, 0.984806776, 0.173615932),
	AntiDown = Vector3.new(0.006237113382667303, -6, -0.18136750161647797),
	OpenHands = Vector3.new(0.006237113382667303, 6, 0.18136750161647797),
	HandsUp1 = Vector3.new(-4237.62255859375, 9848.9267578125, -2292.4501953125),
	HandsUp2 = Vector3.new(-4264.8974609375, 0.9520299434661865, -556.17333984375),
}

local HitLog = { ActiveLogs = {} }
HitLog.THEME = {
	RowHeight = 13,
	PaddingY = 7,
	SidePadding = 16,
	FontSize = 10,
	Font = SilkscreenFont,
	Color_Bg = Color3.fromRGB(0, 0, 0),
	Color_Accent = Color3.fromRGB(0, 255, 0),
	Color_Secondary = Color3.fromRGB(200, 200, 200),
	BgTransparency = 0.5,
	Lifetime = 5.0,
	MaxLogs = 8,
	Position = UDim2.new(0, 20, 0, 70),
}

local BoxESP = { Boxes = {}, Conn = {} }
local espSets = {
	enabled = false,
	targetOnly = false,
	outline = true,
	inline = true,
	outCol = Color3.fromRGB(255, 255, 255),
	inCol = Color3.fromRGB(0, 0, 0),
	outAlpha = 0.5,
	inAlpha = 0.2,
	outSize = 0.1,
	inSize = 0.05,
}
local bodyParts = {
	"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg",
	"UpperTorso", "LowerTorso", "LeftUpperArm", "LeftLowerArm", "LeftHand",
	"RightUpperArm", "RightLowerArm", "RightHand",
	"LeftUpperLeg", "LeftLowerLeg", "LeftFoot",
	"RightUpperLeg", "RightLowerLeg", "RightFoot",
}

local reloadConnections = {}
local PL_TargetSearch, PL_WhiteSearch = nil, nil
local lastTickHadGun = false
local ChangeMouseLockEvent = RepStorage:WaitForChild("Events2"):WaitForChild("ChangeMouseLock")

local function GetLocalRealPosition(): Vector3
	local char = LocalPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return Vector3.zero end
	return hrp.Position - DS.AppliedOffset
end

local function InitHitLog()
	if HitLog.Gui then return end
	HitLog.Gui = Instance.new("ScreenGui")
	HitLog.Gui.Name = "CatHitLog"
	HitLog.Gui.ResetOnSpawn = false
	HitLog.Gui.IgnoreGuiInset = true
	HitLog.Gui.Enabled = false
	HitLog.Gui.Parent = CoreGui
	local c = Instance.new("Frame")
	c.Name = "LogContainer"
	c.Position = HitLog.THEME.Position
	c.Size = UDim2.new(0, 500, 0, 800)
	c.BackgroundTransparency = 1
	c.Parent = HitLog.Gui
	HitLog.Container = c
end

local function RecalculateLogPositions()
	for i, frame in HitLog.ActiveLogs do
		local y = (i - 1) * (HitLog.THEME.RowHeight + HitLog.THEME.PaddingY)
		TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), { Position = UDim2.new(0, 0, 0, y) }):Play()
	end
end

local function AnimateRemoveLog(frame: Instance?)
	if not frame then return end
	local info = TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
	TweenService:Create(frame, info, { Position = frame.Position - UDim2.new(0, 0, 0, 15), BackgroundTransparency = 1 }):Play()
	local lbl = frame:FindFirstChild("Content")
	if lbl then TweenService:Create(lbl, info, { TextTransparency = 1 }):Play() end
	task.delay(0.5, function()
		if frame then frame:Destroy() end
	end)
end

local function AddLogEntry(text: string)
	if not HitLogEnabled or not HitLog.Container then return end
	if #HitLog.ActiveLogs >= HitLog.THEME.MaxLogs then
		AnimateRemoveLog(table.remove(HitLog.ActiveLogs, 1))
		RecalculateLogPositions()
	end
	local bg = Instance.new("Frame")
	bg.AutomaticSize = Enum.AutomaticSize.X
	bg.Size = UDim2.new(0, 0, 0, HitLog.THEME.RowHeight)
	bg.BackgroundColor3 = HitLog.THEME.Color_Bg
	bg.BackgroundTransparency = 1
	bg.Parent = HitLog.Container
	local grad = Instance.new("UIGradient")
	grad.Color = ColorSequence.new(Color3.new(1, 1, 1))
	grad.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0.00, 1.00),
		NumberSequenceKeypoint.new(0.20, HitLog.THEME.BgTransparency),
		NumberSequenceKeypoint.new(0.80, HitLog.THEME.BgTransparency),
		NumberSequenceKeypoint.new(1.00, 1.00),
	})
	grad.Parent = bg
	local pad = Instance.new("UIPadding")
	pad.PaddingLeft = UDim.new(0, HitLog.THEME.SidePadding)
	pad.PaddingRight = UDim.new(0, HitLog.THEME.SidePadding)
	pad.Parent = bg
	local lbl = Instance.new("TextLabel")
	lbl.Name = "Content"
	lbl.AutomaticSize = Enum.AutomaticSize.X
	lbl.Size = UDim2.new(0, 0, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = text
	lbl.TextColor3 = HitLog.THEME.Color_Secondary
	lbl.TextSize = HitLog.THEME.FontSize
	lbl.FontFace = HitLog.THEME.Font
	lbl.RichText = true
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.TextTransparency = 1
	lbl.Parent = bg
	table.insert(HitLog.ActiveLogs, bg)
	local ty = (#HitLog.ActiveLogs - 1) * (HitLog.THEME.RowHeight + HitLog.THEME.PaddingY)
	bg.Position = UDim2.new(0, -25, 0, ty)
	local info = TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
	TweenService:Create(bg, info, { Position = UDim2.new(0, 0, 0, ty), BackgroundTransparency = 0 }):Play()
	TweenService:Create(lbl, info, { TextTransparency = 0 }):Play()
	task.delay(HitLog.THEME.Lifetime, function()
		if not bg or not bg.Parent then return end
		local idx = table.find(HitLog.ActiveLogs, bg)
		if idx then
			table.remove(HitLog.ActiveLogs, idx)
			AnimateRemoveLog(bg)
			RecalculateLogPositions()
		end
	end)
end

local function ProcessHitLog(tName: string, toolName: string, dmg: number, dist: number|string, cached: boolean)
	local s = "rgb(200,200,200)"
	local g = "rgb(0,255,0)"
	local ct = if cached then " Via Cache" else ""
	AddLogEntry("Hit "..tName.." use "..toolName.." in the Head for "..tostring(dmg).." damage "..tostring(dist).."m"..ct)
end

InitHitLog()

local function CreateTracer(origin: Vector3, dir: Vector3)
	if not TR.Enabled then return end
	local a0 = Instance.new("Attachment", Workspace.Terrain)
	a0.Position = origin
	local a1 = Instance.new("Attachment", Workspace.Terrain)
	a1.Position = origin + dir.Unit * 1000
	local beam = Instance.new("Beam", Workspace.Terrain)
	beam.Texture = "rbxassetid://446111271"
	beam.Width0, beam.Width1 = TR.Size, TR.Size
	beam.Color = ColorSequence.new(TR.Color)
	beam.Transparency = NumberSequence.new(TR.Alpha)
	beam.Attachment0, beam.Attachment1 = a0, a1
	beam.FaceCamera, beam.LightEmission = true, 1
	Debris:AddItem(a0, 4)
	Debris:AddItem(a1, 4)
	Debris:AddItem(beam, 4)
end

local function IsBodyPart(p: Instance): boolean
	return p:IsA("BasePart") and (
		p.Name == "Head"
		or p.Name == "Torso"
		or p.Name == "Left Arm"
		or p.Name == "Right Arm"
		or p.Name == "Left Leg"
		or p.Name == "Right Leg"
	)
end

local function onCharacterAdded()
	FF_S.BodyProps, FF_S.ToolProps = {}, {}
	OriginalNeckC0, OriginalNeckC1 = nil, nil
	Invis_Track, Invis_SavedCF = nil, nil
	LF.Track1, LF.Track2, LF.Angle = nil, nil, 0
	FLY.Active = false
	FLY.LastSafeCF = nil
	FLY.PM = nil
	FLY.PC = nil
	FLY.AnimTrack = nil
	FlyRefreshBtn()
end
if LocalPlayer.Character then task.spawn(onCharacterAdded) end
LocalPlayer.CharacterAdded:Connect(onCharacterAdded)

local function OnToolEquipped(tool: Tool)
	task.spawn(function()
		task.wait(0.15)
		if not FF_S.ToolEnabled then return end
		if not tool or not tool.Parent then return end
		for _, p in tool:GetDescendants() do
			if p:IsA("BasePart") then
				if not FF_S.ToolProps[p] then
					FF_S.ToolProps[p] = { Material = p.Material, Color = p.Color }
				end
				p.Material = Enum.Material.ForceField
				p.Color = FF_S.Color
			end
		end
	end)
end
LocalPlayer.CharacterAdded:Connect(function(char)
	char.ChildAdded:Connect(function(obj)
		if obj:IsA("Tool") then OnToolEquipped(obj) end
	end)
end)
if LocalPlayer.Character then
	LocalPlayer.Character.ChildAdded:Connect(function(obj)
		if obj:IsA("Tool") then OnToolEquipped(obj) end
	end)
end

local originalFireServer
originalFireServer = hookfunction(Instance.new("RemoteEvent").FireServer, function(self, ...)
	if NoFallEnabled and self.Name == "__RZDONL" then
		local cs = getcallingscript()
		if cs and cs:IsDescendantOf(game) then return nil end
	end
	return originalFireServer(self, ...)
end)

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
	local method = getnamecallmethod()
	local args = { ... }
	if method == "FireServer" and self == ZF_H then
		if HitSoundSelection ~= "None" and HitSounds[HitSoundSelection] then
			task.spawn(function()
				local s = Instance.new("Sound", Camera)
				s.SoundId = HitSounds[HitSoundSelection]
				s.Volume = 1
				s:Play()
				Debris:AddItem(s, 1)
			end)
		end
	end
	if method == "FireServer" and NoFallEnabled and self.Name == "__RZDONL" then
		local cs = getcallingscript()
		if cs and cs:IsDescendantOf(game) then return nil end
	end
	if (HeadMode or HandsModSelection) and method == "FireServer" and self.Name == "MOVZREP" then
		if args[1] and typeof(args[1]) == "table" and args[1][1] then
			pcall(function()
				if HandsModSelection == "Hands up" then
					args[1][1][1] = AC.HandsUp1
					args[1][1][2] = AC.HandsUp2
				elseif HandsModSelection == "Open hands" then
					args[1][1][1] = AC.OpenHands
					args[1][1][2] = AC.OpenHands
				end
				if HeadMode == "Hide head" then
					args[1][1][3] = AC.AntiDown
				end
			end)
		end
	end
	if not checkcaller() then
		if self == ZF_H and method == "FireServer" and args[1] ~= "🧈" then return nil end
		if self == GN_S and method == "FireServer" and TR.Enabled then
			if typeof(args[5]) == "Vector3" and typeof(args[6]) == "table" and args[6][1] then
				task.spawn(CreateTracer, args[5], args[6][1])
			end
		end
	end
	return oldNamecall(self, ...)
end)

local oldNewIndex
oldNewIndex = hookmetamethod(game, "__newindex", function(t, k, v)
	if FLY.Active then
		local lp = Players.LocalPlayer
		local stats = RepStorage:FindFirstChild("CharStats")
		local pStats = stats and stats:FindFirstChild(lp.Name)
		local rt = pStats and pStats:FindFirstChild("RagdollTime")
		if rt then
			if (t == rt:FindFirstChild("RagdollSwitch") or t == rt:FindFirstChild("RagdollSwitch2") or t == rt:FindFirstChild("SRagdolled")) and k == "Value" then
				return oldNewIndex(t, k, false)
			end
			if t == rt and k == "Value" then
				return oldNewIndex(t, k, 0)
			end
			if t == rt:FindFirstChild("RagdollTime2") and k == "MaxValue" then
				return oldNewIndex(t, k, 0)
			end
		end
		if t == pStats and t:FindFirstChild("NoRagdoll") and k == "Value" then
			return oldNewIndex(t, k, true)
		end
	end
	return oldNewIndex(t, k, v)
end)

local function NR_CacheWeapons()
	NR.Cache = {}
	for _, v in getgc(true) do
		if typeof(v) == "table" and rawget(v, "EquipTime") then
			table.insert(NR.Cache, v)
			if not NR.OrigVals[v] then
				NR.OrigVals[v] = {
					Recoil = v.Recoil,
					CameraRecoilingEnabled = v.CameraRecoilingEnabled,
					AngleX_Min = v.AngleX_Min,
					AngleX_Max = v.AngleX_Max,
					AngleY_Min = v.AngleY_Min,
					AngleY_Max = v.AngleY_Max,
					AngleZ_Min = v.AngleZ_Min,
					AngleZ_Max = v.AngleZ_Max,
					Spread = v.Spread,
				}
			end
		end
	end
end

local function NR_Apply()
	for _, w in NR.Cache do
		w.Recoil = NR.RecoilVal
		w.CameraRecoilingEnabled = false
		w.AngleX_Min = 0
		w.AngleX_Max = 0
		w.AngleY_Min = 0
		w.AngleY_Max = 0
		w.AngleZ_Min = 0
		w.AngleZ_Max = 0
		w.Spread = 0
	end
end

local function NR_Reset()
	for w, val in NR.OrigVals do
		w.Recoil = val.Recoil
		w.CameraRecoilingEnabled = val.CameraRecoilingEnabled
		w.AngleX_Min = val.AngleX_Min
		w.AngleX_Max = val.AngleX_Max
		w.AngleY_Min = val.AngleY_Min
		w.AngleY_Max = val.AngleY_Max
		w.AngleZ_Min = val.AngleZ_Min
		w.AngleZ_Max = val.AngleZ_Max
		w.Spread = val.Spread
	end
end

local function NR_OnChar(char: Model)
	for _, c in char:GetChildren() do
		if c:IsA("Tool") then
			task.delay(0.1, function()
				NR_CacheWeapons()
				NR_Apply()
			end)
		end
	end
	table.insert(NR.Conns, char.ChildAdded:Connect(function(c: Instance)
		if c:IsA("Tool") then
			task.delay(0.1, function()
				NR_CacheWeapons()
				NR_Apply()
			end)
		end
	end))
	local hum = char:WaitForChild("Humanoid", 2)
	if hum then
		table.insert(NR.Conns, hum.Died:Connect(function()
			if NR.Enabled then
				task.wait(1.5)
				NR_CacheWeapons()
				NR_Apply()
			end
		end))
	end
end

local function NR_Enable()
	if NR.Enabled then return end
	NR.Enabled = true
	NR_CacheWeapons()
	NR_Apply()
	table.insert(NR.Conns, LocalPlayer.CharacterAdded:Connect(NR_OnChar))
	if LocalPlayer.Character then NR_OnChar(LocalPlayer.Character) end
end

local function NR_Disable()
	if not NR.Enabled then return end
	NR.Enabled = false
	NR_Reset()
	for _, c in NR.Conns do
		c:Disconnect()
	end
	NR.Conns = {}
end

FLY.AnimObj = Instance.new("Animation")
FLY.AnimObj.AnimationId = FLY.AnimId

local function FlyGetInputDir(): Vector3
	if not FLY.PM then
		local ok, r = pcall(function()
			return require(LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"))
		end)
		if ok then FLY.PM = r end
	end
	if FLY.PM and not FLY.PC then
		FLY.PC = FLY.PM:GetControls()
	end
	if not FLY.PC then return Vector3.zero end
	local mv = FLY.PC:GetMoveVector()
	local fwd = Camera.CFrame.LookVector
	local rgt = Camera.CFrame.RightVector
	local dir = rgt * mv.X + fwd * -mv.Z
	return if dir.Magnitude > 0 then dir.Unit else Vector3.zero
end

local function FlyPlayAnim()
	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not hum then return end
	if FLY.AnimTrack and FLY.AnimTrack.IsPlaying then return end
	local anim = hum:FindFirstChildOfClass("Animator") or hum
	pcall(function()
		FLY.AnimTrack = anim:LoadAnimation(FLY.AnimObj)
		FLY.AnimTrack.Priority = Enum.AnimationPriority.Action4
		FLY.AnimTrack.Looped = true
		FLY.AnimTrack:Play()
	end)
end

local function FlyStopAnim()
	if FLY.AnimTrack then
		pcall(function() FLY.AnimTrack:Stop(0.3) end)
		FLY.AnimTrack = nil
	end
end

local function FlyOn()
	local char = LocalPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not (hrp and hum) then return end
	FLY.Active = true
	FLY.LastSafeCF = nil
	FlyPlayAnim()
	FlyRefreshBtn()
end

local function FlyOff()
	FLY.Active = false
	FLY.LastSafeCF = nil
	FLY.CurrentYaw = nil
	FLY.OffTime = os.clock()
	FlyStopAnim()
	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if hum then
		hum.PlatformStand = false
		hum:ChangeState(Enum.HumanoidStateType.Running)
	end
	if hrp then
		hrp.AssemblyLinearVelocity = Vector3.zero
		hrp.AssemblyAngularVelocity = Vector3.zero
	end
	FlyRefreshBtn()
end

local function FlyCreateUI()
	if FLY.Gui then FLY.Gui:Destroy(); FLY.Gui = nil; FLY.Btn = nil end
	FLY.Gui = Instance.new("ScreenGui")
	FLY.Gui.Name = "FlyHUD"
	FLY.Gui.ResetOnSpawn = false
	FLY.Gui.IgnoreGuiInset = true
	FLY.Gui.DisplayOrder = 99
	FLY.Gui.Parent = CoreGui
	local frame = Instance.new("Frame", FLY.Gui)
	frame.Size = UDim2.new(0, 140, 0, 78)
	frame.Position = UDim2.new(1, -160, 1, -110)
	frame.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
	frame.BackgroundTransparency = 0.08
	frame.BorderSizePixel = 0
	frame.Active = true
	frame.Draggable = true
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 5)
	local stroke = Instance.new("UIStroke", frame)
	stroke.Color = Color3.fromRGB(55, 55, 55)
	stroke.Thickness = 1
	stroke.Transparency = 0.2
	local title = Instance.new("TextLabel", frame)
	title.Size = UDim2.new(1, -16, 0, 20)
	title.Position = UDim2.new(0, 8, 0, 6)
	title.BackgroundTransparency = 1
	title.Text = "FLY"
	title.TextColor3 = Color3.fromRGB(160, 160, 160)
	title.TextSize = 12
	title.Font = Enum.Font.GothamMedium
	title.TextXAlignment = Enum.TextXAlignment.Left
	local speedLabel = Instance.new("TextLabel", frame)
	speedLabel.Size = UDim2.new(1, -16, 0, 16)
	speedLabel.Position = UDim2.new(0, 8, 0, 26)
	speedLabel.BackgroundTransparency = 1
	speedLabel.Text = "spd "..FLY.Speed
	speedLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
	speedLabel.TextSize = 10
	speedLabel.Font = Enum.Font.Gotham
	speedLabel.TextXAlignment = Enum.TextXAlignment.Left
	FLY.SpeedLabel = speedLabel
	local div = Instance.new("Frame", frame)
	div.Size = UDim2.new(1, -16, 0, 1)
	div.Position = UDim2.new(0, 8, 0, 46)
	div.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	div.BorderSizePixel = 0
	local btn = Instance.new("TextButton", frame)
	btn.Size = UDim2.new(1, -16, 0, 22)
	btn.Position = UDim2.new(0, 8, 0, 50)
	btn.BackgroundColor3 = Color3.fromRGB(185, 45, 45)
	btn.BorderSizePixel = 0
	btn.Text = "OFF"
	btn.TextColor3 = Color3.fromRGB(240, 240, 240)
	btn.TextSize = 12
	btn.Font = Enum.Font.GothamBold
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
	FLY.Btn = btn
	btn.MouseButton1Click:Connect(function()
		if FLY.Active then FlyOff() else FlyOn() end
	end)
	FlyRefreshBtn()
end

local function FlyDestroyUI()
	if FLY.Gui then FLY.Gui:Destroy(); FLY.Gui = nil; FLY.Btn = nil end
	FLY.SpeedLabel = nil
end

local function GetCustomTag(char: Model, tagName: string, offset: Vector3): BillboardGui?
	local tag = char:FindFirstChild(tagName)
	if not tag then
		local head = char:FindFirstChild("Head")
		local root = char:FindFirstChild("HumanoidRootPart")
		local adorn = head or root
		if not adorn then return nil end
		tag = Instance.new("BillboardGui")
		tag.Name = tagName
		tag.AlwaysOnTop = true
		tag.Size = UDim2.new(0, 200, 0, 36)
		tag.StudsOffset = Vector3.new(0, 0.6, 0)
		tag.StudsOffsetWorldSpace = Vector3.new(0, 0, 0)
		tag.Enabled = false
		local nameL = Instance.new("TextLabel")
		nameL.Name = "L"
		nameL.BackgroundTransparency = 1
		nameL.Size = UDim2.new(1, 0, 0.5, 0)
		nameL.Position = UDim2.new(0, 0, 0, 0)
		nameL.TextColor3 = Color3.new(1, 1, 1)
		nameL.FontFace = SilkscreenFont
		nameL.TextSize = 7
		nameL.TextXAlignment = Enum.TextXAlignment.Center
		local s1 = Instance.new("UIStroke")
		s1.Thickness = CONFIG.StrokeThickness
		s1.Color = Color3.new(0, 0, 0)
		s1.Parent = nameL
		nameL.Parent = tag
		local distL = Instance.new("TextLabel")
		distL.Name = "DL"
		distL.BackgroundTransparency = 1
		distL.Size = UDim2.new(1, 0, 0.5, 0)
		distL.Position = UDim2.new(0, 0, 0.5, 0)
		distL.TextColor3 = Color3.fromRGB(200, 200, 200)
		distL.FontFace = SilkscreenFont
		distL.TextSize = 7
		distL.TextXAlignment = Enum.TextXAlignment.Center
		local s2 = Instance.new("UIStroke")
		s2.Thickness = CONFIG.StrokeThickness
		s2.Color = Color3.new(0, 0, 0)
		s2.Parent = distL
		distL.Parent = tag
		local ffTag = Instance.new("BillboardGui")
		ffTag.Name = "CAT_FFTag"
		ffTag.AlwaysOnTop = true
		ffTag.Size = UDim2.new(0, 60, 0, 20)
		ffTag.StudsOffset = Vector3.new(2.5, 0, 0)
		ffTag.Enabled = false
		local ffL = Instance.new("TextLabel")
		ffL.Name = "L"
		ffL.BackgroundTransparency = 1
		ffL.Size = UDim2.new(1, 0, 1, 0)
		ffL.Text = "FF"
		ffL.TextColor3 = Color3.new(1, 1, 1)
		ffL.FontFace = SilkscreenFont
		ffL.TextSize = 7
		ffL.TextXAlignment = Enum.TextXAlignment.Center
		local sFF = Instance.new("UIStroke")
		sFF.Thickness = CONFIG.StrokeThickness
		sFF.Color = Color3.new(0, 0, 0)
		sFF.Parent = ffL
		ffL.Parent = ffTag
		ffTag.Parent = char
		ffTag.Adornee = root
		local hpTag = Instance.new("BillboardGui")
		hpTag.Name = "CAT_HPTag"
		hpTag.AlwaysOnTop = true
		hpTag.Size = UDim2.new(0, 60, 0, 20)
		hpTag.StudsOffset = Vector3.new(-2.5, 0, 0)
		hpTag.Enabled = false
		local hpL = Instance.new("TextLabel")
		hpL.Name = "L"
		hpL.BackgroundTransparency = 1
		hpL.Size = UDim2.new(1, 0, 1, 0)
		hpL.TextColor3 = Color3.new(1, 1, 1)
		hpL.FontFace = SilkscreenFont
		hpL.TextSize = 7
		hpL.TextXAlignment = Enum.TextXAlignment.Center
		local sHP = Instance.new("UIStroke")
		sHP.Thickness = CONFIG.StrokeThickness
		sHP.Color = Color3.new(0, 0, 0)
		sHP.Parent = hpL
		hpL.Parent = hpTag
		hpTag.Parent = char
		hpTag.Adornee = root
		tag.Parent = char
		tag.Adornee = adorn
	end
	return tag
end

local function clearReloadConnections()
	for _, c in reloadConnections do
		c:Disconnect()
	end
	reloadConnections = {}
end

local function setupTool(tool: Tool?)
	if not (tool and tool:FindFirstChild("IsGun") and AutoReload) then return end
	local vals = tool:FindFirstChild("Values")
	if not vals then return end
	local sa, ssa = vals:FindFirstChild("SERVER_Ammo"), vals:FindFirstChild("SERVER_StoredAmmo")
	local function reload()
		if AutoReload and ssa and ssa.Value ~= 0 then
			GN_R:FireServer(tick(), "KLWE89U0", tool)
		end
	end
	if ssa then table.insert(reloadConnections, ssa:GetPropertyChangedSignal("Value"):Connect(reload)) end
	if sa then table.insert(reloadConnections, sa:GetPropertyChangedSignal("Value"):Connect(reload)) end
end

local function ShouldLock(): boolean
	if not CL.Enabled then return false end
	local char = LocalPlayer.Character
	local tool = char and char:FindFirstChildOfClass("Tool")
	if not tool or not tool:FindFirstChild("IsGun") then return false end
	local vals = tool:FindFirstChild("Values")
	return vals and vals:FindFirstChild("AimDown") and vals.AimDown.Value == true
end

local function IsVisible(origin: Vector3, tPart: BasePart): boolean
	local p = RaycastParams.new()
	p.FilterType = Enum.RaycastFilterType.Exclude
	p.FilterDescendantsInstances = { LocalPlayer.Character, Camera }
	local r = workspace:Raycast(origin, tPart.Position - origin, p)
	return not r or r.Instance:IsDescendantOf(tPart.Parent)
end

local function GetVisibleParts(origin: Vector3, char: Model): {BasePart}
	local vis = {}
	for _, name in CL.TargetParts do
		local p = char:FindFirstChild(name)
		if p and IsVisible(origin, p) then
			table.insert(vis, p)
		end
	end
	return if #vis > 0 then vis else { char:FindFirstChild("HumanoidRootPart") }
end

local function AutoReloadSetup()
	clearReloadConnections()
	if not AutoReload then return end
	if LocalPlayer.Character then
		setupTool(LocalPlayer.Character:FindFirstChildOfClass("Tool"))
		table.insert(reloadConnections, LocalPlayer.Character.ChildAdded:Connect(function(o: Instance)
			if o:IsA("Tool") then setupTool(o) end
		end))
	end
	table.insert(reloadConnections, LocalPlayer.CharacterAdded:Connect(function(c: Model)
		repeat task.wait() until c and c.Parent
		clearReloadConnections()
		setupTool(c:FindFirstChildOfClass("Tool"))
		table.insert(reloadConnections, c.ChildAdded:Connect(function(o: Instance)
			if o:IsA("Tool") then setupTool(o) end
		end))
	end))
end

local function StartMeleeLoop()
	if MA.Loop then return end
	local WCDs = { Fists = 0.05, Knuckledusters = 0.05, Nunchucks = 0.05, Shiv = 0.05, Chainsaw = 2.5 }
	MA.Loop = task.spawn(function()
		while MA.Enabled do
			local char = LocalPlayer.Character
			local tool = char and char:FindFirstChildOfClass("Tool")
			if tool and char:FindFirstChild("HumanoidRootPart") then
				local cd = 0.5
				if WCDs[tool.Name] then
					cd = WCDs[tool.Name]
				else
					local cfg = tool:FindFirstChild("Config")
					if cfg and cfg:IsA("ModuleScript") then
						pcall(function()
							local m = require(cfg)
							if m.Mains and m.Mains.S1 then
								cd = (m.Mains.S1.SwingWait or 0.2) + (m.Mains.S1.SwingTime or 0.1) + 0.05
							end
						end)
					end
				end
				if tick() - MA.LastHit >= cd then
					for _, p in Players:GetPlayers() do
						if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
							if not table.find(WhiteList, p.Name) and (not MA.TargetOnly or table.find(TargetList, p.Name)) then
								local tChar = p.Character
								local myPos = GetLocalRealPosition()
								local dist = (myPos - tChar.HumanoidRootPart.Position).Magnitude
								local hum = tChar:FindFirstChildOfClass("Humanoid")
								if dist <= MA.Distance and hum and hum.Health > (if MA.DownCheck then 15 else 0) then
									local res = MA.Remote1:InvokeServer("🍞", tick(), tool, "43TRFWX", "Normal", tick(), true)
									if MA.ShowAnim then
										pcall(function()
											char.Humanoid.Animator:LoadAnimation(tool.AnimsFolder.Slash1):Play(0.1, 1, 1.3)
										end)
									end
									task.wait(0.2)
									local hitPart = if MA.TargetPart == "Random"
										then tChar:FindFirstChild(MA.Parts[math.random(1, #MA.Parts)])
										else tChar:FindFirstChild(MA.TargetPart)
									if hitPart then
										local handle = tool:FindFirstChild("WeaponHandle") or tool:FindFirstChild("Handle") or char:FindFirstChild("Left Arm")
										local a = { "🍞", tick(), tool, "2389ZFX34", res, true, handle, hitPart, tChar, myPos, hitPart.Position }
										if tool.Name == "Chainsaw" then
											for _ = 1, 15 do
												MA.Remote2:FireServer(table.unpack(a))
											end
										else
											MA.Remote2:FireServer(table.unpack(a))
										end
										MA.LastHit = tick()
										break
									end
								end
							end
						end
					end
				end
			end
			task.wait()
		end
		MA.Loop = nil
	end)
end

local function StartAutoPickUpMoney()
	if SC.APM_Loop then return end
	SC.APM_Loop = task.spawn(function()
		local event = RepStorage:FindFirstChild("Events") and RepStorage.Events:FindFirstChild("CZDPZUS")
		local filter = Workspace:FindFirstChild("Filter")
		while SC.APM_Enabled do
			local didPickup = false
			if event and filter then
				local char = LocalPlayer.Character
				local hrp = char and char:FindFirstChild("HumanoidRootPart")
				if hrp then
					local bread = filter:FindFirstChild("SpawnedBread")
					if bread then
						for _, item in bread:GetChildren() do
							if (hrp.Position - item.Position).Magnitude < 5 then
								pcall(function() event:FireServer(item) end)
								task.wait(1.1)
								didPickup = true
								break
							end
						end
					end
				end
			end
			if not didPickup then task.wait(0.1) end
		end
		SC.APM_Loop = nil
	end)
end

local function StartAutoUnlockSafe()
	if SC.AUS_Loop then return end
	SC.AUS_Loop = task.spawn(function()
		while SC.AUS_Enabled do
			local processed = false
			local char = LocalPlayer.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			local hum = char and char:FindFirstChild("Humanoid")
			if hrp and hum then
				local map = Workspace:FindFirstChild("Map")
				local bredMakurz = map and map:FindFirstChild("BredMakurz")
				if bredMakurz then
					local closestSafe, minDist = nil, 12
					for _, obj in bredMakurz:GetChildren() do
						if string.find(string.lower(obj.Name), "safe") then
							local vals = obj:FindFirstChild("Values")
							local broken = vals and vals:FindFirstChild("Broken")
							if broken and broken.Value == false then
								local part = if obj:IsA("Model") then obj.PrimaryPart else obj:FindFirstChildWhichIsA("BasePart") or obj
								if part and part:IsA("BasePart") then
									local dist = (hrp.Position - part.Position).Magnitude
									if dist <= minDist then
										minDist = dist
										closestSafe = obj
									end
								end
							end
						end
					end
					if closestSafe then
						processed = true
						local lockpick = char:FindFirstChild("Lockpick")
						if not lockpick then
							local bp = LocalPlayer.Backpack:FindFirstChild("Lockpick")
							if bp then
								hum:EquipTool(bp)
								lockpick = bp
								task.wait(0.25)
							end
						end
						if lockpick then
							local remote = lockpick:FindFirstChild("Remote")
							if remote then
								local token = nil
								for _ = 1, 8 do
									pcall(function() token = remote:InvokeServer("S", closestSafe, "s") end)
									if token then break end
									task.wait(0.15)
								end
								if token then
									task.spawn(function() pcall(function() remote:InvokeServer("D", closestSafe, "s", token) end) end)
									task.spawn(function() pcall(function() remote:InvokeServer("C") end) end)
									task.wait(0.8)
									local vals2 = closestSafe:FindFirstChild("Values")
									local broken2 = vals2 and vals2:FindFirstChild("Broken")
									if broken2 and not broken2.Value then
										pcall(function() remote:InvokeServer("D", closestSafe, "s", token) end)
										task.wait(0.5)
									end
								end
							end
						end
						task.wait(0.5)
					end
				end
			end
			if not processed then task.wait(0.1) end
		end
		SC.AUS_Loop = nil
	end)
end

local function StartSafeChams()
	if SafeChamsLoop then return end
	SafeChamsLoop = task.spawn(function()
		while SafeChamsEnabled do
			local map = Workspace:FindFirstChild("Map")
			local bredMakurz = map and map:FindFirstChild("BredMakurz")
			if bredMakurz then
				for _, obj in bredMakurz:GetChildren() do
					if string.find(string.lower(obj.Name), "safe") then
						local vals = obj:FindFirstChild("Values")
						local broken = vals and vals:FindFirstChild("Broken")
						if broken then
							local hl = obj:FindFirstChild("SafeHighlight")
							if broken.Value == false then
								if not hl then
									hl = Instance.new("Highlight")
									hl.Name = "SafeHighlight"
									hl.FillColor = Color3.fromRGB(0, 255, 0)
									hl.FillTransparency = 0.5
									hl.OutlineColor = Color3.fromRGB(0, 0, 0)
									hl.Parent = obj
								end
							else
								if hl then hl:Destroy() end
							end
						end
					end
				end
			end
			task.wait(1)
		end
		local map = Workspace:FindFirstChild("Map")
		local bredMakurz = map and map:FindFirstChild("BredMakurz")
		if bredMakurz then
			for _, obj in bredMakurz:GetChildren() do
				local hl = obj:FindFirstChild("SafeHighlight")
				if hl then hl:Destroy() end
			end
		end
		SafeChamsLoop = nil
	end)
end

local function clearBoxes(p: Player)
	if BoxESP.Boxes[p] then
		for _, b in BoxESP.Boxes[p] do
			b:Destroy()
		end
		BoxESP.Boxes[p] = nil
	end
end

local function createAdorn(class: string, part: BasePart, name: string, z: number, color: Color3, alpha: number, size: Vector2|Vector3): GuiObject
	local a = Instance.new(class) :: any
	a.Name = name
	a.Adornee = part
	a.AlwaysOnTop = true
	a.ZIndex = z
	a.Color3 = color
	a.Transparency = alpha
	a.Parent = CoreGui
	if class == "BoxHandleAdornment" then
		a.Size = size
	else
		a.Height = size.Y
		a.Radius = size.X
		a.CFrame = CFrame.Angles(math.rad(90), 0, 0)
	end
	return a
end

local function updatePlayerBoxes(p: Player?)
	if not p or not espSets.enabled then clearBoxes(p) return end
	if espSets.targetOnly and not table.find(TargetList, p.Name) then clearBoxes(p) return end
	local char = p.Character
	if not char or not char:FindFirstChildOfClass("Humanoid") then return end
	clearBoxes(p)
	BoxESP.Boxes[p] = {}
	for _, pn in bodyParts do
		local obj = char:FindFirstChild(pn)
		if obj and obj:IsA("BasePart") then
			if obj.Name == "Head" then
				local s = (obj.Size.X / 2) * 0.6
				if espSets.outline then
					table.insert(BoxESP.Boxes[p], createAdorn("CylinderHandleAdornment", obj, "out", -1, espSets.outCol, espSets.outAlpha, Vector2.new(s + espSets.outSize, obj.Size.Z + espSets.outSize)))
				end
				if espSets.inline then
					table.insert(BoxESP.Boxes[p], createAdorn("CylinderHandleAdornment", obj, "in", 1, espSets.inCol, espSets.inAlpha, Vector2.new(s + espSets.inSize, obj.Size.Z + espSets.inSize)))
				end
			else
				if espSets.outline then
					table.insert(BoxESP.Boxes[p], createAdorn("BoxHandleAdornment", obj, "out", -1, espSets.outCol, espSets.outAlpha, obj.Size + Vector3.new(espSets.outSize, espSets.outSize, espSets.outSize)))
				end
				if espSets.inline then
					table.insert(BoxESP.Boxes[p], createAdorn("BoxHandleAdornment", obj, "in", 1, espSets.inCol, espSets.inAlpha, obj.Size + Vector3.new(espSets.inSize, espSets.inSize, espSets.inSize)))
				end
			end
		end
	end
end

local function refreshAllESP()
	for _, p in Players:GetPlayers() do
		updatePlayerBoxes(p)
	end
end

local function VisualizeRay(o: Vector3, t: Vector3, col: Color3)
	if not Debug_Rays then return end
	local d = (t - o).Magnitude
	if d < 0.1 then return end
	local rp = Instance.new("Part")
	rp.Anchored = true
	rp.CanCollide = false
	rp.Material = Enum.Material.Neon
	rp.Color = col
	rp.Size = Vector3.new(0.05, 0.05, d)
	rp.CFrame = CFrame.lookAt(o, t) * CFrame.new(0, 0, -d / 2)
	rp.Parent = Workspace
	Debris:AddItem(rp, 1)
end

local function CheckWallbang(p1: Vector3, p2: Vector3): boolean
	local params = RaycastParams.new()
	params.FilterDescendantsInstances = { LocalPlayer.Character, Camera }
	params.FilterType = Enum.RaycastFilterType.Exclude
	local d = (p2 - p1).Magnitude
	local r = Workspace:Raycast(p1, (p2 - p1).Unit * d, params)
	local ok = not r or (r.Position - p2).Magnitude <= 24
	if Debug_Rays then
		VisualizeRay(p1, if ok then p2 else (r and r.Position or p2), if ok then Color3.new(0, 1, 0) else Color3.new(1, 0, 0))
	end
	return ok
end

local function GetTarget(): Player?
	local char = LocalPlayer.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then return nil end
	local best: Player? = nil
	local metric = math.huge
	local ml = UIS:GetMouseLocation()
	local sc = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
	local myPos = GetLocalRealPosition()
	for _, p in Players:GetPlayers() do
		if p ~= LocalPlayer and p.Character then
			if not table.find(WhiteList, p.Name) and not (TargetMode == "Lock" and #TargetList > 0 and not table.find(TargetList, p.Name)) then
				local pr = p.Character:FindFirstChild("HumanoidRootPart")
				local ph = p.Character:FindFirstChildOfClass("Humanoid")
				if pr and ph and ph.Health > (if DownCheck then 15 else 0) and not p.Character:FindFirstChildOfClass("ForceField") then
					if TargetMode == "Near" or TargetMode == "Lock" then
						local d = (myPos - pr.Position).Magnitude
						if d < metric then metric = d; best = p end
					else
						local sp, on = Camera:WorldToViewportPoint(pr.Position)
						if on then
							local d2 = ((if TargetMode == "Mouse" then ml else sc) - Vector2.new(sp.X, sp.Y)).Magnitude
							if d2 < metric then metric = d2; best = p end
						end
					end
				end
			end
		end
	end
	return best
end

local function ApplyBodyFF()
	local char = LocalPlayer.Character
	if not char then return end
	for _, p in char:GetChildren() do
		if IsBodyPart(p) then
			p.Material = Enum.Material.ForceField
			p.Color = FF_S.Color
		end
	end
end

local function RestoreBody()
	for p, props in FF_S.BodyProps do
		if p and p.Parent then
			p.Material = props.Material
			p.Color = props.Color
		end
	end
	FF_S.BodyProps = {}
end

local function ApplyToolFF()
	local char = LocalPlayer.Character
	local tool = char and char:FindFirstChildOfClass("Tool")
	if tool then
		for _, p in tool:GetDescendants() do
			if p:IsA("BasePart") then
				p.Material = Enum.Material.ForceField
				p.Color = FF_S.Color
			end
		end
	end
end

local function RestoreTool()
	for p, props in FF_S.ToolProps do
		if p and p.Parent then
			p.Material = props.Material
			p.Color = props.Color
		end
	end
	FF_S.ToolProps = {}
end

local function GetAllPlayerNames(): {string}
	local n = {}
	for _, p in Players:GetPlayers() do
		if p ~= LocalPlayer then
			table.insert(n, p.Name)
		end
	end
	return n
end

local ScanVectors = {
	Vector3.new(1, 0, 0),
	Vector3.new(0, 0, 1),
	Vector3.new(0, 1, 0),
	-Vector3.new(1, 0, 0),
	-Vector3.new(0, 0, 1),
	-Vector3.new(0, 1, 0),
	Vector3.new(1, 1, 0) / math.sqrt(2),
	Vector3.new(1, 0, 1) / math.sqrt(2),
	Vector3.new(0, 1, 1) / math.sqrt(2),
	Vector3.new(-1, 1, 0) / math.sqrt(2),
	Vector3.new(-1, 0, 1) / math.sqrt(2),
	-Vector3.new(1, 0, 1) / math.sqrt(2),
	-Vector3.new(-1, 0, 1) / math.sqrt(2),
	-Vector3.new(0, -1, 1) / math.sqrt(2),
	Vector3.new(1, 1, 1) / math.sqrt(3),
	Vector3.new(-1, 1, 1) / math.sqrt(3),
	Vector3.new(1, 1, -1) / math.sqrt(3),
	-Vector3.new(1, 1, 1) / math.sqrt(3),
	-Vector3.new(1, -1, 1) / math.sqrt(3),
	Vector3.new(1, 2, 0) / math.sqrt(5),
	Vector3.new(-1, 2, 0) / math.sqrt(5),
	Vector3.new(1, 0, 2) / math.sqrt(5),
	Vector3.new(-1, 0, 2) / math.sqrt(5),
	-Vector3.new(-1, 0, 2) / math.sqrt(5),
	-Vector3.new(1, 0, 2) / math.sqrt(5),
}

local function GetOffsets_Algo1(firePos: Vector3, targetPos: Vector3, offset: number): {Vector3}
	if not offset or offset <= 0 then return { firePos } end
	local offsets = { firePos }
	local cfOffset = CFrame.new(firePos, targetPos) * CFrame.Angles(0, 0, math.rad(math.random(1, 90)))
	for _, pos in ScanVectors do
		table.insert(offsets, cfOffset * (pos * offset))
	end
	return offsets
end

local function GetOffsets_Algo2(center: Vector3, poleDir: Vector3, radius: number, count: number): {Vector3}
	if not radius or radius <= 0 or count <= 0 then return { center } end
	local offsets = { center }
	local PHI = 0.6180339887
	local arb = if math.abs(poleDir.X) < 0.9 then Vector3.new(1, 0, 0) else Vector3.new(0, 1, 0)
	local t1 = poleDir:Cross(arb).Unit
	local t2 = poleDir:Cross(t1).Unit
	for i = 0, count - 1 do
		local phi = i * PHI * 2 * math.pi
		local cosT = 1 - (i + 0.5) / count
		local sinT = math.sqrt(1 - cosT * cosT)
		local r = radius * (math.random() ^ (1 / 3))
		local dir = t1 * (sinT * math.cos(phi)) + t2 * (sinT * math.sin(phi)) + poleDir * cosT
		table.insert(offsets, center + dir * r)
	end
	return offsets
end

local function DoRagebot()
	if not RB_State then Valid_Pair = nil; Locked_Path = nil; return end
	local target = GetTarget()
	if not target or not target.Character then Valid_Pair = nil; Locked_Path = nil; return end
	if Locked_Path and Locked_Path.Target ~= target then Locked_Path = nil end
	local myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	local tRoot = target.Character:FindFirstChild("HumanoidRootPart")
	if not myRoot or not tRoot then return end
	local myPos = GetLocalRealPosition()
	local tPos = tRoot.Position

	if Locked_Path then
		local dO = (myPos - Locked_Path.MyPos).Magnitude
		local dH = (tPos - Locked_Path.TPos).Magnitude
		local inRange = (myPos - Locked_Path.AbsO).Magnitude <= Origin_Radius and (tPos - Locked_Path.AbsH).Magnitude <= Hit_Radius
		if dO <= WB.Threshold and dH <= WB.Threshold and inRange then
			if CheckWallbang(Locked_Path.AbsO, Locked_Path.AbsH) then
				Valid_Pair = { Origin = Locked_Path.AbsO, Hit = Locked_Path.AbsH, Target = target }
				WB.Cached = true
				return
			end
		end
		Locked_Path = nil
	end

	if tick() - WB.LastScan < 1 / ScanRate then return end
	WB.LastScan = tick()
	WB.Round += 1

	local newOrigin: {Vector3}
	local newTarget: {Vector3}
	if WB.Round % 2 == 0 then
		newOrigin = GetOffsets_Algo1(myPos, tPos, Origin_Radius)
		newTarget = GetOffsets_Algo1(tPos, myPos, Hit_Radius)
	else
		local oPole = (tPos - myPos)
		if oPole.Magnitude < 0.001 then return end
		oPole = oPole.Unit
		local hPole = -oPole
		newOrigin = GetOffsets_Algo2(myPos, oPole, Origin_Radius, Origin_Scans)
		newTarget = GetOffsets_Algo2(tPos, hPole, Hit_Radius, Hit_Scans)
	end

	local bestPO: Vector3? = nil
	local bestPH: Vector3? = nil
	for _, pO in newOrigin do
		for _, pH in newTarget do
			if CheckWallbang(pO, pH) then
				bestPO = pO
				bestPH = pH
				break
			end
		end
		if bestPO then break end
	end

	if bestPO then
		Locked_Path = { AbsO = bestPO, AbsH = bestPH, Target = target, MyPos = myPos, TPos = tPos }
		Valid_Pair = { Origin = bestPO, Hit = bestPH, Target = target }
		WB.Cached = false
	else
		Valid_Pair = nil
	end
end

do
	local ok1, ok2 = pcall(function()
		SA.VisualizeEvent = RepStorage:WaitForChild("Events2", 5):WaitForChild("Visualize", 5)
	end), pcall(function()
		SA.DamageEvent = ZF_H
	end)
	if SA.VisualizeEvent then
		SA.VisualizeEvent.Event:Connect(function(_, key, _, Gun, _, StartPos, BulletsPerShot)
			if not SA.Enabled then return end
			if math.random(1, 100) > SA.HitChance then return end
			local myTool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
			if not myTool or Gun ~= myTool then return end
			local partName = SA.TargetPart
			local center: Vector2
			if SA.FOV_PositionMode == "Mouse" then
				center = UIS:GetMouseLocation()
			else
				center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
			end
			local target: Player? = nil
			local shortestDist = SA.FOV_Radius
			for _, v in Players:GetPlayers() do
				if v == LocalPlayer or not v.Character then continue end
				local h = v.Character:FindFirstChildOfClass("Humanoid")
				if not h or h.Health <= 0 then continue end
				if v.Character:FindFirstChildOfClass("ForceField") then continue end
				local part = v.Character:FindFirstChild(partName)
				if not part then continue end
				local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
				if not onScreen then continue end
				local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
				if dist < shortestDist then
					if SA.WallCheck then
						local ignore = { Camera, LocalPlayer.Character, v.Character }
						if #Camera:GetPartsObscuringTarget({ part.Position }, ignore) > 0 then continue end
					end
					target = v
					shortestDist = dist
				end
			end
			if not target or not target.Character then return end
			local hitPart = target.Character:FindFirstChild(partName)
			if not hitPart then return end
			local hitPos = hitPart.Position
			local lookVec = (hitPos - StartPos).Unit
			task.wait(0.005)
			for i = 1, #BulletsPerShot do
				SA.DamageEvent:FireServer("🧈", Gun, key, i, hitPart, hitPos, lookVec)
			end
			if Gun:FindFirstChild("Hitmarker") then
				Gun.Hitmarker:Fire(hitPart)
			end
		end)
	end
end

local Window = WindUI:CreateWindow({
	Title = "XIAOXI HUB",
	Folder = "ftgshub",
	NewElements = true,
	HideSearchBar = false,
	Size = UDim2.fromOffset(600, 450),
	Theme = "Dark",
	UserEnabled = true,
	SideBarWidth = 135,
	HasOutline = true,
	OpenButton = {
		Title = "XIAOXI HUB",
		CornerRadius = UDim.new(1, 0),
		StrokeThickness = 1.5,
		Enabled = true,
		Draggable = true,
		OnlyMobile = false,
		Color = ColorSequence.new(Color3.fromHex("FFFFFF"), Color3.fromHex("FFFFFF")),
	},
	Topbar = { Height = 44, ButtonsType = "Close" },
})

Window:Tag({ Title = "付费版", Radius = 4, Color = Color3.fromHex("#ffffff") })
Window:Tag({ Title = "犯罪", Radius = 4, Color = Color3.fromHex("#ffffff") })

local AboutTab = Window:Tab({ Title = "公告", Desc = "脚本信息", Icon = "solar:info-square-bold", IconColor = Color3.fromHex("#999999"), IconShape = "Square", Border = true })
local CombatTab = Window:Tab({ Title = "战斗", Desc = "战斗相关", Icon = "rbxassetid://106487037258687", IconColor = Color3.fromHex("#999999"), IconShape = "Square", Border = true })
local VisualsTab = Window:Tab({ Title = "视觉", Desc = "视觉相关", Icon = "solar:eye-bold", IconColor = Color3.fromHex("#999999"), IconShape = "Square", Border = true })
local PlayerTab = Window:Tab({ Title = "玩家", Desc = "玩家相关", Icon = "solar:user-bold", IconColor = Color3.fromHex("#999999"), IconShape = "Square", Border = true })
local AntisTab = Window:Tab({ Title = "反自瞄", Desc = "反自瞄相关", Icon = "solar:shield-bold", IconColor = Color3.fromHex("#999999"), IconShape = "Square", Border = true })
local MiscTab = Window:Tab({ Title = "杂项", Desc = "杂项功能", Icon = "solar:settings-bold", IconColor = Color3.fromHex("#999999"), IconShape = "Square", Border = true })
local PlayerListTab = Window:Tab({ Title = "玩家列表", Desc = "玩家列表", Icon = "solar:users-group-rounded-bold", IconColor = Color3.fromHex("#999999"), IconShape = "Square", Border = true })

AboutTab:Paragraph({
	Title = "XIAOXI 脚本",
	Desc = "作者：小西｜犯罪脚本",
	ImageSize = 50,
	Thumbnail = "https://raw.githubusercontent.com/xiaoxi9008/Server./refs/heads/main/7fdb4ab15ea4447bc9566c7caf856f82fc31ae85362243f5f0dd837a41c9ea86.png",
	ThumbnailSize = 170,
})
AboutTab:Divider()
AboutTab:Button({
	Title = "显示欢迎通知",
	Icon = "bell",
	Color = Color3.fromHex("#999999"),
	Callback = function()
		WindUI:Notify({ Title = "欢迎!", Content = "感谢使用XIAOXI付费版", Icon = "heart", Duration = 3 })
	end,
})

local SASection = CombatTab:Section({ Title = "Silent Aim", Desc = "静默自瞄设置", Side = "Left" })
SASection:Toggle({ Title = "启用", Value = false, Callback = function(v: boolean) SA.Enabled = v end })
SASection:Dropdown({
	Title = "目标部位",
	Value = "Head",
	Values = { "Random", "Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg" },
	Callback = function(v: string)
		if v == "Random" then
			SA.IsRandom = true
			SA.RandomIdx = 1
			SA.RandomTimer = 0
			SA.TargetPart = SA.RandomParts[1]
		else
			SA.IsRandom = false
			SA.TargetPart = v
		end
	end,
})
SASection:Slider({ Title = "命中率", Value = { Min = 0, Max = 100, Default = 100 }, Callback = function(v: number) SA.HitChance = v end })
SASection:Toggle({ Title = "穿墙检测", Value = true, Callback = function(v: boolean) SA.WallCheck = v end })

local FOVSection = CombatTab:Section({ Title = "FOV", Desc = "FOV 设置", Side = "Right" })
FOVSection:Toggle({ Title = "绘制FOV", Value = false, Callback = function(v: boolean) SA.FOV_Visible = v end })
FOVSection:Colorpicker({ Title = "颜色", Value = Color3.fromRGB(255, 0, 0), Callback = function(v: Color3) SA.FOV_Color = v end })
FOVSection:Dropdown({ Title = "位置", Value = "Center", Values = { "Center", "Mouse" }, Callback = function(v: string) SA.FOV_PositionMode = v end })
FOVSection:Slider({ Title = "半径", Value = { Min = 10, Max = 600, Default = 100 }, Callback = function(v: number) SA.FOV_Radius = v end })
FOVSection:Slider({ Title = "边数", Value = { Min = 3, Max = 32, Default = 16 }, Callback = function(v: number) SA.FOV_Sides = math.floor(v) end })
FOVSection:Toggle({ Title = "旋转", Value = false, Callback = function(v: boolean) SA.FOV_SpinEnabled = v end })
FOVSection:Slider({ Title = "旋转速度", Value = { Min = 0, Max = 500, Default = 50 }, Callback = function(v: number) SA.FOV_SpinSpeed = v end })

local CamSection = CombatTab:Section({ Title = "Camlock", Desc = "瞄准锁定设置", Side = "Left" })
CamSection:Toggle({ Title = "启用", Value = false, Callback = function(v: boolean) CL.Enabled = v end })
CamSection:Toggle({ Title = "仅目标", Value = false, Callback = function(v: boolean) CL.TargetOnly = v end })
CamSection:Toggle({ Title = "自动预判", Value = false, Callback = function(v: boolean) CL.AutoPrediction = v end })
CamSection:Toggle({ Title = "倒地检测", Value = false, Callback = function(v: boolean) CL.DownCheck = v end })
CamSection:Slider({ Title = "FOV", Value = { Min = 10, Max = 800, Default = 170 }, Callback = function(v: number) CL.FOV = v end })
CamSection:Slider({ Title = "强度", Value = { Min = 0.1, Max = 1, Default = 1 }, Callback = function(v: number) CL.Power = v end })
CamSection:Slider({ Title = "抖动强度", Value = { Min = 0, Max = 1, Default = 0.2 }, Callback = function(v: number) CL.Shake = v end })
CamSection:Slider({ Title = "切换延迟", Value = { Min = 0.1, Max = 1, Default = 0.1 }, Callback = function(v: number) CL.Delay = v end })

local CamConfigSection = CombatTab:Section({ Title = "Camlock 配置", Desc = "瞄准锁定配置", Side = "Right" })
CamConfigSection:Dropdown({
	Title = "目标部位",
	Value = { "Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg" },
	Values = { "Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg" },
	Multi = true,
	Callback = function(v: {string}) CL.TargetParts = v end,
})

local LGOtherSection = CombatTab:Section({ Title = "其他", Desc = "其他设置", Side = "Right" })
LGOtherSection:Toggle({
	Title = "无后坐力",
	Value = false,
	Callback = function(v: boolean)
		if v then NR_Enable() else NR_Disable() end
	end,
})
LGOtherSection:Slider({
	Title = "后坐力",
	Value = { Min = 0, Max = 1, Default = 0 },
	Callback = function(v: number)
		NR.RecoilVal = v
		if NR.Enabled then NR_Apply() end
	end,
})

local MeleeSection = CombatTab:Section({ Title = "近战光环", Desc = "近战攻击设置", Side = "Left" })
MeleeSection:Toggle({
	Title = "启用",
	Value = false,
	Callback = function(v: boolean)
		MA.Enabled = v
		if v then StartMeleeLoop() end
	end,
})
MeleeSection:Toggle({ Title = "仅目标", Value = false, Callback = function(v: boolean) MA.TargetOnly = v end })
MeleeSection:Toggle({ Title = "倒地检测", Value = false, Callback = function(v: boolean) MA.DownCheck = v end })
MeleeSection:Slider({ Title = "距离", Value = { Min = 5, Max = 25, Default = 20 }, Callback = function(v: number) MA.Distance = v end })
MeleeSection:Toggle({ Title = "显示动画", Value = true, Callback = function(v: boolean) MA.ShowAnim = v end })
MeleeSection:Dropdown({
	Title = "目标部位",
	Value = "Random",
	Values = { "Random", "Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg" },
	Callback = function(v: string) MA.TargetPart = v end,
})

local RageSection = CombatTab:Section({ Title = "Ragebot", Desc = "暴力自瞄设置", Side = "Left" })
RageSection:Toggle({ Title = "启用", Value = false, Callback = function(v: boolean) RB_State = v end })
RageSection:Toggle({ Title = "快速射击", Value = false, Callback = function(v: boolean) RF_State = v end })
RageSection:Toggle({
	Title = "自动换弹",
	Value = false,
	Callback = function(v: boolean)
		AutoReload = v
		if v then AutoReloadSetup() else clearReloadConnections() end
	end,
})
RageSection:Toggle({ Title = "倒地检测", Value = false, Callback = function(v: boolean) DownCheck = v end })
RageSection:Slider({ Title = "最大缓存", Value = { Min = 0.1, Max = 25, Default = 0.5 }, Callback = function(v: number) WB.Threshold = v end })
RageSection:Slider({ Title = "原点半径", Value = { Min = 0.1, Max = 20, Default = 18.50 }, Callback = function(v: number) Origin_Radius = v end })
RageSection:Slider({ Title = "原点扫描数", Value = { Min = 1, Max = 50, Default = 24 }, Callback = function(v: number) Origin_Scans = math.floor(v) end })
RageSection:Slider({ Title = "扫描频率", Value = { Min = 1, Max = 60, Default = 14 }, Callback = function(v: number) ScanRate = math.floor(v) end })
RageSection:Slider({ Title = "命中半径", Value = { Min = 0.1, Max = 25, Default = 23.50 }, Callback = function(v: number) Hit_Radius = v end })
RageSection:Slider({ Title = "命中扫描数", Value = { Min = 1, Max = 50, Default = 24 }, Callback = function(v: number) Hit_Scans = math.floor(v) end })

local TargetSection = CombatTab:Section({ Title = "目标选择", Desc = "目标选择设置", Side = "Right" })
TargetSection:Dropdown({
	Title = "目标模式",
	Value = "Near",
	Values = { "Near", "Mouse", "Centre", "Lock" },
	Callback = function(v: string) TargetMode = v end,
})
TargetSection:Dropdown({
	Title = "命中音效",
	Value = "None",
	Values = { "None", "Skeet", "Neverlose", "Gamesense" },
	Callback = function(v: string) HitSoundSelection = v end,
})

local LightingSection = VisualsTab:Section({ Title = "光照", Desc = "光照设置", Side = "Left" })
LightingSection:Toggle({ Title = "光照模式", Value = false, Callback = function(v: boolean) WV.LightingModeEnabled = v end })
LightingSection:Dropdown({
	Title = "技术",
	Value = "ShadowMap",
	Values = { "Compatibility", "ShadowMap", "Voxel", "Future" },
	Callback = function(v: string) WV.LightingMode = v end,
})
LightingSection:Toggle({ Title = "世界时间", Value = false, Callback = function(v: boolean) WV.WorldTimeEnabled = v end })
LightingSection:Slider({ Title = "时间", Value = { Min = 0, Max = 24, Default = 12 }, Callback = function(v: number) WV.WorldTime = v end })
LightingSection:Toggle({ Title = "自定义环境光", Value = false, Callback = function(v: boolean) WV.AmbientEnabled = v end })
LightingSection:Colorpicker({ Title = "室内", Value = Color3.fromRGB(255, 255, 255), Callback = function(v: Color3) WV.AmbientColor = v end })
LightingSection:Colorpicker({ Title = "室外", Value = Color3.fromRGB(255, 255, 255), Callback = function(v: Color3) WV.OutdoorAmbientColor = v end })

local CameraSection = VisualsTab:Section({ Title = "相机", Desc = "相机设置", Side = "Left" })
CameraSection:Slider({
	Title = "FOV",
	Value = { Min = 50, Max = 180, Default = 70 },
	Callback = function(v: number)
		CAM_FOV = math.floor(v)
		Camera.FieldOfView = CAM_FOV
		if not CAM_FOV_Conn then
			CAM_FOV_Conn = Camera:GetPropertyChangedSignal("FieldOfView"):Connect(function()
				if CAM_FOV and Camera.FieldOfView ~= CAM_FOV then
					Camera.FieldOfView = CAM_FOV
				end
			end)
		end
	end,
})
CameraSection:Slider({
	Title = "相机距离",
	Value = { Min = 1, Max = 40, Default = 10 },
	Callback = function(v: number)
		LocalPlayer.CameraMaxZoomDistance = v
		pcall(function() game:GetService("StarterPlayer").CameraMaxZoomDistance = v end)
	end,
})

local SkySection = VisualsTab:Section({ Title = "天空与天气", Desc = "天空与天气设置", Side = "Right" })
SkySection:Toggle({ Title = "自定义天空盒", Value = false, Callback = function(v: boolean) WV.SkyboxEnabled = v end })
SkySection:Dropdown({
	Title = "天空盒主题",
	Value = "Black Storm",
	Values = { "Black Storm", "Blue Space", "Realistic", "Stormy", "Pink" },
	Callback = function(v: string) WV.SkyboxType = v end,
})
SkySection:Toggle({
	Title = "天气",
	Value = false,
	Callback = function(v: boolean)
		WV.WeatherEnabled = v
		WV_WeatherPart.Parent = if v then Workspace else nil
	end,
})
SkySection:Colorpicker({
	Title = "颜色",
	Value = Color3.fromRGB(255, 255, 255),
	Callback = function(v: Color3)
		WV.WeatherColor = v
		WV_Emitter.Color = ColorSequence.new(v)
	end,
})
SkySection:Dropdown({
	Title = "天气类型",
	Value = "Rain",
	Values = { "Rain", "Snow" },
	Callback = function(v: string)
		WV.WeatherType = v
		if v == "Rain" then
			WV_Emitter.Texture = "rbxassetid://1822883048"
			WV_Emitter.Speed = NumberRange.new(60)
			WV_Emitter.Size = NumberSequence.new(10)
		else
			WV_Emitter.Texture = "http://www.roblox.com/asset/?id=99851851"
			WV_Emitter.Speed = NumberRange.new(30)
			WV_Emitter.Size = NumberSequence.new(0.35)
		end
	end,
})
SkySection:Slider({
	Title = "天气频率",
	Value = { Min = 100, Max = 2000, Default = 600 },
	Callback = function(v: number)
		local r = tonumber(v)
		if r == r then WV_Emitter.Rate = r end
	end,
})

local AtmoSection = VisualsTab:Section({ Title = "大气", Desc = "大气设置", Side = "Right" })
AtmoSection:Toggle({ Title = "大气", Value = false, Callback = function(v: boolean) WV.AtmosphereEnabled = v end })
AtmoSection:Colorpicker({ Title = "颜色", Value = Color3.fromRGB(255, 255, 255), Callback = function(v: Color3) WV.AtmoColor = v end })
AtmoSection:Colorpicker({ Title = "衰减", Value = Color3.fromRGB(120, 120, 120), Callback = function(v: Color3) WV.AtmoDecay = v end })
AtmoSection:Slider({ Title = "密度", Value = { Min = 0, Max = 1, Default = 0.35 }, Callback = function(v: number) WV.AtmoDensity = v end })
AtmoSection:Slider({ Title = "雾霾", Value = { Min = 0, Max = 10, Default = 1 }, Callback = function(v: number) WV.AtmoHaze = v end })
AtmoSection:Slider({ Title = "眩光", Value = { Min = 0, Max = 10, Default = 10 }, Callback = function(v: number) WV.AtmoGlare = v end })

local AudioSection = VisualsTab:Section({ Title = "音频", Desc = "音频设置", Side = "Right" })
AudioSection:Toggle({
	Title = "背景噪音",
	Value = false,
	Callback = function(v: boolean)
		if v then WV_BGSound:Play() else WV_BGSound:Stop() end
	end,
})
AudioSection:Dropdown({
	Title = "音轨",
	Value = "Night",
	Values = { "Windy Winter", "Thunderstorm", "Light Rain", "Night", "Day" },
	Callback = function(v: string)
		WV_BGSound.SoundId = WV_Sounds[v]
		if WV_BGSound.IsPlaying then
			WV_BGSound:Stop()
			WV_BGSound:Play()
		end
	end,
})
AudioSection:Slider({
	Title = "音量",
	Value = { Min = 0, Max = 100, Default = 25 },
	Callback = function(v: number)
		local vol = tonumber(v)
		if vol == vol then WV_BGSound.Volume = vol / 100 end
	end,
})

local SkinSection = VisualsTab:Section({ Title = "皮肤", Desc = "皮肤设置", Side = "Left" })
SkinSection:Toggle({
	Title = "力场身体",
	Value = false,
	Callback = function(v: boolean)
		FF_S.BodyEnabled = v
		if v then
			local char = LocalPlayer.Character
			if char then
				for _, p in char:GetChildren() do
					if IsBodyPart(p) and not FF_S.BodyProps[p] then
						FF_S.BodyProps[p] = { Material = p.Material, Color = p.Color }
					end
				end
			end
			task.delay(0.1, function()
				if FF_S.BodyEnabled then ApplyBodyFF() end
			end)
		else
			RestoreBody()
		end
	end,
})
SkinSection:Colorpicker({
	Title = "颜色",
	Value = FF_S.Color,
	Callback = function(c: Color3)
		FF_S.Color = c
		if FF_S.BodyEnabled then ApplyBodyFF() end
	end,
})
SkinSection:Toggle({
	Title = "力场工具",
	Value = false,
	Callback = function(v: boolean)
		FF_S.ToolEnabled = v
		if v then
			local char = LocalPlayer.Character
			local tool = char and char:FindFirstChildOfClass("Tool")
			if tool then
				for _, p in tool:GetDescendants() do
					if p:IsA("BasePart") and not FF_S.ToolProps[p] then
						FF_S.ToolProps[p] = { Material = p.Material, Color = p.Color }
					end
				end
			end
			task.delay(0.1, function()
				if FF_S.ToolEnabled then ApplyToolFF() end
			end)
		else
			RestoreTool()
		end
	end,
})

local TracerSection = VisualsTab:Section({ Title = "子弹追踪", Desc = "子弹追踪设置", Side = "Left" })
TracerSection:Toggle({ Title = "启用", Value = false, Callback = function(v: boolean) TR.Enabled = v end })
TracerSection:Colorpicker({ Title = "追踪颜色", Value = TR.Color, Callback = function(c: Color3, a: number) TR.Color = c; TR.Alpha = a end })
TracerSection:Slider({ Title = "大小", Value = { Min = 0.1, Max = 10, Default = 1 }, Callback = function(v: number) TR.Size = v end })

local HitLogSection = VisualsTab:Section({ Title = "命中日志", Desc = "命中日志设置", Side = "Left" })
HitLogSection:Toggle({
	Title = "启用",
	Value = false,
	Callback = function(v: boolean)
		HitLogEnabled = v
		if HitLog.Gui then HitLog.Gui.Enabled = v end
	end,
})

local AmbSection = VisualsTab:Section({ Title = "氛围", Desc = "氛围设置", Side = "Left" })
AmbSection:Toggle({
	Title = "氛围",
	Value = false,
	Callback = function(v: boolean)
		AMB.Enabled = v
		if not v then
			local cc = Camera:FindFirstChild("CATColorCorr")
			if cc then cc.Enabled = false end
		end
	end,
})
AmbSection:Colorpicker({ Title = "雾色", Value = Color3.fromRGB(190, 220, 255), Callback = function(c: Color3) AMB.Color = c end })
AmbSection:Slider({ Title = "雾密度", Value = { Min = 0, Max = 1, Default = 0.45 }, Callback = function(v: number) AMB.Density = v end })
AmbSection:Slider({ Title = "亮度", Value = { Min = -1, Max = 1, Default = 0.15 }, Callback = function(v: number) AMB.Brightness = v end })

local ESPSection = VisualsTab:Section({ Title = "ESP", Desc = "ESP 设置", Side = "Right" })
ESPSection:Toggle({
	Title = "名称标签",
	Value = false,
	Callback = function(v: boolean)
		NametagEnabled = v
		if not v then
			for _, p in Players:GetPlayers() do
				local t = p.Character and p.Character:FindFirstChild("CAT_NameTag")
				local l = t and t:FindFirstChild("L")
				if l then
					l.Visible = false
					if not DistanceEnabled then t.Enabled = false end
				end
			end
		end
	end,
})
ESPSection:Toggle({
	Title = "距离",
	Value = false,
	Callback = function(v: boolean)
		DistanceEnabled = v
		if not v then
			for _, p in Players:GetPlayers() do
				local t = p.Character and p.Character:FindFirstChild("CAT_NameTag")
				local l = t and t:FindFirstChild("DL")
				if l then
					l.Visible = false
					if not NametagEnabled then t.Enabled = false end
				end
			end
		end
	end,
})
ESPSection:Toggle({
	Title = "生命值",
	Value = false,
	Callback = function(v: boolean)
		HealthEnabled = v
		if not v then
			for _, p in Players:GetPlayers() do
				local t = p.Character and p.Character:FindFirstChild("CAT_NameTag")
				local l = t and t:FindFirstChild("HL")
				if l then l.Visible = false end
			end
		end
	end,
})
ESPSection:Toggle({
	Title = "保险箱透视",
	Value = false,
	Callback = function(v: boolean)
		SafeChamsEnabled = v
		if v then StartSafeChams() end
	end,
})
ESPSection:Toggle({
	Title = "Chams",
	Value = false,
	Callback = function(v: boolean)
		espSets.enabled = v
		if not v then
			if BoxESP.Conn.M then BoxESP.Conn.M:Disconnect() end
			for _, c in BoxESP.Conn do
				if typeof(c) == "RBXScriptConnection" then c:Disconnect() end
			end
			for p in BoxESP.Boxes do clearBoxes(p) end
			BoxESP = { Boxes = {}, Conn = {} }
		else
			local function s(p: Player)
				if p == LocalPlayer then return end
				BoxESP.Conn[p] = p.CharacterAdded:Connect(function()
					task.wait(0.5)
					updatePlayerBoxes(p)
				end)
				if p.Character then updatePlayerBoxes(p) end
			end
			for _, p in Players:GetPlayers() do s(p) end
			BoxESP.Conn.M = Players.PlayerAdded:Connect(s)
		end
	end,
})
ESPSection:Colorpicker({
	Title = "轮廓颜色",
	Value = espSets.outCol,
	Callback = function(c: Color3, a: number)
		espSets.outCol = c
		espSets.outAlpha = a
		if espSets.enabled then refreshAllESP() end
	end,
})
ESPSection:Toggle({
	Title = "仅目标",
	Value = false,
	Callback = function(v: boolean)
		espSets.targetOnly = v
		if espSets.enabled then refreshAllESP() end
	end,
})
ESPSection:Toggle({ Title = "轮廓", Value = true, Callback = function(v: boolean) espSets.outline = v end })
ESPSection:Toggle({ Title = "内联", Value = true, Callback = function(v: boolean) espSets.inline = v end })
ESPSection:Colorpicker({
	Title = "内联颜色",
	Value = espSets.inCol,
	Callback = function(c: Color3, a: number)
		espSets.inCol = c
		espSets.inAlpha = a
		if espSets.enabled then refreshAllESP() end
	end,
})
ESPSection:Slider({ Title = "轮廓大小", Value = { Min = 0.01, Max = 1, Default = 0.1 }, Callback = function(v: number) espSets.outSize = v end })
ESPSection:Slider({ Title = "内联大小", Value = { Min = 0.01, Max = 0.5, Default = 0.05 }, Callback = function(v: number) espSets.inSize = v end })

local MovementSection = PlayerTab:Section({ Title = "移动", Desc = "移动设置", Side = "Left" })
MovementSection:Toggle({ Title = "步行速度", Value = false, Callback = function(v: boolean) SpeedState = v end })
MovementSection:Slider({ Title = "速度值", Value = { Min = 1, Max = 100, Default = 33.5 }, Callback = function(v: number) SpeedValue = v end })
MovementSection:Toggle({ Title = "跳跃力量", Value = false, Callback = function(v: boolean) JumpState = v end })
MovementSection:Slider({ Title = "力量值", Value = { Min = 1, Max = 100, Default = 73 }, Callback = function(v: number) JumpValue = v end })
MovementSection:Toggle({ Title = "无坠落", Value = false, Callback = function(v: boolean) NoFallEnabled = v end })
MovementSection:Toggle({
	Title = "飞行",
	Value = false,
	Callback = function(v: boolean)
		FLY.Enabled = v
		if FLY.MobileMode then
			if v then FlyCreateUI(); FlyOn() else FlyOff(); FlyDestroyUI() end
		else
			if v then FlyOn() else FlyOff() end
		end
	end,
})
MovementSection:Slider({ Title = "飞行速度", Value = { Min = 1, Max = 100, Default = 60 }, Callback = function(v: number) FLY.Speed = v end })
MovementSection:Toggle({ Title = "手机模式", Value = false, Callback = function(v: boolean) FLY.MobileMode = v end })
MovementSection:Toggle({
	Title = "无限体力",
	Value = false,
	Callback = function(Value: boolean)
		InfStaminaEnabled = Value
		if InfStaminaConnection then InfStaminaConnection:Disconnect(); InfStaminaConnection = nil end
		if Value then
			local ok = pcall(function()
				local tgt = getupvalue(getrenv()._G.S_Take, 2)
				local old
				old = hookfunction(tgt, function(v1, ...) if InfStaminaEnabled then v1 = 0 end return old(v1, ...) end)
			end)
			if not ok then
				local tbs = {}
				local function collect()
					tbs = {}
					for _, v in getgc(true) do
						if typeof(v) == "table" and rawget(v, "S") then
							tbs[#tbs + 1] = v
						end
					end
				end
				pcall(collect)
				InfStaminaConnection = RunService.RenderStepped:Connect(function()
					if InfStaminaEnabled then
						if tick() % 5 < 0.1 then pcall(collect) end
						for _, t in tbs do pcall(function() t.S = 100 end) end
						local c = LocalPlayer.Character
						local h = c and c:FindFirstChildOfClass("Humanoid")
						if h then h:SetAttribute("ZSPRN_M", true) end
					end
				end)
			end
		else
			local c = LocalPlayer.Character
			local h = c and c:FindFirstChildOfClass("Humanoid")
			if h then h:SetAttribute("ZSPRN_M", nil) end
		end
	end,
})

local AntiHitSection = AntisTab:Section({ Title = "反自瞄", Desc = "反自瞄设置", Side = "Left" })
AntiHitSection:Dropdown({
	Title = "头部模式",
	Value = nil,
	Values = { "Hide head", "Yaw head", "Custom" },
	Callback = function(v: string?)
		if not v and OriginalNeckC0 then
			local ch = LocalPlayer.Character
			if ch then
				local hd = ch:FindFirstChild("Head")
				local ts = ch:FindFirstChild("UpperTorso") or ch:FindFirstChild("Torso")
				local nk = (hd and hd:FindFirstChild("Neck")) or (ts and ts:FindFirstChild("Neck"))
				if nk then nk.C0 = OriginalNeckC0; nk.C1 = OriginalNeckC1 end
			end
			OriginalNeckC0, OriginalNeckC1 = nil, nil
		end
		HeadYawTime = 0
		HeadMode = v
	end,
})
AntiHitSection:Slider({ Title = "自定义偏航", Value = { Min = -90, Max = 90, Default = 30 }, Callback = function(v: number) HeadYaw = v; HeadCustomYaw = v end })
AntiHitSection:Slider({ Title = "旋转速度", Value = { Min = -50, Max = 50, Default = 30 }, Callback = function(v: number) HeadRotSpeed = v end })
AntiHitSection:Dropdown({
	Title = "手部模式",
	Value = nil,
	Values = { "Hands up", "Open hands" },
	Callback = function(v: string?) HandsModSelection = v end,
})
AntiHitSection:Toggle({
	Title = "乱飞",
	Value = false,
	Callback = function(v: boolean)
		LF.Enabled = v
		if not v then
			if LF.Track1 then pcall(function() LF.Track1:Stop(0) end); LF.Track1 = nil end
			if LF.Track2 then pcall(function() LF.Track2:Stop(0) end); LF.Track2 = nil end
			LF.Angle = 0
		end
	end,
})
AntiHitSection:Toggle({
	Title = "隐身",
	Value = false,
	Callback = function(v: boolean)
		Invis_Enabled = v
		if not v then
			if Invis_Track then pcall(function() Invis_Track:Stop() end); Invis_Track = nil end
			local char = LocalPlayer.Character
			if char then
				for _, p in char:GetChildren() do
					if p:IsA("BasePart") and p.Transparency == 0.5 then
						p.Transparency = 0
					end
				end
			end
		end
	end,
})

local DesyncSection = AntisTab:Section({ Title = "速度不同步", Desc = "速度不同步设置", Side = "Right" })
DesyncSection:Toggle({ Title = "启用", Value = false, Callback = function(v: boolean) DS.Enabled = v end })
DesyncSection:Toggle({ Title = "可视化", Value = true, Callback = function(v: boolean) DS.Visualize = v end })
DesyncSection:Slider({ Title = "TP 频率", Value = { Min = 1, Max = 100, Default = 60 }, Callback = function(v: number) DS.TPRate = v end })
DesyncSection:Slider({ Title = "X 偏移", Value = { Min = 1, Max = 20, Default = 8.5 }, Callback = function(v: number) DS.X = v end })
DesyncSection:Slider({ Title = "Y 偏移", Value = { Min = 1, Max = 20, Default = 3 }, Callback = function(v: number) DS.Y = v end })
DesyncSection:Slider({ Title = "Z 偏移", Value = { Min = 1, Max = 20, Default = 8.5 }, Callback = function(v: number) DS.Z = v end })

local ShiftSection = MiscTab:Section({ Title = "Shiftlock", Desc = "Shiftlock 设置", Side = "Left" })
ShiftSection:Toggle({ Title = "反自动 Shiftlock", Value = false, Callback = function(v: boolean) MC.AntiShift = v end })
ShiftSection:Slider({ Title = "延迟", Value = { Min = 0.01, Max = 0.50, Default = 0.05 }, Callback = function(v: number) MC.ShiftDelay = v end })

local FarmSection = MiscTab:Section({ Title = "农场", Desc = "农场设置", Side = "Left" })
FarmSection:Toggle({
	Title = "自动捡钱",
	Value = false,
	Callback = function(v: boolean)
		SC.APM_Enabled = v
		if v then StartAutoPickUpMoney() end
	end,
})
FarmSection:Toggle({
	Title = "自动解锁保险箱",
	Value = false,
	Callback = function(v: boolean)
		SC.AUS_Enabled = v
		if v then StartAutoUnlockSafe() end
	end,
})

local CameraMiscSection = MiscTab:Section({ Title = "相机", Desc = "相机设置", Side = "Right" })
CameraMiscSection:Toggle({
	Title = "平滑相机",
	Value = false,
	Callback = function(v: boolean)
		MC.SmoothCam = v
		if not v then MC.SmoothPos = nil end
	end,
})
CameraMiscSection:Slider({ Title = "速度", Value = { Min = 1, Max = 10, Default = 6 }, Callback = function(v: number) MC.LerpSpeed = v end })

local TargetListSection = PlayerListTab:Section({ Title = "目标列表", Desc = "目标列表设置", Side = "Left" })
TargetListSection:Dropdown({
	Title = "目标",
	Value = {},
	Values = GetAllPlayerNames(),
	Multi = true,
	Callback = function(v: {string})
		TargetList = if typeof(v) == "table" then v else { v }
		if espSets.enabled and espSets.targetOnly then refreshAllESP() end
	end,
})
TargetListSection:Button({
	Title = "清除目标",
	Callback = function()
		TargetList = {}
		if espSets.enabled and espSets.targetOnly then refreshAllESP() end
	end,
})

local WhitelistSection = PlayerListTab:Section({ Title = "白名单", Desc = "白名单设置", Side = "Right" })
WhitelistSection:Dropdown({
	Title = "白名单",
	Value = {},
	Values = GetAllPlayerNames(),
	Multi = true,
	Callback = function(v: {string}) WhiteList = if typeof(v) == "table" then v else { v } end,
})
WhitelistSection:Button({ Title = "清除白名单", Callback = function() WhiteList = {} end })

Players.PlayerAdded:Connect(function(p: Player)
	task.wait(1)
	local allNames = GetAllPlayerNames()
	local function updateDropdowns()
		pcall(function()
			TargetListSection:Dropdown({
				Title = "目标",
				Value = TargetList,
				Values = allNames,
				Multi = true,
				Callback = function(v: {string})
					TargetList = if typeof(v) == "table" then v else { v }
					if espSets.enabled and espSets.targetOnly then refreshAllESP() end
				end,
			})
		end)
		pcall(function()
			WhitelistSection:Dropdown({
				Title = "白名单",
				Value = WhiteList,
				Values = allNames,
				Multi = true,
				Callback = function(v: {string}) WhiteList = if typeof(v) == "table" then v else { v } end,
			})
		end)
	end
	task.spawn(updateDropdowns)
end)

Players.PlayerRemoving:Connect(function(p: Player)
	clearBoxes(p)
	if p.Character then
		local t1 = p.Character:FindFirstChild("CAT_NameTag")
		local t2 = p.Character:FindFirstChild("CAT_FFTag")
		local t3 = p.Character:FindFirstChild("CAT_HPTag")
		if t1 then t1:Destroy() end
		if t2 then t2:Destroy() end
		if t3 then t3:Destroy() end
	end
end)

RunService:BindToRenderStep("InvisFix", 199, function()
	if not Invis_Enabled or DS.Enabled or LF.Enabled then Invis_SavedCF = nil; return end
	local char = LocalPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if hrp and Invis_SavedCF then hrp.CFrame = Invis_SavedCF; Invis_SavedCF = nil end
	if Invis_Track then pcall(function() Invis_Track:Stop() end) end
	if char then
		for _, p in char:GetChildren() do
			if p:IsA("BasePart") and (p.Name == "Head" or p.Name == "Torso" or p.Name:match("Arm") or p.Name:match("Leg")) then
				if p.Transparency ~= 0.5 then p.Transparency = 0.5 end
			end
		end
	end
end)

RunService:BindToRenderStep("LuanFeiAnimFix", 199, function()
	if LF.Enabled and not Invis_Enabled then
		if LF.Track1 then pcall(function() LF.Track1:Stop(0) end) end
		if LF.Track2 then pcall(function() LF.Track2:Stop(0) end) end
	end
end)

RunService:UnbindFromRenderStep("SmoothMovementCamera")
RunService:BindToRenderStep("SmoothMovementCamera", Enum.RenderPriority.Camera.Value + 1, function(dt: number)
	if not MC.SmoothCam or not Camera then MC.SmoothPos = nil; return end
	local cf = Camera.CFrame
	local pos = cf.Position
	if not MC.SmoothPos then
		MC.SmoothPos = pos
	else
		MC.SmoothPos = MC.SmoothPos:Lerp(pos, math.clamp(dt * MC.LerpSpeed, 0, 1))
	end
	Camera.CFrame = CFrame.new(MC.SmoothPos, MC.SmoothPos + cf.LookVector)
end)

local function DoSkinUpdate()
	local now = tick()
	if now - FF_S.LastSkin < 1 then return end
	FF_S.LastSkin = now
	if FF_S.BodyEnabled then
		local char = LocalPlayer.Character
		if char then
			for _, p in char:GetChildren() do
				if IsBodyPart(p) then
					if not FF_S.BodyProps[p] then
						FF_S.BodyProps[p] = { Material = p.Material, Color = p.Color }
						p.Material = Enum.Material.ForceField
						p.Color = FF_S.Color
					elseif p.Material ~= Enum.Material.ForceField then
						p.Material = Enum.Material.ForceField
						p.Color = FF_S.Color
					end
				end
			end
		end
	end
	if FF_S.ToolEnabled then
		local char = LocalPlayer.Character
		local tool = char and char:FindFirstChildOfClass("Tool")
		if tool then
			for _, p in tool:GetDescendants() do
				if p:IsA("BasePart") then
					if not FF_S.ToolProps[p] then
						FF_S.ToolProps[p] = { Material = p.Material, Color = p.Color }
					end
					p.Material = Enum.Material.ForceField
					p.Color = FF_S.Color
				end
			end
		end
	end
end

local function DoDesyncLogic()
	if not DS.Enabled or Invis_Enabled then
		DS.AppliedOffset = Vector3.zero
		if not DS.Enabled and DS.Model.Parent then
			DS.Model.Parent = nil
		end
		return
	end
	local char = LocalPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	local ragebotActive = false
	if RB_State and Valid_Pair and Valid_Pair.Target and Valid_Pair.Target.Character then
		local th = Valid_Pair.Target.Character:FindFirstChild("HumanoidRootPart")
		local tu = Valid_Pair.Target.Character:FindFirstChildOfClass("Humanoid")
		if th and tu and tu.Health > 0 then
			local tool = char:FindFirstChildOfClass("Tool")
			if tool and tool:FindFirstChild("IsGun") then ragebotActive = true end
		end
	end
	if ragebotActive then
		if DS.Model.Parent then DS.Model.Parent = nil end
		DS.AppliedOffset = Vector3.zero
		return
	end
	local clk = os.clock()
	local interval = if DS.TPRate > 0 then (1 / DS.TPRate) else 0
	if clk - DS.LastTPTime >= interval then
		DS.LastTPTime = clk
		DS.Y_Toggle = not DS.Y_Toggle
		local yOff = if DS.Y_Toggle then (math.random(0, DS.Y * 10) / 10) else 0
		local tOff = Vector3.new((math.random() - 0.5) * 2 * DS.X, yOff, (math.random() - 0.5) * 2 * DS.Z)
		local p = RaycastParams.new()
		p.FilterDescendantsInstances = { char, DS.Model, Camera }
		p.FilterType = Enum.RaycastFilterType.Exclude
		local rr = workspace:Raycast(hrp.Position, tOff, p)
		if rr then
			DS.CurrentOffset = (rr.Position + rr.Normal * 1.5) - hrp.Position
		else
			DS.CurrentOffset = tOff
		end
	end
	if DS.Visualize then
		if DS.Model.Parent ~= workspace.Terrain then
			DS.Model.Parent = workspace.Terrain
		end
		DS.Model:PivotTo(CFrame.new(hrp.Position + DS.CurrentOffset))
	else
		if DS.Model.Parent then DS.Model.Parent = nil end
	end
	DS.AppliedOffset = DS.CurrentOffset
end

local function DoLuanFeiLogic()
	if not LF.Enabled or Invis_Enabled then return end
	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 then return end
	local animator = hum:FindFirstChildOfClass("Animator") or hum
	if not LF.Track1 then
		pcall(function()
			LF.Track1 = animator:LoadAnimation(LF.Anim1)
			LF.Track1.Priority = Enum.AnimationPriority.Action4
		end)
	end
	if not LF.Track2 then
		pcall(function()
			LF.Track2 = animator:LoadAnimation(LF.Anim2)
			LF.Track2.Priority = Enum.AnimationPriority.Action4
			LF.Track2.Looped = true
		end)
	end
	if LF.Track1 then
		pcall(function()
			if not LF.Track1.IsPlaying then LF.Track1:Play() end
			LF.Track1:AdjustSpeed(0)
			LF.Track1.TimePosition = if LF.Track1.Length > 0 then LF.TimePosRatio * LF.Track1.Length else LF.TimePosRatio
		end)
	end
	if LF.Track2 then
		pcall(function()
			if not LF.Track2.IsPlaying then LF.Track2:Play() end
			LF.Track2:AdjustSpeed(1)
		end)
	end
	LF.Angle += LF.SpinSpeed
end

local function ApplySpoofs()
	local now = tick()
	if (DS.Enabled or LF.Enabled) and now - DS.LastFFlagTime >= 1 then
		DS.LastFFlagTime = now
		pcall(setfflag, "S2PhysicsSenderRate", "99999999")
	end
	DoDesyncLogic()
	DoLuanFeiLogic()
	local char = LocalPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	local spoofed = false
	local realCF = hrp.CFrame
	local newCF = realCF
	if DS.Enabled and DS.AppliedOffset ~= Vector3.zero then
		newCF = newCF + DS.AppliedOffset
		spoofed = true
	end
	if LF.Enabled and not Invis_Enabled then
		local smoothRotation = CFrame.Angles(math.rad(LF.Angle), math.rad(LF.Angle * 1.5), math.rad(LF.Angle * 0.8))
		newCF = newCF * smoothRotation
		spoofed = true
	end
	if spoofed then
		hrp.CFrame = newCF
		RunService:BindToRenderStep("RestoreSpoofCFrame", 199, function()
			if char and hrp and hrp.Parent then hrp.CFrame = realCF end
			if DS.Enabled then DS.AppliedOffset = Vector3.zero end
			RunService:UnbindFromRenderStep("RestoreSpoofCFrame")
		end)
	end
end

local function DoInvisible()
	if not Invis_Enabled or DS.Enabled or LF.Enabled then return end
	local char = LocalPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not (hrp and hum and hum.Health > 0) then return end
	if not Invis_Track then
		local anim = hum:FindFirstChildOfClass("Animator") or hum
		pcall(function()
			Invis_Track = anim:LoadAnimation(Invis_Anim)
			Invis_Track.Priority = Enum.AnimationPriority.Action
		end)
	end
	if Invis_Track then
		pcall(function()
			if not Invis_Track.IsPlaying then Invis_Track:Play() end
			Invis_Track:AdjustSpeed(0)
			Invis_Track.TimePosition = 0.3
		end)
	end
	Invis_SavedCF = hrp.CFrame
	hrp.CFrame = Invis_SavedCF + Vector3.new(0, -2, 0)
end

RunService.Heartbeat:Connect(function()
	DoSkinUpdate()
	ApplySpoofs()
	DoInvisible()
	DoRagebot()
end)

RunService:BindToRenderStep("CAM_FOV_Enforce", Enum.RenderPriority.Camera.Value + 2, function()
	if CAM_FOV then Camera.FieldOfView = CAM_FOV end
	if AMB.Enabled then
		local cc = Camera:FindFirstChild("CATColorCorr")
		if not cc then
			cc = Instance.new("ColorCorrectionEffect")
			cc.Name = "CATColorCorr"
			cc.Parent = Camera
		end
		cc.TintColor = AMB.Color
		cc.Brightness = AMB.Brightness
		cc.Contrast = AMB.Density * 0.3
		cc.Saturation = -(AMB.Density * 0.5)
		cc.Enabled = true
	else
		local cc = Camera:FindFirstChild("CATColorCorr")
		if cc then cc.Enabled = false end
	end
end)

RunService.RenderStepped:Connect(function(dt: number)
	if not HeadMode and not HandsModSelection then return end
	local char = LocalPlayer.Character
	if not (char and char.Parent) then return end
	local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
	local head = char:FindFirstChild("Head")
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if HeadMode then
		local neck = (head and head:FindFirstChild("Neck")) or (torso and torso:FindFirstChild("Neck"))
		if HeadMode == "Hide head" and neck then
			if not OriginalNeckC0 then OriginalNeckC0 = neck.C0; OriginalNeckC1 = neck.C1 end
			neck.C0 = AC.NeckC0
			neck.C1 = AC.NeckC1
		elseif (HeadMode == "Yaw head" or HeadMode == "Custom") and hrp then
			if not DoTweak_fn then
				for _, v in getgc(true) do
					if typeof(v) == "function" then
						local info = debug.getinfo(v)
						if info and info.name == "DoTweak" and info.numparams == 11 then
							DoTweak_fn = v
							break
						end
					end
				end
			end
			if DoTweak_fn then
				local angle: number
				if HeadMode == "Yaw head" then
					HeadYawTime += dt
					angle = math.sin(HeadYawTime * HeadRotSpeed) * math.rad(HeadYaw)
				else
					angle = math.rad(HeadCustomYaw)
				end
				local neckRot = CFrame.Angles(angle, 0, 0)
				pcall(DoTweak_fn, char, hrp.Position + Vector3.new(0, 10, 0), hrp.Position, neckRot.LookVector, true, false, true, true, true, 9e9, true)
			end
		end
	end
	if HandsModSelection and torso then
		local tool = char:FindFirstChildOfClass("Tool")
		if HandsModSelection == "Hands up" and tool then
			local lS = torso:FindFirstChild("Left Shoulder")
			local rS = torso:FindFirstChild("Right Shoulder")
			if lS then lS.C0 = AC.LShoulder end
			if rS then rS.C0 = AC.RShoulder end
			for _, v in tool:GetDescendants() do
				if v.Name == "Mag6D_Torso" and v:IsA("Motor6D") then v.C0 = AC.Mag6D end
				if v.Name == "Tool6D_Torso" and v:IsA("Motor6D") then v.C0 = AC.Tool6D end
			end
		end
	end
end)

RunService.RenderStepped:Connect(function(dt: number)
	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum then
		if SpeedState and hum.WalkSpeed ~= SpeedValue then hum.WalkSpeed = SpeedValue end
		if JumpState then
			if not hum.UseJumpPower then hum.UseJumpPower = true end
			if hum.JumpPower ~= JumpValue then hum.JumpPower = JumpValue end
		end
	end
	if not ShouldLock() then CL.CurrentTarget = nil; CL.LockedPart = nil; return end
	local origin = Camera.CFrame.Position
	CL.ScanTimer += dt
	if CL.ScanTimer > 0.1 then
		CL.ScanTimer = 0
		local best: Model? = nil
		local bDist = CL.FOV
		local b3D = math.huge
		for _, p in Players:GetPlayers() do
			if p ~= LocalPlayer and p.Character then
				if not table.find(WhiteList, p.Name) and (not CL.TargetOnly or table.find(TargetList, p.Name)) then
					local ph = p.Character:FindFirstChild("Humanoid")
					local pr = p.Character:FindFirstChild("HumanoidRootPart")
					if ph and ph.Health > (if CL.DownCheck then 15 else 0) and pr then
						local sp, on = Camera:WorldToViewportPoint(pr.Position)
						local sd = (Vector2.new(sp.X, sp.Y) - Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)).Magnitude
						local d3 = (pr.Position - origin).Magnitude
						if d3 < 15 then
							if d3 < b3D and IsVisible(origin, pr) then b3D = d3; best = p.Character; bDist = 0 end
						elseif on and sd < bDist and IsVisible(origin, pr) then
							bDist = sd
							best = p.Character
						end
					end
				end
			end
		end
		CL.CurrentTarget = best
	end
	if CL.CurrentTarget then
		if tick() - CL.LastSwitchTime >= CL.Delay then
			local vp = GetVisibleParts(origin, CL.CurrentTarget)
			CL.LockedPart = vp[math.random(1, #vp)]
			CL.LastSwitchTime = tick()
		end
		if CL.LockedPart then
			local jit = Vector3.new((math.random() - 0.5) * CL.Shake, (math.random() - 0.5) * CL.Shake, (math.random() - 0.5) * CL.Shake)
			local tPos = CL.LockedPart.Position
			if CL.AutoPrediction then
				local ctool = char and char:FindFirstChildOfClass("Tool")
				if ctool ~= CL.CachedTool then
					CL.CachedTool = ctool
					CL.CachedVel = 1100
					if ctool and ctool:FindFirstChild("Config") then
						pcall(function()
							local cfg = require(ctool.Config)
							if cfg.BulletSettings and cfg.BulletSettings.Velocity then
								CL.CachedVel = cfg.BulletSettings.Velocity
							elseif cfg.Velocity then
								CL.CachedVel = cfg.Velocity
							end
						end)
					end
				end
				tPos = tPos + (CL.LockedPart.AssemblyLinearVelocity * ((tPos - origin).Magnitude / CL.CachedVel))
			end
			Camera.CFrame = CFrame.lookAt(origin, origin + Camera.CFrame.LookVector:Lerp((tPos + jit - origin).Unit, CL.Power))
		end
	end
end)

RunService.Heartbeat:Connect(function()
	if not RB_State or not Valid_Pair then return end
	local char = LocalPlayer.Character
	local tool = char and char:FindFirstChildOfClass("Tool")
	if not (tool and tool:FindFirstChild("IsGun")) then return end
	local waitTime = 0
	local gunConfig = nil
	if RF_State then
		local gn = tool.Name
		if not (gn:find("Beretta") or gn:find("TEC")) then
			local cfg = tool:FindFirstChild("Config")
			if cfg and cfg:IsA("ModuleScript") then
				local ok, gs = pcall(require, cfg)
				if ok and gs then gunConfig = gs; waitTime = 1 / (gs.FireRate or 3) else waitTime = 0.1 end
			else
				waitTime = 0.1
			end
		end
	else
		waitTime = 0.5
	end
	if tick() - Last_Shot < waitTime then return end
	local vals = tool:FindFirstChild("Values")
	local ammo = vals and vals:FindFirstChild("SERVER_Ammo")
	if not (ammo and ammo.Value > 0) then return end
	local part = Valid_Pair.Target.Character:FindFirstChild("Head") or Valid_Pair.Target.Character:FindFirstChild("HumanoidRootPart")
	if not part then return end
	local key = "K"..math.random(1000, 9999)
	local dir = (Valid_Pair.Hit - Valid_Pair.Origin).Unit
	GN_S:FireServer(tick(), key, tool, "FDS9I83", Valid_Pair.Origin, { dir }, false)
	if TR.Enabled then task.spawn(CreateTracer, Valid_Pair.Origin, dir) end
	ZF_H:FireServer("🧈", tool, key, 1, part, Valid_Pair.Hit, dir)
	if tool:FindFirstChild("Hitmarker") then tool.Hitmarker:Fire(part) end
	if HitLogEnabled then
		local dmg = 17
		local mult = 1.35
		if gunConfig then dmg = gunConfig.Damage or 17; mult = gunConfig.HeadshotMultiplier or 1.35
		elseif tool:FindFirstChild("Config") then
			local ok, c = pcall(require, tool.Config)
			if ok then dmg = c.Damage or 17; mult = c.HeadshotMultiplier or 1.35 end
		end
		local fd = (dmg * mult) - (math.floor((Valid_Pair.Origin - Valid_Pair.Hit).Magnitude / 50) * 2)
		local mp = GetLocalRealPosition()
		local tr = Valid_Pair.Target.Character:FindFirstChild("HumanoidRootPart")
		ProcessHitLog(Valid_Pair.Target.Name, tool.Name, math.floor(fd * 100) / 100, if tr then math.floor((mp - tr.Position).Magnitude) else 0, WB.Cached)
	end
	Last_Shot = tick()
end)

RunService.Heartbeat:Connect(function()
	if not MC.AntiShift then return end
	local char = LocalPlayer.Character
	local tool = char and char:FindFirstChildOfClass("Tool")
	local hasGun = tool ~= nil and tool:FindFirstChild("IsGun") ~= nil
	if lastTickHadGun and not hasGun then
		task.delay(MC.ShiftDelay, function()
			firesignal(ChangeMouseLockEvent.Event)
			UIS.MouseBehavior = Enum.MouseBehavior.Default
		end)
	end
	lastTickHadGun = hasGun
end)

RunService.Heartbeat:Connect(function()
	if not (NametagEnabled or DistanceEnabled or HealthEnabled) then return end
	local myChar = LocalPlayer.Character
	local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
	if not myRoot then return end
	local now = tick()
	if now - LastVisualUpdate >= (if (myRoot.Velocity.Magnitude > (CONFIG.VelocityThreshold or 0.5)) then CONFIG.Rate_Active else CONFIG.Rate_Idle) then
		LastVisualUpdate = now
		for _, player in Players:GetPlayers() do
			if player ~= LocalPlayer and player.Character then
				local ch = player.Character
				local h = ch:FindFirstChildOfClass("Humanoid")
				local alive = h and h.Health > 0
				local show = alive and (not espSets.targetOnly or table.find(TargetList, player.Name) ~= nil)
				local tag = GetCustomTag(ch, "CAT_NameTag", CONFIG.NameOffset)
				if tag then
					local showName = NametagEnabled and show
					local showDist = DistanceEnabled and show
					local scaledHP = if h then math.ceil(h.Health * (100 / 115)) else 0
					local showHP = HealthEnabled and show and scaledHP < 100
					tag.Enabled = (showName or showDist)
					local nameL = tag:FindFirstChild("L")
					local distL = tag:FindFirstChild("DL")
					if nameL then
						nameL.Visible = showName
						if showName then
							nameL.TextColor3 = if table.find(WhiteList, player.Name) ~= nil
								then Color3.fromRGB(135, 206, 235)
								elseif table.find(TargetList, player.Name) ~= nil
								then Color3.fromRGB(255, 0, 0)
								else Color3.fromRGB(255, 255, 255)
						end
					end
					if distL then distL.Visible = showDist end
				end
				local hpTag = ch:FindFirstChild("CAT_HPTag")
				if hpTag then
					local scaledHP = if h then math.ceil(h.Health * (100 / 115)) else 0
					local showHP = HealthEnabled and show and scaledHP < 100
					hpTag.Enabled = showHP
					if showHP then
						local l = hpTag:FindFirstChild("L")
						if l then l.Text = tostring(scaledHP) end
					end
				end
				local ffTag = ch:FindFirstChild("CAT_FFTag")
				if ffTag then
					local hasFF = ch:FindFirstChildOfClass("ForceField") ~= nil
					ffTag.Enabled = (NametagEnabled or DistanceEnabled or HealthEnabled) and show and hasFF
				end
			end
		end
	end
	if now - LastContentUpdate >= CONFIG.ContentRate then
		LastContentUpdate = now
		local myPos = GetLocalRealPosition()
		for _, player in Players:GetPlayers() do
			if player.Character then
				local tag = player.Character:FindFirstChild("CAT_NameTag")
				if tag and tag.Enabled then
					local nameL = tag:FindFirstChild("L")
					local distL = tag:FindFirstChild("DL")
					local tr = player.Character:FindFirstChild("HumanoidRootPart")
					if nameL and nameL.Visible then nameL.Text = player.Name end
					if distL and distL.Visible and tr then distL.Text = math.floor((myPos - tr.Position).Magnitude).."M" end
				end
			end
		end
	end
end)

RunService.Heartbeat:Connect(function()
	if FLY.Active then
		local char2 = LocalPlayer.Character
		local torso2 = char2 and (char2:FindFirstChild("Torso") or char2:FindFirstChild("UpperTorso"))
		if torso2 then
			for _, jn in FLY.Joints do
				local j = torso2:FindFirstChild(jn)
				if j and j:IsA("Motor6D") and not j.Enabled then j.Enabled = true end
			end
		end
	end
	if FLY.Active then
		local lp = Players.LocalPlayer
		local stats = RepStorage:FindFirstChild("CharStats")
		local pStats = stats and stats:FindFirstChild(lp.Name)
		local rt = pStats and pStats:FindFirstChild("RagdollTime")
		if rt then
			local s = rt:FindFirstChild("RagdollSwitch")
			local s2 = rt:FindFirstChild("RagdollSwitch2")
			local sr = rt:FindFirstChild("SRagdolled")
			local rt2 = rt:FindFirstChild("RagdollTime2")
			local nr = pStats and pStats:FindFirstChild("NoRagdoll")
			if s then s.Value = false end
			if s2 then s2.Value = false end
			if sr then sr.Value = false end
			if rt then rt.Value = 0 end
			if rt2 then rt2.MaxValue = 0 end
			if nr then nr.Value = true end
		end
	end
	if FLY.Active then
		local canSend = true
		local char = LocalPlayer.Character
		if char then
			local torso = char:FindFirstChild("Torso")
			local collider = torso and torso:FindFirstChild("TorsoCollider")
			if collider and collider.CanCollide == true then canSend = false end
		end
		if canSend then
			if not FLY.RZDONL then pcall(function() FLY.RZDONL = RepStorage.Events:WaitForChild("__RZDONL", 1) end) end
			local now = os.clock()
			if FLY.RZDONL and now >= FLY.NextSend then
				pcall(function() FLY.RZDONL:FireServer(table.unpack(FLY.EvArgs)) end)
				FLY.NextSend = now + 0.05
			end
		end
	end
	if not FLY.Active then return end
	local char = LocalPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	hrp.AssemblyLinearVelocity = FlyGetInputDir() * FLY.Speed
	if FLY.SpeedLabel then FLY.SpeedLabel.Text = "spd "..FLY.Speed end
end)

RunService.RenderStepped:Connect(function()
	if WV.WorldTimeEnabled then WV_Lit.ClockTime = WV.WorldTime end
	if WV.AmbientEnabled then WV_Lit.Ambient = WV.AmbientColor; WV_Lit.OutdoorAmbient = WV.OutdoorAmbientColor end
	if WV.LightingModeEnabled then pcall(function() WV_Lit.Technology = Enum.Technology[WV.LightingMode] end) end
	if WV.AtmosphereEnabled then
		local currentAtmo = WV_Lit:FindFirstChildOfClass("Atmosphere")
		if not currentAtmo then currentAtmo = WV_Atmo; currentAtmo.Parent = WV_Lit end
		currentAtmo.Color = WV.AtmoColor
		currentAtmo.Decay = WV.AtmoDecay
		currentAtmo.Density = WV.AtmoDensity
		currentAtmo.Haze = WV.AtmoHaze
		currentAtmo.Glare = WV.AtmoGlare
		currentAtmo.Offset = WV.AtmoOffset
	else
		local currentAtmo = WV_Lit:FindFirstChildOfClass("Atmosphere")
		if currentAtmo and currentAtmo == WV_Atmo then currentAtmo.Parent = nil elseif currentAtmo then currentAtmo.Density = 0 end
	end
	if WV.SkyboxEnabled then
		local currentSky = WV_Lit:FindFirstChildOfClass("Sky")
		if not currentSky then currentSky = WV_Sky; currentSky.Parent = WV_Lit end
		local ids = WV_Skyboxes[WV.SkyboxType]
		if ids then
			currentSky.SkyboxBk = "rbxassetid://"..ids.Bk
			currentSky.SkyboxDn = "rbxassetid://"..ids.Dn
			currentSky.SkyboxFt = "rbxassetid://"..ids.Ft
			currentSky.SkyboxLf = "rbxassetid://"..ids.Lf
			currentSky.SkyboxRt = "rbxassetid://"..ids.Rt
			currentSky.SkyboxUp = "rbxassetid://"..ids.Up
		end
	else
		if WV_Sky.Parent == WV_Lit then WV_Sky.Parent = nil end
	end
	if WV.WeatherEnabled and WV_WeatherPart.Parent then
		WV_WeatherPart.CFrame = Camera.CFrame + Vector3.new(0, 25, 0)
	end
end)

RunService.Heartbeat:Connect(function(dt: number)
	if not SA.Enabled or not SA.IsRandom then return end
	SA.RandomTimer += dt
	if SA.RandomTimer >= 0.1 then
		SA.RandomTimer = 0
		SA.RandomIdx = (SA.RandomIdx % #SA.RandomParts) + 1
		SA.TargetPart = SA.RandomParts[SA.RandomIdx]
	end
end)

do
	local FOV_Lines = {}
	local FOV_Rotation = 0
	local function ClearLines()
		for _, line in FOV_Lines do
			if line then line:Remove() end
		end
		FOV_Lines = {}
	end
	RunService.RenderStepped:Connect(function(dt: number)
		if not SA.FOV_Visible then ClearLines(); return end
		local center: Vector2
		if SA.FOV_PositionMode == "Mouse" then
			center = UIS:GetMouseLocation()
		else
			center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
		end
		local sides = SA.FOV_Sides
		local radius = SA.FOV_Radius
		if SA.FOV_SpinEnabled then FOV_Rotation += SA.FOV_SpinSpeed * dt end
		local base_rad = math.rad(FOV_Rotation)
		if #FOV_Lines ~= sides then
			ClearLines()
			for i = 1, sides do
				local l = Drawing.new("Line")
				l.Visible = true
				FOV_Lines[i] = l
			end
		end
		local verts = {}
		for i = 1, sides do
			local angle = base_rad + math.rad((i - 1) * (360 / sides))
			verts[i] = center + Vector2.new(math.cos(angle) * radius, math.sin(angle) * radius)
		end
		for i = 1, sides do
			local line = FOV_Lines[i]
			if line then
				line.Visible = true
				line.From = verts[i]
				line.To = verts[i + 1] or verts[1]
				line.Thickness = 1.5
				line.Color = SA.FOV_Color
				line.Transparency = 1
			end
		end
	end)
end

local function startGrayscaleBorder()
	local mainFrame = Window.UIElements and Window.UIElements.Main
	if not mainFrame then task.wait(0.2); mainFrame = Window.UIElements and Window.UIElements.Main; if not mainFrame then warn("无法找到窗口主框架"); return end end
	local corner = mainFrame:FindFirstChildOfClass("UICorner")
	if not corner then corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0, 16); corner.Parent = mainFrame end
	local oldStroke = mainFrame:FindFirstChild("GrayscaleStroke")
	if oldStroke then oldStroke:Destroy() end
	local colorScheme = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromHex("FFFFFF")),
		ColorSequenceKeypoint.new(0.25, Color3.fromHex("CCCCCC")),
		ColorSequenceKeypoint.new(0.5, Color3.fromHex("999999")),
		ColorSequenceKeypoint.new(0.75, Color3.fromHex("666666")),
		ColorSequenceKeypoint.new(1, Color3.fromHex("333333")),
	})
	local stroke = Instance.new("UIStroke")
	stroke.Name = "GrayscaleStroke"
	stroke.Thickness = 3
	stroke.Color = Color3.fromRGB(255, 255, 255)
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.LineJoinMode = Enum.LineJoinMode.Round
	stroke.Parent = mainFrame
	local gradient = Instance.new("UIGradient")
	gradient.Color = colorScheme
	gradient.Rotation = 0
	gradient.Parent = stroke
	local runService = game:GetService("RunService")
	local angle = 0
	local animationConnection = runService.Heartbeat:Connect(function(deltaTime: number)
		if not stroke or stroke.Parent == nil then animationConnection:Disconnect(); return end
		angle = (angle + 180 * deltaTime) % 360
		gradient.Rotation = angle
	end)
	print("黑白渐变边框动画已启动")
	return animationConnection
end

startGrayscaleBorder()

local Library = {}
Library.Window = Window

local function MonitorChar(c) if c then CurrentHum = c:WaitForChild("Humanoid", 10) end end
MonitorChar(LocalPlayer.Character)
LocalPlayer.CharacterAdded:Connect(MonitorChar)

return Library
