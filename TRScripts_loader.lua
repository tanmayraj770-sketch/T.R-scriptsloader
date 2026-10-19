--==============================================================================
-- T.R SCRIPTS - MASTER SCRIPT HUB (V95)
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
--==============================================================================
-- GUI IDENTIFIER (BAC / Anti-Ban & Silent Aim Hooks Removed for Full Stability)
--==============================================================================
local STEALTH_GUI_NAME = "TRScriptsHub_V95" 
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
local PlayerGui = player:FindFirstChildOfClass("PlayerGui") or player:WaitForChild("PlayerGui", 5) local Connections = {}
if genv.TRScripts_ScreenGui then pcall(function() genv.TRScripts_ScreenGui:Destroy() end)
	genv.TRScripts_ScreenGui = nil end if type(genv.TRScripts_ActiveShutdown) == "function" then
	pcall(genv.TRScripts_ActiveShutdown, true) genv.TRScripts_ActiveShutdown = nil end
local function DeepCleanup() pcall(function() RunService:UnbindFromRenderStep("Aimbot_v2") end)
	pcall(function() RunService:UnbindFromRenderStep("TR_ShiftLock_Pre") end)
	pcall(function() RunService:UnbindFromRenderStep("TR_Freecam_Step") end)
	pcall(function() RunService:UnbindFromRenderStep("TR_Spectate_Step") end)
	pcall(function() if cleardrawcache then cleardrawcache() end end)
	local oldGui = genv._TR_GUI_INSTANCE or genv.TRScripts_ScreenGui if oldGui then
		pcall(function() oldGui:Destroy() end) genv._TR_GUI_INSTANCE = nil genv.TRScripts_ScreenGui = nil end
	local targets = { TRScriptsHub = true, UtilityHubGui = true, TRScriptsFlingGui = true, AimbotUI_v2 = true, TR_CoreTest = true }
	local function purge(container) if not container then return end pcall(function()
			for _, ch in ipairs(container:GetChildren()) do
				if targets[ch.Name] or ch.Name:find("RobloxGui_") or ch.Name:find("AssetAdornment") or ch.Name:find("AssetOutline") then
					pcall(function() ch:Destroy() end) end end end) end
	if gethui then pcall(function() purge(gethui()) end) end pcall(function() purge(CoreGui) end)
	pcall(function() purge(player:FindFirstChildOfClass("PlayerGui")) end) pcall(function()
		for _, obj in ipairs(workspace:GetChildren()) do
			if obj.Name == "TR_FakeFloor" or obj.Name == "TR_Floor" then obj:Destroy() end end end)
	pcall(function() for _, plr in ipairs(Players:GetPlayers()) do
			local esp = plr.Character and (plr.Character:FindFirstChild("TR_ESP_Highlight") or plr.Character:FindFirstChild("AssetHighlight"))
			if esp then esp:Destroy() end end end) end DeepCleanup() local function GetSafeGuiParent(targetGui)
	if gethui then local ok, hui = pcall(gethui) if ok and hui then return hui end end
	local protector = (syn and syn.protect_gui) or protect_gui or protectgui or (fluxus and fluxus.protect_gui)
	if protector and targetGui then pcall(protector, targetGui) end
	local okCore, cg = pcall(function() return CoreGui end) if okCore and cg then
		local canCore = pcall(function() if targetGui then targetGui.Parent = cg end end)
		if canCore and targetGui and targetGui.Parent == cg then return cg end end
	return player:WaitForChild("PlayerGui") end
local SafeClipboard = setclipboard or toclipboard or set_clipboard or (Clipboard and Clipboard.set) or function() end
local SafeWriteFile = writefile or function() end
local SafeReadFile = readfile or function() return nil end
local SafeIsFile = isfile or function() return false end
local SafeLoadstring = loadstring or function() return nil, "loadstring unavailable" end
local SafeFireTouch = firetouchinterest or function() end
local SafeFirePrompt = fireproximityprompt or function(prompt) pcall(function() prompt:InputHoldBegin()
		task.wait() prompt:InputHoldEnd() end) end
--==============================================================================
-- 2. PERSISTENT JSON CONFIGURATION & STATE MANAGEMENT SYSTEM (V95)
--==============================================================================
local CONFIG_FILENAME = "TRScripts_Config_V100.json" local FALLBACK_FILES = {
	"TRScripts_Config_V99.json", "TRScripts_Config_V98.json", "TRScripts_Config_V97.json",
	"TRScripts_Config_V96.json", "TRScripts_Config_V95.json", "TRScripts_Config_V94.json",
	"TRScripts_Config_V93.json", "TRScripts_Config_V92.json" } local DefaultConfig = { Settings = {
		Theme = "Default", Animation = "Default", WindowWidth = 760, WindowHeight = 480, WalkSpeed = 18, JumpPower = 50, FOV = 70,
		FlySpeed = 100, FlyKeybind = "E", FreecamSpeed = 60, FreecamKeybind = "C", MouseLockKeybind = "M", AimbotKeybind = "Q", TargetAimbotKeybind = "T", AutoShootKeybind = "Z", AutoShootDelayMs = 45, ESPHealthBars = true, AimbotFOVRadius = 200,
		AimbotFOVCircleEnabled = true, AimbotEnabled = false, TargetAimbotEnabled = false, StrongLock = true, StickMode = "Back", WallcheckEnabled = true,
		AimbotTeamCheck = true, AutoShootEnabled = false, InfiniteJump = false, SpiderClimb = false,
		ItemMagnetEnabled = false, ItemMagnetRadius = 60, ESPShowTeammates = false, AimPartName = "Head",
		MasterUtilityEnabled = false, MasterFlightEnabled = false, NoclipEnabled = false,
		AntiFlingEnabled = true, AutoSelectFling = false, AntiCheatBypass = true, ShiftDownEnabled = true,
		CountdownBypass = false, AntiAFK = true, InstantPrompt = false, ESPEnabled = false,
		FullbrightEnabled = false, CameraOverrideMode = "Free / Unlocked", LockedTime = nil }, Waypoints = {
		{ Name = "Spawn Point", X = 0, Y = 50, Z = 0, Keybind = "None" } }, RadarKeybinds = {},
	ExecutorTabs = {
		{ Name = "Script 1", Code = "-- Welcome to T.R Scripts V95\nprint('T.R Scripts V95 Ready!')" } },
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
				end end end end)
	if not savedConfig.Settings.FreecamKeybind then savedConfig.Settings.FreecamKeybind = "C" end
	if not savedConfig.Settings.FreecamSpeed then savedConfig.Settings.FreecamSpeed = 60 end
	if savedConfig.Settings.Animation ~= "Default" and savedConfig.Settings.Animation ~= "Windows" and savedConfig.Settings.Animation ~= "macOS" then
		savedConfig.Settings.Animation = "Default"
	end
end LoadConfig() local DefaultLighting = { ClockTime = Lighting.ClockTime,
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
local ScreenGui = Instance.new("ScreenGui") ScreenGui.Name = STEALTH_GUI_NAME
ScreenGui.ResetOnSpawn = false ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true ScreenGui.DisplayOrder = 9999
ScreenGui.Parent = GetSafeGuiParent(ScreenGui) genv._TR_GUI_INSTANCE = ScreenGui
genv.TRScripts_ScreenGui = ScreenGui local MIN_WIDTH, MIN_HEIGHT = 560, 360
local MAX_WIDTH, MAX_HEIGHT = 1150, 820
local CurrentWidth = math.clamp(tonumber(Config.WindowWidth) or 760, MIN_WIDTH, MAX_WIDTH)
local CurrentHeight = math.clamp(tonumber(Config.WindowHeight) or 480, MIN_HEIGHT, MAX_HEIGHT)
local MainFrame = Instance.new("Frame") MainFrame.Name = "MainFrame"
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Size = UDim2.new(0, CurrentWidth, 0, CurrentHeight)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0) MainFrame.BackgroundTransparency = 0.06
MainFrame.BorderSizePixel = 0 MainFrame.Active = true MainFrame.ClipsDescendants = true MainFrame.Parent = ScreenGui
RegisterThemeObject(MainFrame, "BackgroundColor3", "MainBg") AddCorner(MainFrame, 12)
local MainScale = Instance.new("UIScale") MainScale.Scale = 1 MainScale.Parent = MainFrame
local MainStroke = Instance.new("UIStroke") MainStroke.Thickness = 1.6 MainStroke.Transparency = 0.25
MainStroke.Parent = MainFrame RegisterThemeObject(MainStroke, "Color", "Stroke")
local TopBar = Instance.new("Frame") TopBar.Name = "TopBar" TopBar.Size = UDim2.new(1, 0, 0, 44)
TopBar.BackgroundTransparency = 0.1 TopBar.BorderSizePixel = 0 TopBar.Parent = MainFrame
RegisterThemeObject(TopBar, "BackgroundColor3", "PanelBg") AddCorner(TopBar, 12)
local TitleLabel = MakeLabel(TopBar, UDim2.new(1, -260, 1, 0), UDim2.new(0, 16, 0, 0), E.Bolt .. " T.R Scripts - Master Script Hub (V95)", Enum.Font.GothamBold, 15, "TextPrimary", Enum.TextXAlignment.Left)
TitleLabel.TextTruncate = Enum.TextTruncate.AtEnd
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
	end)) end local Sidebar = Instance.new("ScrollingFrame") Sidebar.Size = UDim2.new(0, 185, 1, -62)
Sidebar.Position = UDim2.new(0, 10, 0, 50) Sidebar.BackgroundTransparency = 0.12
Sidebar.BorderSizePixel = 0 Sidebar.ScrollBarThickness = 3 Sidebar.CanvasSize = UDim2.new(0, 0, 0, 360)
Sidebar.ScrollingDirection = Enum.ScrollingDirection.Y Sidebar.ZIndex = 5 Sidebar.Parent = MainFrame
RegisterThemeObject(Sidebar, "BackgroundColor3", "PanelBg")
RegisterThemeObject(Sidebar, "ScrollBarImageColor3", "Accent") AddCorner(Sidebar, 10)
local SidebarLayout = Instance.new("UIListLayout") SidebarLayout.Padding = UDim.new(0, 4)
SidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder SidebarLayout.Parent = Sidebar
local SidebarPad = Instance.new("UIPadding") SidebarPad.PaddingTop = UDim.new(0, 6)
SidebarPad.PaddingBottom = UDim.new(0, 6) SidebarPad.Parent = Sidebar
SidebarLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	Sidebar.CanvasSize = UDim2.new(0, 0, 0, SidebarLayout.AbsoluteContentSize.Y + 16)
end)
local ContentContainer = Instance.new("Frame") ContentContainer.Size = UDim2.new(1, -210, 1, -56)
ContentContainer.Position = UDim2.new(0, 200, 0, 50) ContentContainer.BackgroundTransparency = 0.12
ContentContainer.BorderSizePixel = 0 ContentContainer.Parent = MainFrame
RegisterThemeObject(ContentContainer, "BackgroundColor3", "PanelBg") AddCorner(ContentContainer, 10)
local function SetMenuVisible(state, onComplete) if isClosingPermanently then return end
	for _, tw in ipairs(activeWindowTweens) do pcall(function() tw:Cancel() end) end activeWindowTweens = {}
	local wasVisible = MainFrame.Visible
	isMenuVisible = state if SyncAimbotFovCircleVisibility then SyncAimbotFovCircleVisibility() end
	local animStyle = Config.Animation or "Default"
	MainFrame.Size = UDim2.new(0, CurrentWidth, 0, CurrentHeight)
	MainFrame.Rotation = 0
	TopBar.Position = UDim2.new(0, 0, 0, 0)
	Sidebar.Position = UDim2.new(0, 10, 0, 50)
	ContentContainer.Position = UDim2.new(0, 200, 0, 50)
	MainStroke.Thickness = 1.6
	if state then MainFrame.Visible = true
		if animStyle == "Windows" then
			-- Improved Windows 11 Fluent Window Open (Zero Clipping, Zero Flash)
			MainScale.Scale = 0.88
			MainFrame.Position = UDim2.new(RestingPosition.X.Scale, RestingPosition.X.Offset, RestingPosition.Y.Scale, RestingPosition.Y.Offset + 36)
			MainFrame.BackgroundTransparency = 0.70
			MainStroke.Transparency = 0.85
			local info = TweenInfo.new(0.24, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
			local t1 = TweenService:Create(MainScale, info, { Scale = 1 })
			local t2 = TweenService:Create(MainFrame, info, { Position = RestingPosition, BackgroundTransparency = 0.06 })
			local t3 = TweenService:Create(MainStroke, info, { Transparency = 0.25 })
			activeWindowTweens = { t1, t2, t3 }
			t1:Play() t2:Play() t3:Play()
			t1.Completed:Connect(function(st)
				if st == Enum.PlaybackState.Completed and onComplete then onComplete() end
			end)
		elseif animStyle == "macOS" then
			-- Improved macOS Window Open (Dock Spring Bounce, Zero Clipping, Zero Flash)
			MainScale.Scale = 0.12
			MainFrame.Position = UDim2.new(RestingPosition.X.Scale, RestingPosition.X.Offset, RestingPosition.Y.Scale, RestingPosition.Y.Offset + 130)
			MainFrame.BackgroundTransparency = 0.65
			MainStroke.Transparency = 0.80
			local infoScale = TweenInfo.new(0.36, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
			local infoPos = TweenInfo.new(0.34, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
			local infoStroke = TweenInfo.new(0.28, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
			local t1 = TweenService:Create(MainScale, infoScale, { Scale = 1 })
			local t2 = TweenService:Create(MainFrame, infoPos, { Position = RestingPosition, BackgroundTransparency = 0.06 })
			local t3 = TweenService:Create(MainStroke, infoStroke, { Transparency = 0.25 })
			activeWindowTweens = { t1, t2, t3 }
			t1:Play() t2:Play() t3:Play()
			t1.Completed:Connect(function(st)
				if st == Enum.PlaybackState.Completed and onComplete then onComplete() end
			end)
		else
			-- Default Quint Animation: 100% untouched
			if not wasVisible then
				MainScale.Scale = 0 MainFrame.Position = RestingPosition
				MainFrame.BackgroundTransparency = 1 MainStroke.Transparency = 1
			end
			local info = TweenInfo.new(0.26, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
			local t1 = TweenService:Create(MainScale, info, { Scale = 1 })
			local t2 = TweenService:Create(MainFrame, info, { Position = RestingPosition, BackgroundTransparency = 0.06 })
			local t3 = TweenService:Create(MainStroke, info, { Transparency = 0.25 })
			activeWindowTweens = { t1, t2, t3 } t1:Play() t2:Play() t3:Play() t1.Completed:Connect(function(st)
				if st == Enum.PlaybackState.Completed and onComplete then onComplete() end end)
		end
	else
		draggingGui, resizingMode = false, nil
		if animStyle == "Windows" then
			-- Improved Windows 11 Fluent Window Close (Clean Snap-Down, Zero Clipping, Zero Flash)
			local info = TweenInfo.new(0.18, Enum.EasingStyle.Cubic, Enum.EasingDirection.In)
			local t1 = TweenService:Create(MainScale, info, { Scale = 0.88 })
			local t2 = TweenService:Create(MainFrame, info, { Position = UDim2.new(RestingPosition.X.Scale, RestingPosition.X.Offset, RestingPosition.Y.Scale, RestingPosition.Y.Offset + 36), BackgroundTransparency = 1 })
			local t3 = TweenService:Create(MainStroke, info, { Transparency = 1 })
			activeWindowTweens = { t1, t2, t3 }
			t1:Play() t2:Play() t3:Play()
			t1.Completed:Connect(function(st)
				if st == Enum.PlaybackState.Completed then
					if not isMenuVisible then MainFrame.Visible = false end
					if onComplete then onComplete() end
				end
			end)
		elseif animStyle == "macOS" then
			-- Improved macOS Window Close (Smooth Dock Minimize, Zero Clipping, Zero Flash)
			local infoScale = TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.In)
			local infoPos = TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
			local infoStroke = TweenInfo.new(0.22, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
			local t1 = TweenService:Create(MainScale, infoScale, { Scale = 0.06 })
			local t2 = TweenService:Create(MainFrame, infoPos, { Position = UDim2.new(RestingPosition.X.Scale, RestingPosition.X.Offset, RestingPosition.Y.Scale, RestingPosition.Y.Offset + 130), BackgroundTransparency = 1 })
			local t3 = TweenService:Create(MainStroke, infoStroke, { Transparency = 1 })
			activeWindowTweens = { t1, t2, t3 }
			t1:Play() t2:Play() t3:Play()
			t1.Completed:Connect(function(st)
				if st == Enum.PlaybackState.Completed then
					if not isMenuVisible then MainFrame.Visible = false end
					if onComplete then onComplete() end
				end
			end)
		else
			-- Default Quint Animation Close: 100% untouched
			local info = TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
			local t1 = TweenService:Create(MainScale, info, { Scale = 0 })
			local t2 = TweenService:Create(MainFrame, info, { Position = RestingPosition, BackgroundTransparency = 1 })
			local t3 = TweenService:Create(MainStroke, info, { Transparency = 1 })
			activeWindowTweens = { t1, t2, t3 } t1:Play() t2:Play() t3:Play() t1.Completed:Connect(function(st)
				if st == Enum.PlaybackState.Completed then if not isMenuVisible then MainFrame.Visible = false end
					if onComplete then onComplete() end end end)
		end
	end end MainScale.Scale = 1
MainFrame.BackgroundTransparency = 0.06 MainStroke.Transparency = 0.25 MainFrame.Visible = true
isMenuVisible = true MinBtn.MouseButton1Click:Connect(function() SetMenuVisible(false) end)
--==============================================================================
-- 5. REUSABLE UI COMPONENT FACTORY
--==============================================================================
local Tabs = {} local ActiveTabName = nil local function CreateTab(tabName, iconText, order)
	local TabBtn = Instance.new("TextButton") TabBtn.LayoutOrder = order
	TabBtn.Size = UDim2.new(1, -12, 0, 33) TabBtn.BackgroundTransparency = 0.1
	TabBtn.Font = Enum.Font.GothamSemibold TabBtn.TextSize = 12 TabBtn.ZIndex = 6
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
		for name, data in pairs(Tabs) do data.Page.Visible = (name == tabName) end RefreshTabVisuals()
		if tabName == "Player Radar" and genv._TR_RefreshRadar then pcall(genv._TR_RefreshRadar)
		elseif tabName == "Target Fling" and genv._TR_RefreshFling then pcall(genv._TR_RefreshFling)
		elseif tabName == "Aimbot & Visuals" and genv._TR_RefreshTargetAimbotList then pcall(genv._TR_RefreshTargetAimbotList) end end)
	if order == 1 then ActiveTabName = tabName Page.Visible = true RefreshTabVisuals() end return Page end
local function CreateSectionHeader(parent, title, order) local Header = Instance.new("TextLabel")
	Header.LayoutOrder = order Header.Size = UDim2.new(1, 0, 0, 24) Header.BackgroundTransparency = 1
	Header.Font = Enum.Font.GothamBold Header.TextSize = 14 Header.TextXAlignment = Enum.TextXAlignment.Left
	Header.Text = "  " .. title Header.Parent = parent RegisterThemeObject(Header, "TextColor3", "Accent")
	return Header end local function CreateCard(parent, height, order) local Card = Instance.new("Frame")
	Card.LayoutOrder = order Card.Size = UDim2.new(1, 0, 0, height) Card.BackgroundTransparency = 0.12
	Card.BorderSizePixel = 0 Card.ClipsDescendants = true Card.Parent = parent RegisterThemeObject(Card, "BackgroundColor3", "CardBg")
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
		if callback then pcall(callback, value) end end 	BarBg.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			sliding = true UpdateFromInput(input.Position.X) input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then sliding = false end end) end end)
	if UserInputService.InputEnded then table.insert(Connections, UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			sliding = false end end)) end
	table.insert(Connections, UserInputService.InputChanged:Connect(function(input)
		if not sliding then return end
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			if UserInputService.IsMouseButtonPressed and not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
				sliding = false return end
			UpdateFromInput(input.Position.X)
		elseif input.UserInputType == Enum.UserInputType.Touch then
			UpdateFromInput(input.Position.X) end end)) return { SetValue = function(val)
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
local Tab9_Detector  = CreateTab("Hacker Detector", E.Search, 9)
--==============================================================================
-- 7. TAB 1: THEMES, PERFORMANCE & PROTECTION
--==============================================================================
local PerfLabel, CursorUnlockedOverride, SetMouseLockState, ActiveKeybindCaptureCallback, TryAssignUniqueKeybind
local function SetupTab1()
local RefreshMouseLockUI
local function FindKeybindConflict(keyName, ignoreSlot)
	if not keyName or keyName == "" or keyName == "None" then return nil end
	if keyName == "X" and ignoreSlot ~= "MenuToggle" then
		return "Toggle UI Menu [X]"
	end
	if ignoreSlot ~= "MouseLock" and (Config.MouseLockKeybind or "M") == keyName then
		return "Mouse Lock"
	end
	if ignoreSlot ~= "Flight" and (savedConfig.Settings.FlyKeybind or "E") == keyName then
		return "Flight Toggle"
	end
	if ignoreSlot ~= "Aimbot" and (Config.AimbotKeybind or "Q") == keyName then
		return "Aimbot Lock"
	end
	if ignoreSlot ~= "Freecam" and (Config.FreecamKeybind or "C") == keyName then
		return "Freecam"
	end
	if ignoreSlot ~= "TargetAimbot" and (Config.TargetAimbotKeybind or "T") == keyName then
		return "Target Player Aimbot"
	end
	if ignoreSlot ~= "AutoShoot" and (Config.AutoShootKeybind or "Z") == keyName then
		return "Auto Shoot"
	end
	if type(savedConfig.Waypoints) == "table" then
		for idx, wp in ipairs(savedConfig.Waypoints) do
			if ignoreSlot ~= ("Waypoint:" .. tostring(idx)) and wp.Keybind and wp.Keybind ~= "None" and wp.Keybind == keyName then
				return "Waypoint (" .. tostring(wp.Name or ("#" .. idx)) .. ")"
			end
		end
	end
	if type(savedConfig.RadarKeybinds) == "table" then
		for plrName, boundKey in pairs(savedConfig.RadarKeybinds) do
			if ignoreSlot ~= ("Radar:" .. tostring(plrName)) and boundKey and boundKey ~= "None" and boundKey == keyName then
				return "Radar Teleport (@" .. tostring(plrName) .. ")"
			end
		end
	end
	return nil
end
TryAssignUniqueKeybind = function(keyName, slotId, applyFn, refreshFn, btnObj)
	if not keyName or keyName == "None" then
		if applyFn then applyFn("None") end
		if refreshFn then refreshFn() end
		SaveConfig(false)
		return true
	end
	local conflictOwner = FindKeybindConflict(keyName, slotId)
	if conflictOwner then
		if btnObj then
			btnObj.Text = "[Used: " .. tostring(keyName) .. "]"
			task.delay(1.1, function()
				if refreshFn then pcall(refreshFn) end
			end)
		elseif refreshFn then
			pcall(refreshFn)
		end
		pcall(function()
			StarterGui:SetCore("SendNotification", {
				Title = "Keybind Already Assigned",
				Text = "Key [" .. tostring(keyName) .. "] is already assigned to " .. tostring(conflictOwner) .. "!",
				Duration = 3
			})
		end)
		return false
	end
	if applyFn then applyFn(keyName) end
	if refreshFn then refreshFn() end
	SaveConfig(false)
	return true
end
CreateSectionHeader(Tab1_Dashboard, "UI Theme Customizer (6 Dark Themes)", 1)
local ThemeCard = CreateCard(Tab1_Dashboard, 0, 2)
ThemeCard.AutomaticSize = Enum.AutomaticSize.Y
local ThemePad = Instance.new("UIPadding")
ThemePad.PaddingTop = UDim.new(0, 8) ThemePad.PaddingBottom = UDim.new(0, 8)
ThemePad.PaddingLeft = UDim.new(0, 8) ThemePad.PaddingRight = UDim.new(0, 8)
ThemePad.Parent = ThemeCard
local ThemeGrid = Instance.new("UIGridLayout")
ThemeGrid.CellSize = UDim2.new(0.5, -5, 0, 32)
ThemeGrid.CellPadding = UDim2.new(0, 10, 0, 8)
ThemeGrid.HorizontalAlignment = Enum.HorizontalAlignment.Center
ThemeGrid.VerticalAlignment = Enum.VerticalAlignment.Center
ThemeGrid.SortOrder = Enum.SortOrder.LayoutOrder
ThemeGrid.Parent = ThemeCard
for idx, themeName in ipairs(ThemeOrder) do
	local TBtn = Instance.new("TextButton")
	TBtn.LayoutOrder = idx TBtn.BackgroundColor3 = Themes[themeName].Accent
	TBtn.Font = Enum.Font.GothamBold TBtn.TextSize = 12
	TBtn.TextColor3 = Color3.fromRGB(245, 245, 250) TBtn.Text = themeName
	TBtn.Parent = ThemeCard AddCorner(TBtn, 6)
	TBtn.MouseButton1Click:Connect(function() ApplyTheme(themeName) end)
end
CreateSectionHeader(Tab1_Dashboard, "UI Open & Close Animation (3 Styles)", 3)
local AnimCard = CreateCard(Tab1_Dashboard, 0, 4)
AnimCard.AutomaticSize = Enum.AutomaticSize.Y
local AnimPad = Instance.new("UIPadding")
AnimPad.PaddingTop = UDim.new(0, 8) AnimPad.PaddingBottom = UDim.new(0, 8)
AnimPad.PaddingLeft = UDim.new(0, 8) AnimPad.PaddingRight = UDim.new(0, 8)
AnimPad.Parent = AnimCard
local AnimGrid = Instance.new("UIGridLayout")
AnimGrid.CellSize = UDim2.new(0.333, -4, 0, 32)
AnimGrid.CellPadding = UDim2.new(0, 6, 0, 8)
AnimGrid.HorizontalAlignment = Enum.HorizontalAlignment.Center
AnimGrid.VerticalAlignment = Enum.VerticalAlignment.Center
AnimGrid.SortOrder = Enum.SortOrder.LayoutOrder
AnimGrid.Parent = AnimCard
local AnimButtons = {}
local AnimOptions = {
	{ Id = "Default", Label = "Default" },
	{ Id = "Windows", Label = "Windows" },
	{ Id = "macOS", Label = "Mac" }
}
local function RefreshAnimButtons()
	local theme = GetTheme() local curAnim = Config.Animation or "Default"
	for id, btn in pairs(AnimButtons) do
		local active = (id == curAnim)
		btn.BackgroundColor3 = active and theme.Accent or theme.PanelBg
		btn.TextColor3 = active and Color3.fromRGB(245, 245, 250) or theme.TextPrimary
	end
end
table.insert(ThemeObjects.CustomCallbacks, RefreshAnimButtons)
for idx, animOpt in ipairs(AnimOptions) do
	local ABtn = Instance.new("TextButton")
	ABtn.LayoutOrder = idx ABtn.Font = Enum.Font.GothamBold ABtn.TextSize = 12
	ABtn.Text = animOpt.Label ABtn.Parent = AnimCard AddCorner(ABtn, 6)
	AnimButtons[animOpt.Id] = ABtn
	ABtn.MouseButton1Click:Connect(function()
		Config.Animation = animOpt.Id RefreshAnimButtons() SaveConfig(false)
		SetMenuVisible(false, function()
			task.wait(0.05)
			SetMenuVisible(true)
		end)
	end)
end
RefreshAnimButtons()
CreateSectionHeader(Tab1_Dashboard, "Live Performance & Mouse Lock (Shift Lock) Controls", 5)
local PerfCard = CreateCard(Tab1_Dashboard, 46, 6) PerfLabel = Instance.new("TextLabel")
PerfLabel.Size = UDim2.new(1, -24, 1, 0) PerfLabel.Position = UDim2.new(0, 12, 0, 0)
PerfLabel.BackgroundTransparency = 1 PerfLabel.Font = Enum.Font.GothamSemibold PerfLabel.TextSize = 13
PerfLabel.TextXAlignment = Enum.TextXAlignment.Left
PerfLabel.Text = "FPS: --  |  Ping: -- ms  |  Mouse Lock [M]: OFF" PerfLabel.Parent = PerfCard
RegisterThemeObject(PerfLabel, "TextColor3", "TextPrimary") CursorUnlockedOverride = false
local MouseLockCard = CreateCard(Tab1_Dashboard, 94, 7)
local mouseLockToggleBtn = Instance.new("TextButton", MouseLockCard)
mouseLockToggleBtn.Size = UDim2.new(0.5, -14, 0, 34)
mouseLockToggleBtn.Position = UDim2.new(0, 10, 0, 10) mouseLockToggleBtn.Font = Enum.Font.GothamBold
mouseLockToggleBtn.TextSize = 12 mouseLockToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AddCorner(mouseLockToggleBtn, 6) local mouseLockStatusLbl = Instance.new("TextLabel", MouseLockCard)
mouseLockStatusLbl.Size = UDim2.new(0.5, -14, 0, 34)
mouseLockStatusLbl.Position = UDim2.new(0.5, 4, 0, 10) mouseLockStatusLbl.BackgroundTransparency = 0.15
mouseLockStatusLbl.Font = Enum.Font.GothamSemibold mouseLockStatusLbl.TextSize = 12
mouseLockStatusLbl.Text = "Shift Lock: INACTIVE"
RegisterThemeObject(mouseLockStatusLbl, "BackgroundColor3", "PanelBg")
RegisterThemeObject(mouseLockStatusLbl, "TextColor3", "TextPrimary") AddCorner(mouseLockStatusLbl, 6)
local mlKeyBindLabel = MakeLabel(MouseLockCard, UDim2.new(0.38, -10, 0, 30), UDim2.new(0, 10, 0, 52), "Shortcut Key:", Enum.Font.GothamSemibold, 12, "TextPrimary", Enum.TextXAlignment.Left)
mlKeyBindLabel.TextTruncate = Enum.TextTruncate.AtEnd
local mouseLockKeyAssignBtn = MakeButton(MouseLockCard, UDim2.new(0.36, -6, 0, 30), UDim2.new(0.38, 4, 0, 52), "Bind Key: [M]", "PanelBg", 11)
local mouseLockKeyDeleteBtn = Instance.new("TextButton", MouseLockCard)
mouseLockKeyDeleteBtn.Size = UDim2.new(0.26, -14, 0, 30)
mouseLockKeyDeleteBtn.Position = UDim2.new(0.74, 4, 0, 52)
mouseLockKeyDeleteBtn.BackgroundColor3 = Color3.fromRGB(165, 38, 55)
mouseLockKeyDeleteBtn.Font = Enum.Font.GothamBold mouseLockKeyDeleteBtn.TextSize = 11
mouseLockKeyDeleteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
mouseLockKeyDeleteBtn.Text = E.Trash .. " Delete" AddCorner(mouseLockKeyDeleteBtn, 6)
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
		TryAssignUniqueKeybind(keyName, "MouseLock", function(val) Config.MouseLockKeybind = val end, RefreshMouseLockUI, mouseLockKeyAssignBtn) end end)
mouseLockKeyDeleteBtn.MouseButton1Click:Connect(function() Config.MouseLockKeybind = "None"
	ActiveKeybindCaptureCallback = nil RefreshMouseLockUI() SaveConfig(false) end) RefreshMouseLockUI()
CreateSectionHeader(Tab1_Dashboard, "Protection & Physics Stabilizers", 8)
CreateToggle(Tab1_Dashboard, "Anti-AFK Protection (VirtualUser Idle Bypass)", Config.AntiAFK, 9, function(state)
	Config.AntiAFK = state SaveConfig(false) end)
CreateToggle(Tab1_Dashboard, "Super Anti-Fling Shield (No-Collide Players + Velocity Lock)", Config.AntiFlingEnabled ~= false, 10, function(state)
	Config.AntiFlingEnabled = state if not state then lastSafeAntiFlingCF = nil pcall(function()
			for _, plr in ipairs(Players:GetPlayers()) do if plr ~= player and plr.Character then
					for _, part in ipairs(plr.Character:GetDescendants()) do
						if part:IsA("BasePart") and (part.Name == "Head" or part.Name == "Torso" or part.Name == "UpperTorso" or part.Name == "LowerTorso" or part.Name == "HumanoidRootPart") then
							part.CanCollide = true end end end end end) end SaveConfig(false) end)
genv.TR_AntiCheatActive = (Config.AntiCheatBypass ~= false) local function DisableAntiCheatSignals(char)
	-- Intentionally avoid destroying internal replication signals (StateChanged / CFrame)
	-- to prevent games from detecting missing heartbeats and kicking after 5 seconds.
	-- Metamethod spoofing on __index safely handles property inquiries.
end
CreateToggle(Tab1_Dashboard, "Undetected Anti-Cheat Bypass (Fly, Speed, Jump & Teleport)", Config.AntiCheatBypass ~= false, 11, function(state)
	Config.AntiCheatBypass = state genv.TR_AntiCheatActive = state
	if state then DisableAntiCheatSignals(player.Character) end SaveConfig(false) end)
if Config.AntiCheatBypass ~= false then DisableAntiCheatSignals(player.Character) end
table.insert(Connections, player.CharacterAdded:Connect(function(newChar) task.wait(0.25)
	if Config.AntiCheatBypass ~= false then DisableAntiCheatSignals(newChar) end end))
-- Anti-Cheat Protection Engine active globally from Line 1
table.insert(Connections, player.Idled:Connect(function() if Config.AntiAFK then pcall(function()
			VirtualUser:CaptureController() VirtualUser:ClickButton2(Vector2.new()) end) end end)) end SetupTab1()
--==============================================================================
-- 8. TAB 2: WAYPOINTS & TELEPORT
--==============================================================================
local GetRootPart, GetCharacterFromPlayer, freezePosition, lastSafeAntiFlingCF, SafeTeleportToCoords
local teleportBypassLockUntil, teleportBypassTargetCF = 0, nil
local function SetupTab2() CreateSectionHeader(Tab2_Waypoints, "Coordinates & Direct Teleport", 1)
local CoordsTopCard = CreateCard(Tab2_Waypoints, 88, 2)
local CopyCoordsBtn = MakeButton(CoordsTopCard, UDim2.new(0.5, -14, 0, 32), UDim2.new(0, 10, 0, 10), E.Clip .. " Copy Coords", "Accent", 12)
local AddWaypointBtn = MakeButton(CoordsTopCard, UDim2.new(0.5, -14, 0, 32), UDim2.new(0.5, 4, 0, 10), E.Plus .. " Save Pos", "AccentDark", 12)
local CoordsInput = Instance.new("TextBox") CoordsInput.Size = UDim2.new(1, -125, 0, 32)
CoordsInput.Position = UDim2.new(0, 10, 0, 48)
CoordsInput.PlaceholderText = "Enter X, Y, Z coordinates (e.g. 120, 50, -340)..." CoordsInput.Text = ""
CoordsInput.ClearTextOnFocus = false CoordsInput.Font = Enum.Font.Gotham CoordsInput.TextSize = 12
CoordsInput.Parent = CoordsTopCard RegisterThemeObject(CoordsInput, "BackgroundColor3", "PanelBg")
RegisterThemeObject(CoordsInput, "TextColor3", "TextPrimary") AddCorner(CoordsInput, 6)
local DirectTpBtn = MakeButton(CoordsTopCard, UDim2.new(0, 105, 0, 32), UDim2.new(1, -115, 0, 48), E.Bolt .. " Teleport", "Accent", 12)
local CHAR_FOLDER_NAMES = { "Characters", "Players", "Fighters", "Entities", "Alive" }
local fallbackCharCache, fallbackCharTime = {}, {}
GetCharacterFromPlayer = function(plr)
	if not plr then return nil end
	local c = plr.Character
	if c and c.Parent then return c end
	local now = os.clock()
	if fallbackCharTime[plr] and (now - fallbackCharTime[plr] < 0.3) then
		local cached = fallbackCharCache[plr]
		if cached and cached.Parent then return cached end
		return nil
	end
	fallbackCharTime[plr] = now
	local pName = plr.Name
	local wsChar = workspace:FindFirstChild(pName)
	if wsChar and wsChar:IsA("Model") then
		fallbackCharCache[plr] = wsChar
		return wsChar
	end
	for i = 1, #CHAR_FOLDER_NAMES do
		local f = workspace:FindFirstChild(CHAR_FOLDER_NAMES[i])
		if f then
			local sub = f:FindFirstChild(pName)
			if sub and sub:IsA("Model") then
				fallbackCharCache[plr] = sub
				return sub
			end
		end
	end
	fallbackCharCache[plr] = nil
	return c
end
GetRootPart = function(character)
	local char = character
	if typeof and typeof(character) == "Instance" and character:IsA("Player") then
		char = GetCharacterFromPlayer(character)
	elseif not char then
		char = GetCharacterFromPlayer(player)
	end
	if not char then return nil end
	return char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") or char:FindFirstChildWhichIsA("BasePart")
end freezePosition = nil
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
			ActiveKeybindCaptureCallback = function(keyName)
				TryAssignUniqueKeybind(keyName, "Waypoint:" .. tostring(idx), function(val) wp.Keybind = val end, function()
					KeyBtn.Text = "[" .. (wp.Keybind or "None") .. "]"
				end, KeyBtn) end end)
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
		RebuildWaypointsUI() end end) RebuildWaypointsUI() end SetupTab2()
--==============================================================================
-- 9. TAB 3: REAL-TIME PLAYER RADAR & TELEPORT KEYBINDS
--==============================================================================
local SpectatingTarget, SetSpectateTarget, RefreshSpectateVisualsInDetector, IsFriend, RefreshRadarCards, GetPlayerDetectionState
local StickTarget, StickMode, SetStickTarget, IsStickingToPlayer
local isFreecamActive, stopFreecam, ApplyCameraMode
local function SetupTab3()
StickTarget = nil
StickMode = Config.StickMode or "Back"
IsStickingToPlayer = function()
	return StickTarget ~= nil and StickTarget.Parent ~= nil
end

CreateSectionHeader(Tab3_Radar, "Stick to Player (10,000+ s/s Lock | Head, Back Side & Bottom)", 1)
local StickCtrlCard = CreateCard(Tab3_Radar, 0, 2)
StickCtrlCard.AutomaticSize = Enum.AutomaticSize.Y
local StickPad = Instance.new("UIPadding")
StickPad.PaddingTop = UDim.new(0, 8) StickPad.PaddingBottom = UDim.new(0, 8)
StickPad.PaddingLeft = UDim.new(0, 10) StickPad.PaddingRight = UDim.new(0, 10)
StickPad.Parent = StickCtrlCard
local StickCardLayout = Instance.new("UIListLayout")
StickCardLayout.Padding = UDim.new(0, 6)
StickCardLayout.SortOrder = Enum.SortOrder.LayoutOrder
StickCardLayout.Parent = StickCtrlCard

local StickTopRow = Instance.new("Frame")
StickTopRow.Size = UDim2.new(1, 0, 0, 28)
StickTopRow.BackgroundTransparency = 1
StickTopRow.LayoutOrder = 1
StickTopRow.Parent = StickCtrlCard
local StickStatusLbl = MakeLabel(StickTopRow, UDim2.new(0.72, -6, 1, 0), UDim2.new(0, 0, 0, 0), "Stick Status: OFF (Click 'Stick' on any player below)", Enum.Font.GothamBold, 11, "TextPrimary", Enum.TextXAlignment.Left)
StickStatusLbl.TextTruncate = Enum.TextTruncate.AtEnd
local UnstickTopBtn = MakeButton(StickTopRow, UDim2.new(0.28, 0, 0, 26), UDim2.new(0.72, 0, 0, 1), "UNSTICK", "AccentDark", 11)
UnstickTopBtn.BackgroundColor3 = Color3.fromRGB(185, 42, 58)

local StickModeRow = Instance.new("Frame")
StickModeRow.Size = UDim2.new(1, 0, 0, 30)
StickModeRow.BackgroundTransparency = 1
StickModeRow.LayoutOrder = 2
StickModeRow.Parent = StickCtrlCard
local StickModeGrid = Instance.new("UIGridLayout")
StickModeGrid.CellSize = UDim2.new(0.333, -5, 0, 28)
StickModeGrid.CellPadding = UDim2.new(0, 6, 0, 4)
StickModeGrid.HorizontalAlignment = Enum.HorizontalAlignment.Center
StickModeGrid.VerticalAlignment = Enum.VerticalAlignment.Center
StickModeGrid.SortOrder = Enum.SortOrder.LayoutOrder
StickModeGrid.Parent = StickModeRow

local StickModeBtns = {}
local StickModesList = {
	{ Id = "Head", Label = "Part: Head (Top)" },
	{ Id = "Back", Label = "Part: Back Side" },
	{ Id = "Bottom", Label = "Part: Bottom" },
}
local function RefreshStickUI()
	local theme = GetTheme()
	for id, btn in pairs(StickModeBtns) do
		local active = (StickMode == id)
		btn.BackgroundColor3 = active and theme.Accent or theme.PanelBg
		btn.TextColor3 = active and Color3.fromRGB(245, 245, 250) or theme.TextPrimary
	end
	if StickTarget and StickTarget.Parent then
		StickStatusLbl.Text = string.format("STUCK TO: %s (@%s) [%s]", tostring(StickTarget.DisplayName), tostring(StickTarget.Name), string.upper(StickMode))
		StickStatusLbl.TextColor3 = Color3.fromRGB(46, 204, 113)
	else
		StickStatusLbl.Text = "Stick Status: OFF (Mode: " .. StickMode .. " | Click 'Stick' below)"
		StickStatusLbl.TextColor3 = theme.TextPrimary
	end
end
table.insert(ThemeObjects.CustomCallbacks, RefreshStickUI)

for idx, mInfo in ipairs(StickModesList) do
	local mBtn = Instance.new("TextButton")
	mBtn.LayoutOrder = idx
	mBtn.Font = Enum.Font.GothamBold
	mBtn.TextSize = 11
	mBtn.Text = mInfo.Label
	mBtn.Parent = StickModeRow
	AddCorner(mBtn, 6)
	StickModeBtns[mInfo.Id] = mBtn
	mBtn.MouseButton1Click:Connect(function()
		StickMode = mInfo.Id
		Config.StickMode = StickMode
		savedConfig.Settings.StickMode = StickMode
		RefreshStickUI()
		if RefreshRadarCards then pcall(RefreshRadarCards) end
		SaveConfig(false)
	end)
end

local function ComputeStickCFrame(tChar, tRoot, dt)
	local tVel = tRoot.AssemblyLinearVelocity or Vector3.zero
	local leadVec = (tVel.Magnitude > 35) and (tVel * math.clamp(dt or 0.008, 0.001, 0.02)) or Vector3.zero
	local baseCF = tRoot.CFrame + leadVec
	if StickMode == "Head" then
		local tHead = tChar:FindFirstChild("Head")
		if tHead and tHead:IsA("BasePart") then
			return (tHead.CFrame + leadVec) * CFrame.new(0, 3.2, 0), tVel
		end
		return baseCF * CFrame.new(0, 4.5, 0), tVel
	elseif StickMode == "Bottom" then
		return baseCF * CFrame.new(0, -4.5, 0), tVel
	else
		return baseCF * CFrame.new(0, 0, 3.2), tVel
	end
end

local function StepStickEngine(dt)
	if not StickTarget or isClosingPermanently then return end
	if not StickTarget.Parent then
		SetStickTarget(nil)
		return
	end
	local myChar = GetCharacterFromPlayer(player)
	local myRoot = GetRootPart(myChar)
	local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
	if not myChar or not myRoot then return end

	for _, part in ipairs(myChar:GetChildren()) do
		if part:IsA("BasePart") and part.CanCollide then
			part.CanCollide = false
		end
	end

	local tChar = GetCharacterFromPlayer(StickTarget)
	local tRoot = GetRootPart(tChar)
	if not tChar or not tRoot then return end

	local goalCF, tVel = ComputeStickCFrame(tChar, tRoot, dt)
	if myHum then
		myHum.PlatformStand = false
		myHum:ChangeState(Enum.HumanoidStateType.Running)
	end
	myRoot.CFrame = goalCF
	myRoot.AssemblyLinearVelocity = tVel
	myRoot.AssemblyAngularVelocity = Vector3.zero
end

SetStickTarget = function(targetPlr)
	if not targetPlr or targetPlr == player then
		local wasSticking = (StickTarget ~= nil)
		StickTarget = nil
		pcall(function() RunService:UnbindFromRenderStep("TR_Stick_Step") end)
		if wasSticking then
			local myChar = GetCharacterFromPlayer(player)
			local myRoot = GetRootPart(myChar)
			if myRoot then
				myRoot.AssemblyLinearVelocity = Vector3.zero
				myRoot.AssemblyAngularVelocity = Vector3.zero
			end
			if not Config.NoclipEnabled and RestoreCharacterCollision then
				pcall(RestoreCharacterCollision, myChar)
			end
		end
		RefreshStickUI()
		if RefreshRadarCards then pcall(RefreshRadarCards) end
		return false
	end
	StickTarget = targetPlr
	pcall(function() RunService:UnbindFromRenderStep("TR_Stick_Step") end)
	RunService:BindToRenderStep("TR_Stick_Step", Enum.RenderPriority.Character.Value + 1, function(dt)
		StepStickEngine(dt)
	end)
	RefreshStickUI()
	if RefreshRadarCards then pcall(RefreshRadarCards) end
	return true
end

UnstickTopBtn.MouseButton1Click:Connect(function()
	SetStickTarget(nil)
end)
table.insert(Connections, RunService.Stepped:Connect(function(_, dt)
	if StickTarget then StepStickEngine(dt) end
end))
table.insert(Connections, RunService.Heartbeat:Connect(function(dt)
	if StickTarget then StepStickEngine(dt) end
end))
RefreshStickUI()

CreateSectionHeader(Tab3_Radar, "Live Player Radar (Hackers & Speeders Top | Friends " .. E.Star .. " | Delete Unassigns)", 3)
local RadarContainer = Instance.new("Frame") RadarContainer.LayoutOrder = 4
RadarContainer.Size = UDim2.new(1, 0, 0, 0) RadarContainer.AutomaticSize = Enum.AutomaticSize.Y
RadarContainer.BackgroundTransparency = 1 RadarContainer.Parent = Tab3_Radar
local RadarLayout = Instance.new("UIListLayout") RadarLayout.Padding = UDim.new(0, 6)
RadarLayout.SortOrder = Enum.SortOrder.LayoutOrder RadarLayout.Parent = RadarContainer
local FriendCache = {}
SpectatingTarget = nil
local specYaw, specPitch, specDist = 0, -math.rad(15), 14
SetSpectateTarget = function(targetPlr)
	if not targetPlr or targetPlr == player then
		SpectatingTarget = nil
		pcall(function() RunService:UnbindFromRenderStep("TR_Spectate_Step") end)
		pcall(function()
			local cam = workspace.CurrentCamera
			local myChar = GetCharacterFromPlayer(player)
			local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
			local myRoot = GetRootPart(myChar)
			if cam then
				cam.CameraType = Enum.CameraType.Custom
				if myHum then cam.CameraSubject = myHum
				elseif myRoot then cam.CameraSubject = myRoot end
			end
			if ApplyCameraMode then
				ApplyCameraMode(Config.CameraOverrideMode)
			else
				player.CameraMode = Enum.CameraMode.Classic
				player.CameraMinZoomDistance = 0.5
				player.CameraMaxZoomDistance = 400
			end
		end)
		if RefreshRadarCards then pcall(RefreshRadarCards) end
		if RefreshSpectateVisualsInDetector then pcall(RefreshSpectateVisualsInDetector) end
		return false
	end
	if isFreecamActive and isFreecamActive() and stopFreecam then
		pcall(stopFreecam)
	end
	SpectatingTarget = targetPlr
	local tChar = GetCharacterFromPlayer(targetPlr)
	local tHum = tChar and tChar:FindFirstChildOfClass("Humanoid")
	local tRoot = GetRootPart(tChar) or (tChar and tChar:FindFirstChild("Head"))
	pcall(function()
		player.CameraMode = Enum.CameraMode.Classic
		player.CameraMinZoomDistance = 4
		player.CameraMaxZoomDistance = 128
		local cam = workspace.CurrentCamera
		if cam then
			local _, ry, _ = cam.CFrame:ToOrientation()
			specYaw = ry or 0
			specPitch = -math.rad(16)
			cam.CameraType = Enum.CameraType.Custom
			if tHum then cam.CameraSubject = tHum
			elseif tRoot then cam.CameraSubject = tRoot end
		end
	end)
	pcall(function() RunService:UnbindFromRenderStep("TR_Spectate_Step") end)
	RunService:BindToRenderStep("TR_Spectate_Step", Enum.RenderPriority.Camera.Value + 5, function(dt)
		if not SpectatingTarget or isClosingPermanently then
			pcall(function() RunService:UnbindFromRenderStep("TR_Spectate_Step") end)
			return
		end
		if not SpectatingTarget.Parent then
			SetSpectateTarget(nil)
			return
		end
		if isFreecamActive and isFreecamActive() then return end
		local cam = workspace.CurrentCamera
		if not cam then return end
		local curChar = GetCharacterFromPlayer(SpectatingTarget)
		if not curChar then return end
		local curHum = curChar:FindFirstChildOfClass("Humanoid")
		local curRoot = GetRootPart(curChar) or curChar:FindFirstChild("Head")
		local subj = curHum or curRoot
		if not subj then return end
		pcall(function()
			if player.CameraMode == Enum.CameraMode.LockFirstPerson then
				player.CameraMode = Enum.CameraMode.Classic
				player.CameraMinZoomDistance = 4
				player.CameraMaxZoomDistance = 128
			end
			if cam.CameraSubject ~= subj then
				cam.CameraSubject = subj
			end
			if cam.CameraType ~= Enum.CameraType.Custom then
				cam.CameraType = Enum.CameraType.Custom
			end
		end)
		if curRoot then
			local distToTarget = (cam.CFrame.Position - curRoot.Position).Magnitude
			if distToTarget > 65 then
				local dtClamped = math.min(dt or 0.016, 0.1)
				if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) or CursorUnlockedOverride then
					local delta = UserInputService:GetMouseDelta()
					specYaw = specYaw - math.rad(delta.X * 0.28)
					specPitch = math.clamp(specPitch - math.rad(delta.Y * 0.28), -math.rad(80), math.rad(80))
				end
				if UserInputService:GetFocusedTextBox() == nil then
					if UserInputService:IsKeyDown(Enum.KeyCode.Left) then specYaw = specYaw + (1.8 * dtClamped) end
					if UserInputService:IsKeyDown(Enum.KeyCode.Right) then specYaw = specYaw - (1.8 * dtClamped) end
					if UserInputService:IsKeyDown(Enum.KeyCode.Up) then specPitch = math.clamp(specPitch + (1.5 * dtClamped), -math.rad(80), math.rad(80)) end
					if UserInputService:IsKeyDown(Enum.KeyCode.Down) then specPitch = math.clamp(specPitch - (1.5 * dtClamped), -math.rad(80), math.rad(80)) end
				end
				local focusPos = curRoot.Position + Vector3.new(0, 2.2, 0)
				local rotCF = CFrame.fromOrientation(specPitch, specYaw, 0)
				cam.CFrame = CFrame.new(focusPos) * rotCF * CFrame.new(0, 0, specDist)
				cam.Focus = CFrame.new(focusPos)
			end
		end
	end)
	if RefreshRadarCards then pcall(RefreshRadarCards) end
	if RefreshSpectateVisualsInDetector then pcall(RefreshSpectateVisualsInDetector) end
	return true
end
IsFriend = function(targetPlayer)
	if not targetPlayer then return false end
	local uid = targetPlayer.UserId
	if not uid or uid <= 0 then return false end
	if FriendCache[uid] ~= nil then return FriendCache[uid] end
	FriendCache[uid] = false
	task.spawn(function()
		local ok, res = pcall(function() return player:IsFriendsWith(uid) end)
		if ok and res == true then FriendCache[uid] = true end
	end)
	return FriendCache[uid]
end
local RadarCards = {}
RefreshRadarCards = function()
	local myRoot = GetRootPart()
	local myPos = myRoot and myRoot.Position or Vector3.new(0, 0, 0)
	local entries = {}
	local currentPlayersMap = {}
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= player then
			currentPlayersMap[plr] = true
			local isFriend = IsFriend(plr)
			local theirRoot = GetRootPart(plr)
			local dist = theirRoot and (theirRoot.Position - myPos).Magnitude or 999999
			local tier, tag, hRank = 3, nil, 80
			if GetPlayerDetectionState then tier, tag, hRank = GetPlayerDetectionState(plr.Name) end
			table.insert(entries, { Player = plr, IsFriend = isFriend, Distance = dist, Tier = tier or 3, Tag = tag, HackRank = hRank or 80 })
		end
	end
	table.sort(entries, function(a, b)
		if (a.HackRank or 80) ~= (b.HackRank or 80) then return (a.HackRank or 80) < (b.HackRank or 80) end
		if a.Tier ~= b.Tier then return a.Tier < b.Tier end
		if a.IsFriend ~= b.IsFriend then return a.IsFriend end
		return a.Distance < b.Distance
	end)

	for p, cardData in pairs(RadarCards) do
		if not currentPlayersMap[p] then
			if cardData.Card and cardData.Card.Parent then cardData.Card:Destroy() end
			RadarCards[p] = nil
		end
	end

	local theme = GetTheme()
	for idx, entry in ipairs(entries) do
		local plr = entry.Player
		local prefix = entry.IsFriend and (E.Star .. " ") or ""
		if entry.Tier == 1 then prefix = "[HACKER] " .. prefix
		elseif entry.Tier == 2 then prefix = "[SPEED] " .. prefix end
		local distText = (entry.Distance < 999990) and string.format("%.0f studs", entry.Distance) or "N/A"
		local isSpec = (SpectatingTarget == plr)
		local isStuck = (StickTarget == plr)

		local cardData = RadarCards[plr]
		if not cardData or not cardData.Card or not cardData.Card.Parent then
			local Card = CreateCard(RadarContainer, 48, idx)
			local AvatarImg = Instance.new("ImageLabel")
			AvatarImg.Size = UDim2.new(0, 34, 0, 34)
			AvatarImg.Position = UDim2.new(0, 8, 0.5, -17)
			AvatarImg.BackgroundTransparency = 0.4
			AvatarImg.BorderSizePixel = 0
			AvatarImg.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(plr.UserId) .. "&w=48&h=48"
			AvatarImg.Parent = Card
			RegisterThemeObject(AvatarImg, "BackgroundColor3", "PanelBg")
			AddCorner(AvatarImg, 6)

			local NameLbl = MakeLabel(Card, UDim2.new(1, -334, 0, 20), UDim2.new(0, 48, 0, 4), string.format("%s%s (@%s)", prefix, plr.DisplayName, plr.Name), Enum.Font.GothamBold, 12, "TextPrimary", Enum.TextXAlignment.Left)
			NameLbl.TextTruncate = Enum.TextTruncate.AtEnd
			if entry.Tier == 1 then NameLbl.TextColor3 = Color3.fromRGB(255, 65, 65)
			elseif entry.Tier == 2 then NameLbl.TextColor3 = Color3.fromRGB(255, 165, 45) end

			local rChar = plr.Character
			local rHum = rChar and rChar:FindFirstChildOfClass("Humanoid")
			local hp = rHum and math.max(0, rHum.Health) or 100
			local maxHp = rHum and math.max(1, rHum.MaxHealth) or 100
			local rShield = (rChar and (rChar:GetAttribute("Shield") or rChar:GetAttribute("Armor"))) or 0
			local hpText = string.format("HP: %.0f%%", (hp / maxHp) * 100)
			local sText = (type(rShield) == "number" and rShield > 0) and string.format(" | Shield: %.0f", rShield) or ""
			local DistLbl = MakeLabel(Card, UDim2.new(1, -334, 0, 18), UDim2.new(0, 48, 0, 24), string.format("Distance: %s  |  %s%s", distText, hpText, sText), Enum.Font.Gotham, 11, "TextSecondary", Enum.TextXAlignment.Left)
			DistLbl.TextTruncate = Enum.TextTruncate.AtEnd

			local savedKey = savedConfig.RadarKeybinds[plr.Name] or "None"
			local KeyBtn = MakeButton(Card, UDim2.new(0, 56, 0, 28), UDim2.new(1, -280, 0.5, -14), "[" .. savedKey .. "]", "PanelBg", 10)
			KeyBtn.MouseButton1Click:Connect(function()
				KeyBtn.Text = "[Key]"
				ActiveKeybindCaptureCallback = function(keyName)
					TryAssignUniqueKeybind(keyName, "Radar:" .. tostring(plr.Name), function(val)
						if val == "None" then savedConfig.RadarKeybinds[plr.Name] = nil else savedConfig.RadarKeybinds[plr.Name] = val end
					end, function()
						KeyBtn.Text = "[" .. (savedConfig.RadarKeybinds[plr.Name] or "None") .. "]"
					end, KeyBtn)
				end
			end)
			KeyBtn.MouseButton2Click:Connect(function()
				savedConfig.RadarKeybinds[plr.Name] = nil
				KeyBtn.Text = "[None]"
				ActiveKeybindCaptureCallback = nil
				SaveConfig(false)
			end)

			local TpBtn = MakeButton(Card, UDim2.new(0, 58, 0, 28), UDim2.new(1, -218, 0.5, -14), "TP", "Accent", 11)
			TpBtn.MouseButton1Click:Connect(function()
				local targetRoot = GetRootPart(plr)
				if targetRoot then
					local pos = targetRoot.Position
					SafeTeleportToCoords(pos.X, pos.Y + 3, pos.Z)
				end
			end)

			local StickBtn = MakeButton(Card, UDim2.new(0, 72, 0, 28), UDim2.new(1, -154, 0.5, -14), isStuck and "Unstick" or ("Stick:" .. StickMode), isStuck and "Accent" or "PanelBg", 10)
			if isStuck then StickBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113) end
			StickBtn.MouseButton1Click:Connect(function()
				if StickTarget == plr then
					SetStickTarget(nil)
				else
					SetStickTarget(plr)
				end
			end)
			StickBtn.MouseButton2Click:Connect(function()
				if StickMode == "Head" then StickMode = "Back"
				elseif StickMode == "Back" then StickMode = "Bottom"
				else StickMode = "Head" end
				Config.StickMode = StickMode
				savedConfig.Settings.StickMode = StickMode
				RefreshStickUI()
				pcall(RefreshRadarCards)
				SaveConfig(false)
			end)

			local SpecBtn = MakeButton(Card, UDim2.new(0, 72, 0, 28), UDim2.new(1, -78, 0.5, -14), isSpec and "Unview" or "Spectate", isSpec and "Accent" or "AccentDark", 10)
			SpecBtn.MouseButton1Click:Connect(function()
				if SpectatingTarget == plr then
					SetSpectateTarget(nil)
				else
					SetSpectateTarget(plr)
				end
			end)

			cardData = {
				Card = Card,
				AvatarImg = AvatarImg,
				NameLbl = NameLbl,
				DistLbl = DistLbl,
				KeyBtn = KeyBtn,
				TpBtn = TpBtn,
				StickBtn = StickBtn,
				SpecBtn = SpecBtn,
			}
			RadarCards[plr] = cardData
		else
			cardData.Card.LayoutOrder = idx
			cardData.NameLbl.Text = string.format("%s%s (@%s)", prefix, plr.DisplayName, plr.Name)
			if entry.Tier == 1 then
				cardData.NameLbl.TextColor3 = Color3.fromRGB(255, 65, 65)
			elseif entry.Tier == 2 then
				cardData.NameLbl.TextColor3 = Color3.fromRGB(255, 165, 45)
			else
				cardData.NameLbl.TextColor3 = theme.TextPrimary
			end
			local rChar = plr.Character
			local rHum = rChar and rChar:FindFirstChildOfClass("Humanoid")
			local hp = rHum and math.max(0, rHum.Health) or 100
			local maxHp = rHum and math.max(1, rHum.MaxHealth) or 100
			local rShield = (rChar and (rChar:GetAttribute("Shield") or rChar:GetAttribute("Armor"))) or 0
			local hpText = string.format("HP: %.0f%%", (hp / maxHp) * 100)
			local sText = (type(rShield) == "number" and rShield > 0) and string.format(" | Shield: %.0f", rShield) or ""
			cardData.DistLbl.Text = string.format("Distance: %s  |  %s%s", distText, hpText, sText)
			local savedKey = savedConfig.RadarKeybinds[plr.Name] or "None"
			cardData.KeyBtn.Text = "[" .. savedKey .. "]"
			cardData.StickBtn.Text = isStuck and "Unstick" or ("Stick:" .. StickMode)
			cardData.StickBtn.BackgroundColor3 = isStuck and Color3.fromRGB(46, 204, 113) or theme.PanelBg
			cardData.SpecBtn.Text = isSpec and "Unview" or "Spectate"
			cardData.SpecBtn.BackgroundColor3 = isSpec and theme.Accent or theme.AccentDark
		end
	end
	RefreshStickUI()
end genv._TR_RefreshRadar = RefreshRadarCards pcall(RefreshRadarCards) end SetupTab3()
--==============================================================================
-- 10. TAB 4: ITEMS & INSTANT PROXIMITY PROMPTS (ITEM VACUUM / MAGNET)
--==============================================================================
local pullNearbyItems
local function SetupTab4()
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
CreateSectionHeader(Tab4_Items, "Item Vacuum & Magnet Engine", 3)
local function IsCharacterDescendant(inst) for _, plr in ipairs(Players:GetPlayers()) do
		if plr.Character and inst:IsDescendantOf(plr.Character) then return true end end return false end
pullNearbyItems = function() local char = player.Character local root = GetRootPart(char)
	if not root then return end local myPos = root.Position local radius = Config.ItemMagnetRadius or 60
	local radiusSq = radius * radius local function processCandidate(obj)
		if not obj or obj == char or obj.Name == "TR_FakeFloor" then return end if obj:IsA("Tool") then
			local handle = obj:FindFirstChild("Handle")
			if handle and handle:IsA("BasePart") and not handle.Anchored then local hp = handle.Position
				local dx = hp.X - myPos.X local dy = hp.Y - myPos.Y local dz = hp.Z - myPos.Z
				if (dx * dx + dy * dy + dz * dz) <= radiusSq then handle.CFrame = root.CFrame
					handle.AssemblyLinearVelocity = V3_ZERO SafeFireTouch(root, handle, 0)
					SafeFireTouch(root, handle, 1) end end
		elseif obj:IsA("BasePart") and not obj.Anchored and obj.CanTouch ~= false then
			if not IsCharacterDescendant(obj) then local op = obj.Position local dx = op.X - myPos.X
				local dy = op.Y - myPos.Y local dz = op.Z - myPos.Z if (dx * dx + dy * dy + dz * dz) <= radiusSq then
					local lower = obj.Name:lower()
					if lower:find("drop") or lower:find("coin") or lower:find("loot") or lower:find("item") or lower:find("gem") or lower:find("cash") or lower:find("gold") or obj:FindFirstChildOfClass("TouchTransmitter") then
						obj.CFrame = root.CFrame obj.AssemblyLinearVelocity = V3_ZERO SafeFireTouch(root, obj, 0)
						SafeFireTouch(root, obj, 1) end end end
		elseif obj:IsA("Model") and not IsCharacterDescendant(obj) then
			local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
			if part and not part.Anchored then local op = part.Position local dx = op.X - myPos.X
				local dy = op.Y - myPos.Y local dz = op.Z - myPos.Z if (dx * dx + dy * dy + dz * dz) <= radiusSq then
					local lower = obj.Name:lower() local hasPrompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
					if lower:find("drop") or lower:find("coin") or lower:find("loot") or lower:find("item") or lower:find("gem") or lower:find("cash") or lower:find("gold") or hasPrompt then
						part.CFrame = root.CFrame part.AssemblyLinearVelocity = V3_ZERO SafeFireTouch(root, part, 0)
						SafeFireTouch(root, part, 1) if hasPrompt then hasPrompt.HoldDuration = 0 SafeFirePrompt(hasPrompt)
						end end end end end end pcall(function() for _, child in ipairs(workspace:GetChildren()) do
			processCandidate(child) if child:IsA("Folder") or child:IsA("Model") then
				local folderName = child.Name:lower()
				if folderName:find("drop") or folderName:find("item") or folderName:find("loot") or folderName:find("coin") or folderName:find("spawn") or folderName:find("debris") or folderName:find("pickup") then
					for _, sub in ipairs(child:GetChildren()) do processCandidate(sub) end end end end end) end
CreateToggle(Tab4_Items, "Item Vacuum / Magnet (Pulls Nearby Items & Drops to Character)", Config.ItemMagnetEnabled == true, 4, function(state)
	Config.ItemMagnetEnabled = state if state then pullNearbyItems() end SaveConfig(false) end)
CreateSlider(Tab4_Items, "Item Vacuum Radius (studs)", 15, 1000, Config.ItemMagnetRadius or 60, 5, function(val)
	Config.ItemMagnetRadius = val SaveConfig(false) end) local MagnetCard = CreateCard(Tab4_Items, 46, 6)
local PulseBtn = MakeButton(MagnetCard, UDim2.new(1, -20, 0, 30), UDim2.new(0, 10, 0.5, -15), E.Magnet .. " Instant Vacuum Pulse (Pull All Items Now [E])", "Accent", 11)
PulseBtn.MouseButton1Click:Connect(pullNearbyItems) end SetupTab4()
--==============================================================================
local function SetupRemainingTabsAndLoops()
-- 11. TAB 5: FLIGHT & MOVEMENT
--==============================================================================
local masterFlightEnabled = (savedConfig.Settings.MasterFlightEnabled == true)
local keyFlying, fakeGroundPart = false, nil
local isFlightActive, stopFlight, startFlight, toggleFlightState
local naturalWalkSpeed, naturalJumpPower, naturalJumpHeight, naturalUseJumpPower = 16, 50, 7.2, true
local lastRecordedHum = nil
local RecordNaturalHumanoidDefaults, RestoreNaturalHumanoidDefaults, RestoreCharacterCollision
local toggleFreecamState, GetFreecamAnchorCF
local function SetupTab5()
CreateSectionHeader(Tab5_Flight, "Flight Engine & Keybind Controls", 1)
local FlightEngineCard = CreateCard(Tab5_Flight, 94, 2)
local masterFlightToggleBtn = Instance.new("TextButton")
masterFlightToggleBtn.Size = UDim2.new(0.5, -14, 0, 34)
masterFlightToggleBtn.Position = UDim2.new(0, 10, 0, 10)
masterFlightToggleBtn.Font = Enum.Font.GothamBold masterFlightToggleBtn.TextSize = 12
masterFlightToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
masterFlightToggleBtn.Parent = FlightEngineCard AddCorner(masterFlightToggleBtn, 6)
local keyFlyToggleBtn = Instance.new("TextButton") keyFlyToggleBtn.Size = UDim2.new(0.52, -12, 0, 34)
keyFlyToggleBtn.Position = UDim2.new(0.5, 4, 0, 10) keyFlyToggleBtn.Font = Enum.Font.GothamBold
keyFlyToggleBtn.TextSize = 12 keyFlyToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
keyFlyToggleBtn.Parent = FlightEngineCard AddCorner(keyFlyToggleBtn, 6)
local flyKeyBindLabel = MakeLabel(FlightEngineCard, UDim2.new(0.38, -10, 0, 30), UDim2.new(0, 10, 0, 52), "Shortcut Key:", Enum.Font.GothamSemibold, 12, "TextPrimary", Enum.TextXAlignment.Left)
flyKeyBindLabel.TextTruncate = Enum.TextTruncate.AtEnd
local flyKeyAssignBtn = MakeButton(FlightEngineCard, UDim2.new(0.36, -6, 0, 30), UDim2.new(0.38, 4, 0, 52), "Bind Key: [E]", "PanelBg", 11)
local flyKeyDeleteBtn = Instance.new("TextButton") flyKeyDeleteBtn.Size = UDim2.new(0.26, -14, 0, 30)
flyKeyDeleteBtn.Position = UDim2.new(0.74, 4, 0, 52)
flyKeyDeleteBtn.BackgroundColor3 = Color3.fromRGB(165, 38, 55)
flyKeyDeleteBtn.Font = Enum.Font.GothamBold flyKeyDeleteBtn.TextSize = 11
flyKeyDeleteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
flyKeyDeleteBtn.Text = E.Trash .. " Delete Key" flyKeyDeleteBtn.Parent = FlightEngineCard
AddCorner(flyKeyDeleteBtn, 6) masterFlightToggleBtn.BackgroundColor3 = masterFlightEnabled and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)
masterFlightToggleBtn.Text = masterFlightEnabled and "Master Flight Switch: ON" or "Master Flight Switch: OFF"
keyFlyToggleBtn.BackgroundColor3 = keyFlying and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)
keyFlyToggleBtn.Text = keyFlying and "Keybind [E] Flight: ON" or "Keybind [E] Flight: OFF"

isFlightActive = function()
	return masterFlightEnabled and keyFlying
end

stopFlight = function()
	keyFlying = false
	freezePosition = nil
	keyFlyToggleBtn.Text = "Keybind [E] Flight: OFF"
	keyFlyToggleBtn.BackgroundColor3 = Color3.fromRGB(231, 76, 60)

	if fakeGroundPart then
		fakeGroundPart:Destroy()
		fakeGroundPart = nil
	end

	local char = player.Character
	if char then
		local hum = char:FindFirstChildOfClass("Humanoid")
		local root = char:FindFirstChild("HumanoidRootPart")
		if hum then
			hum.PlatformStand = false
			hum:ChangeState(Enum.HumanoidStateType.GettingUp)
			hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
			hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
		end
		if root then
			root.AssemblyLinearVelocity = Vector3.zero
			root.AssemblyAngularVelocity = Vector3.zero
		end
	end
end

startFlight = function()
	if not masterFlightEnabled then return end
	local char = player.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not root or not hum then return end

	keyFlying = true
	freezePosition = root.Position
	keyFlyToggleBtn.Text = "Keybind [E] Flight: ON"
	keyFlyToggleBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)

	hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
	hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
	hum.PlatformStand = false

	if not fakeGroundPart then
		fakeGroundPart = Instance.new("Part")
		fakeGroundPart.Name = "TR_FakeFloor"
		fakeGroundPart.Size = Vector3.new(4, 0.2, 4)
		fakeGroundPart.Transparency = 1
		fakeGroundPart.Anchored = true
		fakeGroundPart.CanCollide = true
		fakeGroundPart.Parent = workspace
	end
end

toggleFlightState = function()
	if not masterFlightEnabled then return end
	if keyFlying then
		stopFlight()
	else
		startFlight()
	end
end

masterFlightToggleBtn.MouseButton1Click:Connect(function()
	masterFlightEnabled = not masterFlightEnabled
	savedConfig.Settings.MasterFlightEnabled = masterFlightEnabled
	if syncAllSystems then syncAllSystems() end
	masterFlightToggleBtn.BackgroundColor3 = masterFlightEnabled and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)
	masterFlightToggleBtn.Text = masterFlightEnabled and "Master Flight Switch: ON" or "Master Flight Switch: OFF"
	if not masterFlightEnabled then
		stopFlight()
	end
end)

keyFlyToggleBtn.MouseButton1Click:Connect(toggleFlightState)

flyKeyAssignBtn.MouseButton1Click:Connect(function()
	flyKeyAssignBtn.Text = "[Key / Del]"
	ActiveKeybindCaptureCallback = function(keyName)
		TryAssignUniqueKeybind(keyName, "Flight", function(val) savedConfig.Settings.FlyKeybind = val end, function()
			flyKeyAssignBtn.Text = "Bind Key: [" .. (savedConfig.Settings.FlyKeybind or "E") .. "]"
		end, flyKeyAssignBtn)
	end
end)
flyKeyDeleteBtn.MouseButton1Click:Connect(function()
	savedConfig.Settings.FlyKeybind = "None"
	ActiveKeybindCaptureCallback = nil
	flyKeyAssignBtn.Text = "Bind Key: [None]"
	SaveConfig(false)
end)

table.insert(Connections, UserInputService.InputBegan:Connect(function(input, gp)
	if gp or UserInputService:GetFocusedTextBox() ~= nil then return end
	if input.KeyCode == Enum.KeyCode.E and masterFlightEnabled then
		toggleFlightState()
	end
end))

table.insert(Connections, RunService.Heartbeat:Connect(function(deltaTime)
	if not isFlightActive() then return end
	local char = player.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not root or not hum then return end

	hum:ChangeState(Enum.HumanoidStateType.Running)

	if UserInputService:GetFocusedTextBox() then
		if freezePosition then
			root.CFrame = CFrame.new(freezePosition) * CFrame.Angles(camera.CFrame:ToEulerAnglesXYZ())
			root.AssemblyLinearVelocity = Vector3.zero
			root.AssemblyAngularVelocity = Vector3.zero
		end
		return
	end

	local moveVector = Vector3.zero
	local camCF = camera.CFrame

	if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVector = moveVector + camCF.LookVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVector = moveVector - camCF.LookVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVector = moveVector - camCF.RightVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVector = moveVector + camCF.RightVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveVector = moveVector + Vector3.new(0, 1, 0) end

	if savedConfig.Settings.ShiftDownEnabled ~= false then
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift) then
			moveVector = moveVector - Vector3.new(0, 1, 0)
		end
	end

	local currentFlySpeed = savedConfig.Settings.FlySpeed or 50

	if moveVector.Magnitude > 0 then
		local step = moveVector.Unit * (currentFlySpeed * deltaTime)
		local newPos = root.Position + step
		freezePosition = newPos
		root.CFrame = CFrame.new(newPos) * CFrame.Angles(camCF:ToEulerAnglesXYZ())
		root.AssemblyLinearVelocity = moveVector.Unit * math.min(currentFlySpeed, 45)
		root.AssemblyAngularVelocity = Vector3.zero
	else
		if not freezePosition then
			freezePosition = root.Position
		end
		root.CFrame = CFrame.new(freezePosition) * CFrame.Angles(camCF:ToEulerAnglesXYZ())
		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero
	end

	if fakeGroundPart then
		fakeGroundPart.CFrame = root.CFrame * CFrame.new(0, -3.1, 0)
	end
end))
RecordNaturalHumanoidDefaults = function(hum)
	if hum and hum ~= lastRecordedHum then
		lastRecordedHum = hum
		naturalWalkSpeed = tonumber(hum.WalkSpeed) or 16
		naturalJumpPower = tonumber(hum.JumpPower) or 50
		naturalJumpHeight = tonumber(hum.JumpHeight) or 7.2
		naturalUseJumpPower = (hum.UseJumpPower ~= false)
	end
end
RestoreNaturalHumanoidDefaults = function()
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum then
		RecordNaturalHumanoidDefaults(hum)
		pcall(function()
			hum.WalkSpeed = naturalWalkSpeed
			hum.UseJumpPower = naturalUseJumpPower
			hum.JumpPower = naturalJumpPower
			hum.JumpHeight = naturalJumpHeight
		end)
	end
end
if player.Character then
	local h = player.Character:FindFirstChildOfClass("Humanoid")
	if h then RecordNaturalHumanoidDefaults(h) end
end
CreateSectionHeader(Tab5_Flight, "Master Utility & Physics Controls", 3)
CreateToggle(Tab5_Flight, "Master Utility Switch (Enable WalkSpeed & JumpPower)", Config.MasterUtilityEnabled, 4, function(state)
	Config.MasterUtilityEnabled = state
	if not state then RestoreNaturalHumanoidDefaults() end
	SaveConfig(false) end)
RestoreCharacterCollision = function(targetChar)
	local c = targetChar or player.Character
	if not c then return end
	pcall(function()
		for _, part in ipairs(c:GetDescendants()) do
			if part:IsA("BasePart") and (part.Name == "HumanoidRootPart" or part.Name == "Torso" or part.Name == "UpperTorso" or part.Name == "LowerTorso" or part.Name == "Head") then
				part.CanCollide = true
			end
		end
		local hum = c:FindFirstChildOfClass("Humanoid")
		if hum and hum.Health > 0 and not (isFlightActive and isFlightActive()) then
			hum:ChangeState(Enum.HumanoidStateType.Running)
		end
	end)
end
CreateToggle(Tab5_Flight, "Noclip Mode (Disable Character CanCollide)", Config.NoclipEnabled, 5, function(state)
	Config.NoclipEnabled = state
	if not state then RestoreCharacterCollision(player.Character) end
	SaveConfig(false) end)
CreateToggle(Tab5_Flight, "Infinite Jump (Jump Continuously Mid-Air Without Ground Touch)", Config.InfiniteJump == true, 6, function(state)
	Config.InfiniteJump = state SaveConfig(false) end)
CreateToggle(Tab5_Flight, "Speed-Synced Spider Climb (Climb Walls at Character WalkSpeed)", Config.SpiderClimb == true, 7, function(state)
	Config.SpiderClimb = state SaveConfig(false) end)
CreateToggle(Tab5_Flight, "Shift-Down Flight Descent (Hold LeftShift to Descend)", Config.ShiftDownEnabled, 8, function(state)
	Config.ShiftDownEnabled = state SaveConfig(false) end)
CreateToggle(Tab5_Flight, "Countdown / Spawn Freeze Bypass (Unanchor & Clear Freeze Tags)", Config.CountdownBypass, 9, function(state)
	Config.CountdownBypass = state SaveConfig(false) end)
CreateSectionHeader(Tab5_Flight, "Speed & Movement Sliders", 10)
local FlySpeedSlider = CreateSlider(Tab5_Flight, "Fly Speed", 1, 1000, math.clamp(tonumber(Config.FlySpeed) or 100, 1, 1000), 11, function(val) Config.FlySpeed = val; savedConfig.Settings.FlySpeed = val; SaveConfig(false) end)
local WalkSpeedSlider = CreateSlider(Tab5_Flight, "WalkSpeed", 1, 500, math.clamp(tonumber(Config.WalkSpeed) or 18, 1, 500), 12, function(val) Config.WalkSpeed = val; savedConfig.Settings.WalkSpeed = val; SaveConfig(false) end)
local JumpPowerSlider = CreateSlider(Tab5_Flight, "JumpPower (1-500 | Low = Normal in Rivals / Steal an Egg)", 1, 500, math.clamp(tonumber(Config.JumpPower) or 50, 1, 500), 13, function(val) Config.JumpPower = val; savedConfig.Settings.JumpPower = val; SaveConfig(false) end)
local ResetSpeedCard = CreateCard(Tab5_Flight, 46, 14)
local ResetSpeedBtn = MakeButton(ResetSpeedCard, UDim2.new(1, -20, 0, 30), UDim2.new(0, 10, 0.5, -15), E.Refresh .. " Reset to Default (WalkSpeed: 18 | Jump: 50 | Fly Speed: 100)", "Accent", 12)
ResetSpeedBtn.MouseButton1Click:Connect(function()
	Config.WalkSpeed = 18 savedConfig.Settings.WalkSpeed = 18
	Config.JumpPower = 50 savedConfig.Settings.JumpPower = 50
	Config.FlySpeed = 100 savedConfig.Settings.FlySpeed = 100
	WalkSpeedSlider.SetValue(18)
	JumpPowerSlider.SetValue(50)
	FlySpeedSlider.SetValue(100)
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum and Config.MasterUtilityEnabled then
		pcall(function() hum.WalkSpeed = 18 hum.JumpPower = 50 end)
	end
	SaveConfig(false)
	ResetSpeedBtn.Text = E.Check .. " Defaults Applied (WalkSpeed: 18 | Jump: 50 | Fly Speed: 100)!"
	task.delay(1.1, function()
		if ResetSpeedBtn and ResetSpeedBtn.Parent then
			ResetSpeedBtn.Text = E.Refresh .. " Reset to Default (WalkSpeed: 18 | Jump: 50 | Fly Speed: 100)"
		end
	end)
end)
CreateSectionHeader(Tab5_Flight, "Freecam Engine & Keybind Controls", 15)
local FreecamCard = CreateCard(Tab5_Flight, 94, 16)
local freecamToggleBtn = Instance.new("TextButton", FreecamCard)
freecamToggleBtn.Size = UDim2.new(0.5, -14, 0, 34)
freecamToggleBtn.Position = UDim2.new(0, 10, 0, 10)
freecamToggleBtn.Font = Enum.Font.GothamBold freecamToggleBtn.TextSize = 12
freecamToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AddCorner(freecamToggleBtn, 6)
local freecamStatusLbl = Instance.new("TextLabel", FreecamCard)
freecamStatusLbl.Size = UDim2.new(0.5, -14, 0, 34)
freecamStatusLbl.Position = UDim2.new(0.5, 4, 0, 10)
freecamStatusLbl.BackgroundTransparency = 0.15
freecamStatusLbl.Font = Enum.Font.GothamSemibold freecamStatusLbl.TextSize = 12
freecamStatusLbl.Text = "Freecam: INACTIVE"
RegisterThemeObject(freecamStatusLbl, "BackgroundColor3", "PanelBg")
RegisterThemeObject(freecamStatusLbl, "TextColor3", "TextPrimary")
AddCorner(freecamStatusLbl, 6)
local fcKeyBindLabel = MakeLabel(FreecamCard, UDim2.new(0.38, -10, 0, 30), UDim2.new(0, 10, 0, 52), "Shortcut Key:", Enum.Font.GothamSemibold, 12, "TextPrimary", Enum.TextXAlignment.Left)
fcKeyBindLabel.TextTruncate = Enum.TextTruncate.AtEnd
local freecamKeyAssignBtn = MakeButton(FreecamCard, UDim2.new(0.36, -6, 0, 30), UDim2.new(0.38, 4, 0, 52), "Bind Key: [C]", "PanelBg", 11)
local freecamKeyDeleteBtn = Instance.new("TextButton", FreecamCard)
freecamKeyDeleteBtn.Size = UDim2.new(0.26, -14, 0, 30)
freecamKeyDeleteBtn.Position = UDim2.new(0.74, 4, 0, 52)
freecamKeyDeleteBtn.BackgroundColor3 = Color3.fromRGB(165, 38, 55)
freecamKeyDeleteBtn.Font = Enum.Font.GothamBold freecamKeyDeleteBtn.TextSize = 11
freecamKeyDeleteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
freecamKeyDeleteBtn.Text = E.Trash .. " Delete"
AddCorner(freecamKeyDeleteBtn, 6)
CreateSlider(Tab5_Flight, "Freecam Speed", 1, 500, math.clamp(tonumber(Config.FreecamSpeed) or 60, 1, 500), 17, function(val)
	Config.FreecamSpeed = val savedConfig.Settings.FreecamSpeed = val SaveConfig(false)
end)
local freecamEnabled, freecamAnchorCF = false, nil
local freecamPos = Vector3.new(0, 50, 0)
local freecamPitch, freecamYaw = 0, 0
local function RefreshFreecamUI()
	local k = Config.FreecamKeybind or "None"
	freecamKeyAssignBtn.Text = "Bind Key: [" .. k .. "]"
	freecamToggleBtn.Text = "Freecam [" .. k .. "]: " .. (freecamEnabled and "ON" or "OFF")
	freecamToggleBtn.BackgroundColor3 = freecamEnabled and Color3.fromRGB(38, 168, 92) or Color3.fromRGB(185, 52, 52)
	freecamStatusLbl.Text = freecamEnabled and "Freecam: ACTIVE (WASD + Mouse)" or "Freecam: INACTIVE"
end
isFreecamActive = function() return freecamEnabled end
GetFreecamAnchorCF = function(defaultCF)
	if not freecamAnchorCF and defaultCF then freecamAnchorCF = defaultCF end
	return freecamAnchorCF
end
stopFreecam = function()
	if not freecamEnabled then return end
	freecamEnabled = false
	freecamAnchorCF = nil
	pcall(function() RunService:UnbindFromRenderStep("TR_Freecam_Step") end)
	RefreshFreecamUI()
	pcall(function()
		local cam = workspace.CurrentCamera
		if cam then
			cam.CameraType = Enum.CameraType.Custom
			local char = GetCharacterFromPlayer(player)
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			if SpectatingTarget then
				local sChar = GetCharacterFromPlayer(SpectatingTarget)
				local sHum = sChar and sChar:FindFirstChildOfClass("Humanoid")
				if sHum then cam.CameraSubject = sHum end
			elseif hum then
				cam.CameraSubject = hum
			end
		end
		if not CursorUnlockedOverride then
			UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		end
		local char = GetCharacterFromPlayer(player)
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum then
			if Config.MasterUtilityEnabled then
				hum.WalkSpeed = math.clamp(tonumber(Config.WalkSpeed) or 18, 1, 500)
			else
				hum.WalkSpeed = naturalWalkSpeed or 16
			end
		end
	end)
end
local function startFreecam()
	if freecamEnabled then return end
	local cam = workspace.CurrentCamera
	if not cam then return end
	freecamEnabled = true
	freecamPos = cam.CFrame.Position
	local rx, ry, _ = cam.CFrame:ToOrientation()
	freecamPitch, freecamYaw = rx, ry
	local char = GetCharacterFromPlayer(player)
	local root = GetRootPart(char)
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if root then
		freecamAnchorCF = root.CFrame
		root.AssemblyLinearVelocity = V3_ZERO
		root.AssemblyAngularVelocity = V3_ZERO
	end
	if hum then hum.WalkSpeed = 0 end
	RefreshFreecamUI()
	RunService:BindToRenderStep("TR_Freecam_Step", Enum.RenderPriority.Camera.Value + 2, function(dt)
		if not freecamEnabled or isClosingPermanently then return end
		local curCam = workspace.CurrentCamera
		if not curCam then return end
		local dtClamped = math.min(dt or 0.016, 0.1)
		local rmbDown = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
		if rmbDown or CursorUnlockedOverride then
			UserInputService.MouseBehavior = rmbDown and Enum.MouseBehavior.LockCurrentPosition or Enum.MouseBehavior.LockCenter
			local delta = UserInputService:GetMouseDelta()
			freecamYaw = freecamYaw - math.rad(delta.X * 0.28)
			freecamPitch = math.clamp(freecamPitch - math.rad(delta.Y * 0.28), -math.rad(88), math.rad(88))
		elseif not CursorUnlockedOverride then
			UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		end
		if UserInputService:GetFocusedTextBox() == nil then
			if UserInputService:IsKeyDown(Enum.KeyCode.Left) then freecamYaw = freecamYaw + (1.8 * dtClamped) end
			if UserInputService:IsKeyDown(Enum.KeyCode.Right) then freecamYaw = freecamYaw - (1.8 * dtClamped) end
			if UserInputService:IsKeyDown(Enum.KeyCode.Up) then freecamPitch = math.clamp(freecamPitch + (1.5 * dtClamped), -math.rad(88), math.rad(88)) end
			if UserInputService:IsKeyDown(Enum.KeyCode.Down) then freecamPitch = math.clamp(freecamPitch - (1.5 * dtClamped), -math.rad(88), math.rad(88)) end
		end
		local rotCF = CFrame.fromOrientation(freecamPitch, freecamYaw, 0)
		local moveVec = V3_ZERO
		if UserInputService:GetFocusedTextBox() == nil then
			local look = rotCF.LookVector
			local right = rotCF.RightVector
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVec = moveVec + look end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVec = moveVec - look end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVec = moveVec + right end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVec = moveVec - right end
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) or UserInputService:IsKeyDown(Enum.KeyCode.E) then
				moveVec = moveVec + Vector3.new(0, 1, 0)
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.Q) then
				moveVec = moveVec - Vector3.new(0, 1, 0)
			end
		end
		local fcSpeed = math.clamp(tonumber(Config.FreecamSpeed) or 60, 1, 500)
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then fcSpeed = fcSpeed * 0.35 end
		if moveVec.Magnitude > 0.001 then
			freecamPos = freecamPos + (moveVec.Unit * (fcSpeed * dtClamped))
		end
		curCam.CameraType = Enum.CameraType.Scriptable
		curCam.CFrame = CFrame.new(freecamPos) * rotCF
	end)
end
toggleFreecamState = function()
	if freecamEnabled then stopFreecam() else startFreecam() end
end
freecamToggleBtn.MouseButton1Click:Connect(toggleFreecamState)
freecamKeyAssignBtn.MouseButton1Click:Connect(function()
	freecamKeyAssignBtn.Text = "[Key / Del]"
	ActiveKeybindCaptureCallback = function(keyName)
		TryAssignUniqueKeybind(keyName, "Freecam", function(val) Config.FreecamKeybind = val; savedConfig.Settings.FreecamKeybind = val end, RefreshFreecamUI, freecamKeyAssignBtn)
	end
end)
freecamKeyDeleteBtn.MouseButton1Click:Connect(function()
	Config.FreecamKeybind = "None"
	savedConfig.Settings.FreecamKeybind = "None"
	ActiveKeybindCaptureCallback = nil
	RefreshFreecamUI()
	SaveConfig(false)
end)
RefreshFreecamUI()
end SetupTab5()
--==============================================================================
-- 12. TAB 6: MULTI-TARGET FLING HUB (WITH NETWORK PAUSE BYPASS)
--==============================================================================
local SelectedTargets, FlingActive = {}, false local RefreshFlingPlayerList, StopFling
local function SetupTab6()
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
	for _, child in pairs(playerScrollFrame:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end
	PlayerCheckboxes = {}
	local playerList = Players:GetPlayers()
	table.sort(playerList, function(a, b) return a.Name:lower() < b.Name:lower() end)
	local yPos = 0
	for _, target in ipairs(playerList) do
		if target ~= player then
			if SelectedTargets[target.Name] == nil and Config.AutoSelectFling == true then
				if not IsFriend(target) then SelectedTargets[target.Name] = target end
			end
			local row = Instance.new("Frame")
			row.Size = UDim2.new(1, -4, 0, 36)
			row.Position = UDim2.new(0, 2, 0, yPos)
			row.BackgroundTransparency = 0.2
			row.Parent = playerScrollFrame
			RegisterThemeObject(row, "BackgroundColor3", "CardBg")
			AddCorner(row, 8)

			local checkBox = Instance.new("Frame")
			checkBox.Size = UDim2.new(0, 20, 0, 20)
			checkBox.Position = UDim2.new(0, 8, 0.5, -10)
			checkBox.BorderSizePixel = 0
			checkBox.Parent = row
			RegisterThemeObject(checkBox, "BackgroundColor3", "PanelBg")
			AddCorner(checkBox, 5)

			local checkMark = Instance.new("TextLabel")
			checkMark.Size = UDim2.new(1, 0, 1, 0)
			checkMark.BackgroundTransparency = 1
			checkMark.Text = E.Tick
			checkMark.TextSize = 14
			checkMark.Font = Enum.Font.GothamBold
			checkMark.Visible = (SelectedTargets[target.Name] ~= nil)
			checkMark.Parent = checkBox
			RegisterThemeObject(checkMark, "TextColor3", "Accent")

			local AvatarImg = Instance.new("ImageLabel")
			AvatarImg.Size = UDim2.new(0, 26, 0, 26)
			AvatarImg.Position = UDim2.new(0, 34, 0.5, -13)
			AvatarImg.BackgroundTransparency = 0.4
			AvatarImg.BorderSizePixel = 0
			AvatarImg.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(target.UserId) .. "&w=48&h=48"
			AvatarImg.Parent = row
			RegisterThemeObject(AvatarImg, "BackgroundColor3", "PanelBg")
			AddCorner(AvatarImg, 5)

			local nameLbl = Instance.new("TextLabel")
			nameLbl.Size = UDim2.new(1, -70, 1, 0)
			nameLbl.Position = UDim2.new(0, 68, 0, 0)
			nameLbl.BackgroundTransparency = 1
			local dName = tostring(target.DisplayName)
			local uName = tostring(target.Name)
			local labelText = (dName ~= uName) and (dName .. " (@" .. uName .. ")") or uName
			if IsFriend(target) then labelText = labelText .. " " .. E.Star end
			nameLbl.Text = labelText
			nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
			nameLbl.TextSize = 12
			nameLbl.Font = Enum.Font.GothamMedium
			nameLbl.TextXAlignment = Enum.TextXAlignment.Left
			nameLbl.Parent = row
			RegisterThemeObject(nameLbl, "TextColor3", "TextPrimary")

			local clickBtn = Instance.new("TextButton")
			clickBtn.Size = UDim2.new(1, 0, 1, 0)
			clickBtn.BackgroundTransparency = 1
			clickBtn.Text = ""
			clickBtn.Parent = row
			clickBtn.MouseButton1Click:Connect(function()
				if SelectedTargets[target.Name] then
					SelectedTargets[target.Name] = nil
					checkMark.Visible = false
				else
					SelectedTargets[target.Name] = target
					checkMark.Visible = true
				end
				UpdateStatus()
			end)

			PlayerCheckboxes[target.Name] = { Row = row, Check = checkMark }
			yPos = yPos + 42
		end
	end
	playerScrollFrame.CanvasSize = UDim2.new(0, 0, 0, yPos)
	UpdateStatus()
end
local function ToggleAllPlayers(select) for _, target in ipairs(Players:GetPlayers()) do
		if target ~= player then local boxData = PlayerCheckboxes[target.Name] if boxData then if select then
					SelectedTargets[target.Name] = target boxData.Check.Visible = true else
					SelectedTargets[target.Name] = nil boxData.Check.Visible = false end end end end UpdateStatus() end
local function Message(title, text, timeLen) pcall(function() StarterGui:SetCore("SendNotification", {
			Title = title, Text = text, Duration = timeLen or 3 }) end) end local function SkidFling(TargetPlayer)
	local Character = player.Character
	local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
	local RootPart = (Humanoid and Humanoid.RootPart) or GetRootPart(Character) local TCharacter = GetCharacterFromPlayer(TargetPlayer)
	if not TCharacter then return end local THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")
	local TRootPart = (THumanoid and THumanoid.RootPart) or GetRootPart(TCharacter) local THead = TCharacter:FindFirstChild("Head")
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
deselectAllButton.MouseButton1Click:Connect(function() ToggleAllPlayers(false) end) genv._TR_RefreshFling = RefreshFlingPlayerList pcall(RefreshFlingPlayerList) end SetupTab6()
--==============================================================================
-- 13. TAB 7: AIMBOT, ESP, CAMERA & LIGHTING VISUALS
--==============================================================================
local ESP_UPDATE_INTERVAL, LERP_ALPHA = 0.25, 0.72
local FOV_RADIUS = tonumber(Config.AimbotFOVRadius) or 200
local fovCircleEnabled = (Config.AimbotFOVCircleEnabled ~= false)
local aimbotEnabled = (Config.AimbotEnabled == true)
local targetAimbotEnabled = (Config.TargetAimbotEnabled == true)
if aimbotEnabled and targetAimbotEnabled then targetAimbotEnabled = false Config.TargetAimbotEnabled = false end
local specificTargetPlayer = nil
local strongLock = (Config.StrongLock ~= false)
local aimbotTeamCheck = (Config.AimbotTeamCheck ~= false)
local autoShootEnabled = (Config.AutoShootEnabled == true) local lastAutoShoot = 0
local isAutoShootingActive = false
local currentTarget, lastEspUpdate = nil, 0
local excludedPlayers, characterCache, adornmentsCache = {}, {}, {}
local guiFovCircle = nil
local reusableWallcheckParams, updateWallcheckFilter
local IsTeammate, getTargetPart, isTargetVisible, removePlayerAdornments, clearAllAdornments, worldToScreenDistance
local RefreshESPHighlights, updateAllAdornments, findBestTarget
local aimbotStatusLabel, autoShootStatusLbl, excludeFrame, updateExcludeCount, rebuildExcludeList
local toggleAimbot, toggleTargetAimbot, toggleAutoShoot, triggerAutoShoot, StopAutoShootFiring
local function SetupTab7()
	local MAX_DISTANCE = 650
	local wallcheckEnabled = (Config.WallcheckEnabled ~= false)
	local espShowTeammates = (Config.ESPShowTeammates == true)
	local aimPartName = Config.AimPartName or "Head"
	local guiFovStroke
	guiFovCircle = Instance.new("Frame") guiFovCircle.Name = "TR_FOVCircle"
	guiFovCircle.AnchorPoint = Vector2.new(0.5, 0.5) guiFovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
	guiFovCircle.Size = UDim2.new(0, FOV_RADIUS * 2, 0, FOV_RADIUS * 2)
	guiFovCircle.BackgroundTransparency = 1 guiFovCircle.BorderSizePixel = 0 guiFovCircle.Visible = false
	guiFovCircle.Parent = ScreenGui Instance.new("UICorner", guiFovCircle).CornerRadius = UDim.new(1, 0)
	guiFovStroke = Instance.new("UIStroke", guiFovCircle) guiFovStroke.Thickness = 1.8
	guiFovStroke.Transparency = 0.15 RegisterThemeObject(guiFovStroke, "Color", "Accent")
	SyncAimbotFovCircleVisibility = function()
		local showCircle = aimbotEnabled and fovCircleEnabled and not isClosingPermanently if guiFovCircle then
			guiFovCircle.Size = UDim2.new(0, FOV_RADIUS * 2, 0, FOV_RADIUS * 2) guiFovCircle.Visible = showCircle
		end end
	StopAutoShootFiring = function()
		if isAutoShootingActive then
			isAutoShootingActive = false
			if mouse1release then pcall(mouse1release) end
		end
	end
	triggerAutoShoot = function()
		if not (aimbotEnabled or targetAimbotEnabled) or not autoShootEnabled then
			StopAutoShootFiring()
			return
		end
		local char = player.Character if not char then StopAutoShootFiring() return end
		local hum = char:FindFirstChildOfClass("Humanoid") if not hum or hum.Health <= 0 then StopAutoShootFiring() return end

		local nowT = os.clock()
		local shootDelay = math.clamp((tonumber(Config.AutoShootDelayMs) or 45) / 1000, 0.02, 0.5)
		if nowT - lastAutoShoot < shootDelay then return end
		lastAutoShoot = nowT

		local tool = char:FindFirstChildOfClass("Tool")
		if tool then pcall(function() tool:Activate() end) end
		if mouse1click then
			pcall(mouse1click)
		elseif mouse1press and mouse1release then
			pcall(mouse1press)
			task.delay(0.016, function() pcall(mouse1release) end)
		elseif mouse1press then
			pcall(mouse1press)
			isAutoShootingActive = true
		end
		if VirtualUser then
			pcall(function()
				if VirtualUser.CaptureController and VirtualUser.ClickButton1 then
					VirtualUser:CaptureController()
					VirtualUser:ClickButton1(Vector2.zero)
				end
			end)
		end
	end
	if false then
		local char = player.Character if not char then return end
		local hum = char:FindFirstChildOfClass("Humanoid") if not hum or hum.Health <= 0 then return end
		local tool = char:FindFirstChildOfClass("Tool") if tool then pcall(function() tool:Activate() end) end
		if mouse1click then pcall(mouse1click) elseif mouse1press and mouse1release then pcall(mouse1press)
			task.delay(0.016, function() pcall(mouse1release) end) elseif VirtualUser then pcall(function()
				if VirtualUser.CaptureController and VirtualUser.ClickButton1 then VirtualUser:CaptureController()
					VirtualUser:ClickButton1(Vector2.new(0, 0)) end end) end end local teamCache = {}
	local lastTeamCacheClear = 0 local function getTeamValFast(p) if not p then return nil end
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
	reusableWallcheckParams = RaycastParams.new()
	reusableWallcheckParams.FilterType = Enum.RaycastFilterType.Blacklist local reusableWallFilter = {}
	updateWallcheckFilter = function(char) char = char or LocalPlayer.Character reusableWallFilter[1] = char
		reusableWallcheckParams.FilterDescendantsInstances = reusableWallFilter end updateWallcheckFilter()
	isTargetVisible = function(targetPart, targetCharacter) if not wallcheckEnabled then return true end
		local cam = workspace.CurrentCamera if not cam or not targetPart then return false end
		if reusableWallFilter[1] ~= LocalPlayer.Character then updateWallcheckFilter(LocalPlayer.Character) end
		local camPos = cam.CFrame.Position local tPos = targetPart.Position
		local dir = Vector3.new(tPos.X - camPos.X, tPos.Y - camPos.Y, tPos.Z - camPos.Z)
		local res = workspace:Raycast(camPos, dir, reusableWallcheckParams)
		if not res or not res.Instance then return true end
		if targetCharacter and res.Instance:IsDescendantOf(targetCharacter) then return true end
		local hurtFolder = workspace:FindFirstChild("HurtEffect")
		if hurtFolder and res.Instance:IsDescendantOf(hurtFolder) then return true end
		return false
	end worldToScreenDistance = function(worldPos) local cam = workspace.CurrentCamera
		if not cam then return nil, false, math.huge end
		local vp, onScreen = cam:WorldToViewportPoint(worldPos)
		if not onScreen or vp.Z <= 0 then return nil, false, math.huge end local vs = cam.ViewportSize
		local dx = vp.X - (vs.X * 0.5) local dy = vp.Y - (vs.Y * 0.5)
		return vp, true, math.sqrt(dx * dx + dy * dy) end local highlightsCache = {}
	local function removePlayerHighlight(plr)
		local hl = highlightsCache[plr]
		if hl then
			pcall(function() hl.Adornee = nil hl:Destroy() end)
			highlightsCache[plr] = nil
		end
		if plr and plr.Character then
			for _, ch in ipairs(plr.Character:GetChildren()) do
				if ch:IsA("Highlight") and (ch.Name == "AssetHighlight" or ch.Name == "TR_ESP_Highlight") then
					pcall(function() ch.Adornee = nil ch:Destroy() end)
				end
			end
		end
	end
	local function clearAllHighlights()
		for plr, hl in pairs(highlightsCache) do
			pcall(function() hl.Adornee = nil hl:Destroy() end)
			highlightsCache[plr] = nil
		end
		if ScreenGui then
			for _, ch in ipairs(ScreenGui:GetChildren()) do
				if ch:IsA("Highlight") or ch.Name == "AssetHighlight" or ch.Name == "TR_ESP_Highlight" or ch.Name:find("^HL_") then
					pcall(function() ch.Adornee = nil ch:Destroy() end)
				end
			end
		end
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr.Character then
				for _, ch in ipairs(plr.Character:GetChildren()) do
					if ch:IsA("Highlight") and (ch.Name == "AssetHighlight" or ch.Name == "TR_ESP_Highlight") then
						pcall(function() ch.Adornee = nil ch:Destroy() end)
					end
				end
			end
		end
	end
	local function GetPlayerHealthAndShield(targetChar, targetHum)
		local hp, maxHp = 100, 100
		if targetHum then
			hp = math.max(0, targetHum.Health)
			maxHp = math.max(1, targetHum.MaxHealth)
		end
		local shield, maxShield = 0, 100
		if targetChar then
			local sAttr = targetChar:GetAttribute("Shield") or targetChar:GetAttribute("Armor")
			if type(sAttr) == "number" then
				shield = math.max(0, sAttr)
				local msAttr = targetChar:GetAttribute("MaxShield") or targetChar:GetAttribute("MaxArmor") or 100
				maxShield = math.max(1, tonumber(msAttr) or 100)
			else
				local sVal = targetChar:FindFirstChild("Shield") or targetChar:FindFirstChild("Armor")
				if sVal and (sVal:IsA("NumberValue") or sVal:IsA("IntValue")) then
					shield = math.max(0, sVal.Value)
				end
			end
		end
		return hp, maxHp, shield, maxShield
	end
	removePlayerAdornments = function(plr)
		local pair = adornmentsCache[plr]
		if pair then
			if pair.inner then pcall(function() pair.inner:Destroy() end) end
			if pair.outline then pcall(function() pair.outline:Destroy() end) end
			if pair.healthBar then pcall(function() pair.healthBar:Destroy() end) end
			if pair.healthBg then pcall(function() pair.healthBg:Destroy() end) end
			if pair.shieldBar then pcall(function() pair.shieldBar:Destroy() end) end
			if pair.shieldBg then pcall(function() pair.shieldBg:Destroy() end) end
			if pair.hpBillboard then pcall(function() pair.hpBillboard:Destroy() end) end
			adornmentsCache[plr] = nil
		end
		removePlayerHighlight(plr)
		characterCache[plr] = nil
	end
	clearAllAdornments = function()
		for plr in pairs(adornmentsCache) do removePlayerAdornments(plr) end
		clearAllHighlights()
	end
	RefreshESPHighlights = function()
		if not Config.ESPEnabled then
			clearAllHighlights()
			return
		end
		local themeAccent = GetTheme().Accent
		for plr in pairs(highlightsCache) do
			if not plr or not plr.Parent or not plr.Character or excludedPlayers[plr] or (not espShowTeammates and IsTeammate(plr)) then
				removePlayerHighlight(plr)
			end
		end
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= player and plr.Character then
				local allowTeam = espShowTeammates or not IsTeammate(plr)
				if not excludedPlayers[plr] and allowTeam then
					local existing = highlightsCache[plr]
					if not existing or not existing.Parent then
						pcall(function()
							local hl = Instance.new("Highlight")
							hl.Name = "AssetHighlight"
							hl.FillColor = themeAccent
							hl.OutlineColor = Color3.fromRGB(255, 255, 255)
							hl.FillTransparency = 0.45
							hl.OutlineTransparency = 0.1
							hl.Adornee = plr.Character
							hl.Parent = ScreenGui
							highlightsCache[plr] = hl
						end)
					else
						if existing.Adornee ~= plr.Character then existing.Adornee = plr.Character end
						if existing.FillColor ~= themeAccent then existing.FillColor = themeAccent end
					end
				else
					removePlayerHighlight(plr)
				end
			else
				removePlayerHighlight(plr)
			end
		end
	end
	updateAllAdornments = function()
		local espOn = (Config.ESPEnabled == true)
		local barsOn = (Config.ESPHealthBars ~= false)
		if not espOn and not barsOn then
			if next(adornmentsCache) ~= nil then clearAllAdornments() end
			return
		end
		local accentCol = GetTheme().Accent
		for plr in pairs(adornmentsCache) do
			if not plr or not plr.Parent or excludedPlayers[plr] then removePlayerAdornments(plr) end
		end
		local showBars = (Config.ESPHealthBars ~= false)
		for _, plr in ipairs(Players:GetPlayers()) do
			local allowTeam = espShowTeammates or not IsTeammate(plr)
			if plr ~= LocalPlayer and not excludedPlayers[plr] and allowTeam then
				local char = plr.Character
				local root = char and (char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart)
				local hum = char and char:FindFirstChildOfClass("Humanoid")
				if char and root and hum and hum.Health > 0 then
					local pair = adornmentsCache[plr]
					if not pair then
						local inner = Instance.new("BoxHandleAdornment")
						inner.AlwaysOnTop = true inner.ZIndex = 10
						inner.Transparency = 0.35 inner.Color3 = accentCol inner.Name = "AssetAdornment"
						inner.Size = V3_ESP_BOX inner.CFrame = CF_ESP_OFFSET inner.Parent = ScreenGui

						local outline = Instance.new("BoxHandleAdornment")
						outline.AlwaysOnTop = true outline.ZIndex = 9
						outline.Transparency = 0.75 outline.Color3 = Color3.fromRGB(0, 0, 0) outline.Name = "AssetOutline"
						outline.Size = V3_ESP_OUTLINE outline.CFrame = CF_ESP_OFFSET outline.Parent = ScreenGui

						local healthBg = Instance.new("BoxHandleAdornment")
						healthBg.AlwaysOnTop = true healthBg.ZIndex = 11
						healthBg.Transparency = 0.5 healthBg.Color3 = Color3.fromRGB(15, 15, 20)
						healthBg.Size = Vector3.new(0.32, 5.2, 0.32) healthBg.CFrame = CFrame.new(-2.6, 0, 0)
						healthBg.Parent = ScreenGui

						local healthBar = Instance.new("BoxHandleAdornment")
						healthBar.AlwaysOnTop = true healthBar.ZIndex = 12
						healthBar.Transparency = 0.1 healthBar.Color3 = Color3.fromRGB(46, 204, 113)
						healthBar.Size = Vector3.new(0.24, 5.0, 0.24) healthBar.CFrame = CFrame.new(-2.6, 0, 0)
						healthBar.Parent = ScreenGui

						local shieldBg = Instance.new("BoxHandleAdornment")
						shieldBg.AlwaysOnTop = true shieldBg.ZIndex = 11
						shieldBg.Transparency = 0.5 shieldBg.Color3 = Color3.fromRGB(15, 15, 20)
						shieldBg.Size = Vector3.new(0.32, 5.2, 0.32) shieldBg.CFrame = CFrame.new(2.6, 0, 0)
						shieldBg.Parent = ScreenGui

						local shieldBar = Instance.new("BoxHandleAdornment")
						shieldBar.AlwaysOnTop = true shieldBar.ZIndex = 12
						shieldBar.Transparency = 0.1 shieldBar.Color3 = Color3.fromRGB(52, 152, 219)
						shieldBar.Size = Vector3.new(0.24, 5.0, 0.24) shieldBar.CFrame = CFrame.new(2.6, 0, 0)
						shieldBar.Parent = ScreenGui

						pair = {
							inner = inner, outline = outline,
							healthBar = healthBar, healthBg = healthBg,
							shieldBar = shieldBar, shieldBg = shieldBg
						}
						adornmentsCache[plr] = pair
					end

					pair.inner.Visible = espOn
					pair.outline.Visible = espOn
					if espOn then
						if pair.inner.Adornee ~= root then
							pair.inner.Adornee = root
							pair.outline.Adornee = root
						end
						if pair.inner.Color3 ~= accentCol then pair.inner.Color3 = accentCol end
					end

					local hp, maxHp, shield, maxShield = GetPlayerHealthAndShield(char, hum)
					if barsOn then
						local cam = workspace.CurrentCamera
						local camPos = cam and cam.CFrame.Position
						local dist = camPos and (camPos - root.Position).Magnitude or 40
						-- Distance-scaled thickness: expands as distance increases so bar never becomes a 1px invisible sliver!
						local barThick = math.clamp(0.48 + (dist * 0.0055), 0.48, 3.2)
						local bgThick = barThick + 0.35
						local xOffsetLeft = -2.5 - (dist * 0.004)
						local xOffsetRight = 2.5 + (dist * 0.004)
						local hpPct = math.clamp(hp / maxHp, 0, 1)
						local barH = math.max(0.22, 5.0 * hpPct)

						pair.healthBg.Visible = true
						pair.healthBar.Visible = true
						if pair.healthBg.Adornee ~= root then
							pair.healthBg.Adornee = root
							pair.healthBar.Adornee = root
						end
						pair.healthBg.Size = Vector3.new(bgThick, 5.3, bgThick)
						pair.healthBg.CFrame = CFrame.new(xOffsetLeft, 0, 0)
						pair.healthBg.Transparency = 0.0
						pair.healthBg.Color3 = Color3.fromRGB(0, 0, 0)

						pair.healthBar.Size = Vector3.new(barThick, barH, barThick)
						pair.healthBar.CFrame = CFrame.new(xOffsetLeft, -2.5 + (barH * 0.5), 0)
						pair.healthBar.Transparency = 0.0
						if hpPct > 0.55 then
							pair.healthBar.Color3 = Color3.fromRGB(0, 255, 120) -- Neon Emerald
						elseif hpPct > 0.25 then
							pair.healthBar.Color3 = Color3.fromRGB(255, 215, 0) -- Neon Gold
						else
							pair.healthBar.Color3 = Color3.fromRGB(255, 30, 30) -- Neon Crimson
						end

						local showShield = (shield > 0)
						pair.shieldBg.Visible = showShield
						pair.shieldBar.Visible = showShield
						if showShield then
							if pair.shieldBg.Adornee ~= root then
								pair.shieldBg.Adornee = root
								pair.shieldBar.Adornee = root
							end
							local sPct = math.clamp(shield / maxShield, 0, 1)
							local sBarH = math.max(0.22, 5.0 * sPct)
							pair.shieldBg.Size = Vector3.new(bgThick, 5.3, bgThick)
							pair.shieldBg.CFrame = CFrame.new(xOffsetRight, 0, 0)
							pair.shieldBg.Transparency = 0.0
							pair.shieldBg.Color3 = Color3.fromRGB(0, 0, 0)

							pair.shieldBar.Size = Vector3.new(barThick, sBarH, barThick)
							pair.shieldBar.CFrame = CFrame.new(xOffsetRight, -2.5 + (sBarH * 0.5), 0)
							pair.shieldBar.Transparency = 0.0
							pair.shieldBar.Color3 = Color3.fromRGB(0, 215, 255) -- Electric Cyan
						end

						-- Overhead BillboardGui for constant, crisp readable health at any distance up to 1200 studs!
						if not pair.hpBillboard then
							local bb = Instance.new("BillboardGui")
							bb.Name = "TR_HealthBillboard"
							bb.AlwaysOnTop = true
							bb.Size = UDim2.new(0, 88, 0, 16)
							bb.StudsOffset = Vector3.new(0, 3.8, 0)
							bb.DistanceMax = 1200
							bb.Parent = ScreenGui
							local bgF = Instance.new("Frame")
							bgF.Size = UDim2.new(1, 0, 1, 0)
							bgF.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
							bgF.BackgroundTransparency = 0.2
							bgF.BorderSizePixel = 0
							bgF.Parent = bb
							AddCorner(bgF, 4)
							local hpFill = Instance.new("Frame")
							hpFill.Size = UDim2.new(1, 0, 1, 0)
							hpFill.BackgroundColor3 = Color3.fromRGB(0, 255, 120)
							hpFill.BorderSizePixel = 0
							hpFill.Parent = bgF
							AddCorner(hpFill, 4)
							local txt = Instance.new("TextLabel")
							txt.Size = UDim2.new(1, 0, 1, 0)
							txt.BackgroundTransparency = 1
							txt.Font = Enum.Font.GothamBold
							txt.TextSize = 11
							txt.TextColor3 = Color3.fromRGB(255, 255, 255)
							txt.Parent = bgF
							pair.hpBillboard = bb
							pair.hpFill = hpFill
							pair.hpText = txt
						end
						if pair.hpBillboard.Adornee ~= root then
							pair.hpBillboard.Adornee = root
						end
						pair.hpBillboard.Enabled = true
						pair.hpFill.Size = UDim2.new(hpPct, 0, 1, 0)
						if hpPct > 0.55 then
							pair.hpFill.BackgroundColor3 = Color3.fromRGB(0, 255, 120)
						elseif hpPct > 0.25 then
							pair.hpFill.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
						else
							pair.hpFill.BackgroundColor3 = Color3.fromRGB(255, 30, 30)
						end
						local sValText = (shield > 0) and string.format(" | %d S", math.floor(shield + 0.5)) or ""
						pair.hpText.Text = string.format("%d HP%s", math.floor(hp + 0.5), sValText)
					else
						pair.healthBg.Visible = false
						pair.healthBar.Visible = false
						pair.shieldBg.Visible = false
						pair.shieldBar.Visible = false
						if pair.hpBillboard then
							pair.hpBillboard.Enabled = false
						end
					end
				else
					if adornmentsCache[plr] then removePlayerAdornments(plr) end
				end
			else
				if adornmentsCache[plr] then removePlayerAdornments(plr) end
			end
		end
	end findBestTarget = function()
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
	-- Section 1: Dual Aimbot Engines (Normal [Q] vs Target Player [T]) & Head-Locked Auto Shoot [Z]
	CreateSectionHeader(Tab7_Visuals, "1. Normal Aimbot [Q] & 2. Target Player Aimbot [T] (Mutually Exclusive)", 1)
	local AimbotEngineCard = CreateCard(Tab7_Visuals, 94, 2)
	local aimbotToggleBtn = Instance.new("TextButton", AimbotEngineCard)
	aimbotToggleBtn.Size = UDim2.new(0.5, -14, 0, 34) aimbotToggleBtn.Position = UDim2.new(0, 10, 0, 10)
	aimbotToggleBtn.Font = Enum.Font.GothamBold aimbotToggleBtn.TextSize = 12
	aimbotToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255) AddCorner(aimbotToggleBtn, 6)
	aimbotStatusLabel = Instance.new("TextLabel", AimbotEngineCard)
	aimbotStatusLabel.Size = UDim2.new(0.5, -14, 0, 34)
	aimbotStatusLabel.Position = UDim2.new(0.5, 4, 0, 10) aimbotStatusLabel.BackgroundTransparency = 0.15
	aimbotStatusLabel.Font = Enum.Font.GothamSemibold aimbotStatusLabel.TextSize = 12
	aimbotStatusLabel.Text = "Status: Idle"
	RegisterThemeObject(aimbotStatusLabel, "BackgroundColor3", "PanelBg")
	RegisterThemeObject(aimbotStatusLabel, "TextColor3", "TextPrimary") AddCorner(aimbotStatusLabel, 6)
	local aimKeyBindLabel = MakeLabel(AimbotEngineCard, UDim2.new(0.38, -10, 0, 30), UDim2.new(0, 10, 0, 52), "Normal Aim Key:", Enum.Font.GothamSemibold, 12, "TextPrimary", Enum.TextXAlignment.Left)
	aimKeyBindLabel.TextTruncate = Enum.TextTruncate.AtEnd
	local aimbotKeyAssignBtn = MakeButton(AimbotEngineCard, UDim2.new(0.36, -6, 0, 30), UDim2.new(0.38, 4, 0, 52), "Bind Key: [Q]", "PanelBg", 11)
	local aimbotKeyDeleteBtn = Instance.new("TextButton", AimbotEngineCard)
	aimbotKeyDeleteBtn.Size = UDim2.new(0.26, -14, 0, 30)
	aimbotKeyDeleteBtn.Position = UDim2.new(0.74, 4, 0, 52)
	aimbotKeyDeleteBtn.BackgroundColor3 = Color3.fromRGB(165, 38, 55)
	aimbotKeyDeleteBtn.Font = Enum.Font.GothamBold aimbotKeyDeleteBtn.TextSize = 11
	aimbotKeyDeleteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	aimbotKeyDeleteBtn.Text = E.Trash .. " Delete" AddCorner(aimbotKeyDeleteBtn, 6)

	-- Card 2: Target Specific Player Aimbot (Locks ONLY onto Selected Player)
	local TargetAimbotCard = CreateCard(Tab7_Visuals, 94, 3)
	local targetAimbotToggleBtn = Instance.new("TextButton", TargetAimbotCard)
	targetAimbotToggleBtn.Size = UDim2.new(0.5, -14, 0, 34) targetAimbotToggleBtn.Position = UDim2.new(0, 10, 0, 10)
	targetAimbotToggleBtn.Font = Enum.Font.GothamBold targetAimbotToggleBtn.TextSize = 12
	targetAimbotToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255) AddCorner(targetAimbotToggleBtn, 6)
	local targetSelectBtn = MakeButton(TargetAimbotCard, UDim2.new(0.5, -14, 0, 34), UDim2.new(0.5, 4, 0, 10), "Target: None [Select]", "AccentDark", 11)
	local tAimKeyLabel = MakeLabel(TargetAimbotCard, UDim2.new(0.38, -10, 0, 30), UDim2.new(0, 10, 0, 52), "Target Aim Key:", Enum.Font.GothamSemibold, 12, "TextPrimary", Enum.TextXAlignment.Left)
	tAimKeyLabel.TextTruncate = Enum.TextTruncate.AtEnd
	local targetAimKeyAssignBtn = MakeButton(TargetAimbotCard, UDim2.new(0.36, -6, 0, 30), UDim2.new(0.38, 4, 0, 52), "Bind Key: [T]", "PanelBg", 11)
	local targetAimKeyDeleteBtn = Instance.new("TextButton", TargetAimbotCard)
	targetAimKeyDeleteBtn.Size = UDim2.new(0.26, -14, 0, 30)
	targetAimKeyDeleteBtn.Position = UDim2.new(0.74, 4, 0, 52)
	targetAimKeyDeleteBtn.BackgroundColor3 = Color3.fromRGB(165, 38, 55)
	targetAimKeyDeleteBtn.Font = Enum.Font.GothamBold targetAimKeyDeleteBtn.TextSize = 11
	targetAimKeyDeleteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	targetAimKeyDeleteBtn.Text = E.Trash .. " Delete" AddCorner(targetAimKeyDeleteBtn, 6)

	local targetListFrame = Instance.new("Frame", TargetAimbotCard)
	targetListFrame.Size = UDim2.new(1, -20, 0, 146)
	targetListFrame.Position = UDim2.new(0, 10, 0, 92)
	targetListFrame.BackgroundTransparency = 0.1
	targetListFrame.BorderSizePixel = 0
	targetListFrame.Visible = false
	RegisterThemeObject(targetListFrame, "BackgroundColor3", "PanelBg")
	AddCorner(targetListFrame, 8)
	local targetScrollList = Instance.new("ScrollingFrame", targetListFrame)
	targetScrollList.Size = UDim2.new(1, -12, 1, -12)
	targetScrollList.Position = UDim2.new(0, 6, 0, 6)
	targetScrollList.BackgroundTransparency = 1
	targetScrollList.BorderSizePixel = 0
	targetScrollList.CanvasSize = UDim2.new(0, 0, 0, 0)
	targetScrollList.ScrollBarThickness = 4
	RegisterThemeObject(targetScrollList, "ScrollBarImageColor3", "Accent")
	Instance.new("UIListLayout", targetScrollList).Padding = UDim.new(0, 5)

	-- Card 3: Auto Shoot (Fires ONLY when locked onto visible Player Head, stops behind walls)
	local AutoShootCard = CreateCard(Tab7_Visuals, 94, 4)
	local autoShootToggleBtn = Instance.new("TextButton", AutoShootCard)
	autoShootToggleBtn.Size = UDim2.new(0.5, -14, 0, 34) autoShootToggleBtn.Position = UDim2.new(0, 10, 0, 10)
	autoShootToggleBtn.Font = Enum.Font.GothamBold autoShootToggleBtn.TextSize = 12
	autoShootToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255) AddCorner(autoShootToggleBtn, 6)
	autoShootStatusLbl = Instance.new("TextLabel", AutoShootCard)
	autoShootStatusLbl.Size = UDim2.new(0.5, -14, 0, 34)
	autoShootStatusLbl.Position = UDim2.new(0.5, 4, 0, 10) autoShootStatusLbl.BackgroundTransparency = 0.15
	autoShootStatusLbl.Font = Enum.Font.GothamSemibold autoShootStatusLbl.TextSize = 11
	autoShootStatusLbl.Text = "Auto Shoot: OFF"
	RegisterThemeObject(autoShootStatusLbl, "BackgroundColor3", "PanelBg")
	RegisterThemeObject(autoShootStatusLbl, "TextColor3", "TextPrimary") AddCorner(autoShootStatusLbl, 6)
	local asKeyLabel = MakeLabel(AutoShootCard, UDim2.new(0.38, -10, 0, 30), UDim2.new(0, 10, 0, 52), "Auto Shoot Key:", Enum.Font.GothamSemibold, 12, "TextPrimary", Enum.TextXAlignment.Left)
	asKeyLabel.TextTruncate = Enum.TextTruncate.AtEnd
	local autoShootKeyAssignBtn = MakeButton(AutoShootCard, UDim2.new(0.36, -6, 0, 30), UDim2.new(0.38, 4, 0, 52), "Bind Key: [Z]", "PanelBg", 11)
	local autoShootKeyDeleteBtn = Instance.new("TextButton", AutoShootCard)
	autoShootKeyDeleteBtn.Size = UDim2.new(0.26, -14, 0, 30)
	autoShootKeyDeleteBtn.Position = UDim2.new(0.74, 4, 0, 52)
	autoShootKeyDeleteBtn.BackgroundColor3 = Color3.fromRGB(165, 38, 55)
	autoShootKeyDeleteBtn.Font = Enum.Font.GothamBold autoShootKeyDeleteBtn.TextSize = 11
	autoShootKeyDeleteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	autoShootKeyDeleteBtn.Text = E.Trash .. " Delete" AddCorner(autoShootKeyDeleteBtn, 6)

	-- Slider for Triggerbot Fire Rate & Burst Delay (20ms to 500ms)
	CreateSlider(Tab7_Visuals, "Triggerbot Fire Rate / Burst Delay (ms)", 20, 500, tonumber(Config.AutoShootDelayMs) or 45, 5, function(val)
		Config.AutoShootDelayMs = val
		savedConfig.Settings.AutoShootDelayMs = val
		SaveConfig(false)
	end)

	CreateToggle(Tab7_Visuals, "Aggressive Strong Lock Mode (Instant Snap + Velocity Lead)", strongLock, 6, function(state)
		strongLock = state Config.StrongLock = state if not strongLock then currentTarget = nil end
		SaveConfig(false) end)
	CreateToggle(Tab7_Visuals, "Raycast Wallcheck (Stop Aim & Auto-Shoot Behind Walls)", wallcheckEnabled, 7, function(state)
		wallcheckEnabled = state Config.WallcheckEnabled = state SaveConfig(false) end)
	CreateToggle(Tab7_Visuals, "Only Aim at Enemies (Ignore Teammates in Normal Aimbot)", aimbotTeamCheck, 8, function(state)
		aimbotTeamCheck = state Config.AimbotTeamCheck = state
		if state and currentTarget and IsTeammate(currentTarget) then currentTarget = nil end SaveConfig(false)
	end)
	CreateToggle(Tab7_Visuals, "Show Aimbot FOV Circle (Turn OFF for Full-Screen Aimbot)", fovCircleEnabled, 9, function(state)
		fovCircleEnabled = state Config.AimbotFOVCircleEnabled = state currentTarget = nil
		SyncAimbotFovCircleVisibility() SaveConfig(false) end)
	-- Neat V95 CreateSlider for Aimbot FOV Circle Radius
	local FovSliderObj local fovBox
	FovSliderObj = CreateSlider(Tab7_Visuals, "Aimbot FOV Circle Radius (px)", 20, 800, FOV_RADIUS, 10, function(val)
		FOV_RADIUS = val Config.AimbotFOVRadius = val if fovBox then fovBox.Text = tostring(val) end
		SyncAimbotFovCircleVisibility() SaveConfig(false) end)
	-- Target Part, Manual FOV Input & Player Exclusion Row Card
	local AimbotExtraCard = CreateCard(Tab7_Visuals, 48, 11)
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
	Instance.new("UIListLayout", excludeList).Padding = UDim.new(0, 5)

	local function RefreshAimbotVisuals()
		local k = Config.AimbotKeybind or "Q"
		aimbotKeyAssignBtn.Text = "Bind Key: [" .. k .. "]"
		aimbotToggleBtn.Text = "Normal Aimbot [" .. k .. "]: " .. (aimbotEnabled and "ON" or "OFF")
		aimbotToggleBtn.BackgroundColor3 = aimbotEnabled and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(185, 52, 52)

		local tk = Config.TargetAimbotKeybind or "T"
		targetAimKeyAssignBtn.Text = "Bind Key: [" .. tk .. "]"
		targetAimbotToggleBtn.Text = "Target Aimbot [" .. tk .. "]: " .. (targetAimbotEnabled and "ON" or "OFF")
		targetAimbotToggleBtn.BackgroundColor3 = targetAimbotEnabled and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(185, 52, 52)
		if specificTargetPlayer and specificTargetPlayer.Parent then
			targetSelectBtn.Text = "Target: " .. tostring(specificTargetPlayer.DisplayName) .. " [List]"
		else
			specificTargetPlayer = nil
			targetSelectBtn.Text = "Target: None [Select]"
		end

		local ask = Config.AutoShootKeybind or "Z"
		autoShootKeyAssignBtn.Text = "Bind Key: [" .. ask .. "]"
		autoShootToggleBtn.Text = "Auto Shoot [" .. ask .. "]: " .. (autoShootEnabled and "ON" or "OFF")
		autoShootToggleBtn.BackgroundColor3 = autoShootEnabled and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(185, 52, 52)
		if not autoShootEnabled then
			StopAutoShootFiring()
			if autoShootStatusLbl then autoShootStatusLbl.Text = "Auto Shoot: OFF" end
		elseif not (aimbotEnabled or targetAimbotEnabled) then
			if autoShootStatusLbl then autoShootStatusLbl.Text = "Auto Shoot: Ready (Wait Lock)" end
		end

		aimPartBtn.Text = (aimPartName == "Head") and "Aim Part: Head" or "Aim Part: Body"
		SyncAimbotFovCircleVisibility()
	end
	table.insert(ThemeObjects.CustomCallbacks, RefreshAimbotVisuals)

	local function rebuildTargetSelectList()
		for _, ch in ipairs(targetScrollList:GetChildren()) do
			if ch:IsA("Frame") or ch:IsA("TextButton") then ch:Destroy() end
		end
		local theme, totalH = GetTheme(), 0
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= LocalPlayer then
				local row = Instance.new("Frame")
				row.Size = UDim2.new(1, -6, 0, 32)
				row.BackgroundTransparency = 0.1
				row.BorderSizePixel = 0
				local isSel = (specificTargetPlayer == plr)
				row.BackgroundColor3 = isSel and theme.Accent or theme.CardBg
				row.Parent = targetScrollList
				AddCorner(row, 6)

				local av = Instance.new("ImageLabel")
				av.Size = UDim2.new(0, 24, 0, 24)
				av.Position = UDim2.new(0, 6, 0.5, -12)
				av.BackgroundTransparency = 0.4
				av.BorderSizePixel = 0
				av.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(plr.UserId) .. "&w=48&h=48"
				av.Parent = row
				AddCorner(av, 5)

				local lbl = MakeLabel(row, UDim2.new(1, -40, 1, 0), UDim2.new(0, 36, 0, 0), (isSel and "[LOCKED] " or "") .. tostring(plr.DisplayName) .. " (@" .. tostring(plr.Name) .. ")", Enum.Font.GothamBold, 11, "TextPrimary", Enum.TextXAlignment.Left)
				lbl.TextTruncate = Enum.TextTruncate.AtEnd

				local cBtn = Instance.new("TextButton")
				cBtn.Size = UDim2.new(1, 0, 1, 0)
				cBtn.BackgroundTransparency = 1
				cBtn.Text = ""
				cBtn.Parent = row
				cBtn.MouseButton1Click:Connect(function()
					if specificTargetPlayer == plr then
						specificTargetPlayer = nil
					else
						specificTargetPlayer = plr
					end
					currentTarget = nil
					RefreshAimbotVisuals()
					rebuildTargetSelectList()
				end)
				totalH = totalH + 37
			end
		end
		targetScrollList.CanvasSize = UDim2.new(0, 0, 0, totalH)
	end
	genv._TR_RefreshTargetAimbotList = rebuildTargetSelectList
	table.insert(ThemeObjects.CustomCallbacks, function()
		if targetListFrame.Visible then rebuildTargetSelectList() end
	end)

	targetSelectBtn.MouseButton1Click:Connect(function()
		targetListFrame.Visible = not targetListFrame.Visible
		TargetAimbotCard.Size = targetListFrame.Visible and UDim2.new(1, 0, 0, 248) or UDim2.new(1, 0, 0, 94)
		if targetListFrame.Visible then rebuildTargetSelectList() end
	end)

	updateExcludeCount = function() local c = 0 for _ in pairs(excludedPlayers) do c = c + 1 end
		excludeBtn.Text = "Exclude Players: " .. tostring(c) end
	rebuildExcludeList = function()
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

	-- Mutual Exclusivity: Normal Aimbot [Q] vs Target Player Aimbot [T]
	toggleAimbot = function()
		aimbotEnabled = not aimbotEnabled
		Config.AimbotEnabled = aimbotEnabled
		savedConfig.Settings.AimbotEnabled = aimbotEnabled
		if aimbotEnabled and targetAimbotEnabled then
			targetAimbotEnabled = false
			Config.TargetAimbotEnabled = false
			savedConfig.Settings.TargetAimbotEnabled = false
		end
		currentTarget = nil
		if not (aimbotEnabled or targetAimbotEnabled) then
			StopAutoShootFiring()
			if aimbotStatusLabel then aimbotStatusLabel.Text = "Status: Idle" end
		end
		RefreshAimbotVisuals()
		SaveConfig(false)
	end

	toggleTargetAimbot = function()
		targetAimbotEnabled = not targetAimbotEnabled
		Config.TargetAimbotEnabled = targetAimbotEnabled
		savedConfig.Settings.TargetAimbotEnabled = targetAimbotEnabled
		if targetAimbotEnabled and aimbotEnabled then
			aimbotEnabled = false
			Config.AimbotEnabled = false
			savedConfig.Settings.AimbotEnabled = false
		end
		currentTarget = nil
		if not (aimbotEnabled or targetAimbotEnabled) then
			StopAutoShootFiring()
			if aimbotStatusLabel then aimbotStatusLabel.Text = "Status: Idle" end
		end
		RefreshAimbotVisuals()
		SaveConfig(false)
	end

	toggleAutoShoot = function()
		autoShootEnabled = not autoShootEnabled
		Config.AutoShootEnabled = autoShootEnabled
		savedConfig.Settings.AutoShootEnabled = autoShootEnabled
		if not autoShootEnabled then
			StopAutoShootFiring()
		end
		RefreshAimbotVisuals()
		SaveConfig(false)
	end

	aimbotToggleBtn.MouseButton1Click:Connect(toggleAimbot)
	targetAimbotToggleBtn.MouseButton1Click:Connect(toggleTargetAimbot)
	autoShootToggleBtn.MouseButton1Click:Connect(toggleAutoShoot)

	aimPartBtn.MouseButton1Click:Connect(function()
		aimPartName = (aimPartName == "Head") and "HumanoidRootPart" or "Head" Config.AimPartName = aimPartName
		RefreshAimbotVisuals() SaveConfig(false) end)

	aimbotKeyAssignBtn.MouseButton1Click:Connect(function()
		aimbotKeyAssignBtn.Text = "[Key / Del]" ActiveKeybindCaptureCallback = function(k)
			TryAssignUniqueKeybind(k, "Aimbot", function(val) Config.AimbotKeybind = val; savedConfig.Settings.AimbotKeybind = val end, RefreshAimbotVisuals, aimbotKeyAssignBtn) end end)
	aimbotKeyDeleteBtn.MouseButton1Click:Connect(function() Config.AimbotKeybind = "None"; savedConfig.Settings.AimbotKeybind = "None"
		ActiveKeybindCaptureCallback = nil RefreshAimbotVisuals() SaveConfig(false) end)

	targetAimKeyAssignBtn.MouseButton1Click:Connect(function()
		targetAimKeyAssignBtn.Text = "[Key / Del]" ActiveKeybindCaptureCallback = function(k)
			TryAssignUniqueKeybind(k, "TargetAimbot", function(val) Config.TargetAimbotKeybind = val; savedConfig.Settings.TargetAimbotKeybind = val end, RefreshAimbotVisuals, targetAimKeyAssignBtn) end end)
	targetAimKeyDeleteBtn.MouseButton1Click:Connect(function() Config.TargetAimbotKeybind = "None"; savedConfig.Settings.TargetAimbotKeybind = "None"
		ActiveKeybindCaptureCallback = nil RefreshAimbotVisuals() SaveConfig(false) end)

	autoShootKeyAssignBtn.MouseButton1Click:Connect(function()
		autoShootKeyAssignBtn.Text = "[Key / Del]" ActiveKeybindCaptureCallback = function(k)
			TryAssignUniqueKeybind(k, "AutoShoot", function(val) Config.AutoShootKeybind = val; savedConfig.Settings.AutoShootKeybind = val end, RefreshAimbotVisuals, autoShootKeyAssignBtn) end end)
	autoShootKeyDeleteBtn.MouseButton1Click:Connect(function() Config.AutoShootKeybind = "None"; savedConfig.Settings.AutoShootKeybind = "None"
		ActiveKeybindCaptureCallback = nil RefreshAimbotVisuals() SaveConfig(false) end)
	fovBox.FocusLost:Connect(function() local v = tonumber(fovBox.Text) if v then
			FOV_RADIUS = math.clamp(math.floor(v + 0.5), 20, 800) Config.AimbotFOVRadius = FOV_RADIUS
			if FovSliderObj then FovSliderObj.SetValue(FOV_RADIUS) end SyncAimbotFovCircleVisibility()
			SaveConfig(false) end fovBox.Text = tostring(FOV_RADIUS) end)
	excludeBtn.MouseButton1Click:Connect(function() excludeFrame.Visible = not excludeFrame.Visible
		AimbotExtraCard.Size = excludeFrame.Visible and UDim2.new(1, 0, 0, 186) or UDim2.new(1, 0, 0, 48)
		if excludeFrame.Visible then rebuildExcludeList() end end) RefreshAimbotVisuals()
	-- Section 2: Player ESP Highlights, 3D Boxes & Health/Shield Bars
	CreateSectionHeader(Tab7_Visuals, "Player ESP (Chams, 3D Boxes & Health/Shield Bars)", 12)
	CreateToggle(Tab7_Visuals, "Player Highlight & 3D Box ESP (Chams + Hitbox Boxes)", Config.ESPEnabled, 13, function(state)
		Config.ESPEnabled = state
		if not state then
			clearAllHighlights()
			if not (Config.ESPHealthBars ~= false) then clearAllAdornments() else updateAllAdornments() end
		else
			updateAllAdornments()
		end
		RefreshESPHighlights()
		SaveConfig(false)
	end)
	CreateToggle(Tab7_Visuals, "Player Health & Shield Bars (Visible At Any Distance | Works Without ESP)", Config.ESPHealthBars ~= false, 14, function(state)
		Config.ESPHealthBars = state
		if not state and not Config.ESPEnabled then
			clearAllAdornments()
		else
			updateAllAdornments()
		end
		SaveConfig(false)
	end)
	CreateToggle(Tab7_Visuals, "Turn On ESP for Teammates (Show Teammate Highlights & Boxes)", espShowTeammates, 15, function(state)
		espShowTeammates = state Config.ESPShowTeammates = state RefreshESPHighlights() updateAllAdornments()
		SaveConfig(false) end)
	-- Section 3: Camera Field of View & Perspective
	CreateSectionHeader(Tab7_Visuals, "Camera Field of View & Perspective", 16)
	CreateSlider(Tab7_Visuals, "Camera Field of View (FOV)", 30, 120, Config.FOV, 17, function(val)
		Config.FOV = val pcall(function() workspace.CurrentCamera.FieldOfView = val end) SaveConfig(false) end)
	local CamModeCard = CreateCard(Tab7_Visuals, 50, 18) local CamModeList = Instance.new("UIListLayout")
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
	CreateSectionHeader(Tab7_Visuals, "Lighting, Fullbright & Time Presets", 19)
	CreateToggle(Tab7_Visuals, "Fullbright Lighting Mode (No Shadows + Max Illumination)", Config.FullbrightEnabled, 20, function(state)
		Config.FullbrightEnabled = state if not state then pcall(function()
				Lighting.Brightness = DefaultLighting.Brightness
				Lighting.GlobalShadows = DefaultLighting.GlobalShadows
				Lighting.OutdoorAmbient = DefaultLighting.OutdoorAmbient end) end SaveConfig(false) end)
	local TimeCard = CreateCard(Tab7_Visuals, 50, 21) local TimeList = Instance.new("UIListLayout")
	TimeList.FillDirection = Enum.FillDirection.Horizontal
	TimeList.HorizontalAlignment = Enum.HorizontalAlignment.Center
	TimeList.VerticalAlignment = Enum.VerticalAlignment.Center TimeList.Padding = UDim.new(0, 10)
	TimeList.Parent = TimeCard for _, preset in ipairs({ { Label = E.Sun .. " Day", Value = 14 },
		{ Label = E.Moon .. " Night", Value = 0 }, { Label = E.Unlock .. " Unlock Time", Value = nil } }) do
		local PBtn = MakeButton(TimeCard, UDim2.new(0, 160, 0, 32), nil, preset.Label, "AccentDark", 12)
		PBtn.MouseButton1Click:Connect(function() Config.LockedTime = preset.Value if preset.Value ~= nil then
				pcall(function() Lighting.ClockTime = preset.Value end) else
				pcall(function() Lighting.ClockTime = DefaultLighting.ClockTime end) end SaveConfig(false) end) end
end SetupTab7()
--==============================================================================
-- 14. TAB 8: MULTI-TAB SCRIPT EXECUTOR
--==============================================================================
local RunningExecutorThreads = {}
local function SetupTab8() CreateSectionHeader(Tab8_Executor, "Multi-Tab Luau Script Executor", 1)
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
local EditorCard = CreateCard(Tab8_Executor, 240, 3)
EditorCard.ClipsDescendants = true

local CodeScroll = Instance.new("ScrollingFrame")
CodeScroll.Size = UDim2.new(1, -16, 1, -16)
CodeScroll.Position = UDim2.new(0, 8, 0, 8)
CodeScroll.BackgroundTransparency = 0.15
CodeScroll.BorderSizePixel = 0
CodeScroll.ScrollBarThickness = 6
CodeScroll.ScrollingEnabled = true
CodeScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
CodeScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
CodeScroll.ScrollingDirection = Enum.ScrollingDirection.Y
CodeScroll.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
CodeScroll.ScrollBarImageTransparency = 0.2
CodeScroll.ClipsDescendants = true
CodeScroll.Parent = EditorCard
RegisterThemeObject(CodeScroll, "BackgroundColor3", "PanelBg")
RegisterThemeObject(CodeScroll, "ScrollBarImageColor3", "Accent")
AddCorner(CodeScroll, 6)

local CodeBox = Instance.new("TextBox")
CodeBox.Size = UDim2.new(1, -12, 1, 0)
CodeBox.AutomaticSize = Enum.AutomaticSize.Y
CodeBox.Position = UDim2.new(0, 6, 0, 6)
CodeBox.BackgroundTransparency = 1
CodeBox.MultiLine = true
CodeBox.ClearTextOnFocus = false
CodeBox.TextWrapped = true
CodeBox.Font = Enum.Font.Code
CodeBox.TextSize = 13
CodeBox.TextXAlignment = Enum.TextXAlignment.Left
CodeBox.TextYAlignment = Enum.TextYAlignment.Top
CodeBox.PlaceholderText = "-- Paste or write your Luau script here..."
CodeBox.Text = ""
CodeBox.Parent = CodeScroll
RegisterThemeObject(CodeBox, "TextColor3", "TextPrimary")

local function UpdateCodeScrollCanvas()
	local minHeight = math.max(0, CodeScroll.AbsoluteSize.Y - 12)
	local textH = math.max(minHeight, CodeBox.TextBounds.Y + 24)
	CodeScroll.CanvasSize = UDim2.new(0, 0, 0, textH)
	CodeBox.Size = UDim2.new(1, -12, 0, textH)
end
CodeBox:GetPropertyChangedSignal("Text"):Connect(UpdateCodeScrollCanvas)
CodeBox:GetPropertyChangedSignal("TextBounds"):Connect(UpdateCodeScrollCanvas)
CodeScroll:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateCodeScrollCanvas)

local function HandleCodeWheelScroll(input)
	if input.UserInputType == Enum.UserInputType.MouseWheel then
		local cur = CodeScroll.CanvasPosition.Y
		local maxScroll = math.max(0, CodeScroll.CanvasSize.Y.Offset - CodeScroll.AbsoluteSize.Y)
		local newY = math.clamp(cur - (input.Position.Z * 45), 0, maxScroll)
		CodeScroll.CanvasPosition = Vector2.new(0, newY)
	end
end
CodeBox.InputChanged:Connect(HandleCodeWheelScroll)
CodeScroll.InputChanged:Connect(HandleCodeWheelScroll)
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
AddCorner(TerminateBtn, 6) local UpdatingCodeBox = false
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
	RunningExecutorThreads = {} end) RebuildExecutorTabs() end SetupTab8()
--==============================================================================
-- 14B. TAB 9: HACKER DETECTOR (MIN SPEED 100 S/S | DELAY-DRIVEN LIST UPDATE | SYNCED SPECTATE)
-- Tier 1: Hackers (Top) | Tier 2: Abnormal Speed Hackers (2nd) | Tier 3: Normal Players (3rd)
--==============================================================================
local function SetupTab9()
local listUpdateDelay = 5
local notificationsEnabled = true
local detectorEnabled = true
local DETECTOR_CONFIG = {
	MIN_DETECT_SPEED    = 100,
	EXTREME_HACK_SPEED  = 160,
	SPEED_MULTIPLIER    = 1.7,
	MAX_AIR_TIME        = 3.0,
	FLING_THRESHOLD     = 300,
	JUMP_MULTIPLIER     = 1.6,
	TELEPORT_DISTANCE   = 100,
	SAMPLE_INTERVAL     = 0.25,
	SAMPLE_COUNT        = 4,
	ANIM_SPEED          = 0.25,
	COLORS = {
		Clean     = Color3.fromRGB(50, 200, 80),
		Cheat     = Color3.fromRGB(255, 55, 55),
		Speed     = Color3.fromRGB(255, 155, 40),
		Warning   = Color3.fromRGB(255, 200, 50),
		Analyzing = Color3.fromRGB(255, 180, 50),
	}
}
local DETECTOR_ICONS = {
	username  = "rbxassetid://136485052187963",
	display   = "rbxassetid://108155244324878",
	studs     = "rbxassetid://121615540167909",
	normal    = "rbxassetid://115320390907184",
	analyzing = "rbxassetid://112148279212860",
	scripter  = "rbxassetid://125920361880643",
	off       = "rbxassetid://118026365011536",
	on        = "rbxassetid://110786993356448",
	logo      = "rbxassetid://121018724060431",
	players   = "rbxassetid://113726939624961",
}
local notifCooldowns = {}
local whitelistedPlayers = {}
local serverTeleporting = false
local playerCards = {}
local playerData = {}
local detectedPlayers = {}
local speedPlayers = {}

local function tweenDetectorObj(obj, props, duration, style, direction)
	return TweenService:Create(obj, TweenInfo.new(
		duration or DETECTOR_CONFIG.ANIM_SPEED,
		style or Enum.EasingStyle.Quad,
		direction or Enum.EasingDirection.Out
	), props)
end

GetPlayerDetectionState = function(plrName)
	if whitelistedPlayers[plrName] then return 4, "WHITELISTED", 90 end
	if detectedPlayers[plrName] then
		local cData = playerCards[plrName]
		local flags = cData and cData.flagsLbl and cData.flagsLbl.Text or ""
		local rank = GetHackRank and GetHackRank(flags, 1, cData and cData.lastSpeed or 0) or 1
		local tag = (flags ~= "") and flags or "HACKER"
		return 1, tag, rank
	end
	if speedPlayers[plrName] then
		local cData = playerCards[plrName]
		local flags = cData and cData.flagsLbl and cData.flagsLbl.Text or ""
		local rank = GetHackRank and GetHackRank(flags, 2, cData and cData.lastSpeed or 0) or 9
		return 2, "SPEED", rank
	end
	return 3, nil, 80
end

CreateSectionHeader(Tab9_Detector, "Hacker & Abnormal Speed Detector (Min Speed: 100 s/s | 1. Hackers | 2. Speed | 3. Normal)", 1)
local ControlsCard = CreateCard(Tab9_Detector, 0, 2)
ControlsCard.AutomaticSize = Enum.AutomaticSize.Y
local CtrlPad = Instance.new("UIPadding")
CtrlPad.PaddingTop = UDim.new(0, 8) CtrlPad.PaddingBottom = UDim.new(0, 8)
CtrlPad.PaddingLeft = UDim.new(0, 10) CtrlPad.PaddingRight = UDim.new(0, 10)
CtrlPad.Parent = ControlsCard
local CtrlLayout = Instance.new("UIListLayout")
CtrlLayout.Padding = UDim.new(0, 8)
CtrlLayout.SortOrder = Enum.SortOrder.LayoutOrder
CtrlLayout.Parent = ControlsCard

local TopStatsRow = Instance.new("Frame")
TopStatsRow.Size = UDim2.new(1, 0, 0, 24)
TopStatsRow.BackgroundTransparency = 1
TopStatsRow.LayoutOrder = 1
TopStatsRow.Parent = ControlsCard
local PlayerCountLabel = MakeLabel(TopStatsRow, UDim2.new(0.32, 0, 1, 0), UDim2.new(0, 0, 0, 0), "Players: 0", Enum.Font.GothamBold, 12, "TextPrimary", Enum.TextXAlignment.Left)
local DetectedCountLabel = MakeLabel(TopStatsRow, UDim2.new(0.68, 0, 1, 0), UDim2.new(0.32, 0, 0, 0), "Hackers: 0  |  Speed: 0", Enum.Font.GothamBold, 12, "TextSecondary", Enum.TextXAlignment.Right)

local BottomControlsRow = Instance.new("Frame")
BottomControlsRow.Size = UDim2.new(1, 0, 0, 30)
BottomControlsRow.BackgroundTransparency = 1
BottomControlsRow.LayoutOrder = 2
BottomControlsRow.Parent = ControlsCard
local BotListLayout = Instance.new("UIListLayout")
BotListLayout.FillDirection = Enum.FillDirection.Horizontal
BotListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
BotListLayout.Padding = UDim.new(0, 6)
BotListLayout.Parent = BottomControlsRow

local DetectorToggleBtn = MakeButton(BottomControlsRow, UDim2.new(0.32, -6, 0, 28), nil, "Detector [F4]: ON", nil, 11)
local NotifToggleBtn = MakeButton(BottomControlsRow, UDim2.new(0.20, -6, 0, 28), nil, "Alerts: ON", nil, 11)

local DelayFrame = Instance.new("Frame")
DelayFrame.Size = UDim2.new(0.28, -6, 0, 28)
DelayFrame.BackgroundTransparency = 1
DelayFrame.Parent = BottomControlsRow
local DelayMinus = MakeButton(DelayFrame, UDim2.new(0, 24, 1, 0), UDim2.new(0, 0, 0, 0), "-", "PanelBg", 13)
local DelayText = MakeLabel(DelayFrame, UDim2.new(1, -52, 1, 0), UDim2.new(0, 26, 0, 0), listUpdateDelay .. "s", Enum.Font.GothamBold, 11, "TextPrimary", Enum.TextXAlignment.Center)
local DelayPlus = MakeButton(DelayFrame, UDim2.new(0, 24, 1, 0), UDim2.new(1, -24, 0, 0), "+", "PanelBg", 13)

local UnviewBtn = Instance.new("TextButton")
UnviewBtn.Size = UDim2.new(0.20, 0, 0, 28)
UnviewBtn.BackgroundColor3 = Color3.fromRGB(185, 38, 58)
UnviewBtn.Font = Enum.Font.GothamBold
UnviewBtn.TextSize = 10
UnviewBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
UnviewBtn.Text = "UNVIEW"
UnviewBtn.Visible = false
UnviewBtn.Parent = BottomControlsRow
AddCorner(UnviewBtn, 6)

local ScannerContainer = Instance.new("Frame")
ScannerContainer.LayoutOrder = 3
ScannerContainer.Size = UDim2.new(1, 0, 0, 0)
ScannerContainer.AutomaticSize = Enum.AutomaticSize.Y
ScannerContainer.BackgroundTransparency = 1
ScannerContainer.Parent = Tab9_Detector
local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 6)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = ScannerContainer

local function RefreshDetectorControlVisuals()
	local theme = GetTheme()
	DetectorToggleBtn.Text = "Detector [F4]: " .. (detectorEnabled and "ON" or "OFF")
	DetectorToggleBtn.BackgroundColor3 = detectorEnabled and theme.Accent or theme.PanelBg
	NotifToggleBtn.Text = notificationsEnabled and "ON" or "OFF"
	NotifToggleBtn.BackgroundColor3 = notificationsEnabled and theme.Accent or theme.PanelBg
	UnviewBtn.Visible = (SpectatingTarget ~= nil)
end

local function ApplyCardThemeAndStatus(cardData)
	if not cardData or not cardData.card or not cardData.card.Parent then return end
	local theme = GetTheme()
	local pName = cardData.playerName
	local isBeingViewed = (SpectatingTarget ~= nil and SpectatingTarget.Name == pName)
	cardData.card.BackgroundColor3 = theme.CardBg
	cardData.avatarFrame.BackgroundColor3 = theme.PanelBg
	cardData.divider.BackgroundColor3 = theme.Stroke
	cardData.studLbl.TextColor3 = theme.TextSecondary
	cardData.wsLbl.TextColor3 = theme.TextSecondary
	cardData.viewBtn.BackgroundColor3 = isBeingViewed and theme.Accent or theme.PanelBg
	cardData.viewBtn.TextColor3 = isBeingViewed and Color3.fromRGB(255, 255, 255) or theme.TextPrimary
	cardData.viewBtn.Text = isBeingViewed and "UNVIEW" or "VIEW"
	cardData.tpBtn.BackgroundColor3 = theme.AccentDark
	cardData.tpBtn.TextColor3 = theme.TextPrimary
	cardData.copyBtn.BackgroundColor3 = theme.PanelBg
	cardData.copyBtn.TextColor3 = theme.TextPrimary
	if whitelistedPlayers[pName] then
		cardData.whitelistBtn.BackgroundColor3 = theme.Accent
		cardData.whitelistBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		cardData.cardStroke.Color = theme.Accent
		cardData.cardStroke.Transparency = 0.15
		cardData.statusBar.BackgroundColor3 = theme.Accent
		cardData.statusIcon.Image = DETECTOR_ICONS.normal
		cardData.statusLbl.Text = "WHITELISTED"
		cardData.statusLbl.TextColor3 = theme.Accent
		cardData.userLbl.TextColor3 = theme.Accent
		cardData.dispLbl.TextColor3 = theme.TextSecondary
		cardData.flagsLbl.Text = ""
	elseif cardData.stateTier == 1 then
		cardData.whitelistBtn.BackgroundColor3 = theme.PanelBg
		cardData.whitelistBtn.TextColor3 = theme.TextSecondary
		cardData.cardStroke.Color = DETECTOR_CONFIG.COLORS.Cheat
		cardData.cardStroke.Transparency = 0.15
		cardData.statusBar.BackgroundColor3 = DETECTOR_CONFIG.COLORS.Cheat
		cardData.statusIcon.Image = DETECTOR_ICONS.scripter
		cardData.statusLbl.Text = "HACKER DETECTED"
		cardData.statusLbl.TextColor3 = DETECTOR_CONFIG.COLORS.Cheat
		cardData.userLbl.TextColor3 = DETECTOR_CONFIG.COLORS.Cheat
		cardData.dispLbl.TextColor3 = Color3.fromRGB(230, 120, 120)
		cardData.flagsLbl.TextColor3 = DETECTOR_CONFIG.COLORS.Cheat
	elseif cardData.stateTier == 2 then
		cardData.whitelistBtn.BackgroundColor3 = theme.PanelBg
		cardData.whitelistBtn.TextColor3 = theme.TextSecondary
		cardData.cardStroke.Color = DETECTOR_CONFIG.COLORS.Speed
		cardData.cardStroke.Transparency = 0.2
		cardData.statusBar.BackgroundColor3 = DETECTOR_CONFIG.COLORS.Speed
		cardData.statusIcon.Image = DETECTOR_ICONS.scripter
		cardData.statusLbl.Text = "ABNORMAL SPEED (100+ S/S)"
		cardData.statusLbl.TextColor3 = DETECTOR_CONFIG.COLORS.Speed
		cardData.userLbl.TextColor3 = DETECTOR_CONFIG.COLORS.Speed
		cardData.dispLbl.TextColor3 = Color3.fromRGB(235, 185, 105)
		cardData.flagsLbl.TextColor3 = DETECTOR_CONFIG.COLORS.Speed
	elseif cardData.stateTier == 3 then
		cardData.whitelistBtn.BackgroundColor3 = theme.PanelBg
		cardData.whitelistBtn.TextColor3 = theme.TextSecondary
		cardData.cardStroke.Color = theme.Stroke
		cardData.cardStroke.Transparency = 0.6
		cardData.statusBar.BackgroundColor3 = DETECTOR_CONFIG.COLORS.Clean
		cardData.statusIcon.Image = DETECTOR_ICONS.normal
		cardData.statusLbl.Text = "Normal"
		cardData.statusLbl.TextColor3 = DETECTOR_CONFIG.COLORS.Clean
		cardData.userLbl.TextColor3 = theme.TextPrimary
		cardData.dispLbl.TextColor3 = theme.TextSecondary
		cardData.flagsLbl.Text = ""
	else
		cardData.whitelistBtn.BackgroundColor3 = theme.PanelBg
		cardData.whitelistBtn.TextColor3 = theme.TextSecondary
		cardData.cardStroke.Color = theme.Stroke
		cardData.cardStroke.Transparency = 0.6
		cardData.statusBar.BackgroundColor3 = DETECTOR_CONFIG.COLORS.Analyzing
		cardData.statusIcon.Image = DETECTOR_ICONS.analyzing
		cardData.statusLbl.Text = "Analyzing..."
		cardData.statusLbl.TextColor3 = DETECTOR_CONFIG.COLORS.Analyzing
		cardData.userLbl.TextColor3 = theme.TextPrimary
		cardData.dispLbl.TextColor3 = theme.TextSecondary
	end
end

local function RefreshAllDetectorThemes()
	RefreshDetectorControlVisuals()
	for _, cData in pairs(playerCards) do
		ApplyCardThemeAndStatus(cData)
	end
end
RefreshSpectateVisualsInDetector = RefreshAllDetectorThemes
table.insert(ThemeObjects.CustomCallbacks, RefreshAllDetectorThemes)

local function ToggleDetectorState()
	detectorEnabled = not detectorEnabled
	RefreshDetectorControlVisuals()
end
DetectorToggleBtn.MouseButton1Click:Connect(ToggleDetectorState)
NotifToggleBtn.MouseButton1Click:Connect(function()
	notificationsEnabled = not notificationsEnabled
	RefreshDetectorControlVisuals()
end)

local listUpdateElapsed = 0
DelayMinus.MouseButton1Click:Connect(function()
	if listUpdateDelay > 5 then
		listUpdateDelay = listUpdateDelay - 5
	else
		listUpdateDelay = math.max(1, listUpdateDelay - 1)
	end
	DelayText.Text = listUpdateDelay .. "s"
	listUpdateElapsed = 0
end)
DelayPlus.MouseButton1Click:Connect(function()
	if listUpdateDelay < 5 then
		listUpdateDelay = listUpdateDelay + 1
	else
		listUpdateDelay = math.min(60, listUpdateDelay + 5)
	end
	DelayText.Text = listUpdateDelay .. "s"
	listUpdateElapsed = 0
end)

local notifications
local function viewPlayer(playerName)
	local targetPlr = Players:FindFirstChild(playerName)
	if not targetPlr then
		if notifications then notifications:show("Spectate Failed", tostring(playerName) .. " is not in the server.", DETECTOR_CONFIG.COLORS.Warning, DETECTOR_ICONS.off) end
		return
	end
	if SpectatingTarget == targetPlr then
		SetSpectateTarget(nil)
		if notifications then notifications:show("Stopped Spectating", "Camera returned to you.", GetTheme().TextSecondary, DETECTOR_ICONS.normal) end
		return
	end
	local tChar = GetCharacterFromPlayer(targetPlr)
	if not tChar then
		if notifications then notifications:show("Spectate Failed", tostring(playerName) .. " has no active character.", DETECTOR_CONFIG.COLORS.Warning, DETECTOR_ICONS.off) end
		return
	end
	SetSpectateTarget(targetPlr)
	if notifications then notifications:show("Spectating Player", "Camera locked to " .. playerName .. ".", GetTheme().Accent, DETECTOR_ICONS.players) end
end

UnviewBtn.MouseButton1Click:Connect(function()
	SetSpectateTarget(nil)
	if notifications then notifications:show("Stopped Spectating", "Camera returned to you.", GetTheme().TextSecondary, DETECTOR_ICONS.normal) end
end)

local function scrollToPlayer(targetName)
	if not isMenuVisible then SetMenuVisible(true) end
	ActiveTabName = "Hacker Detector"
	for name, data in pairs(Tabs) do
		data.Page.Visible = (name == "Hacker Detector")
		local theme = GetTheme()
		data.Button.BackgroundColor3 = (name == "Hacker Detector") and theme.Accent or theme.CardBg
		data.Button.BackgroundTransparency = (name == "Hacker Detector") and 0.02 or 0.2
	end
	local targetCard = playerCards[targetName]
	if not targetCard or not targetCard.card then return end
	task.defer(function()
		local cFrame = targetCard.card
		local sFrame = Tab9_Detector
		local canvasOffset = (cFrame.AbsolutePosition.Y - sFrame.AbsolutePosition.Y) + sFrame.CanvasPosition.Y - 60
		local maxScroll = math.max(0, sFrame.AbsoluteCanvasSize.Y - sFrame.AbsoluteSize.Y)
		canvasOffset = math.clamp(canvasOffset, 0, maxScroll)
		tweenDetectorObj(sFrame, { CanvasPosition = Vector2.new(0, canvasOffset) }):Play()
		local theme = GetTheme()
		tweenDetectorObj(targetCard.cardStroke, { Color = theme.Accent, Transparency = 0 }):Play()
		task.delay(1.5, function()
			pcall(function() ApplyCardThemeAndStatus(targetCard) end)
		end)
	end)
end

local Notifications = {}
function Notifications.new(parent)
	local container = Instance.new("Frame")
	container.Name = "TR_DetectorNotifs"
	container.Size = UDim2.new(0, 320, 1, 0)
	container.Position = UDim2.new(1, -330, 0, 0)
	container.BackgroundTransparency = 1
	container.ZIndex = 100
	container.Parent = parent
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 8)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.VerticalAlignment = Enum.VerticalAlignment.Top
	layout.Parent = container
	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 60)
	padding.PaddingRight = UDim.new(0, 10)
	padding.Parent = container
	return {
		container = container,
		show = function(self, title, message, color, icon, playerName)
			if not notificationsEnabled or isClosingPermanently then return end
			local theme = GetTheme()
			color = color or DETECTOR_CONFIG.COLORS.Warning
			local notification = Instance.new("Frame")
			notification.Size = UDim2.new(1, 0, 0, 0)
			notification.BackgroundTransparency = 1
			notification.LayoutOrder = 100
			notification.Parent = container
			local bg = Instance.new("TextButton")
			bg.Size = UDim2.new(1, 0, 0, 64)
			bg.BackgroundColor3 = theme.MainBg
			bg.BorderSizePixel = 0
			bg.Text = ""
			bg.AutoButtonColor = false
			bg.Parent = notification
			AddCorner(bg, 10)
			RegisterThemeObject(bg, "BackgroundColor3", "MainBg")
			local stroke = Instance.new("UIStroke")
			stroke.Color = color
			stroke.Thickness = 1.8
			stroke.Transparency = 0.2
			stroke.Parent = bg
			local sidebar = Instance.new("Frame")
			sidebar.Size = UDim2.new(0, 4, 0.7, 0)
			sidebar.Position = UDim2.new(0, 8, 0.15, 0)
			sidebar.BackgroundColor3 = color
			sidebar.BorderSizePixel = 0
			sidebar.Parent = bg
			AddCorner(sidebar, 4)
			if icon then
				local iconImg = Instance.new("ImageLabel")
				iconImg.Size = UDim2.new(0, 22, 0, 22)
				iconImg.Position = UDim2.new(0, 18, 0, 8)
				iconImg.BackgroundTransparency = 1
				iconImg.Image = icon
				iconImg.ScaleType = Enum.ScaleType.Fit
				iconImg.ImageColor3 = color
				iconImg.Parent = bg
			end
			local titleLbl = Instance.new("TextLabel")
			titleLbl.Size = UDim2.new(1, -96, 0, 18)
			titleLbl.Position = UDim2.new(0, 46, 0, 8)
			titleLbl.BackgroundTransparency = 1
			titleLbl.Text = title
			titleLbl.TextColor3 = color
			titleLbl.TextSize = 13
			titleLbl.Font = Enum.Font.GothamBold
			titleLbl.TextXAlignment = Enum.TextXAlignment.Left
			titleLbl.TextTruncate = Enum.TextTruncate.AtEnd
			titleLbl.Parent = bg
			local msgLbl = MakeLabel(bg, UDim2.new(1, -52, 0, 28), UDim2.new(0, 46, 0, 28), message, Enum.Font.Gotham, 11, "TextSecondary", Enum.TextXAlignment.Left)
			msgLbl.TextTruncate = Enum.TextTruncate.AtEnd
			msgLbl.TextWrapped = true
			if playerName then
				notification.Name = playerName
				bg.MouseButton1Click:Connect(function() pcall(scrollToPlayer, playerName) end)
				bg.MouseEnter:Connect(function() tweenDetectorObj(bg, { BackgroundColor3 = GetTheme().CardBg }):Play() end)
				bg.MouseLeave:Connect(function() tweenDetectorObj(bg, { BackgroundColor3 = GetTheme().MainBg }):Play() end)
				local viewNotifBtn = MakeButton(bg, UDim2.new(0, 42, 0, 20), UDim2.new(1, -48, 0, 8), "VIEW", "Accent", 9)
				viewNotifBtn.ZIndex = 105
				viewNotifBtn.MouseButton1Click:Connect(function() pcall(viewPlayer, playerName) end)
			end
			tweenDetectorObj(notification, { Size = UDim2.new(1, 0, 0, 72) }):Play()
			for _, child in ipairs(container:GetChildren()) do
				if child:IsA("Frame") and child ~= notification then
					child.LayoutOrder = math.max(0, child.LayoutOrder - 1)
				end
			end
			task.delay(4, function()
				pcall(function()
					tweenDetectorObj(notification, { Size = UDim2.new(1, 0, 0, 0) }):Play()
					task.delay(0.3, function() if notification then notification:Destroy() end end)
				end)
			end)
		end
	}
end
notifications = Notifications.new(ScreenGui)

local function GetHackRank(flagsText, tier, speed)
	if tier == 4 then return 90 end -- Whitelisted
	if tier == 3 then return 80 end -- Normal
	local t = flagsText or ""
	if t:find("|", 1, true) then return 1 end -- Multi-Hack (Top priority)
	if t:find("Fling", 1, true) then return 2 end -- Fling Hack
	if t:find("Extreme Speed", 1, true) then return 3 end -- Extreme Speed
	if t:find("Fly", 1, true) then return 4 end -- Fly Hack
	if t:find("Teleport", 1, true) then return 5 end -- Teleport Hack
	if t:find("NoClip", 1, true) then return 6 end -- NoClip Hack
	if t:find("Jump", 1, true) then return 7 end -- Abnormal Jump
	if t:find("Speed Hack", 1, true) then return 8 end -- Speed Hack (100+ s/s)
	if t:find("Abnormal Speed", 1, true) or tier == 2 then return 9 end -- Abnormal Speed
	if tier == 1 then return 10 end
	return 80
end

local function ReorderDetectorCards()
	local sortable = {}
	for pName, cData in pairs(playerCards) do
		local tier = 3
		if whitelistedPlayers[pName] then
			tier = 4
		elseif detectedPlayers[pName] then
			tier = 1
		elseif speedPlayers[pName] then
			tier = 2
		else
			tier = 3
		end
		local flags = (cData.flagsLbl and cData.flagsLbl.Text) or ""
		local hackRank = GetHackRank(flags, tier, cData.lastSpeed or 0)
		table.insert(sortable, {
			Name = pName,
			Tier = tier,
			HackRank = hackRank,
			Speed = cData.lastSpeed or 0,
			CardData = cData
		})
	end
	table.sort(sortable, function(a, b)
		-- Group strictly according to their detected hacks!
		if a.HackRank ~= b.HackRank then return a.HackRank < b.HackRank end
		if a.Tier ~= b.Tier then return a.Tier < b.Tier end
		if (a.Tier == 1 or a.Tier == 2) and math.abs(a.Speed - b.Speed) > 0.5 then
			return a.Speed > b.Speed
		end
		return a.Name:lower() < b.Name:lower()
	end)
	for idx, item in ipairs(sortable) do
		if item.CardData and item.CardData.card then
			item.CardData.card.LayoutOrder = idx
		end
	end
end

local sharedDetectorRayParams = RaycastParams.new()
sharedDetectorRayParams.FilterType = Enum.RaycastFilterType.Exclude
local sharedDetectorFilter = {}
local RAY_DOWN_16 = Vector3.new(0, -16, 0)
local DIAG_DIRS = {
	Vector3.new(4, -14, 0),
	Vector3.new(-4, -14, 0),
	Vector3.new(0, -14, 4),
	Vector3.new(0, -14, -4)
}

local function isGrounded(hrp, character, humanoid)
	if not hrp then return false end
	if hrp.Anchored then return true end
	if humanoid and humanoid.FloorMaterial ~= nil and humanoid.FloorMaterial ~= Enum.Material.Air then
		return true
	end
	sharedDetectorFilter[1] = character
	sharedDetectorRayParams.FilterDescendantsInstances = sharedDetectorFilter
	local pos = hrp.Position
	if workspace:Raycast(pos, RAY_DOWN_16, sharedDetectorRayParams) ~= nil then
		return true
	end
	for i = 1, 4 do
		if workspace:Raycast(pos, DIAG_DIRS[i], sharedDetectorRayParams) ~= nil then
			return true
		end
	end
	return false
end

local function checkServerTeleport()
	local totalPlayers = 0
	local teleportingPlayers = 0
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and playerData[plr.Name] then
			local character = GetCharacterFromPlayer(plr)
			if character then
				local hrp = GetRootPart(character)
				if hrp then
					totalPlayers = totalPlayers + 1
					local data = playerData[plr.Name]
					local now = tick()
					local dt = now - (data.lastCheck or now)
					local distance = (hrp.Position - data.lastPosition).Magnitude
					if dt < 0.5 and distance > DETECTOR_CONFIG.TELEPORT_DISTANCE then
						teleportingPlayers = teleportingPlayers + 1
					end
				end
			end
		end
	end
	return totalPlayers >= 3 and (teleportingPlayers / totalPlayers) > 0.5
end

-- Silent background physics sampler (runs every 0.25s without mutating UI)
local function samplePlayerPhysics(plr)
	if plr == LocalPlayer then return end
	local character = GetCharacterFromPlayer(plr)
	if not character then return end
	local hrp = GetRootPart(character)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not hrp or not humanoid then return end
	local now = tick()
	if not playerData[plr.Name] then
		playerData[plr.Name] = {
			spawnTime = now,
			lastTeleportTime = now,
			airTime = 0, lastPosition = hrp.Position, lastCheck = now,
			speedSamples = {}, wasDetected = false,
			lastHSpeed = 0, lastTotalSpeed = 0, lastVelY = 0,
			lastWalkSpeed = 16, lastJumpPower = 50, lastGrounded = true,
			recentTeleport = false, recentNoClip = false,
			speedStreak = 0, flyStreak = 0, flingStreak = 0, jumpStreak = 0,
			teleportStreak = 0, noclipStreak = 0
		}
	end
	local data = playerData[plr.Name]
	local dt = math.max(now - (data.lastCheck or now), 0.01)

	local humState = humanoid:GetState()
	local isDead = (humanoid.Health <= 0) or (humState == Enum.HumanoidStateType.Dead)
	local isSeated = humanoid.Sit or (humanoid.SeatPart ~= nil) or (humState == Enum.HumanoidStateType.Seated)
	local isClimbing = (humState == Enum.HumanoidStateType.Climbing)
	local isSwimming = (humState == Enum.HumanoidStateType.Swimming) or (humanoid.FloorMaterial == Enum.Material.Water)
	local isAnchored = (hrp.Anchored == true) or (character:FindFirstChild("CountdownLock") ~= nil) or (character:FindFirstChild("Freeze") ~= nil) or (character:FindFirstChild("Frozen") ~= nil)

	-- Check if player teleported (e.g. from lobby to arena, round start, or respawn in Rivals)
	local distance = (hrp.Position - data.lastPosition).Magnitude
	local isTeleporting = (distance > 30)
	if isTeleporting then
		data.lastTeleportTime = now
		data.airTime = 0
		data.flyingTime = 0
		data.flyStreak = 0
		data.speedStreak = 0
		data.teleportStreak = 0
		data.noclipStreak = 0
		data.lastPosition = hrp.Position
		data.lastCheck = now
		data.recentTeleport = false
		data.recentNoClip = false
		return
	end

	local isJustSpawned = (now - (data.spawnTime or now) < 5.0) or (now - (data.lastTeleportTime or 0) < 5.0)

	if isDead or isSeated or isAnchored or isJustSpawned then
		data.airTime = 0
		data.speedStreak = 0
		data.flyStreak = 0
		data.flingStreak = 0
		data.jumpStreak = 0
		data.teleportStreak = 0
		data.noclipStreak = 0
		data.lastPosition = hrp.Position
		data.lastCheck = now
		data.lastHSpeed = 0
		data.lastTotalSpeed = 0
		data.lastVelY = 0
		data.lastWalkSpeed = math.max(humanoid.WalkSpeed, 1)
		data.lastGrounded = true
		data.recentTeleport = false
		data.recentNoClip = false
		return
	end

	local vel = hrp.AssemblyLinearVelocity
	local hSpeed = math.sqrt(vel.X * vel.X + vel.Z * vel.Z)
	local totalSpeed = math.sqrt(vel.X * vel.X + vel.Y * vel.Y + vel.Z * vel.Z)
	local walkSpeed = math.max(humanoid.WalkSpeed, 1)
	local jumpPower = humanoid.JumpPower
	local grounded = isGrounded(hrp, character, humanoid)

	if grounded or isClimbing or isSwimming or isAnchored then
		data.airTime = 0
		data.flyingTime = 0
	else
		data.airTime = data.airTime + dt
	end

	-- Active flying requires in-air flight without falling naturally with gravity (vel.Y < -8 is natural falling)
	local isActivelyFlying = (not grounded) and not (isDead or isSeated or isAnchored or isClimbing or isSwimming or isJustSpawned) and (
		(math.abs(vel.Y) < 3.0 and hSpeed >= 18) or (vel.Y >= 12 and hSpeed >= 8)
	)

	if isActivelyFlying then
		data.flyingTime = (data.flyingTime or 0) + dt
	else
		data.flyingTime = 0
	end

	-- Real in-combat teleport detection: only outside of spawn/teleport immunity window
	if dt < 0.4 and distance > DETECTOR_CONFIG.TELEPORT_DISTANCE and hSpeed < 80 then
		if not serverTeleporting then
			data.recentTeleport = true
		end
	end

	-- Real NoClip verification: reuse sharedDetectorRayParams with zero extra allocation
	if distance > 2.5 and distance < 40 and not grounded then
		sharedDetectorFilter[1] = character
		sharedDetectorRayParams.FilterDescendantsInstances = sharedDetectorFilter
		local hit = workspace:Raycast(data.lastPosition, (hrp.Position - data.lastPosition).Unit * (distance + 0.5), sharedDetectorRayParams)
		if hit and hit.Instance and hit.Instance.CanCollide and not hit.Instance:IsA("Accessory") and not hit.Instance.Parent:IsA("Accessory") then
			local sz = hit.Instance.Size
			if math.min(sz.X, sz.Y, sz.Z) > 0.8 then
				data.recentNoClip = true
			end
		end
	end

	data.lastPosition = hrp.Position
	data.lastCheck = now
	data.lastHSpeed = hSpeed
	data.lastTotalSpeed = totalSpeed
	data.lastVelY = vel.Y
	data.lastWalkSpeed = walkSpeed
	data.lastJumpPower = jumpPower
	data.lastGrounded = grounded

	table.insert(data.speedSamples, hSpeed)
	if #data.speedSamples > DETECTOR_CONFIG.SAMPLE_COUNT then table.remove(data.speedSamples, 1) end
end

-- Evaluates player & updates UI card (called strictly according to listUpdateDelay!)
local function checkPlayer(plr)
	if plr == LocalPlayer then return end
	local card = playerCards[plr.Name]
	if not card then return end
	local data = playerData[plr.Name]
	if not data then
		samplePlayerPhysics(plr)
		data = playerData[plr.Name]
		if not data then return end
	end

	local character = GetCharacterFromPlayer(plr)
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local hrp = GetRootPart(character)
	local now = tick()
	local isDead = not humanoid or (humanoid.Health <= 0) or (humanoid:GetState() == Enum.HumanoidStateType.Dead)
	local isSeated = humanoid and (humanoid.Sit or (humanoid.SeatPart ~= nil))
	local isAnchored = hrp and (hrp.Anchored == true or character:FindFirstChild("CountdownLock") ~= nil or character:FindFirstChild("Freeze") ~= nil)
	local isJustSpawned = (now - (data.spawnTime or now) < 5.0) or (now - (data.lastTeleportTime or 0) < 5.0)

	if isDead or isSeated or isAnchored or isJustSpawned then
		card.studLbl.Text = "Speed: 0.0 s/s"
		card.wsLbl.Text = string.format("WalkSpeed: %d", (humanoid and humanoid.WalkSpeed) or 16)
		card.groundLbl.Text = isDead and "Dead" or (isAnchored and "Anchored" or "Spawn Protected")
		card.groundLbl.TextColor3 = DETECTOR_CONFIG.COLORS.Clean
		card.stateTier = 3
		card.flagsLbl.Text = ""
		detectedPlayers[plr.Name] = nil
		speedPlayers[plr.Name] = nil
		data.wasDetected = false
		data.speedStreak = 0
		data.flyStreak = 0
		data.flingStreak = 0
		data.jumpStreak = 0
		data.teleportStreak = 0
		data.noclipStreak = 0
		ApplyCardThemeAndStatus(card)
		return
	end

	local hSpeed = data.lastHSpeed or 0
	local totalSpeed = data.lastTotalSpeed or 0
	local velY = data.lastVelY or 0
	local walkSpeed = data.lastWalkSpeed or 16
	local jumpPower = data.lastJumpPower or 50
	local grounded = (data.lastGrounded ~= false)

	local avgSpeed = 0
	if #data.speedSamples > 0 then
		for _, s in ipairs(data.speedSamples) do avgSpeed = avgSpeed + s end
		avgSpeed = avgSpeed / #data.speedSamples
	end
	local peakSpeed = math.max(hSpeed, avgSpeed)
	card.lastSpeed = peakSpeed

	card.studLbl.Text = string.format("Speed: %.1f s/s", hSpeed)
	card.wsLbl.Text = string.format("WalkSpeed: %d", walkSpeed)
	card.groundLbl.Text = grounded and "Grounded" or "Airborne"
	card.groundLbl.TextColor3 = grounded and DETECTOR_CONFIG.COLORS.Clean or DETECTOR_CONFIG.COLORS.Warning

	if whitelistedPlayers[plr.Name] then
		card.stateTier = 4
		detectedPlayers[plr.Name] = nil
		speedPlayers[plr.Name] = nil
		data.wasDetected = false
		ApplyCardThemeAndStatus(card)
		return
	end

	local hardFlags = {}
	local speedFlags = {}
	local minSpeed = DETECTOR_CONFIG.MIN_DETECT_SPEED -- 100 studs/sec minimum

	-- 1. SPEED HACK / ABNORMAL SPEED (Requires sustained >= 100 s/s or WalkSpeed property >= 100)
	if peakSpeed >= minSpeed or walkSpeed >= minSpeed then
		data.speedStreak = (data.speedStreak or 0) + 1
		if data.speedStreak >= 2 or walkSpeed >= minSpeed then
			if peakSpeed >= DETECTOR_CONFIG.EXTREME_HACK_SPEED and peakSpeed > walkSpeed * DETECTOR_CONFIG.SPEED_MULTIPLIER then
				table.insert(hardFlags, "Extreme Speed (" .. math.floor(peakSpeed) .. " s/s)")
			elseif peakSpeed > walkSpeed * DETECTOR_CONFIG.SPEED_MULTIPLIER then
				table.insert(speedFlags, "Speed Hack (100+ s/s)")
			else
				table.insert(speedFlags, "Abnormal Speed (100+ s/s)")
			end
		end
	else
		data.speedStreak = math.max(0, (data.speedStreak or 0) - 1)
	end

	-- 2. FLY HACK: Flagged ONLY when a player is actively flying for AT LEAST 2 SECONDS (data.flyingTime >= 2.0).
	-- Fixes false-positive flagged reports for players teleporting from lobby to arena in Rivals or falling!
	local isFlying2Sec = (data.flyingTime and data.flyingTime >= 2.0)
	if isFlying2Sec and not isJustSpawned and not isAnchored then
		data.flyStreak = (data.flyStreak or 0) + 1
		if data.flyStreak >= 2 then
			table.insert(hardFlags, "Fly")
		end
	else
		data.flyStreak = math.max(0, (data.flyStreak or 0) - 1)
	end

	-- 3. FLING HACK (Requires massive total velocity 350+ AND extreme rotational angular velocity 45+ while alive and standing)
	local isSpinFlinging = (totalSpeed > 350) and (hrp and (hrp.AssemblyAngularVelocity.Magnitude > 45 or hrp.RotVelocity.Magnitude > 45))
	if isSpinFlinging and not grounded then
		data.flingStreak = (data.flingStreak or 0) + 1
		if data.flingStreak >= 2 then
			table.insert(hardFlags, "Fling")
		end
	else
		data.flingStreak = math.max(0, (data.flingStreak or 0) - 1)
	end

	-- 4. ABNORMAL JUMP (Requires sustained extreme vertical velocity >= 100 s/s exceeding 1.8x JumpPower in mid-air)
	if velY >= minSpeed and velY > jumpPower * DETECTOR_CONFIG.JUMP_MULTIPLIER and not grounded and data.airTime > 0.4 then
		data.jumpStreak = (data.jumpStreak or 0) + 1
		if data.jumpStreak >= 2 then
			table.insert(hardFlags, "Abnormal Jump")
		end
	else
		data.jumpStreak = math.max(0, (data.jumpStreak or 0) - 1)
	end

	-- 5. TELEPORT HACK (Requires 2 confirmed in-combat teleports > 100 studs without respawning)
	if data.recentTeleport then
		data.recentTeleport = false
		data.teleportStreak = (data.teleportStreak or 0) + 1
		if data.teleportStreak >= 2 then
			table.insert(hardFlags, "Teleport")
		end
	else
		data.teleportStreak = math.max(0, (data.teleportStreak or 0) - 1)
	end

	-- 6. NOCLIP HACK (Requires crossing through a solid non-passable wall)
	if data.recentNoClip then
		data.recentNoClip = false
		data.noclipStreak = (data.noclipStreak or 0) + 1
		if data.noclipStreak >= 2 then
			table.insert(hardFlags, "NoClip")
		end
	else
		data.noclipStreak = math.max(0, (data.noclipStreak or 0) - 1)
	end

	local allFlags = {}
	for _, f in ipairs(hardFlags) do table.insert(allFlags, f) end
	for _, f in ipairs(speedFlags) do table.insert(allFlags, f) end

	if #hardFlags > 0 then
		card.stateTier = 1
		card.flagsLbl.Text = table.concat(allFlags, " | ")
		detectedPlayers[plr.Name] = true
		speedPlayers[plr.Name] = nil
		ApplyCardThemeAndStatus(card)
		if not data.wasDetected then
			if not notifCooldowns[plr.Name] or (tick() - notifCooldowns[plr.Name] > listUpdateDelay) then
				notifications:show("Hacker Detected!", plr.Name .. " flagged: " .. table.concat(allFlags, ", "), DETECTOR_CONFIG.COLORS.Cheat, DETECTOR_ICONS.scripter, plr.Name)
				notifCooldowns[plr.Name] = tick()
			end
			tweenDetectorObj(card.hoverOverlay, { BackgroundTransparency = 0.78, BackgroundColor3 = DETECTOR_CONFIG.COLORS.Cheat }):Play()
			task.delay(0.6, function()
				pcall(function() tweenDetectorObj(card.hoverOverlay, { BackgroundTransparency = 1, BackgroundColor3 = Color3.fromRGB(255, 255, 255) }):Play() end)
			end)
		end
		data.wasDetected = true
	elseif #speedFlags > 0 then
		card.stateTier = 2
		card.flagsLbl.Text = table.concat(speedFlags, " | ")
		detectedPlayers[plr.Name] = nil
		speedPlayers[plr.Name] = true
		ApplyCardThemeAndStatus(card)
		if not data.wasDetected then
			if not notifCooldowns[plr.Name] or (tick() - notifCooldowns[plr.Name] > listUpdateDelay) then
				notifications:show("Abnormal Speed (100+ s/s)!", plr.Name .. " flagged: " .. table.concat(speedFlags, ", "), DETECTOR_CONFIG.COLORS.Speed, DETECTOR_ICONS.scripter, plr.Name)
				notifCooldowns[plr.Name] = tick()
			end
			tweenDetectorObj(card.hoverOverlay, { BackgroundTransparency = 0.8, BackgroundColor3 = DETECTOR_CONFIG.COLORS.Speed }):Play()
			task.delay(0.6, function()
				pcall(function() tweenDetectorObj(card.hoverOverlay, { BackgroundTransparency = 1, BackgroundColor3 = Color3.fromRGB(255, 255, 255) }):Play() end)
			end)
		end
		data.wasDetected = true
	else
		-- Fully reset and clear back to Normal if no sustained flags exist!
		card.stateTier = 3
		card.flagsLbl.Text = ""
		detectedPlayers[plr.Name] = nil
		speedPlayers[plr.Name] = nil
		data.wasDetected = false
		ApplyCardThemeAndStatus(card)
	end
end

local function RefreshDetectorHeaderCounts()
	local count, hackersCount, speedCount = 0, 0, 0
	for name in pairs(playerCards) do
		count = count + 1
		if detectedPlayers[name] then hackersCount = hackersCount + 1
		elseif speedPlayers[name] then speedCount = speedCount + 1 end
	end
	PlayerCountLabel.Text = string.format("Players: %d", count)
	DetectedCountLabel.Text = string.format("Hackers: %d  |  Abnormal Speed (100+ s/s): %d", hackersCount, speedCount)
	if hackersCount > 0 then
		DetectedCountLabel.TextColor3 = DETECTOR_CONFIG.COLORS.Cheat
	elseif speedCount > 0 then
		DetectedCountLabel.TextColor3 = DETECTOR_CONFIG.COLORS.Speed
	else
		DetectedCountLabel.TextColor3 = GetTheme().TextSecondary
	end
end

local function createPlayerDetectorCard(plr)
	if playerCards[plr.Name] then return end
	local theme = GetTheme()
	local card = Instance.new("Frame")
	card.Name = plr.Name
	card.Size = UDim2.new(1, 0, 0, 126)
	card.BackgroundColor3 = theme.CardBg
	card.BackgroundTransparency = 0.1
	card.BorderSizePixel = 0
	card.LayoutOrder = 3000
	card.Parent = ScannerContainer
	AddCorner(card, 8)
	local cardStroke = Instance.new("UIStroke")
	cardStroke.Color = theme.Stroke
	cardStroke.Thickness = 1.2
	cardStroke.Transparency = 0.6
	cardStroke.Parent = card
	local hoverOverlay = Instance.new("Frame")
	hoverOverlay.Size = UDim2.new(1, 0, 1, 0)
	hoverOverlay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	hoverOverlay.BackgroundTransparency = 1
	hoverOverlay.ZIndex = 1
	hoverOverlay.Parent = card
	AddCorner(hoverOverlay, 8)
	card.MouseEnter:Connect(function() tweenDetectorObj(hoverOverlay, { BackgroundTransparency = 0.95 }):Play() end)
	card.MouseLeave:Connect(function() tweenDetectorObj(hoverOverlay, { BackgroundTransparency = 1 }):Play() end)
	local statusBar = Instance.new("Frame")
	statusBar.Size = UDim2.new(0, 4, 0.84, 0)
	statusBar.Position = UDim2.new(0, 5, 0.08, 0)
	statusBar.BackgroundColor3 = DETECTOR_CONFIG.COLORS.Analyzing
	statusBar.BorderSizePixel = 0
	statusBar.ZIndex = 3
	statusBar.Parent = card
	AddCorner(statusBar, 4)
	local avatarFrame = Instance.new("Frame")
	avatarFrame.Size = UDim2.new(0, 38, 0, 38)
	avatarFrame.Position = UDim2.new(0, 16, 0, 8)
	avatarFrame.BackgroundColor3 = theme.PanelBg
	avatarFrame.BorderSizePixel = 0
	avatarFrame.ZIndex = 3
	avatarFrame.Parent = card
	AddCorner(avatarFrame, 19)
	local avatar = Instance.new("ImageLabel")
	avatar.Size = UDim2.new(1, 0, 1, 0)
	avatar.BackgroundTransparency = 1
	avatar.ZIndex = 4
	avatar.Parent = avatarFrame
	AddCorner(avatar, 19)
	task.spawn(function()
		pcall(function()
			avatar.Image = Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
		end)
	end)
	local userLbl = Instance.new("TextLabel")
	userLbl.Size = UDim2.new(1, -265, 0, 18)
	userLbl.Position = UDim2.new(0, 62, 0, 8)
	userLbl.BackgroundTransparency = 1
	userLbl.Text = plr.DisplayName
	userLbl.TextColor3 = theme.TextPrimary
	userLbl.TextSize = 13
	userLbl.Font = Enum.Font.GothamBold
	userLbl.TextXAlignment = Enum.TextXAlignment.Left
	userLbl.TextTruncate = Enum.TextTruncate.AtEnd
	userLbl.ZIndex = 3
	userLbl.Parent = card
	local dispLbl = Instance.new("TextLabel")
	dispLbl.Size = UDim2.new(1, -265, 0, 14)
	dispLbl.Position = UDim2.new(0, 62, 0, 26)
	dispLbl.BackgroundTransparency = 1
	dispLbl.Text = "@" .. plr.Name
	dispLbl.TextColor3 = theme.TextSecondary
	dispLbl.TextSize = 11
	dispLbl.Font = Enum.Font.Gotham
	dispLbl.TextXAlignment = Enum.TextXAlignment.Left
	dispLbl.TextTruncate = Enum.TextTruncate.AtEnd
	dispLbl.ZIndex = 3
	dispLbl.Parent = card
	local whitelistBtn = Instance.new("TextButton")
	whitelistBtn.Size = UDim2.new(0, 68, 0, 24)
	whitelistBtn.Position = UDim2.new(1, -214, 0, 11)
	whitelistBtn.BackgroundColor3 = theme.PanelBg
	whitelistBtn.BorderSizePixel = 0
	whitelistBtn.Text = "WHITELIST"
	whitelistBtn.TextColor3 = theme.TextSecondary
	whitelistBtn.TextSize = 10
	whitelistBtn.Font = Enum.Font.GothamBold
	whitelistBtn.ZIndex = 5
	whitelistBtn.Parent = card
	AddCorner(whitelistBtn, 6)
	local viewBtn = Instance.new("TextButton")
	viewBtn.Size = UDim2.new(0, 52, 0, 24)
	viewBtn.Position = UDim2.new(1, -142, 0, 11)
	viewBtn.BackgroundColor3 = theme.PanelBg
	viewBtn.BorderSizePixel = 0
	viewBtn.Text = "VIEW"
	viewBtn.TextColor3 = theme.TextPrimary
	viewBtn.TextSize = 10
	viewBtn.Font = Enum.Font.GothamBold
	viewBtn.ZIndex = 5
	viewBtn.Parent = card
	AddCorner(viewBtn, 6)
	local tpBtn = Instance.new("TextButton")
	tpBtn.Size = UDim2.new(0, 36, 0, 24)
	tpBtn.Position = UDim2.new(1, -86, 0, 11)
	tpBtn.BackgroundColor3 = theme.AccentDark
	tpBtn.BorderSizePixel = 0
	tpBtn.Text = "TP"
	tpBtn.TextColor3 = theme.TextPrimary
	tpBtn.TextSize = 10
	tpBtn.Font = Enum.Font.GothamBold
	tpBtn.ZIndex = 5
	tpBtn.Parent = card
	AddCorner(tpBtn, 6)
	local copyBtn = Instance.new("TextButton")
	copyBtn.Size = UDim2.new(0, 42, 0, 24)
	copyBtn.Position = UDim2.new(1, -46, 0, 11)
	copyBtn.BackgroundColor3 = theme.PanelBg
	copyBtn.BorderSizePixel = 0
	copyBtn.Text = "COPY"
	copyBtn.TextColor3 = theme.TextPrimary
	copyBtn.TextSize = 10
	copyBtn.Font = Enum.Font.GothamBold
	copyBtn.ZIndex = 5
	copyBtn.Parent = card
	AddCorner(copyBtn, 6)
	local divider = Instance.new("Frame")
	divider.Size = UDim2.new(1, -20, 0, 1)
	divider.Position = UDim2.new(0, 12, 0, 50)
	divider.BackgroundColor3 = theme.Stroke
	divider.BackgroundTransparency = 0.65
	divider.BorderSizePixel = 0
	divider.ZIndex = 2
	divider.Parent = card
	local studLbl = Instance.new("TextLabel")
	studLbl.Size = UDim2.new(0.45, -16, 0, 16)
	studLbl.Position = UDim2.new(0, 16, 0, 56)
	studLbl.BackgroundTransparency = 1
	studLbl.Text = "Speed: 0.0 s/s"
	studLbl.TextColor3 = theme.TextSecondary
	studLbl.TextSize = 11
	studLbl.Font = Enum.Font.GothamSemibold
	studLbl.TextXAlignment = Enum.TextXAlignment.Left
	studLbl.ZIndex = 3
	studLbl.Parent = card
	local wsLbl = Instance.new("TextLabel")
	wsLbl.Size = UDim2.new(0.55, -16, 0, 16)
	wsLbl.Position = UDim2.new(0.45, 0, 0, 56)
	wsLbl.BackgroundTransparency = 1
	wsLbl.Text = "WalkSpeed: 16"
	wsLbl.TextColor3 = theme.TextSecondary
	wsLbl.TextSize = 11
	wsLbl.Font = Enum.Font.GothamSemibold
	wsLbl.TextXAlignment = Enum.TextXAlignment.Right
	wsLbl.ZIndex = 3
	wsLbl.Parent = card
	local groundLbl = Instance.new("TextLabel")
	groundLbl.Size = UDim2.new(1, -24, 0, 14)
	groundLbl.Position = UDim2.new(0, 16, 0, 73)
	groundLbl.BackgroundTransparency = 1
	groundLbl.Text = "Grounded"
	groundLbl.TextColor3 = DETECTOR_CONFIG.COLORS.Clean
	groundLbl.TextSize = 10
	groundLbl.Font = Enum.Font.GothamBold
	groundLbl.TextXAlignment = Enum.TextXAlignment.Left
	groundLbl.ZIndex = 3
	groundLbl.Parent = card
	local statusIcon = Instance.new("ImageLabel")
	statusIcon.Size = UDim2.new(0, 16, 0, 16)
	statusIcon.Position = UDim2.new(0, 16, 0, 90)
	statusIcon.BackgroundTransparency = 1
	statusIcon.Image = DETECTOR_ICONS.normal
	statusIcon.ScaleType = Enum.ScaleType.Fit
	statusIcon.ZIndex = 3
	statusIcon.Parent = card
	local statusLbl = Instance.new("TextLabel")
	statusLbl.Size = UDim2.new(1, -44, 0, 16)
	statusLbl.Position = UDim2.new(0, 36, 0, 90)
	statusLbl.BackgroundTransparency = 1
	statusLbl.Text = "Normal"
	statusLbl.TextColor3 = DETECTOR_CONFIG.COLORS.Clean
	statusLbl.TextSize = 12
	statusLbl.Font = Enum.Font.GothamBold
	statusLbl.TextXAlignment = Enum.TextXAlignment.Left
	statusLbl.ZIndex = 3
	statusLbl.Parent = card
	local flagsLbl = Instance.new("TextLabel")
	flagsLbl.Size = UDim2.new(1, -24, 0, 15)
	flagsLbl.Position = UDim2.new(0, 16, 0, 107)
	flagsLbl.BackgroundTransparency = 1
	flagsLbl.Text = ""
	flagsLbl.TextColor3 = DETECTOR_CONFIG.COLORS.Cheat
	flagsLbl.TextSize = 10
	flagsLbl.Font = Enum.Font.GothamBold
	flagsLbl.TextXAlignment = Enum.TextXAlignment.Left
	flagsLbl.TextTruncate = Enum.TextTruncate.AtEnd
	flagsLbl.ZIndex = 3
	flagsLbl.Parent = card
	local cData = {
		playerName = plr.Name,
		card = card, cardStroke = cardStroke, statusBar = statusBar,
		avatarFrame = avatarFrame, divider = divider,
		whitelistBtn = whitelistBtn, viewBtn = viewBtn, tpBtn = tpBtn, copyBtn = copyBtn,
		statusIcon = statusIcon, statusLbl = statusLbl, userLbl = userLbl,
		dispLbl = dispLbl, studLbl = studLbl, wsLbl = wsLbl,
		flagsLbl = flagsLbl, groundLbl = groundLbl, hoverOverlay = hoverOverlay,
		stateTier = 3, lastSpeed = 0
	}
	playerCards[plr.Name] = cData
	copyBtn.MouseButton1Click:Connect(function()
		SafeClipboard(plr.Name)
		copyBtn.Text = E.Check
		tweenDetectorObj(copyBtn, { BackgroundColor3 = GetTheme().Accent, TextColor3 = Color3.new(1, 1, 1) }):Play()
		task.delay(0.6, function()
			if copyBtn and copyBtn.Parent then
				copyBtn.Text = "COPY"
				ApplyCardThemeAndStatus(cData)
			end
		end)
	end)
	viewBtn.MouseButton1Click:Connect(function()
		viewPlayer(plr.Name)
	end)
	tpBtn.MouseButton1Click:Connect(function()
		local tRoot = GetRootPart(plr)
		if tRoot then
			local pos = tRoot.Position
			SafeTeleportToCoords(pos.X, pos.Y + 3, pos.Z)
		end
	end)
	whitelistBtn.MouseButton1Click:Connect(function()
		whitelistedPlayers[plr.Name] = not whitelistedPlayers[plr.Name]
		if whitelistedPlayers[plr.Name] then
			detectedPlayers[plr.Name] = nil
			speedPlayers[plr.Name] = nil
		else
			playerData[plr.Name] = nil
			cData.stateTier = 3
		end
		ApplyCardThemeAndStatus(cData)
		ReorderDetectorCards()
		RefreshDetectorHeaderCounts()
	end)
	pcall(checkPlayer, plr)
	ApplyCardThemeAndStatus(cData)
	ReorderDetectorCards()
	RefreshDetectorHeaderCounts()
end

local function removePlayerDetectorCard(plr)
	if SpectatingTarget == plr then
		SetSpectateTarget(nil)
	end
	if playerCards[plr.Name] then
		pcall(function() playerCards[plr.Name].card:Destroy() end)
		playerCards[plr.Name] = nil
	end
	playerData[plr.Name] = nil
	detectedPlayers[plr.Name] = nil
	speedPlayers[plr.Name] = nil
	whitelistedPlayers[plr.Name] = nil
	RefreshDetectorHeaderCounts()
end

local function setupDetectorPlayer(plr)
	if plr == LocalPlayer then return end
	createPlayerDetectorCard(plr)
	table.insert(Connections, plr.CharacterAdded:Connect(function()
		playerData[plr.Name] = nil
	end))
end
for _, plr in ipairs(Players:GetPlayers()) do setupDetectorPlayer(plr) end
table.insert(Connections, Players.PlayerAdded:Connect(setupDetectorPlayer))
table.insert(Connections, Players.PlayerRemoving:Connect(removePlayerDetectorCard))

local sampleElapsed = 0
table.insert(Connections, RunService.Heartbeat:Connect(function(dt)
	if not detectorEnabled then return end
	sampleElapsed = sampleElapsed + dt
	if sampleElapsed >= DETECTOR_CONFIG.SAMPLE_INTERVAL then
		sampleElapsed = 0
		serverTeleporting = checkServerTeleport()
		for _, plr in ipairs(Players:GetPlayers()) do
			pcall(samplePlayerPhysics, plr)
		end
	end
	listUpdateElapsed = listUpdateElapsed + dt
	local targetInterval = math.max(1, tonumber(listUpdateDelay) or 5)
	if listUpdateElapsed < targetInterval then return end
	listUpdateElapsed = 0
	for _, plr in ipairs(Players:GetPlayers()) do
		pcall(checkPlayer, plr)
	end
	ReorderDetectorCards()
	RefreshDetectorHeaderCounts()
end))

table.insert(Connections, UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe or ActiveKeybindCaptureCallback or UserInputService:GetFocusedTextBox() ~= nil then return end
	if input.KeyCode == Enum.KeyCode.F4 then ToggleDetectorState() end
end))

RefreshAllDetectorThemes()
RefreshDetectorHeaderCounts()
end SetupTab9()
--==============================================================================
-- 15. CORE HEARTBEAT, STEPPED, PLAYER LIST & INPUT ENGINES
--==============================================================================
local FREEZE_TAG_NAMES = { Frozen = true, Freeze = true, Stunned = true, CountdownLock = true, SpawnBarrier = true, RootAnchor = true }
local frameCount, lastFpsTime, currentFps, lastRadarRefresh, lastMagnetTime = 0, os.clock(), 60, 0, 0
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
	for k in pairs(characterCache) do characterCache[k] = nil end end)) if UserInputService.JumpRequest then
table.insert(Connections, UserInputService.JumpRequest:Connect(function() if Config.InfiniteJump then
		local char = player.Character local hum = char and char:FindFirstChildOfClass("Humanoid")
		local root = GetRootPart(char) if hum and hum.Health > 0 and root then
			hum:ChangeState(Enum.HumanoidStateType.Jumping)
			local jp
			if Config.MasterUtilityEnabled then
				jp = math.clamp(tonumber(Config.JumpPower) or 50, 1, 500)
			elseif hum.UseJumpPower then
				jp = hum.JumpPower
			else
				local g = workspace.Gravity or 196.2
				jp = math.sqrt(2 * g * math.max(hum.JumpHeight or 7.2, 1))
			end
			local v = root.AssemblyLinearVelocity
			root.AssemblyLinearVelocity = Vector3.new(v.X, jp, v.Z) end end end)) end
table.insert(Connections, RunService.RenderStepped:Connect(function(dt)
	if not (Config.ESPEnabled or (Config.ESPHealthBars ~= false)) and next(adornmentsCache) == nil then return end
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
RunService:BindToRenderStep("Aimbot_v2", Enum.RenderPriority.Camera.Value + 10, function()
	local function setAimbotStatusText(txt)
		if aimbotStatusLabel and aimbotStatusLabel.Text ~= txt then
			aimbotStatusLabel.Text = txt
		end
	end
	local function setAutoShootStatusText(txt)
		if autoShootStatusLbl and autoShootStatusLbl.Text ~= txt then
			autoShootStatusLbl.Text = txt
		end
	end
	local cam = workspace.CurrentCamera
	if not cam then
		if StopAutoShootFiring then StopAutoShootFiring() end
		return
	end
	local anyAimbotActive = (aimbotEnabled or targetAimbotEnabled) and not isClosingPermanently
	local showFov = aimbotEnabled and fovCircleEnabled and not isClosingPermanently
	if guiFovCircle and guiFovCircle.Visible ~= showFov then
		guiFovCircle.Visible = showFov
	end
	if CursorUnlockedOverride and not isClosingPermanently then
		pcall(stepShiftLockCore, cam)
	else
		lastShiftLook = nil
	end
	if not anyAimbotActive then
		currentTarget = nil
		if StopAutoShootFiring then StopAutoShootFiring() end
		setAutoShootStatusText(autoShootEnabled and "Auto Shoot: Ready (Wait Lock)" or "Auto Shoot: OFF")
		return
	end

	-- 1. Target Resolution: Mode 2 (Target Specific Player ONLY) vs Mode 1 (Normal Aimbot)
	if targetAimbotEnabled then
		local tPlr = specificTargetPlayer
		if tPlr and tPlr.Parent and tPlr ~= LocalPlayer then
			local ch = GetCharacterFromPlayer(tPlr)
			local h = ch and ch:FindFirstChildOfClass("Humanoid")
			local p = getTargetPart(ch)
			if ch and h and h.Health > 0 and p and isTargetVisible(p, ch) then
				currentTarget = tPlr
			else
				currentTarget = nil
			end
		else
			currentTarget = nil
		end
	else
		if currentTarget and currentTarget.Parent then
			local ch = GetCharacterFromPlayer(currentTarget)
			local h = ch and ch:FindFirstChildOfClass("Humanoid")
			local p = getTargetPart(ch)
			local _, onScr, sDist = worldToScreenDistance(p and p.Position or V3_ZERO)
			if not ch or not h or h.Health <= 0 or not p or not onScr or (fovCircleEnabled and sDist > FOV_RADIUS) or not isTargetVisible(p, ch) or excludedPlayers[currentTarget] or (aimbotTeamCheck and IsTeammate(currentTarget)) then
				currentTarget = nil
			end
		else
			currentTarget = nil
		end
		if not currentTarget then
			currentTarget = findBestTarget()
		end
	end

	-- 2. Ultra-Aggressive Lock & Strict Head-Locked Auto Shoot
	if currentTarget then
		local tChar = GetCharacterFromPlayer(currentTarget)
		local targetPart = getTargetPart(tChar)
		local headPart = (tChar and tChar:FindFirstChild("Head")) or targetPart
		if tChar and targetPart and isTargetVisible(targetPart, tChar) then
			local camPos = cam.CFrame.Position
			local tVel = targetPart.AssemblyLinearVelocity or V3_ZERO
			local leadPos = targetPart.Position + (tVel * 0.006)
			local goalCF = CFrame.new(camPos, leadPos)
			cam.CFrame = strongLock and goalCF or cam.CFrame:Lerp(goalCF, LERP_ALPHA)
			setAimbotStatusText("Locked: " .. tostring(currentTarget.DisplayName))

			-- Auto Shoot: Fires when locked onto target (Head/Body), stops immediately behind walls!
			local shootTargetPart = (aimPartName == "Head" and headPart) or targetPart
			if autoShootEnabled and shootTargetPart and isTargetVisible(shootTargetPart, tChar) then
				local sp = shootTargetPart.Position
				local cp = cam.CFrame.Position
				local dx, dy, dz = sp.X - cp.X, sp.Y - cp.Y, sp.Z - cp.Z
				local distSq = dx * dx + dy * dy + dz * dz
				local canAutoShoot = strongLock
				if not canAutoShoot and distSq > 0.0001 then
					local invDist = 1 / math.sqrt(distSq)
					local lv = cam.CFrame.LookVector
					local dot = (dx * lv.X + dy * lv.Y + dz * lv.Z) * invDist
					canAutoShoot = (dot >= 0.94)
				end
				if canAutoShoot then
					setAutoShootStatusText("FIRING -> " .. tostring(currentTarget.DisplayName))
					if triggerAutoShoot then triggerAutoShoot() end
				else
					if StopAutoShootFiring then StopAutoShootFiring() end
					setAutoShootStatusText("Aligning Target...")
				end
			else
				if StopAutoShootFiring then StopAutoShootFiring() end
				setAutoShootStatusText(autoShootEnabled and "Stopped (Target Behind Wall)" or "Auto Shoot: OFF")
			end
		else
			currentTarget = nil
			if StopAutoShootFiring then StopAutoShootFiring() end
			setAimbotStatusText(targetAimbotEnabled and "Target Behind Wall / Dead" or "Status: Searching...")
			setAutoShootStatusText(autoShootEnabled and "Stopped (Target Behind Wall)" or "Auto Shoot: OFF")
		end
	else
		if StopAutoShootFiring then StopAutoShootFiring() end
		if targetAimbotEnabled then
			setAimbotStatusText(specificTargetPlayer and ("Waiting: " .. tostring(specificTargetPlayer.DisplayName)) or "Select a Target Player!")
		else
			setAimbotStatusText("Status: Searching...")
		end
		setAutoShootStatusText(autoShootEnabled and "Auto Shoot: Ready (Wait Lock)" or "Auto Shoot: OFF")
	end
end)
local lastAirTimeReset = 0 local function landHum(h) h:ChangeState(Enum.HumanoidStateType.Landed)
	h:ChangeState(Enum.HumanoidStateType.Running) end
table.insert(Connections, RunService.Stepped:Connect(function() local char = player.Character
	if not char then return end if Config.AntiCheatBypass ~= false and isFlightActive() then
		local nowT = os.clock() if nowT - lastAirTimeReset >= 0.85 then lastAirTimeReset = nowT
			local h = char:FindFirstChildOfClass("Humanoid") if h then pcall(landHum, h) end end end
	local myRoot = GetRootPart(char) local myHum = char:FindFirstChildOfClass("Humanoid")
	if Config.AntiFlingEnabled ~= false and not FlingActive and not (IsStickingToPlayer and IsStickingToPlayer()) and myRoot then
		-- Safe Anti-Fling: Protects your character velocity and CFrame without tampering
		-- with other players' weapons/tools (which triggers BAC-8515 sword tampering detections)
		local maxSafeLinear = math.max(135, (Config.MasterUtilityEnabled and (Config.WalkSpeed + Config.JumpPower) or 85) * 1.8)
		if isFlightActive() then maxSafeLinear = math.max(maxSafeLinear, (Config.FlySpeed or 50) * 1.5) end
		if myRoot.AssemblyAngularVelocity.Magnitude > 35 or myRoot.AssemblyLinearVelocity.Magnitude > maxSafeLinear then
			myRoot.AssemblyAngularVelocity = V3_ZERO myRoot.AssemblyLinearVelocity = V3_ZERO
			myRoot.RotVelocity = V3_ZERO myRoot.Velocity = V3_ZERO if lastSafeAntiFlingCF then
				myRoot.CFrame = lastSafeAntiFlingCF end else lastSafeAntiFlingCF = myRoot.CFrame end end
	if Config.NoclipEnabled then
		genv._TR_WasNoclip = true
		for _, child in ipairs(char:GetChildren()) do
			if child:IsA("BasePart") and child.CanCollide and child.Name ~= "TR_FakeFloor" then
				child.CanCollide = false
			end
		end
	elseif genv._TR_WasNoclip then
		genv._TR_WasNoclip = false
		if RestoreCharacterCollision then RestoreCharacterCollision(char) end
	end
	if Config.CountdownBypass then
		for _, child in ipairs(char:GetChildren()) do
			if child:IsA("BasePart") and child.Anchored then
				child.Anchored = false
			elseif FREEZE_TAG_NAMES[child.Name] then
				pcall(child.Destroy, child)
			end
		end
	end end))
-- Consolidated Master Heartbeat Loop (Flight + Anti-Fling Recovery + Systems Monitor)
table.insert(Connections, RunService.Heartbeat:Connect(function(deltaTime)
	camera = workspace.CurrentCamera local char = player.Character
	local root = char and (char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart)
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	-- 0. Freecam Character Anchor (Keeps character stationary while moving Freecam with WASD)
	if isFreecamActive and isFreecamActive() and char and root and hum then
		local fcCF = GetFreecamAnchorCF and GetFreecamAnchorCF(root.CFrame)
		if fcCF then root.CFrame = fcCF end
		root.AssemblyLinearVelocity = V3_ZERO
		root.AssemblyAngularVelocity = V3_ZERO
		if hum.WalkSpeed ~= 0 then hum.WalkSpeed = 0 end
	end
	-- 2. Performance HUD (Only updates text & ping when Dashboard tab is visible)
	frameCount = frameCount + 1 local now = os.clock() if now - lastFpsTime >= 0.5 then
		currentFps = math.floor(frameCount / (now - lastFpsTime) + 0.5) frameCount = 0 lastFpsTime = now
		if isMenuVisible and ActiveTabName == "Dashboard & Themes" then
			local pingMs = 0 local okPing, pingVal = pcall(player.GetNetworkPing, player)
			if okPing and type(pingVal) == "number" then pingMs = math.floor(pingVal * 1000 + 0.5) end
			local mlKey = Config.MouseLockKeybind or "None"
			PerfLabel.Text = string.format("FPS: %d  |  Ping: %d ms  |  Mouse Lock [%s]: %s", currentFps, pingMs, mlKey, CursorUnlockedOverride and "ON" or "OFF")
		end
	end
	-- 3. Radar & ESP Periodic Refresh (every 2.0s, only rebuilds Radar UI when visible)
	if now - lastRadarRefresh >= 2.0 then lastRadarRefresh = now
		if isMenuVisible and ActiveTabName == "Player Radar" and not ActiveKeybindCaptureCallback then RefreshRadarCards() end
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
	if Config.AntiFlingEnabled ~= false and not FlingActive and not (IsStickingToPlayer and IsStickingToPlayer()) then
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
	-- 8. Master Utility WalkSpeed & JumpPower (Paused while flying so it never interferes with Flight)
	if RecordNaturalHumanoidDefaults then RecordNaturalHumanoidDefaults(hum) end
	if Config.MasterUtilityEnabled and not FlingActive and not isFlightActive() and not (IsStickingToPlayer and IsStickingToPlayer()) and not (isFreecamActive and isFreecamActive()) then
		local targetWS = math.clamp(tonumber(Config.WalkSpeed) or 18, 1, 500)
		local targetJP = math.clamp(tonumber(Config.JumpPower) or 50, 1, 500)
		local g = workspace.Gravity or 196.2
		local targetJH = (targetJP * targetJP) / (2 * g)
		if Config.AntiCheatBypass ~= false and not hookmetamethod then
			hum.WalkSpeed = math.min(targetWS, naturalWalkSpeed)
			if naturalUseJumpPower then hum.JumpPower = math.min(targetJP, naturalJumpPower) else hum.JumpHeight = math.min(targetJH, naturalJumpHeight) end
			local extraSpeed = math.max(0, targetWS - naturalWalkSpeed)
			if extraSpeed > 0 and hum.MoveDirection.Magnitude > 0 then
				local stepDist = extraSpeed * 0.016
				local dirUnit = hum.MoveDirection.Unit
				local blocked = false
				if not Config.NoclipEnabled and reusableWallcheckParams then
					local wallHit = workspace:Raycast(root.Position, dirUnit * (stepDist + 2.0), reusableWallcheckParams)
					if wallHit and wallHit.Instance and wallHit.Instance.CanCollide then blocked = true end
				end
				if not blocked then
					local nextPos = root.Position + (dirUnit * stepDist)
					root.CFrame = CFrame.new(nextPos) * (root.CFrame - root.CFrame.Position)
					lastSafeAntiFlingCF = root.CFrame
				end end
			if targetJP > naturalJumpPower and UserInputService:IsKeyDown(Enum.KeyCode.Space) and hum.FloorMaterial ~= Enum.Material.Air then
				local v = root.AssemblyLinearVelocity
				root.AssemblyLinearVelocity = Vector3.new(v.X, targetJP, v.Z) end else
			hum.WalkSpeed = targetWS
			if naturalUseJumpPower then
				hum.UseJumpPower = true hum.JumpPower = targetJP
			else
				hum.UseJumpPower = false hum.JumpHeight = targetJH hum.JumpPower = targetJP
			end end end
	-- 9. Speed-Synced Spider Climb
	if Config.SpiderClimb and not isFlightActive() and not FlingActive and hum.MoveDirection.Magnitude > 0.05 then
		local rayDir = hum.MoveDirection.Unit * 2.5 local rayPos = root.Position
		local spiderHit = workspace:Raycast(rayPos, rayDir, reusableWallcheckParams) if not spiderHit then
			spiderHit = workspace:Raycast(rayPos - Vector3.new(0, 1.4, 0), rayDir, reusableWallcheckParams) end
		if spiderHit and spiderHit.Instance and spiderHit.Instance.CanCollide then
			local curSpeed = (Config.MasterUtilityEnabled and (Config.WalkSpeed or 16)) or hum.WalkSpeed
			local climbSpeed = math.clamp(curSpeed * 0.9, 18, 250) local curVel = root.AssemblyLinearVelocity
			root.AssemblyLinearVelocity = Vector3.new(curVel.X * 0.25, climbSpeed, curVel.Z * 0.25)
			hum:ChangeState(Enum.HumanoidStateType.Climbing) end end
	-- 10. Item Vacuum / Magnet Periodic Check (every 0.2s)
	if Config.ItemMagnetEnabled and pullNearbyItems then if now - lastMagnetTime >= 0.2 then
			lastMagnetTime = now pullNearbyItems() end end end))
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
		local tAimKey = Config.TargetAimbotKeybind or "T"
		if tAimKey ~= "None" and keyName == tAimKey and toggleTargetAimbot then toggleTargetAimbot() return end
		local asKey = Config.AutoShootKeybind or "Z"
		if asKey ~= "None" and keyName == asKey and toggleAutoShoot then toggleAutoShoot() return end
		if input.KeyCode == Enum.KeyCode.E and ActiveTabName == "Items & Prompts" then
			if pullNearbyItems then pullNearbyItems() end return end
		local fcKey = Config.FreecamKeybind or "C"
		if fcKey ~= "None" and keyName == fcKey and toggleFreecamState then toggleFreecamState() return end
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
	FlingActive, aimbotEnabled, targetAimbotEnabled, currentTarget, masterFlightEnabled = false, false, false, nil, false
	if StopAutoShootFiring then pcall(StopAutoShootFiring) end
	if SetStickTarget then pcall(SetStickTarget, nil) end
	pcall(function() RunService:UnbindFromRenderStep("TR_Stick_Step") end)
	genv.TR_AntiCheatActive = false pcall(StopFling) pcall(stopFlight) if stopFreecam then pcall(stopFreecam) end
	if SetSpectateTarget then pcall(SetSpectateTarget, nil) end
	for _, thread in ipairs(RunningExecutorThreads) do pcall(function() task.cancel(thread) end) end
	RunningExecutorThreads = {} pcall(function() SetMouseLockState(false) end)
	SpectatingTarget, ActiveKeybindCaptureCallback = nil, nil
	pcall(function() RunService:UnbindFromRenderStep("Aimbot_v2") end)
	pcall(function() RunService:UnbindFromRenderStep("TR_ShiftLock_Pre") end)
	pcall(function() RunService:UnbindFromRenderStep("TR_Freecam_Step") end)
	pcall(function() RunService:UnbindFromRenderStep("TR_Spectate_Step") end)
	pcall(function() RunService:UnbindFromRenderStep("TR_Freecam_Step") end)
	pcall(function() RunService:UnbindFromRenderStep("TR_Spectate_Step") end)
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
		isClosingPermanently = true task.delay(0.42, function()
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

end
SetupRemainingTabsAndLoops()
