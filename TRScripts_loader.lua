--==============================================================================
-- T.R SCRIPTS - MASTER SCRIPT HUB (V94)
-- 100% ASCII Source + Full Runtime Emojis via utf8.char (JJSploit Proof)
--==============================================================================
local Players = game:GetService("Players") local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService") local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local ProximityPromptService = game:GetService("ProximityPromptService")
local VirtualUser = game:GetService("VirtualUser") local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer or Players.PlayerAdded:Wait() local LocalPlayer = player
local camera = workspace.CurrentCamera local genv = (getgenv and getgenv()) or _G
-- Zero-Allocation Performance Constants for Low-End PCs
local V3_ZERO = Vector3.new(0, 0, 0) local CF_ZERO = CFrame.new(0, 0, 0)
local V3_ESP_BOX = Vector3.new(4, 5.2, 1.2) local V3_ESP_OUTLINE = Vector3.new(4.2, 5.4, 1.25)
local CF_ESP_OFFSET = CFrame.new(0, -0.2, 0) local FULLBRIGHT_AMBIENT = Color3.fromRGB(255, 255, 255)
local userGameSettings = nil
pcall(function() userGameSettings = UserSettings():GetService("UserGameSettings") end)
-- Runtime Emoji Dictionary (renders real emojis in UI without breaking JJSploit's UTF-8 buffer)
local U = utf8.char local E = { Bolt    = U(0x26A1), Save    = U(0x1F4BE), Check   = U(0x2714),
	Dash    = U(0x2014), Close   = U(0x00D7), Chart   = U(0x1F4CA), Pin     = U(0x1F4CD),
	Radar   = U(0x1F4E1), Gem     = U(0x1F48E), Rocket  = U(0x1F680), Eye     = U(0x1F441),
	Laptop  = U(0x1F4BB), Sun     = U(0x1F31E), Moon    = U(0x1F319), Unlock  = U(0x1F513),
	Clip    = U(0x1F4CB), Plus    = U(0x2795), Trash   = U(0x1F5D1), Star    = U(0x2B50),
	Search  = U(0x1F50D), Refresh = U(0x1F504), Magnet  = U(0x1F9F2), Box     = U(0x1F4E6),
	Play    = U(0x25B6), Broom   = U(0x1F9F9), Stop    = U(0x23F9), Tick    = U(0x2713),
	Grip    = U(0x25E2), Target  = U(0x1F3AF) }
--==============================================================================
-- 1. ENVIRONMENT & DEEP CLEANUP ENGINE
--==============================================================================
local PlayerGui = player:WaitForChild("PlayerGui") local Connections = {}
if genv.TRScripts_ScreenGui then pcall(function() genv.TRScripts_ScreenGui:Destroy() end)
	genv.TRScripts_ScreenGui = nil end if type(genv.TRScripts_ActiveShutdown) == "function" then
	pcall(genv.TRScripts_ActiveShutdown, true) genv.TRScripts_ActiveShutdown = nil end
local function DeepCleanup() pcall(function() RunService:UnbindFromRenderStep("Aimbot_v2") end)
	pcall(function() RunService:UnbindFromRenderStep("TR_ShiftLock_Pre") end)
	pcall(function() if cleardrawcache then cleardrawcache() end end)
	for _, name in ipairs({ "TRScriptsHub", "UtilityHubGui", "TRScriptsFlingGui", "AimbotUI_v2" }) do
		if gethui then pcall(function() local hui = gethui() if hui then
					for _, ch in ipairs(hui:GetChildren()) do if ch.Name == name then ch:Destroy() end end end end) end
		pcall(function() for _, ch in ipairs(CoreGui:GetChildren()) do if ch.Name == name then ch:Destroy() end
			end end) pcall(function() local pg = player:FindFirstChildOfClass("PlayerGui") if pg then
				for _, ch in ipairs(pg:GetChildren()) do if ch.Name == name then ch:Destroy() end end end end) end
	pcall(function() for _, obj in ipairs(workspace:GetChildren()) do
			if obj.Name == "TR_FakeFloor" then obj:Destroy() end end end) pcall(function()
		local pg = player:FindFirstChildOfClass("PlayerGui") if pg then
			for _, ch in ipairs(pg:GetChildren()) do
				if ch.Name == "ESP_HitboxInner" or ch.Name == "ESP_HitboxOutline" then ch:Destroy() end end end end)
	pcall(function() for _, plr in ipairs(Players:GetPlayers()) do
			local esp = plr.Character and plr.Character:FindFirstChild("TR_ESP_Highlight")
			if esp then esp:Destroy() end end end) end DeepCleanup() local function GetSafeGuiParent()
	if gethui then local ok, hui = pcall(gethui) if ok and hui then return hui end end
	local ok, parent = pcall(function() local _ = CoreGui:GetChildren() local t = Instance.new("ScreenGui")
		t.Name = "TR_CoreTest" t.Parent = CoreGui t:Destroy() return CoreGui end)
	if ok and parent then return parent end return player:WaitForChild("PlayerGui") end
local SafeClipboard = setclipboard or toclipboard or set_clipboard or (Clipboard and Clipboard.set) or function() end
local SafeWriteFile = writefile or function() end
local SafeReadFile = readfile or function() return nil end
local SafeIsFile = isfile or function() return false end
local SafeLoadstring = loadstring or function() return nil, "loadstring unavailable" end
local SafeFireTouch = firetouchinterest or function() end
local SafeFirePrompt = fireproximityprompt or function(prompt) pcall(function() prompt:InputHoldBegin()
		task.wait() prompt:InputHoldEnd() end) end
--==============================================================================
-- 2. PERSISTENT JSON CONFIGURATION & STATE MANAGEMENT SYSTEM (V94)
--==============================================================================
local CONFIG_FILENAME = "TRScripts_Config_V100.json" local FALLBACK_FILES = {
	"TRScripts_Config_V99.json", "TRScripts_Config_V98.json", "TRScripts_Config_V97.json",
	"TRScripts_Config_V96.json", "TRScripts_Config_V95.json", "TRScripts_Config_V94.json",
	"TRScripts_Config_V93.json", "TRScripts_Config_V92.json" } local DefaultConfig = { Settings = {
		Theme = "Default", WindowWidth = 760, WindowHeight = 480, WalkSpeed = 16, JumpPower = 50, FOV = 70,
		FlySpeed = 50, FlyKeybind = "E", MouseLockKeybind = "M", AimbotKeybind = "Q", AimbotFOVRadius = 200,
		AimbotFOVCircleEnabled = true, AimbotEnabled = false, StrongLock = false, WallcheckEnabled = true,
		AimbotTeamCheck = true, ESPShowTeammates = false, AimPartName = "Head", MasterUtilityEnabled = false,
		MasterFlightEnabled = false, NoclipEnabled = false, AntiFlingEnabled = true, AutoSelectFling = false,
		AntiCheatBypass = true, ShiftDownEnabled = true, CountdownBypass = false, AntiAFK = true,
		InstantPrompt = false, ESPEnabled = false, FullbrightEnabled = false,
		CameraOverrideMode = "Free / Unlocked", LockedTime = nil }, Waypoints = {
		{ Name = "Spawn Point", X = 0, Y = 50, Z = 0, Keybind = "None" } }, RadarKeybinds = {},
	ExecutorTabs = {
		{ Name = "Script 1", Code = "-- Welcome to T.R Scripts V94\nprint('T.R Scripts V94 Ready!')" } },
	ActiveExecutorTab = 1 }
local savedConfig = HttpService:JSONDecode(HttpService:JSONEncode(DefaultConfig))
local Config = savedConfig.Settings local SaveFeedbackCallback = nil
local function SaveConfig(showVisualFeedback) pcall(function()
		SafeWriteFile(CONFIG_FILENAME, HttpService:JSONEncode(savedConfig)) end)
	if showVisualFeedback and SaveFeedbackCallback then SaveFeedbackCallback() end end
local function syncAllSystems() SaveConfig(false) end local function LoadConfig() pcall(function()
		local targetFile = nil if SafeIsFile(CONFIG_FILENAME) then targetFile = CONFIG_FILENAME else
			for _, f in ipairs(FALLBACK_FILES) do if SafeIsFile(f) then targetFile = f break end end end
		if targetFile then local raw = SafeReadFile(targetFile) if raw and #raw > 0 then
				local decoded = HttpService:JSONDecode(raw) if type(decoded) == "table" then
					if type(decoded.Settings) == "table" then
						for k, v in pairs(decoded.Settings) do savedConfig.Settings[k] = v end else
						for k, v in pairs(decoded) do
							if savedConfig.Settings[k] ~= nil then savedConfig.Settings[k] = v end end end
					if type(decoded.Waypoints) == "table" then savedConfig.Waypoints = decoded.Waypoints end
					if type(decoded.RadarKeybinds) == "table" then savedConfig.RadarKeybinds = decoded.RadarKeybinds end
					if type(decoded.ExecutorTabs) == "table" then savedConfig.ExecutorTabs = decoded.ExecutorTabs end
					if type(decoded.ActiveExecutorTab) == "number" then savedConfig.ActiveExecutorTab = decoded.ActiveExecutorTab end
				end end end end) end LoadConfig() local DefaultLighting = { ClockTime = Lighting.ClockTime,
	Brightness = Lighting.Brightness, GlobalShadows = Lighting.GlobalShadows,
	OutdoorAmbient = Lighting.OutdoorAmbient } local DefaultCamera = {
	FOV = (workspace.CurrentCamera and workspace.CurrentCamera.FieldOfView) or 70,
	CameraMode = player.CameraMode, MinZoom = player.CameraMinZoomDistance,
	MaxZoom = player.CameraMaxZoomDistance }
--==============================================================================
-- 3. COMFORTABLE DARK THEME ENGINE & UI HELPERS (6 DARK THEMES)
--==============================================================================
local ThemeOrder = { "Default", "Crimson Blood", "Matrix Neon", "Cyber Cyan", "Solar Gold", "Sakura Pink" }
local Themes = { ["Default"] = {
		MainBg = Color3.fromRGB(11, 8, 18), PanelBg = Color3.fromRGB(17, 12, 28), CardBg = Color3.fromRGB(24, 17, 38),
		Accent = Color3.fromRGB(118, 62, 215), AccentDark = Color3.fromRGB(72, 36, 140), Stroke = Color3.fromRGB(135, 85, 225),
		TextPrimary = Color3.fromRGB(235, 230, 245), TextSecondary = Color3.fromRGB(160, 148, 190) },
	["Crimson Blood"] = {
		MainBg = Color3.fromRGB(15, 7, 9), PanelBg = Color3.fromRGB(24, 10, 14), CardBg = Color3.fromRGB(34, 14, 20),
		Accent = Color3.fromRGB(185, 38, 58), AccentDark = Color3.fromRGB(115, 20, 34), Stroke = Color3.fromRGB(205, 60, 80),
		TextPrimary = Color3.fromRGB(242, 228, 232), TextSecondary = Color3.fromRGB(185, 145, 155) },
	["Matrix Neon"] = {
		MainBg = Color3.fromRGB(7, 13, 9), PanelBg = Color3.fromRGB(11, 21, 15), CardBg = Color3.fromRGB(16, 30, 22),
		Accent = Color3.fromRGB(26, 168, 86), AccentDark = Color3.fromRGB(16, 105, 54), Stroke = Color3.fromRGB(48, 195, 108),
		TextPrimary = Color3.fromRGB(225, 242, 232), TextSecondary = Color3.fromRGB(140, 185, 158) },
	["Cyber Cyan"] = {
		MainBg = Color3.fromRGB(7, 12, 18), PanelBg = Color3.fromRGB(11, 19, 29), CardBg = Color3.fromRGB(16, 27, 40),
		Accent = Color3.fromRGB(18, 152, 198), AccentDark = Color3.fromRGB(12, 96, 130), Stroke = Color3.fromRGB(45, 178, 220),
		TextPrimary = Color3.fromRGB(225, 240, 248), TextSecondary = Color3.fromRGB(140, 175, 198) },
	["Solar Gold"] = {
		MainBg = Color3.fromRGB(14, 11, 7), PanelBg = Color3.fromRGB(22, 18, 10), CardBg = Color3.fromRGB(32, 25, 14),
		Accent = Color3.fromRGB(195, 138, 24), AccentDark = Color3.fromRGB(125, 86, 14), Stroke = Color3.fromRGB(215, 162, 52),
		TextPrimary = Color3.fromRGB(245, 238, 225), TextSecondary = Color3.fromRGB(185, 168, 135) },
	["Sakura Pink"] = {
		MainBg = Color3.fromRGB(15, 8, 13), PanelBg = Color3.fromRGB(24, 12, 21), CardBg = Color3.fromRGB(34, 18, 30),
		Accent = Color3.fromRGB(195, 58, 132), AccentDark = Color3.fromRGB(125, 32, 84), Stroke = Color3.fromRGB(215, 92, 158),
		TextPrimary = Color3.fromRGB(245, 230, 240), TextSecondary = Color3.fromRGB(188, 148, 172) } }
local ThemeObjects = { MainBg = {}, PanelBg = {}, CardBg = {}, Accent = {}, AccentDark = {},
	Stroke = {}, TextPrimary = {}, TextSecondary = {}, CustomCallbacks = {} } local function GetTheme()
	return Themes[Config.Theme] or Themes["Default"] end
local function RegisterThemeObject(instance, prop, themeKey)
	table.insert(ThemeObjects[themeKey], { Instance = instance, Property = prop })
	instance[prop] = GetTheme()[themeKey] end local function ApplyTheme(themeName)
	if not Themes[themeName] then themeName = "Default" end Config.Theme = themeName
	local active = Themes[themeName] for key, list in pairs(ThemeObjects) do
		if key ~= "CustomCallbacks" and active[key] then for _, item in ipairs(list) do
				if item.Instance and item.Instance.Parent then
					TweenService:Create(item.Instance, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						[item.Property] = active[key] }):Play() end end end end
	for _, fn in ipairs(ThemeObjects.CustomCallbacks) do pcall(fn, active) end SaveConfig(false) end
local function AddCorner(parent, radius) local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 6) c.Parent = parent return c end
local function MakeButton(parent, size, pos, text, bgThemeKey, textSize)
	local b = Instance.new("TextButton") b.Size = size if pos then b.Position = pos end
	b.Font = Enum.Font.GothamBold b.TextSize = textSize or 12 b.Text = text b.Parent = parent
	if bgThemeKey then RegisterThemeObject(b, "BackgroundColor3", bgThemeKey) end
	RegisterThemeObject(b, "TextColor3", "TextPrimary") AddCorner(b, 6) return b end
local function MakeLabel(parent, size, pos, text, font, textSize, themeKey, xAlign)
	local l = Instance.new("TextLabel") l.Size = size if pos then l.Position = pos end
	l.BackgroundTransparency = 1 l.Font = font or Enum.Font.GothamSemibold l.TextSize = textSize or 12
	l.TextXAlignment = xAlign or Enum.TextXAlignment.Left l.Text = text l.Parent = parent
	RegisterThemeObject(l, "TextColor3", themeKey or "TextPrimary") return l end
--==============================================================================
-- 4. MAIN GLASSMORPHIC GUI & FLUENT WINDOWS 11 ANIMATION ENGINE
--==============================================================================
local ScreenGui = Instance.new("ScreenGui") ScreenGui.Name = "TRScriptsHub"
ScreenGui.ResetOnSpawn = false ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true ScreenGui.Parent = GetSafeGuiParent()
genv.TRScripts_ScreenGui = ScreenGui local MIN_WIDTH, MIN_HEIGHT = 560, 360
local MAX_WIDTH, MAX_HEIGHT = 1150, 820
local CurrentWidth = math.clamp(tonumber(Config.WindowWidth) or 760, MIN_WIDTH, MAX_WIDTH)
local CurrentHeight = math.clamp(tonumber(Config.WindowHeight) or 480, MIN_HEIGHT, MAX_HEIGHT)
local MainFrame = Instance.new("Frame") MainFrame.Name = "MainFrame"
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Size = UDim2.new(0, CurrentWidth, 0, CurrentHeight)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0) MainFrame.BackgroundTransparency = 0.06
MainFrame.BorderSizePixel = 0 MainFrame.ClipsDescendants = true MainFrame.Parent = ScreenGui
RegisterThemeObject(MainFrame, "BackgroundColor3", "MainBg") AddCorner(MainFrame, 12)
local MainScale = Instance.new("UIScale") MainScale.Scale = 1 MainScale.Parent = MainFrame
local MainStroke = Instance.new("UIStroke") MainStroke.Thickness = 1.6 MainStroke.Transparency = 0.25
MainStroke.Parent = MainFrame RegisterThemeObject(MainStroke, "Color", "Stroke")
local TopBar = Instance.new("Frame") TopBar.Name = "TopBar" TopBar.Size = UDim2.new(1, 0, 0, 44)
TopBar.BackgroundTransparency = 0.1 TopBar.BorderSizePixel = 0 TopBar.Parent = MainFrame
RegisterThemeObject(TopBar, "BackgroundColor3", "PanelBg") AddCorner(TopBar, 12)
local TitleLabel = MakeLabel(TopBar, UDim2.new(0, 420, 1, 0), UDim2.new(0, 16, 0, 0), E.Bolt .. " T.R Scripts - Master Script Hub (V94)", Enum.Font.GothamBold, 15, "TextPrimary", Enum.TextXAlignment.Left)
local SubBadge = Instance.new("TextLabel") SubBadge.Size = UDim2.new(0, 125, 0, 24)
SubBadge.Position = UDim2.new(1, -242, 0.5, -12) SubBadge.BackgroundTransparency = 0.15
SubBadge.Font = Enum.Font.GothamSemibold SubBadge.TextSize = 11 SubBadge.Text = "Toggle UI: [X]"
SubBadge.Parent = TopBar RegisterThemeObject(SubBadge, "BackgroundColor3", "CardBg")
RegisterThemeObject(SubBadge, "TextColor3", "TextSecondary") AddCorner(SubBadge, 6)
local SaveBtn = MakeButton(TopBar, UDim2.new(0, 34, 0, 28), UDim2.new(1, -108, 0.5, -14), E.Save, "CardBg", 14)
SaveFeedbackCallback = function() SaveBtn.Text = E.Check task.delay(1.1, function()
		if SaveBtn and SaveBtn.Parent then SaveBtn.Text = E.Save end end) end
SaveBtn.MouseButton1Click:Connect(function() SaveConfig(true) end)
local MinBtn = MakeButton(TopBar, UDim2.new(0, 32, 0, 28), UDim2.new(1, -68, 0.5, -14), E.Dash, "CardBg", 14)
local CloseBtn = Instance.new("TextButton") CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -30, 0.5, -14) CloseBtn.BackgroundColor3 = Color3.fromRGB(175, 38, 55)
CloseBtn.Font = Enum.Font.GothamBold CloseBtn.TextSize = 14 CloseBtn.Text = E.Close
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255) CloseBtn.Parent = TopBar AddCorner(CloseBtn, 6)
local RestingPosition = MainFrame.Position local isMenuVisible = true local isClosingPermanently = false
local activeWindowTweens = {} local SyncAimbotFovCircleVisibility = nil
local draggingGui, resizingMode = false, nil do local dragStartPos, startFramePos = nil, nil
	local resizeStartMouse, resizeStartSize, resizeStartCenter = nil, nil, nil
	TopBar.InputBegan:Connect(function(input) if resizingMode then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			draggingGui = true dragStartPos = input.Position startFramePos = MainFrame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then draggingGui = false end end) end end)
	local ResizeRight = Instance.new("TextButton", MainFrame) ResizeRight.Size = UDim2.new(0, 7, 1, -24)
	ResizeRight.Position = UDim2.new(1, -7, 0, 12) ResizeRight.BackgroundTransparency = 1
	ResizeRight.Text = "" ResizeRight.ZIndex = 10 local ResizeBottom = Instance.new("TextButton", MainFrame)
	ResizeBottom.Size = UDim2.new(1, -24, 0, 7) ResizeBottom.Position = UDim2.new(0, 12, 1, -7)
	ResizeBottom.BackgroundTransparency = 1 ResizeBottom.Text = "" ResizeBottom.ZIndex = 10
	local ResizeCorner = Instance.new("TextButton", MainFrame) ResizeCorner.Size = UDim2.new(0, 20, 0, 20)
	ResizeCorner.Position = UDim2.new(1, -20, 1, -20) ResizeCorner.BackgroundTransparency = 1
	ResizeCorner.Font = Enum.Font.GothamBold ResizeCorner.TextSize = 13 ResizeCorner.Text = E.Grip
	ResizeCorner.ZIndex = 12 RegisterThemeObject(ResizeCorner, "TextColor3", "Accent")
	local function BeginResize(mode, input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			draggingGui = false resizingMode = mode resizeStartMouse = input.Position
			resizeStartSize = Vector2.new(CurrentWidth, CurrentHeight) resizeStartCenter = MainFrame.Position
			input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then
					resizingMode = nil Config.WindowWidth = CurrentWidth Config.WindowHeight = CurrentHeight
					SaveConfig(false) end end) end end
	ResizeCorner.InputBegan:Connect(function(i) BeginResize("Corner", i) end)
	ResizeRight.InputBegan:Connect(function(i) BeginResize("Right", i) end)
	ResizeBottom.InputBegan:Connect(function(i) BeginResize("Bottom", i) end)
	table.insert(Connections, UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
		if resizingMode then local delta = input.Position - resizeStartMouse
			local newW, newH = resizeStartSize.X, resizeStartSize.Y
			if resizingMode == "Corner" or resizingMode == "Right" then
				newW = math.clamp(math.floor(resizeStartSize.X + delta.X + 0.5), MIN_WIDTH, MAX_WIDTH) end
			if resizingMode == "Corner" or resizingMode == "Bottom" then
				newH = math.clamp(math.floor(resizeStartSize.Y + delta.Y + 0.5), MIN_HEIGHT, MAX_HEIGHT) end
			CurrentWidth, CurrentHeight = newW, newH MainFrame.Size = UDim2.new(0, CurrentWidth, 0, CurrentHeight)
			RestingPosition = UDim2.new(
				resizeStartCenter.X.Scale, resizeStartCenter.X.Offset + math.floor((newW - resizeStartSize.X) * 0.5 + 0.5),
				resizeStartCenter.Y.Scale, resizeStartCenter.Y.Offset + math.floor((newH - resizeStartSize.Y) * 0.5 + 0.5)
			) MainFrame.Position = RestingPosition elseif draggingGui then
			local delta = input.Position - dragStartPos RestingPosition = UDim2.new(
				startFramePos.X.Scale, startFramePos.X.Offset + delta.X,
				startFramePos.Y.Scale, startFramePos.Y.Offset + delta.Y ) MainFrame.Position = RestingPosition end
	end)) end local function SetMenuVisible(state, onComplete) if isClosingPermanently then return end
	for _, tw in ipairs(activeWindowTweens) do pcall(function() tw:Cancel() end) end activeWindowTweens = {}
	isMenuVisible = state if SyncAimbotFovCircleVisibility then SyncAimbotFovCircleVisibility() end
	if state then MainFrame.Visible = true MainFrame.Size = UDim2.new(0, CurrentWidth, 0, CurrentHeight)
		local info = TweenInfo.new(0.26, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		local t1 = TweenService:Create(MainScale, info, { Scale = 1 })
		local t2 = TweenService:Create(MainFrame, info, { Position = RestingPosition, BackgroundTransparency = 0.06 })
		local t3 = TweenService:Create(MainStroke, info, { Transparency = 0.25 })
		activeWindowTweens = { t1, t2, t3 } t1:Play() t2:Play() t3:Play() t1.Completed:Connect(function(st)
			if st == Enum.PlaybackState.Completed and onComplete then onComplete() end end) else
		draggingGui, resizingMode = false, nil
		local info = TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		local t1 = TweenService:Create(MainScale, info, { Scale = 0 })
		local t2 = TweenService:Create(MainFrame, info, { Position = RestingPosition, BackgroundTransparency = 1 })
		local t3 = TweenService:Create(MainStroke, info, { Transparency = 1 })
		activeWindowTweens = { t1, t2, t3 } t1:Play() t2:Play() t3:Play() t1.Completed:Connect(function(st)
			if st == Enum.PlaybackState.Completed then if not isMenuVisible then MainFrame.Visible = false end
				if onComplete then onComplete() end end end) end end MainScale.Scale = 0
MainFrame.BackgroundTransparency = 1 MainStroke.Transparency = 1 SetMenuVisible(true)
MinBtn.MouseButton1Click:Connect(function() SetMenuVisible(false) end)
local Sidebar = Instance.new("ScrollingFrame") Sidebar.Size = UDim2.new(0, 185, 1, -56)
Sidebar.Position = UDim2.new(0, 10, 0, 50) Sidebar.BackgroundTransparency = 0.12
Sidebar.BorderSizePixel = 0 Sidebar.ScrollBarThickness = 3 Sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
Sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y Sidebar.Parent = MainFrame
RegisterThemeObject(Sidebar, "BackgroundColor3", "PanelBg")
RegisterThemeObject(Sidebar, "ScrollBarImageColor3", "Accent") AddCorner(Sidebar, 10)
local SidebarLayout = Instance.new("UIListLayout") SidebarLayout.Padding = UDim.new(0, 6)
SidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder SidebarLayout.Parent = Sidebar
local SidebarPad = Instance.new("UIPadding") SidebarPad.PaddingTop = UDim.new(0, 8)
SidebarPad.PaddingBottom = UDim.new(0, 8) SidebarPad.Parent = Sidebar
local ContentContainer = Instance.new("Frame") ContentContainer.Size = UDim2.new(1, -210, 1, -56)
ContentContainer.Position = UDim2.new(0, 200, 0, 50) ContentContainer.BackgroundTransparency = 0.12
ContentContainer.BorderSizePixel = 0 ContentContainer.Parent = MainFrame
RegisterThemeObject(ContentContainer, "BackgroundColor3", "PanelBg") AddCorner(ContentContainer, 10)
--==============================================================================
-- 5. REUSABLE UI COMPONENT FACTORY
--==============================================================================
local Tabs = {} local ActiveTabName = nil local function CreateTab(tabName, iconText, order)
	local TabBtn = Instance.new("TextButton") TabBtn.LayoutOrder = order
	TabBtn.Size = UDim2.new(1, -14, 0, 38) TabBtn.BackgroundTransparency = 0.1
	TabBtn.Font = Enum.Font.GothamSemibold TabBtn.TextSize = 13
	TabBtn.TextXAlignment = Enum.TextXAlignment.Left TabBtn.Text = "   " .. iconText .. "  " .. tabName
	TabBtn.Parent = Sidebar RegisterThemeObject(TabBtn, "TextColor3", "TextPrimary") AddCorner(TabBtn, 8)
	local Page = Instance.new("ScrollingFrame") Page.Size = UDim2.new(1, -16, 1, -16)
	Page.Position = UDim2.new(0, 8, 0, 8) Page.BackgroundTransparency = 1 Page.BorderSizePixel = 0
	Page.ScrollBarThickness = 4 Page.CanvasSize = UDim2.new(0, 0, 0, 0)
	Page.AutomaticCanvasSize = Enum.AutomaticSize.Y Page.Visible = false Page.Parent = ContentContainer
	RegisterThemeObject(Page, "ScrollBarImageColor3", "Accent")
	local PageLayout = Instance.new("UIListLayout") PageLayout.Padding = UDim.new(0, 8)
	PageLayout.SortOrder = Enum.SortOrder.LayoutOrder PageLayout.Parent = Page
	local PagePad = Instance.new("UIPadding") PagePad.PaddingTop = UDim.new(0, 4)
	PagePad.PaddingBottom = UDim.new(0, 10) PagePad.PaddingLeft = UDim.new(0, 4)
	PagePad.PaddingRight = UDim.new(0, 8) PagePad.Parent = Page
	Tabs[tabName] = { Button = TabBtn, Page = Page } local function RefreshTabVisuals()
		local theme = GetTheme() for name, data in pairs(Tabs) do
			data.Button.BackgroundColor3 = (name == ActiveTabName) and theme.Accent or theme.CardBg
			data.Button.BackgroundTransparency = (name == ActiveTabName) and 0.02 or 0.2 end end
	table.insert(ThemeObjects.CustomCallbacks, RefreshTabVisuals)
	TabBtn.MouseButton1Click:Connect(function() ActiveTabName = tabName
		for name, data in pairs(Tabs) do data.Page.Visible = (name == tabName) end RefreshTabVisuals() end)
	if order == 1 then ActiveTabName = tabName Page.Visible = true RefreshTabVisuals() end return Page end
local function CreateSectionHeader(parent, title, order) local Header = Instance.new("TextLabel")
	Header.LayoutOrder = order Header.Size = UDim2.new(1, 0, 0, 24) Header.BackgroundTransparency = 1
	Header.Font = Enum.Font.GothamBold Header.TextSize = 14 Header.TextXAlignment = Enum.TextXAlignment.Left
	Header.Text = "  " .. title Header.Parent = parent RegisterThemeObject(Header, "TextColor3", "Accent")
	return Header end local function CreateCard(parent, height, order) local Card = Instance.new("Frame")
	Card.LayoutOrder = order Card.Size = UDim2.new(1, 0, 0, height) Card.BackgroundTransparency = 0.12
	Card.BorderSizePixel = 0 Card.Parent = parent RegisterThemeObject(Card, "BackgroundColor3", "CardBg")
	AddCorner(Card, 8) local Stroke = Instance.new("UIStroke") Stroke.Thickness = 1
	Stroke.Transparency = 0.6 Stroke.Parent = Card RegisterThemeObject(Stroke, "Color", "Stroke")
	return Card end local function CreateToggle(parent, labelText, initialValue, order, callback)
	local Card = CreateCard(parent, 42, order)
	local Label = MakeLabel(Card, UDim2.new(1, -110, 1, 0), UDim2.new(0, 14, 0, 0), labelText, Enum.Font.GothamSemibold, 13, "TextPrimary", Enum.TextXAlignment.Left)
	local ToggleBtn = MakeButton(Card, UDim2.new(0, 84, 0, 28), UDim2.new(1, -96, 0.5, -14), "OFF", nil, 12)
	local state = initialValue and true or false local function UpdateToggleVisual()
		local theme = GetTheme() ToggleBtn.Text = state and "ON" or "OFF"
		ToggleBtn.BackgroundColor3 = state and theme.Accent or theme.PanelBg end
	table.insert(ThemeObjects.CustomCallbacks, UpdateToggleVisual) UpdateToggleVisual()
	local function SetState(newState, triggerCallback) state = newState and true or false
		UpdateToggleVisual() if triggerCallback ~= false and callback then pcall(callback, state) end end
	ToggleBtn.MouseButton1Click:Connect(function() SetState(not state, true) end)
	return { SetState = SetState, GetState = function() return state end, Card = Card } end
local function CreateSlider(parent, labelText, minVal, maxVal, initialVal, order, callback)
	local Card = CreateCard(parent, 58, order)
	local Title = MakeLabel(Card, UDim2.new(0.65, 0, 0, 22), UDim2.new(0, 14, 0, 6), labelText, Enum.Font.GothamSemibold, 13, "TextPrimary", Enum.TextXAlignment.Left)
	local ValueLabel = MakeLabel(Card, UDim2.new(0.3, -14, 0, 22), UDim2.new(0.7, 0, 0, 6), tostring(initialVal), Enum.Font.GothamBold, 13, "Accent", Enum.TextXAlignment.Right)
	local BarBg = Instance.new("Frame") BarBg.Size = UDim2.new(1, -28, 0, 12)
	BarBg.Position = UDim2.new(0, 14, 0, 34) BarBg.BorderSizePixel = 0 BarBg.Parent = Card
	RegisterThemeObject(BarBg, "BackgroundColor3", "PanelBg") AddCorner(BarBg, 10)
	local Fill = Instance.new("Frame")
	local initAlpha = math.clamp((initialVal - minVal) / (maxVal - minVal), 0, 1)
	Fill.Size = UDim2.new(initAlpha, 0, 1, 0) Fill.BorderSizePixel = 0 Fill.Parent = BarBg
	RegisterThemeObject(Fill, "BackgroundColor3", "Accent") AddCorner(Fill, 10) local sliding = false
	local function UpdateFromInput(inputPosX)
		local relX = math.clamp(inputPosX - BarBg.AbsolutePosition.X, 0, BarBg.AbsoluteSize.X)
		local alpha = (BarBg.AbsoluteSize.X > 0) and (relX / BarBg.AbsoluteSize.X) or 0
		local value = math.floor(minVal + (maxVal - minVal) * alpha + 0.5)
		Fill.Size = UDim2.new(alpha, 0, 1, 0) ValueLabel.Text = tostring(value)
		if callback then pcall(callback, value) end end BarBg.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			sliding = true UpdateFromInput(input.Position.X) input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then sliding = false end end) end end)
	UserInputService.InputChanged:Connect(function(input)
		if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			UpdateFromInput(input.Position.X) end end) return { SetValue = function(val)
			local clamped = math.clamp(val, minVal, maxVal)
			Fill.Size = UDim2.new((clamped - minVal) / (maxVal - minVal), 0, 1, 0)
			ValueLabel.Text = tostring(clamped) end } end
--==============================================================================
-- 6. CREATE ALL 8 MODULAR TABS (WITH RUNTIME EMOJIS)
--==============================================================================
local Tab1_Dashboard = CreateTab("Themes & Status", E.Chart, 1)
local Tab2_Waypoints = CreateTab("Waypoints & TP", E.Pin, 2)
local Tab3_Radar     = CreateTab("Player Radar", E.Radar, 3)
local Tab4_Items     = CreateTab("Items & Prompts", E.Gem, 4)
local Tab5_Flight    = CreateTab("Flight & Movement", E.Rocket, 5)
local Tab6_Instant   = CreateTab("Target Fling", E.Bolt, 6)
local Tab7_Visuals   = CreateTab("Aimbot & Visuals", E.Target, 7)
local Tab8_Executor  = CreateTab("Script Executor", E.Laptop, 8)
--==============================================================================
-- 7. TAB 1: THEMES, PERFORMANCE & PROTECTION
--==============================================================================
local PerfLabel, CursorUnlockedOverride do
CreateSectionHeader(Tab1_Dashboard, "UI Theme Customizer (6 Dark Themes)", 1)
local ThemeCard = CreateCard(Tab1_Dashboard, 88, 2) local ThemeGrid = Instance.new("UIGridLayout")
ThemeGrid.CellSize = UDim2.new(0, 160, 0, 32) ThemeGrid.CellPadding = UDim2.new(0, 10, 0, 8)
ThemeGrid.HorizontalAlignment = Enum.HorizontalAlignment.Center
ThemeGrid.VerticalAlignment = Enum.VerticalAlignment.Center
ThemeGrid.SortOrder = Enum.SortOrder.LayoutOrder ThemeGrid.Parent = ThemeCard
for idx, themeName in ipairs(ThemeOrder) do local TBtn = Instance.new("TextButton")
	TBtn.LayoutOrder = idx TBtn.BackgroundColor3 = Themes[themeName].Accent TBtn.Font = Enum.Font.GothamBold
	TBtn.TextSize = 12 TBtn.TextColor3 = Color3.fromRGB(245, 245, 250) TBtn.Text = themeName
	TBtn.Parent = ThemeCard AddCorner(TBtn, 6)
	TBtn.MouseButton1Click:Connect(function() ApplyTheme(themeName) end) end
CreateSectionHeader(Tab1_Dashboard, "Live Performance & Mouse Lock (Shift Lock) Controls", 3)
local PerfCard = CreateCard(Tab1_Dashboard, 46, 4) PerfLabel = Instance.new("TextLabel")
PerfLabel.Size = UDim2.new(1, -24, 1, 0) PerfLabel.Position = UDim2.new(0, 12, 0, 0)
PerfLabel.BackgroundTransparency = 1 PerfLabel.Font = Enum.Font.GothamSemibold PerfLabel.TextSize = 13
PerfLabel.TextXAlignment = Enum.TextXAlignment.Left
PerfLabel.Text = "FPS: --  |  Ping: -- ms  |  Mouse Lock [M]: OFF" PerfLabel.Parent = PerfCard
RegisterThemeObject(PerfLabel, "TextColor3", "TextPrimary") CursorUnlockedOverride = false
local MouseLockCard = CreateCard(Tab1_Dashboard, 92, 5)
local mouseLockToggleBtn = Instance.new("TextButton", MouseLockCard)
mouseLockToggleBtn.Size = UDim2.new(0.48, -12, 0, 34)
mouseLockToggleBtn.Position = UDim2.new(0, 10, 0, 10) mouseLockToggleBtn.Font = Enum.Font.GothamBold
mouseLockToggleBtn.TextSize = 12 mouseLockToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AddCorner(mouseLockToggleBtn, 6) local mouseLockStatusLbl = Instance.new("TextLabel", MouseLockCard)
mouseLockStatusLbl.Size = UDim2.new(0.52, -14, 0, 34)
mouseLockStatusLbl.Position = UDim2.new(0.48, 4, 0, 10) mouseLockStatusLbl.BackgroundTransparency = 0.15
mouseLockStatusLbl.Font = Enum.Font.GothamSemibold mouseLockStatusLbl.TextSize = 12
mouseLockStatusLbl.Text = "Shift Lock: INACTIVE"
RegisterThemeObject(mouseLockStatusLbl, "BackgroundColor3", "PanelBg")
RegisterThemeObject(mouseLockStatusLbl, "TextColor3", "TextPrimary") AddCorner(mouseLockStatusLbl, 6)
local mlKeyBindLabel = MakeLabel(MouseLockCard, UDim2.new(0, 210, 0, 30), UDim2.new(0, 12, 0, 52), "Mouse Lock Shortcut Keybind:", Enum.Font.GothamSemibold, 12, "TextPrimary", Enum.TextXAlignment.Left)
local mouseLockKeyAssignBtn = MakeButton(MouseLockCard, UDim2.new(0, 130, 0, 30), UDim2.new(1, -240, 0, 52), "Bind Key: [M]", "PanelBg", 11)
local mouseLockKeyDeleteBtn = Instance.new("TextButton", MouseLockCard)
mouseLockKeyDeleteBtn.Size = UDim2.new(0, 92, 0, 30)
mouseLockKeyDeleteBtn.Position = UDim2.new(1, -102, 0, 52)
mouseLockKeyDeleteBtn.BackgroundColor3 = Color3.fromRGB(165, 38, 55)
mouseLockKeyDeleteBtn.Font = Enum.Font.GothamBold mouseLockKeyDeleteBtn.TextSize = 11
mouseLockKeyDeleteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
mouseLockKeyDeleteBtn.Text = E.Trash .. " Delete Key" AddCorner(mouseLockKeyDeleteBtn, 6)
RefreshMouseLockUI = function() local k = Config.MouseLockKeybind or "None"
	mouseLockKeyAssignBtn.Text = "Bind Key: [" .. k .. "]"
	mouseLockToggleBtn.Text = "Mouse Lock [" .. k .. "]: " .. (CursorUnlockedOverride and "ON" or "OFF")
	mouseLockToggleBtn.BackgroundColor3 = CursorUnlockedOverride and Color3.fromRGB(38, 168, 92) or Color3.fromRGB(185, 52, 52)
	mouseLockStatusLbl.Text = CursorUnlockedOverride and "Shift Lock: ACTIVE" or "Shift Lock: INACTIVE" end
SetMouseLockState = function(newState) CursorUnlockedOverride = newState and true or false
	RefreshMouseLockUI() if CursorUnlockedOverride then pcall(function() player.DevEnableMouseLock = true
			UserSettings():GetService("UserGameSettings").RotationType = Enum.RotationType.CameraRelative
			UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter end) else pcall(function()
			UserInputService.MouseBehavior = Enum.MouseBehavior.Default UserInputService.MouseIconEnabled = true
			UserSettings():GetService("UserGameSettings").RotationType = Enum.RotationType.MovementRelative end)
		pcall(function() local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
			if hum then hum.AutoRotate = true hum.CameraOffset = Vector3.new(0, 0, 0) end end) end end
mouseLockToggleBtn.MouseButton1Click:Connect(function() SetMouseLockState(not CursorUnlockedOverride)
end) mouseLockKeyAssignBtn.MouseButton1Click:Connect(function()
	mouseLockKeyAssignBtn.Text = "[Key / Del]" ActiveKeybindCaptureCallback = function(keyName)
		Config.MouseLockKeybind = keyName RefreshMouseLockUI() SaveConfig(false) end end)
mouseLockKeyDeleteBtn.MouseButton1Click:Connect(function() Config.MouseLockKeybind = "None"
	ActiveKeybindCaptureCallback = nil RefreshMouseLockUI() SaveConfig(false) end) RefreshMouseLockUI()
CreateSectionHeader(Tab1_Dashboard, "Protection & Physics Stabilizers", 6)
CreateToggle(Tab1_Dashboard, "Anti-AFK Protection (VirtualUser Idle Bypass)", Config.AntiAFK, 7, function(state)
	Config.AntiAFK = state SaveConfig(false) end)
CreateToggle(Tab1_Dashboard, "Super Anti-Fling Shield (No-Collide Players + Velocity Lock)", Config.AntiFlingEnabled ~= false, 8, function(state)
	Config.AntiFlingEnabled = state if not state then lastSafeAntiFlingCF = nil pcall(function()
			for _, plr in ipairs(Players:GetPlayers()) do if plr ~= player and plr.Character then
					for _, part in ipairs(plr.Character:GetDescendants()) do
						if part:IsA("BasePart") and (part.Name == "Head" or part.Name == "Torso" or part.Name == "UpperTorso" or part.Name == "LowerTorso" or part.Name == "HumanoidRootPart") then
							part.CanCollide = true end end end end end) end SaveConfig(false) end)
genv.TR_AntiCheatActive = (Config.AntiCheatBypass ~= false) local function DisableAntiCheatSignals(char)
	if not Config.AntiCheatBypass or not getconnections then return end pcall(function()
		local c = char or player.Character if not c then return end
		local hum = c:FindFirstChildOfClass("Humanoid") local root = c:FindFirstChild("HumanoidRootPart")
		local checkExecutor = isexecutorclosure or checkclosure or is_synapse_function
		local function clearSig(sig) if not sig then return end for _, conn in ipairs(getconnections(sig)) do
				if conn and conn.Function and (not checkExecutor or not checkExecutor(conn.Function)) then
					pcall(function() conn:Disable() end) end end end if hum then
			clearSig(hum:GetPropertyChangedSignal("WalkSpeed"))
			clearSig(hum:GetPropertyChangedSignal("JumpPower"))
			clearSig(hum:GetPropertyChangedSignal("JumpHeight"))
			clearSig(hum:GetPropertyChangedSignal("PlatformStand"))
			clearSig(hum:GetPropertyChangedSignal("AutoRotate")) clearSig(hum.StateChanged) end if root then
			clearSig(root:GetPropertyChangedSignal("CFrame")) clearSig(root:GetPropertyChangedSignal("Position"))
			clearSig(root:GetPropertyChangedSignal("Velocity"))
			clearSig(root:GetPropertyChangedSignal("AssemblyLinearVelocity")) end end) end
CreateToggle(Tab1_Dashboard, "Undetected Anti-Cheat Bypass (Fly, Speed, Jump & Teleport)", Config.AntiCheatBypass ~= false, 9, function(state)
	Config.AntiCheatBypass = state genv.TR_AntiCheatActive = state
	if state then DisableAntiCheatSignals(player.Character) end SaveConfig(false) end)
if Config.AntiCheatBypass ~= false then DisableAntiCheatSignals(player.Character) end
table.insert(Connections, player.CharacterAdded:Connect(function(newChar) task.wait(0.25)
	if Config.AntiCheatBypass ~= false then DisableAntiCheatSignals(newChar) end end)) pcall(function()
	local HIDDEN_NAMES = { TR_FakeFloor = true, TRScriptsHub = true, TR_ESP_Highlight = true,
		ESP_HitboxInner = true, ESP_HitboxOutline = true, TR_FOVCircle = true }
	local AC_KEYWORDS = { "walkspeed", "jumppower", "fly", "noclip", "teleport", "anticheat", "exploit", "velocity", "bodyvelocity", "bvelocity" }
	if not genv.TR_HooksInstalled and hookmetamethod and getnamecallmethod and checkcaller then
		genv.TR_HooksInstalled = true local oldNamecall
		oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
			if not checkcaller() and genv.TR_AntiCheatActive then local method = getnamecallmethod()
				if self == player and (method == "Kick" or method == "kick") then return nil end
				if method == "FindFirstChild" then local arg1 = ...
					if type(arg1) == "string" and HIDDEN_NAMES[arg1] then return nil end
				elseif method == "GetState" and typeof and typeof(self) == "Instance" and self:IsA("Humanoid") then
					return Enum.HumanoidStateType.Running
				elseif (method == "FireServer" or method == "InvokeServer") and typeof and typeof(self) == "Instance" then
					local remName = tostring(self.Name):lower()
					if remName:find("ban", 1, true) or remName:find("kick", 1, true) or remName:find("anticheat", 1, true) or remName:find("ac_", 1, true) or remName:find("cheat", 1, true) or remName:find("flag", 1, true) then
						return nil end local args = { ... } for i = 1, #args do if type(args[i]) == "string" then
							local low = args[i]:lower() for _, kw in ipairs(AC_KEYWORDS) do
								if low:find(kw, 1, true) then return nil end end end end end end return oldNamecall(self, ...)
		end) local oldIndex oldIndex = hookmetamethod(game, "__index", function(self, key)
			if not checkcaller() and genv.TR_AntiCheatActive and typeof and typeof(self) == "Instance" then
				if self:IsA("Humanoid") then if key == "WalkSpeed" then return 16
					elseif key == "JumpPower" then return 50 elseif key == "JumpHeight" then return 7.2
					elseif key == "PlatformStand" then return false elseif key == "AutoRotate" then return true
					elseif key == "FloorMaterial" then return Enum.Material.Plastic end
				elseif type(key) == "string" and HIDDEN_NAMES[key] then return nil end end return oldIndex(self, key)
		end) end end) table.insert(Connections, player.Idled:Connect(function() if Config.AntiAFK then
		pcall(function() VirtualUser:CaptureController() VirtualUser:ClickButton2(Vector2.new()) end) end end))
end
--==============================================================================
-- 8. TAB 2: WAYPOINTS & TELEPORT
--==============================================================================
local GetRootPart, freezePosition, lastSafeAntiFlingCF, SafeTeleportToCoords, ActiveKeybindCaptureCallback
do CreateSectionHeader(Tab2_Waypoints, "Coordinates & Direct Teleport", 1)
local CoordsTopCard = CreateCard(Tab2_Waypoints, 88, 2)
local CopyCoordsBtn = MakeButton(CoordsTopCard, UDim2.new(0, 160, 0, 32), UDim2.new(0, 12, 0, 10), E.Clip .. " Copy Coords", "Accent", 12)
local AddWaypointBtn = MakeButton(CoordsTopCard, UDim2.new(0, 180, 0, 32), UDim2.new(0, 182, 0, 10), E.Plus .. " Save Current Pos", "AccentDark", 12)
local CoordsInput = Instance.new("TextBox") CoordsInput.Size = UDim2.new(1, -155, 0, 32)
CoordsInput.Position = UDim2.new(0, 12, 0, 48)
CoordsInput.PlaceholderText = "Enter X, Y, Z coordinates (e.g. 120, 50, -340)..." CoordsInput.Text = ""
CoordsInput.ClearTextOnFocus = false CoordsInput.Font = Enum.Font.Gotham CoordsInput.TextSize = 12
CoordsInput.Parent = CoordsTopCard RegisterThemeObject(CoordsInput, "BackgroundColor3", "PanelBg")
RegisterThemeObject(CoordsInput, "TextColor3", "TextPrimary") AddCorner(CoordsInput, 6)
local DirectTpBtn = MakeButton(CoordsTopCard, UDim2.new(0, 125, 0, 32), UDim2.new(1, -137, 0, 48), E.Bolt .. " Teleport", "Accent", 12)
GetRootPart = function(character) local char = character or player.Character
	if not char then return nil end
	return char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart or char:FindFirstChildWhichIsA("BasePart")
end freezePosition = nil local teleportBypassLockUntil = 0 local teleportBypassTargetCF = nil
SafeTeleportToCoords = function(x, y, z) pcall(function() local char = player.Character
		local root = GetRootPart(char) local hum = char and char:FindFirstChildOfClass("Humanoid") if root then
			pcall(function() CoreGui.RobloxGui["CoreScripts/NetworkPause"]:Destroy() end)
			local target = Vector3.new(x, y, z) local goalCF = CFrame.new(target) freezePosition = target
			lastSafeAntiFlingCF = goalCF teleportBypassTargetCF = goalCF if Config.AntiCheatBypass ~= false then
				teleportBypassLockUntil = os.clock() + 0.22 if hum then
					hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
					hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
					hum:ChangeState(Enum.HumanoidStateType.Landed) hum:ChangeState(Enum.HumanoidStateType.Running) end
				for _, part in ipairs(char:GetDescendants()) do if part:IsA("BasePart") then
						part.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
						part.AssemblyAngularVelocity = Vector3.new(0, 0, 0) part.Velocity = Vector3.new(0, 0, 0)
						part.RotVelocity = Vector3.new(0, 0, 0) end end root.CFrame = goalCF else
				root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
				root.AssemblyAngularVelocity = Vector3.new(0, 0, 0) root.CFrame = goalCF end end end) end
local function ParseCoordinateString(str) if type(str) ~= "string" then return nil end local nums = {}
	for numStr in str:gmatch("[-+]?%d+%.?%d*") do local n = tonumber(numStr)
		if n then table.insert(nums, n) end end if #nums >= 3 then return nums[1], nums[2], nums[3] end
	return nil end CopyCoordsBtn.MouseButton1Click:Connect(function() local root = GetRootPart()
	if root then local pos = root.Position
		SafeClipboard(string.format("%.1f, %.1f, %.1f", pos.X, pos.Y, pos.Z))
		CopyCoordsBtn.Text = E.Check .. " Copied!" task.delay(1.1, function()
			if CopyCoordsBtn and CopyCoordsBtn.Parent then CopyCoordsBtn.Text = E.Clip .. " Copy Coords" end end)
	end end) DirectTpBtn.MouseButton1Click:Connect(function()
	local x, y, z = ParseCoordinateString(CoordsInput.Text)
	if x and y and z then SafeTeleportToCoords(x, y, z) end end)
CreateSectionHeader(Tab2_Waypoints, "Saved Waypoints (Press Delete Key to Unassign Keybind)", 3)
local WaypointsContainer = Instance.new("Frame") WaypointsContainer.LayoutOrder = 4
WaypointsContainer.Size = UDim2.new(1, 0, 0, 0) WaypointsContainer.AutomaticSize = Enum.AutomaticSize.Y
WaypointsContainer.BackgroundTransparency = 1 WaypointsContainer.Parent = Tab2_Waypoints
local WaypointsLayout = Instance.new("UIListLayout") WaypointsLayout.Padding = UDim.new(0, 6)
WaypointsLayout.SortOrder = Enum.SortOrder.LayoutOrder WaypointsLayout.Parent = WaypointsContainer
ActiveKeybindCaptureCallback = nil local function RebuildWaypointsUI()
	for _, child in ipairs(WaypointsContainer:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end end for idx, wp in ipairs(savedConfig.Waypoints) do
		local Row = CreateCard(WaypointsContainer, 44, idx) local NameBox = Instance.new("TextBox")
		NameBox.Size = UDim2.new(0, 175, 0, 28) NameBox.Position = UDim2.new(0, 10, 0.5, -14)
		NameBox.Text = wp.Name or ("Waypoint " .. idx) NameBox.ClearTextOnFocus = false
		NameBox.Font = Enum.Font.GothamSemibold NameBox.TextSize = 12 NameBox.Parent = Row
		RegisterThemeObject(NameBox, "BackgroundColor3", "PanelBg")
		RegisterThemeObject(NameBox, "TextColor3", "TextPrimary") AddCorner(NameBox, 6)
		NameBox.FocusLost:Connect(function() wp.Name = NameBox.Text SaveConfig(false) end)
		local CoordsLbl = MakeLabel(Row, UDim2.new(0, 135, 1, 0), UDim2.new(0, 192, 0, 0), string.format("%.0f, %.0f, %.0f", wp.X or 0, wp.Y or 0, wp.Z or 0), Enum.Font.Gotham, 11, "TextSecondary", Enum.TextXAlignment.Left)
		local KeyBtn = MakeButton(Row, UDim2.new(0, 78, 0, 28), UDim2.new(1, -206, 0.5, -14), "[" .. (wp.Keybind or "None") .. "]", "PanelBg", 11)
		KeyBtn.MouseButton1Click:Connect(function() KeyBtn.Text = "[Key/Del]"
			ActiveKeybindCaptureCallback = function(keyName) wp.Keybind = keyName
				KeyBtn.Text = "[" .. keyName .. "]" SaveConfig(false) end end)
		KeyBtn.MouseButton2Click:Connect(function() wp.Keybind = "None" KeyBtn.Text = "[None]"
			ActiveKeybindCaptureCallback = nil SaveConfig(false) end)
		local TpBtn = MakeButton(Row, UDim2.new(0, 74, 0, 28), UDim2.new(1, -122, 0.5, -14), "Teleport", "Accent", 11)
		TpBtn.MouseButton1Click:Connect(function() SafeTeleportToCoords(wp.X, wp.Y, wp.Z) end)
		local DelBtn = Instance.new("TextButton") DelBtn.Size = UDim2.new(0, 34, 0, 28)
		DelBtn.Position = UDim2.new(1, -42, 0.5, -14) DelBtn.BackgroundColor3 = Color3.fromRGB(165, 38, 55)
		DelBtn.Font = Enum.Font.GothamBold DelBtn.TextSize = 13
		DelBtn.TextColor3 = Color3.fromRGB(255, 255, 255) DelBtn.Text = E.Trash DelBtn.Parent = Row
		AddCorner(DelBtn, 6) DelBtn.MouseButton1Click:Connect(function()
			table.remove(savedConfig.Waypoints, idx) SaveConfig(false) RebuildWaypointsUI() end) end end
AddWaypointBtn.MouseButton1Click:Connect(function() local root = GetRootPart() if root then
		local pos = root.Position table.insert(savedConfig.Waypoints, {
			Name = "Waypoint " .. (#savedConfig.Waypoints + 1), X = math.floor(pos.X + 0.5),
			Y = math.floor(pos.Y + 0.5), Z = math.floor(pos.Z + 0.5), Keybind = "None" }) SaveConfig(false)
		RebuildWaypointsUI() end end) RebuildWaypointsUI() end
--==============================================================================
-- 9. TAB 3: REAL-TIME PLAYER RADAR & TELEPORT KEYBINDS
--==============================================================================
local SpectatingTarget, IsFriend, RefreshRadarCards do
CreateSectionHeader(Tab3_Radar, "Live Player Radar (Friends " .. E.Star .. " First | Press Delete Key to Unassign)", 1)
local RadarContainer = Instance.new("Frame") RadarContainer.LayoutOrder = 2
RadarContainer.Size = UDim2.new(1, 0, 0, 0) RadarContainer.AutomaticSize = Enum.AutomaticSize.Y
RadarContainer.BackgroundTransparency = 1 RadarContainer.Parent = Tab3_Radar
local RadarLayout = Instance.new("UIListLayout") RadarLayout.Padding = UDim.new(0, 6)
RadarLayout.SortOrder = Enum.SortOrder.LayoutOrder RadarLayout.Parent = RadarContainer
SpectatingTarget = nil IsFriend = function(targetPlayer) local success, result = pcall(function()
		return player:IsFriendsWith(targetPlayer.UserId) end) return success and result end
RefreshRadarCards = function() for _, child in ipairs(RadarContainer:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end end local myRoot = GetRootPart()
	local myPos = myRoot and myRoot.Position or Vector3.new(0, 0, 0) local entries = {}
	for _, plr in ipairs(Players:GetPlayers()) do if plr ~= player then local isFriend = IsFriend(plr)
			local theirRoot = GetRootPart(plr.Character)
			local dist = theirRoot and (theirRoot.Position - myPos).Magnitude or 999999
			table.insert(entries, { Player = plr, IsFriend = isFriend, Distance = dist }) end end
	table.sort(entries, function(a, b) if a.IsFriend ~= b.IsFriend then return a.IsFriend end
		return a.Distance < b.Distance end) for idx, entry in ipairs(entries) do local plr = entry.Player
		local Card = CreateCard(RadarContainer, 46, idx)
		local prefix = entry.IsFriend and (E.Star .. " ") or ""
		local distText = (entry.Distance < 999990) and string.format("%.0f studs", entry.Distance) or "N/A"
		local InfoLbl = MakeLabel(Card, UDim2.new(1, -275, 1, 0), UDim2.new(0, 12, 0, 0), string.format("%s%s (@%s) - %s", prefix, plr.DisplayName, plr.Name, distText), Enum.Font.GothamSemibold, 12, "TextPrimary", Enum.TextXAlignment.Left)
		local savedKey = savedConfig.RadarKeybinds[plr.Name] or "None"
		local KeyBtn = MakeButton(Card, UDim2.new(0, 74, 0, 28), UDim2.new(1, -258, 0.5, -14), "[" .. savedKey .. "]", "PanelBg", 11)
		KeyBtn.MouseButton1Click:Connect(function() KeyBtn.Text = "[Key/Del]"
			ActiveKeybindCaptureCallback = function(keyName) if keyName == "None" then
					savedConfig.RadarKeybinds[plr.Name] = nil else savedConfig.RadarKeybinds[plr.Name] = keyName end
				KeyBtn.Text = "[" .. keyName .. "]" SaveConfig(false) end end)
		KeyBtn.MouseButton2Click:Connect(function() savedConfig.RadarKeybinds[plr.Name] = nil
			KeyBtn.Text = "[None]" ActiveKeybindCaptureCallback = nil SaveConfig(false) end)
		local TpBtn = MakeButton(Card, UDim2.new(0, 78, 0, 28), UDim2.new(1, -176, 0.5, -14), "Teleport", "Accent", 11)
		TpBtn.MouseButton1Click:Connect(function() local targetRoot = GetRootPart(plr.Character)
			if targetRoot then local pos = targetRoot.Position SafeTeleportToCoords(pos.X, pos.Y + 3, pos.Z) end
		end)
		local SpecBtn = MakeButton(Card, UDim2.new(0, 84, 0, 28), UDim2.new(1, -92, 0.5, -14), (SpectatingTarget == plr) and "Unspectate" or "Spectate", "AccentDark", 11)
		SpecBtn.MouseButton1Click:Connect(function() pcall(function() if SpectatingTarget == plr then
					SpectatingTarget = nil
					local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
					if hum then workspace.CurrentCamera.CameraSubject = hum end else SpectatingTarget = plr
					local hum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
					if hum then workspace.CurrentCamera.CameraSubject = hum end end RefreshRadarCards() end) end) end
end end
--==============================================================================
-- 10. TAB 4: ITEMS SCANNER & INSTANT PROXIMITY PROMPTS
--==============================================================================
local CollectTargetItem, ScanWorkspaceItems do
CreateSectionHeader(Tab4_Items, "Proximity Prompt Instant Interaction Engine", 1)
local function ApplyInstantPrompts() if not Config.InstantPrompt then return end pcall(function()
		for _, desc in ipairs(workspace:GetDescendants()) do
			if desc:IsA("ProximityPrompt") then desc.HoldDuration = 0 end end end) end
CreateToggle(Tab4_Items, "Instant Proximity Prompts (HoldDuration = 0 Bypass)", Config.InstantPrompt, 2, function(state)
	Config.InstantPrompt = state if state then ApplyInstantPrompts() end SaveConfig(false) end)
table.insert(Connections, ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt)
	if Config.InstantPrompt then pcall(function() prompt.HoldDuration = 0 SafeFirePrompt(prompt) end) end
end)) table.insert(Connections, workspace.DescendantAdded:Connect(function(desc)
	if Config.InstantPrompt and desc:IsA("ProximityPrompt") then pcall(function() desc.HoldDuration = 0 end)
	end end)) if Config.InstantPrompt then ApplyInstantPrompts() end
CreateSectionHeader(Tab4_Items, "Workspace Items & Proximity Scanner (Manual Scan | Collect: [E])", 3)
local ScannerControlCard = CreateCard(Tab4_Items, 46, 4) local ItemSearchBox = Instance.new("TextBox")
ItemSearchBox.Size = UDim2.new(1, -240, 0, 30) ItemSearchBox.Position = UDim2.new(0, 10, 0.5, -15)
ItemSearchBox.PlaceholderText = E.Search .. " Filter items by name..." ItemSearchBox.Text = ""
ItemSearchBox.ClearTextOnFocus = false ItemSearchBox.Font = Enum.Font.Gotham ItemSearchBox.TextSize = 12
ItemSearchBox.Parent = ScannerControlCard
RegisterThemeObject(ItemSearchBox, "BackgroundColor3", "PanelBg")
RegisterThemeObject(ItemSearchBox, "TextColor3", "TextPrimary") AddCorner(ItemSearchBox, 6)
local ScanNowBtn = MakeButton(ScannerControlCard, UDim2.new(0, 100, 0, 30), UDim2.new(1, -220, 0.5, -15), E.Refresh .. " Rescan", "Accent", 11)
local CollectNearestBtn = MakeButton(ScannerControlCard, UDim2.new(0, 104, 0, 30), UDim2.new(1, -112, 0.5, -15), E.Magnet .. " Collect [E]", "AccentDark", 11)
local ItemsListContainer = Instance.new("Frame") ItemsListContainer.LayoutOrder = 5
ItemsListContainer.Size = UDim2.new(1, 0, 0, 0) ItemsListContainer.AutomaticSize = Enum.AutomaticSize.Y
ItemsListContainer.BackgroundTransparency = 1 ItemsListContainer.Parent = Tab4_Items
local ItemsListLayout = Instance.new("UIListLayout") ItemsListLayout.Padding = UDim.new(0, 6)
ItemsListLayout.SortOrder = Enum.SortOrder.LayoutOrder ItemsListLayout.Parent = ItemsListContainer
local ITEM_KEYWORDS = { "drop", "item", "loot", "weapon", "ammo", "coin", "chest", "box", "pack", "pickup", "apple", "gold", "gem" }
local ScannedItemsCache = {} local function IsCharacterDescendant(inst)
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr.Character and inst:IsDescendantOf(plr.Character) then return true end end return false end
local function GetItemBasePart(obj) if obj:IsA("BasePart") then return obj end
	if obj:IsA("Tool") or obj:IsA("Model") then
		return obj:FindFirstChild("Handle") or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
	end return nil end local function MatchesItemCriteria(obj)
	if obj.Name == "TR_FakeFloor" or IsCharacterDescendant(obj) then return false end
	if obj:IsA("Tool") then return GetItemBasePart(obj) ~= nil end
	if obj:IsA("BasePart") or obj:IsA("Model") then
		if obj:FindFirstChildWhichIsA("ProximityPrompt", true) then return GetItemBasePart(obj) ~= nil end
		local lower = obj.Name:lower() for _, kw in ipairs(ITEM_KEYWORDS) do
			if lower:find(kw, 1, true) then return GetItemBasePart(obj) ~= nil end end end return false end
CollectTargetItem = function(itemData) pcall(function() local myRoot = GetRootPart()
		if not myRoot or not itemData or not itemData.Part or not itemData.Part.Parent then return end
		local origCFrame = myRoot.CFrame myRoot.CFrame = itemData.Part.CFrame + Vector3.new(0, 2, 0)
		task.wait(0.06) SafeFireTouch(myRoot, itemData.Part, 0) SafeFireTouch(myRoot, itemData.Part, 1)
		local prompt = itemData.Object:FindFirstChildWhichIsA("ProximityPrompt", true)
			or itemData.Part:FindFirstChildWhichIsA("ProximityPrompt", true) if prompt then
			prompt.HoldDuration = 0 SafeFirePrompt(prompt) end task.wait(0.06)
		if myRoot and myRoot.Parent then myRoot.CFrame = origCFrame end end) end
ScanWorkspaceItems = function() ScannedItemsCache = {} local filter = ItemSearchBox.Text:lower()
	local myRoot = GetRootPart() local myPos = myRoot and myRoot.Position or Vector3.new(0, 0, 0)
	for _, obj in ipairs(workspace:GetDescendants()) do if MatchesItemCriteria(obj) then
			local part = GetItemBasePart(obj)
			if part and (filter == "" or obj.Name:lower():find(filter, 1, true)) then
				table.insert(ScannedItemsCache, { Object = obj, Part = part, Name = obj.Name,
					Distance = (part.Position - myPos).Magnitude }) end end if #ScannedItemsCache >= 35 then break end
	end table.sort(ScannedItemsCache, function(a, b) return a.Distance < b.Distance end)
	for _, child in ipairs(ItemsListContainer:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end end for idx, item in ipairs(ScannedItemsCache) do
		local Row = CreateCard(ItemsListContainer, 42, idx)
		local Lbl = MakeLabel(Row, UDim2.new(1, -190, 1, 0), UDim2.new(0, 12, 0, 0), string.format("%s %s (%.0f studs)", E.Box, item.Name, item.Distance), Enum.Font.GothamSemibold, 12, "TextPrimary", Enum.TextXAlignment.Left)
		local TpBtn = MakeButton(Row, UDim2.new(0, 78, 0, 28), UDim2.new(1, -172, 0.5, -14), "Teleport", "Accent", 11)
		TpBtn.MouseButton1Click:Connect(function() if item.Part and item.Part.Parent then
				local pos = item.Part.Position SafeTeleportToCoords(pos.X, pos.Y + 3, pos.Z) end end)
		local ColBtn = MakeButton(Row, UDim2.new(0, 78, 0, 28), UDim2.new(1, -86, 0.5, -14), "Collect", "AccentDark", 11)
		ColBtn.MouseButton1Click:Connect(function() CollectTargetItem(item) end) end end
ScanNowBtn.MouseButton1Click:Connect(ScanWorkspaceItems)
CollectNearestBtn.MouseButton1Click:Connect(function()
	if ScannedItemsCache[1] then CollectTargetItem(ScannedItemsCache[1]) end end) end
--==============================================================================
-- 11. TAB 5: FLIGHT & MOVEMENT
--==============================================================================
local masterFlightEnabled = (savedConfig.Settings.MasterFlightEnabled == true)
local keyFlying, fakeGroundPart = false, nil
local isFlightActive, stopFlight, startFlight, toggleFlightState do
CreateSectionHeader(Tab5_Flight, "Flight Engine & Keybind Controls", 1)
local FlightEngineCard = CreateCard(Tab5_Flight, 92, 2)
local masterFlightToggleBtn = Instance.new("TextButton")
masterFlightToggleBtn.Size = UDim2.new(0.48, -12, 0, 34)
masterFlightToggleBtn.Position = UDim2.new(0, 10, 0, 10)
masterFlightToggleBtn.Font = Enum.Font.GothamBold masterFlightToggleBtn.TextSize = 12
masterFlightToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
masterFlightToggleBtn.Parent = FlightEngineCard AddCorner(masterFlightToggleBtn, 6)
local keyFlyToggleBtn = Instance.new("TextButton") keyFlyToggleBtn.Size = UDim2.new(0.52, -12, 0, 34)
keyFlyToggleBtn.Position = UDim2.new(0.48, 2, 0, 10) keyFlyToggleBtn.Font = Enum.Font.GothamBold
keyFlyToggleBtn.TextSize = 12 keyFlyToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
keyFlyToggleBtn.Parent = FlightEngineCard AddCorner(keyFlyToggleBtn, 6)
local flyKeyBindLabel = MakeLabel(FlightEngineCard, UDim2.new(0, 210, 0, 30), UDim2.new(0, 12, 0, 52), "Flight Shortcut Keybind:", Enum.Font.GothamSemibold, 12, "TextPrimary", Enum.TextXAlignment.Left)
local flyKeyAssignBtn = MakeButton(FlightEngineCard, UDim2.new(0, 130, 0, 30), UDim2.new(1, -240, 0, 52), "Bind Key: [E]", "PanelBg", 11)
local flyKeyDeleteBtn = Instance.new("TextButton") flyKeyDeleteBtn.Size = UDim2.new(0, 92, 0, 30)
flyKeyDeleteBtn.Position = UDim2.new(1, -102, 0, 52)
flyKeyDeleteBtn.BackgroundColor3 = Color3.fromRGB(165, 38, 55)
flyKeyDeleteBtn.Font = Enum.Font.GothamBold flyKeyDeleteBtn.TextSize = 11
flyKeyDeleteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
flyKeyDeleteBtn.Text = E.Trash .. " Delete Key" flyKeyDeleteBtn.Parent = FlightEngineCard
AddCorner(flyKeyDeleteBtn, 6) local function GetFlyKeyText()
	return savedConfig.Settings.FlyKeybind or "None" end local function RefreshFlyKeyTexts()
	local k = GetFlyKeyText() flyKeyAssignBtn.Text = "Bind Key: [" .. k .. "]"
	keyFlyToggleBtn.Text = "Keybind [" .. k .. "] Flight: " .. (keyFlying and "ON" or "OFF")
	keyFlyToggleBtn.BackgroundColor3 = keyFlying and Color3.fromRGB(38, 168, 92) or Color3.fromRGB(185, 52, 52)
	masterFlightToggleBtn.BackgroundColor3 = masterFlightEnabled and Color3.fromRGB(38, 168, 92) or Color3.fromRGB(185, 52, 52)
	masterFlightToggleBtn.Text = masterFlightEnabled and "Master Flight Switch: ON" or "Master Flight Switch: OFF"
end isFlightActive = function() return masterFlightEnabled and keyFlying end stopFlight = function()
	keyFlying = false freezePosition = nil RefreshFlyKeyTexts() if fakeGroundPart then
		fakeGroundPart:Destroy() fakeGroundPart = nil end local char = player.Character if char then
		local hum = char:FindFirstChildOfClass("Humanoid") local root = char:FindFirstChild("HumanoidRootPart")
		if hum then hum.PlatformStand = false hum:ChangeState(Enum.HumanoidStateType.GettingUp)
			hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
			hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true) end if root then
			root.AssemblyLinearVelocity = Vector3.new(0, 0, 0) root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
		end end end startFlight = function() if not masterFlightEnabled then return end
	local char = player.Character if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart") local hum = char:FindFirstChildOfClass("Humanoid")
	if not root or not hum then return end keyFlying = true freezePosition = root.Position
	RefreshFlyKeyTexts() hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
	hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false) hum.PlatformStand = false
	if not fakeGroundPart then fakeGroundPart = Instance.new("Part") fakeGroundPart.Name = "TR_FakeFloor"
		fakeGroundPart.Size = Vector3.new(4, 0.2, 4) fakeGroundPart.Transparency = 1
		fakeGroundPart.Anchored = true fakeGroundPart.CanCollide = true fakeGroundPart.Parent = workspace end
end toggleFlightState = function() if not masterFlightEnabled then return end if keyFlying then
		stopFlight() else startFlight() end end masterFlightToggleBtn.MouseButton1Click:Connect(function()
	masterFlightEnabled = not masterFlightEnabled
	savedConfig.Settings.MasterFlightEnabled = masterFlightEnabled
	if syncAllSystems then syncAllSystems() end RefreshFlyKeyTexts() if not masterFlightEnabled then
		stopFlight() end end) keyFlyToggleBtn.MouseButton1Click:Connect(toggleFlightState)
flyKeyAssignBtn.MouseButton1Click:Connect(function() flyKeyAssignBtn.Text = "[Key / Del]"
	ActiveKeybindCaptureCallback = function(keyName) savedConfig.Settings.FlyKeybind = keyName
		RefreshFlyKeyTexts() SaveConfig(false) end end) flyKeyDeleteBtn.MouseButton1Click:Connect(function()
	savedConfig.Settings.FlyKeybind = "None" ActiveKeybindCaptureCallback = nil RefreshFlyKeyTexts()
	SaveConfig(false) end) RefreshFlyKeyTexts()
CreateSectionHeader(Tab5_Flight, "Master Utility & Physics Controls", 3)
CreateToggle(Tab5_Flight, "Master Utility Switch (Enable WalkSpeed & JumpPower)", Config.MasterUtilityEnabled, 4, function(state)
	Config.MasterUtilityEnabled = state SaveConfig(false) end)
CreateToggle(Tab5_Flight, "Noclip Mode (Disable Character CanCollide)", Config.NoclipEnabled, 5, function(state)
	Config.NoclipEnabled = state SaveConfig(false) end)
CreateToggle(Tab5_Flight, "Shift-Down Flight Descent (Hold LeftShift to Descend)", Config.ShiftDownEnabled, 7, function(state)
	Config.ShiftDownEnabled = state SaveConfig(false) end)
CreateToggle(Tab5_Flight, "Countdown / Spawn Freeze Bypass (Unanchor & Clear Freeze Tags)", Config.CountdownBypass, 8, function(state)
	Config.CountdownBypass = state SaveConfig(false) end)
CreateSectionHeader(Tab5_Flight, "Speed & Movement Sliders", 9)
CreateSlider(Tab5_Flight, "Fly Speed", 1, 1000, Config.FlySpeed, 10, function(val) Config.FlySpeed = val; SaveConfig(false) end)
CreateSlider(Tab5_Flight, "WalkSpeed", 16, 500, Config.WalkSpeed, 12, function(val) Config.WalkSpeed = val; SaveConfig(false) end)
CreateSlider(Tab5_Flight, "JumpPower", 50, 500, Config.JumpPower, 13, function(val) Config.JumpPower = val; SaveConfig(false) end)
end
--==============================================================================
-- 12. TAB 6: MULTI-TARGET FLING HUB (WITH NETWORK PAUSE BYPASS)
--==============================================================================
local SelectedTargets, FlingActive = {}, false local RefreshFlingPlayerList, StopFling do
CreateSectionHeader(Tab6_Instant, E.Bolt .. " Multi-Target Fling Hub (With Auto Network Pause Bypass)", 1)
CreateToggle(Tab6_Instant, "Auto-Select Players When New Player Joins (Friends Excluded)", Config.AutoSelectFling == true, 2, function(state)
	Config.AutoSelectFling = state SaveConfig(false) end)
local FlingHubCard = CreateCard(Tab6_Instant, 356, 3) local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -24, 0, 22) statusLabel.Position = UDim2.new(0, 12, 0, 8)
statusLabel.BackgroundTransparency = 1 statusLabel.Text = "Select targets to fling (Friends excluded)"
statusLabel.TextSize = 12 statusLabel.Font = Enum.Font.GothamMedium
statusLabel.TextXAlignment = Enum.TextXAlignment.Left statusLabel.Parent = FlingHubCard
RegisterThemeObject(statusLabel, "TextColor3", "TextSecondary")
local selectionFrame = Instance.new("Frame") selectionFrame.Size = UDim2.new(1, -24, 0, 214)
selectionFrame.Position = UDim2.new(0, 12, 0, 34) selectionFrame.BackgroundTransparency = 0.25
selectionFrame.BorderSizePixel = 0 selectionFrame.Parent = FlingHubCard
RegisterThemeObject(selectionFrame, "BackgroundColor3", "PanelBg") AddCorner(selectionFrame, 10)
local playerScrollFrame = Instance.new("ScrollingFrame")
playerScrollFrame.Size = UDim2.new(1, -10, 1, -10) playerScrollFrame.Position = UDim2.new(0, 5, 0, 5)
playerScrollFrame.BackgroundTransparency = 1 playerScrollFrame.BorderSizePixel = 0
playerScrollFrame.ScrollBarThickness = 4 playerScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
playerScrollFrame.Parent = selectionFrame
RegisterThemeObject(playerScrollFrame, "ScrollBarImageColor3", "Accent")
local scrollLayout = Instance.new("UIListLayout") scrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
scrollLayout.Padding = UDim.new(0, 6) scrollLayout.Parent = playerScrollFrame
local startButton = MakeButton(FlingHubCard, UDim2.new(0.48, -12, 0, 40), UDim2.new(0, 12, 0, 258), E.Play .. " START FLING", "Accent", 13)
local stopButton = MakeButton(FlingHubCard, UDim2.new(0.48, -12, 0, 40), UDim2.new(0.52, 0, 0, 258), E.Stop .. " STOP FLING", "AccentDark", 13)
local selectAllButton = MakeButton(FlingHubCard, UDim2.new(0.48, -12, 0, 36), UDim2.new(0, 12, 0, 306), "SELECT ALL", "PanelBg", 12)
local deselectAllButton = MakeButton(FlingHubCard, UDim2.new(0.48, -12, 0, 36), UDim2.new(0.52, 0, 0, 306), "DESELECT ALL", "PanelBg", 12)
local PlayerCheckboxes = {} genv.OldPos = nil genv.FPDH = workspace.FallenPartsDestroyHeight
local UpdateStatus local function RunNetworkPauseBypass() pcall(function()
		CoreGui.RobloxGui["CoreScripts/NetworkPause"]:Destroy() end) end local function CountSelectedTargets()
	local count = 0 for _ in pairs(SelectedTargets) do count = count + 1 end return count end
UpdateStatus = function() local count = CountSelectedTargets() local theme = GetTheme()
	if FlingActive then statusLabel.Text = E.Bolt .. " Flinging " .. count .. " target(s)..."
		statusLabel.TextColor3 = theme.Accent else
		statusLabel.Text = count .. " target(s) selected (Friends excluded)"
		statusLabel.TextColor3 = theme.TextSecondary end end
table.insert(ThemeObjects.CustomCallbacks, UpdateStatus) RefreshFlingPlayerList = function()
	for _, child in pairs(playerScrollFrame:GetChildren()) do if child:IsA("Frame") then child:Destroy() end
	end PlayerCheckboxes = {} local playerList = Players:GetPlayers()
	table.sort(playerList, function(a, b) return a.Name:lower() < b.Name:lower() end) local yPos = 0
	for _, target in ipairs(playerList) do if target ~= player then
			if SelectedTargets[target.Name] == nil and Config.AutoSelectFling == true then
				if not IsFriend(target) then SelectedTargets[target.Name] = target end end
			local row = Instance.new("Frame") row.Size = UDim2.new(1, 0, 0, 36)
			row.Position = UDim2.new(0, 0, 0, yPos) row.BackgroundTransparency = 0.2
			row.Parent = playerScrollFrame RegisterThemeObject(row, "BackgroundColor3", "CardBg")
			AddCorner(row, 8) local checkBox = Instance.new("Frame") checkBox.Size = UDim2.new(0, 22, 0, 22)
			checkBox.Position = UDim2.new(0, 10, 0.5, -11) checkBox.BorderSizePixel = 0 checkBox.Parent = row
			RegisterThemeObject(checkBox, "BackgroundColor3", "PanelBg") AddCorner(checkBox, 5)
			local checkMark = Instance.new("TextLabel") checkMark.Size = UDim2.new(1, 0, 1, 0)
			checkMark.BackgroundTransparency = 1 checkMark.Text = E.Tick checkMark.TextSize = 14
			checkMark.Font = Enum.Font.GothamBold checkMark.Visible = SelectedTargets[target.Name] ~= nil
			checkMark.Parent = checkBox RegisterThemeObject(checkMark, "TextColor3", "Accent")
			local nameLbl = Instance.new("TextLabel") nameLbl.Size = UDim2.new(1, -45, 1, 0)
			nameLbl.Position = UDim2.new(0, 40, 0, 0) nameLbl.BackgroundTransparency = 1
			nameLbl.Text = IsFriend(target) and (target.Name .. " " .. E.Star) or target.Name
			nameLbl.TextSize = 12 nameLbl.Font = Enum.Font.GothamMedium
			nameLbl.TextXAlignment = Enum.TextXAlignment.Left nameLbl.Parent = row
			RegisterThemeObject(nameLbl, "TextColor3", "TextPrimary") local clickBtn = Instance.new("TextButton")
			clickBtn.Size = UDim2.new(1, 0, 1, 0) clickBtn.BackgroundTransparency = 1 clickBtn.Text = ""
			clickBtn.Parent = row clickBtn.MouseButton1Click:Connect(function()
				if SelectedTargets[target.Name] then SelectedTargets[target.Name] = nil checkMark.Visible = false
				else SelectedTargets[target.Name] = target checkMark.Visible = true end UpdateStatus() end)
			PlayerCheckboxes[target.Name] = { Row = row, Check = checkMark } yPos = yPos + 42 end end
	playerScrollFrame.CanvasSize = UDim2.new(0, 0, 0, yPos) UpdateStatus() end
local function ToggleAllPlayers(select) for _, target in ipairs(Players:GetPlayers()) do
		if target ~= player then local boxData = PlayerCheckboxes[target.Name] if boxData then if select then
					SelectedTargets[target.Name] = target boxData.Check.Visible = true else
					SelectedTargets[target.Name] = nil boxData.Check.Visible = false end end end end UpdateStatus() end
local function Message(title, text, timeLen) pcall(function() StarterGui:SetCore("SendNotification", {
			Title = title, Text = text, Duration = timeLen or 3 }) end) end local function SkidFling(TargetPlayer)
	local Character = player.Character
	local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
	local RootPart = Humanoid and Humanoid.RootPart local TCharacter = TargetPlayer.Character
	if not TCharacter then return end local THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")
	local TRootPart = THumanoid and THumanoid.RootPart local THead = TCharacter:FindFirstChild("Head")
	local Accessory = TCharacter:FindFirstChildOfClass("Accessory")
	local Handle = Accessory and Accessory:FindFirstChild("Handle")
	if Character and Humanoid and RootPart then if RootPart.Velocity.Magnitude < 50 then
			genv.OldPos = RootPart.CFrame end if THumanoid and THumanoid.Sit then return end if THead then
			workspace.CurrentCamera.CameraSubject = THead elseif Handle then
			workspace.CurrentCamera.CameraSubject = Handle elseif THumanoid and TRootPart then
			workspace.CurrentCamera.CameraSubject = THumanoid end local FPos = function(BasePart, Pos, Ang)
			RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
			Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang)
			RootPart.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7) RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
		end local SFBasePart = function(BasePart) local TimeToWait = 2 local Time = tick() local Angle = 0
			repeat if RootPart and THumanoid then Angle = Angle + 100
					FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
					task.wait()
					FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
					task.wait() end until Time + TimeToWait < tick() or not FlingActive end
		workspace.FallenPartsDestroyHeight = 0 / 0 local BV = Instance.new("BodyVelocity") BV.Parent = RootPart
		BV.Velocity = Vector3.new(0, 0, 0) BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false) if TRootPart then SFBasePart(TRootPart)
		elseif THead then SFBasePart(THead) elseif Handle then SFBasePart(Handle) end BV:Destroy()
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
		workspace.CurrentCamera.CameraSubject = Humanoid if genv.OldPos then repeat
				RootPart.CFrame = genv.OldPos * CFrame.new(0, 0.5, 0)
				Character:SetPrimaryPartCFrame(genv.OldPos * CFrame.new(0, 0.5, 0)) Humanoid:ChangeState("GettingUp")
				for _, part in pairs(Character:GetChildren()) do if part:IsA("BasePart") then
						part.Velocity, part.RotVelocity = Vector3.new(), Vector3.new() end end task.wait()
			until (RootPart.Position - genv.OldPos.p).Magnitude < 25
			workspace.FallenPartsDestroyHeight = genv.FPDH end end end local function StartFling()
	if FlingActive then return end if CountSelectedTargets() == 0 then
		statusLabel.Text = "No targets selected!" task.delay(1, UpdateStatus) return end
	RunNetworkPauseBypass() FlingActive = true UpdateStatus()
	Message("T.R Fling", "Started multi-target fling & bypass engine.", 2) task.spawn(function()
		while FlingActive do local validTargets = {} for name, targetPlayer in pairs(SelectedTargets) do
				if targetPlayer and targetPlayer.Parent then table.insert(validTargets, targetPlayer) else
					SelectedTargets[name] = nil if PlayerCheckboxes[name] then
						PlayerCheckboxes[name].Check.Visible = false end end end
			for _, targetPlayer in ipairs(validTargets) do if FlingActive then SkidFling(targetPlayer)
					task.wait(0.05) else break end end task.wait(0.2) end end) end StopFling = function()
	if not FlingActive then return end FlingActive = false UpdateStatus()
	Message("T.R Fling", "Fling engine stopped.", 2) end startButton.MouseButton1Click:Connect(StartFling)
stopButton.MouseButton1Click:Connect(StopFling)
selectAllButton.MouseButton1Click:Connect(function() ToggleAllPlayers(true) end)
deselectAllButton.MouseButton1Click:Connect(function() ToggleAllPlayers(false) end) end
--==============================================================================
-- 13. TAB 7: AIMBOT, ESP, CAMERA & LIGHTING VISUALS
--==============================================================================
local ESP_UPDATE_INTERVAL, MAX_DISTANCE, LERP_ALPHA = 0.033333333333333, 500, 0.16
local FOV_RADIUS = tonumber(Config.AimbotFOVRadius) or 200
local fovCircleEnabled = (Config.AimbotFOVCircleEnabled ~= false)
local aimbotEnabled = (Config.AimbotEnabled == true) local strongLock = (Config.StrongLock == true)
local wallcheckEnabled = (Config.WallcheckEnabled ~= false)
local aimbotTeamCheck = (Config.AimbotTeamCheck ~= false)
local espShowTeammates = (Config.ESPShowTeammates == true)
local aimPartName = Config.AimPartName or "Head" local currentTarget, lastEspUpdate = nil, 0
local excludedPlayers, characterCache, adornmentsCache = {}, {}, {}
local guiFovCircle, guiFovStroke = nil, nil
local IsTeammate, getTargetPart, isTargetVisible, removePlayerAdornments, clearAllAdornments
local RefreshESPHighlights, updateAllAdornments, findBestTarget
local aimbotStatusLabel, excludeFrame, updateExcludeCount, rebuildExcludeList, toggleAimbot, ApplyCameraMode
do guiFovCircle = Instance.new("Frame") guiFovCircle.Name = "TR_FOVCircle"
	guiFovCircle.AnchorPoint = Vector2.new(0.5, 0.5) guiFovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
	guiFovCircle.Size = UDim2.new(0, FOV_RADIUS * 2, 0, FOV_RADIUS * 2)
	guiFovCircle.BackgroundTransparency = 1 guiFovCircle.BorderSizePixel = 0 guiFovCircle.Visible = false
	guiFovCircle.Parent = ScreenGui Instance.new("UICorner", guiFovCircle).CornerRadius = UDim.new(1, 0)
	guiFovStroke = Instance.new("UIStroke", guiFovCircle) guiFovStroke.Thickness = 1.8
	guiFovStroke.Transparency = 0.15 RegisterThemeObject(guiFovStroke, "Color", "Accent")
	SyncAimbotFovCircleVisibility = function()
		local showCircle = aimbotEnabled and fovCircleEnabled and not isClosingPermanently if guiFovCircle then
			guiFovCircle.Size = UDim2.new(0, FOV_RADIUS * 2, 0, FOV_RADIUS * 2) guiFovCircle.Visible = showCircle
		end end local teamCache = {} local lastTeamCacheClear = 0 local function getTeamValFast(p)
		if not p then return nil end
		local v = p:FindFirstChild("Team") or p:FindFirstChild("TeamColor") or (p:FindFirstChild("leaderstats") and p.leaderstats:FindFirstChild("Team"))
		if not v and p.Character then
			v = p.Character:FindFirstChild("Team") or p.Character:FindFirstChild("TeamColor") end
		return v and tostring(v.Value or v):lower() end local function checkIsTeammateRaw(plr)
		if LocalPlayer.Team and plr.Team and LocalPlayer.Team == plr.Team then return true end
		if LocalPlayer.Team and plr.Team and tostring(LocalPlayer.Team.Name):lower() == tostring(plr.Team.Name):lower() then
			return true end
		if LocalPlayer.TeamColor and plr.TeamColor and LocalPlayer.TeamColor == plr.TeamColor then
			local tcName = tostring(LocalPlayer.TeamColor.Name):lower()
			if tcName ~= "white" and tcName ~= "medium stone grey" and tcName ~= "institutional white" then
				return true end end
		local myAttr = LocalPlayer:GetAttribute("Team") or (LocalPlayer.Character and LocalPlayer.Character:GetAttribute("Team"))
		local theirAttr = plr:GetAttribute("Team") or (plr.Character and plr.Character:GetAttribute("Team"))
		if myAttr ~= nil and theirAttr ~= nil and tostring(myAttr):lower() == tostring(theirAttr):lower() then
			return true end local myVal, theirVal = getTeamValFast(LocalPlayer), getTeamValFast(plr)
		if myVal and theirVal and myVal ~= "" and myVal == theirVal then return true end return false end
	IsTeammate = function(plr) if not plr or plr == LocalPlayer then return false end local now = os.clock()
		if now - lastTeamCacheClear >= 1.5 then table.clear(teamCache) lastTeamCacheClear = now end
		local cached = teamCache[plr] if cached ~= nil then return cached end
		local ok, res = pcall(checkIsTeammateRaw, plr) local isTeam = (ok and res == true)
		teamCache[plr] = isTeam return isTeam end getTargetPart = function(character)
		if not character then return nil end local p = character:FindFirstChild(aimPartName)
		if p and p:IsA("BasePart") then return p end local hrp = character:FindFirstChild("HumanoidRootPart")
		if hrp and hrp:IsA("BasePart") then return hrp end
		local t = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
		return (t and t:IsA("BasePart") and t) or character.PrimaryPart end
	local reusableWallcheckParams = RaycastParams.new()
	reusableWallcheckParams.FilterType = Enum.RaycastFilterType.Blacklist local reusableWallFilter = {}
	updateWallcheckFilter = function(char) char = char or LocalPlayer.Character reusableWallFilter[1] = char
		reusableWallcheckParams.FilterDescendantsInstances = reusableWallFilter end updateWallcheckFilter()
	isTargetVisible = function(targetPart, targetCharacter) if not wallcheckEnabled then return true end
		local cam = workspace.CurrentCamera if not cam or not targetPart then return false end
		local camPos = cam.CFrame.Position local tPos = targetPart.Position
		local dir = Vector3.new(tPos.X - camPos.X, tPos.Y - camPos.Y, tPos.Z - camPos.Z)
		local res = workspace:Raycast(camPos, dir, reusableWallcheckParams)
		return (not res) or (targetCharacter and res.Instance and res.Instance:IsDescendantOf(targetCharacter))
	end local function worldToScreenDistance(worldPos) local cam = workspace.CurrentCamera
		if not cam then return nil, false, math.huge end
		local vp, onScreen = cam:WorldToViewportPoint(worldPos)
		if not onScreen or vp.Z <= 0 then return nil, false, math.huge end local vs = cam.ViewportSize
		local dx = vp.X - (vs.X * 0.5) local dy = vp.Y - (vs.Y * 0.5)
		return vp, true, math.sqrt(dx * dx + dy * dy) end removePlayerAdornments = function(plr)
		local pair = adornmentsCache[plr] if pair then
			if pair.inner then pcall(function() pair.inner:Destroy() end) end
			if pair.outline then pcall(function() pair.outline:Destroy() end) end adornmentsCache[plr] = nil end
		characterCache[plr] = nil end clearAllAdornments = function()
		for plr in pairs(adornmentsCache) do removePlayerAdornments(plr) end end
	RefreshESPHighlights = function() local themeAccent = GetTheme().Accent
		for _, plr in ipairs(Players:GetPlayers()) do if plr ~= player and plr.Character then
				local existing = plr.Character:FindFirstChild("TR_ESP_Highlight")
				local allowTeam = espShowTeammates or not IsTeammate(plr)
				if Config.ESPEnabled and not excludedPlayers[plr] and allowTeam then if not existing then
						pcall(function() local hl = Instance.new("Highlight") hl.Name = "TR_ESP_Highlight"
							hl.FillColor = themeAccent hl.OutlineColor = Color3.fromRGB(255, 255, 255)
							hl.FillTransparency = 0.45 hl.OutlineTransparency = 0.1 hl.Adornee = plr.Character
							hl.Parent = plr.Character end) else if existing.FillColor ~= themeAccent then
							existing.FillColor = themeAccent end end elseif existing then existing:Destroy() end end end end
	updateAllAdornments = function() if not Config.ESPEnabled then
			if next(adornmentsCache) ~= nil then clearAllAdornments() end return end
		local accentCol = GetTheme().Accent for plr in pairs(adornmentsCache) do
			if not plr or not plr.Parent or excludedPlayers[plr] then removePlayerAdornments(plr) end end
		for _, plr in ipairs(Players:GetPlayers()) do local allowTeam = espShowTeammates or not IsTeammate(plr)
			if plr ~= LocalPlayer and not excludedPlayers[plr] and allowTeam then local char = plr.Character
				local root = char and (char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart)
				local hum = char and char:FindFirstChildOfClass("Humanoid")
				if char and root and hum and hum.Health > 0 then local pair = adornmentsCache[plr] if not pair then
						local inner = Instance.new("BoxHandleAdornment") inner.AlwaysOnTop = true inner.ZIndex = 10
						inner.Transparency = 0.35 inner.Color3 = accentCol inner.Name = "ESP_HitboxInner"
						inner.Size = V3_ESP_BOX inner.CFrame = CF_ESP_OFFSET inner.Parent = PlayerGui
						local outline = Instance.new("BoxHandleAdornment") outline.AlwaysOnTop = true outline.ZIndex = 9
						outline.Transparency = 0.75 outline.Color3 = Color3.fromRGB(0, 0, 0)
						outline.Name = "ESP_HitboxOutline" outline.Size = V3_ESP_OUTLINE outline.CFrame = CF_ESP_OFFSET
						outline.Parent = PlayerGui pair = { inner = inner, outline = outline } adornmentsCache[plr] = pair
					end if pair.inner.Adornee ~= root then pair.inner.Adornee = root pair.outline.Adornee = root end
					if pair.inner.Color3 ~= accentCol then pair.inner.Color3 = accentCol end else
					if adornmentsCache[plr] then removePlayerAdornments(plr) end end else
				if adornmentsCache[plr] then removePlayerAdornments(plr) end end end end findBestTarget = function()
		local cam = workspace.CurrentCamera if not cam then return nil end
		local bestPlr, bestDist = nil, fovCircleEnabled and FOV_RADIUS or math.huge
		local camPos = cam.CFrame.Position local maxDistSq = MAX_DISTANCE * MAX_DISTANCE
		for _, plr in ipairs(Players:GetPlayers()) do
			local validEnemy = (not aimbotTeamCheck) or (not IsTeammate(plr))
			if plr ~= LocalPlayer and not excludedPlayers[plr] and validEnemy then local char = plr.Character
				local hum = char and char:FindFirstChildOfClass("Humanoid") local part = getTargetPart(char)
				if char and hum and hum.Health > 0 and part then local pp = part.Position local dx = pp.X - camPos.X
					local dy = pp.Y - camPos.Y local dz = pp.Z - camPos.Z
					if (dx * dx + dy * dy + dz * dz) <= maxDistSq then
						local _, onScreen, sDist = worldToScreenDistance(pp)
						if onScreen and sDist <= bestDist and isTargetVisible(part, char) then
							bestDist, bestPlr = sDist, plr end end end end end return bestPlr end
	-- Section 1: Aimbot Engine & Keybind Controls (matching Tab 5 FlightEngineCard layout!)
	CreateSectionHeader(Tab7_Visuals, "Aimbot Engine & Keybind Controls", 1)
	local AimbotEngineCard = CreateCard(Tab7_Visuals, 92, 2)
	local aimbotToggleBtn = Instance.new("TextButton", AimbotEngineCard)
	aimbotToggleBtn.Size = UDim2.new(0.48, -12, 0, 34) aimbotToggleBtn.Position = UDim2.new(0, 10, 0, 10)
	aimbotToggleBtn.Font = Enum.Font.GothamBold aimbotToggleBtn.TextSize = 12
	aimbotToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255) AddCorner(aimbotToggleBtn, 6)
	aimbotStatusLabel = Instance.new("TextLabel", AimbotEngineCard)
	aimbotStatusLabel.Size = UDim2.new(0.52, -14, 0, 34)
	aimbotStatusLabel.Position = UDim2.new(0.48, 4, 0, 10) aimbotStatusLabel.BackgroundTransparency = 0.15
	aimbotStatusLabel.Font = Enum.Font.GothamSemibold aimbotStatusLabel.TextSize = 12
	aimbotStatusLabel.Text = "Status: Idle"
	RegisterThemeObject(aimbotStatusLabel, "BackgroundColor3", "PanelBg")
	RegisterThemeObject(aimbotStatusLabel, "TextColor3", "TextPrimary") AddCorner(aimbotStatusLabel, 6)
	local aimKeyBindLabel = MakeLabel(AimbotEngineCard, UDim2.new(0, 210, 0, 30), UDim2.new(0, 12, 0, 52), "Aimbot Shortcut Keybind:", Enum.Font.GothamSemibold, 12, "TextPrimary", Enum.TextXAlignment.Left)
	local aimbotKeyAssignBtn = MakeButton(AimbotEngineCard, UDim2.new(0, 130, 0, 30), UDim2.new(1, -240, 0, 52), "Bind Key: [Q]", "PanelBg", 11)
	local aimbotKeyDeleteBtn = Instance.new("TextButton", AimbotEngineCard)
	aimbotKeyDeleteBtn.Size = UDim2.new(0, 92, 0, 30)
	aimbotKeyDeleteBtn.Position = UDim2.new(1, -102, 0, 52)
	aimbotKeyDeleteBtn.BackgroundColor3 = Color3.fromRGB(165, 38, 55)
	aimbotKeyDeleteBtn.Font = Enum.Font.GothamBold aimbotKeyDeleteBtn.TextSize = 11
	aimbotKeyDeleteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	aimbotKeyDeleteBtn.Text = E.Trash .. " Delete Key" AddCorner(aimbotKeyDeleteBtn, 6)
	-- Neat V94 CreateToggle rows for Aimbot Settings
	CreateToggle(Tab7_Visuals, "Strong Lock Mode (Instant Camera Snap vs Smooth Lerp)", strongLock, 3, function(state)
		strongLock = state Config.StrongLock = state if not strongLock then currentTarget = nil end
		SaveConfig(false) end)
	CreateToggle(Tab7_Visuals, "Raycast Wallcheck (Line-of-Sight Target Verification)", wallcheckEnabled, 4, function(state)
		wallcheckEnabled = state Config.WallcheckEnabled = state SaveConfig(false) end)
	CreateToggle(Tab7_Visuals, "Only Aim at Enemies (Ignore Teammates)", aimbotTeamCheck, 5, function(state)
		aimbotTeamCheck = state Config.AimbotTeamCheck = state
		if state and currentTarget and IsTeammate(currentTarget) then currentTarget = nil end SaveConfig(false)
	end)
	CreateToggle(Tab7_Visuals, "Show Aimbot FOV Circle (Turn OFF for Full-Screen Aimbot)", fovCircleEnabled, 6, function(state)
		fovCircleEnabled = state Config.AimbotFOVCircleEnabled = state currentTarget = nil
		SyncAimbotFovCircleVisibility() SaveConfig(false) end)
	-- Neat V94 CreateSlider for Aimbot FOV Circle Radius
	local FovSliderObj local fovBox
	FovSliderObj = CreateSlider(Tab7_Visuals, "Aimbot FOV Circle Radius (px)", 20, 800, FOV_RADIUS, 7, function(val)
		FOV_RADIUS = val Config.AimbotFOVRadius = val if fovBox then fovBox.Text = tostring(val) end
		SyncAimbotFovCircleVisibility() SaveConfig(false) end)
	-- Target Part, Manual FOV Input & Player Exclusion Row Card
	local AimbotExtraCard = CreateCard(Tab7_Visuals, 48, 8)
	local aimPartBtn = MakeButton(AimbotExtraCard, UDim2.new(0.34, -10, 0, 32), UDim2.new(0, 10, 0, 8), "", "Accent", 12)
	fovBox = Instance.new("TextBox", AimbotExtraCard) fovBox.Size = UDim2.new(0.32, -8, 0, 32)
	fovBox.Position = UDim2.new(0.34, 4, 0, 8)
	fovBox.PlaceholderText = "FOV Radius (" .. tostring(FOV_RADIUS) .. ")"
	fovBox.Text = tostring(FOV_RADIUS) fovBox.ClearTextOnFocus = false
	fovBox.Font = Enum.Font.GothamSemibold fovBox.TextSize = 12
	RegisterThemeObject(fovBox, "BackgroundColor3", "PanelBg")
	RegisterThemeObject(fovBox, "TextColor3", "TextPrimary") AddCorner(fovBox, 6)
	local excludeBtn = MakeButton(AimbotExtraCard, UDim2.new(0.34, -10, 0, 32), UDim2.new(0.66, 0, 0, 8), "Exclude Players: 0", "AccentDark", 12)
	excludeFrame = Instance.new("Frame", AimbotExtraCard) excludeFrame.Size = UDim2.new(1, -20, 0, 130)
	excludeFrame.Position = UDim2.new(0, 10, 0, 48) excludeFrame.BackgroundTransparency = 0.1
	excludeFrame.BorderSizePixel = 0 excludeFrame.Visible = false
	RegisterThemeObject(excludeFrame, "BackgroundColor3", "PanelBg") AddCorner(excludeFrame, 8)
	local excludeList = Instance.new("ScrollingFrame", excludeFrame)
	excludeList.Size = UDim2.new(1, -12, 1, -12) excludeList.Position = UDim2.new(0, 6, 0, 6)
	excludeList.BackgroundTransparency = 1 excludeList.BorderSizePixel = 0
	excludeList.CanvasSize = UDim2.new(0, 0, 0, 0) excludeList.ScrollBarThickness = 4
	RegisterThemeObject(excludeList, "ScrollBarImageColor3", "Accent")
	Instance.new("UIListLayout", excludeList).Padding = UDim.new(0, 5) local function RefreshAimbotVisuals()
		local k = Config.AimbotKeybind or "None" aimbotKeyAssignBtn.Text = "Bind Key: [" .. k .. "]"
		aimbotToggleBtn.Text = "Aimbot Lock [" .. k .. "]: " .. (aimbotEnabled and "ON" or "OFF")
		aimbotToggleBtn.BackgroundColor3 = aimbotEnabled and Color3.fromRGB(38, 168, 92) or Color3.fromRGB(185, 52, 52)
		aimPartBtn.Text = (aimPartName == "Head") and "Aim Part: Head" or "Aim Part: Body"
		SyncAimbotFovCircleVisibility() end table.insert(ThemeObjects.CustomCallbacks, RefreshAimbotVisuals)
	updateExcludeCount = function() local c = 0 for _ in pairs(excludedPlayers) do c = c + 1 end
		excludeBtn.Text = "Exclude Players: " .. tostring(c) end rebuildExcludeList = function()
		for _, ch in ipairs(excludeList:GetChildren()) do if ch:IsA("TextButton") then ch:Destroy() end end
		local theme, totalH = GetTheme(), 0 for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= LocalPlayer then
				local itemBtn = MakeButton(excludeList, UDim2.new(1, -6, 0, 26), nil, tostring(plr.DisplayName) .. " (" .. tostring(plr.Name) .. ")", nil, 12)
				itemBtn.BackgroundColor3 = excludedPlayers[plr] and theme.Accent or theme.CardBg
				itemBtn.MouseButton1Click:Connect(function() if excludedPlayers[plr] then excludedPlayers[plr] = nil
						itemBtn.BackgroundColor3 = GetTheme().CardBg else excludedPlayers[plr] = true
						itemBtn.BackgroundColor3 = GetTheme().Accent if currentTarget == plr then currentTarget = nil end
						removePlayerAdornments(plr)
						if plr.Character and plr.Character:FindFirstChild("TR_ESP_Highlight") then plr.Character.TR_ESP_Highlight:Destroy() end
					end updateExcludeCount() RefreshESPHighlights() end) totalH = totalH + 31 end end
		excludeList.CanvasSize = UDim2.new(0, 0, 0, totalH) updateExcludeCount() end
	table.insert(ThemeObjects.CustomCallbacks, function() if excludeFrame.Visible then rebuildExcludeList() end end)
	toggleAimbot = function() aimbotEnabled = not aimbotEnabled Config.AimbotEnabled = aimbotEnabled
		if not aimbotEnabled then currentTarget = nil aimbotStatusLabel.Text = "Status: Idle" end
		RefreshAimbotVisuals() SaveConfig(false) end aimbotToggleBtn.MouseButton1Click:Connect(toggleAimbot)
	aimPartBtn.MouseButton1Click:Connect(function()
		aimPartName = (aimPartName == "Head") and "HumanoidRootPart" or "Head" Config.AimPartName = aimPartName
		RefreshAimbotVisuals() SaveConfig(false) end) aimbotKeyAssignBtn.MouseButton1Click:Connect(function()
		aimbotKeyAssignBtn.Text = "[Key / Del]" ActiveKeybindCaptureCallback = function(k)
			Config.AimbotKeybind = k RefreshAimbotVisuals() SaveConfig(false) end end)
	aimbotKeyDeleteBtn.MouseButton1Click:Connect(function() Config.AimbotKeybind = "None"
		ActiveKeybindCaptureCallback = nil RefreshAimbotVisuals() SaveConfig(false) end)
	fovBox.FocusLost:Connect(function() local v = tonumber(fovBox.Text) if v then
			FOV_RADIUS = math.clamp(math.floor(v + 0.5), 20, 800) Config.AimbotFOVRadius = FOV_RADIUS
			if FovSliderObj then FovSliderObj.SetValue(FOV_RADIUS) end SyncAimbotFovCircleVisibility()
			SaveConfig(false) end fovBox.Text = tostring(FOV_RADIUS) end)
	excludeBtn.MouseButton1Click:Connect(function() excludeFrame.Visible = not excludeFrame.Visible
		AimbotExtraCard.Size = excludeFrame.Visible and UDim2.new(1, 0, 0, 186) or UDim2.new(1, 0, 0, 48)
		if excludeFrame.Visible then rebuildExcludeList() end end) RefreshAimbotVisuals()
	-- Section 2: Player ESP Highlights & 3D Bounding Boxes
	CreateSectionHeader(Tab7_Visuals, "Player ESP (Chams & 3D Hitbox Boxes)", 9)
	CreateToggle(Tab7_Visuals, "Player Highlight & 3D Box ESP (Chams + Hitbox Boxes)", Config.ESPEnabled, 10, function(state)
		Config.ESPEnabled = state if not state then clearAllAdornments() else updateAllAdornments() end
		RefreshESPHighlights() SaveConfig(false) end)
	CreateToggle(Tab7_Visuals, "Turn On ESP for Teammates (Show Teammate Highlights & Boxes)", espShowTeammates, 11, function(state)
		espShowTeammates = state Config.ESPShowTeammates = state RefreshESPHighlights() updateAllAdornments()
		SaveConfig(false) end)
	-- Section 3: Camera Field of View & Perspective
	CreateSectionHeader(Tab7_Visuals, "Camera Field of View & Perspective", 12)
	CreateSlider(Tab7_Visuals, "Camera Field of View (FOV)", 30, 120, Config.FOV, 13, function(val)
		Config.FOV = val pcall(function() workspace.CurrentCamera.FieldOfView = val end) SaveConfig(false) end)
	local CamModeCard = CreateCard(Tab7_Visuals, 50, 14) local CamModeList = Instance.new("UIListLayout")
	CamModeList.FillDirection = Enum.FillDirection.Horizontal
	CamModeList.HorizontalAlignment = Enum.HorizontalAlignment.Center
	CamModeList.VerticalAlignment = Enum.VerticalAlignment.Center CamModeList.Padding = UDim.new(0, 8)
	CamModeList.Parent = CamModeCard ApplyCameraMode = function(mode) Config.CameraOverrideMode = mode
		pcall(function() if mode == "Force 1st Person" then player.CameraMode = Enum.CameraMode.LockFirstPerson
			elseif mode == "Force 3rd Person" then player.CameraMode = Enum.CameraMode.Classic
				player.CameraMinZoomDistance = 8 player.CameraMaxZoomDistance = 128 else
				player.CameraMode = Enum.CameraMode.Classic player.CameraMinZoomDistance = 0.5
				player.CameraMaxZoomDistance = 400 end end) SaveConfig(false) end
	for _, modeName in ipairs({ "Free / Unlocked", "Force 1st Person", "Force 3rd Person" }) do
		local MBtn = MakeButton(CamModeCard, UDim2.new(0, 165, 0, 32), nil, modeName, "AccentDark", 11)
		MBtn.MouseButton1Click:Connect(function() ApplyCameraMode(modeName) end) end
	-- Section 4: World Lighting, Fullbright & Time Presets
	CreateSectionHeader(Tab7_Visuals, "Lighting, Fullbright & Time Presets", 15)
	CreateToggle(Tab7_Visuals, "Fullbright Lighting Mode (No Shadows + Max Illumination)", Config.FullbrightEnabled, 16, function(state)
		Config.FullbrightEnabled = state if not state then pcall(function()
				Lighting.Brightness = DefaultLighting.Brightness
				Lighting.GlobalShadows = DefaultLighting.GlobalShadows
				Lighting.OutdoorAmbient = DefaultLighting.OutdoorAmbient end) end SaveConfig(false) end)
	local TimeCard = CreateCard(Tab7_Visuals, 50, 17) local TimeList = Instance.new("UIListLayout")
	TimeList.FillDirection = Enum.FillDirection.Horizontal
	TimeList.HorizontalAlignment = Enum.HorizontalAlignment.Center
	TimeList.VerticalAlignment = Enum.VerticalAlignment.Center TimeList.Padding = UDim.new(0, 10)
	TimeList.Parent = TimeCard for _, preset in ipairs({ { Label = E.Sun .. " Day", Value = 14 },
		{ Label = E.Moon .. " Night", Value = 0 }, { Label = E.Unlock .. " Unlock Time", Value = nil } }) do
		local PBtn = MakeButton(TimeCard, UDim2.new(0, 160, 0, 32), nil, preset.Label, "AccentDark", 12)
		PBtn.MouseButton1Click:Connect(function() Config.LockedTime = preset.Value if preset.Value ~= nil then
				pcall(function() Lighting.ClockTime = preset.Value end) else
				pcall(function() Lighting.ClockTime = DefaultLighting.ClockTime end) end SaveConfig(false) end) end
end
--==============================================================================
-- 14. TAB 8: MULTI-TAB SCRIPT EXECUTOR
--==============================================================================
do CreateSectionHeader(Tab8_Executor, "Multi-Tab Luau Script Executor", 1)
local ExecHeaderCard = CreateCard(Tab8_Executor, 42, 2)
local ScrollLeftBtn = MakeButton(ExecHeaderCard, UDim2.new(0, 28, 0, 28), UDim2.new(0, 8, 0.5, -14), "<", "PanelBg", 13)
local ScrollRightBtn = MakeButton(ExecHeaderCard, UDim2.new(0, 28, 0, 28), UDim2.new(1, -70, 0.5, -14), ">", "PanelBg", 13)
local AddTabBtn = MakeButton(ExecHeaderCard, UDim2.new(0, 28, 0, 28), UDim2.new(1, -36, 0.5, -14), "+", "Accent", 15)
local TabsScroll = Instance.new("ScrollingFrame") TabsScroll.Size = UDim2.new(1, -118, 0, 32)
TabsScroll.Position = UDim2.new(0, 42, 0.5, -16) TabsScroll.BackgroundTransparency = 1
TabsScroll.BorderSizePixel = 0 TabsScroll.ScrollBarThickness = 3 TabsScroll.ScrollingEnabled = true
TabsScroll.CanvasSize = UDim2.new(0, 0, 0, 0) TabsScroll.AutomaticCanvasSize = Enum.AutomaticSize.X
TabsScroll.ScrollingDirection = Enum.ScrollingDirection.X TabsScroll.Parent = ExecHeaderCard
RegisterThemeObject(TabsScroll, "ScrollBarImageColor3", "Accent")
local TabsScrollLayout = Instance.new("UIListLayout")
TabsScrollLayout.FillDirection = Enum.FillDirection.Horizontal
TabsScrollLayout.VerticalAlignment = Enum.VerticalAlignment.Center
TabsScrollLayout.Padding = UDim.new(0, 6) TabsScrollLayout.Parent = TabsScroll
local function ScrollExecutorTabsBy(deltaX) local totalW = (#savedConfig.ExecutorTabs * 134) + 8
	local maxScroll = math.max(0, totalW - TabsScroll.AbsoluteSize.X)
	local targetX = math.clamp(TabsScroll.CanvasPosition.X + deltaX, 0, maxScroll)
	TweenService:Create(TabsScroll, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		CanvasPosition = Vector2.new(targetX, 0) }):Play() end
ScrollLeftBtn.MouseButton1Click:Connect(function() ScrollExecutorTabsBy(-134) end)
ScrollRightBtn.MouseButton1Click:Connect(function() ScrollExecutorTabsBy(134) end)
local function HandleTabWheelScroll(input) if input.UserInputType == Enum.UserInputType.MouseWheel then
		ScrollExecutorTabsBy(-input.Position.Z * 110) end end
ExecHeaderCard.InputChanged:Connect(HandleTabWheelScroll)
TabsScroll.InputChanged:Connect(HandleTabWheelScroll)
local EditorCard = CreateCard(Tab8_Executor, 240, 3) local CodeBox = Instance.new("TextBox")
CodeBox.Size = UDim2.new(1, -16, 1, -16) CodeBox.Position = UDim2.new(0, 8, 0, 8)
CodeBox.MultiLine = true CodeBox.ClearTextOnFocus = false CodeBox.TextWrapped = true
CodeBox.Font = Enum.Font.Code CodeBox.TextSize = 13 CodeBox.TextXAlignment = Enum.TextXAlignment.Left
CodeBox.TextYAlignment = Enum.TextYAlignment.Top
CodeBox.PlaceholderText = "-- Paste or write your Luau script here..." CodeBox.Text = ""
CodeBox.Parent = EditorCard RegisterThemeObject(CodeBox, "BackgroundColor3", "PanelBg")
RegisterThemeObject(CodeBox, "TextColor3", "TextPrimary") AddCorner(CodeBox, 6)
local ExecActionCard = CreateCard(Tab8_Executor, 48, 4)
local ExecActionLayout = Instance.new("UIListLayout")
ExecActionLayout.FillDirection = Enum.FillDirection.Horizontal
ExecActionLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
ExecActionLayout.VerticalAlignment = Enum.VerticalAlignment.Center
ExecActionLayout.Padding = UDim.new(0, 12) ExecActionLayout.Parent = ExecActionCard
local ExecuteBtn = MakeButton(ExecActionCard, UDim2.new(0, 155, 0, 32), nil, E.Play .. " Execute", "Accent", 12)
local ClearBtn = MakeButton(ExecActionCard, UDim2.new(0, 155, 0, 32), nil, E.Broom .. " Clear", "AccentDark", 12)
local TerminateBtn = Instance.new("TextButton") TerminateBtn.Size = UDim2.new(0, 155, 0, 32)
TerminateBtn.BackgroundColor3 = Color3.fromRGB(165, 38, 55) TerminateBtn.Font = Enum.Font.GothamBold
TerminateBtn.TextSize = 12 TerminateBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TerminateBtn.Text = E.Stop .. " Terminate" TerminateBtn.Parent = ExecActionCard
AddCorner(TerminateBtn, 6) local RunningExecutorThreads = {} local UpdatingCodeBox = false
local function RebuildExecutorTabs() if #savedConfig.ExecutorTabs == 0 then
		table.insert(savedConfig.ExecutorTabs, { Name = "Script 1", Code = "" }) end
	savedConfig.ActiveExecutorTab = math.clamp(savedConfig.ActiveExecutorTab or 1, 1, #savedConfig.ExecutorTabs)
	for _, child in ipairs(TabsScroll:GetChildren()) do if child:IsA("Frame") then child:Destroy() end end
	local theme = GetTheme() for idx, tabData in ipairs(savedConfig.ExecutorTabs) do
		local isSelected = (idx == savedConfig.ActiveExecutorTab) local TabChip = Instance.new("Frame")
		TabChip.LayoutOrder = idx TabChip.Size = UDim2.new(0, 128, 0, 26)
		TabChip.BackgroundColor3 = isSelected and theme.Accent or theme.PanelBg TabChip.BorderSizePixel = 0
		TabChip.Parent = TabsScroll AddCorner(TabChip, 6) local SelectBtn = Instance.new("TextButton")
		SelectBtn.Size = UDim2.new(0, 22, 1, 0) SelectBtn.BackgroundTransparency = 1
		SelectBtn.Font = Enum.Font.GothamBold SelectBtn.TextSize = 11 SelectBtn.TextColor3 = theme.TextPrimary
		SelectBtn.Text = tostring(idx) SelectBtn.Parent = TabChip
		SelectBtn.MouseButton1Click:Connect(function() savedConfig.ActiveExecutorTab = idx SaveConfig(false)
			RebuildExecutorTabs() end) local NameInput = Instance.new("TextBox")
		NameInput.Size = UDim2.new(1, -48, 1, 0) NameInput.Position = UDim2.new(0, 22, 0, 0)
		NameInput.BackgroundTransparency = 1 NameInput.ClearTextOnFocus = false
		NameInput.Font = Enum.Font.GothamSemibold NameInput.TextSize = 11
		NameInput.TextColor3 = theme.TextPrimary NameInput.Text = tabData.Name or ("Script " .. idx)
		NameInput.Parent = TabChip NameInput.Focused:Connect(function()
			if savedConfig.ActiveExecutorTab ~= idx then savedConfig.ActiveExecutorTab = idx
				UpdatingCodeBox = true CodeBox.Text = tabData.Code or "" UpdatingCodeBox = false
				local curTheme = GetTheme() for _, ch in ipairs(TabsScroll:GetChildren()) do if ch:IsA("Frame") then
						ch.BackgroundColor3 = (ch.LayoutOrder == idx) and curTheme.Accent or curTheme.PanelBg end end end
		end) NameInput.FocusLost:Connect(function() tabData.Name = NameInput.Text SaveConfig(false) end)
		local DelTabBtn = Instance.new("TextButton") DelTabBtn.Size = UDim2.new(0, 22, 1, 0)
		DelTabBtn.Position = UDim2.new(1, -22, 0, 0) DelTabBtn.BackgroundTransparency = 1
		DelTabBtn.Font = Enum.Font.GothamBold DelTabBtn.TextSize = 13 DelTabBtn.TextColor3 = theme.TextPrimary
		DelTabBtn.Text = E.Close DelTabBtn.Parent = TabChip DelTabBtn.MouseButton1Click:Connect(function()
			if #savedConfig.ExecutorTabs > 1 then table.remove(savedConfig.ExecutorTabs, idx)
				savedConfig.ActiveExecutorTab = math.clamp(savedConfig.ActiveExecutorTab, 1, #savedConfig.ExecutorTabs)
				SaveConfig(false) RebuildExecutorTabs() end end) end
	TabsScroll.CanvasSize = UDim2.new(0, (#savedConfig.ExecutorTabs * 134) + 8, 0, 0) UpdatingCodeBox = true
	CodeBox.Text = savedConfig.ExecutorTabs[savedConfig.ActiveExecutorTab].Code or ""
	UpdatingCodeBox = false end table.insert(ThemeObjects.CustomCallbacks, RebuildExecutorTabs)
CodeBox:GetPropertyChangedSignal("Text"):Connect(function() if UpdatingCodeBox then return end
	local activeTab = savedConfig.ExecutorTabs[savedConfig.ActiveExecutorTab] if activeTab then
		activeTab.Code = CodeBox.Text SaveConfig(false) end end) AddTabBtn.MouseButton1Click:Connect(function()
	table.insert(savedConfig.ExecutorTabs, { Name = "Script " .. (#savedConfig.ExecutorTabs + 1), Code = "" })
	savedConfig.ActiveExecutorTab = #savedConfig.ExecutorTabs SaveConfig(false) RebuildExecutorTabs()
	task.defer(function() local totalW = (#savedConfig.ExecutorTabs * 134) + 8
		local maxScroll = math.max(0, totalW - TabsScroll.AbsoluteSize.X)
		TweenService:Create(TabsScroll, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			CanvasPosition = Vector2.new(maxScroll, 0) }):Play() end) end)
ExecuteBtn.MouseButton1Click:Connect(function() local source = CodeBox.Text
	if source and #source > 0 then local fn, err = SafeLoadstring(source) if fn then
			table.insert(RunningExecutorThreads, task.spawn(function() pcall(fn) end)) else
			warn("[T.R Scripts Executor Compile Error]: " .. tostring(err)) end end end)
ClearBtn.MouseButton1Click:Connect(function() CodeBox.Text = "" end)
TerminateBtn.MouseButton1Click:Connect(function()
	for _, thread in ipairs(RunningExecutorThreads) do pcall(function() task.cancel(thread) end) end
	RunningExecutorThreads = {} end) RebuildExecutorTabs() end
--==============================================================================
-- 15. CORE HEARTBEAT, STEPPED, PLAYER LIST & INPUT ENGINES
--==============================================================================
local FREEZE_TAG_NAMES = { Frozen = true, Freeze = true, Stunned = true, CountdownLock = true, SpawnBarrier = true, RootAnchor = true }
local frameCount, lastFpsTime, currentFps, lastRadarRefresh = 0, os.clock(), 60, 0
table.insert(Connections, Players.PlayerAdded:Connect(function(newPlayer)
	if Config.AutoSelectFling == true and newPlayer ~= player and not IsFriend(newPlayer) then
		SelectedTargets[newPlayer.Name] = newPlayer end RefreshFlingPlayerList()
	if excludeFrame and excludeFrame.Visible then rebuildExcludeList() end end))
table.insert(Connections, Players.PlayerRemoving:Connect(function(leftPlayer)
	SelectedTargets[leftPlayer.Name] = nil excludedPlayers[leftPlayer] = nil
	removePlayerAdornments(leftPlayer) if currentTarget == leftPlayer then currentTarget = nil end
	RefreshFlingPlayerList()
	if excludeFrame and excludeFrame.Visible then rebuildExcludeList() else updateExcludeCount() end end))
table.insert(Connections, LocalPlayer.CharacterAdded:Connect(function(c) currentTarget = nil
	if updateWallcheckFilter then pcall(updateWallcheckFilter, c) end
	for k in pairs(characterCache) do characterCache[k] = nil end end))
table.insert(Connections, RunService.RenderStepped:Connect(function(dt)
	if not Config.ESPEnabled and next(adornmentsCache) == nil then return end
	lastEspUpdate = lastEspUpdate + dt if lastEspUpdate >= ESP_UPDATE_INTERVAL then lastEspUpdate = 0
		updateAllAdornments() end end)) local lastShiftLook = nil local function updateShiftLockPre()
	if CursorUnlockedOverride and not isClosingPermanently then
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter if userGameSettings then
			userGameSettings.RotationType = Enum.RotationType.CameraRelative end end end
RunService:BindToRenderStep("TR_ShiftLock_Pre", Enum.RenderPriority.Camera.Value - 1, updateShiftLockPre)
local function stepShiftLockCore(cam) UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
	if userGameSettings then userGameSettings.RotationType = Enum.RotationType.CameraRelative end
	local delta = UserInputService:GetMouseDelta()
	if delta.Magnitude > 0 and lastShiftLook and (cam.CFrame.LookVector - lastShiftLook).Magnitude < 0.0001 then
		local focusPos = cam.Focus.Position local offset = cam.CFrame.Position - focusPos
		local dist = offset.Magnitude local rx, ry, _ = cam.CFrame:ToOrientation()
		local newYaw = ry - math.rad(delta.X * 0.28)
		local newPitch = math.clamp(rx - math.rad(delta.Y * 0.28), -math.rad(80), math.rad(80))
		local rotCF = CFrame.fromOrientation(newPitch, newYaw, 0)
		cam.CFrame = CFrame.new(focusPos) * rotCF * CFrame.new(0, 0, dist) end
	lastShiftLook = cam.CFrame.LookVector local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid") local root = GetRootPart(char)
	if hum and root and hum.Health > 0 and not hum.Sit then
		local camDist = (cam.Focus.Position - cam.CFrame.Position).Magnitude
		hum.CameraOffset = (camDist > 1) and Vector3.new(1.75, 0, 0) or V3_ZERO
		local lv = cam.CFrame.LookVector local flat = Vector3.new(lv.X, 0, lv.Z) if flat.Magnitude > 0.001 then
			hum.AutoRotate = false root.CFrame = CFrame.new(root.Position, root.Position + flat.Unit) end end end
local function setAimbotStatusText(txt) if aimbotStatusLabel and aimbotStatusLabel.Text ~= txt then
		aimbotStatusLabel.Text = txt end end
RunService:BindToRenderStep("Aimbot_v2", Enum.RenderPriority.Camera.Value + 1, function()
	local cam = workspace.CurrentCamera if not cam then return end
	local showFov = aimbotEnabled and fovCircleEnabled and not isClosingPermanently
	if guiFovCircle and guiFovCircle.Visible ~= showFov then guiFovCircle.Visible = showFov end
	if CursorUnlockedOverride and not isClosingPermanently then pcall(stepShiftLockCore, cam) else
		lastShiftLook = nil end if not aimbotEnabled then return end if strongLock and currentTarget then
		local ch = currentTarget.Character local h = ch and ch:FindFirstChildOfClass("Humanoid")
		local p = getTargetPart(ch)
		if not ch or not h or h.Health <= 0 or not p or not isTargetVisible(p, ch) or (aimbotTeamCheck and IsTeammate(currentTarget)) then currentTarget = nil end
	else currentTarget = findBestTarget() end if not currentTarget then currentTarget = findBestTarget() end
	if currentTarget and currentTarget.Character then
		local targetPart = getTargetPart(currentTarget.Character) if targetPart then
			local goalCF = CFrame.new(cam.CFrame.Position, targetPart.Position) local beforeCF = cam.CFrame
			cam.CFrame = strongLock and goalCF or beforeCF:Lerp(goalCF, LERP_ALPHA)
			setAimbotStatusText((cam.CFrame == beforeCF) and "Aimed: Camera writes blocked" or ("Target: " .. tostring(currentTarget.DisplayName)))
		end else setAimbotStatusText("Status: Searching...") end end) local lastAirTimeReset = 0
local function landHum(h) h:ChangeState(Enum.HumanoidStateType.Landed)
	h:ChangeState(Enum.HumanoidStateType.Running) end
table.insert(Connections, RunService.Stepped:Connect(function() local char = player.Character
	if not char then return end if Config.AntiCheatBypass ~= false and isFlightActive() then
		local nowT = os.clock() if nowT - lastAirTimeReset >= 0.85 then lastAirTimeReset = nowT
			local h = char:FindFirstChildOfClass("Humanoid") if h then pcall(landHum, h) end end end
	local myRoot = GetRootPart(char) local myHum = char:FindFirstChildOfClass("Humanoid")
	if Config.AntiFlingEnabled ~= false and not FlingActive and myRoot then local myPos = myRoot.Position
		for _, plr in ipairs(Players:GetPlayers()) do if plr ~= player and plr.Character then
				local theirRoot = plr.Character:FindFirstChild("HumanoidRootPart") or plr.Character.PrimaryPart
				if theirRoot then local tp = theirRoot.Position local dx = tp.X - myPos.X local dy = tp.Y - myPos.Y
					local dz = tp.Z - myPos.Z if (dx * dx + dy * dy + dz * dz) <= 2025 then
						for _, ch in ipairs(plr.Character:GetChildren()) do if ch:IsA("BasePart") then
								ch.CanCollide = false ch.AssemblyAngularVelocity = V3_ZERO ch.AssemblyLinearVelocity = V3_ZERO
							elseif ch:IsA("Accessory") or ch:IsA("Tool") then local h = ch:FindFirstChild("Handle")
								if h and h:IsA("BasePart") then h.CanCollide = false h.AssemblyAngularVelocity = V3_ZERO
									h.AssemblyLinearVelocity = V3_ZERO end end end end end end end if myHum then
			myHum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
			myHum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false) end
		local maxSafeLinear = math.max(135, (Config.MasterUtilityEnabled and (Config.WalkSpeed + Config.JumpPower) or 85) * 1.8)
		if isFlightActive() then maxSafeLinear = math.max(maxSafeLinear, (Config.FlySpeed or 50) * 1.5) end
		if myRoot.AssemblyAngularVelocity.Magnitude > 35 or myRoot.AssemblyLinearVelocity.Magnitude > maxSafeLinear then
			myRoot.AssemblyAngularVelocity = V3_ZERO myRoot.AssemblyLinearVelocity = V3_ZERO
			myRoot.RotVelocity = V3_ZERO myRoot.Velocity = V3_ZERO if lastSafeAntiFlingCF then
				myRoot.CFrame = lastSafeAntiFlingCF end else lastSafeAntiFlingCF = myRoot.CFrame end end
	if Config.NoclipEnabled or Config.CountdownBypass then for _, child in ipairs(char:GetChildren()) do
			if Config.NoclipEnabled and child:IsA("BasePart") and child.CanCollide then child.CanCollide = false
			end if Config.CountdownBypass then if child:IsA("BasePart") and child.Anchored then
					child.Anchored = false elseif FREEZE_TAG_NAMES[child.Name] then pcall(child.Destroy, child) end end
		end end end))
-- Consolidated Master Heartbeat Loop (Flight + Anti-Fling Recovery + Systems Monitor)
table.insert(Connections, RunService.Heartbeat:Connect(function(deltaTime)
	camera = workspace.CurrentCamera local char = player.Character
	local root = char and (char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart)
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	-- 1. Flight Subsystem
	if isFlightActive() and char and root and hum and camera then
		hum:ChangeState(Enum.HumanoidStateType.Running) if UserInputService:GetFocusedTextBox() then
			if freezePosition then
				root.CFrame = CFrame.new(freezePosition) * CFrame.Angles(camera.CFrame:ToEulerAnglesXYZ())
				root.AssemblyLinearVelocity = V3_ZERO root.AssemblyAngularVelocity = V3_ZERO end else
			local camCF = camera.CFrame local mvX, mvY, mvZ = 0, 0, 0
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then local lv = camCF.LookVector
				mvX, mvY, mvZ = mvX + lv.X, mvY + lv.Y, mvZ + lv.Z end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then local lv = camCF.LookVector
				mvX, mvY, mvZ = mvX - lv.X, mvY - lv.Y, mvZ - lv.Z end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then local rv = camCF.RightVector
				mvX, mvY, mvZ = mvX - rv.X, mvY - rv.Y, mvZ - rv.Z end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then local rv = camCF.RightVector
				mvX, mvY, mvZ = mvX + rv.X, mvY + rv.Y, mvZ + rv.Z end
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then mvY = mvY + 1 end
			if savedConfig.Settings.ShiftDownEnabled ~= false then
				if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift) then
					mvY = mvY - 1 end end local currentFlySpeed = savedConfig.Settings.FlySpeed or 50
			local magSq = mvX * mvX + mvY * mvY + mvZ * mvZ if magSq > 0.0001 then
				local invMag = 1 / math.sqrt(magSq) local uX, uY, uZ = mvX * invMag, mvY * invMag, mvZ * invMag
				local stepX = uX * (currentFlySpeed * deltaTime) local stepY = uY * (currentFlySpeed * deltaTime)
				local stepZ = uZ * (currentFlySpeed * deltaTime) local curPos = root.Position
				local newPos = Vector3.new(curPos.X + stepX, curPos.Y + stepY, curPos.Z + stepZ)
				freezePosition = newPos root.CFrame = CFrame.new(newPos) * CFrame.Angles(camCF:ToEulerAnglesXYZ())
				local linSpeed = math.min(currentFlySpeed, 45)
				root.AssemblyLinearVelocity = Vector3.new(uX * linSpeed, uY * linSpeed, uZ * linSpeed)
				root.AssemblyAngularVelocity = V3_ZERO else if not freezePosition then freezePosition = root.Position
				end root.CFrame = CFrame.new(freezePosition) * CFrame.Angles(camCF:ToEulerAnglesXYZ())
				root.AssemblyLinearVelocity = V3_ZERO root.AssemblyAngularVelocity = V3_ZERO end
			if fakeGroundPart then
				local footOffset = math.max((hum.HipHeight or 0) + (root.Size.Y * 0.5) + 0.1, 3.05)
				fakeGroundPart.CFrame = root.CFrame * CFrame.new(0, -footOffset, 0) end end end
	-- 2. Performance HUD (FPS / Ping / Mouse Lock status)
	frameCount = frameCount + 1 local now = os.clock() if now - lastFpsTime >= 0.5 then
		currentFps = math.floor(frameCount / (now - lastFpsTime) + 0.5) frameCount = 0 lastFpsTime = now
		local pingMs = 0 local okPing, pingVal = pcall(player.GetNetworkPing, player)
		if okPing and type(pingVal) == "number" then pingMs = math.floor(pingVal * 1000 + 0.5) end
		local mlKey = Config.MouseLockKeybind or "None"
		PerfLabel.Text = string.format("FPS: %d  |  Ping: %d ms  |  Mouse Lock [%s]: %s", currentFps, pingMs, mlKey, CursorUnlockedOverride and "ON" or "OFF")
	end
	-- 3. Radar & ESP Periodic Refresh (every 2.0s)
	if now - lastRadarRefresh >= 2.0 then lastRadarRefresh = now
		if ActiveTabName == "Player Radar" and not ActiveKeybindCaptureCallback then RefreshRadarCards() end
		if Config.ESPEnabled then RefreshESPHighlights() end end
	-- 4. Environment Lighting (Lock Time & Fullbright)
	if Config.LockedTime ~= nil and Lighting.ClockTime ~= Config.LockedTime then
		Lighting.ClockTime = Config.LockedTime end if Config.FullbrightEnabled then
		if Lighting.GlobalShadows ~= false then Lighting.GlobalShadows = false end
		if Lighting.Brightness ~= 2 then Lighting.Brightness = 2 end
		if Lighting.OutdoorAmbient ~= FULLBRIGHT_AMBIENT then Lighting.OutdoorAmbient = FULLBRIGHT_AMBIENT end
	end
	-- 5. Camera FOV
	if camera and camera.FieldOfView ~= Config.FOV then camera.FieldOfView = Config.FOV end
	if not root or not hum then return end
	-- 6. Super Anti-Fling Safety Net
	if Config.AntiFlingEnabled ~= false and not FlingActive then
		local maxSafeLinear = math.max(135, (Config.MasterUtilityEnabled and (Config.WalkSpeed + Config.JumpPower) or 85) * 1.8)
		if isFlightActive() then maxSafeLinear = math.max(maxSafeLinear, (Config.FlySpeed or 50) * 1.5) end
		if root.AssemblyAngularVelocity.Magnitude > 35 or root.AssemblyLinearVelocity.Magnitude > maxSafeLinear then
			root.AssemblyLinearVelocity = V3_ZERO root.AssemblyAngularVelocity = V3_ZERO root.Velocity = V3_ZERO
			root.RotVelocity = V3_ZERO if lastSafeAntiFlingCF then root.CFrame = lastSafeAntiFlingCF end else
			lastSafeAntiFlingCF = root.CFrame end end
	-- 7. Undetected Teleport Bypass
	if Config.AntiCheatBypass ~= false and teleportBypassTargetCF and os.clock() < teleportBypassLockUntil and not FlingActive then
		root.AssemblyLinearVelocity = V3_ZERO root.AssemblyAngularVelocity = V3_ZERO
		local tpDiff = root.Position - teleportBypassTargetCF.Position
		if (tpDiff.X * tpDiff.X + tpDiff.Y * tpDiff.Y + tpDiff.Z * tpDiff.Z) > 64 then
			root.CFrame = teleportBypassTargetCF lastSafeAntiFlingCF = teleportBypassTargetCF end end
	-- 8. Master Utility WalkSpeed & JumpPower
	if Config.MasterUtilityEnabled and not FlingActive then
		if Config.AntiCheatBypass ~= false and not hookmetamethod then hum.WalkSpeed = 16 hum.JumpPower = 50
			local extraSpeed = math.max(0, (Config.WalkSpeed or 16) - 16)
			if extraSpeed > 0 and hum.MoveDirection.Magnitude > 0 then
				local nextPos = root.Position + (hum.MoveDirection.Unit * (extraSpeed * 0.016))
				root.CFrame = CFrame.new(nextPos) * (root.CFrame - root.CFrame.Position)
				lastSafeAntiFlingCF = root.CFrame end
			if (Config.JumpPower or 50) > 50 and UserInputService:IsKeyDown(Enum.KeyCode.Space) and hum.FloorMaterial ~= Enum.Material.Air then
				local v = root.AssemblyLinearVelocity
				root.AssemblyLinearVelocity = Vector3.new(v.X, Config.JumpPower, v.Z) end else
			hum.WalkSpeed = Config.WalkSpeed hum.UseJumpPower = true hum.JumpPower = Config.JumpPower end end
end))
-- Global InputBegan Shortcut Engine
table.insert(Connections, UserInputService.InputBegan:Connect(function(input, gp)
	if UserInputService:GetFocusedTextBox() ~= nil then return end
	if input.UserInputType == Enum.UserInputType.Keyboard then local keyName = input.KeyCode.Name
		if ActiveKeybindCaptureCallback then local cb = ActiveKeybindCaptureCallback
			ActiveKeybindCaptureCallback = nil
			if input.KeyCode == Enum.KeyCode.Delete or keyName == "Delete" or input.KeyCode == Enum.KeyCode.Backspace or input.KeyCode == Enum.KeyCode.Escape then
				cb("None") else cb(keyName) end return end if input.KeyCode == Enum.KeyCode.X then
			SetMenuVisible(not isMenuVisible) return end local mlKey = Config.MouseLockKeybind or "M"
		if mlKey ~= "None" and keyName == mlKey then SetMouseLockState(not CursorUnlockedOverride) return end
		if gp then return end local aimKey = Config.AimbotKeybind or "Q"
		if aimKey ~= "None" and keyName == aimKey then toggleAimbot() return end
		if input.KeyCode == Enum.KeyCode.E and ActiveTabName == "Items & Prompts" then
			if ScannedItemsCache[1] then CollectTargetItem(ScannedItemsCache[1]) end return end
		local flyKey = savedConfig.Settings.FlyKeybind or "E"
		if flyKey ~= "None" and keyName == flyKey and masterFlightEnabled then toggleFlightState() return end
		for _, wp in ipairs(savedConfig.Waypoints) do
			if wp.Keybind and wp.Keybind ~= "None" and wp.Keybind == keyName then
				SafeTeleportToCoords(wp.X, wp.Y, wp.Z) end end
		for plrName, boundKey in pairs(savedConfig.RadarKeybinds) do
			if boundKey and boundKey ~= "None" and boundKey == keyName then
				local targetPlr = Players:FindFirstChild(plrName) if targetPlr and targetPlr.Character then
					local tRoot = GetRootPart(targetPlr.Character) if tRoot then local pos = tRoot.Position
						SafeTeleportToCoords(pos.X, pos.Y + 3, pos.Z) end end end end end end))
-- Close, Re-Execution Cleanup & Full Shutdown Handler
local function ShutdownInstance(immediate) if isClosingPermanently then return end
	FlingActive, aimbotEnabled, currentTarget, masterFlightEnabled = false, false, nil, false
	genv.TR_AntiCheatActive = false pcall(StopFling) pcall(stopFlight)
	for _, thread in ipairs(RunningExecutorThreads) do pcall(function() task.cancel(thread) end) end
	RunningExecutorThreads = {} pcall(function() SetMouseLockState(false) end)
	SpectatingTarget, ActiveKeybindCaptureCallback = nil, nil
	pcall(function() RunService:UnbindFromRenderStep("Aimbot_v2") end)
	pcall(function() RunService:UnbindFromRenderStep("TR_ShiftLock_Pre") end)
	if guiFovCircle then pcall(function() guiFovCircle.Visible = false guiFovCircle:Destroy() end) guiFovCircle = nil end
	pcall(clearAllAdornments)
	for _, conn in ipairs(Connections) do pcall(function() conn:Disconnect() end) end Connections = {}
	pcall(function() local char = player.Character if char then
			local hum = char:FindFirstChildOfClass("Humanoid") local root = GetRootPart(char) if hum then
				hum.PlatformStand = false hum.AutoRotate = true hum.CameraOffset = Vector3.new(0, 0, 0)
				hum.WalkSpeed = 16 hum.JumpPower = 50 hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
				hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
				hum:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
				hum:ChangeState(Enum.HumanoidStateType.GettingUp)
				if workspace.CurrentCamera then workspace.CurrentCamera.CameraSubject = hum end end if root then
				root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
				root.AssemblyAngularVelocity = Vector3.new(0, 0, 0) end
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") then part.CanCollide = true end end end end) pcall(function()
		if workspace.CurrentCamera then workspace.CurrentCamera.FieldOfView = DefaultCamera.FOV end
		player.CameraMode = DefaultCamera.CameraMode player.CameraMinZoomDistance = DefaultCamera.MinZoom
		player.CameraMaxZoomDistance = DefaultCamera.MaxZoom workspace.FallenPartsDestroyHeight = genv.FPDH
		Lighting.ClockTime = DefaultLighting.ClockTime Lighting.Brightness = DefaultLighting.Brightness
		Lighting.GlobalShadows = DefaultLighting.GlobalShadows
		Lighting.OutdoorAmbient = DefaultLighting.OutdoorAmbient end) if immediate then
		isClosingPermanently = true pcall(function() if ScreenGui then ScreenGui:Destroy() end end)
		DeepCleanup() else SetMenuVisible(false, function()
			pcall(function() if ScreenGui then ScreenGui:Destroy() end end) DeepCleanup() end)
		isClosingPermanently = true task.delay(0.24, function()
			pcall(function() if ScreenGui then ScreenGui:Destroy() end end) DeepCleanup() end) end end
genv.TRScripts_ActiveShutdown = ShutdownInstance CloseBtn.MouseButton1Click:Connect(function()
	if genv.TRScripts_ActiveShutdown == ShutdownInstance then genv.TRScripts_ActiveShutdown = nil end
	ShutdownInstance(false) end)
-- Initial Startup Sync
ApplyTheme(Config.Theme) ApplyCameraMode(Config.CameraOverrideMode) RefreshRadarCards()
RefreshFlingPlayerList() RefreshESPHighlights() updateAllAdornments()
--==============================================================================
-- 17. MODULAR ADD-ON LOADER (UNLIMITED EXPANSION SUPPORT)
--==============================================================================
genv.TRHub = { ScreenGui = ScreenGui, MainFrame = MainFrame, Tabs = Tabs, Config = Config,
	SavedConfig = savedConfig, SaveConfig = SaveConfig, Connections = Connections,
	CreateTab = CreateTab, CreateSectionHeader = CreateSectionHeader, CreateCard = CreateCard,
	CreateToggle = CreateToggle, CreateSlider = CreateSlider, MakeButton = MakeButton,
	MakeLabel = MakeLabel, AddCorner = AddCorner, RegisterThemeObject = RegisterThemeObject,
	GetTheme = GetTheme, ApplyTheme = ApplyTheme, SafeTeleportToCoords = SafeTeleportToCoords,
	GetRootPart = GetRootPart }
for _, addonFile in ipairs({ "TRScripts_Part2.lua", "TRScripts_Part3.lua", "TRScripts_Addons.lua" }) do
	pcall(function() if SafeIsFile(addonFile) then local src = SafeReadFile(addonFile)
			if src and #src > 0 then local fn = SafeLoadstring(src) if fn then task.spawn(fn) end end end end) end
