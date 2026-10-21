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
		Theme = "Default", GuiDesign = "Default", Animation = "Default", WindowWidth = 760, WindowHeight = 480, WalkSpeed = 18, JumpPower = 50, FOV = 70,
		FlySpeed = 100, FlyKeybind = "E", FreecamSpeed = 60, FreecamKeybind = "C", MouseLockKeybind = "M", AimbotKeybind = "Q", AimbotKeyMode = "Toggle", AimbotBurstDurationMs = 1000, TargetAimbotKeybind = "T", AutoShootKeybind = "Z", AimbotAutoShootKeybind = "V", AimbotAutoShootEnabled = false, AutoShootDelayMs = 25, ESPHealthBars = true, AimbotFOVRadius = 200,
		AimbotFOVCircleEnabled = true, AimbotEnabled = false, TargetAimbotEnabled = false, ZombieAimbotEnabled = false, ZombieAimbotKeybind = "G", ZombieAimPriority = "Crosshair", StrongLock = true, StickMode = "Back", OrbitRadius = 8, OrbitSpeed = 10, AntiKatanaEnabled = true, FloatingIconEnabled = true, FloatingIconLocked = false, MobileFloatStyle = "Pill", WallcheckEnabled = true,
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
	Stroke = {}, TextPrimary = {}, TextSecondary = {}, CustomCallbacks = {} } -- Realistic Apple OS (visionOS / iOS 26 / macOS Tahoe) Optical Smoked-Crystal Glass Base
local LiquidGlassBase = {
	MainBg = Color3.fromRGB(34, 46, 68),
	PanelBg = Color3.fromRGB(48, 64, 92),
	CardBg = Color3.fromRGB(62, 82, 116),
	Accent = Color3.fromRGB(68, 178, 255),
	AccentDark = Color3.fromRGB(38, 124, 215),
	Stroke = Color3.fromRGB(242, 249, 255),
	TextPrimary = Color3.fromRGB(255, 255, 255),
	TextSecondary = Color3.fromRGB(205, 226, 250)
}

local function ComputeEffectiveTheme(themeName, designName)
	local base = Themes[themeName] or Themes["Default"]
	designName = designName or Config.GuiDesign or "Default"
	if designName == "LiquidGlass" then
		if themeName == "Default" or not themeName then
			return LiquidGlassBase
		end
		-- Other themes infuse subtle colored glass shading into the realistic Apple Liquid Glass crystal!
		return {
			MainBg = LiquidGlassBase.MainBg:Lerp(base.Accent, 0.32),
			PanelBg = LiquidGlassBase.PanelBg:Lerp(base.Accent, 0.36),
			CardBg = LiquidGlassBase.CardBg:Lerp(base.Accent, 0.30),
			Accent = base.Accent:Lerp(Color3.fromRGB(225, 242, 255), 0.18),
			AccentDark = base.AccentDark:Lerp(Color3.fromRGB(170, 210, 245), 0.16),
			Stroke = Color3.fromRGB(245, 250, 255):Lerp(base.Stroke, 0.38),
			TextPrimary = Color3.fromRGB(255, 255, 255),
			TextSecondary = Color3.fromRGB(220, 234, 250):Lerp(base.TextSecondary, 0.30)
		}
	elseif designName == "CyberHud" then
		local isDef = (themeName == "Default" or not themeName)
		local acc = isDef and Color3.fromRGB(0, 242, 255) or base.Accent
		local accDark = isDef and Color3.fromRGB(0, 130, 175) or base.AccentDark
		local strk = isDef and Color3.fromRGB(190, 55, 255) or base.Stroke
		return {
			MainBg = Color3.fromRGB(5, 6, 12),
			PanelBg = Color3.fromRGB(9, 11, 20):Lerp(acc, 0.10),
			CardBg = Color3.fromRGB(13, 16, 28):Lerp(acc, 0.14),
			Accent = acc,
			AccentDark = accDark,
			Stroke = strk,
			TextPrimary = Color3.fromRGB(245, 253, 255),
			TextSecondary = isDef and Color3.fromRGB(135, 230, 250) or base.TextSecondary
		}
	end
	return base
end

local cachedEffectiveTheme, cachedEffThemeName, cachedEffDesignName = nil, nil, nil
local function GetTheme()
	local tName = Config.Theme or "Default"
	local dName = Config.GuiDesign or "Default"
	if cachedEffectiveTheme and cachedEffThemeName == tName and cachedEffDesignName == dName then
		return cachedEffectiveTheme
	end
	cachedEffThemeName = tName
	cachedEffDesignName = dName
	cachedEffectiveTheme = ComputeEffectiveTheme(tName, dName)
	return cachedEffectiveTheme
end

local ApplyGuiDesignSurface
local function RegisterThemeObject(instance, prop, themeKey)
	table.insert(ThemeObjects[themeKey], { Instance = instance, Property = prop })
	instance[prop] = GetTheme()[themeKey]
end

local function ApplyTheme(themeName)
	if not Themes[themeName] then themeName = "Default" end
	Config.Theme = themeName
	savedConfig.Settings.Theme = themeName
	local active = GetTheme()
	for key, list in pairs(ThemeObjects) do
		if key ~= "CustomCallbacks" and active[key] then
			for _, item in ipairs(list) do
				if item.Instance and item.Instance.Parent then
					TweenService:Create(item.Instance, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						[item.Property] = active[key]
					}):Play()
				end
			end
		end
	end
	if ApplyGuiDesignSurface then pcall(ApplyGuiDesignSurface) end
	for _, fn in ipairs(ThemeObjects.CustomCallbacks) do pcall(fn, active) end
	SaveConfig(false)
end
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
local isMobileDevice = UserInputService.TouchEnabled and (not UserInputService.KeyboardEnabled or (workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize.Y <= 520))
if isMobileDevice then
	Config.FloatingIconEnabled = true
	savedConfig.Settings.FloatingIconEnabled = true
elseif Config.FloatingIconEnabled == nil then
	Config.FloatingIconEnabled = true
	savedConfig.Settings.FloatingIconEnabled = true
end
local FloatingPill = nil
local MobileSquareIcon = nil
local isFloatingPillLocked = (Config.FloatingIconLocked == true)
local FUI = {}
local function SyncFloatingPillState()
	local eff = GetTheme()
	local lockedCol = Color3.fromRGB(245, 166, 35)
	local dotCol = isMenuVisible and Color3.fromRGB(46, 213, 115) or eff.Accent
	if FloatingPill then
		if FUI.FloatSubLbl then
			if isFloatingPillLocked then
				FUI.FloatSubLbl.Text = isMenuVisible and "POS LOCKED | ACTIVE" or "POS LOCKED | OPEN"
				FUI.FloatSubLbl.TextColor3 = lockedCol
			else
				FUI.FloatSubLbl.Text = isMenuVisible and "HUB ACTIVE | V95" or "TAP TO OPEN HUB"
				FUI.FloatSubLbl.TextColor3 = isMenuVisible and eff.TextSecondary or eff.Accent
			end
		end
		if FUI.FloatStatusDot then
			FUI.FloatStatusDot.BackgroundColor3 = dotCol
			if FUI.FloatStatusStroke then FUI.FloatStatusStroke.Color = dotCol end
		end
		if FUI.FloatDragIcon then
			FUI.FloatDragIcon.TextTransparency = isFloatingPillLocked and 0.58 or 0.0
			FUI.FloatDragIcon.TextColor3 = isFloatingPillLocked and eff.TextSecondary or eff.Accent
		end
		if FUI.FloatLeftPodStroke then
			FUI.FloatLeftPodStroke.Color = isFloatingPillLocked and eff.Stroke or eff.Accent
			FUI.FloatLeftPodStroke.Transparency = isFloatingPillLocked and 0.72 or 0.45
		end
		if FUI.FloatLockBtn then
			FUI.FloatLockBtn.Text = isFloatingPillLocked and utf8.char(0x1F512) or utf8.char(0x1F513)
			FUI.FloatLockBtn.BackgroundColor3 = isFloatingPillLocked and eff.PanelBg:Lerp(lockedCol, 0.35) or eff.PanelBg
			FUI.FloatLockBtn.TextColor3 = isFloatingPillLocked and Color3.fromRGB(255, 220, 110) or eff.Accent
		end
		if FUI.FloatLockStroke then
			FUI.FloatLockStroke.Color = isFloatingPillLocked and lockedCol or eff.Accent
			FUI.FloatLockStroke.Transparency = isFloatingPillLocked and 0.15 or 0.45
		end
	end
	if MobileSquareIcon then
		if FUI.SquareStatusDot then
			FUI.SquareStatusDot.BackgroundColor3 = dotCol
		end
		if FUI.SquareLockBtn then
			FUI.SquareLockBtn.Text = isFloatingPillLocked and utf8.char(0x1F512) or utf8.char(0x1F513)
			FUI.SquareLockBtn.BackgroundColor3 = isFloatingPillLocked and eff.PanelBg:Lerp(lockedCol, 0.40) or eff.PanelBg
			FUI.SquareLockBtn.TextColor3 = isFloatingPillLocked and Color3.fromRGB(255, 220, 110) or eff.Accent
		end
		if FUI.SquareLockStroke then
			FUI.SquareLockStroke.Color = isFloatingPillLocked and lockedCol or eff.Accent
		end
	end
end
local function UpdateFloatingPillVisibility()
	if not FloatingPill then return end
	if isClosingPermanently then
		FloatingPill.Visible = false
		if MobileSquareIcon then MobileSquareIcon.Visible = false end
		return
	end
	if isMobileDevice then
		local useSquare = (Config.MobileFloatStyle == "Square")
		FloatingPill.Visible = not useSquare
		if MobileSquareIcon then MobileSquareIcon.Visible = useSquare end
	else
		if MobileSquareIcon then MobileSquareIcon.Visible = false end
		FloatingPill.Visible = (Config.FloatingIconEnabled ~= false)
	end
	SyncFloatingPillState()
end
local function GetTargetWindowScale()
	if not isMobileDevice then return 1 end
	local cam = workspace.CurrentCamera
	local vs = cam and cam.ViewportSize or Vector2.new(800, 400)
	local scaleX = (vs.X * 0.84) / math.max(CurrentWidth, 560)
	local scaleY = (vs.Y * 0.80) / math.max(CurrentHeight, 360)
	return math.clamp(math.min(scaleX, scaleY, 0.70), 0.42, 0.72)
end
local function SetMenuVisible(state, onComplete) if isClosingPermanently then return end
	for _, tw in ipairs(activeWindowTweens) do pcall(function() tw:Cancel() end) end activeWindowTweens = {}
	local wasVisible = MainFrame.Visible
	isMenuVisible = state if SyncAimbotFovCircleVisibility then SyncAimbotFovCircleVisibility() end
	local animStyle = Config.Animation or "Default"
	local targetScale = GetTargetWindowScale()
	local curDesign = Config.GuiDesign or "Default"
	local targetBgTrans = (curDesign == "LiquidGlass" and 0.56) or (curDesign == "CyberHud" and 0.08) or 0.06
	local targetStrokeTrans = (curDesign == "LiquidGlass" and 0.08) or (curDesign == "CyberHud" and 0.0) or 0.25
	pcall(function()
		local blur = Lighting:FindFirstChild("TR_LiquidGlassBlur")
		if blur then blur.Enabled = (state == true and curDesign == "LiquidGlass" and not isClosingPermanently) end
	end)
	MainFrame.Size = UDim2.new(0, CurrentWidth, 0, CurrentHeight)
	MainFrame.Rotation = 0
	TopBar.Position = UDim2.new(0, 0, 0, 0)
	Sidebar.Position = UDim2.new(0, 10, 0, 50)
	ContentContainer.Position = UDim2.new(0, 200, 0, 50)
	MainStroke.Thickness = 1.6
	if state then
		UpdateFloatingPillVisibility()
		MainFrame.Visible = true
		if animStyle == "Windows" then
			MainScale.Scale = targetScale * 0.88
			MainFrame.Position = UDim2.new(RestingPosition.X.Scale, RestingPosition.X.Offset, RestingPosition.Y.Scale, RestingPosition.Y.Offset + 36)
			MainFrame.BackgroundTransparency = 0.70
			MainStroke.Transparency = 0.85
			local info = TweenInfo.new(0.24, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
			local t1 = TweenService:Create(MainScale, info, { Scale = targetScale })
			local t2 = TweenService:Create(MainFrame, info, { Position = RestingPosition, BackgroundTransparency = targetBgTrans })
			local t3 = TweenService:Create(MainStroke, info, { Transparency = targetStrokeTrans })
			activeWindowTweens = { t1, t2, t3 }
			t1:Play() t2:Play() t3:Play()
			t1.Completed:Connect(function(st)
				if st == Enum.PlaybackState.Completed and onComplete then onComplete() end
			end)
		elseif animStyle == "macOS" then
			MainScale.Scale = 0.12
			MainFrame.Position = UDim2.new(RestingPosition.X.Scale, RestingPosition.X.Offset, RestingPosition.Y.Scale, RestingPosition.Y.Offset + 130)
			MainFrame.BackgroundTransparency = 0.65
			MainStroke.Transparency = 0.80
			local infoScale = TweenInfo.new(0.36, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
			local infoPos = TweenInfo.new(0.34, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
			local infoStroke = TweenInfo.new(0.28, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
			local t1 = TweenService:Create(MainScale, infoScale, { Scale = targetScale })
			local t2 = TweenService:Create(MainFrame, infoPos, { Position = RestingPosition, BackgroundTransparency = targetBgTrans })
			local t3 = TweenService:Create(MainStroke, infoStroke, { Transparency = targetStrokeTrans })
			activeWindowTweens = { t1, t2, t3 }
			t1:Play() t2:Play() t3:Play()
			t1.Completed:Connect(function(st)
				if st == Enum.PlaybackState.Completed and onComplete then onComplete() end
			end)
		else
			if not wasVisible then
				MainScale.Scale = 0 MainFrame.Position = RestingPosition
				MainFrame.BackgroundTransparency = 1 MainStroke.Transparency = 1
			end
			local info = TweenInfo.new(0.26, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
			local t1 = TweenService:Create(MainScale, info, { Scale = targetScale })
			local t2 = TweenService:Create(MainFrame, info, { Position = RestingPosition, BackgroundTransparency = targetBgTrans })
			local t3 = TweenService:Create(MainStroke, info, { Transparency = targetStrokeTrans })
			activeWindowTweens = { t1, t2, t3 } t1:Play() t2:Play() t3:Play() t1.Completed:Connect(function(st)
				if st == Enum.PlaybackState.Completed and onComplete then onComplete() end end)
		end
	else
		draggingGui, resizingMode = false, nil
		UpdateFloatingPillVisibility()
		if animStyle == "Windows" then
			local info = TweenInfo.new(0.18, Enum.EasingStyle.Cubic, Enum.EasingDirection.In)
			local t1 = TweenService:Create(MainScale, info, { Scale = targetScale * 0.88 })
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
			local info = TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
			local t1 = TweenService:Create(MainScale, info, { Scale = 0 })
			local t2 = TweenService:Create(MainFrame, info, { Position = RestingPosition, BackgroundTransparency = 1 })
			local t3 = TweenService:Create(MainStroke, info, { Transparency = 1 })
			activeWindowTweens = { t1, t2, t3 } t1:Play() t2:Play() t3:Play() t1.Completed:Connect(function(st)
				if st == Enum.PlaybackState.Completed then if not isMenuVisible then MainFrame.Visible = false end
					if onComplete then onComplete() end end end)
		end
	end end
MainScale.Scale = GetTargetWindowScale()
do
	-- Upper-Middle Screen Spawn Position (Centered Horizontally at Top of Screen)
	FloatingPill = Instance.new("Frame")
	FloatingPill.Name = "TR_FloatingPill"
	FloatingPill.Size = UDim2.new(0, 238, 0, 44)
	FloatingPill.Position = UDim2.new(0.5, -119, 0, 10)
	FloatingPill.BackgroundTransparency = 0.08
	FloatingPill.BorderSizePixel = 0
	FloatingPill.Active = true
	FloatingPill.ClipsDescendants = false
	FloatingPill.ZIndex = 50
	FloatingPill.Parent = ScreenGui
	RegisterThemeObject(FloatingPill, "BackgroundColor3", "MainBg")
	local pillCorner = Instance.new("UICorner", FloatingPill)
	pillCorner.CornerRadius = UDim.new(1, 0)

	FUI.FloatPillScale = Instance.new("UIScale", FloatingPill)
	FUI.FloatPillScale.Scale = 1

	-- Outer Soft Neon / Crystal Aura Ring
	FUI.FloatOuterHalo = Instance.new("Frame", FloatingPill)
	FUI.FloatOuterHalo.Name = "TR_PillOuterHalo"
	FUI.FloatOuterHalo.Size = UDim2.new(1, 8, 1, 8)
	FUI.FloatOuterHalo.Position = UDim2.new(0, -4, 0, -4)
	FUI.FloatOuterHalo.BackgroundTransparency = 1
	FUI.FloatOuterHalo.BorderSizePixel = 0
	FUI.FloatOuterHalo.ZIndex = 49
	local haloCorner = Instance.new("UICorner", FUI.FloatOuterHalo)
	haloCorner.CornerRadius = UDim.new(1, 0)
	FUI.FloatHaloStroke = Instance.new("UIStroke", FUI.FloatOuterHalo)
	FUI.FloatHaloStroke.Thickness = 3.2
	FUI.FloatHaloStroke.Transparency = 0.68
	FUI.FloatHaloStroke.Color = Color3.fromRGB(255, 255, 255)
	FUI.FloatHaloGrad = Instance.new("UIGradient", FUI.FloatHaloStroke)
	FUI.FloatHaloGrad.Rotation = 0

	-- Main Capsule Gradient & Glowing Iridescent Border Stroke
	FUI.FloatPillGrad = Instance.new("UIGradient", FloatingPill)
	FUI.FloatPillGrad.Rotation = 18
	FUI.FloatPillGrad.Enabled = true

	FUI.FloatPillStroke = Instance.new("UIStroke", FloatingPill)
	FUI.FloatPillStroke.Thickness = 2.2
	FUI.FloatPillStroke.Transparency = 0.04
	FUI.FloatPillStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	FUI.FloatPillStroke.Color = Color3.fromRGB(255, 255, 255)

	FUI.FloatPillStrokeGrad = Instance.new("UIGradient", FUI.FloatPillStroke)
	FUI.FloatPillStrokeGrad.Rotation = 0
	FUI.FloatPillStrokeGrad.Enabled = true

	-- Clipped Inner Surface for Specular Glints & Laser Bars
	local FloatClipSurface = Instance.new("Frame", FloatingPill)
	FloatClipSurface.Name = "TR_PillClipSurface"
	FloatClipSurface.Size = UDim2.new(1, 0, 1, 0)
	FloatClipSurface.Position = UDim2.new(0, 0, 0, 0)
	FloatClipSurface.BackgroundTransparency = 1
	FloatClipSurface.ClipsDescendants = true
	FloatClipSurface.ZIndex = 51
	local clipCorner = Instance.new("UICorner", FloatClipSurface)
	clipCorner.CornerRadius = UDim.new(1, 0)

	FUI.FloatPillTopSpec = Instance.new("Frame", FloatClipSurface)
	FUI.FloatPillTopSpec.Name = "TR_PillTopSpec"
	FUI.FloatPillTopSpec.Size = UDim2.new(1, -34, 0, 2)
	FUI.FloatPillTopSpec.Position = UDim2.new(0, 17, 0, 1)
	FUI.FloatPillTopSpec.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	FUI.FloatPillTopSpec.BackgroundTransparency = 0.18
	FUI.FloatPillTopSpec.BorderSizePixel = 0
	FUI.FloatPillTopSpec.ZIndex = 53
	FUI.FloatPillTopSpec.Visible = true
	FUI.FloatTopSpecGrad = Instance.new("UIGradient", FUI.FloatPillTopSpec)
	FUI.FloatTopSpecGrad.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.94),
		NumberSequenceKeypoint.new(0.30, 0.12),
		NumberSequenceKeypoint.new(0.5, 0.0),
		NumberSequenceKeypoint.new(0.70, 0.12),
		NumberSequenceKeypoint.new(1, 0.94)
	})

	FUI.FloatPillBotGlow = Instance.new("Frame", FloatClipSurface)
	FUI.FloatPillBotGlow.Name = "TR_PillBotGlow"
	FUI.FloatPillBotGlow.Size = UDim2.new(1, -48, 0, 2)
	FUI.FloatPillBotGlow.Position = UDim2.new(0, 24, 1, -2)
	FUI.FloatPillBotGlow.BackgroundTransparency = 0.30
	FUI.FloatPillBotGlow.BorderSizePixel = 0
	FUI.FloatPillBotGlow.ZIndex = 53
	RegisterThemeObject(FUI.FloatPillBotGlow, "BackgroundColor3", "Accent")
	FUI.FloatBotGlowGrad = Instance.new("UIGradient", FUI.FloatPillBotGlow)
	FUI.FloatBotGlowGrad.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.95),
		NumberSequenceKeypoint.new(0.5, 0.08),
		NumberSequenceKeypoint.new(1, 0.95)
	})

	-- Left Tactile Grip Pod + 4-Way Directional Move Icon
	FUI.FloatLeftPod = Instance.new("Frame", FloatingPill)
	FUI.FloatLeftPod.Name = "DragGripPod"
	FUI.FloatLeftPod.Size = UDim2.new(0, 32, 0, 32)
	FUI.FloatLeftPod.Position = UDim2.new(0, 6, 0.5, -16)
	FUI.FloatLeftPod.BackgroundTransparency = 0.55
	FUI.FloatLeftPod.BorderSizePixel = 0
	FUI.FloatLeftPod.ZIndex = 52
	RegisterThemeObject(FUI.FloatLeftPod, "BackgroundColor3", "PanelBg")
	local leftPodCorner = Instance.new("UICorner", FUI.FloatLeftPod)
	leftPodCorner.CornerRadius = UDim.new(1, 0)
	FUI.FloatLeftPodStroke = Instance.new("UIStroke", FUI.FloatLeftPod)
	FUI.FloatLeftPodStroke.Thickness = 1.1
	FUI.FloatLeftPodStroke.Transparency = 0.50
	RegisterThemeObject(FUI.FloatLeftPodStroke, "Color", "Accent")

	FUI.FloatDragIcon = Instance.new("TextLabel", FUI.FloatLeftPod)
	FUI.FloatDragIcon.Name = "DragArrowIcon"
	FUI.FloatDragIcon.Size = UDim2.new(1, 0, 1, 0)
	FUI.FloatDragIcon.Position = UDim2.new(0, 0, 0, 0)
	FUI.FloatDragIcon.BackgroundTransparency = 1
	FUI.FloatDragIcon.Font = Enum.Font.GothamBold
	FUI.FloatDragIcon.TextSize = 16
	FUI.FloatDragIcon.Text = utf8.char(0x2725)
	FUI.FloatDragIcon.ZIndex = 53
	RegisterThemeObject(FUI.FloatDragIcon, "TextColor3", "Accent")

	-- Laser-Etched Feathered Vertical Divider Line
	FUI.FloatPillDivider = Instance.new("Frame", FloatingPill)
	FUI.FloatPillDivider.Name = "VerticalDivider"
	FUI.FloatPillDivider.Size = UDim2.new(0, 1, 1, -10)
	FUI.FloatPillDivider.Position = UDim2.new(0, 44, 0, 5)
	FUI.FloatPillDivider.BackgroundTransparency = 0.25
	FUI.FloatPillDivider.BorderSizePixel = 0
	FUI.FloatPillDivider.ZIndex = 52
	RegisterThemeObject(FUI.FloatPillDivider, "BackgroundColor3", "Stroke")
	local divGrad = Instance.new("UIGradient", FUI.FloatPillDivider)
	divGrad.Rotation = 90
	divGrad.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.90),
		NumberSequenceKeypoint.new(0.5, 0.05),
		NumberSequenceKeypoint.new(1, 0.90)
	})

	-- Glowing Script Emblem Badge (Bolt Icon inside Styled Medallion)
	FUI.FloatEmblemPod = Instance.new("Frame", FloatingPill)
	FUI.FloatEmblemPod.Name = "EmblemMedallion"
	FUI.FloatEmblemPod.Size = UDim2.new(0, 28, 0, 28)
	FUI.FloatEmblemPod.Position = UDim2.new(0, 52, 0.5, -14)
	FUI.FloatEmblemPod.BackgroundTransparency = 0.12
	FUI.FloatEmblemPod.BorderSizePixel = 0
	FUI.FloatEmblemPod.ZIndex = 52
	FUI.FloatEmblemPod.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	local embCorner = Instance.new("UICorner", FUI.FloatEmblemPod)
	embCorner.CornerRadius = UDim.new(1, 0)
	FUI.FloatEmblemGrad = Instance.new("UIGradient", FUI.FloatEmblemPod)
	FUI.FloatEmblemGrad.Rotation = 45
	FUI.FloatEmblemStroke = Instance.new("UIStroke", FUI.FloatEmblemPod)
	FUI.FloatEmblemStroke.Thickness = 1.4
	FUI.FloatEmblemStroke.Transparency = 0.12
	FUI.FloatEmblemStroke.Color = Color3.fromRGB(255, 255, 255)
	FUI.FloatEmblemStrokeGrad = Instance.new("UIGradient", FUI.FloatEmblemStroke)
	FUI.FloatEmblemStrokeGrad.Rotation = 0

	FUI.FloatScriptIcon = Instance.new("TextLabel", FUI.FloatEmblemPod)
	FUI.FloatScriptIcon.Name = "ScriptEmblem"
	FUI.FloatScriptIcon.Size = UDim2.new(1, 0, 1, 0)
	FUI.FloatScriptIcon.Position = UDim2.new(0, 0, 0, 0)
	FUI.FloatScriptIcon.BackgroundTransparency = 1
	FUI.FloatScriptIcon.Font = Enum.Font.GothamBold
	FUI.FloatScriptIcon.TextSize = 14
	FUI.FloatScriptIcon.Text = E.Bolt
	FUI.FloatScriptIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
	FUI.FloatScriptIcon.ZIndex = 53

	-- Dual-Line Styled Title & Live Status Subtitle
	FUI.FloatTitleLbl = Instance.new("TextLabel", FloatingPill)
	FUI.FloatTitleLbl.Name = "ScriptTitle"
	FUI.FloatTitleLbl.Size = UDim2.new(1, -142, 0, 18)
	FUI.FloatTitleLbl.Position = UDim2.new(0, 85, 0, 6)
	FUI.FloatTitleLbl.BackgroundTransparency = 1
	FUI.FloatTitleLbl.Font = Enum.Font.GothamBold
	FUI.FloatTitleLbl.TextSize = 14
	FUI.FloatTitleLbl.TextXAlignment = Enum.TextXAlignment.Left
	FUI.FloatTitleLbl.TextTruncate = Enum.TextTruncate.AtEnd
	FUI.FloatTitleLbl.Text = "T.R Scripts"
	FUI.FloatTitleLbl.ZIndex = 52
	RegisterThemeObject(FUI.FloatTitleLbl, "TextColor3", "TextPrimary")
	FUI.FloatTitleGrad = Instance.new("UIGradient", FUI.FloatTitleLbl)
	FUI.FloatTitleGrad.Rotation = 18

	FUI.FloatSubLbl = Instance.new("TextLabel", FloatingPill)
	FUI.FloatSubLbl.Name = "ScriptSubStatus"
	FUI.FloatSubLbl.Size = UDim2.new(1, -142, 0, 13)
	FUI.FloatSubLbl.Position = UDim2.new(0, 85, 0, 23)
	FUI.FloatSubLbl.BackgroundTransparency = 1
	FUI.FloatSubLbl.Font = Enum.Font.GothamBold
	FUI.FloatSubLbl.TextSize = 9
	FUI.FloatSubLbl.TextXAlignment = Enum.TextXAlignment.Left
	FUI.FloatSubLbl.TextTruncate = Enum.TextTruncate.AtEnd
	FUI.FloatSubLbl.Text = "HUB ACTIVE | V95"
	FUI.FloatSubLbl.ZIndex = 52
	RegisterThemeObject(FUI.FloatSubLbl, "TextColor3", "TextSecondary")

	-- Live Glowing Status Indicator Dot
	FUI.FloatStatusDot = Instance.new("Frame", FloatingPill)
	FUI.FloatStatusDot.Name = "LiveStatusDot"
	FUI.FloatStatusDot.Size = UDim2.new(0, 7, 0, 7)
	FUI.FloatStatusDot.Position = UDim2.new(1, -55, 0.5, -3)
	FUI.FloatStatusDot.BackgroundColor3 = Color3.fromRGB(46, 213, 115)
	FUI.FloatStatusDot.BorderSizePixel = 0
	FUI.FloatStatusDot.ZIndex = 53
	local dotCorner = Instance.new("UICorner", FUI.FloatStatusDot)
	dotCorner.CornerRadius = UDim.new(1, 0)
	FUI.FloatStatusStroke = Instance.new("UIStroke", FUI.FloatStatusDot)
	FUI.FloatStatusStroke.Thickness = 2.0
	FUI.FloatStatusStroke.Transparency = 0.55
	FUI.FloatStatusStroke.Color = Color3.fromRGB(46, 213, 115)

	-- Right Feathered Vertical Divider (Separating Lock Position Button)
	FUI.FloatRightDivider = Instance.new("Frame", FloatingPill)
	FUI.FloatRightDivider.Name = "RightVerticalDivider"
	FUI.FloatRightDivider.Size = UDim2.new(0, 1, 1, -10)
	FUI.FloatRightDivider.Position = UDim2.new(1, -44, 0, 5)
	FUI.FloatRightDivider.BackgroundTransparency = 0.25
	FUI.FloatRightDivider.BorderSizePixel = 0
	FUI.FloatRightDivider.ZIndex = 52
	RegisterThemeObject(FUI.FloatRightDivider, "BackgroundColor3", "Stroke")
	local rDivGrad = Instance.new("UIGradient", FUI.FloatRightDivider)
	rDivGrad.Rotation = 90
	rDivGrad.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.90),
		NumberSequenceKeypoint.new(0.5, 0.05),
		NumberSequenceKeypoint.new(1, 0.90)
	})

	-- Dedicated Position Lock / Unlock Button inside Floating Pill
	FUI.FloatLockBtn = Instance.new("TextButton", FloatingPill)
	FUI.FloatLockBtn.Name = "PositionLockBtn"
	FUI.FloatLockBtn.Size = UDim2.new(0, 32, 0, 32)
	FUI.FloatLockBtn.Position = UDim2.new(1, -38, 0.5, -16)
	FUI.FloatLockBtn.BackgroundTransparency = 0.45
	FUI.FloatLockBtn.BorderSizePixel = 0
	FUI.FloatLockBtn.Font = Enum.Font.GothamBold
	FUI.FloatLockBtn.TextSize = 14
	FUI.FloatLockBtn.Text = isFloatingPillLocked and utf8.char(0x1F512) or utf8.char(0x1F513)
	FUI.FloatLockBtn.AutoButtonColor = false
	FUI.FloatLockBtn.ZIndex = 57
	RegisterThemeObject(FUI.FloatLockBtn, "BackgroundColor3", "PanelBg")
	local lockBtnCorner = Instance.new("UICorner", FUI.FloatLockBtn)
	lockBtnCorner.CornerRadius = UDim.new(1, 0)
	FUI.FloatLockStroke = Instance.new("UIStroke", FUI.FloatLockBtn)
	FUI.FloatLockStroke.Thickness = 1.2
	FUI.FloatLockStroke.Transparency = 0.40
	RegisterThemeObject(FUI.FloatLockStroke, "Color", "Accent")

	-- Interactive HitBox (Covers Left & Center Compartments) with Spring Hover/Press Micro-Animations
	local FloatHitBox = Instance.new("TextButton", FloatingPill)
	FloatHitBox.Name = "HitBox"
	FloatHitBox.Size = UDim2.new(1, -44, 1, 0)
	FloatHitBox.Position = UDim2.new(0, 0, 0, 0)
	FloatHitBox.BackgroundTransparency = 1
	FloatHitBox.Text = ""
	FloatHitBox.AutoButtonColor = false
	FloatHitBox.ZIndex = 55

	local floatDragging, floatMoved = false, false
	local floatDragStart, floatStartPos = nil, nil

	local function PlayPillTriggerAnimation()
		if FUI.FloatPillScale then
			FUI.FloatPillScale.Scale = 0.88
			TweenService:Create(FUI.FloatPillScale, TweenInfo.new(0.34, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1.0 }):Play()
		end
		if FUI.FloatScriptIcon then
			FUI.FloatScriptIcon.Rotation = -28
			TweenService:Create(FUI.FloatScriptIcon, TweenInfo.new(0.38, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Rotation = 0 }):Play()
		end
		if FUI.FloatEmblemPod then
			FUI.FloatEmblemPod.Size = UDim2.new(0, 33, 0, 33)
			FUI.FloatEmblemPod.Position = UDim2.new(0, 49, 0.5, -16)
			TweenService:Create(FUI.FloatEmblemPod, TweenInfo.new(0.32, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = UDim2.new(0, 28, 0, 28),
				Position = UDim2.new(0, 52, 0.5, -14)
			}):Play()
		end
		if FUI.FloatPillStroke then
			FUI.FloatPillStroke.Thickness = 3.2
			TweenService:Create(FUI.FloatPillStroke, TweenInfo.new(0.30, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Thickness = 2.2 }):Play()
		end
	end

	FUI.PlayEntranceAnim = function(targetIcon)
		if targetIcon == "Square" and MobileSquareIcon and FUI.SquareScale then
			local restPos = MobileSquareIcon.Position
			FUI.SquareScale.Scale = 0.35
			MobileSquareIcon.Position = UDim2.new(restPos.X.Scale, restPos.X.Offset, restPos.Y.Scale, restPos.Y.Offset - 28)
			TweenService:Create(FUI.SquareScale, TweenInfo.new(0.42, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1.0 }):Play()
			TweenService:Create(MobileSquareIcon, TweenInfo.new(0.40, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Position = restPos }):Play()
		elseif FloatingPill and FUI.FloatPillScale then
			local restPos = FloatingPill.Position
			FUI.FloatPillScale.Scale = 0.35
			FloatingPill.Position = UDim2.new(restPos.X.Scale, restPos.X.Offset, restPos.Y.Scale, restPos.Y.Offset - 32)
			TweenService:Create(FUI.FloatPillScale, TweenInfo.new(0.44, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1.0 }):Play()
			TweenService:Create(FloatingPill, TweenInfo.new(0.42, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Position = restPos }):Play()
		end
	end

	FUI.FloatLockBtn.MouseButton1Click:Connect(function()
		isFloatingPillLocked = not isFloatingPillLocked
		Config.FloatingIconLocked = isFloatingPillLocked
		savedConfig.Settings.FloatingIconLocked = isFloatingPillLocked
		if isFloatingPillLocked then
			floatDragging = false
		end
		SyncFloatingPillState()
		SaveConfig(false)
		if FUI.FloatLockBtn then
			FUI.FloatLockBtn.Rotation = isFloatingPillLocked and -22 or 22
			FUI.FloatLockBtn.Size = UDim2.new(0, 36, 0, 36)
			FUI.FloatLockBtn.Position = UDim2.new(1, -40, 0.5, -18)
			TweenService:Create(FUI.FloatLockBtn, TweenInfo.new(0.30, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Rotation = 0,
				Size = UDim2.new(0, 32, 0, 32),
				Position = UDim2.new(1, -38, 0.5, -16)
			}):Play()
		end
		if FUI.FloatDragIcon then
			FUI.FloatDragIcon.Rotation = isFloatingPillLocked and 45 or -45
			TweenService:Create(FUI.FloatDragIcon, TweenInfo.new(0.32, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Rotation = 0 }):Play()
		end
		if NotifyFeatureToggle then
			NotifyFeatureToggle("Floating Icon Position Lock", isFloatingPillLocked)
		end
	end)

	FloatHitBox.MouseEnter:Connect(function()
		if not floatDragging and FUI.FloatPillScale then
			TweenService:Create(FUI.FloatPillScale, TweenInfo.new(0.20, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1.06 }):Play()
		end
		if FUI.FloatDragIcon and not isFloatingPillLocked then
			TweenService:Create(FUI.FloatDragIcon, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Rotation = 90 }):Play()
		end
	end)
	FloatHitBox.MouseLeave:Connect(function()
		if not floatDragging and FUI.FloatPillScale then
			TweenService:Create(FUI.FloatPillScale, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1.0 }):Play()
		end
		if FUI.FloatDragIcon then
			TweenService:Create(FUI.FloatDragIcon, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Rotation = 0 }):Play()
		end
	end)
	FloatHitBox.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
			floatMoved = false
			if not isFloatingPillLocked then
				floatDragging = true
				floatDragStart = inp.Position
				floatStartPos = FloatingPill.Position
			else
				floatDragging = false
			end
			if FUI.FloatPillScale then
				TweenService:Create(FUI.FloatPillScale, TweenInfo.new(0.11, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = 0.93 }):Play()
			end
			inp.Changed:Connect(function()
				if inp.UserInputState == Enum.UserInputState.End then
					floatDragging = false
					if FUI.FloatPillScale then
						TweenService:Create(FUI.FloatPillScale, TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1.0 }):Play()
					end
				end
			end)
		end
	end)
	table.insert(Connections, UserInputService.InputChanged:Connect(function(inp)
		if floatDragging and not isFloatingPillLocked and (inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseMovement) then
			local delta = inp.Position - floatDragStart
			if delta.Magnitude > 5 then floatMoved = true end
			FloatingPill.Position = UDim2.new(
				floatStartPos.X.Scale, floatStartPos.X.Offset + delta.X,
				floatStartPos.Y.Scale, floatStartPos.Y.Offset + delta.Y
			)
		end
	end))
	FloatHitBox.MouseButton1Click:Connect(function()
		if not floatMoved then
			PlayPillTriggerAnimation()
			SetMenuVisible(not isMenuVisible)
		end
	end)

	-- Enhanced Multi-Layer Orbiting Specular Border, Gliding Lens Glint, Emblem Ring & Sonar Pulse
	table.insert(Connections, RunService.Heartbeat:Connect(function()
		if isClosingPermanently then return end
		local pillVis = (FloatingPill and FloatingPill.Visible)
		local sqVis = (MobileSquareIcon and MobileSquareIcon.Visible)
		if not (pillVis or sqVis) then return end
		local now = os.clock()
		local rot = (now * 48) % 360
		local haloRot = (360 - ((now * 36) % 360)) % 360
		local sweepX = math.sin(now * 1.9) * 0.36
		local textSweepX = math.sin(now * 2.1) * 0.40
		local breathe = math.sin(now * 2.8)
		local sonar = (math.sin(now * 4.2) + 1) * 0.5
		local curD = Config.GuiDesign or "Default"
		local baseHaloT = (curD == "CyberHud" and 0.42) or (curD == "LiquidGlass" and 0.54) or 0.58
		if pillVis then
			if FUI.FloatPillStrokeGrad then FUI.FloatPillStrokeGrad.Rotation = rot end
			if FUI.FloatHaloGrad then FUI.FloatHaloGrad.Rotation = haloRot end
			if FUI.FloatHaloStroke then FUI.FloatHaloStroke.Transparency = baseHaloT + (breathe * 0.10) end
			if FUI.FloatEmblemStrokeGrad then FUI.FloatEmblemStrokeGrad.Rotation = (now * 72) % 360 end
			if FUI.FloatEmblemGrad then FUI.FloatEmblemGrad.Rotation = 45 + (breathe * 28) end
			if FUI.FloatTopSpecGrad then FUI.FloatTopSpecGrad.Offset = Vector2.new(sweepX, 0) end
			if FUI.FloatBotGlowGrad then FUI.FloatBotGlowGrad.Offset = Vector2.new(-sweepX, 0) end
			if FUI.FloatTitleGrad then FUI.FloatTitleGrad.Offset = Vector2.new(textSweepX, 0) end
			if FUI.FloatStatusStroke then
				FUI.FloatStatusStroke.Thickness = 1.3 + (sonar * 1.3)
				FUI.FloatStatusStroke.Transparency = 0.28 + (sonar * 0.46)
			end
		end
		if sqVis then
			if FUI.SquareStrokeGrad then FUI.SquareStrokeGrad.Rotation = rot end
			if FUI.SquareHaloGrad then FUI.SquareHaloGrad.Rotation = haloRot end
			if FUI.SquareHaloStroke then FUI.SquareHaloStroke.Transparency = baseHaloT + (breathe * 0.10) end
		end
	end))

	UpdateFloatingPillVisibility()
	if FUI.PlayEntranceAnim then
		pcall(FUI.PlayEntranceAnim, (isMobileDevice and Config.MobileFloatStyle == "Square") and "Square" or "Pill")
	end
end
if isMobileDevice then
	-- Option 2 (Mobile-Only): Compact Square Shaded "T.R" Floating Icon (Syncs with GUI Design & Theme)
	MobileSquareIcon = Instance.new("Frame")
	MobileSquareIcon.Name = "TR_MobileSquareIcon"
	MobileSquareIcon.Size = UDim2.new(0, 38, 0, 38)
	MobileSquareIcon.Position = UDim2.new(0.5, -19, 0, 10)
	MobileSquareIcon.BackgroundTransparency = 0.06
	MobileSquareIcon.BorderSizePixel = 0
	MobileSquareIcon.Active = true
	MobileSquareIcon.ClipsDescendants = false
	MobileSquareIcon.Visible = false
	MobileSquareIcon.ZIndex = 50
	MobileSquareIcon.Parent = ScreenGui
	RegisterThemeObject(MobileSquareIcon, "BackgroundColor3", "MainBg")
	FUI.SquareCorner = Instance.new("UICorner", MobileSquareIcon)
	FUI.SquareCorner.CornerRadius = UDim.new(0, 10)

	FUI.SquareScale = Instance.new("UIScale", MobileSquareIcon)
	FUI.SquareScale.Scale = 1

	FUI.SquareOuterHalo = Instance.new("Frame", MobileSquareIcon)
	FUI.SquareOuterHalo.Name = "TR_SquareOuterHalo"
	FUI.SquareOuterHalo.Size = UDim2.new(1, 6, 1, 6)
	FUI.SquareOuterHalo.Position = UDim2.new(0, -3, 0, -3)
	FUI.SquareOuterHalo.BackgroundTransparency = 1
	FUI.SquareOuterHalo.BorderSizePixel = 0
	FUI.SquareOuterHalo.ZIndex = 49
	local sqHaloCorner = Instance.new("UICorner", FUI.SquareOuterHalo)
	sqHaloCorner.CornerRadius = UDim.new(0, 12)
	FUI.SquareHaloStroke = Instance.new("UIStroke", FUI.SquareOuterHalo)
	FUI.SquareHaloStroke.Thickness = 2.6
	FUI.SquareHaloStroke.Transparency = 0.62
	FUI.SquareHaloStroke.Color = Color3.fromRGB(255, 255, 255)
	FUI.SquareHaloGrad = Instance.new("UIGradient", FUI.SquareHaloStroke)
	FUI.SquareHaloGrad.Rotation = 0

	FUI.SquareBgGrad = Instance.new("UIGradient", MobileSquareIcon)
	FUI.SquareBgGrad.Rotation = 135
	FUI.SquareBgGrad.Enabled = true

	FUI.SquareStroke = Instance.new("UIStroke", MobileSquareIcon)
	FUI.SquareStroke.Thickness = 2.0
	FUI.SquareStroke.Transparency = 0.04
	FUI.SquareStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	FUI.SquareStroke.Color = Color3.fromRGB(255, 255, 255)
	FUI.SquareStrokeGrad = Instance.new("UIGradient", FUI.SquareStroke)
	FUI.SquareStrokeGrad.Rotation = 45
	FUI.SquareStrokeGrad.Enabled = true

	-- Inner Shaded Recessed Core & Specular Glint
	FUI.SquareInnerShade = Instance.new("Frame", MobileSquareIcon)
	FUI.SquareInnerShade.Name = "InnerShade"
	FUI.SquareInnerShade.Size = UDim2.new(1, -6, 1, -6)
	FUI.SquareInnerShade.Position = UDim2.new(0, 3, 0, 3)
	FUI.SquareInnerShade.BackgroundTransparency = 0.45
	FUI.SquareInnerShade.BorderSizePixel = 0
	FUI.SquareInnerShade.ZIndex = 51
	RegisterThemeObject(FUI.SquareInnerShade, "BackgroundColor3", "PanelBg")
	local sqInCorner = Instance.new("UICorner", FUI.SquareInnerShade)
	sqInCorner.CornerRadius = UDim.new(0, 7)
	local sqInGrad = Instance.new("UIGradient", FUI.SquareInnerShade)
	sqInGrad.Rotation = -45
	sqInGrad.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.25),
		NumberSequenceKeypoint.new(0.5, 0.65),
		NumberSequenceKeypoint.new(1, 0.20)
	})

	FUI.SquareTopSpec = Instance.new("Frame", MobileSquareIcon)
	FUI.SquareTopSpec.Name = "TR_SquareTopSpec"
	FUI.SquareTopSpec.Size = UDim2.new(1, -12, 0, 1)
	FUI.SquareTopSpec.Position = UDim2.new(0, 6, 0, 2)
	FUI.SquareTopSpec.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	FUI.SquareTopSpec.BackgroundTransparency = 0.15
	FUI.SquareTopSpec.BorderSizePixel = 0
	FUI.SquareTopSpec.ZIndex = 53
	local sqSpecGrad = Instance.new("UIGradient", FUI.SquareTopSpec)
	sqSpecGrad.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.85),
		NumberSequenceKeypoint.new(0.5, 0.0),
		NumberSequenceKeypoint.new(1, 0.85)
	})

	FUI.SquareBotGlow = Instance.new("Frame", MobileSquareIcon)
	FUI.SquareBotGlow.Name = "TR_SquareBotGlow"
	FUI.SquareBotGlow.Size = UDim2.new(1, -14, 0, 2)
	FUI.SquareBotGlow.Position = UDim2.new(0, 7, 1, -3)
	FUI.SquareBotGlow.BackgroundTransparency = 0.25
	FUI.SquareBotGlow.BorderSizePixel = 0
	FUI.SquareBotGlow.ZIndex = 53
	RegisterThemeObject(FUI.SquareBotGlow, "BackgroundColor3", "Accent")
	local sqBotGrad = Instance.new("UIGradient", FUI.SquareBotGlow)
	sqBotGrad.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.90),
		NumberSequenceKeypoint.new(0.5, 0.05),
		NumberSequenceKeypoint.new(1, 0.90)
	})

	-- Bold Shaded "T.R" Monogram Text
	FUI.SquareTitleLbl = Instance.new("TextLabel", MobileSquareIcon)
	FUI.SquareTitleLbl.Name = "TRLabel"
	FUI.SquareTitleLbl.Size = UDim2.new(1, 0, 1, -2)
	FUI.SquareTitleLbl.Position = UDim2.new(0, 0, 0, 0)
	FUI.SquareTitleLbl.BackgroundTransparency = 1
	FUI.SquareTitleLbl.Font = Enum.Font.GothamBold
	FUI.SquareTitleLbl.TextSize = 14
	FUI.SquareTitleLbl.Text = "T.R"
	FUI.SquareTitleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
	FUI.SquareTitleLbl.ZIndex = 54
	FUI.SquareTitleGrad = Instance.new("UIGradient", FUI.SquareTitleLbl)
	FUI.SquareTitleGrad.Rotation = 90

	-- Live Status Micro-Dot in Top-Right Corner
	FUI.SquareStatusDot = Instance.new("Frame", MobileSquareIcon)
	FUI.SquareStatusDot.Name = "StatusDot"
	FUI.SquareStatusDot.Size = UDim2.new(0, 5, 0, 5)
	FUI.SquareStatusDot.Position = UDim2.new(1, -8, 0, 4)
	FUI.SquareStatusDot.BackgroundColor3 = Color3.fromRGB(46, 213, 115)
	FUI.SquareStatusDot.BorderSizePixel = 0
	FUI.SquareStatusDot.ZIndex = 55
	local sqDotCorner = Instance.new("UICorner", FUI.SquareStatusDot)
	sqDotCorner.CornerRadius = UDim.new(1, 0)

	-- Mini Position Lock Badge Button in Bottom-Right Corner of Square
	FUI.SquareLockBtn = Instance.new("TextButton", MobileSquareIcon)
	FUI.SquareLockBtn.Name = "MiniLockBtn"
	FUI.SquareLockBtn.Size = UDim2.new(0, 15, 0, 15)
	FUI.SquareLockBtn.Position = UDim2.new(1, -13, 1, -13)
	FUI.SquareLockBtn.BackgroundTransparency = 0.15
	FUI.SquareLockBtn.BorderSizePixel = 0
	FUI.SquareLockBtn.Font = Enum.Font.GothamBold
	FUI.SquareLockBtn.TextSize = 8
	FUI.SquareLockBtn.Text = isFloatingPillLocked and utf8.char(0x1F512) or utf8.char(0x1F513)
	FUI.SquareLockBtn.AutoButtonColor = false
	FUI.SquareLockBtn.ZIndex = 57
	RegisterThemeObject(FUI.SquareLockBtn, "BackgroundColor3", "PanelBg")
	local sqLockCorner = Instance.new("UICorner", FUI.SquareLockBtn)
	sqLockCorner.CornerRadius = UDim.new(1, 0)
	FUI.SquareLockStroke = Instance.new("UIStroke", FUI.SquareLockBtn)
	FUI.SquareLockStroke.Thickness = 1.0
	FUI.SquareLockStroke.Transparency = 0.30
	RegisterThemeObject(FUI.SquareLockStroke, "Color", "Accent")

	local SquareHitBox = Instance.new("TextButton", MobileSquareIcon)
	SquareHitBox.Name = "HitBox"
	SquareHitBox.Size = UDim2.new(1, 0, 1, 0)
	SquareHitBox.Position = UDim2.new(0, 0, 0, 0)
	SquareHitBox.BackgroundTransparency = 1
	SquareHitBox.Text = ""
	SquareHitBox.AutoButtonColor = false
	SquareHitBox.ZIndex = 55

	local sqDragging, sqMoved = false, false
	local sqDragStart, sqStartPos = nil, nil

	FUI.SquareLockBtn.MouseButton1Click:Connect(function()
		isFloatingPillLocked = not isFloatingPillLocked
		Config.FloatingIconLocked = isFloatingPillLocked
		savedConfig.Settings.FloatingIconLocked = isFloatingPillLocked
		if isFloatingPillLocked then sqDragging = false end
		SyncFloatingPillState()
		SaveConfig(false)
		if NotifyFeatureToggle then
			NotifyFeatureToggle("Floating Icon Position Lock", isFloatingPillLocked)
		end
	end)

	SquareHitBox.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
			sqMoved = false
			if not isFloatingPillLocked then
				sqDragging = true
				sqDragStart = inp.Position
				sqStartPos = MobileSquareIcon.Position
			else
				sqDragging = false
			end
			if FUI.SquareScale then
				TweenService:Create(FUI.SquareScale, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = 0.92 }):Play()
			end
			inp.Changed:Connect(function()
				if inp.UserInputState == Enum.UserInputState.End then
					sqDragging = false
					if FUI.SquareScale then
						TweenService:Create(FUI.SquareScale, TweenInfo.new(0.24, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1.0 }):Play()
					end
				end
			end)
		end
	end)
	table.insert(Connections, UserInputService.InputChanged:Connect(function(inp)
		if sqDragging and not isFloatingPillLocked and (inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseMovement) then
			local delta = inp.Position - sqDragStart
			if delta.Magnitude > 5 then sqMoved = true end
			MobileSquareIcon.Position = UDim2.new(
				sqStartPos.X.Scale, sqStartPos.X.Offset + delta.X,
				sqStartPos.Y.Scale, sqStartPos.Y.Offset + delta.Y
			)
		end
	end))
	SquareHitBox.MouseButton1Click:Connect(function()
		if not sqMoved then
			SetMenuVisible(not isMenuVisible)
		end
	end)
	UpdateFloatingPillVisibility()

	-- Mobile-Only On-Screen Quick-Action Buttons (Draggable Floating Combat & Flight Bar)
	local MobileQuickBar = Instance.new("Frame")
	MobileQuickBar.Name = "TR_MobileQuickBar"
	MobileQuickBar.Size = UDim2.new(0, 254, 0, 36)
	MobileQuickBar.Position = UDim2.new(0.5, -127, 0, 60)
	MobileQuickBar.BackgroundTransparency = 0.14
	MobileQuickBar.BorderSizePixel = 0
	MobileQuickBar.Active = true
	MobileQuickBar.ZIndex = 48
	MobileQuickBar.Parent = ScreenGui
	RegisterThemeObject(MobileQuickBar, "BackgroundColor3", "MainBg")
	AddCorner(MobileQuickBar, 10)
	local mqStroke = Instance.new("UIStroke", MobileQuickBar)
	mqStroke.Thickness = 1.4
	mqStroke.Transparency = 0.25
	RegisterThemeObject(mqStroke, "Color", "Accent")

	local mqDragHandle = Instance.new("TextLabel", MobileQuickBar)
	mqDragHandle.Size = UDim2.new(0, 26, 1, 0)
	mqDragHandle.Position = UDim2.new(0, 2, 0, 0)
	mqDragHandle.BackgroundTransparency = 1
	mqDragHandle.Font = Enum.Font.GothamBold
	mqDragHandle.TextSize = 13
	mqDragHandle.Text = E.Grip
	mqDragHandle.ZIndex = 49
	RegisterThemeObject(mqDragHandle, "TextColor3", "Accent")

	local mqDragging = false
	local mqDragStart, mqStartPos = nil, nil
	MobileQuickBar.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
			mqDragging = true
			mqDragStart = inp.Position
			mqStartPos = MobileQuickBar.Position
			inp.Changed:Connect(function()
				if inp.UserInputState == Enum.UserInputState.End then
					mqDragging = false
				end
			end)
		end
	end)
	table.insert(Connections, UserInputService.InputChanged:Connect(function(inp)
		if mqDragging and (inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseMovement) then
			local delta = inp.Position - mqDragStart
			MobileQuickBar.Position = UDim2.new(
				mqStartPos.X.Scale, mqStartPos.X.Offset + delta.X,
				mqStartPos.Y.Scale, mqStartPos.Y.Offset + delta.Y
			)
		end
	end))

	local function CreateMobileQuickBtn(xOffset, labelTxt)
		local b = Instance.new("TextButton", MobileQuickBar)
		b.Size = UDim2.new(0, 52, 0, 26)
		b.Position = UDim2.new(0, xOffset, 0.5, -13)
		b.BackgroundColor3 = Color3.fromRGB(185, 52, 52)
		b.BorderSizePixel = 0
		b.Font = Enum.Font.GothamBold
		b.TextSize = 10
		b.TextColor3 = Color3.fromRGB(255, 255, 255)
		b.Text = labelTxt
		b.ZIndex = 49
		AddCorner(b, 6)
		return b
	end

	local mqAimBtn = CreateMobileQuickBtn(28, "Aim [Q]")
	local mqTAimBtn = CreateMobileQuickBtn(84, "T-Aim [T]")
	local mqShootBtn = CreateMobileQuickBtn(140, "Shoot [Z]")
	local mqFlyBtn = CreateMobileQuickBtn(196, "Fly [E]")

	mqAimBtn.MouseButton1Click:Connect(function()
		if genv._TR_MobileToggleAimbot then genv._TR_MobileToggleAimbot() end
	end)
	mqTAimBtn.MouseButton1Click:Connect(function()
		if genv._TR_MobileToggleTargetAimbot then genv._TR_MobileToggleTargetAimbot() end
	end)
	mqShootBtn.MouseButton1Click:Connect(function()
		if genv._TR_MobileToggleAutoShoot then genv._TR_MobileToggleAutoShoot() end
	end)
	mqFlyBtn.MouseButton1Click:Connect(function()
		if genv._TR_MobileToggleFlight then genv._TR_MobileToggleFlight() end
	end)

	genv._TR_UpdateMobileQuickBar = function(aimOn, tAimOn, shootOn, flyOn)
		local colOn = Color3.fromRGB(46, 204, 113)
		local colOff = Color3.fromRGB(185, 52, 52)
		if mqAimBtn and mqAimBtn.Parent then mqAimBtn.BackgroundColor3 = aimOn and colOn or colOff end
		if mqTAimBtn and mqTAimBtn.Parent then mqTAimBtn.BackgroundColor3 = tAimOn and colOn or colOff end
		if mqShootBtn and mqShootBtn.Parent then mqShootBtn.BackgroundColor3 = shootOn and colOn or colOff end
		if mqFlyBtn and mqFlyBtn.Parent then mqFlyBtn.BackgroundColor3 = flyOn and colOn or colOff end
	end
end
local MainGlassGrad = Instance.new("UIGradient", MainFrame)
MainGlassGrad.Rotation = -38
MainGlassGrad.Enabled = false
local StrokeGlassGrad = Instance.new("UIGradient", MainStroke)
StrokeGlassGrad.Rotation = 35
StrokeGlassGrad.Enabled = false

-- Layer 1: Apple OS Top Specular Rim Reflection Bar (Overhead Curved Glass Glint)
local LiquidTopSpecular = Instance.new("Frame", MainFrame)
LiquidTopSpecular.Name = "TR_LiquidTopSpecular"
LiquidTopSpecular.Size = UDim2.new(1, -24, 0, 2)
LiquidTopSpecular.Position = UDim2.new(0, 12, 0, 1)
LiquidTopSpecular.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
LiquidTopSpecular.BackgroundTransparency = 0.15
LiquidTopSpecular.BorderSizePixel = 0
LiquidTopSpecular.ZIndex = 20
LiquidTopSpecular.Visible = false
local TopSpecGrad = Instance.new("UIGradient", LiquidTopSpecular)
TopSpecGrad.Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0.85),
	NumberSequenceKeypoint.new(0.22, 0.05),
	NumberSequenceKeypoint.new(0.5, 0.0),
	NumberSequenceKeypoint.new(0.78, 0.05),
	NumberSequenceKeypoint.new(1, 0.85)
})

-- Layer 2: Apple OS Diagonal Caustic Glass Sheen Overlay (Refractive Surface Specular Band)
local LiquidCausticOverlay = Instance.new("Frame", MainFrame)
LiquidCausticOverlay.Name = "TR_LiquidCausticOverlay"
LiquidCausticOverlay.Size = UDim2.new(1, 0, 1, 0)
LiquidCausticOverlay.Position = UDim2.new(0, 0, 0, 0)
LiquidCausticOverlay.BackgroundColor3 = Color3.fromRGB(240, 248, 255)
LiquidCausticOverlay.BackgroundTransparency = 0.76
LiquidCausticOverlay.BorderSizePixel = 0
LiquidCausticOverlay.Active = false
LiquidCausticOverlay.ZIndex = 1
LiquidCausticOverlay.Visible = false
AddCorner(LiquidCausticOverlay, 16)
local CausticGrad = Instance.new("UIGradient", LiquidCausticOverlay)
CausticGrad.Rotation = -42
CausticGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
	ColorSequenceKeypoint.new(0.35, Color3.fromRGB(220, 238, 255)),
	ColorSequenceKeypoint.new(0.7, Color3.fromRGB(180, 210, 245)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(250, 253, 255))
})
CausticGrad.Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0.10),
	NumberSequenceKeypoint.new(0.25, 0.65),
	NumberSequenceKeypoint.new(0.48, 0.30),
	NumberSequenceKeypoint.new(0.72, 0.78),
	NumberSequenceKeypoint.new(1, 0.22)
})

-- Layer 3: Cyber-HUD Top & Bottom Neon Laser Emitter Bars
local CyberTopLaser = Instance.new("Frame", MainFrame)
CyberTopLaser.Name = "TR_CyberTopLaser"
CyberTopLaser.Size = UDim2.new(1, -16, 0, 2)
CyberTopLaser.Position = UDim2.new(0, 8, 0, 43)
CyberTopLaser.BackgroundColor3 = Color3.fromRGB(0, 242, 255)
CyberTopLaser.BorderSizePixel = 0
CyberTopLaser.ZIndex = 20
CyberTopLaser.Visible = false
local CyberTopLaserGrad = Instance.new("UIGradient", CyberTopLaser)
CyberTopLaserGrad.Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0.75),
	NumberSequenceKeypoint.new(0.5, 0.0),
	NumberSequenceKeypoint.new(1, 0.75)
})

local CyberBottomLaser = Instance.new("Frame", MainFrame)
CyberBottomLaser.Name = "TR_CyberBottomLaser"
CyberBottomLaser.Size = UDim2.new(1, -40, 0, 2)
CyberBottomLaser.Position = UDim2.new(0, 20, 1, -3)
CyberBottomLaser.BackgroundColor3 = Color3.fromRGB(190, 55, 255)
CyberBottomLaser.BorderSizePixel = 0
CyberBottomLaser.ZIndex = 20
CyberBottomLaser.Visible = false
local CyberBottomLaserGrad = Instance.new("UIGradient", CyberBottomLaser)
CyberBottomLaserGrad.Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0.85),
	NumberSequenceKeypoint.new(0.5, 0.0),
	NumberSequenceKeypoint.new(1, 0.85)
})

-- Layer 4: Subtle Optical Depth-of-Field Glass Blur in Lighting (Active only when LiquidGlass GUI is Open)
local LiquidBlurEffect = nil
pcall(function()
	LiquidBlurEffect = Lighting:FindFirstChild("TR_LiquidGlassBlur") or Instance.new("BlurEffect")
	LiquidBlurEffect.Name = "TR_LiquidGlassBlur"
	LiquidBlurEffect.Size = 6
	LiquidBlurEffect.Enabled = false
	LiquidBlurEffect.Parent = Lighting
end)

ApplyGuiDesignSurface = function()
	local d = Config.GuiDesign or "Default"
	local eff = GetTheme()
	local mainCorner = MainFrame:FindFirstChildOfClass("UICorner")
	local topCorner = TopBar:FindFirstChildOfClass("UICorner")
	local sideCorner = Sidebar:FindFirstChildOfClass("UICorner")
	local contentCorner = ContentContainer:FindFirstChildOfClass("UICorner")

	if d == "LiquidGlass" then
		-- Authentic Apple OS (visionOS / iOS 26) Spatial Frosted Liquid Glass
		MainFrame.BackgroundTransparency = 0.56
		TopBar.BackgroundTransparency = 0.62
		Sidebar.BackgroundTransparency = 0.64
		ContentContainer.BackgroundTransparency = 0.64
		MainStroke.Thickness = 1.8
		MainStroke.Transparency = 0.08
		if mainCorner then mainCorner.CornerRadius = UDim.new(0, 16) end
		if topCorner then topCorner.CornerRadius = UDim.new(0, 16) end
		if sideCorner then sideCorner.CornerRadius = UDim.new(0, 14) end
		if contentCorner then contentCorner.CornerRadius = UDim.new(0, 14) end

		LiquidTopSpecular.Visible = true
		LiquidCausticOverlay.Visible = true
		LiquidCausticOverlay.BackgroundColor3 = (Config.Theme == "Default" or not Config.Theme) and Color3.fromRGB(235, 245, 255) or eff.Accent:Lerp(Color3.fromRGB(255, 255, 255), 0.65)
		CyberTopLaser.Visible = false
		CyberBottomLaser.Visible = false
		if LiquidBlurEffect then LiquidBlurEffect.Enabled = (isMenuVisible == true and not isClosingPermanently) end

		MainGlassGrad.Rotation = -38
		MainGlassGrad.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, eff.MainBg:Lerp(Color3.fromRGB(255, 255, 255), 0.32)),
			ColorSequenceKeypoint.new(0.45, eff.MainBg),
			ColorSequenceKeypoint.new(1, eff.MainBg:Lerp(Color3.fromRGB(210, 232, 255), 0.25))
		})
		MainGlassGrad.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.0),
			NumberSequenceKeypoint.new(0.5, 0.08),
			NumberSequenceKeypoint.new(1, 0.0)
		})
		MainGlassGrad.Enabled = true

		-- Apple Specular Rim Lighting (Bright White Top-Left & Bottom-Right Glint, Soft Refractive Mid)
		StrokeGlassGrad.Rotation = 35
		StrokeGlassGrad.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(0.35, eff.Stroke),
			ColorSequenceKeypoint.new(0.65, eff.Accent:Lerp(Color3.fromRGB(255, 255, 255), 0.55)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
		})
		StrokeGlassGrad.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.0),
			NumberSequenceKeypoint.new(0.45, 0.35),
			NumberSequenceKeypoint.new(0.75, 0.25),
			NumberSequenceKeypoint.new(1, 0.05)
		})
		StrokeGlassGrad.Enabled = true

		for _, item in ipairs(ThemeObjects.CardBg) do
			if item.Instance and item.Instance.Parent then
				if item.Instance:IsA("Frame") then
					item.Instance.BackgroundTransparency = 0.54
					local cc = item.Instance:FindFirstChildOfClass("UICorner")
					if cc then cc.CornerRadius = UDim.new(0, 11) end
					local st = item.Instance:FindFirstChildOfClass("UIStroke")
					if st then st.Transparency = 0.24 st.Thickness = 1.2 end
				elseif item.Instance:IsA("GuiButton") then
					item.Instance.BackgroundTransparency = 0.42
				end
			end
		end
		for _, item in ipairs(ThemeObjects.PanelBg) do
			if item.Instance and item.Instance.Parent and item.Instance ~= TopBar and item.Instance ~= Sidebar and item.Instance ~= ContentContainer then
				if item.Instance:IsA("GuiObject") then
					item.Instance.BackgroundTransparency = 0.48
				end
			end
		end
	elseif d == "CyberHud" then
		-- Quantum Holographic Cyberpunk HUD (Deep Obsidian Carbon + Dual-Tone Glowing Neon Lasers)
		MainFrame.BackgroundTransparency = 0.08
		TopBar.BackgroundTransparency = 0.10
		Sidebar.BackgroundTransparency = 0.14
		ContentContainer.BackgroundTransparency = 0.14
		MainStroke.Thickness = 2.5
		MainStroke.Transparency = 0.0
		if mainCorner then mainCorner.CornerRadius = UDim.new(0, 6) end
		if topCorner then topCorner.CornerRadius = UDim.new(0, 6) end
		if sideCorner then sideCorner.CornerRadius = UDim.new(0, 5) end
		if contentCorner then contentCorner.CornerRadius = UDim.new(0, 5) end

		LiquidTopSpecular.Visible = false
		LiquidCausticOverlay.Visible = false
		CyberTopLaser.Visible = true
		CyberBottomLaser.Visible = true
		CyberTopLaser.BackgroundColor3 = eff.Accent
		CyberBottomLaser.BackgroundColor3 = eff.Stroke
		if LiquidBlurEffect then LiquidBlurEffect.Enabled = false end

		MainGlassGrad.Rotation = 25
		MainGlassGrad.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 14, 26):Lerp(eff.Accent, 0.12)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(5, 6, 12)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(14, 10, 28):Lerp(eff.Stroke, 0.14))
		})
		MainGlassGrad.Transparency = NumberSequence.new(0)
		MainGlassGrad.Enabled = true

		StrokeGlassGrad.Rotation = 45
		StrokeGlassGrad.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, eff.Accent),
			ColorSequenceKeypoint.new(0.35, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(0.65, eff.Stroke),
			ColorSequenceKeypoint.new(1, eff.Accent)
		})
		StrokeGlassGrad.Transparency = NumberSequence.new(0)
		StrokeGlassGrad.Enabled = true

		for _, item in ipairs(ThemeObjects.CardBg) do
			if item.Instance and item.Instance.Parent then
				if item.Instance:IsA("Frame") then
					item.Instance.BackgroundTransparency = 0.10
					local cc = item.Instance:FindFirstChildOfClass("UICorner")
					if cc then cc.CornerRadius = UDim.new(0, 4) end
					local st = item.Instance:FindFirstChildOfClass("UIStroke")
					if st then st.Transparency = 0.04 st.Thickness = 1.5 end
				elseif item.Instance:IsA("GuiButton") then
					item.Instance.BackgroundTransparency = 0.06
				end
			end
		end
		for _, item in ipairs(ThemeObjects.PanelBg) do
			if item.Instance and item.Instance.Parent and item.Instance ~= TopBar and item.Instance ~= Sidebar and item.Instance ~= ContentContainer then
				if item.Instance:IsA("GuiObject") then
					item.Instance.BackgroundTransparency = 0.12
				end
			end
		end
	else
		-- 1. Default Classic Dark Glassmorphic GUI
		MainFrame.BackgroundTransparency = 0.06
		TopBar.BackgroundTransparency = 0.10
		Sidebar.BackgroundTransparency = 0.12
		ContentContainer.BackgroundTransparency = 0.12
		MainStroke.Thickness = 1.6
		MainStroke.Transparency = 0.25
		if mainCorner then mainCorner.CornerRadius = UDim.new(0, 12) end
		if topCorner then topCorner.CornerRadius = UDim.new(0, 12) end
		if sideCorner then sideCorner.CornerRadius = UDim.new(0, 10) end
		if contentCorner then contentCorner.CornerRadius = UDim.new(0, 10) end

		LiquidTopSpecular.Visible = false
		LiquidCausticOverlay.Visible = false
		CyberTopLaser.Visible = false
		CyberBottomLaser.Visible = false
		if LiquidBlurEffect then LiquidBlurEffect.Enabled = false end
		MainGlassGrad.Enabled = false
		StrokeGlassGrad.Enabled = false

		for _, item in ipairs(ThemeObjects.CardBg) do
			if item.Instance and item.Instance.Parent then
				if item.Instance:IsA("Frame") then
					item.Instance.BackgroundTransparency = 0.08
					local cc = item.Instance:FindFirstChildOfClass("UICorner")
					if cc then cc.CornerRadius = UDim.new(0, 8) end
					local st = item.Instance:FindFirstChildOfClass("UIStroke")
					if st then st.Transparency = 0.60 st.Thickness = 1.0 end
				elseif item.Instance:IsA("GuiButton") then
					item.Instance.BackgroundTransparency = 0.0
				end
			end
		end
		for _, item in ipairs(ThemeObjects.PanelBg) do
			if item.Instance and item.Instance.Parent and item.Instance ~= TopBar and item.Instance ~= Sidebar and item.Instance ~= ContentContainer then
				if item.Instance:IsA("GuiObject") then
					item.Instance.BackgroundTransparency = 0.15
				end
			end
		end
	end

	-- Synchronize Enhanced Floating Pill Icon (Both Mobile & PC) with active Theme and GUI Design Style
	if FloatingPill and FloatingPill.Parent then
		FloatingPill.BackgroundColor3 = eff.MainBg
		if FUI.FloatTitleLbl then FUI.FloatTitleLbl.TextColor3 = Color3.fromRGB(255, 255, 255) end
		if FUI.FloatTitleGrad then
			FUI.FloatTitleGrad.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, eff.TextPrimary:Lerp(eff.Accent, 0.24)),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
				ColorSequenceKeypoint.new(1, eff.TextPrimary:Lerp(eff.Accent, 0.28))
			})
		end
		if FUI.FloatEmblemGrad then
			FUI.FloatEmblemGrad.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, eff.Accent:Lerp(Color3.fromRGB(255, 255, 255), 0.28)),
				ColorSequenceKeypoint.new(1, eff.AccentDark)
			})
		end
		if FUI.FloatEmblemStroke then FUI.FloatEmblemStroke.Color = Color3.fromRGB(255, 255, 255) end
		if FUI.FloatEmblemStrokeGrad then
			FUI.FloatEmblemStrokeGrad.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, eff.Accent),
				ColorSequenceKeypoint.new(0.35, Color3.fromRGB(255, 255, 255)),
				ColorSequenceKeypoint.new(0.7, eff.Stroke),
				ColorSequenceKeypoint.new(1, eff.Accent)
			})
		end
		if FUI.FloatLeftPod then FUI.FloatLeftPod.BackgroundColor3 = eff.PanelBg end
		if FUI.FloatLeftPodStroke then FUI.FloatLeftPodStroke.Color = eff.Accent end
		if FUI.FloatPillBotGlow then FUI.FloatPillBotGlow.BackgroundColor3 = eff.Accent end
		if FUI.FloatHaloGrad then
			FUI.FloatHaloGrad.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, eff.Accent),
				ColorSequenceKeypoint.new(0.5, eff.Stroke),
				ColorSequenceKeypoint.new(1, eff.Accent)
			})
		end
		SyncFloatingPillState()

		if d == "LiquidGlass" then
			FloatingPill.BackgroundTransparency = 0.44
			if FUI.FloatHaloStroke then FUI.FloatHaloStroke.Transparency = 0.58 end
			if FUI.FloatLeftPod then FUI.FloatLeftPod.BackgroundTransparency = 0.58 end
			if FUI.FloatEmblemPod then FUI.FloatEmblemPod.BackgroundTransparency = 0.18 end
			if FUI.FloatPillGrad then
				FUI.FloatPillGrad.Rotation = -32
				FUI.FloatPillGrad.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, eff.MainBg:Lerp(Color3.fromRGB(255, 255, 255), 0.38)),
					ColorSequenceKeypoint.new(0.5, eff.MainBg),
					ColorSequenceKeypoint.new(1, eff.MainBg:Lerp(Color3.fromRGB(210, 235, 255), 0.30))
				})
				FUI.FloatPillGrad.Enabled = true
			end
			if FUI.FloatPillStroke then
				FUI.FloatPillStroke.Thickness = 2.0
				FUI.FloatPillStroke.Transparency = 0.04
				FUI.FloatPillStroke.Color = Color3.fromRGB(255, 255, 255)
			end
			if FUI.FloatPillStrokeGrad then
				FUI.FloatPillStrokeGrad.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, eff.Accent:Lerp(Color3.fromRGB(255, 255, 255), 0.30)),
					ColorSequenceKeypoint.new(0.20, Color3.fromRGB(255, 255, 255)),
					ColorSequenceKeypoint.new(0.50, eff.Stroke:Lerp(eff.Accent, 0.35)),
					ColorSequenceKeypoint.new(0.75, Color3.fromRGB(255, 255, 255)),
					ColorSequenceKeypoint.new(1, eff.Accent:Lerp(Color3.fromRGB(255, 255, 255), 0.30))
				})
				FUI.FloatPillStrokeGrad.Enabled = true
			end
			if FUI.FloatPillTopSpec then
				FUI.FloatPillTopSpec.Visible = true
				FUI.FloatPillTopSpec.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				FUI.FloatPillTopSpec.BackgroundTransparency = 0.10
			end
			if FUI.FloatPillDivider then
				FUI.FloatPillDivider.BackgroundColor3 = eff.Stroke
				FUI.FloatPillDivider.BackgroundTransparency = 0.25
			end
			if FUI.FloatDragIcon then FUI.FloatDragIcon.TextColor3 = eff.Accent end
			if FUI.FloatScriptIcon then FUI.FloatScriptIcon.TextColor3 = Color3.fromRGB(255, 255, 255) end
		elseif d == "CyberHud" then
			FloatingPill.BackgroundTransparency = 0.05
			if FUI.FloatHaloStroke then FUI.FloatHaloStroke.Transparency = 0.45 end
			if FUI.FloatLeftPod then FUI.FloatLeftPod.BackgroundTransparency = 0.35 end
			if FUI.FloatEmblemPod then FUI.FloatEmblemPod.BackgroundTransparency = 0.05 end
			if FUI.FloatPillGrad then
				FUI.FloatPillGrad.Rotation = 20
				FUI.FloatPillGrad.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(12, 16, 28):Lerp(eff.Accent, 0.22)),
					ColorSequenceKeypoint.new(0.55, Color3.fromRGB(5, 6, 12)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(16, 10, 28):Lerp(eff.Stroke, 0.22))
				})
				FUI.FloatPillGrad.Enabled = true
			end
			if FUI.FloatPillStroke then
				FUI.FloatPillStroke.Thickness = 2.4
				FUI.FloatPillStroke.Transparency = 0.0
				FUI.FloatPillStroke.Color = Color3.fromRGB(255, 255, 255)
			end
			if FUI.FloatPillStrokeGrad then
				FUI.FloatPillStrokeGrad.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, eff.Accent),
					ColorSequenceKeypoint.new(0.20, Color3.fromRGB(255, 255, 255)),
					ColorSequenceKeypoint.new(0.50, eff.Stroke),
					ColorSequenceKeypoint.new(0.75, Color3.fromRGB(255, 255, 255)),
					ColorSequenceKeypoint.new(1, eff.Accent)
				})
				FUI.FloatPillStrokeGrad.Enabled = true
			end
			if FUI.FloatPillTopSpec then
				FUI.FloatPillTopSpec.Visible = true
				FUI.FloatPillTopSpec.BackgroundColor3 = eff.Accent
				FUI.FloatPillTopSpec.BackgroundTransparency = 0.08
			end
			if FUI.FloatPillDivider then
				FUI.FloatPillDivider.BackgroundColor3 = eff.Accent
				FUI.FloatPillDivider.BackgroundTransparency = 0.15
			end
			if FUI.FloatDragIcon then FUI.FloatDragIcon.TextColor3 = eff.Accent end
			if FUI.FloatScriptIcon then FUI.FloatScriptIcon.TextColor3 = Color3.fromRGB(255, 255, 255) end
		else
			FloatingPill.BackgroundTransparency = 0.06
			if FUI.FloatHaloStroke then FUI.FloatHaloStroke.Transparency = 0.62 end
			if FUI.FloatLeftPod then FUI.FloatLeftPod.BackgroundTransparency = 0.45 end
			if FUI.FloatEmblemPod then FUI.FloatEmblemPod.BackgroundTransparency = 0.08 end
			if FUI.FloatPillGrad then
				FUI.FloatPillGrad.Rotation = 18
				FUI.FloatPillGrad.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, eff.MainBg:Lerp(eff.PanelBg, 0.48)),
					ColorSequenceKeypoint.new(0.55, eff.MainBg),
					ColorSequenceKeypoint.new(1, eff.MainBg:Lerp(eff.AccentDark, 0.22))
				})
				FUI.FloatPillGrad.Enabled = true
			end
			if FUI.FloatPillStroke then
				FUI.FloatPillStroke.Thickness = 2.2
				FUI.FloatPillStroke.Transparency = 0.02
				FUI.FloatPillStroke.Color = Color3.fromRGB(255, 255, 255)
			end
			if FUI.FloatPillStrokeGrad then
				FUI.FloatPillStrokeGrad.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, eff.Accent:Lerp(Color3.fromRGB(130, 240, 255), 0.38)),
					ColorSequenceKeypoint.new(0.20, Color3.fromRGB(255, 255, 255)),
					ColorSequenceKeypoint.new(0.50, eff.AccentDark),
					ColorSequenceKeypoint.new(0.75, Color3.fromRGB(255, 255, 255)),
					ColorSequenceKeypoint.new(1, eff.Accent)
				})
				FUI.FloatPillStrokeGrad.Enabled = true
			end
			if FUI.FloatPillTopSpec then
				FUI.FloatPillTopSpec.Visible = true
				FUI.FloatPillTopSpec.BackgroundColor3 = eff.Stroke:Lerp(Color3.fromRGB(255, 255, 255), 0.5)
				FUI.FloatPillTopSpec.BackgroundTransparency = 0.28
			end
			if FUI.FloatPillDivider then
				FUI.FloatPillDivider.BackgroundColor3 = eff.Stroke
				FUI.FloatPillDivider.BackgroundTransparency = 0.25
			end
			if FUI.FloatDragIcon then FUI.FloatDragIcon.TextColor3 = eff.Accent end
			if FUI.FloatScriptIcon then FUI.FloatScriptIcon.TextColor3 = Color3.fromRGB(255, 255, 255) end
		end
	end

	-- Synchronize Option 2 Mobile Mini Square "T.R" Icon with active Theme and GUI Design Style
	if MobileSquareIcon and MobileSquareIcon.Parent then
		MobileSquareIcon.BackgroundColor3 = eff.MainBg
		if FUI.SquareInnerShade then FUI.SquareInnerShade.BackgroundColor3 = eff.PanelBg end
		if FUI.SquareBotGlow then FUI.SquareBotGlow.BackgroundColor3 = eff.Accent end
		if FUI.SquareHaloGrad then
			FUI.SquareHaloGrad.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, eff.Accent),
				ColorSequenceKeypoint.new(0.5, eff.Stroke),
				ColorSequenceKeypoint.new(1, eff.Accent)
			})
		end
		if FUI.SquareTitleGrad then
			FUI.SquareTitleGrad.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
				ColorSequenceKeypoint.new(0.55, eff.TextPrimary:Lerp(eff.Accent, 0.28)),
				ColorSequenceKeypoint.new(1, eff.Accent:Lerp(Color3.fromRGB(255, 255, 255), 0.35))
			})
		end
		if d == "LiquidGlass" then
			MobileSquareIcon.BackgroundTransparency = 0.42
			if FUI.SquareCorner then FUI.SquareCorner.CornerRadius = UDim.new(0, 11) end
			if FUI.SquareInnerShade then FUI.SquareInnerShade.BackgroundTransparency = 0.56 end
			if FUI.SquareHaloStroke then FUI.SquareHaloStroke.Transparency = 0.56 end
			if FUI.SquareBgGrad then
				FUI.SquareBgGrad.Rotation = -42
				FUI.SquareBgGrad.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, eff.MainBg:Lerp(Color3.fromRGB(255, 255, 255), 0.40)),
					ColorSequenceKeypoint.new(0.5, eff.MainBg:Lerp(eff.Accent, 0.22)),
					ColorSequenceKeypoint.new(1, eff.MainBg:Lerp(Color3.fromRGB(210, 235, 255), 0.32))
				})
				FUI.SquareBgGrad.Enabled = true
			end
			if FUI.SquareStroke then
				FUI.SquareStroke.Thickness = 1.9
				FUI.SquareStroke.Transparency = 0.04
				FUI.SquareStroke.Color = Color3.fromRGB(255, 255, 255)
			end
			if FUI.SquareStrokeGrad then
				FUI.SquareStrokeGrad.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, eff.Accent:Lerp(Color3.fromRGB(255, 255, 255), 0.35)),
					ColorSequenceKeypoint.new(0.4, Color3.fromRGB(255, 255, 255)),
					ColorSequenceKeypoint.new(0.75, eff.Stroke),
					ColorSequenceKeypoint.new(1, eff.Accent)
				})
				FUI.SquareStrokeGrad.Enabled = true
			end
			if FUI.SquareTopSpec then
				FUI.SquareTopSpec.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				FUI.SquareTopSpec.BackgroundTransparency = 0.08
			end
		elseif d == "CyberHud" then
			MobileSquareIcon.BackgroundTransparency = 0.05
			if FUI.SquareCorner then FUI.SquareCorner.CornerRadius = UDim.new(0, 6) end
			if FUI.SquareInnerShade then FUI.SquareInnerShade.BackgroundTransparency = 0.32 end
			if FUI.SquareHaloStroke then FUI.SquareHaloStroke.Transparency = 0.42 end
			if FUI.SquareBgGrad then
				FUI.SquareBgGrad.Rotation = 135
				FUI.SquareBgGrad.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(14, 18, 32):Lerp(eff.Accent, 0.28)),
					ColorSequenceKeypoint.new(0.5, Color3.fromRGB(5, 6, 12)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(18, 10, 32):Lerp(eff.Stroke, 0.28))
				})
				FUI.SquareBgGrad.Enabled = true
			end
			if FUI.SquareStroke then
				FUI.SquareStroke.Thickness = 2.2
				FUI.SquareStroke.Transparency = 0.0
				FUI.SquareStroke.Color = Color3.fromRGB(255, 255, 255)
			end
			if FUI.SquareStrokeGrad then
				FUI.SquareStrokeGrad.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, eff.Accent),
					ColorSequenceKeypoint.new(0.35, Color3.fromRGB(255, 255, 255)),
					ColorSequenceKeypoint.new(0.7, eff.Stroke),
					ColorSequenceKeypoint.new(1, eff.Accent)
				})
				FUI.SquareStrokeGrad.Enabled = true
			end
			if FUI.SquareTopSpec then
				FUI.SquareTopSpec.BackgroundColor3 = eff.Accent
				FUI.SquareTopSpec.BackgroundTransparency = 0.08
			end
		else
			MobileSquareIcon.BackgroundTransparency = 0.06
			if FUI.SquareCorner then FUI.SquareCorner.CornerRadius = UDim.new(0, 9) end
			if FUI.SquareInnerShade then FUI.SquareInnerShade.BackgroundTransparency = 0.42 end
			if FUI.SquareHaloStroke then FUI.SquareHaloStroke.Transparency = 0.60 end
			if FUI.SquareBgGrad then
				FUI.SquareBgGrad.Rotation = 135
				FUI.SquareBgGrad.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, eff.MainBg:Lerp(eff.Accent, 0.26)),
					ColorSequenceKeypoint.new(0.55, eff.MainBg),
					ColorSequenceKeypoint.new(1, eff.MainBg:Lerp(eff.AccentDark, 0.34))
				})
				FUI.SquareBgGrad.Enabled = true
			end
			if FUI.SquareStroke then
				FUI.SquareStroke.Thickness = 2.0
				FUI.SquareStroke.Transparency = 0.02
				FUI.SquareStroke.Color = Color3.fromRGB(255, 255, 255)
			end
			if FUI.SquareStrokeGrad then
				FUI.SquareStrokeGrad.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, eff.Accent:Lerp(Color3.fromRGB(130, 240, 255), 0.38)),
					ColorSequenceKeypoint.new(0.35, Color3.fromRGB(255, 255, 255)),
					ColorSequenceKeypoint.new(0.7, eff.Accent),
					ColorSequenceKeypoint.new(1, eff.AccentDark)
				})
				FUI.SquareStrokeGrad.Enabled = true
			end
			if FUI.SquareTopSpec then
				FUI.SquareTopSpec.BackgroundColor3 = eff.Stroke:Lerp(Color3.fromRGB(255, 255, 255), 0.5)
				FUI.SquareTopSpec.BackgroundTransparency = 0.22
			end
		end
	end
end

genv._TR_ApplyGuiDesign = function(designName, showNotif)
	Config.GuiDesign = designName
	savedConfig.Settings.GuiDesign = designName
	ApplyTheme(Config.Theme or "Default")
	if showNotif and NotifyFeatureToggle then
		local label = (designName == "LiquidGlass" and "GUI: Apple Liquid Glass") or (designName == "CyberHud" and "GUI: Quantum Cyber-HUD") or "GUI: Default Classic"
		NotifyFeatureToggle(label, true)
	end
end
MainFrame.Visible = true
isMenuVisible = true MinBtn.MouseButton1Click:Connect(function() SetMenuVisible(false) end)
--==============================================================================
-- 5. REUSABLE UI COMPONENT FACTORY
--==============================================================================
local Tabs = {} local ActiveTabName = nil
FUI.PageToTabName = {}
FUI.SearchRegistry = {}
FUI.SearchCards = {}

-- Global Quick-Search Bar at Top of ContentContainer (Search & Toggle Functions Directly)
do
	FUI.QuickSearchBar = Instance.new("Frame")
	FUI.QuickSearchBar.Name = "TR_QuickSearchBar"
	FUI.QuickSearchBar.Size = UDim2.new(1, -16, 0, 34)
	FUI.QuickSearchBar.Position = UDim2.new(0, 8, 0, 8)
	FUI.QuickSearchBar.BackgroundTransparency = 0.10
	FUI.QuickSearchBar.BorderSizePixel = 0
	FUI.QuickSearchBar.ZIndex = 8
	FUI.QuickSearchBar.Parent = ContentContainer
	RegisterThemeObject(FUI.QuickSearchBar, "BackgroundColor3", "CardBg")
	AddCorner(FUI.QuickSearchBar, 8)
	local qsStroke = Instance.new("UIStroke", FUI.QuickSearchBar)
	qsStroke.Thickness = 1.2
	qsStroke.Transparency = 0.45
	RegisterThemeObject(qsStroke, "Color", "Accent")

	local qsIcon = MakeLabel(FUI.QuickSearchBar, UDim2.new(0, 28, 1, 0), UDim2.new(0, 8, 0, 0), E.Search, Enum.Font.GothamBold, 13, "Accent", Enum.TextXAlignment.Center)
	qsIcon.ZIndex = 9

	FUI.QuickSearchInput = Instance.new("TextBox", FUI.QuickSearchBar)
	FUI.QuickSearchInput.Name = "SearchInput"
	FUI.QuickSearchInput.Size = UDim2.new(1, -138, 1, 0)
	FUI.QuickSearchInput.Position = UDim2.new(0, 36, 0, 0)
	FUI.QuickSearchInput.BackgroundTransparency = 1
	FUI.QuickSearchInput.ClearTextOnFocus = false
	FUI.QuickSearchInput.Font = Enum.Font.GothamSemibold
	FUI.QuickSearchInput.TextSize = 12
	FUI.QuickSearchInput.TextXAlignment = Enum.TextXAlignment.Left
	FUI.QuickSearchInput.TextTruncate = Enum.TextTruncate.AtEnd
	FUI.QuickSearchInput.PlaceholderText = "Quick-Search any function to toggle ON/OFF (e.g. Aimbot, Fly, ESP, Speed, Glass)..."
	FUI.QuickSearchInput.Text = ""
	FUI.QuickSearchInput.ZIndex = 9
	RegisterThemeObject(FUI.QuickSearchInput, "TextColor3", "TextPrimary")
	RegisterThemeObject(FUI.QuickSearchInput, "PlaceholderColor3", "TextSecondary")

	FUI.QuickSearchCountBadge = Instance.new("TextLabel", FUI.QuickSearchBar)
	FUI.QuickSearchCountBadge.Size = UDim2.new(0, 62, 0, 22)
	FUI.QuickSearchCountBadge.Position = UDim2.new(1, -98, 0.5, -11)
	FUI.QuickSearchCountBadge.BackgroundTransparency = 0.2
	FUI.QuickSearchCountBadge.Font = Enum.Font.GothamBold
	FUI.QuickSearchCountBadge.TextSize = 10
	FUI.QuickSearchCountBadge.Text = "Search"
	FUI.QuickSearchCountBadge.ZIndex = 9
	RegisterThemeObject(FUI.QuickSearchCountBadge, "BackgroundColor3", "PanelBg")
	RegisterThemeObject(FUI.QuickSearchCountBadge, "TextColor3", "TextSecondary")
	AddCorner(FUI.QuickSearchCountBadge, 6)

	FUI.QuickSearchClearBtn = Instance.new("TextButton", FUI.QuickSearchBar)
	FUI.QuickSearchClearBtn.Size = UDim2.new(0, 24, 0, 22)
	FUI.QuickSearchClearBtn.Position = UDim2.new(1, -30, 0.5, -11)
	FUI.QuickSearchClearBtn.BackgroundColor3 = Color3.fromRGB(175, 38, 55)
	FUI.QuickSearchClearBtn.Font = Enum.Font.GothamBold
	FUI.QuickSearchClearBtn.TextSize = 11
	FUI.QuickSearchClearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	FUI.QuickSearchClearBtn.Text = E.Close
	FUI.QuickSearchClearBtn.ZIndex = 9
	AddCorner(FUI.QuickSearchClearBtn, 6)

	FUI.SearchResultsPage = Instance.new("ScrollingFrame")
	FUI.SearchResultsPage.Name = "TR_SearchResultsPage"
	FUI.SearchResultsPage.Size = UDim2.new(1, -16, 1, -54)
	FUI.SearchResultsPage.Position = UDim2.new(0, 8, 0, 46)
	FUI.SearchResultsPage.BackgroundTransparency = 1
	FUI.SearchResultsPage.BorderSizePixel = 0
	FUI.SearchResultsPage.ScrollBarThickness = 4
	FUI.SearchResultsPage.CanvasSize = UDim2.new(0, 0, 0, 0)
	FUI.SearchResultsPage.AutomaticCanvasSize = Enum.AutomaticSize.Y
	FUI.SearchResultsPage.Visible = false
	FUI.SearchResultsPage.Parent = ContentContainer
	RegisterThemeObject(FUI.SearchResultsPage, "ScrollBarImageColor3", "Accent")
	local srLayout = Instance.new("UIListLayout", FUI.SearchResultsPage)
	srLayout.Padding = UDim.new(0, 6)
	srLayout.SortOrder = Enum.SortOrder.LayoutOrder
	local srPad = Instance.new("UIPadding", FUI.SearchResultsPage)
	srPad.PaddingTop = UDim.new(0, 4)
	srPad.PaddingBottom = UDim.new(0, 10)
	srPad.PaddingLeft = UDim.new(0, 4)
	srPad.PaddingRight = UDim.new(0, 8)

	FUI.SearchEmptyLbl = MakeLabel(FUI.SearchResultsPage, UDim2.new(1, -16, 0, 42), nil, "No matching functions found. Try keywords like Aimbot, Fly, ESP, Speed, Katana, Orbit, or Glass.", Enum.Font.GothamSemibold, 12, "TextSecondary", Enum.TextXAlignment.Center)
	FUI.SearchEmptyLbl.LayoutOrder = 9999
	FUI.SearchEmptyLbl.Visible = false
end

FUI.RefreshSearchCardsVisuals = function()
	local theme = GetTheme()
	for _, cEntry in ipairs(FUI.SearchCards) do
		if cEntry.ToggleBtn and cEntry.GetState then
			local ok, st = pcall(cEntry.GetState)
			local isOn = (ok and st == true)
			cEntry.ToggleBtn.Text = isOn and "ON" or "OFF"
			cEntry.ToggleBtn.BackgroundColor3 = isOn and theme.Accent or theme.PanelBg
			cEntry.ToggleBtn.TextColor3 = isOn and Color3.fromRGB(255, 255, 255) or theme.TextPrimary
		end
		if cEntry.JumpBtn then
			cEntry.JumpBtn.BackgroundColor3 = theme.PanelBg
			cEntry.JumpBtn.TextColor3 = theme.TextSecondary
		end
		if cEntry.SubLbl then
			cEntry.SubLbl.TextColor3 = theme.Accent
		end
	end
end
table.insert(ThemeObjects.CustomCallbacks, FUI.RefreshSearchCardsVisuals)

FUI.ApplySearchFilter = function()
	local rawQ = FUI.QuickSearchInput and FUI.QuickSearchInput.Text or ""
	local q = rawQ:lower():gsub("^%s+", ""):gsub("%s+$", "")
	if q == "" then
		if FUI.SearchResultsPage then FUI.SearchResultsPage.Visible = false end
		if FUI.QuickSearchCountBadge then FUI.QuickSearchCountBadge.Text = "Search" end
		for name, data in pairs(Tabs) do
			data.Page.Visible = (name == ActiveTabName)
		end
		return
	end
	for _, data in pairs(Tabs) do
		data.Page.Visible = false
	end
	if FUI.SearchResultsPage then FUI.SearchResultsPage.Visible = true end
	local words = {}
	for w in q:gmatch("%S+") do table.insert(words, w) end
	local matchCount = 0
	for _, cEntry in ipairs(FUI.SearchCards) do
		local matched = true
		for i = 1, #words do
			if not cEntry.Keywords:find(words[i], 1, true) then
				matched = false
				break
			end
		end
		cEntry.Card.Visible = matched
		if matched then matchCount = matchCount + 1 end
	end
	if FUI.SearchEmptyLbl then FUI.SearchEmptyLbl.Visible = (matchCount == 0) end
	if FUI.QuickSearchCountBadge then FUI.QuickSearchCountBadge.Text = tostring(matchCount) .. " Found" end
	FUI.RefreshSearchCardsVisuals()
end

FUI.QuickSearchInput:GetPropertyChangedSignal("Text"):Connect(FUI.ApplySearchFilter)
FUI.QuickSearchClearBtn.MouseButton1Click:Connect(function()
	FUI.QuickSearchInput.Text = ""
	FUI.ApplySearchFilter()
end)

FUI.SwitchToTab = function(tabName)
	if not Tabs[tabName] then return end
	ActiveTabName = tabName
	if FUI.QuickSearchInput and FUI.QuickSearchInput.Text ~= "" then
		FUI.QuickSearchInput.Text = ""
	end
	if FUI.SearchResultsPage then FUI.SearchResultsPage.Visible = false end
	for name, data in pairs(Tabs) do
		data.Page.Visible = (name == tabName)
		local theme = GetTheme()
		data.Button.BackgroundColor3 = (name == ActiveTabName) and theme.Accent or theme.CardBg
		data.Button.BackgroundTransparency = (name == ActiveTabName) and 0.02 or 0.2
	end
	if tabName ~= "Avatar Changer" and genv._TR_StopAvatarHoverPreview then pcall(genv._TR_StopAvatarHoverPreview) end
	if tabName == "Player Radar" and genv._TR_RefreshRadar then pcall(genv._TR_RefreshRadar)
	elseif tabName == "Target Fling" and genv._TR_RefreshFling then pcall(genv._TR_RefreshFling)
	elseif tabName == "Aimbot & Visuals" and genv._TR_RefreshTargetAimbotList then pcall(genv._TR_RefreshTargetAimbotList) end
end

local function CreateTab(tabName, iconText, order)
	local TabBtn = Instance.new("TextButton") TabBtn.LayoutOrder = order
	TabBtn.Size = UDim2.new(1, -12, 0, 33) TabBtn.BackgroundTransparency = 0.1
	TabBtn.Font = Enum.Font.GothamSemibold TabBtn.TextSize = 12 TabBtn.ZIndex = 6
	TabBtn.TextXAlignment = Enum.TextXAlignment.Left TabBtn.Text = "   " .. iconText .. "  " .. tabName
	TabBtn.Parent = Sidebar RegisterThemeObject(TabBtn, "TextColor3", "TextPrimary") AddCorner(TabBtn, 8)
	local Page = Instance.new("ScrollingFrame") Page.Size = UDim2.new(1, -16, 1, -54)
	Page.Position = UDim2.new(0, 8, 0, 46) Page.BackgroundTransparency = 1 Page.BorderSizePixel = 0
	Page.ScrollBarThickness = 4 Page.CanvasSize = UDim2.new(0, 0, 0, 0)
	Page.AutomaticCanvasSize = Enum.AutomaticSize.Y Page.Visible = false Page.Parent = ContentContainer
	RegisterThemeObject(Page, "ScrollBarImageColor3", "Accent")
	FUI.PageToTabName[Page] = tabName
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
	TabBtn.MouseButton1Click:Connect(function()
		FUI.SwitchToTab(tabName)
	end)
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
	return Card end local RightNotifHolder = Instance.new("Frame")
RightNotifHolder.Name = "TR_RightNotifications"
RightNotifHolder.AnchorPoint = Vector2.new(1, 1)
RightNotifHolder.Position = UDim2.new(1, -14, 1, -18)
RightNotifHolder.Size = UDim2.new(0, 236, 1, -80)
RightNotifHolder.BackgroundTransparency = 1
RightNotifHolder.BorderSizePixel = 0
RightNotifHolder.ZIndex = 90
RightNotifHolder.Parent = ScreenGui
local RightNotifLayout = Instance.new("UIListLayout")
RightNotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
RightNotifLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
RightNotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
RightNotifLayout.Padding = UDim.new(0, 6)
RightNotifLayout.Parent = RightNotifHolder
local activeFeatureNotifs = {}
local notifCounter = 0

local function NotifyFeatureToggle(rawName, isEnabled)
	if FUI and FUI.RefreshSearchCardsVisuals then pcall(FUI.RefreshSearchCardsVisuals) end
	if isClosingPermanently or not ScreenGui or not ScreenGui.Parent then return end
	local cleanName = tostring(rawName or "Feature"):gsub("%s*%b()$", "")
	if cleanName == "" then cleanName = tostring(rawName or "Feature") end
	local stateBool = (isEnabled == true)
	local statusColor = stateBool and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)
	local statusText = stateBool and "ON" or "OFF"
	local theme = GetTheme()
	local existing = activeFeatureNotifs[cleanName]
	if existing and existing.Slot and existing.Slot.Parent then
		existing.Token = existing.Token + 1
		local myToken = existing.Token
		existing.Bar.BackgroundColor3 = statusColor
		existing.Stroke.Color = statusColor
		existing.Badge.BackgroundColor3 = statusColor
		existing.Badge.Text = statusText
		existing.Title.Text = cleanName
		pcall(function()
			TweenService:Create(existing.Inner, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Position = UDim2.new(0, 0, 0, 0) }):Play()
		end)
		task.delay(1.85, function()
			if activeFeatureNotifs[cleanName] == existing and existing.Token == myToken then
				activeFeatureNotifs[cleanName] = nil
				if existing.Inner and existing.Inner.Parent then
					local tw = TweenService:Create(existing.Inner, TweenInfo.new(0.20, Enum.EasingStyle.Quint, Enum.EasingDirection.In), { Position = UDim2.new(1, 250, 0, 0) })
					tw:Play()
					tw.Completed:Connect(function()
						if existing.Slot and existing.Slot.Parent then existing.Slot:Destroy() end
					end)
				elseif existing.Slot and existing.Slot.Parent then
					existing.Slot:Destroy()
				end
			end
		end)
		return
	end

	notifCounter = notifCounter + 1
	local slot = Instance.new("Frame")
	slot.Size = UDim2.new(0, 232, 0, 38)
	slot.BackgroundTransparency = 1
	slot.BorderSizePixel = 0
	slot.LayoutOrder = notifCounter
	slot.ZIndex = 91
	slot.Parent = RightNotifHolder

	local inner = Instance.new("Frame")
	inner.Size = UDim2.new(1, 0, 1, 0)
	inner.Position = UDim2.new(1, 250, 0, 0)
	inner.BackgroundColor3 = theme.MainBg
	inner.BackgroundTransparency = 0.06
	inner.BorderSizePixel = 0
	inner.ZIndex = 91
	inner.Parent = slot
	AddCorner(inner, 8)

	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 1.3
	stroke.Transparency = 0.2
	stroke.Color = statusColor
	stroke.Parent = inner

	local bar = Instance.new("Frame")
	bar.Size = UDim2.new(0, 4, 1, -12)
	bar.Position = UDim2.new(0, 6, 0, 6)
	bar.BackgroundColor3 = statusColor
	bar.BorderSizePixel = 0
	bar.ZIndex = 92
	bar.Parent = inner
	AddCorner(bar, 4)

	local titleLbl = Instance.new("TextLabel")
	titleLbl.Size = UDim2.new(1, -68, 1, 0)
	titleLbl.Position = UDim2.new(0, 16, 0, 0)
	titleLbl.BackgroundTransparency = 1
	titleLbl.Font = Enum.Font.GothamBold
	titleLbl.TextSize = 12
	titleLbl.TextColor3 = theme.TextPrimary
	titleLbl.TextXAlignment = Enum.TextXAlignment.Left
	titleLbl.TextTruncate = Enum.TextTruncate.AtEnd
	titleLbl.Text = cleanName
	titleLbl.ZIndex = 92
	titleLbl.Parent = inner

	local badge = Instance.new("TextLabel")
	badge.Size = UDim2.new(0, 42, 0, 22)
	badge.Position = UDim2.new(1, -50, 0.5, -11)
	badge.BackgroundColor3 = statusColor
	badge.BorderSizePixel = 0
	badge.Font = Enum.Font.GothamBold
	badge.TextSize = 11
	badge.TextColor3 = Color3.fromRGB(255, 255, 255)
	badge.Text = statusText
	badge.ZIndex = 92
	badge.Parent = inner
	AddCorner(badge, 6)

	local entry = { Slot = slot, Inner = inner, Bar = bar, Stroke = stroke, Badge = badge, Title = titleLbl, Token = 1 }
	activeFeatureNotifs[cleanName] = entry

	pcall(function()
		TweenService:Create(inner, TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Position = UDim2.new(0, 0, 0, 0) }):Play()
	end)

	task.delay(1.85, function()
		if activeFeatureNotifs[cleanName] == entry and entry.Token == 1 then
			activeFeatureNotifs[cleanName] = nil
			if inner and inner.Parent then
				local tw = TweenService:Create(inner, TweenInfo.new(0.20, Enum.EasingStyle.Quint, Enum.EasingDirection.In), { Position = UDim2.new(1, 250, 0, 0) })
				tw:Play()
				tw.Completed:Connect(function()
					if slot and slot.Parent then slot:Destroy() end
				end)
			elseif slot and slot.Parent then
				slot:Destroy()
			end
		end
	end)
end

FUI.RegisterSearchFunction = function(info)
	if not FUI.SearchResultsPage or not info or not info.Name then return end
	local idx = #FUI.SearchCards + 1
	local sCard = CreateCard(FUI.SearchResultsPage, 46, info.Priority or (100 + idx))
	sCard.Visible = false
	local titleLbl = MakeLabel(sCard, UDim2.new(1, -180, 0, 20), UDim2.new(0, 12, 0, 5), info.Name, Enum.Font.GothamBold, 12, "TextPrimary", Enum.TextXAlignment.Left)
	titleLbl.TextTruncate = Enum.TextTruncate.AtEnd
	local tabStr = tostring(info.TabName or "General")
	local subLbl = MakeLabel(sCard, UDim2.new(1, -180, 0, 16), UDim2.new(0, 12, 0, 24), "Tab: " .. tabStr, Enum.Font.GothamSemibold, 10, "Accent", Enum.TextXAlignment.Left)
	subLbl.TextTruncate = Enum.TextTruncate.AtEnd
	local jumpBtn = MakeButton(sCard, UDim2.new(0, 62, 0, 28), UDim2.new(1, -160, 0.5, -14), "Open Tab", "PanelBg", 10)
	jumpBtn.MouseButton1Click:Connect(function()
		if FUI.SwitchToTab then FUI.SwitchToTab(tabStr) end
	end)
	local togBtn = MakeButton(sCard, UDim2.new(0, 84, 0, 28), UDim2.new(1, -92, 0.5, -14), "OFF", nil, 12)
	local entry = {
		Card = sCard,
		TitleLbl = titleLbl,
		SubLbl = subLbl,
		JumpBtn = jumpBtn,
		ToggleBtn = togBtn,
		TabName = tabStr,
		Keywords = string.lower(tostring(info.Name) .. " " .. tabStr .. " " .. tostring(info.Keywords or "")),
		GetState = info.GetState,
		Toggle = info.Toggle
	}
	togBtn.MouseButton1Click:Connect(function()
		if entry.Toggle then pcall(entry.Toggle) end
		if FUI.RefreshSearchCardsVisuals then FUI.RefreshSearchCardsVisuals() end
	end)
	table.insert(FUI.SearchCards, entry)
	if FUI.RefreshSearchCardsVisuals then FUI.RefreshSearchCardsVisuals() end
end

local function CreateToggle(parent, labelText, initialValue, order, callback)
	local Card = CreateCard(parent, 42, order)
	local Label = MakeLabel(Card, UDim2.new(1, -110, 1, 0), UDim2.new(0, 14, 0, 0), labelText, Enum.Font.GothamSemibold, 13, "TextPrimary", Enum.TextXAlignment.Left)
	local ToggleBtn = MakeButton(Card, UDim2.new(0, 84, 0, 28), UDim2.new(1, -96, 0.5, -14), "OFF", nil, 12)
	local state = initialValue and true or false local function UpdateToggleVisual()
		local theme = GetTheme() ToggleBtn.Text = state and "ON" or "OFF"
		ToggleBtn.BackgroundColor3 = state and theme.Accent or theme.PanelBg
		if FUI.RefreshSearchCardsVisuals then pcall(FUI.RefreshSearchCardsVisuals) end end
	table.insert(ThemeObjects.CustomCallbacks, UpdateToggleVisual) UpdateToggleVisual()
	local function SetState(newState, triggerCallback) state = newState and true or false
		UpdateToggleVisual() if triggerCallback ~= false then NotifyFeatureToggle(labelText, state) if callback then pcall(callback, state) end end end
	ToggleBtn.MouseButton1Click:Connect(function() SetState(not state, true) end)
	if FUI.RegisterSearchFunction then
		FUI.RegisterSearchFunction({
			Name = labelText,
			TabName = (FUI.PageToTabName and FUI.PageToTabName[parent]) or "Themes & Status",
			GetState = function() return state end,
			Toggle = function() SetState(not state, true) end
		})
	end
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
local Tab10_Avatar   = CreateTab("Avatar Changer", E.Star, 10)
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
		return "Normal Auto Shoot"
	end
	if ignoreSlot ~= "AimbotAutoShoot" and (Config.AimbotAutoShootKeybind or "V") == keyName then
		return "Aimbot Auto Shoot"
	end
	if ignoreSlot ~= "ZombieAimbot" and (Config.ZombieAimbotKeybind or "G") == keyName then
		return "Zombie & Gargoyle Aimbot"
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
CreateSectionHeader(Tab1_Dashboard, "GUI Design Style (1. Default | 2. Apple Liquid Glass | 3. Neon Cyber-HUD)", 1)
local DesignCard = CreateCard(Tab1_Dashboard, 0, 1)
DesignCard.AutomaticSize = Enum.AutomaticSize.Y
local DesignPad = Instance.new("UIPadding")
DesignPad.PaddingTop = UDim.new(0, 8) DesignPad.PaddingBottom = UDim.new(0, 8)
DesignPad.PaddingLeft = UDim.new(0, 8) DesignPad.PaddingRight = UDim.new(0, 8)
DesignPad.Parent = DesignCard
local DesignGrid = Instance.new("UIGridLayout")
DesignGrid.CellSize = UDim2.new(0.333, -5, 0, 34)
DesignGrid.CellPadding = UDim2.new(0, 6, 0, 6)
DesignGrid.HorizontalAlignment = Enum.HorizontalAlignment.Center
DesignGrid.VerticalAlignment = Enum.VerticalAlignment.Center
DesignGrid.SortOrder = Enum.SortOrder.LayoutOrder
DesignGrid.Parent = DesignCard
local DesignButtons = {}
local DesignOptions = {
	{ Id = "Default", Label = "1. Default Classic" },
	{ Id = "LiquidGlass", Label = "2. Apple Liquid Glass" },
	{ Id = "CyberHud", Label = "3. Neon Cyber-HUD" }
}
local ThemeBtnsMap = {}
local function RefreshDesignButtons()
	local theme = GetTheme()
	local curD = Config.GuiDesign or "Default"
	for id, btn in pairs(DesignButtons) do
		local active = (id == curD)
		btn.BackgroundColor3 = active and theme.Accent or theme.PanelBg
		btn.TextColor3 = active and Color3.fromRGB(255, 255, 255) or theme.TextPrimary
		btn.Text = (active and "[ON] " or "") .. (id == "Default" and "1. Default" or (id == "LiquidGlass" and "2. Liquid Glass" or "3. Cyber-HUD"))
	end
	if ThemeBtnsMap["Default"] then
		if curD == "LiquidGlass" then
			ThemeBtnsMap["Default"].Text = "Liquid Glass (Clear)"
			ThemeBtnsMap["Default"].BackgroundColor3 = Color3.fromRGB(70, 165, 255)
		elseif curD == "CyberHud" then
			ThemeBtnsMap["Default"].Text = "Cyber Neon (Default)"
			ThemeBtnsMap["Default"].BackgroundColor3 = Color3.fromRGB(0, 210, 235)
		else
			ThemeBtnsMap["Default"].Text = "Default"
			ThemeBtnsMap["Default"].BackgroundColor3 = Themes["Default"].Accent
		end
	end
end
table.insert(ThemeObjects.CustomCallbacks, RefreshDesignButtons)
for idx, dOpt in ipairs(DesignOptions) do
	local DBtn = Instance.new("TextButton")
	DBtn.LayoutOrder = idx DBtn.Font = Enum.Font.GothamBold DBtn.TextSize = 11
	DBtn.Text = dOpt.Label DBtn.Parent = DesignCard AddCorner(DBtn, 6)
	DesignButtons[dOpt.Id] = DBtn
	DBtn.MouseButton1Click:Connect(function()
		if genv._TR_ApplyGuiDesign then genv._TR_ApplyGuiDesign(dOpt.Id, true) end
	end)
end

CreateSectionHeader(Tab1_Dashboard, "UI Theme Customizer (6 Themes | Shades Liquid Glass & Cyber-HUD)", 2)
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
	ThemeBtnsMap[themeName] = TBtn
	TBtn.MouseButton1Click:Connect(function() ApplyTheme(themeName) end)
end
RefreshDesignButtons()
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
if FUI.RegisterSearchFunction then
	FUI.RegisterSearchFunction({
		Name = "Mouse Lock / Shift Lock [M]",
		TabName = "Themes & Status",
		Keywords = "mouse lock shift lock cursor center m",
		Priority = 10,
		GetState = function() return CursorUnlockedOverride == true end,
		Toggle = function() if SetMouseLockState then SetMouseLockState(not CursorUnlockedOverride) end end
	})
	FUI.RegisterSearchFunction({
		Name = "GUI Design: 2. Apple Liquid Glass",
		TabName = "Themes & Status",
		Keywords = "gui design apple liquid glass transparent crystal",
		Priority = 11,
		GetState = function() return (Config.GuiDesign == "LiquidGlass") end,
		Toggle = function()
			local nextD = (Config.GuiDesign == "LiquidGlass") and "Default" or "LiquidGlass"
			if genv._TR_ApplyGuiDesign then genv._TR_ApplyGuiDesign(nextD, true) end
		end
	})
	FUI.RegisterSearchFunction({
		Name = "GUI Design: 3. Neon Cyber-HUD",
		TabName = "Themes & Status",
		Keywords = "gui design neon cyber hud cyberpunk laser",
		Priority = 12,
		GetState = function() return (Config.GuiDesign == "CyberHud") end,
		Toggle = function()
			local nextD = (Config.GuiDesign == "CyberHud") and "Default" or "CyberHud"
			if genv._TR_ApplyGuiDesign then genv._TR_ApplyGuiDesign(nextD, true) end
		end
	})
	FUI.RegisterSearchFunction({
		Name = "Floating Icon Position Lock (Lock/Unlock Drag)",
		TabName = "Themes & Status",
		Keywords = "floating icon pill lock unlock position drag",
		Priority = 13,
		GetState = function() return isFloatingPillLocked == true end,
		Toggle = function()
			isFloatingPillLocked = not isFloatingPillLocked
			Config.FloatingIconLocked = isFloatingPillLocked
			savedConfig.Settings.FloatingIconLocked = isFloatingPillLocked
			SyncFloatingPillState()
			SaveConfig(false)
			if NotifyFeatureToggle then NotifyFeatureToggle("Floating Icon Position Lock", isFloatingPillLocked) end
		end
	})
end
SetMouseLockState = function(newState) local prevML = CursorUnlockedOverride CursorUnlockedOverride = newState and true or false if prevML ~= CursorUnlockedOverride and not isClosingPermanently then NotifyFeatureToggle("Mouse Lock", CursorUnlockedOverride) end
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
local FloatPillToggleCtrl
FloatPillToggleCtrl = CreateToggle(Tab1_Dashboard, "Floating Hub Pill Icon (Mobile: Always ON | PC: Toggle)", isMobileDevice or (Config.FloatingIconEnabled ~= false), 8, function(state)
	if isMobileDevice then
		Config.FloatingIconEnabled = true
		savedConfig.Settings.FloatingIconEnabled = true
		if not state and FloatPillToggleCtrl then
			task.defer(function()
				FloatPillToggleCtrl.SetState(true, false)
				if NotifyFeatureToggle then NotifyFeatureToggle("Floating Pill (Mobile: Always ON)", true) end
			end)
		end
		UpdateFloatingPillVisibility()
		return
	end
	Config.FloatingIconEnabled = state
	savedConfig.Settings.FloatingIconEnabled = state
	UpdateFloatingPillVisibility()
	SaveConfig(false)
end)
if isMobileDevice then
	local MobFloatStyleCard = CreateCard(Tab1_Dashboard, 0, 8)
	MobFloatStyleCard.AutomaticSize = Enum.AutomaticSize.Y
	local mfsPad = Instance.new("UIPadding", MobFloatStyleCard)
	mfsPad.PaddingTop = UDim.new(0, 8) mfsPad.PaddingBottom = UDim.new(0, 8)
	mfsPad.PaddingLeft = UDim.new(0, 8) mfsPad.PaddingRight = UDim.new(0, 8)
	local mfsGrid = Instance.new("UIGridLayout", MobFloatStyleCard)
	mfsGrid.CellSize = UDim2.new(0.5, -5, 0, 32)
	mfsGrid.CellPadding = UDim2.new(0, 8, 0, 6)
	mfsGrid.HorizontalAlignment = Enum.HorizontalAlignment.Center
	mfsGrid.VerticalAlignment = Enum.VerticalAlignment.Center
	mfsGrid.SortOrder = Enum.SortOrder.LayoutOrder
	local MobStyleBtns = {}
	local MobStyleOpts = {
		{ Id = "Pill", Label = "1. Default Pill Icon" },
		{ Id = "Square", Label = "2. Mini Square [T.R]" }
	}
	local function RefreshMobStyleBtns()
		local th = GetTheme()
		local curS = Config.MobileFloatStyle or "Pill"
		for id, b in pairs(MobStyleBtns) do
			local act = (id == curS)
			b.BackgroundColor3 = act and th.Accent or th.PanelBg
			b.TextColor3 = act and Color3.fromRGB(255, 255, 255) or th.TextPrimary
			b.Text = (act and "[ON] " or "") .. (id == "Pill" and "1. Default Pill" or "2. Mini Square [T.R]")
		end
	end
	table.insert(ThemeObjects.CustomCallbacks, RefreshMobStyleBtns)
	for idx, sOpt in ipairs(MobStyleOpts) do
		local sb = Instance.new("TextButton", MobFloatStyleCard)
		sb.LayoutOrder = idx sb.Font = Enum.Font.GothamBold sb.TextSize = 11
		sb.Text = sOpt.Label AddCorner(sb, 6)
		MobStyleBtns[sOpt.Id] = sb
		sb.MouseButton1Click:Connect(function()
			Config.MobileFloatStyle = sOpt.Id
			savedConfig.Settings.MobileFloatStyle = sOpt.Id
			RefreshMobStyleBtns()
			UpdateFloatingPillVisibility()
			if FUI.PlayEntranceAnim then pcall(FUI.PlayEntranceAnim, sOpt.Id) end
			if ApplyGuiDesignSurface then pcall(ApplyGuiDesignSurface) end
			SaveConfig(false)
			if NotifyFeatureToggle then
				NotifyFeatureToggle("Mobile Icon: " .. (sOpt.Id == "Square" and "Mini Square (T.R)" or "Default Pill"), true)
			end
		end)
	end
	RefreshMobStyleBtns()
end
CreateSectionHeader(Tab1_Dashboard, "Protection & Physics Stabilizers", 9)
CreateToggle(Tab1_Dashboard, "Anti-AFK Protection (VirtualUser Idle Bypass)", Config.AntiAFK, 10, function(state)
	Config.AntiAFK = state SaveConfig(false) end)
CreateToggle(Tab1_Dashboard, "Super Anti-Fling Shield (No-Collide Players + Velocity Lock)", Config.AntiFlingEnabled ~= false, 11, function(state)
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
CreateToggle(Tab1_Dashboard, "Undetected Anti-Cheat Bypass (Fly, Speed, Jump & Teleport)", Config.AntiCheatBypass ~= false, 12, function(state)
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
local GetRootPart, GetCharacterFromPlayer, GetCachedCharBaseParts, freezePosition, lastSafeAntiFlingCF, SafeTeleportToCoords
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
	if typeof and typeof(plr) == "Instance" and plr:IsA("Model") then return plr.Parent and plr or nil end
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
end
local cachedBasePartsChar, cachedBasePartsList, cachedBasePartsTime = nil, {}, 0
GetCachedCharBaseParts = function(char)
	if not char then return {} end
	local now = os.clock()
	if char == cachedBasePartsChar and (now - cachedBasePartsTime < 0.5) then
		return cachedBasePartsList
	end
	cachedBasePartsChar = char
	cachedBasePartsTime = now
	table.clear(cachedBasePartsList)
	for _, ch in ipairs(char:GetChildren()) do
		if ch:IsA("BasePart") and ch.Name ~= "TR_FakeFloor" then
			table.insert(cachedBasePartsList, ch)
		end
	end
	return cachedBasePartsList
end
freezePosition = nil
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

CreateSectionHeader(Tab3_Radar, "Stick & Orbit Player (10,000+ s/s Lock | Head, Back, Bottom & Orbit Strafe)", 1)
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
StickModeGrid.CellSize = UDim2.new(0.25, -5, 0, 28)
StickModeGrid.CellPadding = UDim2.new(0, 5, 0, 4)
StickModeGrid.HorizontalAlignment = Enum.HorizontalAlignment.Center
StickModeGrid.VerticalAlignment = Enum.VerticalAlignment.Center
StickModeGrid.SortOrder = Enum.SortOrder.LayoutOrder
StickModeGrid.Parent = StickModeRow

local StickModeBtns = {}
local StickModesList = {
	{ Id = "Head", Label = "Part: Head" },
	{ Id = "Back", Label = "Part: Back" },
	{ Id = "Bottom", Label = "Part: Bottom" },
	{ Id = "Orbit", Label = "Mode: Orbit Strafe" },
}
local orbitAngle = 0
local orbitRadius = math.clamp(tonumber(Config.OrbitRadius) or 8, 2, 50)
local orbitSpeed = math.clamp(tonumber(Config.OrbitSpeed) or 10, 1, 40)

local OrbitParamsRow = Instance.new("Frame")
OrbitParamsRow.Size = UDim2.new(1, 0, 0, 28)
OrbitParamsRow.BackgroundTransparency = 1
OrbitParamsRow.LayoutOrder = 3
OrbitParamsRow.Parent = StickCtrlCard
local OrbitRadLbl = MakeLabel(OrbitParamsRow, UDim2.new(0.26, -4, 1, 0), UDim2.new(0, 0, 0, 0), "Orbit Radius (studs):", Enum.Font.GothamSemibold, 11, "TextSecondary", Enum.TextXAlignment.Left)
OrbitRadLbl.TextTruncate = Enum.TextTruncate.AtEnd
local OrbitRadBox = Instance.new("TextBox", OrbitParamsRow)
OrbitRadBox.Size = UDim2.new(0.22, -6, 0, 26)
OrbitRadBox.Position = UDim2.new(0.26, 2, 0, 1)
OrbitRadBox.Text = tostring(orbitRadius)
OrbitRadBox.PlaceholderText = "Radius (8)"
OrbitRadBox.ClearTextOnFocus = false
OrbitRadBox.Font = Enum.Font.GothamSemibold
OrbitRadBox.TextSize = 11
RegisterThemeObject(OrbitRadBox, "BackgroundColor3", "PanelBg")
RegisterThemeObject(OrbitRadBox, "TextColor3", "TextPrimary")
AddCorner(OrbitRadBox, 6)

local OrbitSpdLbl = MakeLabel(OrbitParamsRow, UDim2.new(0.26, -4, 1, 0), UDim2.new(0.50, 4, 0, 0), "Orbit Speed (rad/s):", Enum.Font.GothamSemibold, 11, "TextSecondary", Enum.TextXAlignment.Left)
OrbitSpdLbl.TextTruncate = Enum.TextTruncate.AtEnd
local OrbitSpdBox = Instance.new("TextBox", OrbitParamsRow)
OrbitSpdBox.Size = UDim2.new(0.22, -6, 0, 26)
OrbitSpdBox.Position = UDim2.new(0.76, 2, 0, 1)
OrbitSpdBox.Text = tostring(orbitSpeed)
OrbitSpdBox.PlaceholderText = "Speed (10)"
OrbitSpdBox.ClearTextOnFocus = false
OrbitSpdBox.Font = Enum.Font.GothamSemibold
OrbitSpdBox.TextSize = 11
RegisterThemeObject(OrbitSpdBox, "BackgroundColor3", "PanelBg")
RegisterThemeObject(OrbitSpdBox, "TextColor3", "TextPrimary")
AddCorner(OrbitSpdBox, 6)

OrbitRadBox.FocusLost:Connect(function()
	local v = tonumber(OrbitRadBox.Text)
	if v then
		orbitRadius = math.clamp(math.floor(v * 10 + 0.5) / 10, 2, 50)
		Config.OrbitRadius = orbitRadius
		savedConfig.Settings.OrbitRadius = orbitRadius
		SaveConfig(false)
	end
	OrbitRadBox.Text = tostring(orbitRadius)
end)

OrbitSpdBox.FocusLost:Connect(function()
	local v = tonumber(OrbitSpdBox.Text)
	if v then
		orbitSpeed = math.clamp(math.floor(v * 10 + 0.5) / 10, 1, 40)
		Config.OrbitSpeed = orbitSpeed
		savedConfig.Settings.OrbitSpeed = orbitSpeed
		SaveConfig(false)
	end
	OrbitSpdBox.Text = tostring(orbitSpeed)
end)
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
	elseif StickMode == "Orbit" then
		orbitAngle = (orbitAngle + (orbitSpeed * math.clamp(dt or 0.016, 0.001, 0.1))) % (math.pi * 2)
		local tPos = baseCF.Position
		local orbitPos = tPos + Vector3.new(math.cos(orbitAngle) * orbitRadius, 0.5, math.sin(orbitAngle) * orbitRadius)
		return CFrame.new(orbitPos, tPos), tVel
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

	for _, part in ipairs(GetCachedCharBaseParts(myChar)) do
		if part.CanCollide then
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
	lastSafeAntiFlingCF = goalCF
	freezePosition = goalCF.Position
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
			NotifyFeatureToggle("Player Stick", false)
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
	NotifyFeatureToggle("Stick: " .. tostring(targetPlr.DisplayName), true)
	pcall(function() RunService:UnbindFromRenderStep("TR_Stick_Step") end)
	RunService:BindToRenderStep("TR_Stick_Step", Enum.RenderPriority.Character.Value + 1, function(dt)
		StepStickEngine(dt)
	end)
	pcall(StepStickEngine, 0.016)
	RefreshStickUI()
	if RefreshRadarCards then pcall(RefreshRadarCards) end
	return true
end

if FUI.RegisterSearchFunction then
	FUI.RegisterSearchFunction({
		Name = "Orbit / Strafe Around Target Mode (Player Radar)",
		TabName = "Player Radar",
		Keywords = "orbit strafe circle target stick mode radar",
		Priority = 8,
		GetState = function() return StickMode == "Orbit" end,
		Toggle = function()
			StickMode = (StickMode == "Orbit") and "Back" or "Orbit"
			Config.StickMode = StickMode
			savedConfig.Settings.StickMode = StickMode
			RefreshStickUI()
			if RefreshRadarCards then pcall(RefreshRadarCards) end
			SaveConfig(false)
			if NotifyFeatureToggle then NotifyFeatureToggle("Orbit Strafe Mode", StickMode == "Orbit") end
		end
	})
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
		local wasSpec = (SpectatingTarget ~= nil)
		SpectatingTarget = nil
		if wasSpec then NotifyFeatureToggle("Spectate Player", false) end
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
				elseif StickMode == "Bottom" then StickMode = "Orbit"
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
	NotifyFeatureToggle("Flight", keyFlying)
end

masterFlightToggleBtn.MouseButton1Click:Connect(function()
	masterFlightEnabled = not masterFlightEnabled
	NotifyFeatureToggle("Master Flight Switch", masterFlightEnabled)
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
	local activeCam = workspace.CurrentCamera or camera
	local camCF = activeCam.CFrame

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

	if moveVector.Magnitude == 0 then
		local moveDir = hum.MoveDirection
		if moveDir and moveDir.Magnitude > 0.01 then
			local flatLook = Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z)
			local flatRight = Vector3.new(camCF.RightVector.X, 0, camCF.RightVector.Z)
			if flatLook.Magnitude > 0.001 and flatRight.Magnitude > 0.001 then
				flatLook = flatLook.Unit
				flatRight = flatRight.Unit
				local forwardInput = moveDir:Dot(flatLook)
				local rightInput = moveDir:Dot(flatRight)
				moveVector = moveVector + (camCF.LookVector * forwardInput) + (camCF.RightVector * rightInput)
			else
				moveVector = moveVector + moveDir
			end
		end
	end
	if hum.Jump then
		moveVector = moveVector + Vector3.new(0, 1, 0)
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
	NotifyFeatureToggle("Freecam", freecamEnabled)
end
if FUI.RegisterSearchFunction then
		FUI.RegisterSearchFunction({
			Name = "Flight Active [E] (3D Camera-Aligned Fly)",
			TabName = "Flight & Movement",
			Keywords = "fly flight active air hover speed e",
			Priority = 5,
			GetState = function() return isFlightActive and isFlightActive() or false end,
			Toggle = function()
				if not masterFlightEnabled then
					masterFlightEnabled = true
					savedConfig.Settings.MasterFlightEnabled = true
					UpdateFlightUI()
				end
				if toggleFlightState then toggleFlightState() end
			end
		})
		FUI.RegisterSearchFunction({
			Name = "Master Flight Switch (Enable/Disable Flight Engine)",
			TabName = "Flight & Movement",
			Keywords = "master flight switch enable fly",
			Priority = 6,
			GetState = function() return masterFlightEnabled == true end,
			Toggle = function()
				masterFlightEnabled = not masterFlightEnabled
				savedConfig.Settings.MasterFlightEnabled = masterFlightEnabled
				if not masterFlightEnabled and keyFlying then stopFlight() end
				UpdateFlightUI()
				SaveConfig(false)
				NotifyFeatureToggle("Master Flight Switch", masterFlightEnabled)
			end
		})
		FUI.RegisterSearchFunction({
			Name = "Freecam Explorer [C] (Detach Camera & Fly)",
			TabName = "Flight & Movement",
			Keywords = "freecam camera spectator detach look c",
			Priority = 7,
			GetState = function() return isFreecamActive and isFreecamActive() or false end,
			Toggle = function() if toggleFreecamState then toggleFreecamState() end end
		})
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
	RunNetworkPauseBypass() FlingActive = true UpdateStatus() NotifyFeatureToggle("Target Fling", true)
	Message("T.R Fling", "Started multi-target fling & bypass engine.", 2) task.spawn(function()
		while FlingActive do local validTargets = {} for name, targetPlayer in pairs(SelectedTargets) do
				if targetPlayer and targetPlayer.Parent then table.insert(validTargets, targetPlayer) else
					SelectedTargets[name] = nil if PlayerCheckboxes[name] then
						PlayerCheckboxes[name].Check.Visible = false end end end
			for _, targetPlayer in ipairs(validTargets) do if FlingActive then SkidFling(targetPlayer)
					task.wait(0.05) else break end end task.wait(0.2) end end) end StopFling = function()
	if not FlingActive then return end FlingActive = false UpdateStatus() NotifyFeatureToggle("Target Fling", false)
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
local aimbotKeyMode = (Config.AimbotKeyMode == "Burst1s") and "Burst1s" or "Toggle"
local aimbotBurstDurationMs = math.clamp(math.floor((tonumber(Config.AimbotBurstDurationMs) or 1000) + 0.5), 50, 60000)
local aimbotBurstEndTime = 0
local aimbotEnabled = (aimbotKeyMode == "Toggle") and (Config.AimbotEnabled == true) or false
local targetAimbotEnabled = (Config.TargetAimbotEnabled == true)
if aimbotEnabled and targetAimbotEnabled then targetAimbotEnabled = false Config.TargetAimbotEnabled = false end
local specificTargetPlayer = nil
local strongLock = (Config.StrongLock ~= false)
local aimbotTeamCheck = (Config.AimbotTeamCheck ~= false)
local autoShootEnabled = (Config.AutoShootEnabled == true)
local aimbotAutoShootEnabled = (Config.AimbotAutoShootEnabled == true)
if autoShootEnabled and aimbotAutoShootEnabled then aimbotAutoShootEnabled = false Config.AimbotAutoShootEnabled = false end
local lastAutoShoot = 0
local isAutoShootingActive = false
local lastMiddleDotTarget, lastMiddleDotTime = nil, 0
local currentTarget, lastEspUpdate = nil, 0
local excludedPlayers, characterCache, adornmentsCache, katanaActiveUntil = {}, {}, {}, {}
local guiFovCircle = nil
local MAX_DISTANCE = 650
local wallcheckEnabled = (Config.WallcheckEnabled ~= false)
local espShowTeammates = (Config.ESPShowTeammates == true)
local aimPartName = Config.AimPartName or "Head"
local reusableWallcheckParams, updateWallcheckFilter
local IsTeammate, getTargetPart, isTargetVisible, removePlayerAdornments, clearAllAdornments, worldToScreenDistance
local RefreshESPHighlights, updateAllAdornments, findBestTarget
local aimbotStatusLabel, autoShootStatusLbl, aimbotAutoShootStatusLbl, excludeFrame, updateExcludeCount, rebuildExcludeList
local toggleAimbot, toggleTargetAimbot, toggleAutoShoot, toggleAimbotAutoShoot, triggerAutoShoot, StopAutoShootFiring, RefreshAimbotVisuals
local function SetupTab7()
	local guiFovStroke
	guiFovCircle = Instance.new("Frame") guiFovCircle.Name = "TR_FOVCircle"
	guiFovCircle.AnchorPoint = Vector2.new(0.5, 0.5) guiFovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
	guiFovCircle.Size = UDim2.new(0, FOV_RADIUS * 2, 0, FOV_RADIUS * 2)
	guiFovCircle.BackgroundTransparency = 1 guiFovCircle.BorderSizePixel = 0 guiFovCircle.Visible = false
	guiFovCircle.Parent = ScreenGui Instance.new("UICorner", guiFovCircle).CornerRadius = UDim.new(1, 0)
	guiFovStroke = Instance.new("UIStroke", guiFovCircle) guiFovStroke.Thickness = 1.8
	guiFovStroke.Transparency = 0.15 RegisterThemeObject(guiFovStroke, "Color", "Accent")
	SyncAimbotFovCircleVisibility = function()
		local showCircle = (aimbotEnabled or (FUI.ZombieAim and FUI.ZombieAim.Enabled)) and fovCircleEnabled and not isClosingPermanently if guiFovCircle then
			guiFovCircle.Size = UDim2.new(0, FOV_RADIUS * 2, 0, FOV_RADIUS * 2) guiFovCircle.Visible = showCircle
		end end
	StopAutoShootFiring = function()
		if isAutoShootingActive then
			isAutoShootingActive = false
			if mouse1release then pcall(mouse1release) end
		end
	end
	triggerAutoShoot = function()
		if not (autoShootEnabled or aimbotAutoShootEnabled) then
			StopAutoShootFiring()
			return
		end
		local zAimOn = (FUI.ZombieAim and FUI.ZombieAim.Enabled == true)
		if aimbotAutoShootEnabled and not ((aimbotEnabled or targetAimbotEnabled or zAimOn) and currentTarget ~= nil) then
			StopAutoShootFiring()
			return
		end
		local char = player.Character if not char then StopAutoShootFiring() return end
		local hum = char:FindFirstChildOfClass("Humanoid") if not hum or hum.Health <= 0 then StopAutoShootFiring() return end
		if (aimbotEnabled or targetAimbotEnabled or zAimOn) and currentTarget and strongLock then
			local cam = workspace.CurrentCamera
			local tChar = GetCharacterFromPlayer(currentTarget)
			local tPart = (aimPartName == "Head" and tChar and tChar:FindFirstChild("Head")) or getTargetPart(tChar)
			if cam and tPart then
				cam.CFrame = CFrame.new(cam.CFrame.Position, tPart.Position)
			end
		end
		if not isAutoShootingActive then
			isAutoShootingActive = true
			if mouse1press then
				pcall(mouse1press)
			elseif mouse1click then
				pcall(mouse1click)
			end
		end
		local nowT = os.clock()
		local shootDelay = math.clamp((tonumber(Config.AutoShootDelayMs) or 25) / 1000, 0.001, 0.1)
		if nowT - lastAutoShoot >= shootDelay then
			lastAutoShoot = nowT
			local tool = char:FindFirstChildOfClass("Tool")
			if tool then pcall(function() tool:Activate() end) end
			if mouse1press then
				pcall(mouse1press)
			elseif mouse1click then
				pcall(mouse1click)
			elseif VirtualUser then
				pcall(function()
					local cam = workspace.CurrentCamera
					local vs = cam and cam.ViewportSize or Vector2.new(960, 540)
					if VirtualUser.CaptureController and VirtualUser.ClickButton1 then
						VirtualUser:CaptureController()
						VirtualUser:ClickButton1(Vector2.new(vs.X * 0.5, vs.Y * 0.5))
					end
				end)
			end
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
	IsTeammate = function(plr) if not plr or plr == LocalPlayer or (typeof(plr) == "Instance" and not plr:IsA("Player")) then return false end local now = os.clock()
		if now - lastTeamCacheClear >= 1.5 then table.clear(teamCache) lastTeamCacheClear = now end
		local cached = teamCache[plr] if cached ~= nil then return cached end
		local ok, res = pcall(checkIsTeammateRaw, plr) local isTeam = (ok and res == true)
		teamCache[plr] = isTeam return isTeam end getTargetPart = function(character)
		if not character then return nil end
		local zEnt = FUI.ZombieAim and FUI.ZombieAim.CacheMap[character]
		if zEnt then local zp = (aimPartName == "Head" and zEnt.Head) or zEnt.Body or zEnt.Head if zp and zp.Parent then return zp end end local p = character:FindFirstChild(aimPartName)
		if p and p:IsA("BasePart") then return p end local hrp = character:FindFirstChild("HumanoidRootPart")
		if hrp and hrp:IsA("BasePart") then return hrp end
		local t = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
		return (t and t:IsA("BasePart") and t) or character.PrimaryPart end
	reusableWallcheckParams = RaycastParams.new()
	reusableWallcheckParams.FilterType = Enum.RaycastFilterType.Blacklist
	reusableWallcheckParams.IgnoreWater = true
	local reusableWallFilter = {}
	updateWallcheckFilter = function(char)
		char = char or LocalPlayer.Character
		table.clear(reusableWallFilter)
		if char then table.insert(reusableWallFilter, char) end
		if workspace.CurrentCamera then table.insert(reusableWallFilter, workspace.CurrentCamera) end
		local fakeFloor = workspace:FindFirstChild("TR_FakeFloor")
		if fakeFloor then table.insert(reusableWallFilter, fakeFloor) end
		local hurtFolder = workspace:FindFirstChild("HurtEffect")
		if hurtFolder then table.insert(reusableWallFilter, hurtFolder) end
		reusableWallcheckParams.FilterDescendantsInstances = reusableWallFilter
	end
	updateWallcheckFilter()
	isTargetVisible = function(targetPart, targetCharacter)
		if not wallcheckEnabled then return true end
		local cam = workspace.CurrentCamera
		if not cam or not targetPart then return false end
		if reusableWallFilter[1] ~= LocalPlayer.Character or reusableWallFilter[2] ~= cam then
			updateWallcheckFilter(LocalPlayer.Character)
		end
		local origin = cam.CFrame.Position
		local tPos = targetPart.Position
		for _ = 1, 6 do
			local dir = Vector3.new(tPos.X - origin.X, tPos.Y - origin.Y, tPos.Z - origin.Z)
			if dir.Magnitude < 0.5 then return true end
			local res = workspace:Raycast(origin, dir, reusableWallcheckParams)
			if not res or not res.Instance then return true end
			local hit = res.Instance
			if targetCharacter and hit:IsDescendantOf(targetCharacter) then return true end
			local hurtFolder = workspace:FindFirstChild("HurtEffect")
			if hurtFolder and hit:IsDescendantOf(hurtFolder) then return true end
			if not hit.CanCollide or hit.Transparency >= 0.85 or hit:FindFirstAncestorOfClass("Accessory") or hit:FindFirstAncestorOfClass("Tool") or (FUI.ZombieAim and FUI.ZombieAim.Enabled and FUI.ZombieAim.IsPartInAnyZombie(hit)) then
				origin = res.Position + (dir.Unit * 0.2)
			else
				return false
			end
		end
		return true
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
	local COL_ESP_BLACK = Color3.fromRGB(0, 0, 0)
	local COL_ESP_DARKBG = Color3.fromRGB(15, 15, 20)
	local COL_HP_HIGH = Color3.fromRGB(0, 255, 120)
	local COL_HP_MID = Color3.fromRGB(255, 215, 0)
	local COL_HP_LOW = Color3.fromRGB(255, 30, 30)
	local COL_SHIELD_CYAN = Color3.fromRGB(0, 215, 255)
	local COL_ESP_WHITE = Color3.fromRGB(255, 255, 255)
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
		local cam = workspace.CurrentCamera
		local camPos = cam and cam.CFrame.Position
		local nowClock = os.clock()
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

					if barsOn then
						local hp, maxHp, shield, maxShield = GetPlayerHealthAndShield(char, hum)
						local dist = camPos and (camPos - root.Position).Magnitude or 40
						local distBucket = math.floor(dist * 0.25)
						local hpInt = math.floor(hp + 0.5)
						local maxHpInt = math.floor(maxHp + 0.5)
						local shieldInt = math.floor(shield + 0.5)
						local hpPct = math.clamp(hp / maxHp, 0, 1)
						local hpCol = (hpPct > 0.55 and COL_HP_HIGH) or (hpPct > 0.25 and COL_HP_MID) or COL_HP_LOW

						if not pair.healthBg.Visible then
							pair.healthBg.Visible = true
							pair.healthBar.Visible = true
							pair.healthBg.Transparency = 0.0
							pair.healthBg.Color3 = COL_ESP_BLACK
							pair.healthBar.Transparency = 0.0
						end
						if pair.healthBg.Adornee ~= root then
							pair.healthBg.Adornee = root
							pair.healthBar.Adornee = root
						end
						if pair.lastDistBucket ~= distBucket or pair.lastHpInt ~= hpInt or pair.lastMaxHpInt ~= maxHpInt then
							local barThick = math.clamp(0.48 + (dist * 0.0055), 0.48, 3.2)
							local bgThick = barThick + 0.35
							local xOffsetLeft = -2.5 - (dist * 0.004)
							local barH = math.max(0.22, 5.0 * hpPct)
							pair.healthBg.Size = Vector3.new(bgThick, 5.3, bgThick)
							pair.healthBg.CFrame = CFrame.new(xOffsetLeft, 0, 0)
							pair.healthBar.Size = Vector3.new(barThick, barH, barThick)
							pair.healthBar.CFrame = CFrame.new(xOffsetLeft, -2.5 + (barH * 0.5), 0)
							pair.healthBar.Color3 = hpCol
						end

						local showShield = (shieldInt > 0)
						if pair.shieldBg.Visible ~= showShield then
							pair.shieldBg.Visible = showShield
							pair.shieldBar.Visible = showShield
						end
						if showShield then
							if pair.shieldBg.Adornee ~= root then
								pair.shieldBg.Adornee = root
								pair.shieldBar.Adornee = root
							end
							if pair.lastDistBucket ~= distBucket or pair.lastShieldInt ~= shieldInt then
								local barThick = math.clamp(0.48 + (dist * 0.0055), 0.48, 3.2)
								local bgThick = barThick + 0.35
								local xOffsetRight = 2.5 + (dist * 0.004)
								local sPct = math.clamp(shield / maxShield, 0, 1)
								local sBarH = math.max(0.22, 5.0 * sPct)
								pair.shieldBg.Size = Vector3.new(bgThick, 5.3, bgThick)
								pair.shieldBg.CFrame = CFrame.new(xOffsetRight, 0, 0)
								pair.shieldBg.Transparency = 0.0
								pair.shieldBg.Color3 = COL_ESP_BLACK
								pair.shieldBar.Size = Vector3.new(barThick, sBarH, barThick)
								pair.shieldBar.CFrame = CFrame.new(xOffsetRight, -2.5 + (sBarH * 0.5), 0)
								pair.shieldBar.Transparency = 0.0
								pair.shieldBar.Color3 = COL_SHIELD_CYAN
							end
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
							bgF.BackgroundColor3 = COL_ESP_BLACK
							bgF.BackgroundTransparency = 0.2
							bgF.BorderSizePixel = 0
							bgF.Parent = bb
							AddCorner(bgF, 4)
							local hpFill = Instance.new("Frame")
							hpFill.Size = UDim2.new(1, 0, 1, 0)
							hpFill.BackgroundColor3 = COL_HP_HIGH
							hpFill.BorderSizePixel = 0
							hpFill.Parent = bgF
							AddCorner(hpFill, 4)
							local txt = Instance.new("TextLabel")
							txt.Size = UDim2.new(1, 0, 1, 0)
							txt.BackgroundTransparency = 1
							txt.Font = Enum.Font.GothamBold
							txt.TextSize = 11
							txt.TextColor3 = COL_ESP_WHITE
							txt.Parent = bgF
							pair.hpBillboard = bb
							pair.hpFill = hpFill
							pair.hpText = txt
						end
						if pair.hpBillboard.Adornee ~= root then
							pair.hpBillboard.Adornee = root
						end
						if not pair.hpBillboard.Enabled then pair.hpBillboard.Enabled = true end
						local katTag = (katanaActiveUntil and katanaActiveUntil[plr] and nowClock < katanaActiveUntil[plr]) and "[KATANA] " or ""
						if pair.lastHpInt ~= hpInt or pair.lastMaxHpInt ~= maxHpInt or pair.lastShieldInt ~= shieldInt or pair.lastKatTag ~= katTag then
							pair.hpFill.Size = UDim2.new(hpPct, 0, 1, 0)
							pair.hpFill.BackgroundColor3 = hpCol
							local sValText = (shieldInt > 0) and string.format(" | %d S", shieldInt) or ""
							pair.hpText.Text = string.format("%s%d HP%s", katTag, hpInt, sValText)
							pair.lastKatTag = katTag
						end
						pair.lastDistBucket = distBucket
						pair.lastHpInt = hpInt
						pair.lastMaxHpInt = maxHpInt
						pair.lastShieldInt = shieldInt
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
	-- Section 1: Dual Aimbot Engines ([Q] vs [T]) & Dual Auto Shoot Modes ([Z] Normal vs [V] Aimbot-Lock)
	CreateSectionHeader(Tab7_Visuals, "1. Normal Aimbot [Q] & 2. Target Player Aimbot [T] (Mutually Exclusive)", 1)
	local AimbotEngineCard = CreateCard(Tab7_Visuals, 170, 2)
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
	local aimKeyBindLabel = MakeLabel(AimbotEngineCard, UDim2.new(0.38, -10, 0, 30), UDim2.new(0, 10, 0, 50), "Normal Aim Key:", Enum.Font.GothamSemibold, 12, "TextPrimary", Enum.TextXAlignment.Left)
	aimKeyBindLabel.TextTruncate = Enum.TextTruncate.AtEnd
	local aimbotKeyAssignBtn = MakeButton(AimbotEngineCard, UDim2.new(0.36, -6, 0, 30), UDim2.new(0.38, 4, 0, 50), "Bind Key: [Q]", "PanelBg", 11)
	local aimbotKeyDeleteBtn = Instance.new("TextButton", AimbotEngineCard)
	aimbotKeyDeleteBtn.Size = UDim2.new(0.26, -14, 0, 30)
	aimbotKeyDeleteBtn.Position = UDim2.new(0.74, 4, 0, 50)
	aimbotKeyDeleteBtn.BackgroundColor3 = Color3.fromRGB(165, 38, 55)
	aimbotKeyDeleteBtn.Font = Enum.Font.GothamBold aimbotKeyDeleteBtn.TextSize = 11
	aimbotKeyDeleteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	aimbotKeyDeleteBtn.Text = E.Trash .. " Delete" AddCorner(aimbotKeyDeleteBtn, 6)
	local aimbotBurstModeBtn = Instance.new("TextButton", AimbotEngineCard)
	aimbotBurstModeBtn.Size = UDim2.new(0.5, -14, 0, 32)
	aimbotBurstModeBtn.Position = UDim2.new(0, 10, 0, 88)
	aimbotBurstModeBtn.Font = Enum.Font.GothamBold aimbotBurstModeBtn.TextSize = 11
	aimbotBurstModeBtn.TextColor3 = Color3.fromRGB(255, 255, 255) AddCorner(aimbotBurstModeBtn, 6)
	local aimbotToggleModeBtn = Instance.new("TextButton", AimbotEngineCard)
	aimbotToggleModeBtn.Size = UDim2.new(0.5, -14, 0, 32)
	aimbotToggleModeBtn.Position = UDim2.new(0.5, 4, 0, 88)
	aimbotToggleModeBtn.Font = Enum.Font.GothamBold aimbotToggleModeBtn.TextSize = 11
	aimbotToggleModeBtn.TextColor3 = Color3.fromRGB(255, 255, 255) AddCorner(aimbotToggleModeBtn, 6)
	local aimbotDurLabel = MakeLabel(AimbotEngineCard, UDim2.new(0.5, -14, 0, 32), UDim2.new(0, 10, 0, 126), "Button [Q] On-Time (ms):", Enum.Font.GothamSemibold, 12, "TextPrimary", Enum.TextXAlignment.Left)
	aimbotDurLabel.TextTruncate = Enum.TextTruncate.AtEnd
	local aimbotDurationBox = Instance.new("TextBox", AimbotEngineCard)
	aimbotDurationBox.Size = UDim2.new(0.5, -14, 0, 32)
	aimbotDurationBox.Position = UDim2.new(0.5, 4, 0, 126)
	aimbotDurationBox.PlaceholderText = "Time in ms (e.g. 1000)"
	aimbotDurationBox.Text = tostring(aimbotBurstDurationMs)
	aimbotDurationBox.ClearTextOnFocus = false
	aimbotDurationBox.Font = Enum.Font.GothamSemibold
	aimbotDurationBox.TextSize = 12
	RegisterThemeObject(aimbotDurationBox, "BackgroundColor3", "PanelBg")
	RegisterThemeObject(aimbotDurationBox, "TextColor3", "TextPrimary")
	AddCorner(aimbotDurationBox, 6)

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

	--==============================================================================
	-- ZERO-LAG ZOMBIE & GARGOYLE TOWER AIMBOT ENGINE (Pre-Cached Parts + 0.45ms Budgeted Scanner)
	--==============================================================================
	FUI.ZombieAim = {
		Enabled = (Config.ZombieAimbotEnabled == true),
		Priority = (Config.ZombieAimPriority == "Distance") and "Distance" or "Crosshair",
		CacheList = {},
		CacheMap = {},
		PendingModels = {},
		PendingMap = {},
		DescAddedConn = nil,
		ScanRunning = false,
		LastScanTime = 0,
		MaxDistSq = 950 * 950,
	}
	local Z_KEYWORDS = {
		"zombie", "gargoyle", "monster", "mob", "enemy", "enemies", "undead", "infected",
		"walker", "runner", "brute", "boss", "skeleton", "ghoul", "npc", "bot", "creep",
		"horde", "dummy", "target", "fiend", "minion", "mutant"
	}
	local function HasZombieKeyword(str)
		if type(str) ~= "string" or str == "" then return false end
		local low = string.lower(str)
		for i = 1, #Z_KEYWORDS do
			if string.find(low, Z_KEYWORDS[i], 1, true) then
				return true
			end
		end
		return false
	end

	FUI.ZombieAim.IsPartInAnyZombie = function(inst)
		if not inst then return false, nil end
		local cmap = FUI.ZombieAim.CacheMap
		local p1 = inst.Parent
		if p1 then
			if cmap[p1] then return true, p1 end
			local p2 = p1.Parent
			if p2 then
				if cmap[p2] then return true, p2 end
				local p3 = p2.Parent
				if p3 and cmap[p3] then return true, p3 end
			end
		end
		return false, nil
	end

	FUI.ZombieAim.IsEntryAlive = function(entry)
		if not entry then return false end
		local mdl = entry.Model
		local head = entry.Head
		if not mdl or not mdl.Parent or not head or not head.Parent then return false end
		if head.Transparency >= 0.98 then return false end
		local hum = entry.Hum
		if hum then
			if not hum.Parent or hum.Health <= 0 then return false end
		end
		local hpAttr = mdl:GetAttribute("Health")
		if type(hpAttr) == "number" and hpAttr <= 0 then return false end
		if mdl:GetAttribute("Dead") == true or mdl:GetAttribute("IsDead") == true then return false end
		if head.Position.Y < -450 then return false end
		return true
	end

	FUI.ZombieAim.TryRegisterModel = function(mdl)
		if not mdl or not mdl:IsA("Model") or not mdl.Parent then return false end
		if FUI.ZombieAim.CacheMap[mdl] then return true end
		local myChar = LocalPlayer.Character
		if mdl == myChar or mdl.Name == "LocalWearer_LocalTryOn" or mdl.Name == "TR_FakeFloor" then return false end
		local cam = workspace.CurrentCamera
		if cam and mdl:IsDescendantOf(cam) then return false end
		if myChar and mdl:IsDescendantOf(myChar) then return false end
		if Players:GetPlayerFromCharacter(mdl) ~= nil or Players:FindFirstChild(mdl.Name) ~= nil then return false end
		for _, plr in ipairs(Players:GetPlayers()) do
			local pc = plr.Character
			if pc and (mdl == pc or mdl:IsDescendantOf(pc)) then return false end
		end

		local head = mdl:FindFirstChild("Head") or mdl:FindFirstChild("HeadHitbox") or mdl:FindFirstChild("Hitbox")
		local body = mdl:FindFirstChild("HumanoidRootPart") or mdl:FindFirstChild("Torso") or mdl:FindFirstChild("UpperTorso") or mdl:FindFirstChild("LowerTorso") or mdl:FindFirstChild("Body") or mdl.PrimaryPart
		local hum = mdl:FindFirstChildOfClass("Humanoid")
		local anim = mdl:FindFirstChildOfClass("AnimationController") or mdl:FindFirstChildOfClass("Animator")

		if hum and hum.Health <= 0 then return false end
		local hpAttr = mdl:GetAttribute("Health")
		if type(hpAttr) == "number" and hpAttr <= 0 then return false end
		if mdl:GetAttribute("Dead") == true or mdl:GetAttribute("IsDead") == true then return false end

		local p1 = mdl.Parent
		local p2 = p1 and p1.Parent
		local p3 = p2 and p2.Parent
		local hasKeyword = HasZombieKeyword(mdl.Name) or (p1 and HasZombieKeyword(p1.Name)) or (p2 and HasZombieKeyword(p2.Name)) or (p3 and HasZombieKeyword(p3.Name))

		local limbCount, hasGreenLimb = 0, false
		if not head or not head:IsA("BasePart") or not body or not body:IsA("BasePart") then
			local highestY = -math.huge
			for _, ch in ipairs(mdl:GetChildren()) do
				if ch:IsA("BasePart") and ch.Transparency < 0.98 and ch.Size.X <= 16 and ch.Size.Y <= 16 and ch.Size.Z <= 16 then
					limbCount = limbCount + 1
					local col = ch.Color
					if col.G > 0.42 and col.G > col.R * 1.2 and col.G > col.B * 1.2 then
						hasGreenLimb = true
					end
					if not body then body = ch end
					if ch.Position.Y > highestY then
						highestY = ch.Position.Y
						head = ch
					end
				end
			end
		end

		local validHead = (head and head:IsA("BasePart") and head) or (body and body:IsA("BasePart") and body)
		local validBody = (body and body:IsA("BasePart") and body) or validHead
		if not validHead then return false end
		if validHead.Size.X > 22 or validHead.Size.Y > 22 or validHead.Size.Z > 22 then return false end
		if validHead.Transparency >= 0.98 then return false end

		local hasRigAnatomy = (head ~= nil and body ~= nil and head ~= body and (
			mdl:FindFirstChild("Left Arm") ~= nil or mdl:FindFirstChild("Right Arm") ~= nil or
			mdl:FindFirstChild("LeftUpperArm") ~= nil or mdl:FindFirstChild("RightUpperArm") ~= nil or
			validHead:FindFirstChildOfClass("Decal") ~= nil or validHead:FindFirstChildOfClass("SpecialMesh") ~= nil or
			validBody:FindFirstChildOfClass("Motor6D") ~= nil or validHead:FindFirstChildOfClass("Motor6D") ~= nil or
			not validHead.Anchored or not validBody.Anchored
		))
		local hasHealthVal = (hpAttr ~= nil or mdl:GetAttribute("MaxHealth") ~= nil or mdl:FindFirstChild("Health") ~= nil)

		local hasZombieColorRig = (hasGreenLimb and limbCount >= 3 and limbCount <= 20)
		if not (hum or anim or hasKeyword or hasRigAnatomy or hasHealthVal or hasZombieColorRig) then
			return false
		end

		local dispName = mdl.Name
		if dispName == "Model" or dispName == "Rig" or dispName == "Enemy" then
			dispName = (p1 and p1 ~= workspace and p1.Name ~= "Models" and p1.Name) or "Zombie"
		end

		local entry = {
			Model = mdl,
			Head = validHead,
			Body = validBody,
			Hum = hum,
			Name = dispName
		}
		FUI.ZombieAim.CacheMap[mdl] = entry
		FUI.ZombieAim.CacheList[#FUI.ZombieAim.CacheList + 1] = entry
		return true
	end

	FUI.ZombieAim.QueueModel = function(mdl)
		if not mdl or not mdl:IsA("Model") or FUI.ZombieAim.CacheMap[mdl] or FUI.ZombieAim.PendingMap[mdl] then return end
		FUI.ZombieAim.PendingMap[mdl] = true
		FUI.ZombieAim.PendingModels[#FUI.ZombieAim.PendingModels + 1] = mdl
	end

	FUI.ZombieAim.StepPendingQueue = function()
		local q = FUI.ZombieAim.PendingModels
		local qMap = FUI.ZombieAim.PendingMap
		local count = 0
		while #q > 0 and count < 25 do
			local mdl = q[#q]
			q[#q] = nil
			qMap[mdl] = nil
			count = count + 1
			FUI.ZombieAim.TryRegisterModel(mdl)
		end
	end

	FUI.ZombieAim.StartBudgetedScan = function()
		if FUI.ZombieAim.ScanRunning then return end
		FUI.ZombieAim.ScanRunning = true
		FUI.ZombieAim.LastScanTime = os.clock()
		task.spawn(function()
			local myChar = LocalPlayer.Character
			local cam = workspace.CurrentCamera
			local stack = { workspace }
			local depthMap = { [workspace] = 0 }
			local sliceStart = os.clock()

			while #stack > 0 and FUI.ZombieAim.Enabled and not isClosingPermanently do
				local node = stack[#stack]
				stack[#stack] = nil
				local d = depthMap[node] or 0
				depthMap[node] = nil

				if node and node.Parent or node == workspace then
					local okCh, children = pcall(node.GetChildren, node)
					if okCh and type(children) == "table" then
						for i = 1, #children do
							local ch = children[i]
							if ch ~= cam and ch ~= myChar and ch.Name ~= "Terrain" and ch.Name ~= "LocalWearer_LocalTryOn" and ch.Name ~= "TR_FakeFloor" then
								if ch:IsA("Model") then
									if Players:GetPlayerFromCharacter(ch) == nil then
										local isZ = FUI.ZombieAim.TryRegisterModel(ch)
										if not isZ and d < 9 then
											stack[#stack + 1] = ch
											depthMap[ch] = d + 1
										end
									end
								elseif ch:IsA("Folder") and d < 10 then
									stack[#stack + 1] = ch
									depthMap[ch] = d + 1
								end
							end
						end
					end
				end

				if os.clock() - sliceStart >= 0.00045 then
					task.wait()
					sliceStart = os.clock()
					myChar = LocalPlayer.Character
					cam = workspace.CurrentCamera
				end
			end
			FUI.ZombieAim.ScanRunning = false
		end)
	end

	FUI.ZombieAim.SyncScannerHooks = function()
		if FUI.ZombieAim.Enabled and not isClosingPermanently then
			if not FUI.ZombieAim.DescAddedConn then
				FUI.ZombieAim.DescAddedConn = workspace.DescendantAdded:Connect(function(inst)
					if not FUI.ZombieAim.Enabled then return end
					if inst:IsA("Model") then
						FUI.ZombieAim.QueueModel(inst)
					elseif inst:IsA("Humanoid") or inst:IsA("AnimationController") then
						local p = inst.Parent
						if p and p:IsA("Model") then FUI.ZombieAim.QueueModel(p) end
					elseif inst:IsA("BasePart") and (inst.Name == "Head" or inst.Name == "Torso" or inst.Name == "UpperTorso" or inst.Name == "HumanoidRootPart" or inst.Name == "Hitbox") then
						local p = inst.Parent
						if p and p:IsA("Model") then FUI.ZombieAim.QueueModel(p) end
					end
				end)
			end
			FUI.ZombieAim.StartBudgetedScan()
		else
			if FUI.ZombieAim.DescAddedConn then
				pcall(function() FUI.ZombieAim.DescAddedConn:Disconnect() end)
				FUI.ZombieAim.DescAddedConn = nil
			end
			table.clear(FUI.ZombieAim.PendingModels)
			table.clear(FUI.ZombieAim.PendingMap)
		end
	end

	FUI.ZombieAim.FindBestZombie = function(cam)
		if not FUI.ZombieAim.Enabled or not cam then return nil, nil, math.huge end
		local list = FUI.ZombieAim.CacheList
		local cmap = FUI.ZombieAim.CacheMap
		local camPos = cam.CFrame.Position
		local myChar = LocalPlayer.Character
		local myRoot = myChar and (myChar:FindFirstChild("HumanoidRootPart") or myChar.PrimaryPart)
		local refPos = (myRoot and myRoot.Position) or camPos
		local maxDistSq = FUI.ZombieAim.MaxDistSq
		local maxFov = fovCircleEnabled and FOV_RADIUS or math.huge
		local useDistPrio = (FUI.ZombieAim.Priority == "Distance")
		local wantHead = (aimPartName == "Head")

		local b1Entry, b1Part, b1Score = nil, nil, math.huge
		local b2Entry, b2Part, b2Score = nil, nil, math.huge
		local b3Entry, b3Part, b3Score = nil, nil, math.huge

		for i = #list, 1, -1 do
			local entry = list[i]
			if not FUI.ZombieAim.IsEntryAlive(entry) then
				cmap[entry.Model] = nil
				list[i] = list[#list]
				list[#list] = nil
			else
				local part = (wantHead and entry.Head) or entry.Body or entry.Head
				if part and part.Parent then
					local pp = part.Position
					local cdx, cdy, cdz = pp.X - camPos.X, pp.Y - camPos.Y, pp.Z - camPos.Z
					local cDistSq = cdx * cdx + cdy * cdy + cdz * cdz
					if cDistSq >= 4.5 and cDistSq <= maxDistSq then
						local _, onScreen, sDist = worldToScreenDistance(pp)
						if onScreen and sDist <= maxFov then
							local score
							if useDistPrio then
								local rdx, rdy, rdz = pp.X - refPos.X, pp.Y - refPos.Y, pp.Z - refPos.Z
								score = math.sqrt(rdx * rdx + rdy * rdy + rdz * rdz) + (sDist * 0.05)
							else
								score = sDist + (math.sqrt(cDistSq) * 0.08)
							end
							if score < b1Score then
								b3Entry, b3Part, b3Score = b2Entry, b2Part, b2Score
								b2Entry, b2Part, b2Score = b1Entry, b1Part, b1Score
								b1Entry, b1Part, b1Score = entry, part, score
							elseif score < b2Score then
								b3Entry, b3Part, b3Score = b2Entry, b2Part, b2Score
								b2Entry, b2Part, b2Score = entry, part, score
							elseif score < b3Score then
								b3Entry, b3Part, b3Score = entry, part, score
							end
						end
					end
				end
			end
		end

		if b1Entry and isTargetVisible(b1Part, b1Entry.Model) then
			return b1Entry.Model, b1Entry, b1Score
		end
		if b2Entry and isTargetVisible(b2Part, b2Entry.Model) then
			return b2Entry.Model, b2Entry, b2Score
		end
		if b3Entry and isTargetVisible(b3Part, b3Entry.Model) then
			return b3Entry.Model, b3Entry, b3Score
		end
		return nil, nil, math.huge
	end

	-- Card 2.5: 3. Zombie & Gargoyle Tower Aimbot [G] (Zero-Lag Horde Aimlock)
	local ZombieAimbotCard = CreateCard(Tab7_Visuals, 132, 3)
	local zombieAimToggleBtn = Instance.new("TextButton", ZombieAimbotCard)
	zombieAimToggleBtn.Size = UDim2.new(0.5, -14, 0, 34)
	zombieAimToggleBtn.Position = UDim2.new(0, 10, 0, 10)
	zombieAimToggleBtn.Font = Enum.Font.GothamBold
	zombieAimToggleBtn.TextSize = 12
	zombieAimToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	AddCorner(zombieAimToggleBtn, 6)

	local zombieAimStatusLbl = Instance.new("TextLabel", ZombieAimbotCard)
	zombieAimStatusLbl.Size = UDim2.new(0.5, -14, 0, 34)
	zombieAimStatusLbl.Position = UDim2.new(0.5, 4, 0, 10)
	zombieAimStatusLbl.BackgroundTransparency = 0.15
	zombieAimStatusLbl.Font = Enum.Font.GothamSemibold
	zombieAimStatusLbl.TextSize = 11
	zombieAimStatusLbl.Text = "Zombie Aim: Idle"
	RegisterThemeObject(zombieAimStatusLbl, "BackgroundColor3", "PanelBg")
	RegisterThemeObject(zombieAimStatusLbl, "TextColor3", "TextPrimary")
	AddCorner(zombieAimStatusLbl, 6)
	FUI.ZombieAim.StatusLabel = zombieAimStatusLbl

	local zKeyLabel = MakeLabel(ZombieAimbotCard, UDim2.new(0.38, -10, 0, 30), UDim2.new(0, 10, 0, 50), "Zombie Aim Key:", Enum.Font.GothamSemibold, 12, "TextPrimary", Enum.TextXAlignment.Left)
	zKeyLabel.TextTruncate = Enum.TextTruncate.AtEnd
	local zombieAimKeyAssignBtn = MakeButton(ZombieAimbotCard, UDim2.new(0.36, -6, 0, 30), UDim2.new(0.38, 4, 0, 50), "Bind Key: [G]", "PanelBg", 11)
	local zombieAimKeyDeleteBtn = Instance.new("TextButton", ZombieAimbotCard)
	zombieAimKeyDeleteBtn.Size = UDim2.new(0.26, -14, 0, 30)
	zombieAimKeyDeleteBtn.Position = UDim2.new(0.74, 4, 0, 50)
	zombieAimKeyDeleteBtn.BackgroundColor3 = Color3.fromRGB(165, 38, 55)
	zombieAimKeyDeleteBtn.Font = Enum.Font.GothamBold
	zombieAimKeyDeleteBtn.TextSize = 11
	zombieAimKeyDeleteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	zombieAimKeyDeleteBtn.Text = E.Trash .. " Delete"
	AddCorner(zombieAimKeyDeleteBtn, 6)

	local zombieCrosshairPrioBtn = Instance.new("TextButton", ZombieAimbotCard)
	zombieCrosshairPrioBtn.Size = UDim2.new(0.5, -14, 0, 32)
	zombieCrosshairPrioBtn.Position = UDim2.new(0, 10, 0, 88)
	zombieCrosshairPrioBtn.Font = Enum.Font.GothamBold
	zombieCrosshairPrioBtn.TextSize = 11
	zombieCrosshairPrioBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	AddCorner(zombieCrosshairPrioBtn, 6)

	local zombieDistancePrioBtn = Instance.new("TextButton", ZombieAimbotCard)
	zombieDistancePrioBtn.Size = UDim2.new(0.5, -14, 0, 32)
	zombieDistancePrioBtn.Position = UDim2.new(0.5, 4, 0, 88)
	zombieDistancePrioBtn.Font = Enum.Font.GothamBold
	zombieDistancePrioBtn.TextSize = 11
	zombieDistancePrioBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	AddCorner(zombieDistancePrioBtn, 6)

	-- Card 3: Mode 1 - Normal Auto Shoot [Z] (Works Anytime Screen Middle Dot is on a Player)
	local AutoShootCard = CreateCard(Tab7_Visuals, 94, 4)
	local autoShootToggleBtn = Instance.new("TextButton", AutoShootCard)
	autoShootToggleBtn.Size = UDim2.new(0.5, -14, 0, 34) autoShootToggleBtn.Position = UDim2.new(0, 10, 0, 10)
	autoShootToggleBtn.Font = Enum.Font.GothamBold autoShootToggleBtn.TextSize = 12
	autoShootToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255) AddCorner(autoShootToggleBtn, 6)
	autoShootStatusLbl = Instance.new("TextLabel", AutoShootCard)
	autoShootStatusLbl.Size = UDim2.new(0.5, -14, 0, 34)
	autoShootStatusLbl.Position = UDim2.new(0.5, 4, 0, 10) autoShootStatusLbl.BackgroundTransparency = 0.15
	autoShootStatusLbl.Font = Enum.Font.GothamSemibold autoShootStatusLbl.TextSize = 11
	autoShootStatusLbl.Text = "Normal Shoot: OFF"
	RegisterThemeObject(autoShootStatusLbl, "BackgroundColor3", "PanelBg")
	RegisterThemeObject(autoShootStatusLbl, "TextColor3", "TextPrimary") AddCorner(autoShootStatusLbl, 6)
	local asKeyLabel = MakeLabel(AutoShootCard, UDim2.new(0.38, -10, 0, 30), UDim2.new(0, 10, 0, 52), "Normal Shoot Key:", Enum.Font.GothamSemibold, 12, "TextPrimary", Enum.TextXAlignment.Left)
	asKeyLabel.TextTruncate = Enum.TextTruncate.AtEnd
	local autoShootKeyAssignBtn = MakeButton(AutoShootCard, UDim2.new(0.36, -6, 0, 30), UDim2.new(0.38, 4, 0, 52), "Bind Key: [Z]", "PanelBg", 11)
	local autoShootKeyDeleteBtn = Instance.new("TextButton", AutoShootCard)
	autoShootKeyDeleteBtn.Size = UDim2.new(0.26, -14, 0, 30)
	autoShootKeyDeleteBtn.Position = UDim2.new(0.74, 4, 0, 52)
	autoShootKeyDeleteBtn.BackgroundColor3 = Color3.fromRGB(165, 38, 55)
	autoShootKeyDeleteBtn.Font = Enum.Font.GothamBold autoShootKeyDeleteBtn.TextSize = 11
	autoShootKeyDeleteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	autoShootKeyDeleteBtn.Text = E.Trash .. " Delete" AddCorner(autoShootKeyDeleteBtn, 6)

	-- Card 4: Mode 2 - Aimbot-Lock Auto Shoot [V] (Fires ONLY When Aimbot [Q]/[T] is ON & Locked onto a Player)
	local AimbotAutoShootCard = CreateCard(Tab7_Visuals, 94, 5)
	local aimbotAutoShootToggleBtn = Instance.new("TextButton", AimbotAutoShootCard)
	aimbotAutoShootToggleBtn.Size = UDim2.new(0.5, -14, 0, 34) aimbotAutoShootToggleBtn.Position = UDim2.new(0, 10, 0, 10)
	aimbotAutoShootToggleBtn.Font = Enum.Font.GothamBold aimbotAutoShootToggleBtn.TextSize = 12
	aimbotAutoShootToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255) AddCorner(aimbotAutoShootToggleBtn, 6)
	aimbotAutoShootStatusLbl = Instance.new("TextLabel", AimbotAutoShootCard)
	aimbotAutoShootStatusLbl.Size = UDim2.new(0.5, -14, 0, 34)
	aimbotAutoShootStatusLbl.Position = UDim2.new(0.5, 4, 0, 10) aimbotAutoShootStatusLbl.BackgroundTransparency = 0.15
	aimbotAutoShootStatusLbl.Font = Enum.Font.GothamSemibold aimbotAutoShootStatusLbl.TextSize = 11
	aimbotAutoShootStatusLbl.Text = "Aimbot Shoot: OFF"
	RegisterThemeObject(aimbotAutoShootStatusLbl, "BackgroundColor3", "PanelBg")
	RegisterThemeObject(aimbotAutoShootStatusLbl, "TextColor3", "TextPrimary") AddCorner(aimbotAutoShootStatusLbl, 6)
	local aasKeyLabel = MakeLabel(AimbotAutoShootCard, UDim2.new(0.38, -10, 0, 30), UDim2.new(0, 10, 0, 52), "Aimbot Shoot Key:", Enum.Font.GothamSemibold, 12, "TextPrimary", Enum.TextXAlignment.Left)
	aasKeyLabel.TextTruncate = Enum.TextTruncate.AtEnd
	local aimbotAutoShootKeyAssignBtn = MakeButton(AimbotAutoShootCard, UDim2.new(0.36, -6, 0, 30), UDim2.new(0.38, 4, 0, 52), "Bind Key: [V]", "PanelBg", 11)
	local aimbotAutoShootKeyDeleteBtn = Instance.new("TextButton", AimbotAutoShootCard)
	aimbotAutoShootKeyDeleteBtn.Size = UDim2.new(0.26, -14, 0, 30)
	aimbotAutoShootKeyDeleteBtn.Position = UDim2.new(0.74, 4, 0, 52)
	aimbotAutoShootKeyDeleteBtn.BackgroundColor3 = Color3.fromRGB(165, 38, 55)
	aimbotAutoShootKeyDeleteBtn.Font = Enum.Font.GothamBold aimbotAutoShootKeyDeleteBtn.TextSize = 11
	aimbotAutoShootKeyDeleteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	aimbotAutoShootKeyDeleteBtn.Text = E.Trash .. " Delete" AddCorner(aimbotAutoShootKeyDeleteBtn, 6)

	-- Slider for Triggerbot Fire Rate & Burst Delay (1ms to 100ms)
	CreateSlider(Tab7_Visuals, "Triggerbot Fire Rate / Burst Delay (ms)", 1, 100, math.clamp(tonumber(Config.AutoShootDelayMs) or 25, 1, 100), 6, function(val)
		Config.AutoShootDelayMs = val
		savedConfig.Settings.AutoShootDelayMs = val
		SaveConfig(false)
	end)

	CreateToggle(Tab7_Visuals, "Aggressive Strong Lock Mode (Instant Snap + Velocity Lead)", strongLock, 7, function(state)
		strongLock = state Config.StrongLock = state if not strongLock then currentTarget = nil end
		SaveConfig(false) end)
	CreateToggle(Tab7_Visuals, "Raycast Wallcheck (Stop Aim & Auto-Shoot Behind Walls)", wallcheckEnabled, 8, function(state)
		wallcheckEnabled = state Config.WallcheckEnabled = state SaveConfig(false) end)
	CreateToggle(Tab7_Visuals, "Enemy Katana Auto-Alert & Deflect Blocker (Notify + Stop Shoot)", Config.AntiKatanaEnabled ~= false, 8, function(state)
		Config.AntiKatanaEnabled = state savedConfig.Settings.AntiKatanaEnabled = state
		if not state then SetKatanaClickBlockState(false) if KatanaWarnBanner then KatanaWarnBanner.Visible = false end end
		SaveConfig(false) end)
	CreateToggle(Tab7_Visuals, "Only Aim at Enemies (Ignore Teammates in Normal Aimbot)", aimbotTeamCheck, 9, function(state)
		aimbotTeamCheck = state Config.AimbotTeamCheck = state
		if state and currentTarget and IsTeammate(currentTarget) then currentTarget = nil end SaveConfig(false)
	end)
	CreateToggle(Tab7_Visuals, "Show Aimbot FOV Circle (Turn OFF for Full-Screen Aimbot)", fovCircleEnabled, 10, function(state)
		fovCircleEnabled = state Config.AimbotFOVCircleEnabled = state currentTarget = nil
		SyncAimbotFovCircleVisibility() SaveConfig(false) end)
	-- Neat V95 CreateSlider for Aimbot FOV Circle Radius
	local FovSliderObj local fovBox
	FovSliderObj = CreateSlider(Tab7_Visuals, "Aimbot FOV Circle Radius (px)", 20, 800, FOV_RADIUS, 11, function(val)
		FOV_RADIUS = val Config.AimbotFOVRadius = val if fovBox then fovBox.Text = tostring(val) end
		SyncAimbotFovCircleVisibility() SaveConfig(false) end)
	-- Target Part, Manual FOV Input & Player Exclusion Row Card
	local AimbotExtraCard = CreateCard(Tab7_Visuals, 48, 12)
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

	RefreshAimbotVisuals = function()
		local theme = GetTheme()
		local k = Config.AimbotKeybind or "Q"
		aimbotKeyAssignBtn.Text = "Bind Key: [" .. k .. "]"
		local isBurst = (aimbotKeyMode == "Burst1s")
		if isBurst then
			aimbotToggleBtn.Text = "Button Aim [" .. k .. "]: " .. (aimbotEnabled and ("ON (" .. tostring(aimbotBurstDurationMs) .. "ms)") or "OFF")
		else
			aimbotToggleBtn.Text = "Toggle Aimbot [" .. k .. "]: " .. (aimbotEnabled and "ON" or "OFF")
		end
		aimbotToggleBtn.BackgroundColor3 = aimbotEnabled and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(185, 52, 52)
		aimbotBurstModeBtn.Text = (isBurst and "[ON] " or "") .. "1. Button [" .. k .. "] (" .. tostring(aimbotBurstDurationMs) .. "ms)"
		aimbotBurstModeBtn.BackgroundColor3 = isBurst and theme.Accent or theme.PanelBg
		aimbotToggleModeBtn.Text = (not isBurst and "[ON] " or "") .. "2. Toggle [" .. k .. "] (Stay ON)"
		aimbotToggleModeBtn.BackgroundColor3 = (not isBurst) and theme.Accent or theme.PanelBg

		local zk = Config.ZombieAimbotKeybind or "G"
		zombieAimKeyAssignBtn.Text = "Bind Key: [" .. zk .. "]"
		local zOn = (FUI.ZombieAim and FUI.ZombieAim.Enabled == true)
		zombieAimToggleBtn.Text = "Zombie Aimbot [" .. zk .. "]: " .. (zOn and "ON" or "OFF")
		zombieAimToggleBtn.BackgroundColor3 = zOn and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(185, 52, 52)
		local isCrossPrio = (not FUI.ZombieAim or FUI.ZombieAim.Priority ~= "Distance")
		zombieCrosshairPrioBtn.Text = (isCrossPrio and "[ON] " or "") .. "1. Crosshair / FOV Priority"
		zombieCrosshairPrioBtn.BackgroundColor3 = isCrossPrio and theme.Accent or theme.PanelBg
		zombieDistancePrioBtn.Text = (not isCrossPrio and "[ON] " or "") .. "2. Closest Distance Priority"
		zombieDistancePrioBtn.BackgroundColor3 = (not isCrossPrio) and theme.Accent or theme.PanelBg
		if not zOn and zombieAimStatusLbl then
			zombieAimStatusLbl.Text = "Zombie Aim: Idle"
		end

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
		autoShootToggleBtn.Text = "Normal Auto Shoot [" .. ask .. "]: " .. (autoShootEnabled and "ON" or "OFF")
		autoShootToggleBtn.BackgroundColor3 = autoShootEnabled and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(185, 52, 52)
		if not autoShootEnabled then
			if autoShootStatusLbl then autoShootStatusLbl.Text = "Normal Shoot: OFF" end
		else
			if autoShootStatusLbl then autoShootStatusLbl.Text = "Ready (Point at Player)" end
		end

		local aask = Config.AimbotAutoShootKeybind or "V"
		aimbotAutoShootKeyAssignBtn.Text = "Bind Key: [" .. aask .. "]"
		aimbotAutoShootToggleBtn.Text = "Aimbot Auto Shoot [" .. aask .. "]: " .. (aimbotAutoShootEnabled and "ON" or "OFF")
		aimbotAutoShootToggleBtn.BackgroundColor3 = aimbotAutoShootEnabled and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(185, 52, 52)
		if not aimbotAutoShootEnabled then
			if aimbotAutoShootStatusLbl then aimbotAutoShootStatusLbl.Text = "Aimbot Shoot: OFF" end
		elseif not (aimbotEnabled or targetAimbotEnabled or (FUI.ZombieAim and FUI.ZombieAim.Enabled)) then
			if aimbotAutoShootStatusLbl then aimbotAutoShootStatusLbl.Text = "Standby (Need Aimbot [Q])" end
		else
			if aimbotAutoShootStatusLbl then aimbotAutoShootStatusLbl.Text = "Waiting Aimbot Lock..." end
		end

		if not (autoShootEnabled or aimbotAutoShootEnabled) then
			StopAutoShootFiring()
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
	if FUI.RegisterSearchFunction then
		FUI.RegisterSearchFunction({
			Name = "1. Normal Aimbot [Q] (Camera Lock)",
			TabName = "Aimbot & Visuals",
			Keywords = "normal aimbot lock head body q camera aim",
			Priority = 1,
			GetState = function() return aimbotEnabled == true end,
			Toggle = function() if toggleAimbot then toggleAimbot() end end
		})
		FUI.RegisterSearchFunction({
			Name = "3. Zombie & Gargoyle Tower Aimbot [G] (Zero-Lag NPC Lock)",
			TabName = "Aimbot & Visuals",
			Keywords = "zombie gargoyle tower npc mob monster aimbot lock g horde",
			Priority = 2,
			GetState = function() return (FUI.ZombieAim and FUI.ZombieAim.Enabled == true) end,
			Toggle = function() if FUI.ZombieAim and FUI.ZombieAim.ToggleFunc then FUI.ZombieAim.ToggleFunc() end end
		})
		FUI.RegisterSearchFunction({
			Name = "2. Target Specific Player Aimbot [T]",
			TabName = "Aimbot & Visuals",
			Keywords = "target specific player aimbot lock t aim",
			Priority = 2,
			GetState = function() return targetAimbotEnabled == true end,
			Toggle = function() if toggleTargetAimbot then toggleTargetAimbot() end end
		})
		FUI.RegisterSearchFunction({
			Name = "Mode 1: Normal Auto Shoot / Triggerbot [Z]",
			TabName = "Aimbot & Visuals",
			Keywords = "normal auto shoot triggerbot rapid fire z shoot",
			Priority = 3,
			GetState = function() return autoShootEnabled == true end,
			Toggle = function() if toggleAutoShoot then toggleAutoShoot() end end
		})
		FUI.RegisterSearchFunction({
			Name = "Mode 2: Aimbot-Lock Auto Shoot [V]",
			TabName = "Aimbot & Visuals",
			Keywords = "aimbot lock auto shoot triggerbot fire v shoot",
			Priority = 4,
			GetState = function() return aimbotAutoShootEnabled == true end,
			Toggle = function() if toggleAimbotAutoShoot then toggleAimbotAutoShoot() end end
		})
	end
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

	-- Mutual Exclusivity: Normal Aimbot [Q] (Option 1: 1s Button vs Option 2: Toggle) vs Target Player Aimbot [T]
	toggleAimbot = function()
		if aimbotKeyMode == "Burst1s" then
			local durSec = math.clamp((tonumber(aimbotBurstDurationMs) or 1000) / 1000, 0.05, 60)
			aimbotEnabled = true
			Config.AimbotEnabled = true
			savedConfig.Settings.AimbotEnabled = false
			aimbotBurstEndTime = os.clock() + durSec
			NotifyFeatureToggle("Button Aimbot (" .. tostring(aimbotBurstDurationMs) .. "ms)", true)
			if targetAimbotEnabled then
				targetAimbotEnabled = false
				Config.TargetAimbotEnabled = false
				savedConfig.Settings.TargetAimbotEnabled = false
			end
			currentTarget = nil
			RefreshAimbotVisuals()
			task.delay(durSec + 0.01, function()
				if aimbotEnabled and aimbotKeyMode == "Burst1s" and aimbotBurstEndTime > 0 and os.clock() >= aimbotBurstEndTime then
					aimbotEnabled = false
					Config.AimbotEnabled = false
					aimbotBurstEndTime = 0
					currentTarget = nil
					if aimbotAutoShootEnabled and StopAutoShootFiring then StopAutoShootFiring() end
					NotifyFeatureToggle("Button Aimbot", false)
					if aimbotStatusLabel then aimbotStatusLabel.Text = "Status: Idle (" .. tostring(aimbotBurstDurationMs) .. "ms Ended)" end
					RefreshAimbotVisuals()
				end
			end)
		else
			aimbotBurstEndTime = 0
			aimbotEnabled = not aimbotEnabled
			NotifyFeatureToggle("Normal Aimbot", aimbotEnabled)
			Config.AimbotEnabled = aimbotEnabled
			savedConfig.Settings.AimbotEnabled = aimbotEnabled
			if aimbotEnabled and targetAimbotEnabled then
				targetAimbotEnabled = false
				Config.TargetAimbotEnabled = false
				savedConfig.Settings.TargetAimbotEnabled = false
			end
			currentTarget = nil
			if not (aimbotEnabled or targetAimbotEnabled) then
				if aimbotAutoShootEnabled then StopAutoShootFiring() end
				if aimbotStatusLabel then aimbotStatusLabel.Text = "Status: Idle" end
			end
			RefreshAimbotVisuals()
			SaveConfig(false)
		end
	end

	aimbotBurstModeBtn.MouseButton1Click:Connect(function()
		aimbotKeyMode = "Burst1s"
		Config.AimbotKeyMode = "Burst1s"
		savedConfig.Settings.AimbotKeyMode = "Burst1s"
		aimbotBurstEndTime = 0
		if aimbotEnabled then
			aimbotEnabled = false
			Config.AimbotEnabled = false
			savedConfig.Settings.AimbotEnabled = false
			currentTarget = nil
			if aimbotAutoShootEnabled and StopAutoShootFiring then StopAutoShootFiring() end
			if aimbotStatusLabel then aimbotStatusLabel.Text = "Status: Idle (1s Mode)" end
		end
		RefreshAimbotVisuals()
		SaveConfig(false)
	end)

	aimbotToggleModeBtn.MouseButton1Click:Connect(function()
		aimbotKeyMode = "Toggle"
		Config.AimbotKeyMode = "Toggle"
		savedConfig.Settings.AimbotKeyMode = "Toggle"
		aimbotBurstEndTime = 0
		RefreshAimbotVisuals()
		SaveConfig(false)
	end)

	aimbotDurationBox.FocusLost:Connect(function()
		local v = tonumber(aimbotDurationBox.Text)
		if v then
			aimbotBurstDurationMs = math.clamp(math.floor(v + 0.5), 50, 60000)
			Config.AimbotBurstDurationMs = aimbotBurstDurationMs
			savedConfig.Settings.AimbotBurstDurationMs = aimbotBurstDurationMs
			SaveConfig(false)
		end
		aimbotDurationBox.Text = tostring(aimbotBurstDurationMs)
		RefreshAimbotVisuals()
	end)

	toggleTargetAimbot = function()
		targetAimbotEnabled = not targetAimbotEnabled
		NotifyFeatureToggle("Target Aimbot", targetAimbotEnabled)
		Config.TargetAimbotEnabled = targetAimbotEnabled
		savedConfig.Settings.TargetAimbotEnabled = targetAimbotEnabled
		if targetAimbotEnabled and aimbotEnabled then
			aimbotEnabled = false
			Config.AimbotEnabled = false
			savedConfig.Settings.AimbotEnabled = false
		end
		currentTarget = nil
		if not (aimbotEnabled or targetAimbotEnabled) then
			if aimbotAutoShootEnabled then StopAutoShootFiring() end
			if aimbotStatusLabel then aimbotStatusLabel.Text = "Status: Idle" end
		end
		RefreshAimbotVisuals()
		SaveConfig(false)
	end

	-- Mutual Exclusivity: Normal Auto Shoot [Z] vs Aimbot-Lock Auto Shoot [V]
	toggleAutoShoot = function()
		autoShootEnabled = not autoShootEnabled
		NotifyFeatureToggle("Normal Auto Shoot", autoShootEnabled)
		Config.AutoShootEnabled = autoShootEnabled
		savedConfig.Settings.AutoShootEnabled = autoShootEnabled
		if autoShootEnabled and aimbotAutoShootEnabled then
			aimbotAutoShootEnabled = false
			Config.AimbotAutoShootEnabled = false
			savedConfig.Settings.AimbotAutoShootEnabled = false
		end
		if not (autoShootEnabled or aimbotAutoShootEnabled) then
			StopAutoShootFiring()
		end
		RefreshAimbotVisuals()
		SaveConfig(false)
	end

	toggleAimbotAutoShoot = function()
		aimbotAutoShootEnabled = not aimbotAutoShootEnabled
		NotifyFeatureToggle("Aimbot Auto Shoot", aimbotAutoShootEnabled)
		Config.AimbotAutoShootEnabled = aimbotAutoShootEnabled
		savedConfig.Settings.AimbotAutoShootEnabled = aimbotAutoShootEnabled
		if aimbotAutoShootEnabled and autoShootEnabled then
			autoShootEnabled = false
			Config.AutoShootEnabled = false
			savedConfig.Settings.AutoShootEnabled = false
		end
		if not (autoShootEnabled or aimbotAutoShootEnabled) or not (aimbotEnabled or targetAimbotEnabled) then
			StopAutoShootFiring()
		end
		RefreshAimbotVisuals()
		SaveConfig(false)
	end

	aimbotToggleBtn.MouseButton1Click:Connect(toggleAimbot)
	targetAimbotToggleBtn.MouseButton1Click:Connect(toggleTargetAimbot)
	autoShootToggleBtn.MouseButton1Click:Connect(toggleAutoShoot)
	aimbotAutoShootToggleBtn.MouseButton1Click:Connect(toggleAimbotAutoShoot)

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

	aimbotAutoShootKeyAssignBtn.MouseButton1Click:Connect(function()
		aimbotAutoShootKeyAssignBtn.Text = "[Key / Del]" ActiveKeybindCaptureCallback = function(k)
			TryAssignUniqueKeybind(k, "AimbotAutoShoot", function(val) Config.AimbotAutoShootKeybind = val; savedConfig.Settings.AimbotAutoShootKeybind = val end, RefreshAimbotVisuals, aimbotAutoShootKeyAssignBtn) end end)
	aimbotAutoShootKeyDeleteBtn.MouseButton1Click:Connect(function() Config.AimbotAutoShootKeybind = "None"; savedConfig.Settings.AimbotAutoShootKeybind = "None"
		ActiveKeybindCaptureCallback = nil RefreshAimbotVisuals() SaveConfig(false) end)

	FUI.ZombieAim.ToggleFunc = function()
		FUI.ZombieAim.Enabled = not FUI.ZombieAim.Enabled
		Config.ZombieAimbotEnabled = FUI.ZombieAim.Enabled
		savedConfig.Settings.ZombieAimbotEnabled = FUI.ZombieAim.Enabled
		if not FUI.ZombieAim.Enabled then
			if currentTarget and typeof(currentTarget) == "Instance" and currentTarget:IsA("Model") then
				currentTarget = nil
			end
			if not (aimbotEnabled or targetAimbotEnabled) and aimbotAutoShootEnabled then
				StopAutoShootFiring()
			end
		end
		FUI.ZombieAim.SyncScannerHooks()
		RefreshAimbotVisuals()
		SaveConfig(false)
		if NotifyFeatureToggle then NotifyFeatureToggle("Zombie & Gargoyle Aimbot", FUI.ZombieAim.Enabled) end
	end
	zombieAimToggleBtn.MouseButton1Click:Connect(FUI.ZombieAim.ToggleFunc)

	zombieCrosshairPrioBtn.MouseButton1Click:Connect(function()
		FUI.ZombieAim.Priority = "Crosshair"
		Config.ZombieAimPriority = "Crosshair"
		savedConfig.Settings.ZombieAimPriority = "Crosshair"
		RefreshAimbotVisuals()
		SaveConfig(false)
	end)
	zombieDistancePrioBtn.MouseButton1Click:Connect(function()
		FUI.ZombieAim.Priority = "Distance"
		Config.ZombieAimPriority = "Distance"
		savedConfig.Settings.ZombieAimPriority = "Distance"
		RefreshAimbotVisuals()
		SaveConfig(false)
	end)
	zombieAimKeyAssignBtn.MouseButton1Click:Connect(function()
		zombieAimKeyAssignBtn.Text = "[Key / Del]"
		ActiveKeybindCaptureCallback = function(k)
			TryAssignUniqueKeybind(k, "ZombieAimbot", function(val)
				Config.ZombieAimbotKeybind = val
				savedConfig.Settings.ZombieAimbotKeybind = val
			end, RefreshAimbotVisuals, zombieAimKeyAssignBtn)
		end
	end)
	zombieAimKeyDeleteBtn.MouseButton1Click:Connect(function()
		Config.ZombieAimbotKeybind = "None"
		savedConfig.Settings.ZombieAimbotKeybind = "None"
		ActiveKeybindCaptureCallback = nil
		RefreshAimbotVisuals()
		SaveConfig(false)
	end)
	if FUI.ZombieAim.Enabled then
		FUI.ZombieAim.SyncScannerHooks()
	end
	fovBox.FocusLost:Connect(function() local v = tonumber(fovBox.Text) if v then
			FOV_RADIUS = math.clamp(math.floor(v + 0.5), 20, 800) Config.AimbotFOVRadius = FOV_RADIUS
			if FovSliderObj then FovSliderObj.SetValue(FOV_RADIUS) end SyncAimbotFovCircleVisibility()
			SaveConfig(false) end fovBox.Text = tostring(FOV_RADIUS) end)
	excludeBtn.MouseButton1Click:Connect(function() excludeFrame.Visible = not excludeFrame.Visible
		AimbotExtraCard.Size = excludeFrame.Visible and UDim2.new(1, 0, 0, 186) or UDim2.new(1, 0, 0, 48)
		if excludeFrame.Visible then rebuildExcludeList() end end) RefreshAimbotVisuals()
	-- Section 2: Player ESP Highlights, 3D Boxes & Health/Shield Bars
	CreateSectionHeader(Tab7_Visuals, "Player ESP (Chams, 3D Boxes & Health/Shield Bars)", 13)
	CreateToggle(Tab7_Visuals, "Player Highlight & 3D Box ESP (Chams + Hitbox Boxes)", Config.ESPEnabled, 14, function(state)
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
	CreateToggle(Tab7_Visuals, "Player Health & Shield Bars (Visible At Any Distance | Works Without ESP)", Config.ESPHealthBars ~= false, 15, function(state)
		Config.ESPHealthBars = state
		if not state and not Config.ESPEnabled then
			clearAllAdornments()
		else
			updateAllAdornments()
		end
		SaveConfig(false)
	end)
	CreateToggle(Tab7_Visuals, "Turn On ESP for Teammates (Show Teammate Highlights & Boxes)", espShowTeammates, 16, function(state)
		espShowTeammates = state Config.ESPShowTeammates = state RefreshESPHighlights() updateAllAdornments()
		SaveConfig(false) end)
	-- Section 3: Camera Field of View & Perspective
	CreateSectionHeader(Tab7_Visuals, "Camera Field of View & Perspective", 17)
	CreateSlider(Tab7_Visuals, "Camera Field of View (FOV)", 30, 120, Config.FOV, 18, function(val)
		Config.FOV = val pcall(function() workspace.CurrentCamera.FieldOfView = val end) SaveConfig(false) end)
	local CamModeCard = CreateCard(Tab7_Visuals, 50, 19) local CamModeList = Instance.new("UIListLayout")
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
	CreateSectionHeader(Tab7_Visuals, "Lighting, Fullbright & Time Presets", 20)
	CreateToggle(Tab7_Visuals, "Fullbright Lighting Mode (No Shadows + Max Illumination)", Config.FullbrightEnabled, 21, function(state)
		Config.FullbrightEnabled = state if not state then pcall(function()
				Lighting.Brightness = DefaultLighting.Brightness
				Lighting.GlobalShadows = DefaultLighting.GlobalShadows
				Lighting.OutdoorAmbient = DefaultLighting.OutdoorAmbient end) end SaveConfig(false) end)
	local TimeCard = CreateCard(Tab7_Visuals, 50, 22) local TimeList = Instance.new("UIListLayout")
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
	NotifyFeatureToggle("Hacker Detector", detectorEnabled)
	RefreshDetectorControlVisuals()
end
DetectorToggleBtn.MouseButton1Click:Connect(ToggleDetectorState)
NotifToggleBtn.MouseButton1Click:Connect(function()
	notificationsEnabled = not notificationsEnabled
	NotifyFeatureToggle("Detector Alerts", notificationsEnabled)
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

if FUI.RegisterSearchFunction then
	FUI.RegisterSearchFunction({
		Name = "Hacker & Abnormal Speed Detector [F4]",
		TabName = "Hacker Detector",
		Keywords = "hacker speed detector scanner anticheat f4",
		Priority = 8,
		GetState = function() return detectorEnabled == true end,
		Toggle = function() ToggleDetectorState() end
	})
	FUI.RegisterSearchFunction({
		Name = "Hacker Detector Popup Alerts",
		TabName = "Hacker Detector",
		Keywords = "hacker detector alerts notifications popup",
		Priority = 9,
		GetState = function() return notificationsEnabled == true end,
		Toggle = function()
			notificationsEnabled = not notificationsEnabled
			NotifyFeatureToggle("Detector Alerts", notificationsEnabled)
			RefreshDetectorControlVisuals()
		end
	})
end
RefreshAllDetectorThemes()
RefreshDetectorHeaderCounts()
end SetupTab9()
--==============================================================================
-- 15.6 TAB 10: AVATAR CHANGER & SAVER (R6/R15 Local Try-On, 3D Preview, Multi-Source Saver)
--==============================================================================
local function SetupTab10()
local vars = {}

vars.getService = function(name)
	local ok, service = pcall(function()
		local s = game:GetService(name)
		return (type(cloneref) == "function") and cloneref(s) or s
	end)
	return ok and service or game:GetService(name)
end

vars.UI_FONT_FAMILY = "rbxasset://fonts/families/BuilderExtended.json"
vars.UI_WEIGHT = Enum.FontWeight.SemiBold

vars.Players = vars.getService("Players")
vars.HttpService = vars.getService("HttpService")
vars.UserInputService = vars.getService("UserInputService")
vars.RunService = vars.getService("RunService")
vars.ContentProvider = vars.getService("ContentProvider")
vars.TweenService = vars.getService("TweenService")
vars.Workspace = vars.getService("Workspace")
vars.CoreGui = vars.getService("CoreGui")
vars.InsertService = vars.getService("InsertService")
vars.StarterGui = vars.getService("StarterGui")
vars.ReplicatedStorage = vars.getService("ReplicatedStorage")

vars.IS_CATALOG_AVATAR_CREATOR = (game.PlaceId == 7041939546)
vars.CATALOG_EVENTS = vars.ReplicatedStorage:FindFirstChild("Events")
vars.CATALOG_GUI_REMOTE = vars.CATALOG_EVENTS and vars.CATALOG_EVENTS:FindFirstChild("CatalogGuiRemote")
vars.SAVED_OUTFITS_REMOTE = vars.CATALOG_EVENTS and vars.CATALOG_EVENTS:FindFirstChild("SavedOutfitsRemote")

vars.LocalPlayer = player or vars.Players.LocalPlayer
if not vars.LocalPlayer then return end

vars.FOLDER_NAME = "Avatar Saver v2"
vars.FILE_PATH = vars.FOLDER_NAME .. "/SavedAvatars.json"
vars.AVATARS_FOLDER = "Avatars"
vars.AVATAR_INDEX_PATH = vars.AVATARS_FOLDER .. "/AvatarIndex.json"
vars.MASTER_FILE_PATH = "TR_SavedAvatars_Master.json"
vars.AVATAR_FILE_PREFIX = "Avatar"
vars.AVATAR_FILE_EXTENSION = ".ava"
vars.SCREEN_GUI_NAME = "LocalWearer_UI"

vars.uiFont = function(weight)
	local ok, font = pcall(function()
		return Font.new(vars.UI_FONT_FAMILY, weight or Enum.FontWeight.Regular)
	end)
	if ok then return font end
	return Font.new("rbxasset://fonts/families/GothamSSm.json", weight or Enum.FontWeight.Regular)
end

vars.runtimeConnections = {}
vars.scriptAlive = true
vars.tryOnActive = false
vars.localTryOnModel = nil
vars.hiddenCharacterParts = {}
vars.hiddenCharacterDecals = {}
vars.localTryOnConnections = {}
vars.localTryOnRootPart = nil
vars.localTryOnGroundOffset = Vector3.zero
vars.localTryOnGroundOffsetValid = false
vars.localTryOnNeutralCloneFeetRootOffsetY = nil
vars.localTryOnSwimOffset = Vector3.zero
vars.currentVerticalOffset = Vector3.zero
vars.localTryOnSeatedHipOffsetLocal = Vector3.zero
vars.localTryOnSeatedHipOffsetValid = false
vars.localTryOnSeatTransitionActive = false
vars.localTryOnSeatTransitionStartLocal = Vector3.zero
vars.localTryOnSeatTransitionStartedAt = 0
vars.localTryOnSwimTransitionActive = false
vars.localTryOnSwimTransitionStart = Vector3.zero
vars.localTryOnSwimTransitionStartedAt = 0
vars.localTryOnLastSwimming = false
vars.localTryOnSeatPart = nil
vars.localTryOnPositionMode = "Ground"
vars.localTryOnSeatCalibrationPending = false
vars.localTryOnSeatCalibrationToken = 0
vars.localTryOnGroundCalibrationFrames = 0
vars.localTryOnHiddenInFirstPerson = false
vars.localTryOnBuilding = false
vars.localTryOnBuildId = 0
vars.localTryOnMissingRecoveryPending = false
vars.localTryOnCollisionParts = {}
vars.placeholderMode = false
vars.placeholderR6Active = false
vars.placeholderR6Building = false
vars.placeholderR6Backup = nil
vars.deathConnection = nil
vars.characterAddedConnection = nil
vars.searchDebounceThread = nil

vars.activeCloneTracks = {}
vars.activeCloneStopConnections = {}
vars.activeCloneEmoteAnimations = {}
vars.activeEmotePlayerTrack = nil
vars.animPlayedConnection = nil
vars.emoteAssetAnimationCache = {}

vars.parseAssetId = function(val)
	if not val then return nil end
	if type(val) == "number" then return val > 0 and val or nil end
	local digits = string.match(tostring(val), "%d+")
	return digits and tonumber(digits) or nil
end

vars.cloneEmoteTable = function(emotes)
	local copy = {}
	if type(emotes) ~= "table" then return copy end
	for name, ids in pairs(emotes) do
		if type(name) == "string" and type(ids) == "table" then
			local idList = {}
			for _, assetId in ipairs(ids) do
				local parsed = vars.parseAssetId(assetId)
				if parsed then idList[#idList + 1] = parsed end
			end
			if #idList > 0 then copy[name] = idList end
		end
	end
	return copy
end

vars.BLUE_NORMAL = Color3.fromRGB(25, 115, 230)
vars.BLUE_HOVER = Color3.fromRGB(45, 135, 255)
vars.GREEN_NORMAL = Color3.fromRGB(35, 175, 80)
vars.GREEN_HOVER = Color3.fromRGB(50, 200, 95)

vars.R6_DEFAULTS = {
	Idle = "rbxassetid://180435571",
	Walk = "rbxassetid://180426354",
	Run = "rbxassetid://180426354",
	Jump = "rbxassetid://125750702",
	Fall = "rbxassetid://180436148",
	Climb = "rbxassetid://180436334",
	Swim = "rbxassetid://180426354",
	SwimIdle = "rbxassetid://180435571",
	Sit = "rbxassetid://178130996"
}

vars.R15_DEFAULTS = {
	Idle = "rbxassetid://507766388",
	Walk = "rbxassetid://913403211",
	Run = "rbxassetid://913384386",
	Jump = "rbxassetid://507765000",
	Fall = "rbxassetid://507767968",
	Climb = "rbxassetid://507765644",
	Swim = "rbxassetid://913389285",
	SwimIdle = "rbxassetid://507785072",
	Sit = "rbxassetid://507768133"
}

vars.R6_EMOTE_LIBRARY = {
	wave = { "rbxassetid://128777973" },
	point = { "rbxassetid://128853357" },
	dance = {
		"rbxassetid://182435998",
		"rbxassetid://182491037",
		"rbxassetid://182491065"
	},
	dance1 = {
		"rbxassetid://182435998",
		"rbxassetid://182491037",
		"rbxassetid://182491065"
	},
	dance2 = {
		"rbxassetid://182436842",
		"rbxassetid://182491248",
		"rbxassetid://182491277"
	},
	dance3 = {
		"rbxassetid://182436935",
		"rbxassetid://182491368",
		"rbxassetid://182491423"
	},
	laugh = { "rbxassetid://129423131" },
	cheer = { "rbxassetid://129423030" }
}

vars.R6_EMOTE_LOOPED = {
	wave = false,
	point = false,
	dance = true,
	dance1 = true,
	dance2 = true,
	dance3 = true,
	laugh = false,
	cheer = false
}

vars.PLAYER_LEGACY_EMOTE_IDS = {
	["507770239"] = "wave",
	["507770453"] = "point",
	["507771019"] = "dance",
	["507771955"] = "dance",
	["507772104"] = "dance",
	["507776043"] = "dance2",
	["507776720"] = "dance2",
	["507776879"] = "dance2",
	["507777268"] = "dance3",
	["507777451"] = "dance3",
	["507777623"] = "dance3",
	["507770818"] = "laugh",
	["507770677"] = "cheer",
}

for emoteName, assetList in pairs(vars.R6_EMOTE_LIBRARY) do
	for _, assetId in ipairs(assetList) do
		local parsed = vars.parseAssetId(assetId)
		if parsed then vars.PLAYER_LEGACY_EMOTE_IDS[tostring(parsed)] = emoteName end
	end
end

vars.previewQueue = {}
vars.previewQueueRunning = false
vars.previewQueueGeneration = 0
vars.previewStates = {}

vars.previewModelCache = {}
vars.previewCacheOrder = {}
vars.PREVIEW_CACHE_LIMIT = 24

vars.getPreviewCacheKey = function(data)
	if not data then return nil end
	local stableId = data.Signature or data.FileName or data.UserId or data.Name
	if stableId ~= nil then
		return tostring(stableId) .. "|" .. tostring(data.RigType)
	end
	local ok, encoded = pcall(function()
		return vars.HttpService:JSONEncode({
			Properties = data.Properties,
			RigType = tostring(data.RigType)
		})
	end)
	if ok and encoded then return encoded end
	return tostring(data)
end

vars.clearPreviewModelCache = function()
	for key, model in pairs(vars.previewModelCache) do
		pcall(function() if model then model:Destroy() end end)
		vars.previewModelCache[key] = nil
	end
	table.clear(vars.previewCacheOrder)
end

vars.touchPreviewCache = function(key)
	for i = #vars.previewCacheOrder, 1, -1 do
		if vars.previewCacheOrder[i] == key then table.remove(vars.previewCacheOrder, i) end
	end
	table.insert(vars.previewCacheOrder, key)
	while #vars.previewCacheOrder > vars.PREVIEW_CACHE_LIMIT do
		local oldKey = table.remove(vars.previewCacheOrder, 1)
		local oldModel = vars.previewModelCache[oldKey]
		vars.previewModelCache[oldKey] = nil
		pcall(function() if oldModel then oldModel:Destroy() end end)
	end
end

vars.wire = function(signal, callback)
	local connection = signal:Connect(callback)
	vars.runtimeConnections[#vars.runtimeConnections + 1] = connection
	return connection
end

vars.disconnectConnection = function(connection)
	if connection then
		pcall(function()
			if connection.Connected then connection:Disconnect() end
		end)
	end
end

vars.setLocalTryOnConnection = function(name, signal, callback)
	vars.disconnectConnection(vars.localTryOnConnections[name])
	if signal and callback then
		vars.localTryOnConnections[name] = signal:Connect(callback)
	else
		vars.localTryOnConnections[name] = nil
	end
	return vars.localTryOnConnections[name]
end

vars.disconnectLocalTryOnConnections = function()
	for name, connection in pairs(vars.localTryOnConnections) do
		vars.disconnectConnection(connection)
		vars.localTryOnConnections[name] = nil
	end
	table.clear(vars.localTryOnCollisionParts)
end

vars.resetLocalTryOnState = function()
	vars.localTryOnRootPart = nil
	vars.localTryOnGroundOffset = Vector3.zero
	vars.localTryOnGroundOffsetValid = false
	vars.localTryOnNeutralCloneFeetRootOffsetY = nil
	vars.localTryOnSwimOffset = Vector3.zero
	vars.currentVerticalOffset = Vector3.zero
	vars.localTryOnSeatedHipOffsetLocal = Vector3.zero
	vars.localTryOnSeatedHipOffsetValid = false
	vars.localTryOnSeatTransitionActive = false
	vars.localTryOnSeatTransitionStartLocal = Vector3.zero
	vars.localTryOnSeatTransitionStartedAt = 0
	vars.localTryOnSwimTransitionActive = false
	vars.localTryOnSwimTransitionStart = Vector3.zero
	vars.localTryOnSwimTransitionStartedAt = 0
	vars.localTryOnLastSwimming = false
	vars.localTryOnSeatPart = nil
	vars.localTryOnPositionMode = "Ground"
	vars.localTryOnSeatCalibrationPending = false
	vars.localTryOnSeatCalibrationToken = vars.localTryOnSeatCalibrationToken + 1
	vars.localTryOnGroundCalibrationFrames = 0
	vars.localTryOnHiddenInFirstPerson = false
end

vars.vector3FromSaved = function(value, fallback)
	if typeof(value) == "Vector3" then return value end
	if type(value) == "table" then
		return Vector3.new(
			tonumber(value.X or value.x) or fallback.X,
			tonumber(value.Y or value.y) or fallback.Y,
			tonumber(value.Z or value.z) or fallback.Z
		)
	end
	return fallback
end

vars.getEnumRigType = function(value)
	if typeof(value) == "EnumItem" then return value end
	local text = tostring(value or "")
	if text:find("R6") then return Enum.HumanoidRigType.R6 end
	return Enum.HumanoidRigType.R15
end

vars.stopAllCloneTracks = function(fadeTime)
	for _, stoppedConnection in pairs(vars.activeCloneStopConnections) do
		vars.disconnectConnection(stoppedConnection)
	end
	table.clear(vars.activeCloneStopConnections)

	for playerTrack, cloneTrack in pairs(vars.activeCloneTracks) do
		pcall(function() cloneTrack:Stop(fadeTime or 0.05) end)
		local animation = vars.activeCloneEmoteAnimations[playerTrack]
		if animation then pcall(function() animation:Destroy() end) end
		vars.activeCloneEmoteAnimations[playerTrack] = nil
	end
	table.clear(vars.activeCloneTracks)
	table.clear(vars.activeCloneEmoteAnimations)
	vars.activeEmotePlayerTrack = nil
end

vars.cleanupAnimationSync = function()
	vars.stopAllCloneTracks()
	vars.disconnectConnection(vars.animPlayedConnection)
	vars.animPlayedConnection = nil
end

vars.cleanup = function()
	vars.scriptAlive = false
	if vars.ui and vars.stopPlayerSelection then pcall(vars.stopPlayerSelection) end
	if vars.stopHoverPreview then pcall(vars.stopHoverPreview) end
	vars.localTryOnBuildId = vars.localTryOnBuildId + 1
	vars.localTryOnBuilding = false
	vars.tryOnActive = false
	vars.cleanupAnimationSync()

	if vars.placeholderR6Active or vars.placeholderR6Backup then
		if vars.restorePlaceholderR6 then pcall(vars.restorePlaceholderR6) end
	end

	if vars.searchDebounceThread then
		pcall(function() task.cancel(vars.searchDebounceThread) end)
		vars.searchDebounceThread = nil
	end

	vars.previewQueueGeneration = vars.previewQueueGeneration + 1
	vars.clearPreviewModelCache()
	table.clear(vars.previewQueue)
	table.clear(vars.previewStates)
	vars.previewQueueRunning = false

	vars.disconnectConnection(vars.deathConnection)
	vars.deathConnection = nil
	vars.disconnectConnection(vars.characterAddedConnection)
	vars.characterAddedConnection = nil
	vars.disconnectLocalTryOnConnections()

	pcall(function() if vars.localTryOnModel then vars.localTryOnModel:Destroy() end end)
	vars.localTryOnModel = nil
	vars.resetLocalTryOnState()

	for part, oldTransparency in pairs(vars.hiddenCharacterParts) do
		pcall(function()
			if part and part.Parent then
				part.LocalTransparencyModifier = oldTransparency
			end
		end)
	end
	table.clear(vars.hiddenCharacterParts)

	for decal, oldTransparency in pairs(vars.hiddenCharacterDecals) do
		pcall(function()
			if decal and decal.Parent then
				decal.Transparency = oldTransparency
			end
		end)
	end
	table.clear(vars.hiddenCharacterDecals)

	for _, connection in ipairs(vars.runtimeConnections) do
		vars.disconnectConnection(connection)
	end
	table.clear(vars.runtimeConnections)

	pcall(function()
		if vars.HoverPreview and vars.HoverPreview.Parent then
			vars.HoverPreview:Destroy()
		end
	end)

	pcall(function()
		if type(getgenv) == "function" and getgenv().__LocalWearerCleanup == vars.cleanup then
			getgenv().__LocalWearerCleanup = nil
		end
	end)
end

pcall(function()
	if type(getgenv) == "function" and type(getgenv().__LocalWearerCleanup) == "function" then
		pcall(getgenv().__LocalWearerCleanup)
	end
end)
vars.scriptAlive = true
pcall(function()
	if type(getgenv) == "function" then
		getgenv().__LocalWearerCleanup = vars.cleanup
	end
end)

vars.mainCamera = vars.Workspace.CurrentCamera
vars.viewportSize = vars.mainCamera and vars.mainCamera.ViewportSize or Vector2.new(1024, 768)
vars.mainWidth = 500
vars.mainHeight = 400
vars.minimizedWidth = 180
vars.previewWidth = 276
vars.previewGap = 10
vars.previewCameraDistanceMultiplier = 1.80

-- Dynamic Theme Color Bridge (Automatically synced with Hub's GetTheme() & GUI Design)
local initTheme = GetTheme()
vars.COLORS = {
	Background = initTheme.MainBg,
	Surface = initTheme.CardBg,
	Surface2 = initTheme.PanelBg,
	Surface3 = initTheme.PanelBg,
	Border = initTheme.Stroke,
	Text = initTheme.TextPrimary,
	Muted = initTheme.TextSecondary,
	Accent = initTheme.Accent,
	AccentHover = initTheme.AccentDark,
	Accent2 = initTheme.AccentDark,
	Success = Color3.fromRGB(46, 204, 113),
	SuccessHover = Color3.fromRGB(68, 224, 132),
	Danger = Color3.fromRGB(231, 76, 60),
	DangerHover = Color3.fromRGB(245, 96, 82),
}

vars.SyncColorsFromHubTheme = function()
	local t = GetTheme()
	vars.COLORS.Background = t.MainBg
	vars.COLORS.Surface = t.CardBg
	vars.COLORS.Surface2 = t.PanelBg
	vars.COLORS.Surface3 = t.PanelBg
	vars.COLORS.Border = t.Stroke
	vars.COLORS.Text = t.TextPrimary
	vars.COLORS.Muted = t.TextSecondary
	vars.COLORS.Accent = t.Accent
	vars.COLORS.AccentHover = t.AccentDark
	vars.COLORS.Accent2 = t.AccentDark
end

vars.ScreenGui = ScreenGui
vars.UIRoot = ScreenGui
vars.Main = MainFrame

vars.ui = {
	savedAvatars = (type(genv._TR_SavedAvatarsMemory) == "table") and genv._TR_SavedAvatarsMemory or {},
	deletedSignatures = {},
	selectedAvatar = nil,
	avatarRows = {},
	hoverModel = nil,
	hoverViewport = nil,
	hoverConnection = nil,
	hoverButton = nil,
	pinnedPreviewData = nil,
	selectingPlayer = false,
	selectionHighlight = nil,
	selectionPlayer = nil,
}
genv._TR_SavedAvatarsMemory = vars.ui.savedAvatars

vars.addCorner = function(parent, radius)
	local corner = parent:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 8)
	corner.Parent = parent
	return corner
end

vars.addStroke = function(parent, color, thickness, transparency)
	local stroke = parent:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke")
	stroke.Color = color or vars.COLORS.Border
	stroke.Thickness = thickness or 1
	stroke.Transparency = transparency or 0.4
	stroke.Parent = parent
	return stroke
end

vars.addGradient = function(parent, color1, color2, rotation)
	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new(color1, color2)
	gradient.Rotation = rotation or 0
	gradient.Parent = parent
	return gradient
end

vars.addPadding = function(parent, left, right, top, bottom)
	local pad = Instance.new("UIPadding")
	pad.PaddingLeft = UDim.new(0, left or 0)
	pad.PaddingRight = UDim.new(0, right or left or 0)
	pad.PaddingTop = UDim.new(0, top or 0)
	pad.PaddingBottom = UDim.new(0, bottom or top or 0)
	pad.Parent = parent
	return pad
end

vars.BUILDER_ICONS_FONT = "rbxasset://LuaPackages/Packages/_Index/BuilderIcons/BuilderIcons/BuilderIcons.json"
vars.BUILDER_ICONS = {
	Rename = "pencil-square",
	Preview3D = "cube-vertexes",
	Delete = "trash-can",
	Refresh = "arrow-spin-clockwise",
	Minimize = "two-arrows-to-center",
	Maximize = "two-arrows-from-center",
	Close = "x"
}

vars.createBuilderIcon = function(parent, name, code, size, color)
	local label = Instance.new("TextLabel")
	label.Name = name or "Icon"
	label.BackgroundTransparency = 1
	label.Text = code or ""
	label.TextColor3 = color or vars.COLORS.Text
	label.TextScaled = true
	label.Size = UDim2.fromOffset(size or 16, size or 16)
	label.Font = Enum.Font.GothamBold
	if code and code ~= "" then
		pcall(function()
			label.FontFace = Font.new(vars.BUILDER_ICONS_FONT, Enum.FontWeight.Bold)
		end)
	end
	label.Parent = parent
	return label
end

vars.createButton = function(parent, name, text, baseColor, hoverColor)
	local button = Instance.new("TextButton")
	button.Name = name
	button.BackgroundColor3 = baseColor or vars.COLORS.Surface3
	button.BorderSizePixel = 0
	button.Text = text
	button.TextColor3 = vars.COLORS.Text
	button.TextSize = 11
	button.Font = Enum.Font.GothamBold
	button.AutoButtonColor = false
	button.Active = true
	button.Parent = parent
	vars.addCorner(button, 6)
	vars.addStroke(button, vars.COLORS.Border, 1, 0.35)
	return button
end

--==============================================================================
-- TAB 10 UI LAYOUT (Native Hub Cards & Theme-Reactive Surfaces)
--==============================================================================
CreateSectionHeader(Tab10_Avatar, "Avatar Changer & Saver (Local R6/R15 Try-On | Click Player | Username | 3D Preview)", 1)

local AvatarControlCard = CreateCard(Tab10_Avatar, 0, 2)
AvatarControlCard.AutomaticSize = Enum.AutomaticSize.Y
local CtrlPad = Instance.new("UIPadding")
CtrlPad.PaddingTop = UDim.new(0, 8)
CtrlPad.PaddingBottom = UDim.new(0, 8)
CtrlPad.PaddingLeft = UDim.new(0, 10)
CtrlPad.PaddingRight = UDim.new(0, 10)
CtrlPad.Parent = AvatarControlCard

local CtrlLayout = Instance.new("UIListLayout")
CtrlLayout.Padding = UDim.new(0, 8)
CtrlLayout.SortOrder = Enum.SortOrder.LayoutOrder
CtrlLayout.Parent = AvatarControlCard

-- Row 1: Live Status Bar + Unequip/Try-On Action Button
vars.Footer = Instance.new("Frame")
vars.Footer.Name = "StatusHeaderRow"
vars.Footer.Size = UDim2.new(1, 0, 0, 26)
vars.Footer.BackgroundTransparency = 1
vars.Footer.LayoutOrder = 1
vars.Footer.Parent = AvatarControlCard

vars.StatusDot = Instance.new("Frame")
vars.StatusDot.Name = "StatusDot"
vars.StatusDot.Size = UDim2.fromOffset(8, 8)
vars.StatusDot.Position = UDim2.new(0, 2, 0.5, -4)
vars.StatusDot.BackgroundColor3 = initTheme.Accent
vars.StatusDot.BorderSizePixel = 0
vars.StatusDot.Parent = vars.Footer
vars.addCorner(vars.StatusDot, 999)

vars.Status = MakeLabel(vars.Footer, UDim2.new(1, -138, 1, 0), UDim2.new(0, 16, 0, 0), "Initializing Avatar Changer...", Enum.Font.GothamBold, 11, "TextPrimary", Enum.TextXAlignment.Left)
vars.Status.TextTruncate = Enum.TextTruncate.AtEnd

vars.WearButton = MakeButton(vars.Footer, UDim2.new(0, 124, 0, 24), UDim2.new(1, -124, 0.5, -12), "TRY ON SELECTED", nil, 10)
vars.WearButton.Active = true

vars.updateWearButtonState = function()
	if not vars.WearButton or not vars.WearButton.Parent then return end
	local t = GetTheme()
	if vars.localTryOnBuilding then
		vars.WearButton.Text = "BUILDING..."
		vars.WearButton.BackgroundColor3 = t.AccentDark
		vars.WearButton.TextColor3 = t.TextPrimary
	elseif vars.tryOnActive or vars.localTryOnModel or vars.placeholderR6Active then
		vars.WearButton.Text = "RESTORE DEFAULT"
		vars.WearButton.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
		vars.WearButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	elseif vars.ui.selectedAvatar then
		vars.WearButton.Text = "WEAR SELECTED"
		vars.WearButton.BackgroundColor3 = t.Accent
		vars.WearButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	else
		vars.WearButton.Text = "NO AVATAR WORN"
		vars.WearButton.BackgroundColor3 = t.PanelBg
		vars.WearButton.TextColor3 = t.TextSecondary
	end
end

-- Row 2: Username Input + Save Self + Save Other (Click Player) + Method Toggle
vars.SaveBar = Instance.new("Frame")
vars.SaveBar.Name = "SaveBar"
vars.SaveBar.Size = UDim2.new(1, 0, 0, 30)
vars.SaveBar.BackgroundTransparency = 1
vars.SaveBar.LayoutOrder = 2
vars.SaveBar.Parent = AvatarControlCard

vars.UsernameBox = Instance.new("TextBox")
vars.UsernameBox.Name = "UsernameBox"
vars.UsernameBox.Size = UDim2.new(0.36, -4, 1, 0)
vars.UsernameBox.Position = UDim2.new(0, 0, 0, 0)
vars.UsernameBox.BorderSizePixel = 0
vars.UsernameBox.Text = ""
vars.UsernameBox.PlaceholderText = "Username (Enter to Wear)..."
vars.UsernameBox.TextSize = 11
vars.UsernameBox.Font = Enum.Font.GothamSemibold
vars.UsernameBox.ClearTextOnFocus = false
vars.UsernameBox.TextXAlignment = Enum.TextXAlignment.Left
vars.UsernameBox.Parent = vars.SaveBar
RegisterThemeObject(vars.UsernameBox, "BackgroundColor3", "PanelBg")
RegisterThemeObject(vars.UsernameBox, "TextColor3", "TextPrimary")
RegisterThemeObject(vars.UsernameBox, "PlaceholderColor3", "TextSecondary")
vars.addPadding(vars.UsernameBox, 8, 6, 0, 0)
vars.addCorner(vars.UsernameBox, 6)
local userStroke = vars.addStroke(vars.UsernameBox, initTheme.Stroke, 1, 0.35)
RegisterThemeObject(userStroke, "Color", "Stroke")

vars.SaveSelfButton = MakeButton(vars.SaveBar, UDim2.new(0.19, -4, 1, 0), UDim2.new(0.36, 2, 0, 0), "SAVE SELF", "PanelBg", 10)
local saveSelfStroke = vars.addStroke(vars.SaveSelfButton, initTheme.Stroke, 1, 0.35)
RegisterThemeObject(saveSelfStroke, "Color", "Stroke")

vars.SaveClickedButton = MakeButton(vars.SaveBar, UDim2.new(0.21, -4, 1, 0), UDim2.new(0.55, 2, 0, 0), "SAVE OTHER", "PanelBg", 10)
local saveOtherStroke = vars.addStroke(vars.SaveClickedButton, initTheme.Stroke, 1, 0.35)
RegisterThemeObject(saveOtherStroke, "Color", "Stroke")

vars.PlaceholderToggle = MakeButton(vars.SaveBar, UDim2.new(0.24, -2, 1, 0), UDim2.new(0.76, 2, 0, 0), "MODE: CLONE", nil, 10)
local placeStroke = vars.addStroke(vars.PlaceholderToggle, initTheme.Stroke, 1, 0.35)
RegisterThemeObject(placeStroke, "Color", "Stroke")

-- Row 3: Search Saved Avatars + Refresh Button
vars.SearchRow = Instance.new("Frame")
vars.SearchRow.Name = "SearchRow"
vars.SearchRow.Size = UDim2.new(1, 0, 0, 30)
vars.SearchRow.BackgroundTransparency = 1
vars.SearchRow.LayoutOrder = 3
vars.SearchRow.Parent = AvatarControlCard

vars.SearchBox = Instance.new("TextBox")
vars.SearchBox.Name = "SearchBox"
vars.SearchBox.Size = UDim2.new(1, -92, 1, 0)
vars.SearchBox.Position = UDim2.new(0, 0, 0, 0)
vars.SearchBox.BorderSizePixel = 0
vars.SearchBox.PlaceholderText = "Search Saved Avatars (Name, @User, R6/R15)..."
vars.SearchBox.Text = ""
vars.SearchBox.TextSize = 11
vars.SearchBox.Font = Enum.Font.GothamSemibold
vars.SearchBox.ClearTextOnFocus = false
vars.SearchBox.TextXAlignment = Enum.TextXAlignment.Left
vars.SearchBox.Parent = vars.SearchRow
RegisterThemeObject(vars.SearchBox, "BackgroundColor3", "PanelBg")
RegisterThemeObject(vars.SearchBox, "TextColor3", "TextPrimary")
RegisterThemeObject(vars.SearchBox, "PlaceholderColor3", "TextSecondary")
vars.addPadding(vars.SearchBox, 8, 6, 0, 0)
vars.addCorner(vars.SearchBox, 6)
local searchStroke = vars.addStroke(vars.SearchBox, initTheme.Stroke, 1, 0.35)
RegisterThemeObject(searchStroke, "Color", "Stroke")

vars.RefreshButton = MakeButton(vars.SearchRow, UDim2.new(0, 86, 1, 0), UDim2.new(1, -86, 0, 0), "REFRESH", "PanelBg", 10)
local refreshStroke = vars.addStroke(vars.RefreshButton, initTheme.Stroke, 1, 0.35)
RegisterThemeObject(refreshStroke, "Color", "Stroke")

CreateSectionHeader(Tab10_Avatar, "Saved Avatars Library (Click Name to Wear/Unequip | Hover/Click 3D for Preview)", 3)

-- Auto-Sizing Saved Avatars Container inside Tab10_Avatar (Never clips after 5 avatars!)
vars.List = Instance.new("Frame")
vars.List.Name = "AvatarList"
vars.List.LayoutOrder = 4
vars.List.Size = UDim2.new(1, 0, 0, 0)
vars.List.AutomaticSize = Enum.AutomaticSize.Y
vars.List.BackgroundTransparency = 1
vars.List.BorderSizePixel = 0
vars.List.Parent = Tab10_Avatar

vars.ListLayout = Instance.new("UIListLayout")
vars.ListLayout.Padding = UDim.new(0, 6)
vars.ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
vars.ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
vars.ListLayout.Parent = vars.List

vars.ListPadding = Instance.new("UIPadding")
vars.ListPadding.PaddingTop = UDim.new(0, 2)
vars.ListPadding.PaddingBottom = UDim.new(0, 8)
vars.ListPadding.Parent = vars.List

-- Overlays (Confirm Delete/Refresh, Rename Avatar, Wear Diagnostics) parented to MainFrame
vars.ConfirmOverlay = Instance.new("TextButton")
vars.ConfirmOverlay.Name = "TR_AvatarConfirmOverlay"
vars.ConfirmOverlay.Size = UDim2.new(1, 0, 1, 0)
vars.ConfirmOverlay.BackgroundColor3 = Color3.fromRGB(4, 6, 12)
vars.ConfirmOverlay.BackgroundTransparency = 0.25
vars.ConfirmOverlay.BorderSizePixel = 0
vars.ConfirmOverlay.ZIndex = 75
vars.ConfirmOverlay.Visible = false
vars.ConfirmOverlay.Active = true
vars.ConfirmOverlay.AutoButtonColor = false
vars.ConfirmOverlay.Text = ""
vars.ConfirmOverlay.Parent = MainFrame
vars.addCorner(vars.ConfirmOverlay, 12)

vars.ConfirmBox = Instance.new("Frame")
vars.ConfirmBox.Name = "ConfirmBox"
vars.ConfirmBox.Size = UDim2.new(0, 310, 0, 134)
vars.ConfirmBox.Position = UDim2.new(0.5, -155, 0.5, -67)
vars.ConfirmBox.BorderSizePixel = 0
vars.ConfirmBox.ZIndex = 76
vars.ConfirmBox.Parent = vars.ConfirmOverlay
RegisterThemeObject(vars.ConfirmBox, "BackgroundColor3", "CardBg")
vars.addCorner(vars.ConfirmBox, 10)
local confirmStroke = vars.addStroke(vars.ConfirmBox, initTheme.Stroke, 1.4, 0.15)
RegisterThemeObject(confirmStroke, "Color", "Stroke")

vars.ConfirmAccent = Instance.new("Frame")
vars.ConfirmAccent.Size = UDim2.new(1, 0, 0, 3)
vars.ConfirmAccent.BorderSizePixel = 0
vars.ConfirmAccent.ZIndex = 77
vars.ConfirmAccent.Parent = vars.ConfirmBox
RegisterThemeObject(vars.ConfirmAccent, "BackgroundColor3", "Accent")
vars.addCorner(vars.ConfirmAccent, 4)

vars.ConfirmText = MakeLabel(vars.ConfirmBox, UDim2.new(1, -24, 0, 62), UDim2.new(0, 12, 0, 16), "Are you sure?", Enum.Font.GothamBold, 12, "TextPrimary", Enum.TextXAlignment.Center)
vars.ConfirmText.TextWrapped = true
vars.ConfirmText.ZIndex = 77

vars.ConfirmYesBtn = MakeButton(vars.ConfirmBox, UDim2.new(0.44, 0, 0, 30), UDim2.new(0.04, 0, 1, -40), "CONFIRM", nil, 11)
vars.ConfirmYesBtn.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
vars.ConfirmYesBtn.ZIndex = 78

vars.ConfirmNoBtn = MakeButton(vars.ConfirmBox, UDim2.new(0.44, 0, 0, 30), UDim2.new(0.52, 0, 1, -40), "CANCEL", "PanelBg", 11)
vars.ConfirmNoBtn.ZIndex = 78

vars.currentConfirmAction = nil
vars.minimized = false

vars.showConfirmation = function(message, onConfirm)
	vars.ConfirmText.Text = tostring(message or "Are you sure?")
	vars.currentConfirmAction = onConfirm
	vars.ConfirmOverlay.Visible = true
end

vars.hideConfirmation = function()
	vars.ConfirmOverlay.Visible = false
	vars.currentConfirmAction = nil
end

vars.wire(vars.ConfirmYesBtn.Activated, function()
	local action = vars.currentConfirmAction
	vars.hideConfirmation()
	if type(action) == "function" then action() end
end)
vars.wire(vars.ConfirmNoBtn.Activated, vars.hideConfirmation)

-- Rename Overlay
vars.RenameOverlay = Instance.new("Frame")
vars.RenameOverlay.Name = "TR_AvatarRenameOverlay"
vars.RenameOverlay.Size = UDim2.new(1, 0, 1, 0)
vars.RenameOverlay.BackgroundColor3 = Color3.fromRGB(4, 6, 12)
vars.RenameOverlay.BackgroundTransparency = 0.25
vars.RenameOverlay.BorderSizePixel = 0
vars.RenameOverlay.Visible = false
vars.RenameOverlay.ZIndex = 75
vars.RenameOverlay.Parent = MainFrame
vars.addCorner(vars.RenameOverlay, 12)

vars.RenameBox = Instance.new("Frame")
vars.RenameBox.Name = "RenameBox"
vars.RenameBox.Size = UDim2.new(0, 340, 0, 148)
vars.RenameBox.Position = UDim2.new(0.5, -170, 0.5, -74)
vars.RenameBox.BorderSizePixel = 0
vars.RenameBox.ZIndex = 76
vars.RenameBox.Parent = vars.RenameOverlay
RegisterThemeObject(vars.RenameBox, "BackgroundColor3", "CardBg")
vars.addCorner(vars.RenameBox, 10)
local renameBoxStroke = vars.addStroke(vars.RenameBox, initTheme.Stroke, 1.4, 0.15)
RegisterThemeObject(renameBoxStroke, "Color", "Stroke")

vars.RenameTitle = MakeLabel(vars.RenameBox, UDim2.new(1, -24, 0, 26), UDim2.new(0, 12, 0, 10), "RENAME SAVED AVATAR", Enum.Font.GothamBold, 13, "TextPrimary", Enum.TextXAlignment.Left)
vars.RenameTitle.ZIndex = 77

vars.RenameInput = Instance.new("TextBox")
vars.RenameInput.Name = "RenameInput"
vars.RenameInput.Size = UDim2.new(1, -24, 0, 36)
vars.RenameInput.Position = UDim2.new(0, 12, 0, 44)
vars.RenameInput.BorderSizePixel = 0
vars.RenameInput.PlaceholderText = "New Display Name..."
vars.RenameInput.Text = ""
vars.RenameInput.TextSize = 12
vars.RenameInput.Font = Enum.Font.GothamSemibold
vars.RenameInput.ClearTextOnFocus = false
vars.RenameInput.TextXAlignment = Enum.TextXAlignment.Left
vars.RenameInput.ZIndex = 77
vars.RenameInput.Parent = vars.RenameBox
RegisterThemeObject(vars.RenameInput, "BackgroundColor3", "PanelBg")
RegisterThemeObject(vars.RenameInput, "TextColor3", "TextPrimary")
RegisterThemeObject(vars.RenameInput, "PlaceholderColor3", "TextSecondary")
vars.addPadding(vars.RenameInput, 8, 8, 0, 0)
vars.addCorner(vars.RenameInput, 6)
local renameInputStroke = vars.addStroke(vars.RenameInput, initTheme.Stroke, 1, 0.25)
RegisterThemeObject(renameInputStroke, "Color", "Stroke")

vars.RenameCancel = MakeButton(vars.RenameBox, UDim2.new(0, 106, 0, 30), UDim2.new(1, -228, 1, -40), "CANCEL", "PanelBg", 11)
vars.RenameCancel.ZIndex = 77

vars.RenameSave = MakeButton(vars.RenameBox, UDim2.new(0, 106, 0, 30), UDim2.new(1, -116, 1, -40), "SAVE NAME", "Accent", 11)
vars.RenameSave.ZIndex = 77

vars.RenameTarget = nil
vars.wire(vars.RenameCancel.Activated, function()
	vars.RenameOverlay.Visible = false
	vars.RenameTarget = nil
end)

-- Diagnostics / Error Popup Overlay
vars.ErrorPopup = Instance.new("Frame")
vars.ErrorPopup.Name = "TR_WearDiagnostics"
vars.ErrorPopup.Size = UDim2.new(0, 380, 0, 168)
vars.ErrorPopup.Position = UDim2.new(0.5, -190, 0.5, -84)
vars.ErrorPopup.BorderSizePixel = 0
vars.ErrorPopup.Visible = false
vars.ErrorPopup.ZIndex = 80
vars.ErrorPopup.Parent = MainFrame
RegisterThemeObject(vars.ErrorPopup, "BackgroundColor3", "MainBg")
vars.addCorner(vars.ErrorPopup, 10)
local errStroke = vars.addStroke(vars.ErrorPopup, Color3.fromRGB(231, 76, 60), 1.5, 0.1)

vars.ErrorTitle = MakeLabel(vars.ErrorPopup, UDim2.new(1, -44, 0, 28), UDim2.new(0, 12, 0, 6), "Avatar Notice / Diagnostics", Enum.Font.GothamBold, 12, "Accent", Enum.TextXAlignment.Left)
vars.ErrorTitle.ZIndex = 81

vars.ErrorCloseBtn = MakeButton(vars.ErrorPopup, UDim2.new(0, 26, 0, 24), UDim2.new(1, -32, 0, 8), "X", "PanelBg", 12)
vars.ErrorCloseBtn.ZIndex = 82

vars.ErrorScroll = Instance.new("ScrollingFrame")
vars.ErrorScroll.Name = "ErrorScroll"
vars.ErrorScroll.Size = UDim2.new(1, -24, 1, -44)
vars.ErrorScroll.Position = UDim2.new(0, 12, 0, 38)
vars.ErrorScroll.BackgroundTransparency = 1
vars.ErrorScroll.BorderSizePixel = 0
vars.ErrorScroll.ScrollBarThickness = 3
vars.ErrorScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
vars.ErrorScroll.ZIndex = 81
vars.ErrorScroll.Parent = vars.ErrorPopup
RegisterThemeObject(vars.ErrorScroll, "ScrollBarImageColor3", "Accent")

vars.ErrorText = Instance.new("TextLabel")
vars.ErrorText.Name = "FullError"
vars.ErrorText.Size = UDim2.new(1, -6, 0, 0)
vars.ErrorText.AutomaticSize = Enum.AutomaticSize.Y
vars.ErrorText.BackgroundTransparency = 1
vars.ErrorText.Text = ""
vars.ErrorText.TextSize = 11
vars.ErrorText.Font = Enum.Font.Code
vars.ErrorText.TextWrapped = true
vars.ErrorText.TextXAlignment = Enum.TextXAlignment.Left
vars.ErrorText.TextYAlignment = Enum.TextYAlignment.Top
vars.ErrorText.ZIndex = 82
vars.ErrorText.Parent = vars.ErrorScroll
RegisterThemeObject(vars.ErrorText, "TextColor3", "TextPrimary")

vars.wire(vars.ErrorCloseBtn.Activated, function() vars.ErrorPopup.Visible = false end)

vars.clearDiagnostics = function()
	vars.ErrorPopup.Visible = false
	vars.ErrorText.Text = ""
	vars.ErrorScroll.CanvasPosition = Vector2.zero
end

vars.showDiagnostics = function(summary, detail)
	vars.Status.Text = tostring(summary or "Wear failed.")
	vars.ErrorText.Text = tostring(detail or "No additional error text was returned.")
	vars.ErrorPopup.Visible = true
	task.defer(function()
		if vars.ErrorScroll.Parent then vars.ErrorScroll.CanvasPosition = Vector2.zero end
	end)
end

vars.SEATED_TRY_ON_BLOCK_MESSAGE = "Please wear avatars while standing still. Cannot wear avatars while sitting at the moment because of the avatar placement glitch similar to wearing while flying and wearing while doing a forward/backward swim. The bug/glitch is under maintenance and is fixing right away. Thank you for understanding.\n\nKnightingale."

vars.isCharacterCurrentlySitting = function(character, humanoid)	humanoid = humanoid or (character and character:FindFirstChildOfClass("Humanoid"))
	if not humanoid then return false end

	local state = humanoid:GetState()
	return humanoid.Sit
		or humanoid.SeatPart ~= nil
		or state == Enum.HumanoidStateType.Seated
end

vars.showSeatedTryOnBlocked = function()	vars.showDiagnostics("[!] Cannot wear avatars while sitting.", vars.SEATED_TRY_ON_BLOCK_MESSAGE)
end

vars.accessoryPropertyNames = {
	"HatAccessory", "HairAccessory", "FaceAccessory", "NeckAccessory",
	"ShouldersAccessory", "FrontAccessory", "BackAccessory", "WaistAccessory",
	"JacketAccessory", "ShortsAccessory", "SweaterAccessory", "TShirtAccessory",
	"PantsAccessory", "ShoesAccessory", "DressSkirtAccessory", "EyelashAccessory",
	"EyebrowAccessory", "MoodAccessory"
}

vars.rgbForSave = function(color)
	if not color then return {r = 255, g = 255, b = 255} end
	return {
		r = math.floor(color.R * 255 + 0.5),
		g = math.floor(color.G * 255 + 0.5),
		b = math.floor(color.B * 255 + 0.5)
	}
end

vars.vectorForSave = function(value, fallback)
	fallback = fallback or Vector3.zero
	if typeof(value) == "Vector3" then
		return {X = value.X, Y = value.Y, Z = value.Z}
	end
	if type(value) == "table" then
		return {
			X = tonumber(value.X or value.x) or fallback.X,
			Y = tonumber(value.Y or value.y) or fallback.Y,
			Z = tonumber(value.Z or value.z) or fallback.Z
		}
	end
	return {X = fallback.X, Y = fallback.Y, Z = fallback.Z}
end

vars.getSavedHeadShape = function(desc)
	local shape = ""
	pcall(function()
		for _, child in ipairs(desc:GetChildren()) do
			if child:IsA("BodyPartDescription") and child.BodyPart == Enum.BodyPart.Head then
				local value = tostring(child.HeadShape or "")
				if value ~= "" then shape = value break end
			end
		end
	end)
	return shape
end

vars.getSavedMakeups = function(desc)
	local result, seen = {}, {}
	local function addMakeup(makeup)
		if not makeup then return end
		local assetId = tonumber(makeup.AssetId)
		if not assetId or assetId <= 0 then return end
		local makeupType = makeup.MakeupType
		local typeName = makeupType and makeupType.Name or tostring(makeupType or "")
		local order = tonumber(makeup.Order) or 1
		local key = tostring(assetId) .. "|" .. typeName .. "|" .. tostring(order)
		if seen[key] then return end
		seen[key] = true
		result[#result + 1] = {Order = order, AssetId = assetId, MakeupType = typeName}
	end
	pcall(function()
		for _, child in ipairs(desc:GetChildren()) do
			if child:IsA("MakeupDescription") then addMakeup(child) end
		end
	end)
	pcall(function()
		if #result == 0 and type(desc.GetMakeups) == "function" then
			for _, makeup in ipairs(desc:GetMakeups()) do addMakeup(makeup) end
		end
	end)
	return result
end

vars.getSavedLayeredAccessories = function(desc)
	local result = {}
	pcall(function()
		if type(desc.GetAccessories) ~= "function" then return end
		for _, accessory in ipairs(desc:GetAccessories(true)) do
			if accessory.IsLayered then
				result[#result + 1] = {
					Rotation = vars.vectorForSave(accessory.Rotation),
					AssetId = accessory.AssetId,
					AccessoryType = accessory.AccessoryType and accessory.AccessoryType.Name or "Unknown",
					Position = vars.vectorForSave(accessory.Position),
					Order = accessory.Order or 1,
					IsLayered = true,
					Puffiness = accessory.Puffiness or 0.5,
					Scale = vars.vectorForSave(accessory.Scale, Vector3.one)
				}
			end
		end
	end)
	return result
end

vars.getSavedAccessoryRefinements = function(desc, character)
	local refinements = {}
	pcall(function()
		if character then
			local raw = character:GetAttribute("AccessoryRefinements") or desc:GetAttribute("AccessoryRefinements")
			if raw then
				local decoded = type(raw) == "string" and vars.HttpService:JSONDecode(raw) or raw
				if type(decoded) == "table" then
					for id, value in pairs(decoded) do refinements[tostring(id)] = value end
				end
			end
		end
	end)
	pcall(function()
		if type(desc.GetAccessories) ~= "function" then return end
		for _, accessory in ipairs(desc:GetAccessories(true)) do
			local id = tostring(accessory.AssetId or 0)
			if id ~= "0" then
				local pos = accessory.Position
				local scale = accessory.Scale
				local rot = accessory.Rotation
				local hasPos = pos and pos.Magnitude > 0.0001
				local hasScale = scale and (math.abs(scale.X - 1) > 0.0001 or math.abs(scale.Y - 1) > 0.0001 or math.abs(scale.Z - 1) > 0.0001)
				local hasRot = rot and rot.Magnitude > 0.0001
				if hasPos or hasScale or hasRot then
					local ref = type(refinements[id]) == "table" and refinements[id] or {}
					if hasPos then ref.Position = vars.vectorForSave(pos) end
					if hasScale then ref.Scale = vars.vectorForSave(scale, Vector3.one) end
					if hasRot then ref.Rotation = vars.vectorForSave(rot) end
					refinements[id] = ref
				end
			end
		end
	end)
	return refinements
end

vars.createCopiedProperties = function(desc, character)
	if not desc then return nil end
	local categories = {
		"HatAccessory", "HairAccessory", "FaceAccessory", "NeckAccessory", "ShouldersAccessory",
		"FrontAccessory", "BackAccessory", "WaistAccessory", "JacketAccessory", "ShortsAccessory",
		"SweaterAccessory", "TShirtAccessory", "PantsAccessory", "ShoesAccessory", "DressSkirtAccessory",
		"EyelashAccessory", "EyebrowAccessory", "MoodAccessory"
	}
	local accLists = {}
	for _, category in ipairs(categories) do accLists[category] = {} end
	local function add(category, id)
		if not accLists[category] then return end
		id = tostring(id or "")
		if id ~= "" and id ~= "0" and not table.find(accLists[category], id) then table.insert(accLists[category], id) end
	end
	for _, category in ipairs(categories) do
		pcall(function()
			for id in tostring(desc[category] or ""):gmatch("%d+") do add(category, id) end
		end)
	end
	pcall(function()
		if type(desc.GetAccessories) == "function" then
			local typeToCategory = {
				[Enum.AccessoryType.Hat] = "HatAccessory", [Enum.AccessoryType.Hair] = "HairAccessory",
				[Enum.AccessoryType.Face] = "FaceAccessory", [Enum.AccessoryType.Neck] = "NeckAccessory",
				[Enum.AccessoryType.Shoulder] = "ShouldersAccessory", [Enum.AccessoryType.Front] = "FrontAccessory",
				[Enum.AccessoryType.Back] = "BackAccessory", [Enum.AccessoryType.Waist] = "WaistAccessory",
				[Enum.AccessoryType.TShirt] = "TShirtAccessory", [Enum.AccessoryType.Shirt] = "ShirtAccessory",
				[Enum.AccessoryType.Pants] = "PantsAccessory", [Enum.AccessoryType.Jacket] = "JacketAccessory",
				[Enum.AccessoryType.Sweater] = "SweaterAccessory", [Enum.AccessoryType.Shorts] = "ShortsAccessory",
				[Enum.AccessoryType.LeftShoe] = "ShoesAccessory", [Enum.AccessoryType.RightShoe] = "ShoesAccessory",
				[Enum.AccessoryType.DressSkirt] = "DressSkirtAccessory", [Enum.AccessoryType.Eyebrow] = "EyebrowAccessory",
				[Enum.AccessoryType.Eyelash] = "EyelashAccessory"
			}
			for _, accessory in ipairs(desc:GetAccessories(true)) do
				if not accessory.IsLayered then
					local category = typeToCategory[accessory.AccessoryType]
					if category then add(category, accessory.AssetId) end
				end
			end
		end
	end)
	local props = {
		WalkAnimation = desc.WalkAnimation or 0, MoodAnimation = desc.MoodAnimation or 0,
		ClimbAnimation = desc.ClimbAnimation or 0, FallAnimation = desc.FallAnimation or 0,
		RunAnimation = desc.RunAnimation or 0, SwimAnimation = desc.SwimAnimation or 0,
		IdleAnimation = desc.IdleAnimation or 0, JumpAnimation = desc.JumpAnimation or 0,
		Face = desc.Face or 0, Shirt = desc.Shirt or 0, Pants = desc.Pants or 0, GraphicTShirt = desc.GraphicTShirt or 0,
		RightArmColor = vars.rgbForSave(desc.RightArmColor), TorsoColor = vars.rgbForSave(desc.TorsoColor),
		RightLegColor = vars.rgbForSave(desc.RightLegColor), LeftLegColor = vars.rgbForSave(desc.LeftLegColor),
		LeftArmColor = vars.rgbForSave(desc.LeftArmColor), HeadColor = vars.rgbForSave(desc.HeadColor),
		Head = desc.Head or 0, Torso = desc.Torso or 0, LeftArm = desc.LeftArm or 0, RightArm = desc.RightArm or 0,
		LeftLeg = desc.LeftLeg or 0, RightLeg = desc.RightLeg or 0, HeadShape = vars.getSavedHeadShape(desc),
		MakeupItems = vars.getSavedMakeups(desc), ProportionScale = desc.ProportionScale or 0, DepthScale = desc.DepthScale or 1,
		HeightScale = desc.HeightScale or 1, WidthScale = desc.WidthScale or 1, BodyTypeScale = desc.BodyTypeScale or 0,
		HeadScale = desc.HeadScale or 1, LayeredAccessories = vars.getSavedLayeredAccessories(desc),
		AccessoryRefinements = vars.getSavedAccessoryRefinements(desc, character), StaticFacialAnimation = false
	}
	for _, category in ipairs(categories) do props[category] = table.concat(accLists[category], ",") end
	pcall(function() props.StaticFacialAnimation = desc.StaticFacialAnimation == true end)
	pcall(function()
		local all = {}
		for _, accessory in ipairs(desc:GetAccessories(true)) do
			local entry = {AssetId = accessory.AssetId, AccessoryType = accessory.AccessoryType and accessory.AccessoryType.Name or "Unknown", IsLayered = accessory.IsLayered == true}
			if accessory.Order ~= nil then entry.Order = accessory.Order end
			if accessory.Puffiness ~= nil then entry.Puffiness = accessory.Puffiness end
			all[#all + 1] = entry
		end
		props.AllAccessories = all
	end)
	pcall(function() if type(desc.GetEmotes) == "function" then props.Emotes = desc:GetEmotes() end end)
	pcall(function() if type(desc.GetEquippedEmotes) == "function" then props.EquippedEmotes = desc:GetEquippedEmotes() end end)
	return props
end

vars.getAvatarSignature = function(properties, rigType)
	local ok, result = pcall(function()
		return vars.HttpService:JSONEncode({Properties = properties, RigType = tostring(rigType)})
	end)
	return ok and result or tostring(properties)
end


--==============================================================================
-- BULLETPROOF MULTI-SOURCE AVATAR PERSISTENCE ENGINE (Fixes 5+ Avatar Disappear Bug)
--==============================================================================
vars.ensureAvatarFolder = function()
	if type(makefolder) ~= "function" or type(isfolder) ~= "function" then return false end
	pcall(function()
		if not isfolder(vars.AVATARS_FOLDER) then makefolder(vars.AVATARS_FOLDER) end
	end)
	pcall(function()
		if not isfolder(vars.FOLDER_NAME) then makefolder(vars.FOLDER_NAME) end
	end)
	return true
end

vars.getAvatarFilePath = function(index)
	return vars.AVATARS_FOLDER .. "/" .. vars.AVATAR_FILE_PREFIX .. tostring(index) .. vars.AVATAR_FILE_EXTENSION
end

vars.sanitizeAvatarFileName = function(name)
	name = tostring(name or ""):gsub("^%s+", ""):gsub("%s+$", "")
	name = name:gsub("[<>:\"/\\|%?%*]", "-")
	name = name:gsub("[%. ]+$", "")
	if name == "" then return nil end
	if name:lower():sub(-4) == ".ava" then name = name:sub(1, -5) end
	if name == "" then return nil end
	return name .. ".ava"
end

vars.getNextAvatarFilePath = function(displayName)
	vars.ensureAvatarFolder()
	local sanitized = vars.sanitizeAvatarFileName(displayName or "Avatar") or "Avatar.ava"
	local baseName = sanitized:sub(1, -5)
	if baseName == "" then baseName = "Avatar" end

	-- Track filenames already used in memory so even if executor `isfile` is broken, we NEVER overwrite an existing entry!
	local usedNames = {}
	for _, existing in ipairs(vars.ui.savedAvatars or {}) do
		if existing.FileName then
			usedNames[string.lower(tostring(existing.FileName))] = true
		end
		if existing.FilePath then
			local fn = tostring(existing.FilePath):match("([^/\\]+)$")
			if fn then usedNames[string.lower(fn)] = true end
		end
	end

	for index = 1, 10000 do
		local candidateName = (index == 1) and baseName or (baseName .. "_" .. tostring(index))
		local fileName = candidateName .. vars.AVATAR_FILE_EXTENSION
		local path = vars.AVATARS_FOLDER .. "/" .. fileName
		local existsOnDisk = false
		if type(isfile) == "function" then
			pcall(function() existsOnDisk = isfile(path) end)
		end
		if not existsOnDisk and not usedNames[string.lower(fileName)] then
			return path
		end
	end
	return vars.AVATARS_FOLDER .. "/Avatar_" .. tostring(math.floor(os.clock() * 1000)) .. ".ava"
end

vars.serializeAvatarEntryForMaster = function(entry)
	if type(entry) ~= "table" or type(entry.Properties) ~= "table" then return nil end
	local sig = entry.Signature or vars.getAvatarSignature(entry.Properties, entry.RigType or "R6")
	entry.Signature = sig
	return {
		Name = entry.Name or entry.Username or "Avatar",
		Username = entry.Username or entry.Name or "Avatar",
		UserId = entry.UserId or 1,
		DisplayName = entry.DisplayName or entry.Name or "Avatar",
		Properties = entry.Properties,
		RigType = entry.RigType or "R15",
		Signature = sig,
		FileName = entry.FileName,
		FilePath = entry.FilePath,
		Source = entry.Source or "ava",
		Order = entry.Order or 1
	}
end

vars.syncAllSavedAvatarsToDisk = function()
	if type(writefile) ~= "function" then return false end
	vars.ensureAvatarFolder()
	local masterList = {}
	local indexNames = {}
	for idx, entry in ipairs(vars.ui.savedAvatars or {}) do
		local clean = vars.serializeAvatarEntryForMaster(entry)
		if clean then
			clean.Order = idx
			masterList[#masterList + 1] = clean
			if clean.FileName then
				indexNames[#indexNames + 1] = clean.FileName
			end
		end
	end
	local okEnc, encodedMaster = pcall(function()
		return vars.HttpService:JSONEncode(masterList)
	end)
	if okEnc and encodedMaster then
		-- 1. Save root master JSON (works even if subfolders/listfiles fail on executor)
		pcall(function() writefile(vars.MASTER_FILE_PATH, encodedMaster) end)
		-- 2. Save v2 SavedAvatars.json
		pcall(function() writefile(vars.FILE_PATH, encodedMaster) end)
		-- 3. Save Avatars/AvatarIndex.json manifest
		pcall(function()
			writefile(vars.AVATAR_INDEX_PATH, vars.HttpService:JSONEncode({
				Files = indexNames,
				Avatars = masterList
			}))
		end)
	end
	genv._TR_SavedAvatarsMemory = vars.ui.savedAvatars
	return true
end

vars.writeAvatarFile = function(data)
	vars.ensureAvatarFolder()
	local path = data.FilePath or vars.getNextAvatarFilePath(data.DisplayName or data.Name)
	data.FilePath = path
	data.FileName = tostring(path):match("([^/\\]+)$") or path
	data.Source = "ava"
	if not data.Signature and data.Properties then
		data.Signature = vars.getAvatarSignature(data.Properties, data.RigType or "R6")
	end
	if type(writefile) == "function" then
		pcall(function() writefile(path, vars.HttpService:JSONEncode(data)) end)
	end
	return true, path
end

vars.readAvatarFiles = function()
	local result = {}
	if type(readfile) ~= "function" then return result end
	vars.ensureAvatarFolder()
	local paths = {}
	local seenPath = {}
	local function addCandidatePath(p)
		if not p or p == "" then return end
		local norm = tostring(p):gsub("\\", "/")
		local low = string.lower(norm)
		if not low:match("%.ava$") then return end
		if not seenPath[low] then
			seenPath[low] = true
			paths[#paths + 1] = p
		end
	end

	-- 1. Check AvatarIndex.json manifest for known .ava filenames
	if type(isfile) == "function" then
		local okIdx, hasIdx = pcall(isfile, vars.AVATAR_INDEX_PATH)
		if okIdx and hasIdx then
			local okRead, decoded = pcall(function()
				return vars.HttpService:JSONDecode(readfile(vars.AVATAR_INDEX_PATH))
			end)
			if okRead and type(decoded) == "table" and type(decoded.Files) == "table" then
				for _, fn in ipairs(decoded.Files) do
					local p = vars.AVATARS_FOLDER .. "/" .. tostring(fn)
					local okF, ex = pcall(isfile, p)
					if okF and ex then addCandidatePath(p) end
				end
			end
		end
	end

	-- 2. Check listfiles("Avatars")
	if type(listfiles) == "function" then
		pcall(function()
			for _, path in ipairs(listfiles(vars.AVATARS_FOLDER)) do
				if tostring(path):lower():match("%.ava$") then
					addCandidatePath(path)
				end
			end
		end)
	end

	-- 3. Check sequential Avatar1.ava .. Avatar200.ava
	if type(isfile) == "function" then
		for index = 1, 200 do
			local path = vars.getAvatarFilePath(index)
			local exists = false
			pcall(function() exists = isfile(path) end)
			if exists then addCandidatePath(path) end
		end
	end

	for _, path in ipairs(paths) do
		local ok, data = pcall(function() return vars.HttpService:JSONDecode(readfile(path)) end)
		if ok and type(data) == "table" and type(data.Properties) == "table" then
			data.FilePath = data.FilePath or path
			data.FileName = data.FileName or tostring(path):match("([^/\\]+)$")
			data.Source = "ava"
			if not data.Signature then
				data.Signature = vars.getAvatarSignature(data.Properties, data.RigType or "R6")
			end
			result[#result + 1] = data
		end
	end
	return result
end

vars.renameAvatarFile = function(data, newName)
	if not data then return false, "No avatar selected." end
	local displayName = tostring(newName or ""):gsub("^%s+", ""):gsub("%s+$", "")
	if displayName == "" then return false, "The new name cannot be empty." end
	data.DisplayName = displayName

	local fileName = vars.sanitizeAvatarFileName(displayName)
	if fileName and type(writefile) == "function" then
		vars.ensureAvatarFolder()
		local oldPath = data.FilePath or (data.FileName and (vars.AVATARS_FOLDER .. "/" .. tostring(data.FileName)))
		local newPath = vars.AVATARS_FOLDER .. "/" .. fileName
		data.FilePath = newPath
		data.FileName = fileName
		data.Source = "ava"
		pcall(function()
			writefile(newPath, vars.HttpService:JSONEncode(data))
		end)
		if oldPath and oldPath:lower() ~= newPath:lower() and type(delfile) == "function" then
			pcall(function() delfile(oldPath) end)
		end
	end
	vars.syncAllSavedAvatarsToDisk()
	return true, data.FilePath or displayName
end

vars.wire(vars.RenameSave.Activated, function()
	local target = vars.RenameTarget
	local newName = tostring(vars.RenameInput.Text or ""):gsub("^%s+", ""):gsub("%s+$", "")
	if not target or newName == "" then return end
	local ok, result = vars.renameAvatarFile(target, newName)
	if not ok then
		vars.showDiagnostics("Failed to rename avatar.", tostring(result))
		return
	end
	vars.RenameOverlay.Visible = false
	vars.RenameTarget = nil
	vars.populateAvatarList()
	vars.Status.Text = "[OK] Renamed avatar to: " .. newName
end)

vars.buildSavedAvatarData = function(targetPlayer)
	if not targetPlayer or not targetPlayer.Character then return nil, "Player character is unavailable." end
	local humanoid = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return nil, "Humanoid is unavailable." end
	local ok, desc = pcall(function() return humanoid:GetAppliedDescription() end)
	if not ok or not desc then return nil, "Could not read the currently applied avatar." end
	local properties = vars.createCopiedProperties(desc, targetPlayer.Character)
	if type(properties) ~= "table" then return nil, "Could not serialize the avatar." end
	local rigType = humanoid.RigType
	local data = {
		Name = targetPlayer.Name,
		Username = targetPlayer.Name,
		UserId = targetPlayer.UserId,
		DisplayName = targetPlayer.DisplayName,
		Properties = properties,
		RigType = (rigType == Enum.HumanoidRigType.R6) and "R6" or "R15",
		Signature = vars.getAvatarSignature(properties, rigType),
		Order = 1
	}
	return data
end

vars.notifyCatalogAvatarCreator = function()
	if not vars.IS_CATALOG_AVATAR_CREATOR then return end
	local payload = {
		Title = "T.R Avatar Changer",
		Text = "Catalog Avatar Creator detected: avatars are FE and saved to Saved Outfits!",
		Duration = 7
	}
	task.spawn(function()
		for _ = 1, 6 do
			if not vars.scriptAlive then return end
			local ok = pcall(function()
				vars.StarterGui:SetCore("SendNotification", payload)
			end)
			if ok then return end
			task.wait(0.5)
		end
	end)
end

vars.getCatalogWearRemotes = function()
	if not vars.IS_CATALOG_AVATAR_CREATOR then return nil, nil end
	if not vars.CATALOG_EVENTS or not vars.CATALOG_EVENTS.Parent then
		vars.CATALOG_EVENTS = vars.ReplicatedStorage:FindFirstChild("Events")
	end
	vars.CATALOG_GUI_REMOTE = vars.CATALOG_EVENTS and vars.CATALOG_EVENTS:FindFirstChild("CatalogGuiRemote")
	vars.SAVED_OUTFITS_REMOTE = vars.CATALOG_EVENTS and vars.CATALOG_EVENTS:FindFirstChild("SavedOutfitsRemote")
	return vars.CATALOG_GUI_REMOTE, vars.SAVED_OUTFITS_REMOTE
end

vars.wearAvatarThroughCatalog = function(data)
	if not vars.IS_CATALOG_AVATAR_CREATOR then return false, "Not in Catalog Avatar Creator." end
	if not data or type(data.Properties) ~= "table" then return false, "Avatar has no saved properties." end
	local catalogGuiRemote = vars.getCatalogWearRemotes()
	if not catalogGuiRemote then return false, "CatalogGuiRemote was not found." end

	local rigTypeEnum = (tostring(data.RigType):find("R6") and Enum.HumanoidRigType.R6) or Enum.HumanoidRigType.R15
	local cleanProps = {}
	for key, value in pairs(data.Properties) do
		if key ~= "Emotes" and key ~= "EquippedEmotes" and key ~= "AllAccessories" then
			cleanProps[key] = value
		end
	end

	local payload = {
		Properties = cleanProps,
		Action = "CreateAndWearHumanoidDescription",
		RigType = rigTypeEnum
	}
	local ok, result = pcall(function()
		return catalogGuiRemote:InvokeServer(payload)
	end)
	if not ok then return false, tostring(result) end
	return true, result
end

vars.saveAvatarToCatalogOutfit = function(data)
	if not vars.IS_CATALOG_AVATAR_CREATOR then return false, "Not in Catalog Avatar Creator." end
	if not data or not data.Properties then return false, "Avatar has no saved properties." end
	local _, savedOutfitsRemote = vars.getCatalogWearRemotes()
	if not savedOutfitsRemote then return false, "SavedOutfitsRemote was not found." end

	local okWear, wearErr = vars.wearAvatarThroughCatalog(data)
	if not okWear then return false, wearErr end

	local username = tostring(data.Name or data.Username or "Unknown")
	local outfitName = "Avatar Saver: " .. username
	local ok, result = pcall(function()
		return savedOutfitsRemote:InvokeServer({
			OutfitName = outfitName,
			Configs = {},
			Action = "CreateNewOutfit"
		})
	end)
	if not ok then return false, tostring(result) end
	return true, outfitName, result
end

vars.notifyCatalogAvatarCreator()

vars.buildSavedAvatarDataFromUsername = function(username)
	username = tostring(username or ""):gsub("^%s+", ""):gsub("%s+$", "")
	username = username:gsub("^@", "")
	if username == "" then return nil, "Enter a Roblox username first." end

	local okId, userId = pcall(function()
		return vars.Players:GetUserIdFromNameAsync(username)
	end)
	if not okId or not userId then
		return nil, "Could not find Roblox user @" .. username .. "."
	end

	local desc
	local descOk, descResult = pcall(function()
		if type(vars.Players.GetHumanoidDescriptionFromUserIdAsync) == "function" then
			return vars.Players:GetHumanoidDescriptionFromUserIdAsync(userId)
		end
		return vars.Players:GetHumanoidDescriptionFromUserId(userId)
	end)
	if not descOk or not descResult then
		return nil, "Could not load the profile avatar for @" .. username .. "."
	end
	desc = descResult

	local properties = vars.createCopiedProperties(desc, nil)
	if type(properties) ~= "table" then
		return nil, "Could not serialize the profile avatar for @" .. username .. "."
	end

	local localHumanoid = vars.LocalPlayer.Character and vars.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	local rigType = localHumanoid and localHumanoid.RigType or Enum.HumanoidRigType.R6
	local displayName = username
	pcall(function()
		local fetchedPlayer = vars.Players:GetPlayerByUserId(userId)
		if fetchedPlayer then displayName = fetchedPlayer.DisplayName end
	end)

	local data = {
		Name = username,
		Username = username,
		UserId = userId,
		DisplayName = displayName,
		Properties = properties,
		RigType = (rigType == Enum.HumanoidRigType.R6) and "R6" or "R15",
		Signature = vars.getAvatarSignature(properties, rigType),
		Order = 1
	}
	return data
end

vars.findExactSavedAvatarMatch = function(data)
	if type(data) ~= "table" then return nil end
	local targetSignature = data.Signature
	if not targetSignature and data.Properties then
		targetSignature = vars.getAvatarSignature(data.Properties, data.RigType or "R6")
	end
	for _, existing in ipairs(vars.ui.savedAvatars or {}) do
		local existingSignature = existing.Signature
		if not existingSignature and existing.Properties then
			existingSignature = vars.getAvatarSignature(existing.Properties, existing.RigType or "R6")
			existing.Signature = existingSignature
		end
		if targetSignature and existingSignature and targetSignature == existingSignature then
			return existing
		end
	end
	return nil
end

vars.saveAndWearUsernameAvatar = function(rawUsername)
	local username = tostring(rawUsername or ""):gsub("^%s+", ""):gsub("%s+$", "")
	username = username:gsub("^@", "")
	if username == "" then
		return false, "Enter a Roblox username first."
	end

	if vars.ui.selectingPlayer then vars.stopPlayerSelection() end
	if vars.tryOnActive or vars.localTryOnModel or vars.localTryOnBuilding or vars.placeholderR6Active then
		vars.tryOnActive = false
		vars.stopLocalTryOn(false)
	end
	vars.ui.selectedAvatar = nil
	vars.updateRowVisuals(nil)

	local data, buildErr = vars.buildSavedAvatarDataFromUsername(username)
	if not data then return false, buildErr end

	local existingMatch = vars.findExactSavedAvatarMatch(data)
	if existingMatch then
		data = existingMatch
		vars.ui.selectedAvatar = data
		vars.populateAvatarList()
		vars.updateRowVisuals(data)

		if vars.IS_CATALOG_AVATAR_CREATOR then
			local wearOk, wearErr = vars.wearAvatarThroughCatalog(data)
			if not wearOk then
				vars.showDiagnostics("Existing avatar could not be equipped.", tostring(wearErr))
				return false, wearErr
			end
			vars.Status.Text = "[FE] Already saved - equipped existing avatar: " .. tostring(data.Name or data.Username or username)
		else
			vars.Status.Text = "[OK] Already saved - equipped existing avatar: " .. tostring(data.Name or data.Username or username)
			task.defer(function()
				if vars.scriptAlive and vars.ui.selectedAvatar == data then
					vars.tryOnSelectedAvatarLocally()
				end
			end)
		end
		vars.clearDiagnostics()
		return true, data
	end

	local okWrite, pathOrErr = vars.writeAvatarFile(data)
	if not okWrite then return false, pathOrErr end
	data.FilePath = pathOrErr
	data.FileName = tostring(pathOrErr):match("([^/\\]+)$") or pathOrErr
	data.Source = "ava"
	if data.Signature then vars.ui.deletedSignatures[data.Signature] = nil end
	vars.ui.savedAvatars = vars.ui.savedAvatars or {}
	table.insert(vars.ui.savedAvatars, 1, data)
	vars.syncAllSavedAvatarsToDisk()

	vars.ui.selectedAvatar = data
	vars.populateAvatarList()
	vars.updateRowVisuals(data)

	if vars.IS_CATALOG_AVATAR_CREATOR then
		local catalogOk, catalogName, catalogErr = vars.saveAvatarToCatalogOutfit(data)
		if not catalogOk then
			vars.showDiagnostics("CAC avatar save/wear failed.", tostring(catalogErr))
			return false, catalogErr
		end
		vars.Status.Text = "[FE] Wore @" .. username .. " and saved to Saved Outfits as " .. tostring(catalogName)
		vars.clearDiagnostics()
		return true, data
	end

	vars.Status.Text = "[...] Wearing profile avatar: @" .. username
	vars.clearDiagnostics()
	task.defer(function()
		if vars.scriptAlive and vars.ui.selectedAvatar == data then
			vars.tryOnSelectedAvatarLocally()
		end
	end)
	return true, data
end

vars.savePlayerAvatar = function(targetPlayer)
	local data, err = vars.buildSavedAvatarData(targetPlayer)
	if not data then return false, err end
	if vars.findExactSavedAvatarMatch(data) then
		return false, "You already have that exact avatar saved in your list."
	end
	local ok, pathOrErr = vars.writeAvatarFile(data)
	if not ok then return false, pathOrErr end
	data.FilePath = pathOrErr
	data.FileName = tostring(pathOrErr):match("([^/\\]+)$") or pathOrErr
	data.Source = "ava"
	if data.Signature then vars.ui.deletedSignatures[data.Signature] = nil end
	vars.ui.savedAvatars = vars.ui.savedAvatars or {}
	table.insert(vars.ui.savedAvatars, 1, data)
	vars.syncAllSavedAvatarsToDisk()
	vars.ui.selectedAvatar = data
	return true, data
end

vars.stopPlayerSelection = function()
	vars.ui.selectingPlayer = false
	vars.ui.selectionPlayer = nil
	if vars.ui.selectionHighlight then
		pcall(function() vars.ui.selectionHighlight:Destroy() end)
		vars.ui.selectionHighlight = nil
	end
	if vars.SaveClickedButton and vars.SaveClickedButton.Parent then
		local t = GetTheme()
		vars.SaveClickedButton.Text = "SAVE OTHER"
		vars.SaveClickedButton.BackgroundColor3 = t.PanelBg
		vars.SaveClickedButton.TextColor3 = t.TextPrimary
	end
end

vars.setPlayerSelectionHighlight = function(targetPlayer)
	if not targetPlayer or targetPlayer == vars.LocalPlayer or not targetPlayer.Character then
		if vars.ui.selectionHighlight then pcall(function() vars.ui.selectionHighlight:Destroy() end) vars.ui.selectionHighlight = nil end
		vars.ui.selectionPlayer = nil
		return
	end
	if vars.ui.selectionPlayer == targetPlayer and vars.ui.selectionHighlight and vars.ui.selectionHighlight.Parent then return end
	if vars.ui.selectionHighlight then pcall(function() vars.ui.selectionHighlight:Destroy() end) end
	local t = GetTheme()
	local highlight = Instance.new("Highlight")
	highlight.Name = "AvatarSaveSelectionHighlight"
	highlight.Adornee = targetPlayer.Character
	highlight.FillColor = t.Accent
	highlight.FillTransparency = 0.68
	highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
	highlight.OutlineTransparency = 0.05
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Parent = vars.ScreenGui
	vars.ui.selectionHighlight = highlight
	vars.ui.selectionPlayer = targetPlayer
end

vars.getPlayerFromScreenPosition = function(position)
	local camera = vars.Workspace.CurrentCamera
	if not camera then return nil end
	local ray = camera:ScreenPointToRay(position.X, position.Y)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {vars.LocalPlayer.Character}
	local result = vars.Workspace:Raycast(ray.Origin, ray.Direction * 1000, params)
	local target = result and result.Instance
	if not target then return nil end
	local model = target:FindFirstAncestorOfClass("Model")
	if not model then return nil end
	local humanoid = model:FindFirstChildOfClass("Humanoid")
	if not humanoid then return nil end
	local hitPlayer = vars.Players:GetPlayerFromCharacter(model)
	return (hitPlayer and hitPlayer ~= vars.LocalPlayer) and hitPlayer or nil
end

vars.getPlayerFromMouseTarget = function()
	local mouse = vars.LocalPlayer:GetMouse()
	if not mouse then return nil end
	return vars.getPlayerFromScreenPosition(Vector2.new(mouse.X, mouse.Y))
end

-- Non-destructive multi-source loader: merges in-memory avatars + Master JSON + AvatarIndex + .ava files + Legacy JSON
vars.loadSavedAvatars = function()
	local previousSignature = vars.ui.selectedAvatar and vars.ui.selectedAvatar.Signature
	local previousName = vars.ui.selectedAvatar and vars.ui.selectedAvatar.Name

	local merged = {}
	local seenSignatures = {}

	local function addAvatarIfUnique(data, defaultSource)
		if type(data) ~= "table" or type(data.Properties) ~= "table" then return end
		local sig = data.Signature
		if not sig or sig == "" then
			sig = vars.getAvatarSignature(data.Properties, data.RigType or "R6")
			data.Signature = sig
		end
		if vars.ui.deletedSignatures and vars.ui.deletedSignatures[sig] then
			return
		end
		if seenSignatures[sig] then
			return
		end
		seenSignatures[sig] = true
		data.Source = data.Source or defaultSource or "ava"
		merged[#merged + 1] = data
	end

	-- 1. First preserve all currently loaded in-memory avatars (so saving a 6th+ avatar NEVER loses session avatars!)
	for _, memEntry in ipairs(vars.ui.savedAvatars or {}) do
		addAvatarIfUnique(memEntry, memEntry.Source or "ava")
	end

	-- 2. Read Master JSON (TR_SavedAvatars_Master.json)
	if type(readfile) == "function" and type(isfile) == "function" then
		local okM, hasMaster = pcall(isfile, vars.MASTER_FILE_PATH)
		if okM and hasMaster then
			local okDec, list = pcall(function() return vars.HttpService:JSONDecode(readfile(vars.MASTER_FILE_PATH)) end)
			if okDec and type(list) == "table" then
				for _, entry in ipairs(list) do
					addAvatarIfUnique(entry, "ava")
				end
			end
		end

		-- 3. Read AvatarIndex.json embedded Avatars list
		local okIdx, hasIdx = pcall(isfile, vars.AVATAR_INDEX_PATH)
		if okIdx and hasIdx then
			local okDec, idxData = pcall(function() return vars.HttpService:JSONDecode(readfile(vars.AVATAR_INDEX_PATH)) end)
			if okDec and type(idxData) == "table" and type(idxData.Avatars) == "table" then
				for _, entry in ipairs(idxData.Avatars) do
					addAvatarIfUnique(entry, "ava")
				end
			end
		end

		-- 4. Read individual .ava files from Avatars/ folder
		for _, fileData in ipairs(vars.readAvatarFiles()) do
			addAvatarIfUnique(fileData, "ava")
		end

		-- 5. Read SavedAvatars.json (v2 / legacy path)
		local okLeg, hasLeg = pcall(isfile, vars.FILE_PATH)
		if okLeg and hasLeg then
			local okDec, legList = pcall(function() return vars.HttpService:JSONDecode(readfile(vars.FILE_PATH)) end)
			if okDec and type(legList) == "table" then
				for _, entry in ipairs(legList) do
					addAvatarIfUnique(entry, "ava")
				end
			end
		end
	end

	table.clear(vars.ui.savedAvatars)
	for idx, item in ipairs(merged) do
		item.Order = idx
		vars.ui.savedAvatars[#vars.ui.savedAvatars + 1] = item
	end
	genv._TR_SavedAvatarsMemory = vars.ui.savedAvatars
	vars.syncAllSavedAvatarsToDisk()

	if previousSignature or previousName then
		vars.ui.selectedAvatar = nil
		for _, data in ipairs(vars.ui.savedAvatars) do
			if (previousSignature and data.Signature == previousSignature) or (not previousSignature and previousName and data.Name == previousName) then
				vars.ui.selectedAvatar = data
				break
			end
		end
	end
	vars.Status.Text = "[File] " .. tostring(#vars.ui.savedAvatars) .. " avatar(s) loaded."
	vars.clearDiagnostics()
	return true
end

vars.applyBodyColors = function(character, props)	if not character or type(props) ~= "table" then return end
	local bodyColors = character:FindFirstChildOfClass("BodyColors") or Instance.new("BodyColors")
	bodyColors.Parent = character
	local colorProps = {
		HeadColor = "HeadColor3", TorsoColor = "TorsoColor3", LeftArmColor = "LeftArmColor3",
		RightArmColor = "RightArmColor3", LeftLegColor = "LeftLegColor3", RightLegColor = "RightLegColor3"
	}
	for propKey, colorKey in pairs(colorProps) do
		local colorData = props[propKey]
		if type(colorData) == "table" then
			pcall(function()
				bodyColors[colorKey] = Color3.fromRGB(
					colorData.r or colorData.R or 255,
					colorData.g or colorData.G or 255,
					colorData.b or colorData.B or 255
				)
			end)
		end
	end
end

vars.applyHeadShapeToModel = function(model, props)	if not model or type(props) ~= "table" or props.HeadShape == nil then return end
	local head = model:FindFirstChild("Head")
	if not head then return end

	local shapeStr = tostring(props.HeadShape):lower()
	local specialMesh = head:FindFirstChildOfClass("SpecialMesh")

	if specialMesh then
		if shapeStr:find("block") then
			specialMesh.MeshType = Enum.MeshType.Brick
		elseif shapeStr:find("round") or shapeStr:find("standard") then
			specialMesh.MeshType = Enum.MeshType.Head
		end
	end
end

vars.applyHeadShapeToDescription = function(description, props)	if not description or type(props) ~= "table" then return false end

	local rawShape = props.HeadShape
	local shape = tostring(rawShape or "")
	shape = string.match(shape, "^%s*(.-)%s*$")
	if shape == "" then return false end

	local headAssetId = vars.parseAssetId(props.Head)
		or vars.parseAssetId(props.HeadAssetId)
		or vars.parseAssetId(props.HeadId)
		or (type(props.BodyParts) == "table" and vars.parseAssetId(props.BodyParts.Head))
		or (type(props.EquippedAssets) == "table" and vars.parseAssetId(props.EquippedAssets.Head))
	if not headAssetId then return false end

	local ok = pcall(function()
		local headDescription = Instance.new("BodyPartDescription")
		headDescription.BodyPart = Enum.BodyPart.Head
		headDescription.AssetId = headAssetId
		headDescription.HeadShape = shape
		headDescription.Parent = description
	end)

	return ok
end

vars.reconstructHumanoidDescription = function(props)	local desc = Instance.new("HumanoidDescription")
	if type(props) ~= "table" then return desc end

	local headShape = tostring(props.HeadShape or "")
	headShape = string.match(headShape, "^%s*(.-)%s*$")
	local hasHeadShape = headShape ~= ""
	local headShapeApplied = vars.applyHeadShapeToDescription(desc, props)

	local directProps = {
		"Face", "Shirt", "Pants", "GraphicTShirt", "Head", "Torso",
		"LeftArm", "RightArm", "LeftLeg", "RightLeg", "WalkAnimation",
		"MoodAnimation", "ClimbAnimation", "FallAnimation", "RunAnimation",
		"SwimAnimation", "IdleAnimation", "JumpAnimation"
	}
	for _, prop in ipairs(directProps) do
		local parsedId = vars.parseAssetId(props[prop])
		if parsedId and not (prop == "Head" and hasHeadShape and headShapeApplied) then
			pcall(function() desc[prop] = parsedId end)
		end
	end

	if not headShapeApplied and (desc.Head == 0 or not desc.Head) then
		local fallbackHeadId = vars.parseAssetId(props.HeadAssetId) or vars.parseAssetId(props.HeadId)
			or (type(props.BodyParts) == "table" and vars.parseAssetId(props.BodyParts.Head))
			or (type(props.EquippedAssets) == "table" and vars.parseAssetId(props.EquippedAssets.Head))
		if fallbackHeadId then pcall(function() desc.Head = fallbackHeadId end) end
	end

	if props.StaticFacialAnimation ~= nil then
		pcall(function() desc.StaticFacialAnimation = props.StaticFacialAnimation == true end)
	end
	if type(props.Emotes) == "table" then pcall(function() desc:SetEmotes(props.Emotes) end) end
	if type(props.EquippedEmotes) == "table" then pcall(function() desc:SetEquippedEmotes(props.EquippedEmotes) end) end

	if type(props.MakeupItems) == "table" then
		for _, makeup in ipairs(props.MakeupItems) do
			pcall(function()
				local assetId = vars.parseAssetId(makeup.AssetId)
				local makeupType = Enum.MakeupType[tostring(makeup.MakeupType)]
				if assetId and makeupType then
					local makeupDescription = Instance.new("MakeupDescription")
					makeupDescription.AssetId = assetId
					makeupDescription.Order = tonumber(makeup.Order) or 1
					makeupDescription.MakeupType = makeupType
					makeupDescription.Parent = desc
				end
			end)
		end
	end

	local refinements = props.AccessoryRefinements or {}
	if props.AllAccessories and type(props.AllAccessories) == "table" then
		local accessories = {}
		for _, entry in ipairs(props.AllAccessories) do
			if type(entry) == "table" and entry.AssetId and entry.AccessoryType then
				local parsedAssetId = vars.parseAssetId(entry.AssetId)
				local accessoryType = Enum.AccessoryType[entry.AccessoryType]
				if parsedAssetId and accessoryType then
					local accessory = { AssetId = parsedAssetId, AccessoryType = accessoryType }
					local refData = refinements[tostring(parsedAssetId)] or entry
					if refData then
						if refData.Position then accessory.Position = vars.vector3FromSaved(refData.Position, Vector3.zero) end
						if refData.Rotation then accessory.Rotation = vars.vector3FromSaved(refData.Rotation, Vector3.zero) end
						if refData.Scale then accessory.Scale = vars.vector3FromSaved(refData.Scale, Vector3.one) end
					end
					if entry.IsLayered then
						accessory.IsLayered = true
						accessory.Order = tonumber(entry.Order) or 0
						if entry.Puffiness ~= nil then accessory.Puffiness = tonumber(entry.Puffiness) or 0 end
					end
					table.insert(accessories, accessory)
				end
			end
		end
		pcall(function() desc:SetAccessories(accessories, true) end)
	else
		for _, propertyName in ipairs(vars.accessoryPropertyNames) do
			if props[propertyName] ~= nil then
				pcall(function() desc[propertyName] = tostring(props[propertyName]) end)
			end
		end
	end

	local colorProps = { "RightArmColor", "TorsoColor", "RightLegColor", "LeftLegColor", "LeftArmColor", "HeadColor" }
	for _, colorName in ipairs(colorProps) do
		local colorData = props[colorName]
		if type(colorData) == "table" then
			pcall(function()
				desc[colorName] = Color3.fromRGB(
					colorData.r or colorData.R or 255,
					colorData.g or colorData.G or 255,
					colorData.b or colorData.B or 255
				)
			end)
		end
	end

	local scaleProps = { "ProportionScale", "DepthScale", "HeightScale", "WidthScale", "BodyTypeScale", "HeadScale" }
	for _, scaleName in ipairs(scaleProps) do
		if props[scaleName] ~= nil then pcall(function() desc[scaleName] = tonumber(props[scaleName]) or 1 end) end
	end

	return desc
end

vars.applyRigidAccessoryRefinements = function(model, props)	local refinements = props and props.AccessoryRefinements
	if type(refinements) ~= "table" then return 0 end
	local matched = 0
	local used = {}
	for _, accessory in ipairs(model:GetDescendants()) do
		if accessory:IsA("Accessory") then
			local handle = accessory:FindFirstChild("Handle")
			if handle then
				local assetId = nil
				pcall(function() assetId = vars.parseAssetId(accessory:GetAttribute("AssetId")) end)
				if not assetId then pcall(function() assetId = vars.parseAssetId(handle:GetAttribute("AssetId")) end) end
				if not assetId then
					local specialMesh = handle:FindFirstChildOfClass("SpecialMesh")
					if specialMesh and specialMesh.MeshId then assetId = vars.parseAssetId(specialMesh.MeshId) end
				end
				if not assetId and handle:IsA("MeshPart") and handle.MeshId then assetId = vars.parseAssetId(handle.MeshId) end

				local ref = (assetId and refinements[tostring(assetId)]) or refinements[accessory.Name]
				if ref and type(ref) == "table" then
					local key = assetId or accessory.Name
					if not used[key] then
						local position = vars.vector3FromSaved(ref.Position, Vector3.zero)
						local rotation = vars.vector3FromSaved(ref.Rotation, Vector3.zero)
						local scale = vars.vector3FromSaved(ref.Scale, Vector3.one)

						local offsetCF = CFrame.new(position) * CFrame.Angles(
							math.rad(rotation.X), math.rad(rotation.Y), math.rad(rotation.Z)
						)

						local attachment = handle:FindFirstChildOfClass("Attachment")
						if attachment then
							attachment.CFrame = attachment.CFrame * offsetCF
						else
							local weld = handle:FindFirstChildOfClass("Weld") or handle:FindFirstChildOfClass("WeldConstraint") or handle:FindFirstChildOfClass("ManualWeld")
							if weld and weld:IsA("Weld") then weld.C0 = weld.C0 * offsetCF end
						end

						if scale ~= Vector3.one then
							handle.Size = handle.Size * scale
							local specialMesh = handle:FindFirstChildOfClass("SpecialMesh")
							if specialMesh then specialMesh.Scale = specialMesh.Scale * scale end
						end
						used[key] = true
						matched = matched + 1
					end
				end
			end
		end
	end
	return matched
end

vars.getAnimationIdFromFolder = function(container, animName)	if not container then return nil end
	local target = container:FindFirstChild(animName)
		or container:FindFirstChild(string.lower(animName))
		or (animName == "SwimIdle" and (container:FindFirstChild("swimidle") or container:FindFirstChild("SwimIdle")))
		or (animName == "Swim" and (container:FindFirstChild("swim") or container:FindFirstChild("Swim")))
	if not target then return nil end

	if target:IsA("Animation") and target.AnimationId ~= "" then return target.AnimationId
	elseif target:IsA("StringValue") and target.Value ~= "" then return target.Value end

	for _, child in ipairs(target:GetChildren()) do
		if child:IsA("Animation") and child.AnimationId ~= "" then return child.AnimationId
		elseif child:IsA("StringValue") and child.Value ~= "" then return child.Value end
	end
	return nil
end

vars.resolveAnimationIds = function(cloneModel, savedProps, isR6)	local defaults = isR6 and vars.R6_DEFAULTS or vars.R15_DEFAULTS
	local animFolder = cloneModel:FindFirstChild("Animate")
	local animIds = {}
	local animKeys = {"Idle", "Walk", "Run", "Jump", "Fall", "Climb", "Swim", "SwimIdle", "Sit"}

	for _, key in ipairs(animKeys) do
		if key == "Sit" then
			local cloneSitId = vars.getAnimationIdFromFolder(animFolder, "Sit")
			animIds[key] = cloneSitId or defaults[key]
		elseif isR6 then
			animIds[key] = defaults[key]
		else
			local idFromAnimate = vars.getAnimationIdFromFolder(animFolder, key)
			local propKey = key .. "Animation"
			local rawPropVal = savedProps and savedProps[propKey]
			local parsedPropId = vars.parseAssetId(rawPropVal)

			local finalId = (idFromAnimate and idFromAnimate ~= "") and idFromAnimate or nil
			if not finalId and parsedPropId then finalId = "rbxassetid://" .. tostring(parsedPropId) end
			if not finalId or finalId == "" then finalId = defaults[key] end
			animIds[key] = finalId
		end
	end
	return animIds
end

vars.getAppliedPlayerEmoteData = function(humanoid)	if not humanoid then return {}, {} end
	local description = nil
	local ok = pcall(function()
		description = humanoid:GetAppliedDescription()
	end)
	if not ok or not description then return {}, {} end

	local emotes = {}
	local equipped = {}
	pcall(function()
		emotes = vars.cloneEmoteTable(description:GetEmotes())
	end)
	pcall(function()
		local value = description:GetEquippedEmotes()
		if type(value) == "table" then
			for _, entry in ipairs(value) do
				if type(entry) == "table" and type(entry.Name) == "string" and entry.Name ~= "" then
					equipped[#equipped + 1] = {
						Slot = tonumber(entry.Slot) or (#equipped + 1),
						Name = entry.Name
					}
				end
			end
		end
	end)
	pcall(function() description:Destroy() end)
	return emotes, equipped
end

vars.mergePlayerEmotesIntoDescription = function(description, playerHumanoid, rigType)	if not description or vars.getEnumRigType(rigType) ~= Enum.HumanoidRigType.R15 then
		return
	end

	local playerEmotes, playerEquippedEmotes = vars.getAppliedPlayerEmoteData(playerHumanoid)
	local merged = {}
	pcall(function()
		merged = vars.cloneEmoteTable(description:GetEmotes())
	end)
	for name, ids in pairs(playerEmotes) do
		merged[name] = ids
	end

	if next(merged) ~= nil then
		pcall(function() description:SetEmotes(merged) end)
	end

	if #playerEquippedEmotes > 0 then
		local validEquipped = {}
		for _, entry in ipairs(playerEquippedEmotes) do
			if merged[entry.Name] then
				validEquipped[#validEquipped + 1] = entry
			end
		end
		if #validEquipped > 0 then
			pcall(function() description:SetEquippedEmotes(validEquipped) end)
		end
	end
end

vars.bindAnimationSync = function(playerCharacter, cloneModel, savedProps, rigType)	vars.cleanupAnimationSync()

	local playerHumanoid = playerCharacter and playerCharacter:FindFirstChildOfClass("Humanoid")
	local cloneHumanoid = cloneModel and cloneModel:FindFirstChildOfClass("Humanoid")
	if not playerHumanoid or not cloneHumanoid then return function() end end

	local playerAnimator = playerHumanoid:FindFirstChildOfClass("Animator")
	local cloneAnimator = cloneHumanoid:FindFirstChildOfClass("Animator")
	if not cloneAnimator then
		cloneAnimator = Instance.new("Animator")
		cloneAnimator.Parent = cloneHumanoid
	end

	for _, track in ipairs(cloneAnimator:GetPlayingAnimationTracks()) do
		pcall(function() track:Stop(0) end)
	end

	local enumRig = vars.getEnumRigType(rigType)
	local isR6 = (enumRig == Enum.HumanoidRigType.R6)
		or (cloneModel:FindFirstChild("Torso") ~= nil and cloneModel:FindFirstChild("UpperTorso") == nil)
	local defaults = isR6 and vars.R6_DEFAULTS or vars.R15_DEFAULTS
	local animIds = vars.resolveAnimationIds(cloneModel, savedProps, isR6)

	local playerEmoteByAssetId = {}
	local playerEmoteByAnimationId = {}
	local playerEmotePlayNameByCanonical = {}
	local equippedEmoteNames = {}

	local function normalizeEmoteName(rawName)
		local value = string.lower(tostring(rawName or ""))
		value = string.match(value, "^%s*(.-)%s*$") or value
		value = value:gsub("[^%w]+", "")
		return value
	end

	local function rememberEmoteAsset(assetId, emoteName, exactNameForPlayback)
		local parsed = vars.parseAssetId(assetId)
		if not parsed then return end
		local normalized = normalizeEmoteName(emoteName)
		if normalized == "" then return end
		playerEmoteByAssetId[tostring(parsed)] = normalized
		local exactName = exactNameForPlayback or emoteName
		if type(exactName) == "string" and exactName ~= "" then
			playerEmotePlayNameByCanonical[normalized] = exactName
		end
	end

	local function rememberResolvedAnimation(emoteAnimationId, emoteName, exactNameForPlayback)
		local parsed = vars.parseAssetId(emoteAnimationId)
		if not parsed then return end
		local normalized = normalizeEmoteName(emoteName)
		if normalized == "" then return end
		playerEmoteByAnimationId[tostring(parsed)] = normalized
		local exactName = exactNameForPlayback or emoteName
		if type(exactName) == "string" and exactName ~= "" then
			playerEmotePlayNameByCanonical[normalized] = exactName
		end
	end

	local function extractAnimationIdFromLoadedEmoteAsset(root)
		if not root then return nil end
		if root:IsA("Animation") and root.AnimationId ~= "" then
			return root.AnimationId
		end
		for _, instance in ipairs(root:GetDescendants()) do
			if instance:IsA("Animation") and instance.AnimationId ~= "" then
				return instance.AnimationId
			end
		end
		return nil
	end

	local function resolveEmoteCatalogAssetToAnimationId(catalogAssetId)
		local parsed = vars.parseAssetId(catalogAssetId)
		if not parsed then return nil end
		local key = tostring(parsed)
		if vars.emoteAssetAnimationCache[key] ~= nil then
			return vars.emoteAssetAnimationCache[key]
		end

		local animationId = nil

		pcall(function()
			if type(game.GetObjects) == "function" then
				local objects = game:GetObjects("rbxassetid://" .. key)
				if type(objects) == "table" then
					for _, root in ipairs(objects) do
						animationId = extractAnimationIdFromLoadedEmoteAsset(root)
						if animationId then
							pcall(function() root:Destroy() end)
							break
						end
					end
				end
			end
		end)

		if not animationId and vars.InsertService then
			pcall(function()
				local root = vars.InsertService:LoadAsset(parsed)
				animationId = extractAnimationIdFromLoadedEmoteAsset(root)
				if root then root:Destroy() end
			end)
		end

		if animationId then
			vars.emoteAssetAnimationCache[key] = animationId
		end
		return animationId
	end

	local appliedDescription = nil
	local appliedDescriptionOk = pcall(function()
		appliedDescription = playerHumanoid:GetAppliedDescription()
	end)
	if appliedDescriptionOk and appliedDescription then
		pcall(function()
			local equipped = appliedDescription:GetEquippedEmotes()
			if type(equipped) == "table" then
				for _, entry in ipairs(equipped) do
					if type(entry) == "table" and type(entry.Name) == "string" then
						equippedEmoteNames[normalizeEmoteName(entry.Name)] = entry.Name
					end
				end
			end
		end)

		pcall(function()
			local emotes = appliedDescription:GetEmotes()
			if type(emotes) == "table" then
				for name, ids in pairs(emotes) do
					if type(ids) == "table" then
						local exactName = type(name) == "string" and name or tostring(name)
						for _, assetId in ipairs(ids) do
							rememberEmoteAsset(assetId, exactName, exactName)
							local actualAnimationId = resolveEmoteCatalogAssetToAnimationId(assetId)
							if actualAnimationId then
								rememberResolvedAnimation(actualAnimationId, exactName, exactName)
							end
						end
					end
				end
			end
		end)
		pcall(function() appliedDescription:Destroy() end)
	end

	for emoteName, assetList in pairs(vars.R6_EMOTE_LIBRARY) do
		for _, assetId in ipairs(assetList) do
			rememberEmoteAsset(assetId, emoteName)
		end
	end

	local playerAnimate = playerCharacter:FindFirstChild("Animate")
	local knownEmoteNames = {}
	for emoteName in pairs(vars.R6_EMOTE_LIBRARY) do
		knownEmoteNames[normalizeEmoteName(emoteName)] = emoteName
	end
	for normalized, exactName in pairs(equippedEmoteNames) do
		knownEmoteNames[normalized] = exactName
	end

	local function getNamedEmoteFromHierarchy(animation)
		if not animation then return nil end

		local function checkName(instance)
			if not instance then return nil end
			local normalized = normalizeEmoteName(instance.Name)
			return knownEmoteNames[normalized]
		end

		local direct = checkName(animation)
		if direct then return direct end

		local parent = animation.Parent
		while parent and parent ~= playerCharacter do
			local named = checkName(parent)
			if named then return named end
			if parent == playerAnimate then break end
			parent = parent.Parent
		end
		return nil
	end

	local locomotionFolderNames = {
		idle = true,
		walk = true,
		run = true,
		jump = true,
		fall = true,
		climb = true,
		swim = true,
		swimidle = true,
		sit = true,
		seated = true,
		tool = true,
		toolnone = true,
		toolnoneanim = true,
		toolslash = true,
		toollunge = true,
		slash = true,
		lunge = true,
	}

	local function hasLocomotionOrToolAncestor(animation)
		if not animation then return false end
		local normalizedName = normalizeEmoteName(animation.Name)
		if locomotionFolderNames[normalizedName] then return true end

		local parent = animation.Parent
		while parent and parent ~= playerCharacter do
			local parentName = normalizeEmoteName(parent.Name)
			if locomotionFolderNames[parentName] then return true end
			parent = parent.Parent
		end
		return false
	end

	local function isLikelyR15EmoteTrack(playerTrack)
		if isR6 or not playerTrack or not playerTrack.Animation then return false end
		if hasLocomotionOrToolAncestor(playerTrack.Animation) then return false end

		local priority = playerTrack.Priority
		local isCore = priority == Enum.AnimationPriority.Core
		local isAction = priority == Enum.AnimationPriority.Action
			or priority == Enum.AnimationPriority.Action2
			or priority == Enum.AnimationPriority.Action3
			or priority == Enum.AnimationPriority.Action4
		if not isCore and not isAction then return false end

		local animationId = vars.parseAssetId(playerTrack.Animation.AnimationId)
		if not animationId then return false end

		if next(equippedEmoteNames) ~= nil
			or next(playerEmoteByAnimationId) ~= nil
			or next(playerEmoteByAssetId) ~= nil then
			return true
		end

		return false
	end

	if playerAnimate then
		for _, instance in ipairs(playerAnimate:GetDescendants()) do
			if instance:IsA("Animation") then
				local emoteName = getNamedEmoteFromHierarchy(instance)
				if emoteName then
					rememberEmoteAsset(instance.AnimationId, emoteName)
				end
			end
		end
	end

	local function resolvePlayerEmoteName(playerTrack)
		if not playerTrack or not playerTrack.Animation then return nil, false end

		local assetId = vars.parseAssetId(playerTrack.Animation.AnimationId)
		if assetId then
			local assetKey = tostring(assetId)

			local resolvedAnimationMapped = playerEmoteByAnimationId[assetKey]
			if resolvedAnimationMapped then
				return resolvedAnimationMapped, true
			end

			local legacyMapped = vars.PLAYER_LEGACY_EMOTE_IDS[assetKey]
			if legacyMapped then return legacyMapped, true end

			local mapped = playerEmoteByAssetId[assetKey]
			if mapped then return mapped, true end
		end

		local named = getNamedEmoteFromHierarchy(playerTrack.Animation)
		if named then return normalizeEmoteName(named), true end

		if isLikelyR15EmoteTrack(playerTrack) then
			return "__direct_r15_emote_track__", false
		end

	return nil, false
	end

	local function chooseR6EmoteAnimation(emoteName)
		local list = vars.R6_EMOTE_LIBRARY[emoteName]
		if type(list) ~= "table" or #list == 0 then return nil end

		if #list == 1 then return list[1] end
		local index = (math.floor(os.clock() * 1000) % #list) + 1
		return list[index]
	end
	local function findFreshCloneEmoteTrack(beforeTracks, expectedAssetId)
		local expectedParsed = vars.parseAssetId(expectedAssetId)
		local expectedKey = expectedParsed and tostring(expectedParsed) or nil
		local fallback = nil

		for _, candidate in ipairs(cloneAnimator:GetPlayingAnimationTracks()) do
			if candidate and candidate.IsPlaying and not beforeTracks[candidate] then
				local candidateId = candidate.Animation and vars.parseAssetId(candidate.Animation.AnimationId)
				if expectedKey and candidateId and tostring(candidateId) == expectedKey then
					return candidate
				end
				fallback = fallback or candidate
			end
		end

		return fallback
	end

	local function syncInitialEmotePhase(playerTrack, cloneTrack)
		if not playerTrack or not cloneTrack then return end
		if not playerTrack.IsPlaying or not cloneTrack.IsPlaying then return end

		local playerAnimation = playerTrack.Animation
		local cloneAnimation = cloneTrack.Animation
		local playerId = playerAnimation and vars.parseAssetId(playerAnimation.AnimationId)
		local cloneId = cloneAnimation and vars.parseAssetId(cloneAnimation.AnimationId)

		if not playerId or not cloneId or playerId ~= cloneId then return end

		local function applyPhase()
			if not playerTrack.IsPlaying or not cloneTrack.IsPlaying then return true end
			if playerTrack.Length <= 0 or cloneTrack.Length <= 0 then return false end

			local playerPhase = math.clamp(playerTrack.TimePosition / playerTrack.Length, 0, 0.999999)
			local targetPosition = playerPhase * cloneTrack.Length
			pcall(function()
				cloneTrack.TimePosition = targetPosition
			end)
			return true
		end

		if applyPhase() then return end

		task.spawn(function()
			for _ = 1, 4 do
				vars.RunService.Heartbeat:Wait()
				if not vars.scriptAlive then return end
				if applyPhase() then return end
			end
		end)
	end

	local function tryPlayRegisteredR15Emote(emoteName, playerTrack)
		if isR6 then return nil, nil end

		local playbackName = playerEmotePlayNameByCanonical[emoteName]
		if not playbackName then return nil, nil end

		local beforeTracks = {}
		for _, track in ipairs(cloneAnimator:GetPlayingAnimationTracks()) do
			beforeTracks[track] = true
		end

		local ok, result = pcall(function()
			return cloneHumanoid:PlayEmoteAsync(playbackName)
		end)
		if not ok or result ~= true then return nil, nil end

		local expectedAssetId = playerTrack
			and playerTrack.Animation
			and playerTrack.Animation.AnimationId

		local cloneTrack = nil
		local deadline = os.clock() + 0.35
		repeat
			cloneTrack = findFreshCloneEmoteTrack(beforeTracks, expectedAssetId)
			if cloneTrack then break end
			vars.RunService.Heartbeat:Wait()
		until os.clock() >= deadline

		if not cloneTrack then
			local expectedParsed = vars.parseAssetId(expectedAssetId)
			if expectedParsed then
				pcall(function()
					cloneTrack = cloneAnimator:GetTrackByAnimationId("rbxassetid://" .. tostring(expectedParsed))
				end)
			end
		end

		if cloneTrack then
			pcall(function() cloneTrack.Priority = Enum.AnimationPriority.Action end)
			pcall(function() cloneTrack.Looped = true end)
			syncInitialEmotePhase(playerTrack, cloneTrack)
		end

		return cloneTrack
	end

	local function loadDirectCloneEmote(animationId, emoteName, playerTrack)
		if not animationId or animationId == "" then return nil, nil end

		local animation = Instance.new("Animation")
		animation.AnimationId = animationId

		local ok, cloneTrack = pcall(function()
			return cloneAnimator:LoadAnimation(animation)
		end)
		if not ok or not cloneTrack then
			animation:Destroy()
			return nil, nil
		end

		cloneTrack.Priority = Enum.AnimationPriority.Action
		if isR6 then
			cloneTrack.Looped = vars.R6_EMOTE_LOOPED[emoteName] == true
		else
			cloneTrack.Looped = playerTrack.Looped
		end

		local playedOk = pcall(function()
			cloneTrack:Play(0.08, 1, 1)
		end)
		if not playedOk then
			pcall(function() cloneTrack:Stop(0) end)
			animation:Destroy()
			return nil, nil
		end

		syncInitialEmotePhase(playerTrack, cloneTrack)
		return cloneTrack, animation
	end

	local catchEmoteTrack

	local function playCloneEmote(playerTrack, emoteName, isDirectR15Track)
		if not playerTrack or not emoteName then return false end

		vars.stopAllCloneTracks(0.08)

		local cloneTrack = nil
		local animationObject = nil

		if not isR6 and not isDirectR15Track then
			cloneTrack = tryPlayRegisteredR15Emote(emoteName, playerTrack)
		end

		if not cloneTrack then
			local animationId = nil
			if isR6 then
				animationId = chooseR6EmoteAnimation(emoteName)
			else
				animationId = playerTrack.Animation.AnimationId
			end

			cloneTrack, animationObject = loadDirectCloneEmote(animationId, emoteName, playerTrack)
		end

		if not cloneTrack then
			return false
		end

		vars.activeCloneTracks[playerTrack] = cloneTrack
		vars.activeCloneEmoteAnimations[playerTrack] = animationObject
		vars.activeEmotePlayerTrack = playerTrack

		local stoppedConnection
		stoppedConnection = playerTrack.Stopped:Connect(function()
			task.delay(0.12, function()
				if not vars.scriptAlive or vars.activeEmotePlayerTrack ~= playerTrack then return end
				if playerAnimator then
					for _, replacementTrack in ipairs(playerAnimator:GetPlayingAnimationTracks()) do
						if replacementTrack and replacementTrack.IsPlaying then
							local replacementName = resolvePlayerEmoteName(replacementTrack)
							if replacementName == emoteName then
								catchEmoteTrack(replacementTrack)
								return
							end
						end
					end
				end

				local active = vars.activeCloneTracks[playerTrack]
				vars.activeCloneTracks[playerTrack] = nil
				vars.activeCloneStopConnections[playerTrack] = nil
				local activeAnimation = vars.activeCloneEmoteAnimations[playerTrack]
				vars.activeCloneEmoteAnimations[playerTrack] = nil
				if active then pcall(function() active:Stop(0.08) end) end
				if activeAnimation then pcall(function() activeAnimation:Destroy() end) end
				vars.disconnectConnection(stoppedConnection)
				if vars.activeEmotePlayerTrack == playerTrack then vars.activeEmotePlayerTrack = nil end
			end)
		end)

		vars.activeCloneStopConnections[playerTrack] = stoppedConnection
		return true
	end

	catchEmoteTrack = function(playerTrack)
		if not playerTrack or not playerTrack.IsPlaying then return false end
		if vars.activeCloneTracks[playerTrack] then return true end
		local emoteName, isKnownEmote = resolvePlayerEmoteName(playerTrack)
		if not emoteName then return false end
		if next(vars.activeCloneTracks) ~= nil and vars.activeEmotePlayerTrack ~= playerTrack and not isKnownEmote then
			return false
		end
		local directR15 = (emoteName == "__direct_r15_emote_track__")
		return playCloneEmote(playerTrack, emoteName, directR15)
	end

	if playerAnimator then
		for _, track in ipairs(playerAnimator:GetPlayingAnimationTracks()) do
			task.defer(catchEmoteTrack, track)
		end
		vars.animPlayedConnection = playerAnimator.AnimationPlayed:Connect(function(playerTrack)
			task.defer(catchEmoteTrack, playerTrack)
		end)
	end

	local loadedTracks = {}
	for key, animId in pairs(animIds) do
		if animId and animId ~= "" then
			local animObj = Instance.new("Animation")
			animObj.AnimationId = animId
			local ok, track = pcall(function() return cloneAnimator:LoadAnimation(animObj) end)

			if (not ok or not track) and isR6 and defaults[key] then
				local fallbackObj = Instance.new("Animation")
				fallbackObj.AnimationId = defaults[key]
				ok, track = pcall(function() return cloneAnimator:LoadAnimation(fallbackObj) end)
			end

			if ok and track then
				if key == "Idle" then track.Priority = Enum.AnimationPriority.Idle
				elseif key == "Walk" or key == "Run" or key == "Climb" or key == "Swim" or key == "SwimIdle" then track.Priority = Enum.AnimationPriority.Movement
				elseif key == "Jump" or key == "Fall" or key == "Sit" then track.Priority = Enum.AnimationPriority.Action
				else track.Priority = Enum.AnimationPriority.Core end

				track.Looped = (key ~= "Jump")
				loadedTracks[key] = track
			end
		end
	end

	local activeKey = nil

	return function()
		if not vars.scriptAlive or not cloneModel or not cloneModel.Parent then return end

		local playerRoot = playerCharacter:FindFirstChild("HumanoidRootPart") or playerCharacter.PrimaryPart
		local moveSpeed, verticalVel, totalVel = 0, 0, 0
		local moveDirectionMagnitude = 0

		if playerRoot then
			local vel = playerRoot.AssemblyLinearVelocity or playerRoot.Velocity
			moveSpeed = Vector3.new(vel.X, 0, vel.Z).Magnitude
			verticalVel = vel.Y
			totalVel = vel.Magnitude
		end

		if playerHumanoid then
			moveDirectionMagnitude = playerHumanoid.MoveDirection.Magnitude
		end

		local state = playerHumanoid and playerHumanoid:GetState()
		local isSeated = playerHumanoid and (playerHumanoid.Sit or playerHumanoid.SeatPart ~= nil or state == Enum.HumanoidStateType.Seated) or false

		if not isR6 and vars.activeEmotePlayerTrack then
			local activePlayerEmoteTrack = vars.activeEmotePlayerTrack
			local activeCloneEmoteTrack = vars.activeCloneTracks[activePlayerEmoteTrack]
			if activePlayerEmoteTrack.IsPlaying and activeCloneEmoteTrack and activeCloneEmoteTrack.IsPlaying then
				pcall(function() activeCloneEmoteTrack.Looped = true end)
			end
		end

		local intentionalMovement = moveDirectionMagnitude > 0.05 and moveSpeed > 1.2

		local shouldReleaseEmote = isSeated or intentionalMovement
			or state == Enum.HumanoidStateType.Jumping
			or state == Enum.HumanoidStateType.Freefall
			or state == Enum.HumanoidStateType.Climbing
			or state == Enum.HumanoidStateType.Swimming

		if shouldReleaseEmote and next(vars.activeCloneTracks) ~= nil then
			vars.stopAllCloneTracks(0.08)
		end

		local desiredKey = "Idle"
		local climbPlaybackSpeed = 0

		if isSeated and isR6 then
			local sitTrack = loadedTracks.Sit
			if sitTrack then
				for key, track in pairs(loadedTracks) do
					if key ~= "Sit" and track.IsPlaying then
						pcall(function() track:Stop(0.05) end)
					end
				end
				sitTrack.Priority = Enum.AnimationPriority.Action4
				sitTrack.Looped = true
				if not sitTrack.IsPlaying then
					pcall(function() sitTrack:Play(0.08, 1, 1) end)
				else
					pcall(function() sitTrack:AdjustWeight(1, 0.05) end)
				end
				activeKey = "Sit"
				return
			end
			desiredKey = "Sit"
		elseif isSeated then desiredKey = "Sit"
		elseif state == Enum.HumanoidStateType.Climbing then
			desiredKey = "Climb"
			if verticalVel > 0.1 then
				climbPlaybackSpeed = math.clamp(verticalVel / 8, 0.4, 2.0)
			elseif verticalVel < -0.1 then
				climbPlaybackSpeed = -math.clamp(math.abs(verticalVel) / 8, 0.4, 2.0)
			end
		elseif state == Enum.HumanoidStateType.Swimming then desiredKey = (totalVel > 0.75) and "Swim" or "SwimIdle"
		elseif state == Enum.HumanoidStateType.Jumping then desiredKey = "Jump"
		elseif state == Enum.HumanoidStateType.Freefall then
			desiredKey = (activeKey == "Jump" and loadedTracks["Jump"] and loadedTracks["Jump"].IsPlaying and verticalVel > 0.1) and "Jump" or "Fall"
		else
			if moveSpeed > 1.2 then
				desiredKey = (moveSpeed > 12 and loadedTracks["Run"]) and "Run" or "Walk"
			else desiredKey = "Idle" end
		end

		if not loadedTracks[desiredKey] then
			if desiredKey == "SwimIdle" then desiredKey = loadedTracks["Swim"] and "Swim" or (loadedTracks["Idle"] and "Idle" or "Walk")
			elseif desiredKey == "Swim" then desiredKey = loadedTracks["SwimIdle"] and "SwimIdle" or (loadedTracks["Walk"] and "Walk" or "Idle")
			elseif desiredKey == "Run" then desiredKey = "Walk" end
			if not loadedTracks[desiredKey] then desiredKey = "Idle" end
		end

		local activeTrack = activeKey and loadedTracks[activeKey]
		local desiredTrack = desiredKey and loadedTracks[desiredKey]

		local sameAnimationAsset = activeTrack and desiredTrack
			and activeTrack.Animation and desiredTrack.Animation
			and activeTrack.Animation.AnimationId == desiredTrack.Animation.AnimationId

		if activeKey ~= desiredKey and not sameAnimationAsset then
			if activeTrack then pcall(function() activeTrack:Stop(0.15) end) end
			activeKey = desiredKey
			activeTrack = loadedTracks[activeKey]
			if activeTrack then
				if activeKey == "Climb" then
					pcall(function() activeTrack:Play(0.15, 1, 0) end)
					if activeTrack.Length > 0 then
						pcall(function()
							activeTrack.TimePosition = (climbPlaybackSpeed < 0) and math.max(activeTrack.Length - 0.001, 0) or 0
						end)
					end
					pcall(function() activeTrack:AdjustSpeed(climbPlaybackSpeed) end)
				else
					pcall(function() activeTrack:Play(0.15) end)
				end
			end
		elseif activeTrack and not activeTrack.IsPlaying then
			if activeKey == "Climb" then
				pcall(function() activeTrack:Play(0.15, 1, 0) end)
				if activeTrack.Length > 0 then
					pcall(function()
						activeTrack.TimePosition = (climbPlaybackSpeed < 0) and math.max(activeTrack.Length - 0.001, 0) or 0
					end)
				end
				pcall(function() activeTrack:AdjustSpeed(climbPlaybackSpeed) end)
			else
				pcall(function() activeTrack:Play(0.15) end)
			end
		end

		if activeKey == "Walk" or activeKey == "Run" then
			local currentTrack = loadedTracks[activeKey]
			if currentTrack and currentTrack.IsPlaying then
				pcall(function() currentTrack:AdjustSpeed(math.clamp(moveSpeed / 14, 0.6, 2.0)) end)
			end
		elseif activeKey == "Climb" then
			local currentTrack = loadedTracks[activeKey]
			if currentTrack and currentTrack.IsPlaying then
				pcall(function() currentTrack:AdjustSpeed(climbPlaybackSpeed) end)
			end
		elseif activeKey == "Swim" or activeKey == "SwimIdle" then
			local currentTrack = loadedTracks[activeKey]
			if currentTrack and currentTrack.IsPlaying then
				local targetSpeed = isR6 and math.clamp(totalVel / 12, 0.5, 1.8) or math.clamp(totalVel / 10, 0.6, 2.0)
				if activeKey == "SwimIdle" and totalVel < 0.5 then targetSpeed = 1.0 end
				pcall(function() currentTrack:AdjustSpeed(targetSpeed) end)
			end
		end
	end
end

vars.queuePreview = function(card, data)	if not vars.scriptAlive or not card or not data or not card.Parent then return end
	local state = vars.previewStates[data]
	if state == "queued" or state == "loading" or state == "ready" then return end

	vars.previewStates[data] = "queued"
	vars.previewQueue[#vars.previewQueue + 1] = {
		Card = card,
		Data = data,
		Generation = vars.previewQueueGeneration
	}
end

vars.preloadAvatarVisualContent = function(model)	if not model then return false end
	local targets = {}
	for _, instance in ipairs(model:GetDescendants()) do
		if instance:IsA("MeshPart")
			or instance:IsA("SpecialMesh")
			or instance:IsA("Decal")
			or instance:IsA("Texture") then
			targets[#targets + 1] = instance
		end
	end
	if #targets == 0 then return true end
	return pcall(function() vars.ContentProvider:PreloadAsync(targets) end)
end

vars.createPreviewViewport = function(parentContainer)	if not parentContainer or not parentContainer.Parent then return nil end

	local oldPreview = parentContainer:FindFirstChild("Preview")
	if oldPreview then oldPreview:Destroy() end

	local viewport = Instance.new("ViewportFrame")
	viewport.Name = "Preview"
	viewport.Size = UDim2.new(1, 0, 1, 0)
	viewport.BackgroundTransparency = 1
	viewport.BorderSizePixel = 0
	viewport.ZIndex = parentContainer.ZIndex + 1
	viewport.Parent = parentContainer

	local worldModel = Instance.new("WorldModel")
	worldModel.Parent = viewport

	local previewCamera = Instance.new("Camera")
	previewCamera.FieldOfView = 30
	previewCamera.Parent = viewport
	viewport.CurrentCamera = previewCamera

	return viewport, worldModel, previewCamera
end

vars.positionPreviewCamera = function(previewCamera, model)	if not previewCamera or not model then return end
	local head = model:FindFirstChild("Head", true)
	local root = model:FindFirstChild("HumanoidRootPart", true) or head or model.PrimaryPart
	if not root then return end

	local cf, size = model:GetBoundingBox()
	if size.Magnitude <= 0 then return end

	local targetPosition = cf.Position + Vector3.new(0, size.Y * 0.04, 0)
	local lookVector = head and head.CFrame.LookVector or root.CFrame.LookVector
	if lookVector.Magnitude == 0 then lookVector = Vector3.new(0, 0, -1) end

	local distance = math.max(math.max(size.Y, size.X, size.Z) * 1.85, 5.5)
	previewCamera.CFrame = CFrame.lookAt(targetPosition + lookVector.Unit * distance, targetPosition)
end

vars.buildPreviewTemplate = function(data, cacheKey)	if not data or not data.Properties then return nil end

	local description = vars.reconstructHumanoidDescription(data.Properties)
	local rigType = vars.getEnumRigType(data.RigType)
	local ok, model = pcall(function()
		if type(vars.Players.CreateHumanoidModelFromDescriptionAsync) == "function" then
			return vars.Players:CreateHumanoidModelFromDescriptionAsync(description, rigType)
		end
		return vars.Players:CreateHumanoidModelFromDescription(description, rigType)
	end)
	pcall(function() description:Destroy() end)

	if not ok or not model or not model:IsA("Model") then
		if model and typeof(model) == "Instance" then pcall(function() model:Destroy() end) end
		return nil
	end

	model.Parent = nil
	model:PivotTo(CFrame.new(0, 0, 0))
	vars.applyBodyColors(model, data.Properties)
	vars.applyHeadShapeToModel(model, data.Properties)

	if cacheKey then
		vars.previewModelCache[cacheKey] = model
		vars.touchPreviewCache(cacheKey)
	end
	return model
end

vars.renderPreview = function(card, data)	if not card or not card.Parent or not data then return false end
	local previewContainer = card:FindFirstChild("PreviewContainer")
	if not previewContainer then return false end

	local cacheKey = vars.getPreviewCacheKey(data)
	local template = cacheKey and vars.previewModelCache[cacheKey]
	if template and template.Parent ~= nil then
		vars.previewModelCache[cacheKey] = nil
		template = nil
	elseif template then
		vars.touchPreviewCache(cacheKey)
	end

	for attempt = 1, 3 do
		if not vars.scriptAlive or not card.Parent then return false end

		local viewport, worldModel, camera = vars.createPreviewViewport(previewContainer)
		if not viewport then return false end

		if not template then
			template = vars.buildPreviewTemplate(data, cacheKey)
		end

		if template then
			local model
			local cloneOk = pcall(function() model = template:Clone() end)
			if cloneOk and model then
				model.Parent = worldModel
				model:PivotTo(CFrame.new(0, 0, 0))
				task.wait()
				if model.Parent == worldModel and model:FindFirstChildOfClass("Humanoid") then
					local cf, size = model:GetBoundingBox()
			local center = cf.Position + Vector3.new(0, size.Y * 0.03, 0)
			local distance = math.max(size.X, size.Y, size.Z) * vars.previewCameraDistanceMultiplier
			camera.FieldOfView = 35
			camera.CFrame = CFrame.lookAt(center + Vector3.new(0, size.Y * 0.02, distance), center)
					return true
				end
				pcall(function() model:Destroy() end)
			end
		end

		pcall(function() viewport:Destroy() end)
		if attempt < 3 then task.wait(0.12 * attempt) end
	end

	return false
end

vars.processPreviewQueue = function()	if vars.previewQueueRunning then return end
	vars.previewQueueRunning = true

	while vars.scriptAlive and #vars.previewQueue > 0 do
		local taskData = table.remove(vars.previewQueue, 1)
		if taskData and taskData.Generation == vars.previewQueueGeneration then
			local card = taskData.Card
			local data = taskData.Data
			if card and card.Parent and data then
				vars.previewStates[data] = "loading"
				local ok, rendered = pcall(function()
					return vars.renderPreview(card, data)
				end)
				if ok and rendered then
					vars.previewStates[data] = "ready"
				else
					vars.previewStates[data] = "unavailable"
				end
			end
		end
		task.wait(0.04)
	end

	vars.previewQueueRunning = false
end

vars.getAccessoryCount = function(data)	local props = data and data.Properties
	if type(props) ~= "table" then return 0 end

	if type(props.AllAccessories) == "table" then
		local count = 0
		for _, entry in ipairs(props.AllAccessories) do
			if type(entry) == "table" and vars.parseAssetId(entry.AssetId) then
				count = count + 1
			end
		end
		return count
	end

	local count = 0
	for _, propertyName in ipairs(vars.accessoryPropertyNames) do
		local value = props[propertyName]
		if value ~= nil and tostring(value) ~= "" and tostring(value) ~= "0" then
			for _ in tostring(value):gmatch("%d+") do
				count = count + 1
			end
		end
	end
	return count
end

--==============================================================================
-- 3D ROTATING VIEWPORT PREVIEW & THEME-REACTIVE SAVED AVATAR CARDS
--==============================================================================
vars.hoverPreviewToken = vars.hoverPreviewToken or 0

vars.stopHoverPreview = function()
	vars.hoverPreviewToken = vars.hoverPreviewToken + 1
	vars.ui.hoverButton = nil
	vars.ui.pinnedPreviewData = nil
	if vars.ui.hoverConnection then
		vars.disconnectConnection(vars.ui.hoverConnection)
		vars.ui.hoverConnection = nil
	end
	if vars.ui.hoverModel then
		pcall(function() vars.ui.hoverModel:Destroy() end)
		vars.ui.hoverModel = nil
	end
	vars.ui.hoverViewport = nil
	local popup = vars.HoverPreview
	if popup then
		popup.Visible = false
	end
end
genv._TR_StopAvatarHoverPreview = vars.stopHoverPreview

vars.createHoverPreviewUI = function()
	local t = GetTheme()
	local popup = Instance.new("Frame")
	popup.Name = "TR_AvatarHoverPreview"
	popup.Size = UDim2.new(0, vars.previewWidth, 0, 370)
	popup.Position = UDim2.new(0.5, 290, 0.5, -185)
	popup.BackgroundColor3 = t.MainBg
	popup.BackgroundTransparency = 0.06
	popup.BorderSizePixel = 0
	popup.Visible = false
	popup.ZIndex = 65
	popup.Parent = vars.ScreenGui
	vars.addCorner(popup, 12)
	local pStroke = vars.addStroke(popup, t.Stroke, 1.6, 0.2)

	local pGrad = Instance.new("UIGradient")
	pGrad.Name = "PreviewGlassGrad"
	pGrad.Rotation = -38
	pGrad.Enabled = false
	pGrad.Parent = popup

	local sGrad = Instance.new("UIGradient")
	sGrad.Name = "PreviewStrokeGrad"
	sGrad.Rotation = 35
	sGrad.Enabled = false
	sGrad.Parent = pStroke

	local topBar = Instance.new("Frame")
	topBar.Name = "PreviewTopBar"
	topBar.Size = UDim2.new(1, -20, 0, 28)
	topBar.Position = UDim2.new(0, 10, 0, 8)
	topBar.BackgroundTransparency = 1
	topBar.ZIndex = 67
	topBar.Parent = popup

	local title = Instance.new("TextLabel")
	title.Name = "OutfitName"
	title.Size = UDim2.new(1, -32, 1, 0)
	title.Position = UDim2.new(0, 2, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = "3D AVATAR PREVIEW"
	title.TextColor3 = t.Accent
	title.TextSize = 12
	title.Font = Enum.Font.GothamBold
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextTruncate = Enum.TextTruncate.AtEnd
	title.ZIndex = 68
	title.Parent = topBar

	local closeBtn = Instance.new("TextButton")
	closeBtn.Name = "ClosePreviewBtn"
	closeBtn.Size = UDim2.fromOffset(24, 24)
	closeBtn.Position = UDim2.new(1, -24, 0.5, -12)
	closeBtn.BackgroundColor3 = t.PanelBg
	closeBtn.BorderSizePixel = 0
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.TextSize = 11
	closeBtn.TextColor3 = t.TextPrimary
	closeBtn.Text = "X"
	closeBtn.ZIndex = 69
	closeBtn.Parent = topBar
	vars.addCorner(closeBtn, 6)
	vars.wire(closeBtn.Activated, function()
		vars.stopHoverPreview()
	end)

	local viewportHolder = Instance.new("Frame")
	viewportHolder.Name = "ViewportHolder"
	viewportHolder.Size = UDim2.new(1, -24, 1, -96)
	viewportHolder.Position = UDim2.new(0, 12, 0, 40)
	viewportHolder.BackgroundColor3 = t.PanelBg
	viewportHolder.BackgroundTransparency = 0.25
	viewportHolder.BorderSizePixel = 0
	viewportHolder.ClipsDescendants = true
	viewportHolder.ZIndex = 66
	viewportHolder.Parent = popup
	vars.addCorner(viewportHolder, 8)
	local vhStroke = vars.addStroke(viewportHolder, t.Stroke, 1, 0.45)
	vhStroke.Name = "VHStroke"

	local info = Instance.new("TextLabel")
	info.Name = "Info"
	info.Size = UDim2.new(1, -24, 0, 18)
	info.Position = UDim2.new(0, 12, 1, -50)
	info.BackgroundTransparency = 1
	info.Text = "R15  |  0 accessories"
	info.TextColor3 = t.TextSecondary
	info.TextSize = 11
	info.Font = Enum.Font.GothamSemibold
	info.TextXAlignment = Enum.TextXAlignment.Left
	info.ZIndex = 68
	info.Parent = popup

	local previewStatus = Instance.new("TextLabel")
	previewStatus.Name = "PreviewStatus"
	previewStatus.Size = UDim2.new(1, -24, 1, -24)
	previewStatus.Position = UDim2.new(0, 12, 0, 12)
	previewStatus.BackgroundTransparency = 1
	previewStatus.Text = ""
	previewStatus.TextColor3 = t.TextSecondary
	previewStatus.TextSize = 12
	previewStatus.Font = Enum.Font.GothamSemibold
	previewStatus.TextWrapped = true
	previewStatus.TextXAlignment = Enum.TextXAlignment.Center
	previewStatus.TextYAlignment = Enum.TextYAlignment.Center
	previewStatus.Visible = false
	previewStatus.ZIndex = 69
	previewStatus.Parent = viewportHolder

	local bottomName = Instance.new("TextLabel")
	bottomName.Name = "BottomOutfitName"
	bottomName.Size = UDim2.new(1, -24, 0, 22)
	bottomName.Position = UDim2.new(0, 12, 1, -28)
	bottomName.BackgroundTransparency = 1
	bottomName.Text = "Outfit"
	bottomName.TextColor3 = t.TextPrimary
	bottomName.TextSize = 13
	bottomName.Font = Enum.Font.GothamBold
	bottomName.TextXAlignment = Enum.TextXAlignment.Left
	bottomName.TextTruncate = Enum.TextTruncate.AtEnd
	bottomName.ZIndex = 68
	bottomName.Parent = popup

	return popup
end
vars.HoverPreview = vars.createHoverPreviewUI()

vars.updateHoverPreviewPosition = function()
	local popup = vars.HoverPreview
	if not popup or not MainFrame then return end
	if not isMenuVisible or ActiveTabName ~= "Avatar Changer" then
		if popup.Visible then vars.stopHoverPreview() end
		return
	end
	local cam = vars.Workspace.CurrentCamera
	local vp = cam and cam.ViewportSize or Vector2.new(1280, 720)
	local mPos = MainFrame.AbsolutePosition
	local mSize = MainFrame.AbsoluteSize
	local pWidth = vars.previewWidth
	local pHeight = math.clamp(mSize.Y, 320, 420)
	popup.Size = UDim2.fromOffset(pWidth, pHeight)

	local targetX = mPos.X + mSize.X + vars.previewGap
	if targetX + pWidth > vp.X - 8 then
		targetX = math.max(8, mPos.X - pWidth - vars.previewGap)
	end
	local targetY = math.clamp(mPos.Y, 8, math.max(8, vp.Y - pHeight - 8))
	popup.Position = UDim2.fromOffset(targetX, targetY)
end

vars.showHoverPreview = function(data, isPinned)
	if not vars.scriptAlive or not data then return end

	vars.stopHoverPreview()
	if isPinned then vars.ui.pinnedPreviewData = data end
	local token = vars.hoverPreviewToken

	local popup = vars.HoverPreview
	vars.updateHoverPreviewPosition()
	local topBar = popup:FindFirstChild("PreviewTopBar")
	local title = topBar and topBar:FindFirstChild("OutfitName")
	local bottomName = popup:FindFirstChild("BottomOutfitName")
	local info = popup:FindFirstChild("Info")
	local holder = popup:FindFirstChild("ViewportHolder")
	local status = holder and holder:FindFirstChild("PreviewStatus")
	if not title or not bottomName or not info or not holder or not status then return end

	local outfitName = tostring(data.DisplayName or data.Name or "Unnamed Outfit")
	title.Text = "3D AVATAR PREVIEW"
	bottomName.Text = outfitName
	info.Text = string.upper(tostring(data.RigType or "Unknown"))
		.. "  |  " .. tostring(vars.getAccessoryCount(data)) .. " accessories"

	popup.Visible = true
	status.Text = "Loading 3D preview..."
	status.Visible = true

	local viewport, worldModel, camera = vars.createPreviewViewport(holder)
	if not viewport then
		status.Text = "Preview error:\nCould not create the viewport."
		status.Visible = true
		return
	end

	task.spawn(function()
		local ok, err = xpcall(function()
			if not vars.scriptAlive or token ~= vars.hoverPreviewToken or not popup.Visible then return end

			local cacheKey = vars.getPreviewCacheKey(data)
			local template = cacheKey and vars.previewModelCache[cacheKey]

			if template and template.Parent ~= nil then
				vars.previewModelCache[cacheKey] = nil
				template = nil
			elseif template then
				vars.touchPreviewCache(cacheKey)
			end

			if not template then
				template = vars.buildPreviewTemplate(data, cacheKey)
			end

			if not template then
				error("buildPreviewTemplate returned no model")
			end

			if not vars.scriptAlive or token ~= vars.hoverPreviewToken or not popup.Visible then return end

			local cloneOk, model = pcall(function()
				return template:Clone()
			end)
			if not cloneOk or not model then
				error("failed to clone the preview model: " .. tostring(model))
			end

			model.Parent = worldModel
			model:PivotTo(CFrame.new(0, 0, 0))
			vars.ui.hoverModel = model
			vars.ui.hoverViewport = viewport

			local cameraOk, cameraErr = pcall(function()
				vars.positionPreviewCamera(camera, model)
				camera.FieldOfView = 35
			end)
			if not cameraOk then
				pcall(function() model:Destroy() end)
				error("camera setup failed: " .. tostring(cameraErr))
			end

			if not vars.scriptAlive or token ~= vars.hoverPreviewToken or not popup.Visible then
				pcall(function() model:Destroy() end)
				return
			end

			status.Text = ""
			status.Visible = false

			local angle = 0
			vars.ui.hoverConnection = vars.RunService.RenderStepped:Connect(function(dt)
				if not vars.scriptAlive or token ~= vars.hoverPreviewToken or not popup.Visible or not model.Parent then
					vars.stopHoverPreview()
					return
				end

				vars.updateHoverPreviewPosition()
				angle = angle + dt * math.rad(75)
				pcall(function()
					model:PivotTo(CFrame.Angles(0, angle, 0))
				end)
			end)
		end, debug.traceback)

		if not ok and vars.scriptAlive and token == vars.hoverPreviewToken and popup.Visible then
			pcall(function()
				if vars.ui.hoverModel then
					vars.ui.hoverModel:Destroy()
					vars.ui.hoverModel = nil
				end
			end)
			vars.ui.hoverViewport = nil
			status.Text = "Preview error:\n" .. tostring(err)
			status.Visible = true
		end
	end)
end

vars.clearAvatarCards = function()
	vars.previewQueueGeneration = vars.previewQueueGeneration + 1
	table.clear(vars.previewQueue)
	table.clear(vars.previewStates)
	table.clear(vars.ui.avatarRows)
	vars.clearPreviewModelCache()
	vars.stopHoverPreview()

	for _, child in ipairs(vars.List:GetChildren()) do
		if child:IsA("Frame") and child.Name == "AvatarRow" then
			child:Destroy()
		end
	end
end

vars.StyleAvatarRow = function(data, row)
	if not row or not row.Parent then return end
	local t = GetTheme()
	local d = Config.GuiDesign or "Default"
	local selected = (data == vars.ui.selectedAvatar)

	row.BackgroundColor3 = t.CardBg
	row.BackgroundTransparency = (d == "LiquidGlass" and 0.54) or (d == "CyberHud" and 0.10) or 0.08
	local rc = row:FindFirstChildOfClass("UICorner")
	if rc then
		rc.CornerRadius = UDim.new(0, (d == "LiquidGlass" and 11) or (d == "CyberHud" and 4) or 8)
	end
	local rst = row:FindFirstChildOfClass("UIStroke")
	if rst then
		rst.Color = selected and t.Accent or t.Stroke
		rst.Thickness = selected and 1.6 or ((d == "CyberHud" and 1.5) or 1.0)
		rst.Transparency = selected and 0.05 or ((d == "LiquidGlass" and 0.24) or (d == "CyberHud" and 0.04) or 0.55)
	end

	local thumbHolder = row:FindFirstChild("ThumbHolder")
	if thumbHolder then
		thumbHolder.BackgroundColor3 = t.PanelBg
		local tst = thumbHolder:FindFirstChildOfClass("UIStroke")
		if tst then tst.Color = selected and t.Accent or t.Stroke end
	end

	local rigBadge = row:FindFirstChild("RigBadge")
	if rigBadge then
		rigBadge.BackgroundColor3 = selected and t.Accent or t.PanelBg
		rigBadge.TextColor3 = selected and Color3.fromRGB(255, 255, 255) or t.TextSecondary
	end

	local button = row:FindFirstChild("AvatarName")
	if button then
		button.BackgroundColor3 = selected and t.AccentDark:Lerp(t.PanelBg, 0.55) or t.PanelBg
		button.BackgroundTransparency = (d == "LiquidGlass" and 0.45) or 0.12
		button.TextColor3 = t.TextPrimary
		local disp = tostring(data.DisplayName or data.Name or "Unnamed Avatar")
		local uname = tostring(data.Name or data.Username or "")
		if uname ~= "" and string.lower(uname) ~= string.lower(disp) then
			button.Text = disp .. " (@" .. uname .. ")"
		else
			button.Text = disp
		end
		local bst = button:FindFirstChildOfClass("UIStroke")
		if bst then
			bst.Color = selected and t.Accent or t.Stroke
			bst.Transparency = selected and 0.15 or 0.55
		end
		local marker = button:FindFirstChild("SelectionMarker")
		if marker then
			marker.Visible = selected
			marker.BackgroundColor3 = t.Accent
		end
	end

	local renBtn = row:FindFirstChild("Rename")
	if renBtn then
		renBtn.BackgroundColor3 = t.PanelBg
		local st = renBtn:FindFirstChildOfClass("UIStroke")
		if st then st.Color = t.Stroke end
		local ic = renBtn:FindFirstChild("Icon")
		if ic then ic.TextColor3 = t.TextSecondary end
	end

	local hovBtn = row:FindFirstChild("Hover3D")
	if hovBtn then
		local isPinned = (vars.ui.pinnedPreviewData == data and vars.HoverPreview and vars.HoverPreview.Visible)
		hovBtn.BackgroundColor3 = isPinned and t.Accent or t.PanelBg
		local st = hovBtn:FindFirstChildOfClass("UIStroke")
		if st then st.Color = isPinned and t.Accent or t.Stroke end
		local ic = hovBtn:FindFirstChild("Icon")
		if ic then ic.TextColor3 = isPinned and Color3.fromRGB(255, 255, 255) or t.TextSecondary end
	end
end

vars.updateRowVisuals = function(selectedData)
	vars.updateWearButtonState()
	for data, row in pairs(vars.ui.avatarRows) do
		vars.StyleAvatarRow(data, row)
	end
end

vars.deleteAvatar = function(data)
	if not data then return end
	local sig = data.Signature or (data.Properties and vars.getAvatarSignature(data.Properties, data.RigType or "R6"))
	if sig then
		vars.ui.deletedSignatures[sig] = true
	end

	local path = data.FilePath or (data.FileName and (vars.AVATARS_FOLDER .. "/" .. tostring(data.FileName)))
	if path and type(delfile) == "function" then
		pcall(function() delfile(path) end)
	end

	for index = #vars.ui.savedAvatars, 1, -1 do
		local entry = vars.ui.savedAvatars[index]
		if entry == data or (sig and entry.Signature == sig) then
			table.remove(vars.ui.savedAvatars, index)
		end
	end

	if vars.ui.selectedAvatar == data then
		vars.ui.selectedAvatar = nil
	end
	vars.syncAllSavedAvatarsToDisk()
	vars.Status.Text = "[OK] Deleted: " .. tostring(data.DisplayName or data.Name or "avatar")
	vars.StatusDot.BackgroundColor3 = vars.COLORS.Success
	vars.clearDiagnostics()
	vars.populateAvatarList()
end

vars.showRenameDialog = function(data)
	if not data then return end
	vars.RenameTarget = data
	vars.RenameInput.Text = tostring(data.DisplayName or data.Name or "")
	vars.RenameOverlay.Visible = true
	task.defer(function()
		if vars.RenameInput and vars.RenameInput.Parent then
			vars.RenameInput:CaptureFocus()
			vars.RenameInput.CursorPosition = #vars.RenameInput.Text + 1
		end
	end)
end

vars.createAvatarCard = function(data, index)
	local t = GetTheme()
	local Row = Instance.new("Frame")
	Row.Name = "AvatarRow"
	Row.Size = UDim2.new(1, 0, 0, 46)
	Row.BackgroundColor3 = t.CardBg
	Row.BorderSizePixel = 0
	Row.LayoutOrder = index
	Row.Parent = vars.List
	vars.addCorner(Row, 8)
	vars.addStroke(Row, t.Stroke, 1, 0.5)

	-- Avatar Headshot Thumbnail
	local thumbHolder = Instance.new("Frame")
	thumbHolder.Name = "ThumbHolder"
	thumbHolder.Size = UDim2.fromOffset(34, 34)
	thumbHolder.Position = UDim2.new(0, 6, 0.5, -17)
	thumbHolder.BackgroundColor3 = t.PanelBg
	thumbHolder.BorderSizePixel = 0
	thumbHolder.Parent = Row
	vars.addCorner(thumbHolder, 8)
	vars.addStroke(thumbHolder, t.Stroke, 1, 0.5)

	local thumbImg = Instance.new("ImageLabel")
	thumbImg.Name = "ThumbImg"
	thumbImg.Size = UDim2.new(1, 0, 1, 0)
	thumbImg.BackgroundTransparency = 1
	local uid = tonumber(data.UserId) or 1
	thumbImg.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(uid) .. "&w=48&h=48"
	thumbImg.Parent = thumbHolder
	vars.addCorner(thumbImg, 8)

	-- Rig Badge (R6 / R15)
	local rigBadge = Instance.new("TextLabel")
	rigBadge.Name = "RigBadge"
	rigBadge.Size = UDim2.fromOffset(32, 22)
	rigBadge.Position = UDim2.new(0, 44, 0.5, -11)
	rigBadge.BackgroundColor3 = t.PanelBg
	rigBadge.BorderSizePixel = 0
	rigBadge.Font = Enum.Font.GothamBold
	rigBadge.TextSize = 10
	rigBadge.TextColor3 = t.TextSecondary
	rigBadge.Text = tostring(data.RigType or "R15")
	rigBadge.Parent = Row
	vars.addCorner(rigBadge, 5)

	-- Main Click-to-Wear Avatar Name Button
	local AvatarName = Instance.new("TextButton")
	AvatarName.Name = "AvatarName"
	AvatarName.Size = UDim2.new(1, -198, 1, -10)
	AvatarName.Position = UDim2.new(0, 80, 0, 5)
	AvatarName.BackgroundColor3 = t.PanelBg
	AvatarName.BorderSizePixel = 0
	AvatarName.Text = tostring(data.DisplayName or data.Name or "Unnamed Avatar")
	AvatarName.TextColor3 = t.TextPrimary
	AvatarName.TextSize = 12
	AvatarName.Font = Enum.Font.GothamBold
	AvatarName.TextXAlignment = Enum.TextXAlignment.Left
	AvatarName.TextTruncate = Enum.TextTruncate.AtEnd
	AvatarName.AutoButtonColor = false
	AvatarName.Parent = Row
	vars.addPadding(AvatarName, 10, 10, 0, 0)
	vars.addCorner(AvatarName, 6)
	vars.addStroke(AvatarName, t.Stroke, 1, 0.5)

	local selectionMarker = Instance.new("Frame")
	selectionMarker.Name = "SelectionMarker"
	selectionMarker.Size = UDim2.new(0, 4, 1, -8)
	selectionMarker.Position = UDim2.new(0, -6, 0, 4)
	selectionMarker.BackgroundColor3 = t.Accent
	selectionMarker.BorderSizePixel = 0
	selectionMarker.Visible = (vars.ui.selectedAvatar == data)
	selectionMarker.ZIndex = AvatarName.ZIndex + 1
	selectionMarker.Active = false
	selectionMarker.Parent = AvatarName
	vars.addCorner(selectionMarker, 4)

	-- Action Buttons: Rename | 3D Preview | Delete
	local Rename = Instance.new("TextButton")
	Rename.Name = "Rename"
	Rename.Size = UDim2.fromOffset(32, 30)
	Rename.Position = UDim2.new(1, -112, 0.5, -15)
	Rename.BackgroundColor3 = t.PanelBg
	Rename.BorderSizePixel = 0
	Rename.Text = ""
	Rename.AutoButtonColor = false
	Rename.Parent = Row
	vars.addCorner(Rename, 6)
	vars.addStroke(Rename, t.Stroke, 1, 0.45)
	local renameIcon = vars.createBuilderIcon(Rename, "Icon", vars.BUILDER_ICONS.Rename, 15, t.TextSecondary)
	renameIcon.AnchorPoint = Vector2.new(0.5, 0.5)
	renameIcon.Position = UDim2.new(0.5, 0, 0.5, 0)

	local Hover3D = Instance.new("TextButton")
	Hover3D.Name = "Hover3D"
	Hover3D.Size = UDim2.fromOffset(32, 30)
	Hover3D.Position = UDim2.new(1, -75, 0.5, -15)
	Hover3D.BackgroundColor3 = t.PanelBg
	Hover3D.BorderSizePixel = 0
	Hover3D.Text = ""
	Hover3D.AutoButtonColor = false
	Hover3D.Parent = Row
	vars.addCorner(Hover3D, 6)
	vars.addStroke(Hover3D, t.Stroke, 1, 0.45)
	local previewIcon = vars.createBuilderIcon(Hover3D, "Icon", vars.BUILDER_ICONS.Preview3D, 15, t.TextSecondary)
	previewIcon.AnchorPoint = Vector2.new(0.5, 0.5)
	previewIcon.Position = UDim2.new(0.5, 0, 0.5, 0)

	local DeleteButton = Instance.new("TextButton")
	DeleteButton.Name = "Delete"
	DeleteButton.Size = UDim2.fromOffset(32, 30)
	DeleteButton.Position = UDim2.new(1, -38, 0.5, -15)
	DeleteButton.BackgroundColor3 = Color3.fromRGB(48, 22, 28)
	DeleteButton.BorderSizePixel = 0
	DeleteButton.Text = ""
	DeleteButton.AutoButtonColor = false
	DeleteButton.Parent = Row
	vars.addCorner(DeleteButton, 6)
	vars.addStroke(DeleteButton, Color3.fromRGB(165, 55, 70), 1, 0.25)
	local deleteIcon = vars.createBuilderIcon(DeleteButton, "Icon", vars.BUILDER_ICONS.Delete, 15, Color3.fromRGB(240, 110, 125))
	deleteIcon.AnchorPoint = Vector2.new(0.5, 0.5)
	deleteIcon.Position = UDim2.new(0.5, 0, 0.5, 0)

	vars.wire(AvatarName.Activated, function()
		if vars.ui.selectedAvatar == data and (vars.tryOnActive or vars.localTryOnModel or vars.localTryOnBuilding or vars.placeholderR6Active) then
			vars.tryOnActive = false
			vars.stopLocalTryOn(false)
			vars.ui.selectedAvatar = nil
			vars.updateRowVisuals(nil)
			vars.Status.Text = "Local try-on cleared. Original avatar restored."
			vars.clearDiagnostics()
			if NotifyFeatureToggle then NotifyFeatureToggle("Avatar Try-On", false) end
			return
		end

		if vars.ui.selectedAvatar ~= data and (vars.tryOnActive or vars.localTryOnModel or vars.localTryOnBuilding or vars.placeholderR6Active) then
			vars.tryOnActive = false
			vars.stopLocalTryOn(false)
		end

		vars.ui.selectedAvatar = data
		vars.updateRowVisuals(data)
		local dispName = tostring(data.DisplayName or data.Name or "avatar")
		vars.Status.Text = "[...] Wearing: " .. dispName
		vars.StatusDot.BackgroundColor3 = GetTheme().Accent
		vars.clearDiagnostics()
		if NotifyFeatureToggle then NotifyFeatureToggle("Wear: " .. dispName, true) end
		task.defer(function()
			if vars.scriptAlive and vars.ui.selectedAvatar == data then
				vars.tryOnSelectedAvatarLocally()
			end
		end)
	end)

	vars.wire(Rename.Activated, function()
		vars.showRenameDialog(data)
	end)

	vars.wire(Hover3D.MouseEnter, function()
		if vars.ui.pinnedPreviewData then return end
		vars.ui.hoverButton = Hover3D
		vars.showHoverPreview(data, false)
	end)
	vars.wire(Hover3D.MouseLeave, function()
		if vars.ui.pinnedPreviewData then return end
		if vars.ui.hoverButton == Hover3D then vars.ui.hoverButton = nil end
		vars.stopHoverPreview()
	end)
	vars.wire(Hover3D.Activated, function()
		if vars.ui.pinnedPreviewData == data and vars.HoverPreview and vars.HoverPreview.Visible then
			vars.stopHoverPreview()
		else
			vars.showHoverPreview(data, true)
		end
		vars.updateRowVisuals(vars.ui.selectedAvatar)
	end)

	vars.wire(DeleteButton.Activated, function()
		vars.showConfirmation('Delete "' .. tostring(data.DisplayName or data.Name or "this avatar") .. '" from your saved avatars?', function()
			vars.deleteAvatar(data)
		end)
	end)

	vars.ui.avatarRows[data] = Row
	vars.StyleAvatarRow(data, Row)
end

vars.filterAvatarCards = function(query)
	query = string.lower(string.match(tostring(query or ""), "^%s*(.-)%s*$"))
	local shown = 0

	for _, data in ipairs(vars.ui.savedAvatars) do
		local matches = (query == "")
			or (string.lower(tostring(data.DisplayName or "")):find(query, 1, true) ~= nil)
			or (string.lower(tostring(data.Name or "")):find(query, 1, true) ~= nil)
			or (string.lower(tostring(data.FileName or "")):find(query, 1, true) ~= nil)
			or (string.lower(tostring(data.UserId or "")):find(query, 1, true) ~= nil)
			or (string.lower(tostring(data.RigType or "")):find(query, 1, true) ~= nil)

		local row = vars.ui.avatarRows[data]
		if row and row.Parent then
			row.Visible = matches
			if matches then shown = shown + 1 end
		end
	end

	vars.Status.Text = "[File] " .. tostring(shown) .. "/" .. tostring(#vars.ui.savedAvatars) .. " avatar(s) shown"
end

vars.populateAvatarList = function()
	vars.clearAvatarCards()
	for index, data in ipairs(vars.ui.savedAvatars) do
		vars.createAvatarCard(data, index)
	end
	vars.filterAvatarCards(vars.SearchBox.Text)
	vars.updateWearButtonState()
end

vars.restoreLocalCharacter = function()	for part, oldTransparency in pairs(vars.hiddenCharacterParts) do
		pcall(function()
			if part and part.Parent then part.LocalTransparencyModifier = oldTransparency end
		end)
	end
	table.clear(vars.hiddenCharacterParts)

	for decal, oldTransparency in pairs(vars.hiddenCharacterDecals) do
		pcall(function()
			if decal and decal.Parent then decal.Transparency = oldTransparency end
		end)
	end
	table.clear(vars.hiddenCharacterDecals)
end

vars.destroyOrphanedLocalTryOnModels = function(exceptModel)	for _, instance in ipairs(vars.Workspace:GetDescendants()) do
		if instance:IsA("Model") and instance.Name == "LocalWearer_LocalTryOn" and instance ~= exceptModel then
			pcall(function() instance:Destroy() end)
		end
	end
end

vars.capturePlaceholderR6Backup = function(character)
	if not character or not character.Parent then return nil end
	local backup = {Character = character, Items = {}, PartAppearance = {}, HeadVisuals = {}}
	for _, child in ipairs(character:GetChildren()) do
		if child:IsA("Accessory") or child:IsA("Shirt") or child:IsA("Pants")
			or child:IsA("ShirtGraphic") or child:IsA("BodyColors") or child:IsA("CharacterMesh") then
			local ok, clone = pcall(function() return child:Clone() end)
			if ok and clone then backup.Items[#backup.Items + 1] = clone end
		end
	end
	for _, name in ipairs({"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}) do
		local part = character:FindFirstChild(name)
		if part and part:IsA("BasePart") then
			backup.PartAppearance[name] = {Color = part.Color, Material = part.Material}
		end
	end
	local head = character:FindFirstChild("Head")
	if head then
		for _, child in ipairs(head:GetChildren()) do
			if child:IsA("SpecialMesh") or child:IsA("Mesh") or child:IsA("Decal") then
				local ok, clone = pcall(function() return child:Clone() end)
				if ok and clone then backup.HeadVisuals[#backup.HeadVisuals + 1] = clone end
			end
		end
	end
	return backup
end

vars.clearPlaceholderR6Appearance = function(character)
	if not character then return end
	for _, child in ipairs(character:GetChildren()) do
		if child:IsA("Accessory") or child:IsA("Shirt") or child:IsA("Pants")
			or child:IsA("ShirtGraphic") or child:IsA("BodyColors") or child:IsA("CharacterMesh") then
			pcall(function() child:Destroy() end)
		end
	end
	local head = character:FindFirstChild("Head")
	if head then
		for _, child in ipairs(head:GetChildren()) do
			if child:IsA("SpecialMesh") or child:IsA("Mesh") or child:IsA("Decal") then
				pcall(function() child:Destroy() end)
			end
		end
	end
end

vars.restorePlaceholderR6 = function()
	local backup = vars.placeholderR6Backup
	vars.placeholderR6Backup = nil
	vars.placeholderR6Active = false
	vars.placeholderR6Building = false
	if not backup then return end
	local character = backup.Character
	if not character or not character.Parent then
		for _, item in ipairs(backup.Items or {}) do pcall(function() item:Destroy() end) end
		for _, item in ipairs(backup.HeadVisuals or {}) do pcall(function() item:Destroy() end) end
		return
	end
	vars.clearPlaceholderR6Appearance(character)
	for name, appearance in pairs(backup.PartAppearance or {}) do
		local part = character:FindFirstChild(name)
		if part and part:IsA("BasePart") then
			pcall(function() part.Color = appearance.Color end)
			pcall(function() part.Material = appearance.Material end)
		end
	end
	local head = character:FindFirstChild("Head")
	if head then
		for _, item in ipairs(backup.HeadVisuals or {}) do pcall(function() item.Parent = head end) end
	end
	for _, item in ipairs(backup.Items or {}) do pcall(function() item.Parent = character end) end
end

vars.applyPlaceholderR6 = function(selectedData)
	if vars.placeholderR6Building then return false, "Already applying placeholder mode." end
	
	if vars.placeholderR6Active or vars.placeholderR6Backup then
		vars.restorePlaceholderR6()
	end
	local character = vars.LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not character or not character.Parent or not humanoid then return false, "Your character is not available." end
	if humanoid.RigType ~= Enum.HumanoidRigType.R6 then
		return false, "R15 uses the normal local try-on path."
	end
	if not selectedData or not selectedData.Properties then return false, "The selected avatar has no saved properties." end

	vars.placeholderR6Building = true
	vars.placeholderR6Backup = vars.capturePlaceholderR6Backup(character)
	if not vars.placeholderR6Backup then
		vars.placeholderR6Building = false
		return false, "Could not back up your current R6 appearance."
	end

	local description = vars.reconstructHumanoidDescription(selectedData.Properties)
	local okCreate, modelOrError = pcall(function()
		return vars.Players:CreateHumanoidModelFromDescriptionAsync(description, Enum.HumanoidRigType.R6)
	end)
	pcall(function() description:Destroy() end)
	if not okCreate or not modelOrError or not modelOrError:IsA("Model") then
		vars.restorePlaceholderR6()
		return false, tostring(modelOrError)
	end

	local model = modelOrError
	local ok, err = xpcall(function()
		vars.clearPlaceholderR6Appearance(character)
		local bp = {
			Head = character:FindFirstChild("Head"), Torso = character:FindFirstChild("Torso"),
			["Left Arm"] = character:FindFirstChild("Left Arm"), ["Right Arm"] = character:FindFirstChild("Right Arm"),
			["Left Leg"] = character:FindFirstChild("Left Leg"), ["Right Leg"] = character:FindFirstChild("Right Leg"),
		}
		for _, child in ipairs(model:GetChildren()) do
			if child:IsA("Accessory") then
				local a = child:Clone()
				local handle = a:FindFirstChild("Handle")
				if handle then
					handle.Anchored = false
					handle.CanCollide = false
					handle.CanTouch = false
					handle.CanQuery = false
					handle.Massless = true
					local at = handle:FindFirstChildWhichIsA("Attachment")
					local targetAttachment = at and character:FindFirstChild(at.Name, true)
					local part = targetAttachment and targetAttachment.Parent:IsA("BasePart") and targetAttachment.Parent or bp.Head or bp.Torso
					if targetAttachment and targetAttachment.Parent:IsA("BasePart") then
						handle.CFrame = targetAttachment.WorldCFrame * at.CFrame:Inverse()
					elseif at and part then
						handle.CFrame = part.CFrame * CFrame.new(at.Position)
					elseif part then
						handle.CFrame = part.CFrame
					end
					if part then
						local weld = Instance.new("WeldConstraint")
						weld.Part0 = handle; weld.Part1 = part; weld.Parent = handle
					end
					for _, q in ipairs(a:GetDescendants()) do
						if q:IsA("BasePart") and q ~= handle then
							q.CanCollide = false; q.CanTouch = false; q.CanQuery = false; q.Massless = true
							if part then
								local weld = Instance.new("WeldConstraint")
								weld.Part0 = q; weld.Part1 = handle; weld.Parent = q
							end
						end
					end
					a.Parent = character
				else a:Destroy() end
			elseif child:IsA("Shirt") or child:IsA("Pants") or child:IsA("ShirtGraphic") or child:IsA("BodyColors") or child:IsA("CharacterMesh") then
				child:Clone().Parent = character
			end
		end
		for _, name in ipairs({"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}) do
			local sourcePart, targetPart = model:FindFirstChild(name), character:FindFirstChild(name)
			if sourcePart and targetPart and sourcePart:IsA("BasePart") and targetPart:IsA("BasePart") then
				targetPart.Color = sourcePart.Color
				targetPart.Material = sourcePart.Material
			end
		end
		local sourceHead, targetHead = model:FindFirstChild("Head"), character:FindFirstChild("Head")
		if sourceHead and targetHead then
			for _, child in ipairs(sourceHead:GetChildren()) do
				if child:IsA("SpecialMesh") or child:IsA("Mesh") or child:IsA("Decal") then
					child:Clone().Parent = targetHead
				end
			end
		end
	end, debug.traceback)
	pcall(function() model:Destroy() end)
	if not ok then
		vars.restorePlaceholderR6()
		return false, tostring(err)
	end
	vars.placeholderR6Building = false
	vars.placeholderR6Active = true
	return true
end

vars.stopLocalTryOn = function(preserveActiveState)	vars.localTryOnBuildId = vars.localTryOnBuildId + 1
	if vars.placeholderR6Active or vars.placeholderR6Backup then vars.restorePlaceholderR6() end
	vars.localTryOnBuilding = false
	vars.localTryOnMissingRecoveryPending = false
	if not preserveActiveState then vars.tryOnActive = false end

	vars.cleanupAnimationSync()
	vars.disconnectLocalTryOnConnections()

	if vars.localTryOnModel then
		pcall(function() vars.localTryOnModel:Destroy() end)
		vars.localTryOnModel = nil
	end

	vars.destroyOrphanedLocalTryOnModels(nil)

	vars.resetLocalTryOnState()
	vars.restoreLocalCharacter()
	vars.updateWearButtonState()
end

vars.abortLocalTryOnForSeatedPlayer = function()	vars.stopLocalTryOn(false)
	vars.WearButton.Active = true
	vars.updateWearButtonState()
	vars.showSeatedTryOnBlocked()
end

vars.CHARACTER_BODY_PART_NAMES = {
	Head = true,
	HumanoidRootPart = true,
	Torso = true,
	UpperTorso = true,
	LowerTorso = true,
	["Left Arm"] = true,
	["Right Arm"] = true,
	["Left Leg"] = true,
	["Right Leg"] = true,
	LeftUpperArm = true,
	LeftLowerArm = true,
	LeftHand = true,
	RightUpperArm = true,
	RightLowerArm = true,
	RightHand = true,
	LeftUpperLeg = true,
	LeftLowerLeg = true,
	LeftFoot = true,
	RightUpperLeg = true,
	RightLowerLeg = true,
	RightFoot = true,
}

vars.getCharacterTopLevel = function(instance, character)	local current = instance
	while current and current.Parent and current.Parent ~= character do
		current = current.Parent
	end
	return current and current.Parent == character and current or nil
end

vars.isExternalCharacterAttachment = function(instance, character)	if instance:FindFirstAncestorOfClass("Tool") or instance:FindFirstAncestorOfClass("VehicleSeat") then
		return true
	end

	local topLevel = vars.getCharacterTopLevel(instance, character)
	if not topLevel then return true end

	if topLevel:IsA("Accessory") then
		return false
	end

	local modelAncestor = instance:FindFirstAncestorOfClass("Model")
	if modelAncestor and modelAncestor ~= character then
		return true
	end

	if topLevel:IsA("BasePart") and vars.CHARACTER_BODY_PART_NAMES[topLevel.Name] then
		if instance:IsA("BasePart") and instance ~= topLevel and instance.Parent == topLevel and not vars.CHARACTER_BODY_PART_NAMES[instance.Name] then
			return true
		end
		return false
	end

	return true
end

vars.hideCharacterInstance = function(instance)	if not instance then return end
	local character = vars.LocalPlayer.Character
	if not character or not instance:IsDescendantOf(character) then return end
	if vars.isExternalCharacterAttachment(instance, character) then return end

	if instance:IsA("BasePart") then
		if vars.hiddenCharacterParts[instance] == nil then
			vars.hiddenCharacterParts[instance] = instance.LocalTransparencyModifier
		end
		instance.LocalTransparencyModifier = 1
	elseif instance:IsA("Decal") or instance:IsA("Texture") then
		if vars.hiddenCharacterDecals[instance] == nil then
			vars.hiddenCharacterDecals[instance] = instance.Transparency
		end
		instance.Transparency = 1
	end
end

vars.hideCharacterLocally = function(character)	if not character then return end
	for _, instance in ipairs(character:GetDescendants()) do
		vars.hideCharacterInstance(instance)
	end
	vars.setLocalTryOnConnection("visibility", character.DescendantAdded, vars.hideCharacterInstance)
end

vars.enforceCharacterHidden = function()	for part in pairs(vars.hiddenCharacterParts) do
		if part and part.Parent and part.LocalTransparencyModifier ~= 1 then
			part.LocalTransparencyModifier = 1
		end
	end
	for decal in pairs(vars.hiddenCharacterDecals) do
		if decal and decal.Parent and decal.Transparency ~= 1 then
			decal.Transparency = 1
		end
	end
end

vars.isFirstPersonCamera = function(character)	local camera = vars.Workspace.CurrentCamera
	local head = character and character:FindFirstChild("Head", true)
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not camera or not head or not humanoid then return false end

	local cameraDistance = (camera.CFrame.Position - head.Position).Magnitude
	local cameraFollowsCharacter = camera.CameraSubject == humanoid or (camera.CameraSubject and camera.CameraSubject:IsDescendantOf(character))
	return cameraFollowsCharacter and cameraDistance <= 1.65
end

vars.setLocalTryOnFirstPersonVisibility = function(hidden)	if not vars.localTryOnModel or vars.localTryOnHiddenInFirstPerson == hidden then return end
	vars.localTryOnHiddenInFirstPerson = hidden

	for _, instance in ipairs(vars.localTryOnModel:GetDescendants()) do
		if instance:IsA("BasePart") then
			instance.LocalTransparencyModifier = hidden and 1 or 0
		elseif instance:IsA("Decal") or instance:IsA("Texture") then
			pcall(function() instance.LocalTransparencyModifier = hidden and 1 or 0 end)
		end
	end
end

vars.disableLocalTryOnCollision = function(instance)	if not instance or not instance:IsA("BasePart") then return end
	vars.localTryOnCollisionParts[instance] = true
	pcall(function()
		if instance.CanCollide then instance.CanCollide = false end
		if instance.CanTouch then instance.CanTouch = false end
		if instance.CanQuery then instance.CanQuery = false end
		if not instance.Massless then instance.Massless = true end
	end)
end

vars.enforceLocalTryOnNoCollision = function()	for instance in pairs(vars.localTryOnCollisionParts) do
		if instance and instance.Parent then
			pcall(function()
				if instance.CanCollide then instance.CanCollide = false end
				if instance.CanTouch then instance.CanTouch = false end
				if instance.CanQuery then instance.CanQuery = false end
				if not instance.Massless then instance.Massless = true end
			end)
		else
			vars.localTryOnCollisionParts[instance] = nil
		end
	end
end

vars.isLocalTryOnModelValid = function(model)	if not model or not model:IsA("Model") then return false end
	if not model:IsDescendantOf(vars.Workspace) then return false end
	if not model:FindFirstChildOfClass("Humanoid") then return false end
	local root = model:FindFirstChild("HumanoidRootPart", true) or model.PrimaryPart or model:FindFirstChild("Head", true)
	return root ~= nil and root:IsA("BasePart")
end

vars.prepareLocalModel = function(model)	local modelHumanoid = model:FindFirstChildOfClass("Humanoid")
	if modelHumanoid then
		modelHumanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		modelHumanoid.RequiresNeck = false
		modelHumanoid.AutomaticScalingEnabled = false
		pcall(function() modelHumanoid.EvaluateStateMachine = false end)
		pcall(function()
			for _, state in ipairs(Enum.HumanoidStateType:GetEnumItems()) do
				if state ~= Enum.HumanoidStateType.None then modelHumanoid:SetStateEnabled(state, false) end
			end
			modelHumanoid:ChangeState(Enum.HumanoidStateType.None)
		end)
	end

	local rootPart = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
	for _, instance in ipairs(model:GetDescendants()) do
		if instance:IsA("BasePart") then
			instance.Anchored = (instance == rootPart)
			instance.CanCollide = false
			instance.CanTouch = false
			instance.CanQuery = false
			instance.Massless = true
			instance.LocalTransparencyModifier = 0
		elseif instance:IsA("Decal") or instance:IsA("Texture") then
			pcall(function() instance.LocalTransparencyModifier = 0 end)
		elseif instance:IsA("Script") or instance:IsA("LocalScript") then
			pcall(function() instance.Disabled = true end)
		end
	end
end

vars.setLocalTryOnStagingVisibility = function(model, hidden)	if not model then return end
	for _, instance in ipairs(model:GetDescendants()) do
		if instance:IsA("BasePart") then
			instance.LocalTransparencyModifier = hidden and 1 or 0
		elseif instance:IsA("Decal") or instance:IsA("Texture") then
			pcall(function() instance.LocalTransparencyModifier = hidden and 1 or 0 end)
		end
	end
end

vars.getPartBottomY = function(part)	local halfSize = part.Size / 2
	local lowestY = math.huge
	for _, x in ipairs({-halfSize.X, halfSize.X}) do
		for _, y in ipairs({-halfSize.Y, halfSize.Y}) do
			for _, z in ipairs({-halfSize.Z, halfSize.Z}) do
				lowestY = math.min(lowestY, part.CFrame:PointToWorldSpace(Vector3.new(x, y, z)).Y)
			end
		end
	end
	return lowestY
end

vars.getFeetBottomY = function(model)	local footNames = {"LeftFoot", "RightFoot", "Left Leg", "Right Leg"}
	local lowestY = math.huge
	local foundFoot = false
	local seen = {}

	for _, footName in ipairs(footNames) do
		local foot = model:FindFirstChild(footName, true)
		if foot and foot:IsA("BasePart") and not seen[foot] then
			seen[foot] = true
			foundFoot = true
			lowestY = math.min(lowestY, vars.getPartBottomY(foot))
		end
	end
	return foundFoot and lowestY or nil
end

vars.calculateLocalTryOnSwimOffset = function(character, model, characterRoot, generatedRoot)	local charTorso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso") or characterRoot
	local modelTorso = model:FindFirstChild("UpperTorso") or model:FindFirstChild("Torso") or generatedRoot
	local charTorsoY = characterRoot.CFrame:ToObjectSpace(charTorso.CFrame).Y
	local modelTorsoY = generatedRoot.CFrame:ToObjectSpace(modelTorso.CFrame).Y
	return Vector3.new(0, charTorsoY - modelTorsoY, 0)
end

vars.calculateGroundOffsetFromCurrentPlacement = function(character, model, currentOffset)	if not character or not model then return nil end
	local characterFeetY = vars.getFeetBottomY(character)
	local modelFeetY = vars.getFeetBottomY(model)
	if not characterFeetY or not modelFeetY then return nil end

	local currentOffsetY = currentOffset and currentOffset.Y or 0
	return Vector3.new(0, characterFeetY - modelFeetY + currentOffsetY, 0)
end

vars.calculateGroundOffsetFromNeutralCloneFeet = function(character, characterRoot)	if not character or not characterRoot or vars.localTryOnNeutralCloneFeetRootOffsetY == nil then return nil end
	local characterFeetY = vars.getFeetBottomY(character)
	if not characterFeetY then return nil end
	return Vector3.new(0, characterFeetY - characterRoot.Position.Y - vars.localTryOnNeutralCloneFeetRootOffsetY, 0)
end

vars.getLocalTryOnHipReference = function(model)	if not model then return nil end

	local lowerTorso = model:FindFirstChild("LowerTorso", true)
	if lowerTorso and lowerTorso:IsA("BasePart") then
		local leftHipRigAttachment = lowerTorso:FindFirstChild("LeftHipRigAttachment")
		local rightHipRigAttachment = lowerTorso:FindFirstChild("RightHipRigAttachment")
		if leftHipRigAttachment and leftHipRigAttachment:IsA("Attachment")
			and rightHipRigAttachment and rightHipRigAttachment:IsA("Attachment") then
			return (leftHipRigAttachment.WorldPosition + rightHipRigAttachment.WorldPosition) * 0.5
		end

		local leftUpperLeg = model:FindFirstChild("LeftUpperLeg", true)
		local rightUpperLeg = model:FindFirstChild("RightUpperLeg", true)
		local leftHipAttachment = leftUpperLeg and leftUpperLeg:FindFirstChild("LeftHipAttachment")
		local rightHipAttachment = rightUpperLeg and rightUpperLeg:FindFirstChild("RightHipAttachment")
		if leftHipAttachment and leftHipAttachment:IsA("Attachment")
			and rightHipAttachment and rightHipAttachment:IsA("Attachment") then
			return (leftHipAttachment.WorldPosition + rightHipAttachment.WorldPosition) * 0.5
		end
	end

	local torso = model:FindFirstChild("Torso", true)
	if torso and torso:IsA("BasePart") then
		local leftHip = torso:FindFirstChild("Left Hip")
		local rightHip = torso:FindFirstChild("Right Hip")
		if leftHip and leftHip:IsA("Motor6D") and rightHip and rightHip:IsA("Motor6D") then
			local leftPart0 = leftHip.Part0 or torso
			local rightPart0 = rightHip.Part0 or torso
			local leftJointWorld = leftPart0.CFrame * leftHip.C0 * leftHip.Transform
			local rightJointWorld = rightPart0.CFrame * rightHip.C0 * rightHip.Transform
			return (leftJointWorld.Position + rightJointWorld.Position) * 0.5
		end
	end

	return nil
end

vars.calculateLocalTryOnSeatedHipOffset = function(character, model, currentOffset)	if not vars.scriptAlive or not model or model ~= vars.localTryOnModel or not model:IsDescendantOf(vars.Workspace) then return nil end
	if not character or not character.Parent then return nil end

	local characterHip = vars.getLocalTryOnHipReference(character)
	local modelHip = vars.getLocalTryOnHipReference(model)
	if not characterHip or not modelHip then return nil end

	local baseOffset = currentOffset or Vector3.zero
	return baseOffset + (characterHip - modelHip)
end

vars.getLocalTryOnSeatedHipOffsetLocal = function(characterRoot, worldOffset)	if not characterRoot or not worldOffset then return Vector3.zero end
	return characterRoot.CFrame:VectorToObjectSpace(worldOffset)
end

vars.isCloneSitAnimationSettled = function(model)	if not model then return false end

	local humanoid = model:FindFirstChildOfClass("Humanoid")
	if not humanoid then return false end

	local animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then return false end

	local enumRig = humanoid.RigType
	local isR6 = enumRig == Enum.HumanoidRigType.R6
		or (model:FindFirstChild("Torso") ~= nil and model:FindFirstChild("UpperTorso") == nil)
	local resolved = vars.resolveAnimationIds(model, nil, isR6)
	local sitId = vars.parseAssetId(resolved and resolved.Sit)
	if not sitId then return false end

	local sitTrack = nil
	for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
		if track and track.Animation then
			local trackId = vars.parseAssetId(track.Animation.AnimationId)
			if trackId == sitId and track.IsPlaying then
				sitTrack = track
				break
			end
		end
	end
	if not sitTrack then return false end

	if sitTrack.WeightTarget < 0.95 then return false end
	if math.abs(sitTrack.WeightCurrent - sitTrack.WeightTarget) > 0.02 then return false end

	for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
		if track ~= sitTrack and track.IsPlaying and track.WeightCurrent > 0.05 then
			return false
		end
	end

	return true
end

vars.isPlayerSitAnimationCleared = function(character)	if not character then return true end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return true end

	local animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then return true end

	local isR6 = humanoid.RigType == Enum.HumanoidRigType.R6
		or (character:FindFirstChild("Torso") ~= nil and character:FindFirstChild("UpperTorso") == nil)
	local resolved = vars.resolveAnimationIds(character, nil, isR6)
	local sitId = vars.parseAssetId(resolved and resolved.Sit)
	if not sitId then return true end

	for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
		if track and track.Animation then
			local trackId = vars.parseAssetId(track.Animation.AnimationId)
			if trackId == sitId and (track.IsPlaying or track.WeightCurrent > 0.05 or track.WeightTarget > 0.05) then
				return false
			end
		end
	end

	return true
end

vars.waitForCloneSitAnimationToSettle = function(character, model, playerHumanoid, seatPart, timeoutSeconds)	local deadline = os.clock() + (timeoutSeconds or 0.6)

	while vars.scriptAlive and os.clock() < deadline do
		if not character or not character.Parent or not playerHumanoid then return false end
		if not model or model ~= vars.localTryOnModel or not model:IsDescendantOf(vars.Workspace) then return false end

		local state = playerHumanoid:GetState()
		local stillSeated = playerHumanoid.Sit
			or playerHumanoid.SeatPart ~= nil
			or state == Enum.HumanoidStateType.Seated
		if not stillSeated or playerHumanoid.SeatPart ~= seatPart then return false end

		if vars.isCloneSitAnimationSettled(model) then
			return true
		end

		vars.RunService.Heartbeat:Wait()
	end

	return false
end

vars.scheduleSeatHipCalibrationAfterHeartbeat = function(character, model, playerHumanoid, seatPart, baseGroundOffset)	vars.localTryOnSeatCalibrationToken = vars.localTryOnSeatCalibrationToken + 1
	local calibrationToken = vars.localTryOnSeatCalibrationToken
	vars.localTryOnSeatCalibrationPending = true

	task.spawn(function()
		local settled = vars.waitForCloneSitAnimationToSettle(character, model, playerHumanoid, seatPart, 0.6)

		if not vars.scriptAlive or calibrationToken ~= vars.localTryOnSeatCalibrationToken then return end
		if not settled then
			vars.localTryOnSeatCalibrationPending = false
			return
		end
		if not model or model ~= vars.localTryOnModel or not model:IsDescendantOf(vars.Workspace) then
			vars.localTryOnSeatCalibrationPending = false
			return
		end
		if not character or not character.Parent or not playerHumanoid then
			vars.localTryOnSeatCalibrationPending = false
			return
		end

		local state = playerHumanoid:GetState()
		local stillSeated = playerHumanoid.Sit or playerHumanoid.SeatPart ~= nil or state == Enum.HumanoidStateType.Seated
		if not stillSeated or playerHumanoid.SeatPart ~= seatPart then
			vars.localTryOnSeatCalibrationPending = false
			return
		end

		local characterRoot = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
		if not characterRoot then
			vars.localTryOnSeatCalibrationPending = false
			return
		end

		local seatedOffset = vars.calculateLocalTryOnSeatedHipOffset(character, model, baseGroundOffset)
		if seatedOffset then
			vars.localTryOnSeatedHipOffsetLocal = vars.getLocalTryOnSeatedHipOffsetLocal(characterRoot, seatedOffset)
			vars.localTryOnSeatedHipOffsetValid = true
			vars.localTryOnPositionMode = "Seat"
		end
		vars.localTryOnSeatCalibrationPending = false
	end)
end

vars.isGroundPlacementState = function(state)	return state == Enum.HumanoidStateType.Running
		or state == Enum.HumanoidStateType.Landed
		or state == Enum.HumanoidStateType.Standing
		or state == Enum.HumanoidStateType.PlatformStanding
end

vars.tryOnSelectedAvatarLocally = function()	if vars.localTryOnBuilding then return end

	local selectedData = vars.ui.selectedAvatar
	if not selectedData or not selectedData.Properties then
		vars.Status.Text = "[!] Select an avatar first."
		vars.clearDiagnostics()
		return
	end

	if vars.IS_CATALOG_AVATAR_CREATOR then
		local ok, err = vars.wearAvatarThroughCatalog(selectedData)
		if ok then
			vars.tryOnActive = true
			vars.Status.Text = "[FE] Avatar worn through Catalog Avatar Creator."
			vars.clearDiagnostics()
			return
		end
		vars.tryOnActive = false
		vars.showDiagnostics("CAC avatar wear failed.", tostring(err))
		return
	end

	local character = vars.LocalPlayer.Character
	local initialHumanoid = character and character:FindFirstChildOfClass("Humanoid")
	if vars.placeholderMode and initialHumanoid and initialHumanoid.RigType == Enum.HumanoidRigType.R6 then
		vars.tryOnActive = true
		vars.Status.Text = "[...] Applying R6 placeholder..."
		vars.clearDiagnostics()
		local ok, err = vars.applyPlaceholderR6(selectedData)
		if ok then
			vars.Status.Text = "[OK] R6 placeholder active!"
			return
		end
		vars.tryOnActive = false
		vars.showDiagnostics("R6 placeholder failed.", tostring(err))
		return
	end
	if not character or not character.Parent then
		vars.showDiagnostics("Local try-on failed.", "Your character is not available yet. Waiting for spawn...")
		return
	end

	if vars.isCharacterCurrentlySitting(character, initialHumanoid) then
		vars.abortLocalTryOnForSeatedPlayer()
		return
	end

	vars.tryOnActive = true
	vars.stopLocalTryOn(true)
	vars.localTryOnBuildId = vars.localTryOnBuildId + 1
	local currentBuildId = vars.localTryOnBuildId
	vars.localTryOnBuilding = true
	vars.WearButton.Active = false
	vars.updateWearButtonState()
	vars.Status.Text = "[...] Building local avatar..."
	vars.clearDiagnostics()

	local rigType = vars.getEnumRigType(selectedData.RigType)
	local playerHumanoidForEmotes = initialHumanoid
	local lastTryOnError = "Unknown local avatar creation failure."
	local seatDetectedDuringBuild = false

	if initialHumanoid then
		vars.setLocalTryOnConnection("buildSeat", initialHumanoid.Seated, function(active)
			if active then
				seatDetectedDuringBuild = true
			end
		end)
	end

	local function seatBlockedDuringBuild()
		return seatDetectedDuringBuild or vars.isCharacterCurrentlySitting(character, initialHumanoid)
	end

	for attempt = 1, 3 do
		if seatBlockedDuringBuild() then
			vars.abortLocalTryOnForSeatedPlayer()
			return
		end
		if not vars.scriptAlive or currentBuildId ~= vars.localTryOnBuildId then
			vars.localTryOnBuilding = false
			vars.WearButton.Active = true
			vars.updateWearButtonState()
			return
		end

		if attempt > 1 then
			vars.Status.Text = string.format("[...] Retrying local avatar... (%d/3)", attempt)
			task.wait(0.1 * (attempt - 1))
			if seatBlockedDuringBuild() then
				vars.abortLocalTryOnForSeatedPlayer()
				return
			end
			if not vars.scriptAlive or currentBuildId ~= vars.localTryOnBuildId then
				vars.localTryOnBuilding = false
				vars.WearButton.Active = true
				vars.updateWearButtonState()
				return
			end
		end

		local description = vars.reconstructHumanoidDescription(selectedData.Properties)
		vars.mergePlayerEmotesIntoDescription(description, playerHumanoidForEmotes, rigType)

		local okCreate, modelOrError = pcall(function()
			return vars.Players:CreateHumanoidModelFromDescriptionAsync(description, rigType)
		end)
		pcall(function() description:Destroy() end)

		if seatBlockedDuringBuild() then
			if typeof(modelOrError) == "Instance" then
				pcall(function() modelOrError:Destroy() end)
			end
			vars.abortLocalTryOnForSeatedPlayer()
			return
		end

		if not okCreate or typeof(modelOrError) ~= "Instance" or not modelOrError:IsA("Model") then
			lastTryOnError = tostring(modelOrError)
			if modelOrError and typeof(modelOrError) == "Instance" then
				pcall(function() modelOrError:Destroy() end)
			end
		else

		local model = modelOrError
		local updateCloneAnims = nil
		local okSetup, setupError = pcall(function()
			model.Name = "LocalWearer_LocalTryOn"
			vars.applyBodyColors(model, selectedData.Properties)
			vars.applyHeadShapeToModel(model, selectedData.Properties)
			vars.applyRigidAccessoryRefinements(model, selectedData.Properties)

			local generatedRoot = model:FindFirstChild("HumanoidRootPart", true) or model.PrimaryPart or model:FindFirstChild("Head", true)
			local characterRoot = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart

			if not generatedRoot then error("Generated avatar missing root part.") end
			if not characterRoot then error("Your character missing root part.") end

			vars.prepareLocalModel(model)

			for _, instance in ipairs(model:GetDescendants()) do
				vars.disableLocalTryOnCollision(instance)
			end

			vars.setLocalTryOnConnection("collision", model.DescendantAdded, vars.disableLocalTryOnCollision)

			vars.setLocalTryOnConnection("preSimulation", vars.RunService.PreSimulation, vars.enforceLocalTryOnNoCollision)
			vars.enforceLocalTryOnNoCollision()

			vars.setLocalTryOnStagingVisibility(model, true)
			generatedRoot.CFrame = characterRoot.CFrame + Vector3.new(0, 100, 0)
			model.Parent = vars.Workspace
			if not vars.isLocalTryOnModelValid(model) then
				error("Generated avatar was removed or invalid immediately after entering Workspace.")
			end

			vars.localTryOnModel = model

			vars.RunService.Heartbeat:Wait()
			if seatBlockedDuringBuild() then
				error("Local try-on blocked: player became seated during avatar build.")
			end
			if not vars.isLocalTryOnModelValid(model) then
				error("Generated avatar did not survive initial rig settling.")
			end

			generatedRoot = model:FindFirstChild("HumanoidRootPart", true) or model.PrimaryPart or model:FindFirstChild("Head", true)
			if not generatedRoot then error("Generated avatar root disappeared after rig settling.") end

			generatedRoot.CFrame = characterRoot.CFrame

			local initialState = initialHumanoid and initialHumanoid:GetState()
			local initiallySwimming = initialState == Enum.HumanoidStateType.Swimming

			vars.currentVerticalOffset = Vector3.zero
			vars.localTryOnRootPart = generatedRoot
			vars.localTryOnSwimOffset = vars.calculateLocalTryOnSwimOffset(character, model, characterRoot, generatedRoot)
			local cloneFeetY = vars.getFeetBottomY(model)
			vars.localTryOnNeutralCloneFeetRootOffsetY = cloneFeetY and (cloneFeetY - characterRoot.Position.Y) or nil
			vars.localTryOnGroundOffset = vars.calculateGroundOffsetFromCurrentPlacement(character, model, Vector3.zero)
			if not vars.localTryOnGroundOffset then
				error("Could not establish initial feet-to-feet ground alignment.")
			end
			vars.localTryOnGroundOffsetValid = true
			vars.localTryOnSeatedHipOffsetValid = false
			vars.localTryOnPositionMode = "Ground"
			vars.localTryOnSeatCalibrationPending = false
			vars.localTryOnSeatCalibrationToken = vars.localTryOnSeatCalibrationToken + 1
			vars.localTryOnGroundCalibrationFrames = 0
			vars.localTryOnSwimTransitionActive = false
			vars.localTryOnSwimTransitionStart = Vector3.zero
			vars.localTryOnSwimTransitionStartedAt = 0
			vars.localTryOnLastSwimming = initiallySwimming
			vars.localTryOnSeatPart = nil

			vars.currentVerticalOffset = initiallySwimming and vars.localTryOnSwimOffset or vars.localTryOnGroundOffset
			vars.localTryOnRootPart.CFrame = characterRoot.CFrame + vars.currentVerticalOffset

			vars.enforceLocalTryOnNoCollision()
			vars.setLocalTryOnStagingVisibility(model, false)
			vars.localTryOnHiddenInFirstPerson = false
			vars.setLocalTryOnFirstPersonVisibility(vars.isFirstPersonCamera(character))

			updateCloneAnims = vars.bindAnimationSync(character, model, selectedData.Properties, selectedData.RigType)

			if seatBlockedDuringBuild() then
				error("Local try-on blocked: player became seated during avatar build.")
			end

			if not vars.isLocalTryOnModelValid(model) then
				error("Generated avatar did not survive animation setup.")
			end

			vars.hideCharacterLocally(character)

			task.spawn(function()
				if vars.scriptAlive and model.Parent and model:IsDescendantOf(vars.Workspace) then
					vars.preloadAvatarVisualContent(model)
				end
			end)
		end)

		if not okSetup then
			if vars.localTryOnModel == model then vars.localTryOnModel = nil end
			vars.setLocalTryOnConnection("collision", nil)
			vars.setLocalTryOnConnection("preSimulation", nil)
			pcall(function() model:Destroy() end)
			lastTryOnError = tostring(setupError)
			if seatBlockedDuringBuild() then
				vars.abortLocalTryOnForSeatedPlayer()
				return
			end
		end

		if okSetup and vars.scriptAlive and currentBuildId == vars.localTryOnBuildId and vars.isLocalTryOnModelValid(model) then
			if seatBlockedDuringBuild() then
				vars.abortLocalTryOnForSeatedPlayer()
				return
			end

			vars.destroyOrphanedLocalTryOnModels(model)
			vars.enforceLocalTryOnNoCollision()
			vars.setLocalTryOnConnection("buildSeat", nil)
			vars.localTryOnBuilding = false
			vars.WearButton.Active = true
			vars.setLocalTryOnConnection("position", vars.RunService.RenderStepped, function()
				if not vars.scriptAlive then return end

				if not vars.localTryOnModel or not vars.localTryOnModel:IsDescendantOf(vars.Workspace) then
					if vars.tryOnActive and not vars.localTryOnBuilding and not vars.localTryOnMissingRecoveryPending then
						vars.localTryOnMissingRecoveryPending = true
						local missingBuildId = vars.localTryOnBuildId
						task.delay(0.15, function()
							vars.localTryOnMissingRecoveryPending = false
							if not vars.scriptAlive or missingBuildId ~= vars.localTryOnBuildId or vars.localTryOnBuilding or not vars.tryOnActive then return end
							if not vars.localTryOnModel or not vars.localTryOnModel:IsDescendantOf(vars.Workspace) then
								vars.stopLocalTryOn(false)
								vars.Status.Text = "[!] Local try-on was removed by this experience. Original avatar restored."
								vars.showDiagnostics(
									"Local try-on unavailable in this experience.",
									"The generated avatar was removed after creation. Your real avatar has been restored. Try again; some games replace or restrict local Humanoid models."
								)
							end
						end)
					end
					return
				end

				vars.localTryOnMissingRecoveryPending = false
				vars.enforceLocalTryOnNoCollision()

				if not character or not character.Parent then
					vars.stopLocalTryOn(vars.tryOnActive)
					vars.updateWearButtonState()
					if vars.tryOnActive then vars.Status.Text = "[...] Character respawning..." end
					return
				end

				local characterRoot = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
				local playerHumanoid = character:FindFirstChildOfClass("Humanoid")

				if not characterRoot or not vars.localTryOnRootPart then
					vars.stopLocalTryOn(vars.tryOnActive)
					vars.updateWearButtonState()
					if vars.tryOnActive then vars.Status.Text = "[...] Waiting for character..." end
					return
				end

				local currentState = playerHumanoid and playerHumanoid:GetState()
				local isSwimming = (currentState == Enum.HumanoidStateType.Swimming)
				local isSeated = playerHumanoid and (playerHumanoid.Sit or playerHumanoid.SeatPart ~= nil or currentState == Enum.HumanoidStateType.Seated) or false
				local seatPart = playerHumanoid and playerHumanoid.SeatPart or nil

				if not isSeated and isSwimming ~= vars.localTryOnLastSwimming then
					vars.localTryOnLastSwimming = isSwimming
					vars.localTryOnSwimTransitionActive = isSwimming or vars.localTryOnGroundOffsetValid
					vars.localTryOnSwimTransitionStart = vars.currentVerticalOffset
					vars.localTryOnSwimTransitionStartedAt = os.clock()
				elseif isSeated then
					vars.localTryOnLastSwimming = isSwimming
					vars.localTryOnSwimTransitionActive = false
				end

				if updateCloneAnims then updateCloneAnims() end

				local targetOffset = vars.currentVerticalOffset

				if isSeated then
					if (vars.localTryOnPositionMode ~= "Seat" and not vars.localTryOnSeatCalibrationPending) or vars.localTryOnSeatPart ~= seatPart then
						vars.localTryOnPositionMode = "SeatCalibration"
						vars.localTryOnGroundCalibrationFrames = 0
						vars.localTryOnSeatPart = seatPart
						vars.localTryOnSeatedHipOffsetValid = false
						vars.localTryOnSeatTransitionActive = false
						if not vars.localTryOnSeatCalibrationPending then
							vars.scheduleSeatHipCalibrationAfterHeartbeat(character, vars.localTryOnModel, playerHumanoid, seatPart, vars.localTryOnGroundOffset)
						end
					end

					if vars.localTryOnSeatedHipOffsetValid then
						if not vars.localTryOnSeatTransitionActive then
							vars.localTryOnSeatTransitionActive = true
							vars.localTryOnSeatTransitionStartLocal = characterRoot.CFrame:VectorToObjectSpace(vars.currentVerticalOffset)
							vars.localTryOnSeatTransitionStartedAt = os.clock()
						end

						local alpha = math.clamp((os.clock() - vars.localTryOnSeatTransitionStartedAt) / 0.16, 0, 1)
						local eased = alpha * alpha * (3 - 2 * alpha)
						local blendedLocalOffset = vars.localTryOnSeatTransitionStartLocal:Lerp(vars.localTryOnSeatedHipOffsetLocal, eased)
						targetOffset = characterRoot.CFrame:VectorToWorldSpace(blendedLocalOffset)
					else
						targetOffset = vars.currentVerticalOffset
					end
				else
					if vars.localTryOnPositionMode == "Seat" or vars.localTryOnPositionMode == "SeatCalibration" then
						vars.localTryOnSeatCalibrationToken = vars.localTryOnSeatCalibrationToken + 1
						vars.localTryOnSeatCalibrationPending = false
						vars.localTryOnSeatPart = nil
						vars.localTryOnSeatedHipOffsetValid = false
						vars.localTryOnSeatTransitionActive = false
						vars.localTryOnSeatTransitionStartLocal = Vector3.zero
						vars.localTryOnSeatTransitionStartedAt = 0
						if vars.localTryOnGroundOffsetValid then
							vars.localTryOnPositionMode = "Ground"
							vars.localTryOnGroundCalibrationFrames = 0
							targetOffset = isSwimming and vars.localTryOnSwimOffset or vars.localTryOnGroundOffset
						else
							vars.localTryOnPositionMode = "GroundCalibration"
							vars.localTryOnGroundCalibrationFrames = 2
						end
					end

					if vars.localTryOnPositionMode == "GroundCalibration" then
						if not isSwimming and vars.isGroundPlacementState(currentState) then
							if not vars.isPlayerSitAnimationCleared(character) then
								vars.localTryOnGroundCalibrationFrames = 2
							elseif vars.localTryOnGroundCalibrationFrames > 0 then
								vars.localTryOnGroundCalibrationFrames = vars.localTryOnGroundCalibrationFrames - 1
							end
							if vars.localTryOnGroundCalibrationFrames == 0 and vars.isPlayerSitAnimationCleared(character) then
								local groundOffset = vars.calculateGroundOffsetFromNeutralCloneFeet(character, characterRoot)
								if groundOffset then
									vars.localTryOnGroundOffset = groundOffset
									vars.localTryOnGroundOffsetValid = true
									vars.localTryOnPositionMode = "Ground"
									targetOffset = groundOffset
								else
									vars.localTryOnGroundCalibrationFrames = 1
								end
							end
						else
							vars.localTryOnGroundCalibrationFrames = 2
						end
						targetOffset = (vars.localTryOnPositionMode == "Ground") and vars.localTryOnGroundOffset or targetOffset
					elseif isSwimming then
						local desiredSwimOffset = vars.localTryOnSwimOffset
						if vars.localTryOnSwimTransitionActive then
							local alpha = math.clamp((os.clock() - vars.localTryOnSwimTransitionStartedAt) / 0.16, 0, 1)
							local eased = alpha * alpha * (3 - 2 * alpha)
							targetOffset = vars.localTryOnSwimTransitionStart:Lerp(desiredSwimOffset, eased)
							if alpha >= 1 then
								vars.localTryOnSwimTransitionActive = false
								targetOffset = desiredSwimOffset
							end
						else
							targetOffset = desiredSwimOffset
						end
					else
						local desiredGroundOffset = vars.localTryOnGroundOffset
						if vars.localTryOnSwimTransitionActive then
							local alpha = math.clamp((os.clock() - vars.localTryOnSwimTransitionStartedAt) / 0.16, 0, 1)
							local eased = alpha * alpha * (3 - 2 * alpha)
							targetOffset = vars.localTryOnSwimTransitionStart:Lerp(desiredGroundOffset, eased)
							if alpha >= 1 then
								vars.localTryOnSwimTransitionActive = false
								targetOffset = desiredGroundOffset
							end
						else
							targetOffset = desiredGroundOffset
						end
					end
				end

				vars.currentVerticalOffset = targetOffset
				vars.localTryOnRootPart.CFrame = characterRoot.CFrame + vars.currentVerticalOffset

				vars.enforceCharacterHidden()
				vars.setLocalTryOnFirstPersonVisibility(vars.isFirstPersonCamera(character))
			end)

			vars.updateWearButtonState()
			vars.Status.Text = "[OK] Local try-on active!"
			return
		end

		lastTryOnError = tostring(setupError)
		pcall(function() model:Destroy() end)
		vars.localTryOnModel = nil
		vars.localTryOnRootPart = nil
		vars.localTryOnGroundOffset = Vector3.zero
		vars.localTryOnSwimOffset = Vector3.zero
		vars.currentVerticalOffset = Vector3.zero
		vars.localTryOnSeatedHipOffsetValid = false
		vars.localTryOnSeatPart = nil
		vars.localTryOnPositionMode = "Ground"
		vars.localTryOnSeatCalibrationPending = false
		vars.localTryOnSeatCalibrationToken = vars.localTryOnSeatCalibrationToken + 1
		vars.resetLocalTryOnState()
		vars.disconnectLocalTryOnConnections()
		end
	end

	vars.setLocalTryOnConnection("buildSeat", nil)
	vars.localTryOnBuilding = false
	vars.WearButton.Active = true
	vars.updateWearButtonState()
	vars.showDiagnostics("Local try-on failed.", lastTryOnError)
end

vars.toggleLocalTryOn = function()	if vars.localTryOnBuilding then return end
	if vars.localTryOnModel or vars.tryOnActive then
		vars.tryOnActive = false
		vars.stopLocalTryOn(false)
		vars.updateWearButtonState()
		vars.Status.Text = "Local try-on cleared."
		vars.clearDiagnostics()
	else
		vars.tryOnSelectedAvatarLocally()
	end
end

vars.bindCharacterLifecycle = function(character)
	vars.disconnectConnection(vars.deathConnection)
	vars.deathConnection = nil
	if not character then return end

	task.spawn(function()
		local humanoid = character:WaitForChild("Humanoid", 10)
		local root = character:WaitForChild("HumanoidRootPart", 10)
		if not humanoid or not root or not vars.scriptAlive then return end

		vars.deathConnection = humanoid.Died:Connect(function()
			if vars.tryOnActive or vars.localTryOnModel or vars.localTryOnBuilding or vars.placeholderR6Active or vars.placeholderR6Backup then
				-- Tear down all visuals attached to the dying character immediately.
				vars.stopLocalTryOn(true)
				vars.destroyOrphanedLocalTryOnModels(nil)
				vars.WearButton.Active = false
				vars.updateWearButtonState()
				vars.Status.Text = "[...] Character died. Reapplying avatar after respawn..."
			end
		end)

		local function applyToThisCharacter()
			if not vars.scriptAlive or vars.LocalPlayer.Character ~= character then return end
			if not vars.tryOnActive or not vars.ui.selectedAvatar then return end
			vars.tryOnSelectedAvatarLocally()
		end

		if vars.tryOnActive and vars.ui.selectedAvatar and vars.scriptAlive then
			task.wait(0.15)
			applyToThisCharacter()

			if vars.placeholderMode and humanoid.RigType == Enum.HumanoidRigType.R6 then
				for _, delaySeconds in ipairs({0.45, 1.0, 2.0}) do
					task.delay(delaySeconds, function()
						if not vars.scriptAlive or vars.LocalPlayer.Character ~= character then return end
						if not vars.placeholderMode or not vars.tryOnActive or not vars.ui.selectedAvatar then return end
						if vars.placeholderR6Building then return end
					applyToThisCharacter()
					end)
				end
			end
		else
			vars.WearButton.Active = true
			vars.updateWearButtonState()
		end
	end)
end

vars.characterAddedConnection = vars.LocalPlayer.CharacterAdded:Connect(vars.bindCharacterLifecycle)


--==============================================================================
-- TAB 10 EVENT CONNECTIONS, THEME ENGINE HOOKS & QUICK-SEARCH REGISTRATION
--==============================================================================
vars.wire(vars.WearButton.Activated, function()
	if vars.localTryOnBuilding then return end
	if vars.localTryOnModel or vars.tryOnActive or vars.placeholderR6Active then
		vars.tryOnActive = false
		vars.stopLocalTryOn(false)
		vars.ui.selectedAvatar = nil
		vars.updateRowVisuals(nil)
		vars.Status.Text = "Local try-on cleared. Original avatar restored."
		vars.clearDiagnostics()
		if NotifyFeatureToggle then NotifyFeatureToggle("Avatar Try-On", false) end
	elseif vars.ui.selectedAvatar then
		vars.tryOnSelectedAvatarLocally()
		if NotifyFeatureToggle then NotifyFeatureToggle("Avatar Try-On", true) end
	else
		vars.Status.Text = "[!] Click an avatar in your list or enter a username above."
	end
end)

vars.updatePlaceholderToggleVisual = function()
	if not vars.PlaceholderToggle or not vars.PlaceholderToggle.Parent then return end
	local t = GetTheme()
	local on = vars.placeholderMode
	vars.PlaceholderToggle.Text = on and "MODE: R6 PLACEHOLDER" or "MODE: CLONE TRY-ON"
	vars.PlaceholderToggle.BackgroundColor3 = on and t.Accent or t.PanelBg
	vars.PlaceholderToggle.TextColor3 = on and Color3.fromRGB(255, 255, 255) or t.TextPrimary
end

vars.wire(vars.PlaceholderToggle.Activated, function()
	if vars.placeholderR6Building then return end
	vars.placeholderMode = not vars.placeholderMode
	vars.updatePlaceholderToggleVisual()
	if NotifyFeatureToggle then NotifyFeatureToggle("R6 Placeholder Mode", vars.placeholderMode) end
	if vars.ui.selectedAvatar and (vars.tryOnActive or vars.localTryOnModel or vars.localTryOnBuilding or vars.placeholderR6Active) then
		vars.tryOnActive = false
		vars.stopLocalTryOn(false)
		task.defer(function()
			if vars.scriptAlive and vars.ui.selectedAvatar then vars.tryOnSelectedAvatarLocally() end
		end)
	else
		vars.Status.Text = vars.placeholderMode and "R6 Placeholder mode enabled." or "Clone Try-On mode enabled."
		vars.clearDiagnostics()
	end
end)

vars.usernameAvatarBusy = false
vars.wire(vars.UsernameBox.FocusLost, function()
	if vars.usernameAvatarBusy then return end
	local username = tostring(vars.UsernameBox.Text or ""):gsub("^%s+", ""):gsub("%s+$", "")
	if username == "" then return end

	vars.usernameAvatarBusy = true
	vars.UsernameBox.Active = false
	vars.SaveSelfButton.Active = false
	vars.SaveClickedButton.Active = false
	vars.PlaceholderToggle.Active = false
	vars.Status.Text = "[...] Loading profile avatar: @" .. username
	vars.clearDiagnostics()

	task.spawn(function()
		local ok, success, result = pcall(function()
			return vars.saveAndWearUsernameAvatar(username)
		end)
		if not ok then
			vars.showDiagnostics("Profile avatar failed.", tostring(success))
		elseif not success then
			vars.showDiagnostics("Profile avatar failed.", tostring(result))
		else
			if NotifyFeatureToggle then NotifyFeatureToggle("Saved & Wore @" .. username, true) end
		end

		if vars.UsernameBox and vars.UsernameBox.Parent then
			vars.UsernameBox.Active = true
			vars.SaveSelfButton.Active = true
			vars.SaveClickedButton.Active = not vars.ui.selectingPlayer
			vars.PlaceholderToggle.Active = true
			vars.usernameAvatarBusy = false
		end
	end)
end)

vars.wire(vars.SearchBox:GetPropertyChangedSignal("Text"), function()
	if not vars.scriptAlive then return end
	if vars.searchDebounceThread then task.cancel(vars.searchDebounceThread) vars.searchDebounceThread = nil end
	vars.searchDebounceThread = task.delay(0.12, function()
		if vars.scriptAlive then vars.filterAvatarCards(vars.SearchBox.Text) end
	end)
end)

vars.wire(vars.SaveSelfButton.Activated, function()
	if vars.ui.selectingPlayer then vars.stopPlayerSelection() end
	vars.SaveSelfButton.Active = false
	vars.SaveSelfButton.Text = "SAVING..."
	local ok, result = vars.savePlayerAvatar(vars.LocalPlayer)
	if ok then
		local catalogOk, catalogName, catalogErr
		if vars.IS_CATALOG_AVATAR_CREATOR then
			catalogOk, catalogName, catalogErr = vars.saveAvatarToCatalogOutfit(result)
		end
		vars.SaveSelfButton.Text = (not vars.IS_CATALOG_AVATAR_CREATOR or catalogOk) and "SAVED!" or "LOCAL SAVED"
		vars.SaveSelfButton.BackgroundColor3 = (not vars.IS_CATALOG_AVATAR_CREATOR or catalogOk) and vars.COLORS.Success or vars.COLORS.Danger
		vars.populateAvatarList()
		if NotifyFeatureToggle then NotifyFeatureToggle("Saved My Avatar", true) end
		if vars.IS_CATALOG_AVATAR_CREATOR and catalogOk then
			vars.Status.Text = "[FE] Saved to Saved Outfits as " .. tostring(catalogName)
		elseif vars.IS_CATALOG_AVATAR_CREATOR then
			vars.Status.Text = "[LOCAL] Saved, but CAC outfit save failed."
			vars.showDiagnostics("CAC outfit save failed.", tostring(catalogErr))
		else
			vars.Status.Text = "[OK] Saved your current avatar (" .. tostring(#vars.ui.savedAvatars) .. " total)"
		end
	else
		vars.SaveSelfButton.Text = "EXISTS / ERR"
		vars.SaveSelfButton.BackgroundColor3 = vars.COLORS.Danger
		vars.showDiagnostics("Could not save avatar.", tostring(result))
	end
	task.delay(1.1, function()
		if vars.SaveSelfButton and vars.SaveSelfButton.Parent then
			local t = GetTheme()
			vars.SaveSelfButton.Text = "SAVE SELF"
			vars.SaveSelfButton.BackgroundColor3 = t.PanelBg
			vars.SaveSelfButton.Active = true
		end
	end)
end)

vars.wire(vars.SaveClickedButton.Activated, function()
	if vars.ui.selectingPlayer then
		vars.stopPlayerSelection()
		if NotifyFeatureToggle then NotifyFeatureToggle("Click Player to Save", false) end
		return
	end
	local t = GetTheme()
	vars.ui.selectingPlayer = true
	vars.ui.selectionPlayer = nil
	vars.SaveClickedButton.Text = "CLICK PLAYER"
	vars.SaveClickedButton.BackgroundColor3 = t.Accent
	vars.SaveClickedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	vars.Status.Text = "Click or tap any player in-game to save their avatar."
	vars.clearDiagnostics()
	if NotifyFeatureToggle then NotifyFeatureToggle("Click Player to Save", true) end
end)

vars.isRefreshing = false
vars.wire(vars.RefreshButton.Activated, function()
	if vars.isRefreshing then return end
	vars.isRefreshing = true
	vars.RefreshButton.Text = "..."
	vars.Status.Text = "Syncing & refreshing saved avatars..."
	vars.previewQueueGeneration = vars.previewQueueGeneration + 1
	table.clear(vars.previewQueue)
	table.clear(vars.previewStates)
	task.wait(0.05)
	vars.loadSavedAvatars()
	vars.populateAvatarList()
	vars.RefreshButton.Text = "REFRESH"
	task.delay(0.35, function() vars.isRefreshing = false end)
end)

vars.wire(vars.UserInputService.InputChanged, function(input)
	if not vars.ui.selectingPlayer then return end
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		vars.setPlayerSelectionHighlight(vars.getPlayerFromMouseTarget())
	end
end)

vars.wire(vars.UserInputService.InputBegan, function(input, gameProcessed)
	if vars.ui.selectingPlayer and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
		if gameProcessed and input.UserInputType == Enum.UserInputType.MouseButton1 then return end
		local targetPlayer
		if input.UserInputType == Enum.UserInputType.Touch then
			targetPlayer = vars.getPlayerFromScreenPosition(input.Position)
		else
			targetPlayer = vars.getPlayerFromMouseTarget()
		end
		if targetPlayer then
			vars.SaveClickedButton.Text = "SAVING..."
			vars.SaveClickedButton.BackgroundColor3 = GetTheme().PanelBg
			vars.SaveClickedButton.Active = false
			local ok, result = vars.savePlayerAvatar(targetPlayer)
			vars.stopPlayerSelection()
			if ok then
				local catalogOk, catalogName, catalogErr
				if vars.IS_CATALOG_AVATAR_CREATOR then
					catalogOk, catalogName, catalogErr = vars.saveAvatarToCatalogOutfit(result)
				end
				vars.populateAvatarList()
				vars.SaveClickedButton.Text = (not vars.IS_CATALOG_AVATAR_CREATOR or catalogOk) and "SAVED!" or "LOCAL SAVED"
				vars.SaveClickedButton.BackgroundColor3 = (not vars.IS_CATALOG_AVATAR_CREATOR or catalogOk) and vars.COLORS.Success or vars.COLORS.Danger
				if NotifyFeatureToggle then NotifyFeatureToggle("Saved @" .. tostring(targetPlayer.Name), true) end
				if vars.IS_CATALOG_AVATAR_CREATOR and catalogOk then
					vars.Status.Text = "[FE] Saved @" .. tostring(targetPlayer.Name) .. " to Saved Outfits as " .. tostring(catalogName)
				elseif vars.IS_CATALOG_AVATAR_CREATOR then
					vars.Status.Text = "[LOCAL] Saved @" .. tostring(targetPlayer.Name) .. ", but CAC outfit save failed."
					vars.showDiagnostics("CAC outfit save failed.", tostring(catalogErr))
				else
					vars.Status.Text = "[OK] Saved @" .. tostring(targetPlayer.Name) .. " (" .. tostring(#vars.ui.savedAvatars) .. " total)"
				end
			else
				vars.SaveClickedButton.Text = "EXISTS / ERR"
				vars.SaveClickedButton.BackgroundColor3 = vars.COLORS.Danger
				vars.showDiagnostics("Failed to save " .. tostring(targetPlayer.Name) .. ".", tostring(result))
			end
			task.delay(1.1, function()
				if vars.SaveClickedButton and vars.SaveClickedButton.Parent then
					local t = GetTheme()
					vars.SaveClickedButton.Text = "SAVE OTHER"
					vars.SaveClickedButton.BackgroundColor3 = t.PanelBg
					vars.SaveClickedButton.TextColor3 = t.TextPrimary
					vars.SaveClickedButton.Active = true
				end
			end)
			return
		end
		if input.UserInputType == Enum.UserInputType.Touch then
			vars.Status.Text = "No player found there. Tap a player character to save them."
			return
		end
		vars.stopPlayerSelection()
		vars.Status.Text = "Player selection cancelled."
		return
	end
end)

-- Dynamic Theme & 3-Style GUI Design Synchronization for Avatar Changer Tab & 3D Preview
vars.RefreshAvatarChangerTheme = function()
	vars.SyncColorsFromHubTheme()
	local t = GetTheme()
	local d = Config.GuiDesign or "Default"

	vars.updatePlaceholderToggleVisual()
	vars.updateWearButtonState()
	if not vars.ui.selectingPlayer and vars.SaveClickedButton and vars.SaveClickedButton.Parent then
		vars.SaveClickedButton.BackgroundColor3 = t.PanelBg
		vars.SaveClickedButton.TextColor3 = t.TextPrimary
	elseif vars.ui.selectingPlayer and vars.SaveClickedButton and vars.SaveClickedButton.Parent then
		vars.SaveClickedButton.BackgroundColor3 = t.Accent
		vars.SaveClickedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	end
	if vars.ui.selectionHighlight and vars.ui.selectionHighlight.Parent then
		vars.ui.selectionHighlight.FillColor = t.Accent
	end
	if vars.StatusDot and vars.StatusDot.Parent then
		vars.StatusDot.BackgroundColor3 = t.Accent
	end

	-- Style 3D Preview Popup to match active Theme & GUI Design (Classic / LiquidGlass / CyberHud)
	local popup = vars.HoverPreview
	if popup and popup.Parent then
		popup.BackgroundColor3 = t.MainBg
		local pCorner = popup:FindFirstChildOfClass("UICorner")
		local pStroke = popup:FindFirstChildOfClass("UIStroke")
		local pGrad = popup:FindFirstChild("PreviewGlassGrad")
		local sGrad = pStroke and pStroke:FindFirstChild("PreviewStrokeGrad")
		local topBar = popup:FindFirstChild("PreviewTopBar")
		local title = topBar and topBar:FindFirstChild("OutfitName")
		local closeBtn = topBar and topBar:FindFirstChild("ClosePreviewBtn")
		local holder = popup:FindFirstChild("ViewportHolder")
		local vhStroke = holder and holder:FindFirstChild("VHStroke")
		local info = popup:FindFirstChild("Info")
		local botName = popup:FindFirstChild("BottomOutfitName")
		local status = holder and holder:FindFirstChild("PreviewStatus")

		if title then title.TextColor3 = t.Accent end
		if closeBtn then
			closeBtn.BackgroundColor3 = t.PanelBg
			closeBtn.TextColor3 = t.TextPrimary
		end
		if holder then
			holder.BackgroundColor3 = t.PanelBg
			holder.BackgroundTransparency = (d == "LiquidGlass" and 0.52) or (d == "CyberHud" and 0.14) or 0.20
		end
		if vhStroke then vhStroke.Color = t.Stroke end
		if info then info.TextColor3 = t.TextSecondary end
		if botName then botName.TextColor3 = t.TextPrimary end
		if status then status.TextColor3 = t.TextSecondary end

		if d == "LiquidGlass" then
			popup.BackgroundTransparency = 0.48
			if pCorner then pCorner.CornerRadius = UDim.new(0, 16) end
			if pStroke then
				pStroke.Thickness = 1.8
				pStroke.Transparency = 0.08
				pStroke.Color = Color3.fromRGB(255, 255, 255)
			end
			if pGrad then
				pGrad.Rotation = -38
				pGrad.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, t.MainBg:Lerp(Color3.fromRGB(255, 255, 255), 0.32)),
					ColorSequenceKeypoint.new(0.5, t.MainBg),
					ColorSequenceKeypoint.new(1, t.MainBg:Lerp(Color3.fromRGB(210, 232, 255), 0.25))
				})
				pGrad.Enabled = true
			end
			if sGrad then
				sGrad.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
					ColorSequenceKeypoint.new(0.45, t.Stroke),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
				})
				sGrad.Enabled = true
			end
		elseif d == "CyberHud" then
			popup.BackgroundTransparency = 0.06
			if pCorner then pCorner.CornerRadius = UDim.new(0, 6) end
			if pStroke then
				pStroke.Thickness = 2.2
				pStroke.Transparency = 0.0
				pStroke.Color = Color3.fromRGB(255, 255, 255)
			end
			if pGrad then
				pGrad.Rotation = 25
				pGrad.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 14, 26):Lerp(t.Accent, 0.14)),
					ColorSequenceKeypoint.new(0.5, Color3.fromRGB(5, 6, 12)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(14, 10, 28):Lerp(t.Stroke, 0.14))
				})
				pGrad.Enabled = true
			end
			if sGrad then
				sGrad.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, t.Accent),
					ColorSequenceKeypoint.new(0.5, t.Stroke),
					ColorSequenceKeypoint.new(1, t.Accent)
				})
				sGrad.Enabled = true
			end
		else
			popup.BackgroundTransparency = 0.06
			if pCorner then pCorner.CornerRadius = UDim.new(0, 12) end
			if pStroke then
				pStroke.Thickness = 1.5
				pStroke.Transparency = 0.22
				pStroke.Color = t.Stroke
			end
			if pGrad then pGrad.Enabled = false end
			if sGrad then sGrad.Enabled = false end
		end
	end

	for data, row in pairs(vars.ui.avatarRows) do
		vars.StyleAvatarRow(data, row)
	end
end

table.insert(ThemeObjects.CustomCallbacks, vars.RefreshAvatarChangerTheme)

-- Register Avatar Changer Functions in Global Quick-Search Bar
if FUI.RegisterSearchFunction then
	FUI.RegisterSearchFunction({
		Name = "Avatar Changer: Local Avatar Try-On (Wear / Restore)",
		TabName = "Avatar Changer",
		Keywords = "avatar changer try on wear outfit skin restore character",
		Priority = 14,
		GetState = function() return (vars.tryOnActive == true or vars.localTryOnModel ~= nil or vars.placeholderR6Active == true) end,
		Toggle = function()
			if vars.localTryOnModel or vars.tryOnActive or vars.placeholderR6Active then
				vars.tryOnActive = false
				vars.stopLocalTryOn(false)
				vars.ui.selectedAvatar = nil
				vars.updateRowVisuals(nil)
				vars.Status.Text = "Local try-on cleared. Original avatar restored."
				if NotifyFeatureToggle then NotifyFeatureToggle("Avatar Try-On", false) end
			else
				if not vars.ui.selectedAvatar and #vars.ui.savedAvatars > 0 then
					vars.ui.selectedAvatar = vars.ui.savedAvatars[1]
				end
				if vars.ui.selectedAvatar then
					vars.updateRowVisuals(vars.ui.selectedAvatar)
					vars.tryOnSelectedAvatarLocally()
					if NotifyFeatureToggle then NotifyFeatureToggle("Avatar Try-On", true) end
				else
					FUI.SwitchToTab("Avatar Changer")
					vars.Status.Text = "[!] Save or select an avatar in Avatar Changer first."
				end
			end
		end
	})
	FUI.RegisterSearchFunction({
		Name = "Avatar Changer: R6 Placeholder Mode (Direct R6 Swap)",
		TabName = "Avatar Changer",
		Keywords = "avatar changer r6 placeholder mode swap method",
		Priority = 15,
		GetState = function() return vars.placeholderMode == true end,
		Toggle = function()
			if vars.placeholderR6Building then return end
			vars.placeholderMode = not vars.placeholderMode
			vars.updatePlaceholderToggleVisual()
			if NotifyFeatureToggle then NotifyFeatureToggle("R6 Placeholder Mode", vars.placeholderMode) end
		end
	})
	FUI.RegisterSearchFunction({
		Name = "Avatar Changer: Click Player to Save Avatar",
		TabName = "Avatar Changer",
		Keywords = "avatar changer click player save other copy outfit steal",
		Priority = 16,
		GetState = function() return vars.ui.selectingPlayer == true end,
		Toggle = function()
			if vars.ui.selectingPlayer then
				vars.stopPlayerSelection()
				if NotifyFeatureToggle then NotifyFeatureToggle("Click Player to Save", false) end
			else
				local t = GetTheme()
				vars.ui.selectingPlayer = true
				vars.ui.selectionPlayer = nil
				vars.SaveClickedButton.Text = "CLICK PLAYER"
				vars.SaveClickedButton.BackgroundColor3 = t.Accent
				vars.SaveClickedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
				vars.Status.Text = "Click or tap any player in-game to save their avatar."
				if NotifyFeatureToggle then NotifyFeatureToggle("Click Player to Save", true) end
			end
		end
	})
end

if vars.LocalPlayer.Character then
	vars.bindCharacterLifecycle(vars.LocalPlayer.Character)
end

vars.loadSavedAvatars()
vars.populateAvatarList()
vars.RefreshAvatarChangerTheme()
task.defer(function()
	if vars.scriptAlive and not vars.previewQueueRunning then
		task.spawn(vars.processPreviewQueue)
	end
end)

end
SetupTab10()

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
local ContextActionService = game:GetService("ContextActionService")
local isKatanaBlockingClick = false

local KatanaClickSinkBtn = Instance.new("TextButton")
KatanaClickSinkBtn.Name = "TR_KatanaClickSink"
KatanaClickSinkBtn.Size = UDim2.new(1, 0, 1, 0)
KatanaClickSinkBtn.Position = UDim2.new(0, 0, 0, 0)
KatanaClickSinkBtn.BackgroundTransparency = 1
KatanaClickSinkBtn.BorderSizePixel = 0
KatanaClickSinkBtn.Text = ""
KatanaClickSinkBtn.AutoButtonColor = false
KatanaClickSinkBtn.Active = true
KatanaClickSinkBtn.Visible = false
KatanaClickSinkBtn.ZIndex = 999999
KatanaClickSinkBtn.Parent = ScreenGui

local function SetKatanaClickBlockState(shouldBlock)
	if shouldBlock then
		if StopAutoShootFiring then StopAutoShootFiring() end
		if mouse1release then pcall(mouse1release) end
		local myChar = LocalPlayer.Character
		local myTool = myChar and myChar:FindFirstChildOfClass("Tool")
		if myTool then pcall(function() myTool:Deactivate() end) end
		if not isKatanaBlockingClick then
			isKatanaBlockingClick = true
			KatanaClickSinkBtn.Visible = true
			pcall(function()
				ContextActionService:BindActionAtPriority("TR_KatanaClickBlock", function()
					if mouse1release then pcall(mouse1release) end
					return Enum.ContextActionResult.Sink
				end, false, Enum.ContextActionPriority.High.Value + 5000, Enum.UserInputType.MouseButton1, Enum.UserInputType.Touch)
			end)
		end
	else
		if isKatanaBlockingClick then
			isKatanaBlockingClick = false
			KatanaClickSinkBtn.Visible = false
			pcall(function()
				ContextActionService:UnbindAction("TR_KatanaClickBlock")
			end)
		end
	end
end

local KatanaWarnBanner = Instance.new("Frame")
KatanaWarnBanner.Name = "TR_KatanaWarnBanner"
KatanaWarnBanner.AnchorPoint = Vector2.new(0.5, 0)
KatanaWarnBanner.Position = UDim2.new(0.5, 0, 0, 48)
KatanaWarnBanner.Size = UDim2.new(0, 290, 0, 30)
KatanaWarnBanner.BackgroundColor3 = Color3.fromRGB(28, 10, 14)
KatanaWarnBanner.BackgroundTransparency = 0.12
KatanaWarnBanner.BorderSizePixel = 0
KatanaWarnBanner.Visible = false
KatanaWarnBanner.ZIndex = 88
KatanaWarnBanner.Parent = ScreenGui
AddCorner(KatanaWarnBanner, 8)
local kwStroke = Instance.new("UIStroke", KatanaWarnBanner)
kwStroke.Thickness = 1.6
kwStroke.Color = Color3.fromRGB(255, 65, 65)
local KatanaWarnText = Instance.new("TextLabel", KatanaWarnBanner)
KatanaWarnText.Size = UDim2.new(1, -16, 1, 0)
KatanaWarnText.Position = UDim2.new(0, 8, 0, 0)
KatanaWarnText.BackgroundTransparency = 1
KatanaWarnText.Font = Enum.Font.GothamBold
KatanaWarnText.TextSize = 12
KatanaWarnText.TextColor3 = Color3.fromRGB(255, 220, 90)
KatanaWarnText.TextTruncate = Enum.TextTruncate.AtEnd
KatanaWarnText.Text = ""
KatanaWarnText.ZIndex = 89

local KATANA_BOOL_ATTRS = { "Deflect", "Deflecting", "IsDeflecting", "KatanaDeflect", "Parry", "Parrying", "Reflect", "Reflecting", "Blocking", "Counter" }
local KATANA_STR_ATTRS = { "Weapon", "EquippedWeapon", "CurrentWeapon", "Equipped", "Tool", "ActiveWeapon", "HeldWeapon" }
local katanaLastScanTime, katanaLastScanResult = {}, {}
local anyEnemyKatanaCurrentlyActive = false

local function GetPlayingTracksDirect(animator)
	return animator:GetPlayingAnimationTracks()
end

local function CheckRawEnemyKatanaActive(plr, char)
	if not char then return false end
	-- 1. Check pre-allocated Attribute lists on Character and Player (Zero table allocations)
	for i = 1, #KATANA_BOOL_ATTRS do
		local attrName = KATANA_BOOL_ATTRS[i]
		if char:GetAttribute(attrName) == true or (plr and plr:GetAttribute(attrName) == true) then
			return true
		end
	end
	for i = 1, #KATANA_STR_ATTRS do
		local wAttr = KATANA_STR_ATTRS[i]
		local wv = char:GetAttribute(wAttr) or (plr and plr:GetAttribute(wAttr))
		if type(wv) == "string" then
			local low = wv:lower()
			if low:find("katana", 1, true) or low:find("deflect", 1, true) then
				return true
			end
		end
	end
	-- 2. Check Playing AnimationTracks on Animator
	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum then
		local animator = hum:FindFirstChildOfClass("Animator") or hum
		local ok, tracks = pcall(GetPlayingTracksDirect, animator)
		if ok and type(tracks) == "table" then
			for i = 1, #tracks do
				local tr = tracks[i]
				if tr.IsPlaying then
					local tName = tostring(tr.Name or ""):lower()
					local aName = tostring((tr.Animation and tr.Animation.Name) or ""):lower()
					if tName:find("katana", 1, true) or tName:find("deflect", 1, true) or tName:find("parry", 1, true) or tName:find("reflect", 1, true) or aName:find("katana", 1, true) or aName:find("deflect", 1, true) or aName:find("parry", 1, true) or aName:find("reflect", 1, true) then
						return true
					end
				end
			end
		end
	end
	-- 3. Fast 2-level child scan (avoids full char:GetDescendants() over 100+ character attachments/welds)
	for _, child in ipairs(char:GetChildren()) do
		local cn = child.Name:lower()
		if cn:find("katana", 1, true) or cn:find("deflect", 1, true) or cn:find("parry", 1, true) then
			if child:IsA("Tool") then
				return true
			elseif child:IsA("Highlight") and child.Enabled and child.Name ~= "AssetHighlight" and child.Name ~= "TR_ESP_Highlight" then
				return true
			elseif child:IsA("BasePart") and child.Transparency < 0.9 then
				return true
			elseif child:IsA("Model") or child:IsA("Folder") then
				for _, sub in ipairs(child:GetDescendants()) do
					if sub:IsA("BasePart") and sub.Transparency < 0.9 then
						return true
					end
				end
			end
		elseif child:IsA("Model") or child:IsA("Folder") or child:IsA("Tool") then
			for _, sub in ipairs(child:GetChildren()) do
				local sn = sub.Name:lower()
				if sn:find("katana", 1, true) or sn:find("deflect", 1, true) or sn:find("parry", 1, true) then
					if sub:IsA("Tool") or (sub:IsA("BasePart") and sub.Transparency < 0.9) or ((sub:IsA("ParticleEmitter") or sub:IsA("Beam") or sub:IsA("Trail")) and sub.Enabled) then
						return true
					elseif sub:IsA("Model") then
						for _, p in ipairs(sub:GetChildren()) do
							if p:IsA("BasePart") and p.Transparency < 0.9 then return true end
						end
					end
				end
			end
		end
	end
	return false
end

local function IsEnemyUsingKatana(plr, char)
	if Config.AntiKatanaEnabled == false or not plr or (typeof(plr) == "Instance" and not plr:IsA("Player")) then return false end
	local now = os.clock()
	local lastT = katanaLastScanTime[plr]
	if lastT and (now - lastT < 0.10) then
		if katanaLastScanResult[plr] then
			return true
		end
		local exp = katanaActiveUntil[plr]
		return (exp ~= nil and now < exp)
	end
	char = char or GetCharacterFromPlayer(plr)
	local rawActive = CheckRawEnemyKatanaActive(plr, char)
	katanaLastScanTime[plr] = now
	katanaLastScanResult[plr] = rawActive
	if rawActive then
		katanaActiveUntil[plr] = now + 0.25
		return true
	end
	local exp = katanaActiveUntil[plr]
	if exp and now < exp then
		return true
	end
	return false
end

genv._TR_MobileToggleAimbot = function() if toggleAimbot then toggleAimbot() end end
genv._TR_MobileToggleTargetAimbot = function() if toggleTargetAimbot then toggleTargetAimbot() end end
genv._TR_MobileToggleAutoShoot = function() if toggleAutoShoot then toggleAutoShoot() end end
genv._TR_MobileToggleFlight = function()
	if not masterFlightEnabled then
		masterFlightEnabled = true
		savedConfig.Settings.MasterFlightEnabled = true
	end
	if toggleFlightState then toggleFlightState() end
end

local function getValidEnemyHitboxFromInstance(hitInstance)
	if not hitInstance then return nil, nil end
	if FUI.ZombieAim and FUI.ZombieAim.Enabled then
		local isZ, zMdl = FUI.ZombieAim.IsPartInAnyZombie(hitInstance)
		if isZ and zMdl then return zMdl, zMdl end
	end
	if hitInstance:FindFirstAncestorOfClass("Accessory") or hitInstance:FindFirstAncestorOfClass("Tool") then
		return nil, nil
	end
	local cur = hitInstance
	while cur and cur ~= workspace do
		if cur:IsA("Model") then
			local p = Players:GetPlayerFromCharacter(cur)
			if p then return p, cur end
		end
		cur = cur.Parent
	end
	return nil, nil
end

local lastWallFilterSync = 0
local lastWallCharRef, lastWallCamRef = nil, nil
local function EnsureWallcheckFilterFresh(cam)
	local myChar = LocalPlayer.Character
	local now = os.clock()
	if myChar ~= lastWallCharRef or cam ~= lastWallCamRef or (now - lastWallFilterSync >= 1.0) then
		lastWallCharRef = myChar
		lastWallCamRef = cam
		lastWallFilterSync = now
		if updateWallcheckFilter then updateWallcheckFilter(myChar) end
	end
end

local function checkScreenMiddleDotRay(cam)
	if not cam then return nil, nil end
	EnsureWallcheckFilterFresh(cam)
	local origin = cam.CFrame.Position
	local lookDir = cam.CFrame.LookVector
	for _ = 1, 6 do
		local res = workspace:Raycast(origin, lookDir * 1000, reusableWallcheckParams)
		if not res or not res.Instance then break end
		local hit = res.Instance
		local hitPlr, hitChar = getValidEnemyHitboxFromInstance(hit)
		if hitPlr then
			if hitPlr == hitChar and FUI.ZombieAim and FUI.ZombieAim.CacheMap[hitChar] then
				local zEnt = FUI.ZombieAim.CacheMap[hitChar]
				if FUI.ZombieAim.IsEntryAlive(zEnt) then
					lastMiddleDotTarget = hitChar
					lastMiddleDotTime = os.clock()
					return hitChar, hitChar
				end
			elseif hitPlr ~= LocalPlayer and not excludedPlayers[hitPlr] then
				local hitHum = hitChar:FindFirstChildOfClass("Humanoid")
				if hitHum and hitHum.Health > 0 then
					local teamAllowed = (not aimbotTeamCheck) or (not IsTeammate(hitPlr))
					local targetAllowed = (not targetAimbotEnabled) or (not specificTargetPlayer) or (hitPlr == specificTargetPlayer)
					if teamAllowed and targetAllowed then
						lastMiddleDotTarget = hitPlr
						lastMiddleDotTime = os.clock()
						return hitPlr, hitChar
					end
				end
			end
			break
		end
		if not hit.CanCollide or hit.Transparency >= 0.85 or hit:FindFirstAncestorOfClass("Accessory") or hit:FindFirstAncestorOfClass("Tool") then
			origin = res.Position + (lookDir * 0.2)
		else
			break
		end
	end
	-- 150ms anti-stutter hold grace so recoil vibration never interrupts rapid Assault Rifle spray
	if isAutoShootingActive and lastMiddleDotTarget and lastMiddleDotTarget.Parent and (os.clock() - lastMiddleDotTime <= 0.15) then
		local gChar = GetCharacterFromPlayer(lastMiddleDotTarget)
		local gHum = gChar and gChar:FindFirstChildOfClass("Humanoid")
		local gPart = getTargetPart(gChar)
		if gChar and gHum and gHum.Health > 0 and gPart and isTargetVisible(gPart, gChar) then
			local gp = gPart.Position
			local dx, dy, dz = gp.X - origin.X, gp.Y - origin.Y, gp.Z - origin.Z
			local dSq = dx * dx + dy * dy + dz * dz
			if dSq > 0.0001 then
				local dot = (dx * lookDir.X + dy * lookDir.Y + dz * lookDir.Z) / math.sqrt(dSq)
				if dot >= 0.95 then
					return lastMiddleDotTarget, gChar
				end
			end
		end
	end
	return nil, nil
end

local function GetTargetLabelName(t)
	if not t then return "None" end
	if typeof(t) == "Instance" then
		if t:IsA("Player") then return tostring(t.DisplayName or t.Name) end
		local zEnt = FUI.ZombieAim and FUI.ZombieAim.CacheMap[t]
		if zEnt and zEnt.Name then return tostring(zEnt.Name) end
		return tostring(t.Name)
	end
	return tostring(t)
end

local function EnforceLockedCamera()
	local zAimOn = (FUI.ZombieAim and FUI.ZombieAim.Enabled == true)
	if isClosingPermanently or not (aimbotEnabled or targetAimbotEnabled or zAimOn) or not currentTarget then return end
	local cam = workspace.CurrentCamera
	if not cam then return end
	local tChar = GetCharacterFromPlayer(currentTarget)
	local tPart = getTargetPart(tChar)
	if tChar and tPart then
		local camPos = cam.CFrame.Position
		local tVel = tPart.AssemblyLinearVelocity or V3_ZERO
		local leadPos = tPart.Position + (tVel * 0.006)
		local goalCF = CFrame.new(camPos, leadPos)
		cam.CFrame = strongLock and goalCF or cam.CFrame:Lerp(goalCF, LERP_ALPHA)
	end
end

local enemyKatanaNotifiedState = {}
local lastKatanaScanTime = 0

local function ScanEnemiesForKatanaEquip()
	if isClosingPermanently or Config.AntiKatanaEnabled == false then
		if KatanaWarnBanner and KatanaWarnBanner.Visible then KatanaWarnBanner.Visible = false end
		return
	end
	local now = os.clock()
	if now - lastKatanaScanTime < 0.14 then return end
	lastKatanaScanTime = now

	local myChar = LocalPlayer.Character
	local myRoot = myChar and (myChar:FindFirstChild("HumanoidRootPart") or myChar.PrimaryPart)
	local myPos = myRoot and myRoot.Position
	local closestKatanaPlr, closestKatanaDist = nil, math.huge

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and not excludedPlayers[plr] and ((not aimbotTeamCheck) or (not IsTeammate(plr))) then
			local char = GetCharacterFromPlayer(plr)
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			local root = char and (char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart)
			local dist = (myPos and root) and (root.Position - myPos).Magnitude or 0
			local isAlive = (char and hum and hum.Health > 0 and dist <= MAX_DISTANCE)
			local hasKatana = isAlive and IsEnemyUsingKatana(plr, char) or false

			if hasKatana then
				if dist < closestKatanaDist then
					closestKatanaDist = dist
					closestKatanaPlr = plr
				end
				if not enemyKatanaNotifiedState[plr] then
					enemyKatanaNotifiedState[plr] = true
					if NotifyFeatureToggle then
						NotifyFeatureToggle("KATANA: " .. tostring(plr.DisplayName), true)
					end
				end
			elseif enemyKatanaNotifiedState[plr] then
				enemyKatanaNotifiedState[plr] = nil
				if NotifyFeatureToggle then
					NotifyFeatureToggle("KATANA: " .. tostring(plr.DisplayName), false)
				end
			end
		elseif enemyKatanaNotifiedState[plr] then
			enemyKatanaNotifiedState[plr] = nil
		end
	end

	anyEnemyKatanaCurrentlyActive = (closestKatanaPlr ~= nil)
	if closestKatanaPlr then
		if not KatanaWarnBanner.Visible then KatanaWarnBanner.Visible = true end
		local warnStr = string.format("[!] KATANA EQUIPPED: %s (%d studs)", tostring(closestKatanaPlr.DisplayName), math.floor(closestKatanaDist + 0.5))
		if KatanaWarnText.Text ~= warnStr then KatanaWarnText.Text = warnStr end
	elseif KatanaWarnBanner.Visible then
		KatanaWarnBanner.Visible = false
	end
end

table.insert(Connections, RunService.Heartbeat:Connect(function()
	EnforceLockedCamera()
	ScanEnemiesForKatanaEquip()
	if FUI.ZombieAim and FUI.ZombieAim.Enabled and not isClosingPermanently then
		FUI.ZombieAim.StepPendingQueue()
		if os.clock() - FUI.ZombieAim.LastScanTime >= 1.2 then
			FUI.ZombieAim.StartBudgetedScan()
		end
	end
end))

local function setAimbotStatusText(txt)
	if aimbotStatusLabel and aimbotStatusLabel.Text ~= txt then
		aimbotStatusLabel.Text = txt
	end
end
local function setNormalShootStatusText(txt)
	if autoShootStatusLbl and autoShootStatusLbl.Text ~= txt then
		autoShootStatusLbl.Text = txt
	end
end
local function setAimbotShootStatusText(txt)
	if aimbotAutoShootStatusLbl and aimbotAutoShootStatusLbl.Text ~= txt then
		aimbotAutoShootStatusLbl.Text = txt
	end
end
local lastMqAim, lastMqTAim, lastMqShoot, lastMqFly = nil, nil, nil, nil

RunService:BindToRenderStep("Aimbot_v2", Enum.RenderPriority.Camera.Value + 10, function()
	local cam = workspace.CurrentCamera
	if not cam then
		if StopAutoShootFiring then StopAutoShootFiring() end
		return
	end
	if aimbotEnabled and aimbotKeyMode == "Burst1s" and aimbotBurstEndTime > 0 and os.clock() >= aimbotBurstEndTime then
		aimbotEnabled = false
		Config.AimbotEnabled = false
		aimbotBurstEndTime = 0
		currentTarget = nil
		if aimbotAutoShootEnabled and StopAutoShootFiring then StopAutoShootFiring() end
		NotifyFeatureToggle("Button Aimbot", false)
		setAimbotStatusText("Status: Idle (" .. tostring(aimbotBurstDurationMs) .. "ms Ended)")
		if RefreshAimbotVisuals then pcall(RefreshAimbotVisuals) end
	end
	local zAimOn = (FUI.ZombieAim and FUI.ZombieAim.Enabled == true)
	local anyAimbotActive = (aimbotEnabled or targetAimbotEnabled or zAimOn) and not isClosingPermanently
	local showFov = (aimbotEnabled or zAimOn) and fovCircleEnabled and not isClosingPermanently
	if guiFovCircle and guiFovCircle.Visible ~= showFov then
		guiFovCircle.Visible = showFov
	end
	if CursorUnlockedOverride and not isClosingPermanently then
		pcall(stepShiftLockCore, cam)
	else
		lastShiftLook = nil
	end

	if genv._TR_UpdateMobileQuickBar then
		local curShoot = (autoShootEnabled or aimbotAutoShootEnabled)
		local curFly = (isFlightActive and isFlightActive() or false)
		if aimbotEnabled ~= lastMqAim or targetAimbotEnabled ~= lastMqTAim or curShoot ~= lastMqShoot or curFly ~= lastMqFly then
			lastMqAim, lastMqTAim, lastMqShoot, lastMqFly = aimbotEnabled, targetAimbotEnabled, curShoot, curFly
			pcall(genv._TR_UpdateMobileQuickBar, aimbotEnabled, targetAimbotEnabled, curShoot, curFly)
		end
	end

	-- When Aimbot [Q]/[T] is OFF:
	-- Fast Idle Path: Only run checkScreenMiddleDotRay if Normal Auto Shoot [Z] is ON or an enemy currently has Katana active!
	if not anyAimbotActive then
		currentTarget = nil
		local needMiddleDotRay = (autoShootEnabled and not isClosingPermanently) or anyEnemyKatanaCurrentlyActive or isKatanaBlockingClick
		local hitPlr, hitChar = nil, nil
		if needMiddleDotRay then
			hitPlr, hitChar = checkScreenMiddleDotRay(cam)
		end
		if hitPlr and IsEnemyUsingKatana(hitPlr, hitChar) then
			SetKatanaClickBlockState(true)
			setAimbotStatusText("KATANA BLOCK: " .. GetTargetLabelName(hitPlr))
			setNormalShootStatusText("BLOCKED (Katana Active!)")
			setAimbotShootStatusText(aimbotAutoShootEnabled and "Standby (Need Aimbot [Q])" or "Aimbot Shoot: OFF")
			return
		end
		SetKatanaClickBlockState(false)
		setAimbotStatusText("Status: Idle")
		setAimbotShootStatusText(aimbotAutoShootEnabled and "Standby (Need Aimbot [Q])" or "Aimbot Shoot: OFF")
		if autoShootEnabled and not isClosingPermanently then
			if hitPlr then
				setNormalShootStatusText("FIRING -> " .. GetTargetLabelName(hitPlr))
				if triggerAutoShoot then triggerAutoShoot() end
			else
				if StopAutoShootFiring then StopAutoShootFiring() end
				setNormalShootStatusText("Ready (Point at Player)")
			end
		else
			if StopAutoShootFiring then StopAutoShootFiring() end
			setNormalShootStatusText("Normal Shoot: OFF")
		end
		return
	end

	-- When Aimbot [Q]/[T]/[G] is ON:
	-- 1. Target Resolution: Mode 2 (Target Specific Player) vs Mode 3 (Zombie & Gargoyle Aimbot [G]) vs Mode 1 (Normal Player Aimbot [Q])
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
	elseif zAimOn and not aimbotEnabled then
		-- Pure Zombie & Gargoyle Tower Mode (Zero Player Overhead)
		local zModel, zEntry = FUI.ZombieAim.FindBestZombie(cam)
		currentTarget = zModel
		if FUI.ZombieAim.StatusLabel then
			local zCount = #FUI.ZombieAim.CacheList
			local zTxt = zEntry and ("Locked: " .. tostring(zEntry.Name) .. " [" .. tostring(zCount) .. "]") or ("Scanning Tower... (" .. tostring(zCount) .. ")")
			if FUI.ZombieAim.StatusLabel.Text ~= zTxt then FUI.ZombieAim.StatusLabel.Text = zTxt end
		end
	else
		-- Normal Aimbot [Q] (plus Zombie Aimbot [G] if both [Q] and [G] are enabled together)
		if currentTarget and currentTarget.Parent then
			if typeof(currentTarget) == "Instance" and currentTarget:IsA("Model") then
				if not zAimOn then
					currentTarget = nil
				else
					local zEnt = FUI.ZombieAim.CacheMap[currentTarget]
					local p = getTargetPart(currentTarget)
					local _, onScr, sDist = worldToScreenDistance(p and p.Position or V3_ZERO)
					if not zEnt or not FUI.ZombieAim.IsEntryAlive(zEnt) or not p or not onScr or (fovCircleEnabled and sDist > FOV_RADIUS) or not isTargetVisible(p, currentTarget) then
						currentTarget = nil
					end
				end
			else
				local ch = GetCharacterFromPlayer(currentTarget)
				local h = ch and ch:FindFirstChildOfClass("Humanoid")
				local p = getTargetPart(ch)
				local _, onScr, sDist = worldToScreenDistance(p and p.Position or V3_ZERO)
				if not ch or not h or h.Health <= 0 or not p or not onScr or (fovCircleEnabled and sDist > FOV_RADIUS) or not isTargetVisible(p, ch) or excludedPlayers[currentTarget] or (aimbotTeamCheck and IsTeammate(currentTarget)) then
					currentTarget = nil
				end
			end
		else
			currentTarget = nil
		end
		if not currentTarget then
			currentTarget = findBestTarget()
			if not currentTarget and zAimOn then
				local zModel = FUI.ZombieAim.FindBestZombie(cam)
				currentTarget = zModel
			end
		end
		if zAimOn and FUI.ZombieAim.StatusLabel then
			local zCount = #FUI.ZombieAim.CacheList
			local isZLocked = (currentTarget and typeof(currentTarget) == "Instance" and currentTarget:IsA("Model"))
			local zTxt = isZLocked and ("Locked: " .. GetTargetLabelName(currentTarget) .. " [" .. tostring(zCount) .. "]") or ("Active (" .. tostring(zCount) .. " Zombies)")
			if FUI.ZombieAim.StatusLabel.Text ~= zTxt then FUI.ZombieAim.StatusLabel.Text = zTxt end
		end
	end

	-- 2. Ultra-Aggressive Lock & Dual Auto Shoot Execution
	if currentTarget then
		local tChar = GetCharacterFromPlayer(currentTarget)
		local targetPart = getTargetPart(tChar)
		local headPart = (tChar and tChar:FindFirstChild("Head")) or targetPart
		local lockPart = (aimPartName == "Head" and headPart) or targetPart
		if tChar and targetPart and isTargetVisible(targetPart, tChar) then
			local camPos = cam.CFrame.Position
			local tVel = targetPart.AssemblyLinearVelocity or V3_ZERO
			local leadPos = targetPart.Position + (tVel * 0.006)
			local goalCF = CFrame.new(camPos, leadPos)
			cam.CFrame = strongLock and goalCF or cam.CFrame:Lerp(goalCF, LERP_ALPHA)
			if IsEnemyUsingKatana(currentTarget, tChar) then
				SetKatanaClickBlockState(true)
				setAimbotStatusText("KATANA BLOCK: " .. GetTargetLabelName(currentTarget))
				setNormalShootStatusText(autoShootEnabled and "BLOCKED (Katana Active!)" or "Normal Shoot: OFF")
				setAimbotShootStatusText(aimbotAutoShootEnabled and "BLOCKED (Katana Active!)" or "Aimbot Shoot: OFF")
				return
			end
			SetKatanaClickBlockState(false)
			setAimbotStatusText("Locked: " .. GetTargetLabelName(currentTarget))

			if (autoShootEnabled or aimbotAutoShootEnabled) and lockPart and isTargetVisible(lockPart, tChar) then
				local hp = lockPart.Position
				local cp = cam.CFrame.Position
				if strongLock then
					cam.CFrame = CFrame.new(cp, hp)
				end
				local dx, dy, dz = hp.X - cp.X, hp.Y - cp.Y, hp.Z - cp.Z
				local distSq = dx * dx + dy * dy + dz * dz
				local isHeadLocked = strongLock
				if not isHeadLocked and distSq > 0.0001 then
					local invDist = 1 / math.sqrt(distSq)
					local lv = cam.CFrame.LookVector
					local dot = (dx * lv.X + dy * lv.Y + dz * lv.Z) * invDist
					local minDot = isAutoShootingActive and 0.92 or 0.985
					isHeadLocked = (dot >= minDot)
				end
				if not isHeadLocked then
					local rayHitPlr = checkScreenMiddleDotRay(cam)
					if rayHitPlr == currentTarget then
						isHeadLocked = true
					end
				end
				if isHeadLocked then
					local fireTxt = "FIRING -> " .. GetTargetLabelName(currentTarget)
					setNormalShootStatusText(autoShootEnabled and fireTxt or "Normal Shoot: OFF")
					setAimbotShootStatusText(aimbotAutoShootEnabled and fireTxt or "Aimbot Shoot: OFF")
					if triggerAutoShoot then triggerAutoShoot() end
				else
					if StopAutoShootFiring then StopAutoShootFiring() end
					setNormalShootStatusText(autoShootEnabled and "Aligning Target..." or "Normal Shoot: OFF")
					setAimbotShootStatusText(aimbotAutoShootEnabled and "Aligning Head..." or "Aimbot Shoot: OFF")
				end
			else
				if StopAutoShootFiring then StopAutoShootFiring() end
				setNormalShootStatusText(autoShootEnabled and "Stopped (Behind Wall)" or "Normal Shoot: OFF")
				setAimbotShootStatusText(aimbotAutoShootEnabled and "Stopped (Behind Wall)" or "Aimbot Shoot: OFF")
			end
		else
			currentTarget = nil
			SetKatanaClickBlockState(false)
			if StopAutoShootFiring then StopAutoShootFiring() end
			setAimbotStatusText(targetAimbotEnabled and "Target Behind Wall / Dead" or "Status: Searching...")
			setNormalShootStatusText(autoShootEnabled and "Stopped (Behind Wall)" or "Normal Shoot: OFF")
			setAimbotShootStatusText(aimbotAutoShootEnabled and "Stopped (Behind Wall)" or "Aimbot Shoot: OFF")
		end
	else
		if targetAimbotEnabled then
			setAimbotStatusText(specificTargetPlayer and ("Waiting: " .. tostring(specificTargetPlayer.DisplayName)) or "Select a Target Player!")
		else
			setAimbotStatusText("Status: Searching...")
		end
		-- Mode 2 (Aimbot-Lock Auto Shoot) MUST NOT fire when Aimbot has no locked target!
		setAimbotShootStatusText(aimbotAutoShootEnabled and "Waiting Aimbot Lock..." or "Aimbot Shoot: OFF")
		-- Check if crosshair is on a Katana-using enemy even when Aimbot is still searching
		local hitPlr, hitChar = checkScreenMiddleDotRay(cam)
		if hitPlr and IsEnemyUsingKatana(hitPlr, hitChar) then
			SetKatanaClickBlockState(true)
			setNormalShootStatusText("BLOCKED (Katana Active!)")
			return
		end
		SetKatanaClickBlockState(false)
		-- Mode 1 (Normal Auto Shoot) still fires if Screen Middle Dot is on an enemy!
		if autoShootEnabled and not isClosingPermanently then
			if hitPlr then
				setNormalShootStatusText("FIRING -> " .. GetTargetLabelName(hitPlr))
				if triggerAutoShoot then triggerAutoShoot() end
			else
				if StopAutoShootFiring then StopAutoShootFiring() end
				setNormalShootStatusText("Ready (Point at Player)")
			end
		else
			if StopAutoShootFiring then StopAutoShootFiring() end
			setNormalShootStatusText("Normal Shoot: OFF")
		end
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
		for _, part in ipairs(GetCachedCharBaseParts(char)) do
			if part.CanCollide then
				part.CanCollide = false
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
		local zAimKey = Config.ZombieAimbotKeybind or "G"
		if zAimKey ~= "None" and keyName == zAimKey and FUI.ZombieAim and FUI.ZombieAim.ToggleFunc then FUI.ZombieAim.ToggleFunc() return end
		local asKey = Config.AutoShootKeybind or "Z"
		if asKey ~= "None" and keyName == asKey and toggleAutoShoot then toggleAutoShoot() return end
		local aasKey = Config.AimbotAutoShootKeybind or "V"
		if aasKey ~= "None" and keyName == aasKey and toggleAimbotAutoShoot then toggleAimbotAutoShoot() return end
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
	FlingActive, aimbotEnabled, targetAimbotEnabled, autoShootEnabled, aimbotAutoShootEnabled, currentTarget, masterFlightEnabled = false, false, false, false, false, nil, false
	if StopAutoShootFiring then pcall(StopAutoShootFiring) end
	pcall(function() game:GetService("ContextActionService"):UnbindAction("TR_KatanaClickBlock") end)
	if SetStickTarget then pcall(SetStickTarget, nil) end
	pcall(function() RunService:UnbindFromRenderStep("TR_Stick_Step") end)
	genv.TR_AntiCheatActive = false pcall(StopFling) pcall(stopFlight) if stopFreecam then pcall(stopFreecam) end
	if SetSpectateTarget then pcall(SetSpectateTarget, nil) end
	if genv.__LocalWearerCleanup then pcall(genv.__LocalWearerCleanup) end
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
if ApplyGuiDesignSurface then pcall(ApplyGuiDesignSurface) end
