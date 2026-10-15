local XL,XR,XC,MB1,TCH,MMV,UEND,tins,KC,HST,ES,ED=Enum.TextXAlignment.Left,Enum.TextXAlignment.Right,Enum.TextXAlignment.Center,Enum.UserInputType.MouseButton1,Enum.UserInputType.Touch,Enum.UserInputType.MouseMovement,Enum.UserInputState.End,table.insert,Enum.KeyCode,Enum.HumanoidStateType,Enum.EasingStyle,Enum.EasingDirection
local mclamp,mfloor,sfmt,twait,tdelay,tspawn=math.clamp,math.floor,string.format,task.wait,task.delay,task.spawn
local c1=game:GetService("Players") local cs=game:GetService("RunService") local aA=game:GetService("UserInputService")
local cM=game:GetService("TweenService") local fG=game:GetService("HttpService") local bM=game:GetService("Lighting")
local f1=game:GetService("ProximityPromptService") local hw=game:GetService("VirtualUser")
local jk=game:GetService("StarterGui") local g2=game:GetService("CoreGui") local aY=c1.LocalPlayer or c1.PlayerAdded:Wait()
local LocalPlayer=aY local ji=workspace.CurrentCamera local ih=(getgenv and getgenv())or _G local U=utf8.char
local cX,U2,U1,V2,V3,CF,kN,cK=Color3.fromRGB,UDim2.new,UDim.new,Vector2.new,Vector3.new,CFrame.new,CFrame.Angles,Instance.new
local d0,fg,kO,kv,kR=Enum.Font.GothamBold,Enum.Font.GothamSemibold,Enum.Font.GothamMedium,Enum.Font.Gotham,Enum.Font.Code
local E={ a=U(0x26A1), b=U(0x1F4BE), c=U(0x2714), d=U(0x2014), e=U(0x00D7), f=U(0x1F4CA),
g=U(0x1F4CD), h=U(0x1F4E1), i=U(0x1F48E), j=U(0x1F680), k=U(0x1F441), l=U(0x1F4BB), m=U(0x1F31E),
n=U(0x1F319), o=U(0x1F513), p=U(0x1F4CB), q=U(0x2795), r=U(0x1F5D1), s=U(0x2B50), t=U(0x1F50D),
u=U(0x1F504), v=U(0x1F9F2), w=U(0x1F4E6), x=U(0x25B6), y=U(0x1F9F9), z=U(0x23F9), Aa=U(0x2713),
Ab=U(0x25E2), Ac=U(0x1F3AF) } local iw=aY:WaitForChild("PlayerGui") local bn={} local function gy()
pcall(function()cs:UnbindFromRenderStep("Aimbot_v2")end) pcall(function()cs:UnbindFromRenderStep("TR_ShiftLock_Pre")end)
pcall(function()if cleardrawcache then cleardrawcache()end end)
for _,name in ipairs({"TRScriptsHub","UtilityHubGui","TRScriptsFlingGui","AimbotUI_v2"})do pcall(function()
local c=g2:FindFirstChild(name) if c then c:Destroy()end end) pcall(function() local pg=aY:FindFirstChildOfClass("PlayerGui")
local g=pg and pg:FindFirstChild(name) if g then g:Destroy()end end) end pcall(function()
for _,hp in ipairs(workspace:GetChildren())do if hp.Name=="TR_FakeFloor" then hp:Destroy()end end end) pcall(function()
local pg=aY:FindFirstChildOfClass("PlayerGui") if pg then for _,ch in ipairs(pg:GetChildren())do
if ch.Name=="ESP_HitboxInner" or ch.Name=="ESP_HitboxOutline" then ch:Destroy()end end end end) pcall(function()
for _,dm in ipairs(c1:GetPlayers())do local ln=dm.Character and dm.Character:FindFirstChild("TR_ESP_Highlight")
if ln then ln:Destroy()end end end) end gy() local function hq() if gethui then local ok,lg=pcall(gethui)
if ok and lg then return lg end end local ok,dk=pcall(function() local _=g2:GetChildren() local t=cK("ScreenGui")
t.Name="TR_CoreTest" t.Parent=g2 t:Destroy() return g2 end) if ok and dk then return dk end
return aY:WaitForChild("PlayerGui") end
local h8=setclipboard or toclipboard or set_clipboard or(Clipboard and Clipboard.set)or function()end
local h9=writefile or function()end local g3=readfile or function()return nil end
local g0=isfile or function()return false end local gw=loadstring or function()return nil,"loadstring unavailable" end
local gQ=firetouchinterest or function()end local gj=fireproximityprompt or function(fW) pcall(function() fW:InputHoldBegin()
twait() fW:InputHoldEnd() end) end local e3="TRScripts_Config_V100.json" local hU={
"TRScripts_Config_V99.json","TRScripts_Config_V98.json","TRScripts_Config_V97.json",
"TRScripts_Config_V96.json","TRScripts_Config_V95.json","TRScripts_Config_V94.json",
"TRScripts_Config_V93.json","TRScripts_Config_V92.json" } local ii={ Settings={ Theme="Default", WindowWidth=760,
WindowHeight=480, WalkSpeed=16, JumpPower=50, FOV=70, FlySpeed=50, FlyKeybind="E", MouseLockKeybind="M", AimbotKeybind="Q",
AimbotFOVRadius=200, AimbotFOVCircleEnabled=true, AimbotEnabled=false, StrongLock=false, WallcheckEnabled=true,
AimPartName="Head", MasterUtilityEnabled=false, MasterFlightEnabled=false, NoclipEnabled=false, AntiFlingEnabled=false,
AutoSelectFling=false, AntiCheatBypass=true, ShiftDownEnabled=true, CountdownBypass=false, AntiAFK=true, InstantPrompt=false,
ESPEnabled=false, FullbrightEnabled=false, CameraOverrideMode="Free / Unlocked", LockedTime=nil }, Waypoints={
{Name="Spawn Point",X=0,Y=50,Z=0,Keybind="None"} }, RadarKeybinds={}, ExecutorTabs={
{Name="Script 1",Code="-- Welcome to T.R Scripts V94\nprint('T.R Scripts V94 Ready!')"} }, ActiveExecutorTab=1 }
local ae=fG:JSONDecode(fG:JSONEncode(ii)) local ao=ae.Settings local c3=nil local function aj(gZ) pcall(function()
h9(e3,fG:JSONEncode(ae)) end) if gZ and c3 then c3() end end local function gf() aj(false) end local function jh()
pcall(function() local fZ=nil if g0(e3)then fZ=e3 else for _,f in ipairs(hU)do if g0(f)then fZ=f break end end end if fZ then
local k6=g3(fZ) if k6 and #k6>0 then local dw=fG:JSONDecode(k6) if type(dw)=="table" then if type(dw.Settings)=="table" then
for k,v in pairs(dw.Settings)do ae.Settings[k]=v end else for k,v in pairs(dw)do
if ae.Settings[k]~=nil then ae.Settings[k]=v end end end if type(dw.Waypoints)=="table" then ae.Waypoints=dw.Waypoints end
if type(dw.RadarKeybinds)=="table" then ae.RadarKeybinds=dw.RadarKeybinds end
if type(dw.ExecutorTabs)=="table" then ae.ExecutorTabs=dw.ExecutorTabs end
if type(dw.ActiveExecutorTab)=="number" then ae.ActiveExecutorTab=dw.ActiveExecutorTab end end end end end) end jh()
local bF={ ClockTime=bM.ClockTime, Brightness=bM.Brightness, GlobalShadows=bM.GlobalShadows, OutdoorAmbient=bM.OutdoorAmbient
} local ek={ FOV=(workspace.CurrentCamera and workspace.CurrentCamera.FieldOfView)or 70, CameraMode=aY.CameraMode,
MinZoom=aY.CameraMinZoomDistance, MaxZoom=aY.CameraMaxZoomDistance }
local i4={"Default","Crimson Blood","Matrix Neon","Cyber Cyan","Solar Gold","Sakura Pink"} local hK={ ["Default"]={
MainBg=cX(11,8,18),PanelBg=cX(17,12,28),CardBg=cX(24,17,38),
Accent=cX(118,62,215),AccentDark=cX(72,36,140),Stroke=cX(135,85,225),
TextPrimary=cX(235,230,245),TextSecondary=cX(160,148,190) }, ["Crimson Blood"]={
MainBg=cX(15,7,9),PanelBg=cX(24,10,14),CardBg=cX(34,14,20),
Accent=cX(185,38,58),AccentDark=cX(115,20,34),Stroke=cX(205,60,80), TextPrimary=cX(242,228,232),TextSecondary=cX(185,145,155)
}, ["Matrix Neon"]={ MainBg=cX(7,13,9),PanelBg=cX(11,21,15),CardBg=cX(16,30,22),
Accent=cX(26,168,86),AccentDark=cX(16,105,54),Stroke=cX(48,195,108),
TextPrimary=cX(225,242,232),TextSecondary=cX(140,185,158) }, ["Cyber Cyan"]={
MainBg=cX(7,12,18),PanelBg=cX(11,19,29),CardBg=cX(16,27,40),
Accent=cX(18,152,198),AccentDark=cX(12,96,130),Stroke=cX(45,178,220),
TextPrimary=cX(225,240,248),TextSecondary=cX(140,175,198) }, ["Solar Gold"]={
MainBg=cX(14,11,7),PanelBg=cX(22,18,10),CardBg=cX(32,25,14),
Accent=cX(195,138,24),AccentDark=cX(125,86,14),Stroke=cX(215,162,52),
TextPrimary=cX(245,238,225),TextSecondary=cX(185,168,135) }, ["Sakura Pink"]={
MainBg=cX(15,8,13),PanelBg=cX(24,12,21),CardBg=cX(34,18,30),
Accent=cX(195,58,132),AccentDark=cX(125,32,84),Stroke=cX(215,92,158),
TextPrimary=cX(245,230,240),TextSecondary=cX(188,148,172) } } local cq={
MainBg={},PanelBg={},CardBg={},Accent={},AccentDark={}, Stroke={},TextPrimary={},TextSecondary={},CustomCallbacks={} }
local function cQ() return hK[ao.Theme]or hK["Default"] end local function aa(iY,kW,g4)
tins(cq[g4],{Instance=iY,Property=kW}) iY[kW]=cQ()[g4] end local function gX(dV) if not hK[dV]then dV="Default" end
ao.Theme=dV local i7=hK[dV] for ka,list in pairs(cq)do if ka~="CustomCallbacks" and i7[ka]then for _,item in ipairs(list)do
if item.Instance and item.Instance.Parent then cM:Create(item.Instance,TweenInfo.new(0.25,ES.Quad,ED.Out),{
[item.Property]=i7[ka] }):Play() end end end end for _,fn in ipairs(cq.CustomCallbacks)do pcall(fn,i7)end aj(false) end
local function aB(dk,kt) local c=cK("UICorner") c.CornerRadius=U1(0,kt or 6) c.Parent=dk return c end
local function az(dk,kq,hh,jV,hN,hX) local b=cK("TextButton") b.Size=kq if hh then b.Position=hh end b.Font=d0
b.TextSize=hX or 12 b.Text=jV b.Parent=dk if hN then aa(b,"BackgroundColor3",hN) end aa(b,"TextColor3","TextPrimary") aB(b,6)
return b end local function cW(dk,kq,hh,jV,k3,hX,g4,ku) local l=cK("TextLabel") l.Size=kq if hh then l.Position=hh end
l.BackgroundTransparency=1 l.Font=k3 or fg l.TextSize=hX or 12 l.TextXAlignment=ku or XL l.Text=jV l.Parent=dk
aa(l,"TextColor3",g4 or "TextPrimary") return l end local dX=cK("ScreenGui") dX.Name="TRScriptsHub" dX.ResetOnSpawn=false
dX.ZIndexBehavior=Enum.ZIndexBehavior.Sibling dX.IgnoreGuiInset=true dX.Parent=hq() local iq,hS=560,360 local iJ,hL=1150,820
local c9=mclamp(tonumber(ao.WindowWidth)or 760,iq,iJ) local cV=mclamp(tonumber(ao.WindowHeight)or 480,hS,hL)
local aF=cK("Frame") aF.Name="MainFrame" aF.AnchorPoint=V2(0.5,0.5) aF.Size=U2(0,c9,0,cV) aF.Position=U2(0.5,0,0.5,0)
aF.BackgroundTransparency=0.06 aF.BorderSizePixel=0 aF.ClipsDescendants=true aF.Parent=dX aa(aF,"BackgroundColor3","MainBg")
aB(aF,12) local fO=cK("UIScale") fO.Scale=1 fO.Parent=aF local dA=cK("UIStroke") dA.Thickness=1.6 dA.Transparency=0.25
dA.Parent=aF aa(dA,"Color","Stroke") local d6=cK("Frame") d6.Name="TopBar" d6.Size=U2(1,0,0,44) d6.BackgroundTransparency=0.1
d6.BorderSizePixel=0 d6.Parent=aF aa(d6,"BackgroundColor3","PanelBg") aB(d6,12)
local kz=cW(d6,U2(0,420,1,0),U2(0,16,0,0),E.a .. " T.R Scripts - Master Script Hub (V94)",d0,15,"TextPrimary",XL)
local dp=cK("TextLabel") dp.Size=U2(0,125,0,24) dp.Position=U2(1,-242,0.5,-12) dp.BackgroundTransparency=0.15 dp.Font=fg
dp.TextSize=11 dp.Text="Toggle UI: [X]" dp.Parent=d6 aa(dp,"BackgroundColor3","CardBg") aa(dp,"TextColor3","TextSecondary")
aB(dp,6) local g5=az(d6,U2(0,34,0,28),U2(1,-108,0.5,-14),E.b,"CardBg",14) c3=function() g5.Text=E.c
tdelay(1.1,function() if g5 and g5.Parent then g5.Text=E.b end end) end
g5.MouseButton1Click:Connect(function()aj(true)end) local kj=az(d6,U2(0,32,0,28),U2(1,-68,0.5,-14),E.d,"CardBg",14)
local dn=cK("TextButton") dn.Size=U2(0,28,0,28) dn.Position=U2(1,-30,0.5,-14) dn.BackgroundColor3=cX(175,38,55) dn.Font=d0
dn.TextSize=14 dn.Text=E.e dn.TextColor3=cX(255,255,255) dn.Parent=d6 aB(dn,6) local cj=aF.Position local fI=true
local a8=false local cP={} local aI=nil local e0,bW=false,nil do local hg,dq=nil,nil local fN,bS,cp=nil,nil,nil
d6.InputBegan:Connect(function(bR) if bW then return end if bR.UserInputType==MB1 or bR.UserInputType==TCH then e0=true
hg=bR.Position dq=aF.Position bR.Changed:Connect(function() if bR.UserInputState==UEND then e0=false end end) end end)
local dU=cK("TextButton",aF) dU.Size=U2(0,7,1,-24) dU.Position=U2(1,-7,0,12) dU.BackgroundTransparency=1 dU.Text=""
dU.ZIndex=10 local dh=cK("TextButton",aF) dh.Size=U2(1,-24,0,7) dh.Position=U2(0,12,1,-7) dh.BackgroundTransparency=1
dh.Text="" dh.ZIndex=10 local bU=cK("TextButton",aF) bU.Size=U2(0,20,0,20) bU.Position=U2(1,-20,1,-20)
bU.BackgroundTransparency=1 bU.Font=d0 bU.TextSize=13 bU.Text=E.Ab bU.ZIndex=12 aa(bU,"TextColor3","Accent")
local function gF(jH,bR) if bR.UserInputType==MB1 or bR.UserInputType==TCH then e0=false bW=jH fN=bR.Position bS=V2(c9,cV)
cp=aF.Position bR.Changed:Connect(function() if bR.UserInputState==UEND then bW=nil ao.WindowWidth=c9 ao.WindowHeight=cV
aj(false) end end) end end bU.InputBegan:Connect(function(i)gF("Corner",i)end)
dU.InputBegan:Connect(function(i)gF("Right",i)end) dh.InputBegan:Connect(function(i)gF("Bottom",i)end)
tins(bn,aA.InputChanged:Connect(function(bR) if bR.UserInputType~=MMV and bR.UserInputType~=TCH then return end if bW then
local g8=bR.Position-fN local kA,kp=bS.X,bS.Y if bW=="Corner" or bW=="Right" then
kA=mclamp(mfloor(bS.X+g8.X+0.5),iq,iJ) end if bW=="Corner" or bW=="Bottom" then
kp=mclamp(mfloor(bS.Y+g8.Y+0.5),hS,hL) end c9,cV=kA,kp aF.Size=U2(0,c9,0,cV) cj=U2(
cp.X.Scale,cp.X.Offset+mfloor((kA-bS.X)*0.5+0.5), cp.Y.Scale,cp.Y.Offset+mfloor((kp-bS.Y)*0.5+0.5) ) aF.Position=cj
elseif e0 then local g8=bR.Position-hg cj=U2( dq.X.Scale,dq.X.Offset+g8.X, dq.Y.Scale,dq.Y.Offset+g8.Y ) aF.Position=cj end
end)) end local function d3(bq,fQ) if a8 then return end for _,tw in ipairs(cP)do pcall(function()tw:Cancel()end)end cP={}
fI=bq if aI then aI()end if bq then aF.Visible=true aF.Size=U2(0,c9,0,cV) local i8=TweenInfo.new(0.26,ES.Quint,ED.Out)
local t1=cM:Create(fO,i8,{Scale=1}) local t2=cM:Create(aF,i8,{Position=cj,BackgroundTransparency=0.06})
local t3=cM:Create(dA,i8,{Transparency=0.25}) cP={t1,t2,t3} t1:Play()t2:Play()t3:Play() t1.Completed:Connect(function(st)
if st==Enum.PlaybackState.Completed and fQ then fQ()end end) else e0,bW=false,nil
local i8=TweenInfo.new(0.22,ES.Quint,ED.Out) local t1=cM:Create(fO,i8,{Scale=0})
local t2=cM:Create(aF,i8,{Position=cj,BackgroundTransparency=1}) local t3=cM:Create(dA,i8,{Transparency=1}) cP={t1,t2,t3}
t1:Play()t2:Play()t3:Play() t1.Completed:Connect(function(st) if st==Enum.PlaybackState.Completed then
if not fI then aF.Visible=false end if fQ then fQ()end end end) end end fO.Scale=0 aF.BackgroundTransparency=1
dA.Transparency=1 d3(true) kj.MouseButton1Click:Connect(function()d3(false)end) local cZ=cK("ScrollingFrame")
cZ.Size=U2(0,185,1,-56) cZ.Position=U2(0,10,0,50) cZ.BackgroundTransparency=0.12 cZ.BorderSizePixel=0 cZ.ScrollBarThickness=3
cZ.CanvasSize=U2(0,0,0,0) cZ.AutomaticCanvasSize=Enum.AutomaticSize.Y cZ.Parent=aF aa(cZ,"BackgroundColor3","PanelBg")
aa(cZ,"ScrollBarImageColor3","Accent") aB(cZ,10) local eu=cK("UIListLayout") eu.Padding=U1(0,6)
eu.HorizontalAlignment=Enum.HorizontalAlignment.Center eu.SortOrder=Enum.SortOrder.LayoutOrder eu.Parent=cZ
local gW=cK("UIPadding") gW.PaddingTop=U1(0,8) gW.PaddingBottom=U1(0,8) gW.Parent=cZ local bx=cK("Frame")
bx.Size=U2(1,-210,1,-56) bx.Position=U2(0,200,0,50) bx.BackgroundTransparency=0.12 bx.BorderSizePixel=0 bx.Parent=aF
aa(bx,"BackgroundColor3","PanelBg") aB(bx,10) local j6={} local cU=nil local function dc(hf,jJ,gO) local e6=cK("TextButton")
e6.LayoutOrder=gO e6.Size=U2(1,-14,0,38) e6.BackgroundTransparency=0.1 e6.Font=fg e6.TextSize=13 e6.TextXAlignment=XL
e6.Text="   " .. jJ .. "  " .. hf e6.Parent=cZ aa(e6,"TextColor3","TextPrimary") aB(e6,8) local Page=cK("ScrollingFrame")
Page.Size=U2(1,-16,1,-16) Page.Position=U2(0,8,0,8) Page.BackgroundTransparency=1 Page.BorderSizePixel=0
Page.ScrollBarThickness=4 Page.CanvasSize=U2(0,0,0,0) Page.AutomaticCanvasSize=Enum.AutomaticSize.Y Page.Visible=false
Page.Parent=bx aa(Page,"ScrollBarImageColor3","Accent") local gV=cK("UIListLayout") gV.Padding=U1(0,8)
gV.SortOrder=Enum.SortOrder.LayoutOrder gV.Parent=Page local g9=cK("UIPadding") g9.PaddingTop=U1(0,4)
g9.PaddingBottom=U1(0,10) g9.PaddingLeft=U1(0,4) g9.PaddingRight=U1(0,8) g9.Parent=Page j6[hf]={Button=e6,Page=Page}
local function d4() local eU=cQ() for name,data in pairs(j6)do
data.Button.BackgroundColor3=(name==cU)and eU.Accent or eU.CardBg
data.Button.BackgroundTransparency=(name==cU)and 0.02 or 0.2 end end tins(cq.CustomCallbacks,d4)
e6.MouseButton1Click:Connect(function() cU=hf for name,data in pairs(j6)do data.Page.Visible=(name==hf)end d4() end)
if gO==1 then cU=hf Page.Visible=true d4() end return Page end local function aq(dk,jR,gO) local fH=cK("TextLabel")
fH.LayoutOrder=gO fH.Size=U2(1,0,0,24) fH.BackgroundTransparency=1 fH.Font=d0 fH.TextSize=14 fH.TextXAlignment=XL
fH.Text="  " .. jR fH.Parent=dk aa(fH,"TextColor3","Accent") return fH end local function aW(dk,kD,gO) local Card=cK("Frame")
Card.LayoutOrder=gO Card.Size=U2(1,0,0,kD) Card.BackgroundTransparency=0.12 Card.BorderSizePixel=0 Card.Parent=dk
aa(Card,"BackgroundColor3","CardBg") aB(Card,8) local Stroke=cK("UIStroke") Stroke.Thickness=1 Stroke.Transparency=0.6
Stroke.Parent=Card aa(Stroke,"Color","Stroke") return Card end local function a1(dk,hv,iS,gO,gk) local Card=aW(dk,42,gO)
local Label=cW(Card,U2(1,-110,1,0),U2(0,14,0,0),hv,fg,13,"TextPrimary",XL)
local hm=az(Card,U2(0,84,0,28),U2(1,-96,0.5,-14),"OFF",nil,12) local bq=iS and true or false local function dM()
local eU=cQ() hm.Text=bq and "ON" or "OFF" hm.BackgroundColor3=bq and eU.Accent or eU.PanelBg end tins(cq.CustomCallbacks,dM)
dM() local function SetState(hO,hD) bq=hO and true or false dM() if hD~=false and gk then pcall(gk,bq)end end
hm.MouseButton1Click:Connect(function()SetState(not bq,true)end)
return{SetState=SetState,GetState=function()return bq end,Card=Card} end local function c7(dk,hv,g1,iM,h0,gO,gk)
local Card=aW(dk,58,gO) local Title=cW(Card,U2(0.65,0,0,22),U2(0,14,0,6),hv,fg,13,"TextPrimary",XL)
local hV=cW(Card,U2(0.3,-14,0,22),U2(0.7,0,0,6),tostring(h0),d0,13,"Accent",XR) local f5=cK("Frame") f5.Size=U2(1,-28,0,12)
f5.Position=U2(0,14,0,34) f5.BorderSizePixel=0 f5.Parent=Card aa(f5,"BackgroundColor3","PanelBg") aB(f5,10)
local i6=cK("Frame") local jw=mclamp((h0-g1)/(iM-g1),0,1) i6.Size=U2(jw,0,1,0) i6.BorderSizePixel=0 i6.Parent=f5
aa(i6,"BackgroundColor3","Accent") aB(i6,10) local iK=false local function f6(jz)
local kY=mclamp(jz-f5.AbsolutePosition.X,0,f5.AbsoluteSize.X) local kd=(f5.AbsoluteSize.X>0)and(kY/f5.AbsoluteSize.X)or 0
local j9=mfloor(g1+(iM-g1)*kd+0.5) i6.Size=U2(kd,0,1,0) hV.Text=tostring(j9) if gk then pcall(gk,j9)end end
f5.InputBegan:Connect(function(bR) if bR.UserInputType==MB1 or bR.UserInputType==TCH then iK=true f6(bR.Position.X)
bR.Changed:Connect(function() if bR.UserInputState==UEND then iK=false end end) end end) tins(bn,aA.InputChanged:Connect(function(bR)
if iK and(bR.UserInputType==MMV or bR.UserInputType==TCH)then f6(bR.Position.X) end end)) return{ SetValue=function(js)
local clamped=mclamp(js,g1,iM) i6.Size=U2((clamped-g1)/(iM-g1),0,1,0) hV.Text=tostring(clamped) end } end
local bz=dc("Themes & Status",E.f,1) local d5=dc("Waypoints & TP",E.g,2) local h4=dc("Player Radar",E.h,3)
local fw=dc("Items & Prompts",E.i,4) local bL=dc("Flight & Movement",E.j,5) local f2=dc("Target Fling",E.a,6)
local a2=dc("Aimbot & Visuals",E.Ac,7) local d8=dc("Script Executor",E.l,8) local cI,aD,ah do
aq(bz,"UI Theme Customizer (6 Dark Themes)",1) local iH=aW(bz,88,2) local fk=cK("UIGridLayout") fk.CellSize=U2(0,160,0,32)
fk.CellPadding=U2(0,10,0,8) fk.HorizontalAlignment=Enum.HorizontalAlignment.Center
fk.VerticalAlignment=Enum.VerticalAlignment.Center fk.SortOrder=Enum.SortOrder.LayoutOrder fk.Parent=iH
for idx,dV in ipairs(i4)do local iT=cK("TextButton") iT.LayoutOrder=idx iT.BackgroundColor3=hK[dV].Accent iT.Font=d0
iT.TextSize=12 iT.TextColor3=cX(245,245,250) iT.Text=dV iT.Parent=iH aB(iT,6)
iT.MouseButton1Click:Connect(function()gX(dV)end) end aq(bz,"Live Performance & Mouse Lock (Shift Lock) Controls",3)
local jF=aW(bz,46,4) cI=cK("TextLabel") cI.Size=U2(1,-24,1,0) cI.Position=U2(0,12,0,0) cI.BackgroundTransparency=1 cI.Font=fg
cI.TextSize=13 cI.TextXAlignment=XL cI.Text="FPS: --  |  Ping: -- ms  |  Mouse Lock [M]: OFF" cI.Parent=jF
aa(cI,"TextColor3","TextPrimary") aD=false local du=aW(bz,92,5) local a3=cK("TextButton",du) a3.Size=U2(0.48,-12,0,34)
a3.Position=U2(0,10,0,10) a3.Font=d0 a3.TextSize=12 a3.TextColor3=cX(255,255,255) aB(a3,6) local aV=cK("TextLabel",du)
aV.Size=U2(0.52,-14,0,34) aV.Position=U2(0.48,4,0,10) aV.BackgroundTransparency=0.15 aV.Font=fg aV.TextSize=12
aV.Text="Shift Lock: INACTIVE" aa(aV,"BackgroundColor3","PanelBg") aa(aV,"TextColor3","TextPrimary") aB(aV,6)
local jD=cW(du,U2(0,210,0,30),U2(0,12,0,52),"Mouse Lock Shortcut Keybind:",fg,12,"TextPrimary",XL)
local cY=az(du,U2(0,130,0,30),U2(1,-240,0,52),"Bind Key: [M]","PanelBg",11) local aP=cK("TextButton",du)
aP.Size=U2(0,92,0,30) aP.Position=U2(1,-102,0,52) aP.BackgroundColor3=cX(165,38,55) aP.Font=d0 aP.TextSize=11
aP.TextColor3=cX(255,255,255) aP.Text=E.r .. " Delete Key" aB(aP,6) _L1=function() local k=ao.MouseLockKeybind or "None"
cY.Text="Bind Key: [" .. k .. "]" a3.Text="Mouse Lock [" .. k .. "]: " ..(aD and "ON" or "OFF")
a3.BackgroundColor3=aD and cX(38,168,92)or cX(185,52,52) aV.Text=aD and "Shift Lock: ACTIVE" or "Shift Lock: INACTIVE" end
_L0=function(hO) aD=hO and true or false _L1() if aD then pcall(function() aY.DevEnableMouseLock=true
UserSettings():GetService("UserGameSettings").RotationType=Enum.RotationType.CameraRelative
aA.MouseBehavior=Enum.MouseBehavior.LockCenter end) else pcall(function() aA.MouseBehavior=Enum.MouseBehavior.Default
aA.MouseIconEnabled=true UserSettings():GetService("UserGameSettings").RotationType=Enum.RotationType.MovementRelative end)
pcall(function() local fd=aY.Character and aY.Character:FindFirstChildOfClass("Humanoid") if fd then fd.AutoRotate=true
fd.CameraOffset=V3(0,0,0) end end) end end a3.MouseButton1Click:Connect(function() _L0(not aD) end)
cY.MouseButton1Click:Connect(function() cY.Text="[Key / Del]" ah=function(cf) ao.MouseLockKeybind=cf _L1() aj(false) end end)
aP.MouseButton1Click:Connect(function() ao.MouseLockKeybind="None" ah=nil _L1() aj(false) end) _L1()
aq(bz,"Protection & Physics Stabilizers",6) a1(bz,"Anti-AFK Protection (VirtualUser Idle Bypass)",ao.AntiAFK,7,function(bq)
ao.AntiAFK=bq aj(false) end)
a1(bz,"Anti-Fling Physics Stabilizer (Zero Abnormal Velocity)",ao.AntiFlingEnabled,8,function(bq) ao.AntiFlingEnabled=bq
aj(false) end) a1(bz,"Anti-Kick & Movement Spoofer (Hide Fly / Speed / Jump)",ao.AntiCheatBypass~=false,9,function(bq)
ao.AntiCheatBypass=bq aj(false) end) pcall(function() if hookmetamethod and getnamecallmethod and checkcaller then local hz
hz=hookmetamethod(game,"__namecall",function(ju,...) if not a8 and not checkcaller()and ao.AntiCheatBypass~=false then
local jM=getnamecallmethod() if ju==aY and(jM=="Kick" or jM=="kick")then return nil end end return hz(ju,...) end) local i3
i3=hookmetamethod(game,"__index",function(ju,ka)
if not a8 and not checkcaller()and ao.AntiCheatBypass~=false and typeof and typeof(ju)=="Instance" and ju:IsA("Humanoid")then
if ka=="WalkSpeed" then return 16 elseif ka=="JumpPower" then return 50 elseif ka=="PlatformStand" then return false end end
return i3(ju,ka) end) end end) tins(bn,aY.Idled:Connect(function() if not a8 and ao.AntiAFK then pcall(function() hw:CaptureController()
hw:ClickButton2(V2()) end) end end)) end local bm,bp,aZ do aq(d5,"Coordinates & Direct Teleport",1) local ej=aW(d5,88,2)
local dv=az(ej,U2(0,160,0,32),U2(0,12,0,10),E.p .. " Copy Coords","Accent",12)
local hP=az(ej,U2(0,180,0,32),U2(0,182,0,10),E.q .. " Save Current Pos","AccentDark",12) local bG=cK("TextBox")
bG.Size=U2(1,-155,0,32) bG.Position=U2(0,12,0,48) bG.PlaceholderText="Enter X, Y, Z coordinates (e.g. 120, 50, -340)..."
bG.Text="" bG.ClearTextOnFocus=false bG.Font=kv bG.TextSize=12 bG.Parent=ej aa(bG,"BackgroundColor3","PanelBg")
aa(bG,"TextColor3","TextPrimary") aB(bG,6) local iW=az(ej,U2(0,125,0,32),U2(1,-137,0,48),E.a .. " Teleport","Accent",12)
bm=function(dQ) local char=dQ or aY.Character if not char then return nil end
return char:FindFirstChild("HumanoidRootPart")or char.PrimaryPart or char:FindFirstChildWhichIsA("BasePart") end bp=nil
aZ=function(x,y,z) pcall(function() local bT=bm() if bT then local b9=V3(x,y,z) bp=b9 bT.AssemblyLinearVelocity=V3(0,0,0)
bT.CFrame=CF(b9) end end) end local function f7(k9) if type(k9)~="string" then return nil end local jZ={}
for numStr in k9:gmatch("[-+]?%d+%.?%d*")do local n=tonumber(numStr) if n then tins(jZ,n)end end
if #jZ>=3 then return jZ[1],jZ[2],jZ[3]end return nil end dv.MouseButton1Click:Connect(function() local bT=bm() if bT then
local hh=bT.Position h8(sfmt("%.1f, %.1f, %.1f",hh.X,hh.Y,hh.Z)) dv.Text=E.c .. " Copied!"
tdelay(1.1,function() if dv and dv.Parent then dv.Text=E.p .. " Copy Coords" end end) end end)
iW.MouseButton1Click:Connect(function() local x,y,z=f7(bG.Text) if x and y and z then aZ(x,y,z)end end)
aq(d5,"Saved Waypoints (Press Delete Key to Unassign Keybind)",3) local a7=cK("Frame") a7.LayoutOrder=4 a7.Size=U2(1,0,0,0)
a7.AutomaticSize=Enum.AutomaticSize.Y a7.BackgroundTransparency=1 a7.Parent=d5 local e4=cK("UIListLayout") e4.Padding=U1(0,6)
e4.SortOrder=Enum.SortOrder.LayoutOrder e4.Parent=a7 ah=nil local function dJ() for _,child in ipairs(a7:GetChildren())do
if child:IsA("Frame")then child:Destroy()end end for idx,wp in ipairs(ae.Waypoints)do local Row=aW(a7,44,idx)
local dz=cK("TextBox") dz.Size=U2(0,175,0,28) dz.Position=U2(0,10,0.5,-14) dz.Text=wp.Name or("Waypoint " .. idx)
dz.ClearTextOnFocus=false dz.Font=fg dz.TextSize=12 dz.Parent=Row aa(dz,"BackgroundColor3","PanelBg")
aa(dz,"TextColor3","TextPrimary") aB(dz,6) dz.FocusLost:Connect(function() wp.Name=dz.Text aj(false) end)
local kH=cW(Row,U2(0,135,1,0),U2(0,192,0,0),sfmt("%.0f, %.0f, %.0f",wp.X or 0,wp.Y or 0,wp.Z or 0),kv,11,"TextSecondary",XL)
local fx=az(Row,U2(0,78,0,28),U2(1,-206,0.5,-14),"[" ..(wp.Keybind or "None").. "]","PanelBg",11)
fx.MouseButton1Click:Connect(function() fx.Text="[Key/Del]" ah=function(cf) wp.Keybind=cf fx.Text="[" .. cf .. "]" aj(false)
end end) fx.MouseButton2Click:Connect(function() wp.Keybind="None" fx.Text="[None]" ah=nil aj(false) end)
local iX=az(Row,U2(0,74,0,28),U2(1,-122,0.5,-14),"Teleport","Accent",11)
iX.MouseButton1Click:Connect(function()aZ(wp.X,wp.Y,wp.Z)end) local fJ=cK("TextButton") fJ.Size=U2(0,34,0,28)
fJ.Position=U2(1,-42,0.5,-14) fJ.BackgroundColor3=cX(165,38,55) fJ.Font=d0 fJ.TextSize=13 fJ.TextColor3=cX(255,255,255)
fJ.Text=E.r fJ.Parent=Row aB(fJ,6) fJ.MouseButton1Click:Connect(function() table.remove(ae.Waypoints,idx) aj(false) dJ()
end) end end hP.MouseButton1Click:Connect(function() local bT=bm() if bT then local hh=bT.Position tins(ae.Waypoints,{
Name="Waypoint " ..(#ae.Waypoints+1), X=mfloor(hh.X+0.5), Y=mfloor(hh.Y+0.5), Z=mfloor(hh.Z+0.5), Keybind="None"
}) aj(false) dJ() end end) dJ() end local b0,IsFriend,c0 do
aq(h4,"Live Player Radar (Friends " .. E.s .. " First | Press Delete Key to Unassign)",1) local bK=cK("Frame")
bK.LayoutOrder=2 bK.Size=U2(1,0,0,0) bK.AutomaticSize=Enum.AutomaticSize.Y bK.BackgroundTransparency=1 bK.Parent=h4
local gq=cK("UIListLayout") gq.Padding=U1(0,6) gq.SortOrder=Enum.SortOrder.LayoutOrder gq.Parent=bK b0=nil
IsFriend=function(cN) local j3,ky=pcall(function() return aY:IsFriendsWith(cN.UserId) end) return j3 and ky end c0=function()
for _,child in ipairs(bK:GetChildren())do if child:IsA("Frame")then child:Destroy()end end local dY=bm()
local jX=dY and dY.Position or V3(0,0,0) local iU={} for _,dm in ipairs(c1:GetPlayers())do if dm~=aY then
local jC=IsFriend(dm) local iB=bm(dm.Character) local kx=iB and(iB.Position-jX).Magnitude or 999999
tins(iU,{Player=dm,IsFriend=jC,Distance=kx}) end end table.sort(iU,function(a,b)
if a.IsFriend~=b.IsFriend then return a.IsFriend end return a.Distance<b.Distance end) for idx,entry in ipairs(iU)do
local dm=entry.Player local Card=aW(bK,46,idx) local kG=entry.IsFriend and(E.s .. " ")or ""
local jI=(entry.Distance<999990)and sfmt("%.0f studs",entry.Distance)or "N/A"
local kX=cW(Card,U2(1,-275,1,0),U2(0,12,0,0),sfmt("%s%s (@%s) - %s",kG,dm.DisplayName,dm.Name,jI),fg,12,"TextPrimary",XL)
local jP=ae.RadarKeybinds[dm.Name]or "None" local fx=az(Card,U2(0,74,0,28),U2(1,-258,0.5,-14),"[" .. jP .. "]","PanelBg",11)
fx.MouseButton1Click:Connect(function() fx.Text="[Key/Del]" ah=function(cf) if cf=="None" then ae.RadarKeybinds[dm.Name]=nil
else ae.RadarKeybinds[dm.Name]=cf end fx.Text="[" .. cf .. "]" aj(false) end end) fx.MouseButton2Click:Connect(function()
ae.RadarKeybinds[dm.Name]=nil fx.Text="[None]" ah=nil aj(false) end)
local iX=az(Card,U2(0,78,0,28),U2(1,-176,0.5,-14),"Teleport","Accent",11) iX.MouseButton1Click:Connect(function()
local h1=bm(dm.Character) if h1 then local hh=h1.Position aZ(hh.X,hh.Y+3,hh.Z) end end)
local j5=az(Card,U2(0,84,0,28),U2(1,-92,0.5,-14),(b0==dm)and "Unspectate" or "Spectate","AccentDark",11)
j5.MouseButton1Click:Connect(function() pcall(function() if b0==dm then b0=nil
local fd=aY.Character and aY.Character:FindFirstChildOfClass("Humanoid")
if fd then workspace.CurrentCamera.CameraSubject=fd end else b0=dm
local fd=dm.Character and dm.Character:FindFirstChildOfClass("Humanoid")
if fd then workspace.CurrentCamera.CameraSubject=fd end end c0() end) end) end end end local c2,fy,kP do local pH={}
aq(fw,"Proximity Prompt Instant Interaction Engine",1) local function fc() if not ao.InstantPrompt then return end
pcall(function() for _,jK in ipairs(workspace:GetDescendants())do if jK:IsA("ProximityPrompt")then if pH[jK]==nil then pH[jK]=jK.HoldDuration end jK.HoldDuration=0 end end
end) end kP=function() pcall(function() for jK,hd in pairs(pH)do if jK and jK.Parent then jK.HoldDuration=hd end end pH={} end) end a1(fw,"Instant Proximity Prompts (HoldDuration = 0 Bypass)",ao.InstantPrompt,2,function(bq) ao.InstantPrompt=bq
if bq then fc()else kP()end aj(false) end) tins(bn,f1.PromptButtonHoldBegan:Connect(function(fW) if ao.InstantPrompt then
pcall(function() if pH[fW]==nil then pH[fW]=fW.HoldDuration end fW.HoldDuration=0 gj(fW) end) end end)) tins(bn,workspace.DescendantAdded:Connect(function(jK)
if ao.InstantPrompt and jK:IsA("ProximityPrompt")then pcall(function() if pH[jK]==nil then pH[jK]=jK.HoldDuration end jK.HoldDuration=0 end) end end))
if ao.InstantPrompt then fc()end aq(fw,"Workspace Items & Proximity Scanner (Manual Scan | Collect: [E])",3)
local dG=aW(fw,46,4) local bd=cK("TextBox") bd.Size=U2(1,-240,0,30) bd.Position=U2(0,10,0.5,-15)
bd.PlaceholderText=E.t .. " Filter items by name..." bd.Text="" bd.ClearTextOnFocus=false bd.Font=kv bd.TextSize=12
bd.Parent=dG aa(bd,"BackgroundColor3","PanelBg") aa(bd,"TextColor3","TextPrimary") aB(bd,6)
local jf=az(dG,U2(0,100,0,30),U2(1,-220,0.5,-15),E.u .. " Rescan","Accent",11)
local hc=az(dG,U2(0,104,0,30),U2(1,-112,0.5,-15),E.v .. " Collect [E]","AccentDark",11) local a6=cK("Frame")
a6.LayoutOrder=5 a6.Size=U2(1,0,0,0) a6.AutomaticSize=Enum.AutomaticSize.Y a6.BackgroundTransparency=1 a6.Parent=fw
local e2=cK("UIListLayout") e2.Padding=U1(0,6) e2.SortOrder=Enum.SortOrder.LayoutOrder e2.Parent=a6
local h7={"drop","item","loot","weapon","ammo","coin","chest","box","pack","pickup","apple","gold","gem"} local a5={}
local function gc(kZ) for _,dm in ipairs(c1:GetPlayers())do
if dm.Character and kZ:IsDescendantOf(dm.Character)then return true end end return false end local function dy(hp)
if hp:IsA("BasePart")then return hp end if hp:IsA("Tool")or hp:IsA("Model")then
return hp:FindFirstChild("Handle")or hp.PrimaryPart or hp:FindFirstChildWhichIsA("BasePart",true) end return nil end
local function gN(hp) if hp.Name=="TR_FakeFloor" or gc(hp)then return false end if hp:IsA("Tool")then return dy(hp)~=nil end
if hp:IsA("BasePart")or hp:IsA("Model")then if hp:FindFirstChildWhichIsA("ProximityPrompt",true)then return dy(hp)~=nil end
local lower=hp.Name:lower() for _,kw in ipairs(h7)do if lower:find(kw,1,true)then return dy(hp)~=nil end end end return false
end c2=function(eY) pcall(function() local dY=bm() if not dY or not eY or not eY.Part or not eY.Part.Parent then return end
local ja=dY.CFrame dY.CFrame=eY.Part.CFrame+V3(0,2,0) twait(0.06) gQ(dY,eY.Part,0) gQ(dY,eY.Part,1)
local fW=eY.Object:FindFirstChildWhichIsA("ProximityPrompt",true) or eY.Part:FindFirstChildWhichIsA("ProximityPrompt",true)
if fW then fW.HoldDuration=0 gj(fW) end twait(0.06) if dY and dY.Parent then dY.CFrame=ja end end) end fy=function()
a5={} local jS=bd.Text:lower() local dY=bm() local jX=dY and dY.Position or V3(0,0,0)
for _,hp in ipairs(workspace:GetDescendants())do if gN(hp)then local fX=dy(hp)
if fX and(jS=="" or hp.Name:lower():find(jS,1,true))then tins(a5,{ Object=hp,Part=fX,Name=hp.Name,
Distance=(fX.Position-jX).Magnitude }) end end if #a5>=35 then break end end
table.sort(a5,function(a,b)return a.Distance<b.Distance end) for _,child in ipairs(a6:GetChildren())do
if child:IsA("Frame")then child:Destroy()end end for idx,item in ipairs(a5)do local Row=aW(a6,42,idx)
local lx=cW(Row,U2(1,-190,1,0),U2(0,12,0,0),sfmt("%s %s (%.0f studs)",E.w,item.Name,item.Distance),fg,12,"TextPrimary",XL)
local iX=az(Row,U2(0,78,0,28),U2(1,-172,0.5,-14),"Teleport","Accent",11) iX.MouseButton1Click:Connect(function()
if item.Part and item.Part.Parent then local hh=item.Part.Position aZ(hh.X,hh.Y+3,hh.Z) end end)
local kk=az(Row,U2(0,78,0,28),U2(1,-86,0.5,-14),"Collect","AccentDark",11)
kk.MouseButton1Click:Connect(function()c2(item)end) end end jf.MouseButton1Click:Connect(fy)
hc.MouseButton1Click:Connect(function() if a5[1]then c2(a5[1])end end) end local aL=(ae.Settings.MasterFlightEnabled==true)
local fm,aX=false,nil local gt,fS,hx,d2 do aq(bL,"Flight Engine & Keybind Controls",1) local cG=aW(bL,92,2)
local aK=cK("TextButton") aK.Size=U2(0.48,-12,0,34) aK.Position=U2(0,10,0,10) aK.Font=d0 aK.TextSize=12
aK.TextColor3=cX(255,255,255) aK.Parent=cG aB(aK,6) local bc=cK("TextButton") bc.Size=U2(0.52,-12,0,34)
bc.Position=U2(0.48,2,0,10) bc.Font=d0 bc.TextSize=12 bc.TextColor3=cX(255,255,255) bc.Parent=cG aB(bc,6)
local jB=cW(cG,U2(0,210,0,30),U2(0,12,0,52),"Flight Shortcut Keybind:",fg,12,"TextPrimary",XL)
local e5=az(cG,U2(0,130,0,30),U2(1,-240,0,52),"Bind Key: [E]","PanelBg",11) local bf=cK("TextButton") bf.Size=U2(0,92,0,30)
bf.Position=U2(1,-102,0,52) bf.BackgroundColor3=cX(165,38,55) bf.Font=d0 bf.TextSize=11 bf.TextColor3=cX(255,255,255)
bf.Text=E.r .. " Delete Key" bf.Parent=cG aB(bf,6) local function h5() return ae.Settings.FlyKeybind or "None" end
local function bH() local k=h5() e5.Text="Bind Key: [" .. k .. "]"
bc.Text="Keybind [" .. k .. "] Flight: " ..(fm and "ON" or "OFF") bc.BackgroundColor3=fm and cX(38,168,92)or cX(185,52,52)
aK.BackgroundColor3=aL and cX(38,168,92)or cX(185,52,52)
aK.Text=aL and "Master Flight Switch: ON" or "Master Flight Switch: OFF" end gt=function() return aL and fm end fS=function()
fm=false bp=nil bH() if aX then aX:Destroy() aX=nil end local char=aY.Character if char then
local fd=char:FindFirstChildOfClass("Humanoid") local bT=char:FindFirstChild("HumanoidRootPart") if fd then
fd.PlatformStand=false fd:ChangeState(HST.GettingUp) fd:SetStateEnabled(HST.FallingDown,true)
fd:SetStateEnabled(HST.Ragdoll,true) end if bT then bT.AssemblyLinearVelocity=V3(0,0,0) bT.AssemblyAngularVelocity=V3(0,0,0)
end end end hx=function() if not aL then return end local char=aY.Character if not char then return end
local bT=char:FindFirstChild("HumanoidRootPart") local fd=char:FindFirstChildOfClass("Humanoid")
if not bT or not fd then return end fm=true bp=bT.Position bH() fd:SetStateEnabled(HST.FallingDown,false)
fd:SetStateEnabled(HST.Ragdoll,false) fd.PlatformStand=false if not aX then aX=cK("Part") aX.Name="TR_FakeFloor"
aX.Size=V3(4,0.2,4) aX.Transparency=1 aX.Anchored=true aX.CanCollide=true aX.Parent=workspace end end d2=function()
if not aL then return end if fm then fS() else hx() end end aK.MouseButton1Click:Connect(function() aL=not aL
ae.Settings.MasterFlightEnabled=aL if gf then gf()end bH() if not aL then fS() end end) bc.MouseButton1Click:Connect(d2)
e5.MouseButton1Click:Connect(function() e5.Text="[Key / Del]" ah=function(cf) ae.Settings.FlyKeybind=cf bH() aj(false) end
end) bf.MouseButton1Click:Connect(function() ae.Settings.FlyKeybind="None" ah=nil bH() aj(false) end) bH()
aq(bL,"Master Utility & Physics Controls",3)
a1(bL,"Master Utility Switch (Enable WalkSpeed & JumpPower)",ao.MasterUtilityEnabled,4,function(bq)
ao.MasterUtilityEnabled=bq aj(false) end) a1(bL,"Noclip Mode (Disable Character CanCollide)",ao.NoclipEnabled,5,function(bq)
ao.NoclipEnabled=bq aj(false) end)
a1(bL,"Shift-Down Flight Descent (Hold LeftShift to Descend)",ao.ShiftDownEnabled,7,function(bq) ao.ShiftDownEnabled=bq
aj(false) end) a1(bL,"Countdown / Spawn Freeze Bypass (Unanchor & Clear Freeze Tags)",ao.CountdownBypass,8,function(bq)
ao.CountdownBypass=bq aj(false) end) aq(bL,"Speed & Movement Sliders",9)
c7(bL,"Fly Speed",1,1000,ao.FlySpeed,10,function(js)ao.FlySpeed=js;aj(false)end)
c7(bL,"WalkSpeed",16,500,ao.WalkSpeed,12,function(js)ao.WalkSpeed=js;aj(false)end)
c7(bL,"JumpPower",50,500,ao.JumpPower,13,function(js)ao.JumpPower=js;aj(false)end) end local aU,bJ={},false local bY,hs do
aq(f2,E.a .. " Multi-Target Fling Hub (With Auto Network Pause Bypass)",1)
a1(f2,"Auto-Select Players When New Player Joins (Friends Excluded)",ao.AutoSelectFling==true,2,function(bq)
ao.AutoSelectFling=bq aj(false) end) local c6=aW(f2,356,3) local bk=cK("TextLabel") bk.Size=U2(1,-24,0,22)
bk.Position=U2(0,12,0,8) bk.BackgroundTransparency=1 bk.Text="Select targets to fling (Friends excluded)" bk.TextSize=12
bk.Font=kO bk.TextXAlignment=XL bk.Parent=c6 aa(bk,"TextColor3","TextSecondary") local bO=cK("Frame") bO.Size=U2(1,-24,0,214)
bO.Position=U2(0,12,0,34) bO.BackgroundTransparency=0.25 bO.BorderSizePixel=0 bO.Parent=c6
aa(bO,"BackgroundColor3","PanelBg") aB(bO,10) local aN=cK("ScrollingFrame") aN.Size=U2(1,-10,1,-10) aN.Position=U2(0,5,0,5)
aN.BackgroundTransparency=1 aN.BorderSizePixel=0 aN.ScrollBarThickness=4 aN.CanvasSize=U2(0,0,0,0) aN.Parent=bO
aa(aN,"ScrollBarImageColor3","Accent") local fP=cK("UIListLayout") fP.SortOrder=Enum.SortOrder.LayoutOrder fP.Padding=U1(0,6)
fP.Parent=aN local iV=az(c6,U2(0.48,-12,0,40),U2(0,12,0,258),E.x .. " START FLING","Accent",13)
local i5=az(c6,U2(0.48,-12,0,40),U2(0.52,0,0,258),E.z .. " STOP FLING","AccentDark",13)
local hG=az(c6,U2(0.48,-12,0,36),U2(0,12,0,306),"SELECT ALL","PanelBg",12)
local hd=az(c6,U2(0.48,-12,0,36),U2(0.52,0,0,306),"DESELECT ALL","PanelBg",12) local cD,fL={},nil ih.OldPos=nil
ih.FPDH=workspace.FallenPartsDestroyHeight local cn local function f9() pcall(function()
g2.RobloxGui["CoreScripts/NetworkPause"]:Destroy() end) end local function eZ() local iy=0 for _ in pairs(aU)do iy=iy+1 end
return iy end cn=function() local iy=eZ() local eU=cQ() if bJ then bk.Text=E.a .. " Flinging " .. iy .. " target(s)..."
bk.TextColor3=eU.Accent else bk.Text=iy .. " target(s) selected (Friends excluded)" bk.TextColor3=eU.TextSecondary end end
tins(cq.CustomCallbacks,cn) bY=function() for _,child in pairs(aN:GetChildren())do
if child:IsA("Frame")then child:Destroy()end end cD={} local hY=c1:GetPlayers()
table.sort(hY,function(a,b)return a.Name:lower()<b.Name:lower()end) local j2=0 for _,b9 in ipairs(hY)do if b9~=aY then
if aU[b9.Name]==nil and ao.AutoSelectFling==true then if not IsFriend(b9)then aU[b9.Name]=b9 end end local j0=cK("Frame")
j0.Size=U2(1,0,0,36) j0.Position=U2(0,0,0,j2) j0.BackgroundTransparency=0.2 j0.Parent=aN aa(j0,"BackgroundColor3","CardBg")
aB(j0,8) local fv=cK("Frame") fv.Size=U2(0,22,0,22) fv.Position=U2(0,10,0.5,-11) fv.BorderSizePixel=0 fv.Parent=j0
aa(fv,"BackgroundColor3","PanelBg") aB(fv,5) local cF=cK("TextLabel") cF.Size=U2(1,0,1,0) cF.BackgroundTransparency=1
cF.Text=E.Aa cF.TextSize=14 cF.Font=d0 cF.Visible=aU[b9.Name]~=nil cF.Parent=fv aa(cF,"TextColor3","Accent")
local fj=cK("TextLabel") fj.Size=U2(1,-45,1,0) fj.Position=U2(0,40,0,0) fj.BackgroundTransparency=1
fj.Text=IsFriend(b9)and(b9.Name .. " " .. E.s)or b9.Name fj.TextSize=12 fj.Font=kO fj.TextXAlignment=XL fj.Parent=j0
aa(fj,"TextColor3","TextPrimary") local gv=cK("TextButton") gv.Size=U2(1,0,1,0) gv.BackgroundTransparency=1 gv.Text=""
gv.Parent=j0 gv.MouseButton1Click:Connect(function() if aU[b9.Name]then aU[b9.Name]=nil cF.Visible=false else aU[b9.Name]=b9
cF.Visible=true end cn() end) cD[b9.Name]={Row=j0,Check=cF} j2=j2+42 end end aN.CanvasSize=U2(0,0,0,j2) cn() end
local function fM(select) for _,b9 in ipairs(c1:GetPlayers())do if b9~=aY then local iQ=cD[b9.Name] if iQ then if select then
aU[b9.Name]=b9 iQ.Check.Visible=true else aU[b9.Name]=nil iQ.Check.Visible=false end end end end cn() end
local function jp(jR,jV,j4) pcall(function() jk:SetCore("SendNotification",{ Title=jR, Text=jV, Duration=j4 or 3 }) end) end
local function jy(iO) local Character=aY.Character local fD=Character and Character:FindFirstChildOfClass("Humanoid")
local RootPart=fD and fD.RootPart local f0=iO.Character if not f0 then return end
local c4=f0:FindFirstChildOfClass("Humanoid") local hk=c4 and c4.RootPart local jo=f0:FindFirstChild("Head")
local iG=f0:FindFirstChildOfClass("Accessory") local iR=iG and iG:FindFirstChild("Handle")
if Character and fD and RootPart then if RootPart.Velocity.Magnitude<50 then ih.OldPos=RootPart.CFrame end
if c4 and c4.Sit then return end if jo then workspace.CurrentCamera.CameraSubject=jo elseif iR then
workspace.CurrentCamera.CameraSubject=iR elseif c4 and hk then workspace.CurrentCamera.CameraSubject=c4 end
local kI=function(fp,k8,lj) RootPart.CFrame=CF(fp.Position)*k8*lj Character:SetPrimaryPartCFrame(CF(fp.Position)*k8*lj)
RootPart.Velocity=V3(9e7,9e7*10,9e7) RootPart.RotVelocity=V3(9e8,9e8,9e8) end local gY=function(fp) local jj=2
local k5=tick() local jt=0 repeat if RootPart and c4 then jt=jt+100
kI(fp,CF(0,1.5,0)+c4.MoveDirection*fp.Velocity.Magnitude/1.25,kN(math.rad(jt),0,0)) twait()
kI(fp,CF(0,-1.5,0)+c4.MoveDirection*fp.Velocity.Magnitude/1.25,kN(math.rad(jt),0,0)) twait() end
until k5+jj<tick()or not bJ end workspace.FallenPartsDestroyHeight=0/0 local BV=cK("BodyVelocity") BV.Parent=RootPart
BV.Velocity=V3(0,0,0) BV.MaxForce=V3(9e9,9e9,9e9) fD:SetStateEnabled(HST.Seated,false) if hk then gY(hk) elseif jo then
gY(jo) elseif iR then gY(iR) end BV:Destroy() fD:SetStateEnabled(HST.Seated,true) workspace.CurrentCamera.CameraSubject=fD
if ih.OldPos then repeat RootPart.CFrame=ih.OldPos*CF(0,0.5,0) Character:SetPrimaryPartCFrame(ih.OldPos*CF(0,0.5,0))
fD:ChangeState("GettingUp") for _,fX in pairs(Character:GetChildren())do if fX:IsA("BasePart")then
fX.Velocity,fX.RotVelocity=V3(),V3() end end twait() until(RootPart.Position-ih.OldPos.p).Magnitude<25
workspace.FallenPartsDestroyHeight=ih.FPDH end end end local function jm() if bJ then return end if eZ()==0 then
bk.Text="No targets selected!" tdelay(1,cn) return end f9() bJ=true cn()
jp("T.R Fling","Started multi-target fling & bypass engine.",2) fL=tspawn(function() while bJ do local g7={}
for name,cN in pairs(aU)do if cN and cN.Parent then tins(g7,cN) else aU[name]=nil if cD[name]then
cD[name].Check.Visible=false end end end for _,cN in ipairs(g7)do if bJ then jy(cN) twait(0.05) else break end end
twait(0.2) end end) end hs=function() local wF=bJ bJ=false if fL then pcall(function()task.cancel(fL)end) fL=nil end cn()
pcall(function() workspace.FallenPartsDestroyHeight=ih.FPDH local char=aY.Character
local fd=char and char:FindFirstChildOfClass("Humanoid") local bT=bm(char)
if bT then for _,ch in ipairs(bT:GetChildren())do if ch:IsA("BodyVelocity")then ch:Destroy()end end
if wF and ih.OldPos then bT.CFrame=ih.OldPos*CF(0,0.5,0) char:SetPrimaryPartCFrame(ih.OldPos*CF(0,0.5,0)) end
bT.AssemblyLinearVelocity=V3(0,0,0) bT.AssemblyAngularVelocity=V3(0,0,0) end
if fd then fd:SetStateEnabled(HST.Seated,true) fd:ChangeState(HST.GettingUp)
if workspace.CurrentCamera then workspace.CurrentCamera.CameraSubject=fd end end
if char then for _,fX in ipairs(char:GetChildren())do if fX:IsA("BasePart")then fX.Velocity,fX.RotVelocity=V3(),V3() end end end end)
if wF then jp("T.R Fling","Fling engine stopped.",2) end end iV.MouseButton1Click:Connect(jm) i5.MouseButton1Click:Connect(hs) hG.MouseButton1Click:Connect(function()fM(true)end)
hd.MouseButton1Click:Connect(function()fM(false)end) end local gJ,iN,jd=0.033333333333333,500,0.16
local bv=tonumber(ao.AimbotFOVRadius)or 200 local cJ=(ao.AimbotFOVCircleEnabled~=false) local bZ=(ao.AimbotEnabled==true)
local fB=(ao.StrongLock==true) local d7=(ao.WallcheckEnabled~=false) local eX=ao.AimPartName or "Head" local aH,eq=nil,0
local a9,fq,cg={},{},{} local aG,fh=nil,nil local eH,e1,a4,cO local bQ,cv,fA local aJ,aQ,cL,cd,fY,fb do aG=cK("Frame")
aG.Name="TR_FOVCircle" aG.AnchorPoint=V2(0.5,0.5) aG.Position=U2(0.5,0,0.5,0) aG.Size=U2(0,bv*2,0,bv*2)
aG.BackgroundTransparency=1 aG.BorderSizePixel=0 aG.Visible=false aG.Parent=dX cK("UICorner",aG).CornerRadius=U1(1,0)
fh=cK("UIStroke",aG) fh.Thickness=1.8 fh.Transparency=0.15 aa(fh,"Color","Accent") aI=function() if aG then
aG.Size=U2(0,bv*2,0,bv*2) aG.Visible=bZ and cJ and not a8 end end eH=function(dQ) if not dQ then return nil end
local p=dQ:FindFirstChild(eX) if p and p:IsA("BasePart")then return p end local k4=dQ:FindFirstChild("HumanoidRootPart")
if k4 and k4:IsA("BasePart")then return k4 end local t=dQ:FindFirstChild("Torso")or dQ:FindFirstChild("UpperTorso")
return(t and t:IsA("BasePart")and t)or dQ.PrimaryPart end e1=function(fz,f4) if not d7 then return true end
local hC=workspace.CurrentCamera if not hC or not fz then return false end local jl=RaycastParams.new()
jl.FilterType=Enum.RaycastFilterType.Blacklist
jl.FilterDescendantsInstances=LocalPlayer.Character and{LocalPlayer.Character}or{}
local lh=workspace:Raycast(hC.CFrame.Position,fz.Position-hC.CFrame.Position,jl)
return(not lh)or(f4 and lh.Instance:IsDescendantOf(f4)) end local function gb(jY) local hC=workspace.CurrentCamera
if not hC then return nil,false,math.huge end local vp,hW=hC:WorldToViewportPoint(jY)
if not hW or vp.Z<=0 then return nil,false,math.huge end local kh=V2(hC.ViewportSize.X/2,hC.ViewportSize.Y/2)
local hh=V2(vp.X,vp.Y) return hh,true,(hh-kh).Magnitude end a4=function(dm) local gK=cg[dm] if gK then
if gK.inner then pcall(function()gK.inner:Destroy()end)end if gK.outline then pcall(function()gK.outline:Destroy()end)end
cg[dm]=nil end fq[dm]=nil end cO=function() for dm in pairs(cg)do a4(dm)end end bQ=function()
for _,dm in ipairs(c1:GetPlayers())do if dm~=aY and dm.Character then
local g6=dm.Character:FindFirstChild("TR_ESP_Highlight") if ao.ESPEnabled and not a9[dm]then if not g6 then pcall(function()
local hl=cK("Highlight") hl.Name="TR_ESP_Highlight" hl.FillColor=cQ().Accent hl.OutlineColor=cX(255,255,255)
hl.FillTransparency=0.45 hl.OutlineTransparency=0.1 hl.Adornee=dm.Character hl.Parent=dm.Character end) else
g6.FillColor=cQ().Accent end elseif g6 then g6:Destroy() end end end end cv=function()
if not ao.ESPEnabled then cO()return end local ik=cQ().Accent for dm in pairs(cg)do
if not dm or not dm.Parent or a9[dm]then a4(dm)end end for _,dm in ipairs(c1:GetPlayers())do
if dm~=LocalPlayer and not a9[dm]then local char=dm.Character
local bT=char and(char:FindFirstChild("HumanoidRootPart")or char.PrimaryPart)
local fd=char and char:FindFirstChildOfClass("Humanoid") if char and bT and fd and fd.Health>0 then local gK=cg[dm]
if not gK then local inner=cK("BoxHandleAdornment") inner.AlwaysOnTop=true inner.ZIndex=10 inner.Transparency=0.35
inner.Color3=ik inner.Name="ESP_HitboxInner" inner.Parent=iw local outline=cK("BoxHandleAdornment") outline.AlwaysOnTop=true
outline.ZIndex=9 outline.Transparency=0.75 outline.Color3=cX(0,0,0) outline.Name="ESP_HitboxOutline" outline.Parent=iw
gK={inner=inner,outline=outline} cg[dm]=gK end gK.inner.Color3=ik
local ok,jW,h3=pcall(function()return char:GetBoundingBox()end) if ok and jW and h3 then local j8=bT.CFrame:ToObjectSpace(jW)
gK.inner.Adornee=bT gK.inner.Size=h3 gK.inner.CFrame=j8 gK.outline.Adornee=bT gK.outline.Size=h3*1.05 gK.outline.CFrame=j8
end else a4(dm) end else a4(dm) end end end fA=function() local hC=workspace.CurrentCamera if not hC then return nil end
local jr,i1=nil,cJ and bv or math.huge for _,dm in ipairs(c1:GetPlayers())do if dm~=LocalPlayer and not a9[dm]then
local char=dm.Character local fd=char and char:FindFirstChildOfClass("Humanoid") local fX=eH(char)
if char and fd and fd.Health>0 and fX then if(fX.Position-hC.CFrame.Position).Magnitude<=iN then
local _,hW,j7=gb(fX.Position) if hW and j7<=i1 and e1(fX,char)then i1,jr=j7,dm end end end end end return jr end
aq(a2,"Aimbot Engine & Keybind Controls",1) local cx=aW(a2,92,2) local bt=cK("TextButton",cx) bt.Size=U2(0.48,-12,0,34)
bt.Position=U2(0,10,0,10) bt.Font=d0 bt.TextSize=12 bt.TextColor3=cX(255,255,255) aB(bt,6) aJ=cK("TextLabel",cx)
aJ.Size=U2(0.52,-14,0,34) aJ.Position=U2(0.48,4,0,10) aJ.BackgroundTransparency=0.15 aJ.Font=fg aJ.TextSize=12
aJ.Text="Status: Idle" aa(aJ,"BackgroundColor3","PanelBg") aa(aJ,"TextColor3","TextPrimary") aB(aJ,6)
local jA=cW(cx,U2(0,210,0,30),U2(0,12,0,52),"Aimbot Shortcut Keybind:",fg,12,"TextPrimary",XL)
local dH=az(cx,U2(0,130,0,30),U2(1,-240,0,52),"Bind Key: [Q]","PanelBg",11) local a0=cK("TextButton",cx)
a0.Size=U2(0,92,0,30) a0.Position=U2(1,-102,0,52) a0.BackgroundColor3=cX(165,38,55) a0.Font=d0 a0.TextSize=11
a0.TextColor3=cX(255,255,255) a0.Text=E.r .. " Delete Key" aB(a0,6)
a1(a2,"Strong Lock Mode (Instant Camera Snap vs Smooth Lerp)",fB,3,function(bq) fB=bq ao.StrongLock=bq
if not fB then aH=nil end aj(false) end) a1(a2,"Raycast Wallcheck (Line-of-Sight Target Verification)",d7,4,function(bq)
d7=bq ao.WallcheckEnabled=bq aj(false) end)
a1(a2,"Show Aimbot FOV Circle (Turn OFF for Full-Screen Aimbot)",cJ,5,function(bq) cJ=bq ao.AimbotFOVCircleEnabled=bq aH=nil
aI() aj(false) end) local fT local dj fT=c7(a2,"Aimbot FOV Circle Radius (px)",20,800,bv,6,function(js) bv=js
ao.AimbotFOVRadius=js if dj then dj.Text=tostring(js)end aI() aj(false) end) local cT=aW(a2,48,7)
local h2=az(cT,U2(0.34,-10,0,32),U2(0,10,0,8),"","Accent",12) dj=cK("TextBox",cT) dj.Size=U2(0.32,-8,0,32)
dj.Position=U2(0.34,4,0,8) dj.PlaceholderText="FOV Radius (" .. tostring(bv).. ")" dj.Text=tostring(bv)
dj.ClearTextOnFocus=false dj.Font=fg dj.TextSize=12 aa(dj,"BackgroundColor3","PanelBg") aa(dj,"TextColor3","TextPrimary")
aB(dj,6) local hQ=az(cT,U2(0.34,-10,0,32),U2(0.66,0,0,8),"Exclude Players: 0","AccentDark",12) aQ=cK("Frame",cT)
aQ.Size=U2(1,-20,0,130) aQ.Position=U2(0,10,0,48) aQ.BackgroundTransparency=0.1 aQ.BorderSizePixel=0 aQ.Visible=false
aa(aQ,"BackgroundColor3","PanelBg") aB(aQ,8) local bP=cK("ScrollingFrame",aQ) bP.Size=U2(1,-12,1,-12) bP.Position=U2(0,6,0,6)
bP.BackgroundTransparency=1 bP.BorderSizePixel=0 bP.CanvasSize=U2(0,0,0,0) bP.ScrollBarThickness=4
aa(bP,"ScrollBarImageColor3","Accent") cK("UIListLayout",bP).Padding=U1(0,5) local function by()
local k=ao.AimbotKeybind or "None" dH.Text="Bind Key: [" .. k .. "]"
bt.Text="Aimbot Lock [" .. k .. "]: " ..(bZ and "ON" or "OFF") bt.BackgroundColor3=bZ and cX(38,168,92)or cX(185,52,52)
h2.Text=(eX=="Head")and "Aim Part: Head" or "Aim Part: Body" aI() end tins(cq.CustomCallbacks,by) cL=function() local c=0
for _ in pairs(a9)do c=c+1 end hQ.Text="Exclude Players: " .. tostring(c) end cd=function()
for _,ch in ipairs(bP:GetChildren())do if ch:IsA("TextButton")then ch:Destroy()end end local eU,jn=cQ(),0
for _,dm in ipairs(c1:GetPlayers())do if dm~=LocalPlayer then
local hH=az(bP,U2(1,-6,0,26),nil,tostring(dm.DisplayName).. " (" .. tostring(dm.Name).. ")",nil,12)
hH.BackgroundColor3=a9[dm]and eU.Accent or eU.CardBg hH.MouseButton1Click:Connect(function() if a9[dm]then a9[dm]=nil
hH.BackgroundColor3=cQ().CardBg else a9[dm]=true hH.BackgroundColor3=cQ().Accent if aH==dm then aH=nil end a4(dm)
if dm.Character and dm.Character:FindFirstChild("TR_ESP_Highlight")then dm.Character.TR_ESP_Highlight:Destroy()end end cL()
bQ() end) jn=jn+31 end end bP.CanvasSize=U2(0,0,0,jn) cL() end
tins(cq.CustomCallbacks,function()if aQ.Visible then cd()end end) fY=function() bZ=not bZ ao.AimbotEnabled=bZ
if not bZ then aH=nil aJ.Text="Status: Idle" end by() aj(false) end bt.MouseButton1Click:Connect(fY)
h2.MouseButton1Click:Connect(function() eX=(eX=="Head")and "HumanoidRootPart" or "Head" ao.AimPartName=eX by() aj(false) end)
dH.MouseButton1Click:Connect(function() dH.Text="[Key / Del]" ah=function(k) ao.AimbotKeybind=k by() aj(false) end end)
a0.MouseButton1Click:Connect(function() ao.AimbotKeybind="None" ah=nil by() aj(false) end) dj.FocusLost:Connect(function()
local v=tonumber(dj.Text) if v then bv=mclamp(mfloor(v+0.5),20,800) ao.AimbotFOVRadius=bv
if fT then fT.SetValue(bv)end aI() aj(false) end dj.Text=tostring(bv) end) hQ.MouseButton1Click:Connect(function()
aQ.Visible=not aQ.Visible cT.Size=aQ.Visible and U2(1,0,0,186)or U2(1,0,0,48) if aQ.Visible then cd()end end) by()
aq(a2,"Player ESP (Chams & 3D Hitbox Boxes)",8)
a1(a2,"Player Highlight & 3D Box ESP (Chams + Hitbox Boxes)",ao.ESPEnabled,9,function(bq) ao.ESPEnabled=bq
if not bq then cO()else cv()end bQ() aj(false) end) aq(a2,"Camera Field of View & Perspective",10)
c7(a2,"Camera Field of View (FOV)",30,120,ao.FOV,11,function(js) ao.FOV=js
pcall(function()workspace.CurrentCamera.FieldOfView=js end) aj(false) end) local hy=aW(a2,50,12) local eQ=cK("UIListLayout")
eQ.FillDirection=Enum.FillDirection.Horizontal eQ.HorizontalAlignment=Enum.HorizontalAlignment.Center
eQ.VerticalAlignment=Enum.VerticalAlignment.Center eQ.Padding=U1(0,8) eQ.Parent=hy fb=function(jH) ao.CameraOverrideMode=jH
pcall(function() if jH=="Force 1st Person" then aY.CameraMode=Enum.CameraMode.LockFirstPerson
elseif jH=="Force 3rd Person" then aY.CameraMode=Enum.CameraMode.Classic aY.CameraMinZoomDistance=8
aY.CameraMaxZoomDistance=128 else aY.CameraMode=Enum.CameraMode.Classic aY.CameraMinZoomDistance=0.5
aY.CameraMaxZoomDistance=400 end end) aj(false) end
for _,modeName in ipairs({"Free / Unlocked","Force 1st Person","Force 3rd Person"})do
local k1=az(hy,U2(0,165,0,32),nil,modeName,"AccentDark",11) k1.MouseButton1Click:Connect(function()fb(modeName)end) end
aq(a2,"Lighting, Fullbright & Time Presets",13)
a1(a2,"Fullbright Lighting Mode (No Shadows + Max Illumination)",ao.FullbrightEnabled,14,function(bq) ao.FullbrightEnabled=bq
if not bq then pcall(function() bM.Brightness=bF.Brightness bM.GlobalShadows=bF.GlobalShadows
bM.OutdoorAmbient=bF.OutdoorAmbient end) end aj(false) end) local iZ=aW(a2,50,15) local gx=cK("UIListLayout")
gx.FillDirection=Enum.FillDirection.Horizontal gx.HorizontalAlignment=Enum.HorizontalAlignment.Center
gx.VerticalAlignment=Enum.VerticalAlignment.Center gx.Padding=U1(0,10) gx.Parent=iZ for _,preset in ipairs({
{Label=E.m .. " Day",Value=14}, {Label=E.n .. " Night",Value=0}, {Label=E.o .. " Unlock Time",Value=nil} })do
local k2=az(iZ,U2(0,160,0,32),nil,preset.Label,"AccentDark",12) k2.MouseButton1Click:Connect(function()
ao.LockedTime=preset.Value if preset.Value~=nil then pcall(function()bM.ClockTime=preset.Value end) else
pcall(function()bM.ClockTime=bF.ClockTime end) end aj(false) end) end end local bA={} do aq(d8,"Multi-Tab Luau Script Executor",1)
local dZ=aW(d8,42,2) local h6=az(dZ,U2(0,28,0,28),U2(0,8,0.5,-14),"<","PanelBg",13)
local hZ=az(dZ,U2(0,28,0,28),U2(1,-70,0.5,-14),">","PanelBg",13)
local jx=az(dZ,U2(0,28,0,28),U2(1,-36,0.5,-14),"+","Accent",15) local bh=cK("ScrollingFrame") bh.Size=U2(1,-118,0,30)
bh.Position=U2(0,42,0.5,-15) bh.BackgroundTransparency=1 bh.BorderSizePixel=0 bh.ScrollBarThickness=0
bh.CanvasSize=U2(0,0,0,0) bh.AutomaticCanvasSize=Enum.AutomaticSize.X bh.ScrollingDirection=Enum.ScrollingDirection.X
bh.Parent=dZ local c5=cK("UIListLayout") c5.FillDirection=Enum.FillDirection.Horizontal
c5.VerticalAlignment=Enum.VerticalAlignment.Center c5.Padding=U1(0,6) c5.Parent=bh h6.MouseButton1Click:Connect(function()
bh.CanvasPosition=V2(math.max(0,bh.CanvasPosition.X-120),0) end) hZ.MouseButton1Click:Connect(function()
bh.CanvasPosition=V2(bh.CanvasPosition.X+120,0) end) local jb=aW(d8,240,3) local bI=cK("TextBox") bI.Size=U2(1,-16,1,-16)
bI.Position=U2(0,8,0,8) bI.MultiLine=true bI.ClearTextOnFocus=false bI.TextWrapped=true bI.Font=kR bI.TextSize=13
bI.TextXAlignment=XL bI.TextYAlignment=Enum.TextYAlignment.Top
bI.PlaceholderText="-- Paste or write your Luau script here..." bI.Text="" bI.Parent=jb aa(bI,"BackgroundColor3","PanelBg")
aa(bI,"TextColor3","TextPrimary") aB(bI,6) local d1=aW(d8,48,4) local cz=cK("UIListLayout")
cz.FillDirection=Enum.FillDirection.Horizontal cz.HorizontalAlignment=Enum.HorizontalAlignment.Center
cz.VerticalAlignment=Enum.VerticalAlignment.Center cz.Padding=U1(0,12) cz.Parent=d1
local i9=az(d1,U2(0,155,0,32),nil,E.x .. " Execute","Accent",12)
local jQ=az(d1,U2(0,155,0,32),nil,E.y .. " Clear","AccentDark",12) local bX=cK("TextButton") bX.Size=U2(0,155,0,32)
bX.BackgroundColor3=cX(165,38,55) bX.Font=d0 bX.TextSize=12 bX.TextColor3=cX(255,255,255) bX.Text=E.z .. " Terminate"
bX.Parent=d1 aB(bX,6) local cR=false local function cw() if #ae.ExecutorTabs==0 then
tins(ae.ExecutorTabs,{Name="Script 1",Code=""}) end
ae.ActiveExecutorTab=mclamp(ae.ActiveExecutorTab or 1,1,#ae.ExecutorTabs) for _,child in ipairs(bh:GetChildren())do
if child:IsA("Frame")then child:Destroy()end end local eU=cQ() for idx,tabData in ipairs(ae.ExecutorTabs)do
local jc=(idx==ae.ActiveExecutorTab) local fF=cK("Frame") fF.Size=U2(0,128,0,26)
fF.BackgroundColor3=jc and eU.Accent or eU.PanelBg fF.BorderSizePixel=0 fF.Parent=bh aB(fF,6) local dR=cK("TextButton")
dR.Size=U2(0,22,1,0) dR.BackgroundTransparency=1 dR.Font=d0 dR.TextSize=11 dR.TextColor3=eU.TextPrimary dR.Text=tostring(idx)
dR.Parent=fF dR.MouseButton1Click:Connect(function() ae.ActiveExecutorTab=idx aj(false) cw() end) local cm=cK("TextBox")
cm.Size=U2(1,-48,1,0) cm.Position=U2(0,22,0,0) cm.BackgroundTransparency=1 cm.ClearTextOnFocus=false cm.Font=fg
cm.TextSize=11 cm.TextColor3=eU.TextPrimary cm.Text=tabData.Name or("Script " .. idx) cm.Parent=fF
cm.Focused:Connect(function() if ae.ActiveExecutorTab~=idx then ae.ActiveExecutorTab=idx cR=true bI.Text=tabData.Code or ""
cR=false end end) cm.FocusLost:Connect(function() tabData.Name=cm.Text aj(false) end) local c8=cK("TextButton")
c8.Size=U2(0,22,1,0) c8.Position=U2(1,-22,0,0) c8.BackgroundTransparency=1 c8.Font=d0 c8.TextSize=13
c8.TextColor3=eU.TextPrimary c8.Text=E.e c8.Parent=fF c8.MouseButton1Click:Connect(function() if #ae.ExecutorTabs>1 then
table.remove(ae.ExecutorTabs,idx) ae.ActiveExecutorTab=mclamp(ae.ActiveExecutorTab,1,#ae.ExecutorTabs) aj(false) cw() end
end) end cR=true bI.Text=ae.ExecutorTabs[ae.ActiveExecutorTab].Code or "" cR=false end
bI:GetPropertyChangedSignal("Text"):Connect(function() if cR then return end local ij=ae.ExecutorTabs[ae.ActiveExecutorTab]
if ij then ij.Code=bI.Text aj(false) end end) jx.MouseButton1Click:Connect(function()
tins(ae.ExecutorTabs,{Name="Script " ..(#ae.ExecutorTabs+1),Code=""}) ae.ActiveExecutorTab=#ae.ExecutorTabs aj(false) cw()
end) i9.MouseButton1Click:Connect(function() local jg=bI.Text if jg and #jg>0 then local fn,lq=gw(jg) if fn then
tins(bA,tspawn(function()pcall(fn)end)) else warn("[T.R Scripts Executor Compile Error]: " .. tostring(lq)) end end end)
jQ.MouseButton1Click:Connect(function()bI.Text="" end) bX.MouseButton1Click:Connect(function()
for _,thread in ipairs(bA)do pcall(function()task.cancel(thread)end)end bA={} end) cw() end
local hj={Frozen=true,Freeze=true,Stunned=true,CountdownLock=true,SpawnBarrier=true,RootAnchor=true}
local fU,gz,hJ,fK=0,os.clock(),60,0 tins(bn,c1.PlayerAdded:Connect(function(gI)
if ao.AutoSelectFling==true and gI~=aY and not IsFriend(gI)then aU[gI.Name]=gI end bY() if aQ and aQ.Visible then cd()end
end)) tins(bn,c1.PlayerRemoving:Connect(function(fR) aU[fR.Name]=nil a9[fR]=nil a4(fR) if aH==fR then aH=nil end bY()
if aQ and aQ.Visible then cd()else cL()end end)) tins(bn,LocalPlayer.CharacterAdded:Connect(function() aH=nil
for k in pairs(fq)do fq[k]=nil end end)) tins(bn,cs.RenderStepped:Connect(function(dt) eq=eq+dt if eq>=gJ then eq=0 cv() end
end)) local d9=nil cs:BindToRenderStep("TR_ShiftLock_Pre",Enum.RenderPriority.Camera.Value-1,function() if aD and not a8 then
pcall(function() aA.MouseBehavior=Enum.MouseBehavior.LockCenter
UserSettings():GetService("UserGameSettings").RotationType=Enum.RotationType.CameraRelative end) end end)
cs:BindToRenderStep("Aimbot_v2",Enum.RenderPriority.Camera.Value+1,function() local hC=workspace.CurrentCamera
if not hC then return end if aG then aG.Size=U2(0,bv*2,0,bv*2) aG.Visible=bZ and cJ and not a8 end if aD and not a8 then
pcall(function() aA.MouseBehavior=Enum.MouseBehavior.LockCenter
UserSettings():GetService("UserGameSettings").RotationType=Enum.RotationType.CameraRelative local g8=aA:GetMouseDelta()
if g8.Magnitude>0 and d9 and(hC.CFrame.LookVector-d9).Magnitude<0.0001 then local i0=hC.Focus.Position
local kr=hC.CFrame.Position-i0 local kx=kr.Magnitude local rx,ry,_=hC.CFrame:ToOrientation() local ko=ry-math.rad(g8.X*0.28)
local jT=mclamp(rx-math.rad(g8.Y*0.28),-math.rad(80),math.rad(80)) local kL=CFrame.fromOrientation(jT,ko,0)
hC.CFrame=CF(i0)*kL*CF(0,0,kx) end d9=hC.CFrame.LookVector local char=aY.Character
local fd=char and char:FindFirstChildOfClass("Humanoid") local bT=bm(char) if fd and bT and fd.Health>0 and not fd.Sit then
local j1=(hC.Focus.Position-hC.CFrame.Position).Magnitude fd.CameraOffset=(j1>1)and V3(1.75,0,0)or V3(0,0,0)
local lv=hC.CFrame.LookVector local kJ=V3(lv.X,0,lv.Z) if kJ.Magnitude>0.001 then fd.AutoRotate=false
bT.CFrame=CF(bT.Position,bT.Position+kJ.Unit) end end end) else d9=nil end if not bZ then return end if fB and aH then
local ch=aH.Character local h=ch and ch:FindFirstChildOfClass("Humanoid") local p=eH(ch)
if not ch or not h or h.Health<=0 or not p or not e1(p,ch)then aH=nil end else aH=fA() end if not aH then aH=fA()end
if aH and aH.Character then local fz=eH(aH.Character) if fz then local jL=CF(hC.CFrame.Position,fz.Position)
local i2=hC.CFrame hC.CFrame=fB and jL or i2:Lerp(jL,jd)
aJ.Text=(hC.CFrame==i2)and "Aimed: Camera writes blocked" or("Target: " .. tostring(aH.DisplayName)) end else
aJ.Text="Status: Searching..." end end) tins(bn,cs.Stepped:Connect(function() local char=aY.Character
if not char then return end if ao.NoclipEnabled then for _,fX in ipairs(char:GetDescendants())do
if fX:IsA("BasePart")and fX.CanCollide then fX.CanCollide=false end end end if ao.CountdownBypass then
for _,child in ipairs(char:GetDescendants())do if child:IsA("BasePart")and child.Anchored then child.Anchored=false
elseif hj[child.Name]then pcall(function()child:Destroy()end) end end end end)) tins(bn,cs.Heartbeat:Connect(function(jv)
ji=workspace.CurrentCamera if not gt()then return end local char=aY.Character if not char then return end
local bT=char:FindFirstChild("HumanoidRootPart") local fd=char:FindFirstChildOfClass("Humanoid")
if not bT or not fd then return end fd:ChangeState(HST.Running) if aA:GetFocusedTextBox()then if bp then
bT.CFrame=CF(bp)*kN(ji.CFrame:ToEulerAnglesXYZ()) bT.AssemblyLinearVelocity=V3(0,0,0) bT.AssemblyAngularVelocity=V3(0,0,0)
end return end local bw=V3(0,0,0) local iD=ji.CFrame if aA:IsKeyDown(KC.W)then bw=bw+iD.LookVector end
if aA:IsKeyDown(KC.S)then bw=bw-iD.LookVector end if aA:IsKeyDown(KC.A)then bw=bw-iD.RightVector end
if aA:IsKeyDown(KC.D)then bw=bw+iD.RightVector end if aA:IsKeyDown(KC.Space)then bw=bw+V3(0,1,0)end
if ae.Settings.ShiftDownEnabled~=false then if aA:IsKeyDown(KC.LeftShift)or aA:IsKeyDown(KC.RightShift)then bw=bw-V3(0,1,0)
end end local f3=ae.Settings.FlySpeed or 50 if bw.Magnitude>0 then local k0=bw.Unit*(f3*jv) local jN=bT.Position+k0 bp=jN
bT.CFrame=CF(jN)*kN(iD:ToEulerAnglesXYZ()) bT.AssemblyLinearVelocity=bw.Unit*math.min(f3,45)
bT.AssemblyAngularVelocity=V3(0,0,0) else if not bp then bp=bT.Position end bT.CFrame=CF(bp)*kN(iD:ToEulerAnglesXYZ())
bT.AssemblyLinearVelocity=V3(0,0,0) bT.AssemblyAngularVelocity=V3(0,0,0) end if aX then aX.CFrame=bT.CFrame*CF(0,-3.1,0) end
end)) tins(bn,cs.Heartbeat:Connect(function() fU=fU+1 local kQ=os.clock() if kQ-gz>=0.5 then hJ=mfloor(fU/(kQ-gz)+0.5)
fU=0 gz=kQ local jO=0 pcall(function()jO=mfloor(aY:GetNetworkPing()*1000+0.5)end) local jq=ao.MouseLockKeybind or "None"
cI.Text=sfmt("FPS: %d  |  Ping: %d ms  |  Mouse Lock [%s]: %s",hJ,jO,jq,aD and "ON" or "OFF") end if kQ-fK>=2.0 then
fK=kQ if cU=="Player Radar" and not ah then c0()end if ao.ESPEnabled then bQ()end end
if ao.LockedTime~=nil then pcall(function()bM.ClockTime=ao.LockedTime end)end if ao.FullbrightEnabled then pcall(function()
bM.GlobalShadows=false bM.Brightness=2 bM.OutdoorAmbient=cX(255,255,255) end) end pcall(function()
if workspace.CurrentCamera and workspace.CurrentCamera.FieldOfView~=ao.FOV then workspace.CurrentCamera.FieldOfView=ao.FOV
end end) local char=aY.Character local bT=bm(char) local fd=char and char:FindFirstChildOfClass("Humanoid")
if not bT or not fd then return end if ao.AntiFlingEnabled and not bJ then
if bT.AssemblyLinearVelocity.Magnitude>250 or bT.AssemblyAngularVelocity.Magnitude>150 then
bT.AssemblyLinearVelocity=V3(0,0,0) bT.AssemblyAngularVelocity=V3(0,0,0) end end if ao.MasterUtilityEnabled and not bJ then
fd.WalkSpeed=ao.WalkSpeed fd.UseJumpPower=true fd.JumpPower=ao.JumpPower end end))
tins(bn,aA.InputBegan:Connect(function(bR,gp) if aA:GetFocusedTextBox()~=nil then return end
if bR.UserInputType==Enum.UserInputType.Keyboard then if bR.KeyCode==KC.Unknown then return end local cf=bR.KeyCode.Name if ah then local cb=ah ah=nil
if bR.KeyCode==KC.Delete or cf=="Delete" or bR.KeyCode==KC.Backspace or bR.KeyCode==KC.Escape then cb("None") else cb(cf) end
return end if bR.KeyCode==KC.X then d3(not fI) return end local jq=ao.MouseLockKeybind or "M" if jq~="None" and cf==jq then
_L0(not aD) return end if gp then return end local jU=ao.AimbotKeybind or "Q" if jU~="None" and cf==jU then fY() return end
if bR.KeyCode==KC.E and cU=="Items & Prompts" then if a5[1]then c2(a5[1])end return end
local jG=ae.Settings.FlyKeybind or "E" if jG~="None" and cf==jG and aL then d2() return end
for _,wp in ipairs(ae.Waypoints)do if wp.Keybind and wp.Keybind~="None" and wp.Keybind==cf then aZ(wp.X,wp.Y,wp.Z) end end
for plrName,boundKey in pairs(ae.RadarKeybinds)do if boundKey and boundKey~="None" and boundKey==cf then
local hn=c1:FindFirstChild(plrName) if hn and hn.Character then local kf=bm(hn.Character) if kf then local hh=kf.Position
aZ(hh.X,hh.Y+3,hh.Z) end end end end end end)) dn.MouseButton1Click:Connect(function() if a8 then return end
hs() bJ,bZ,aH,aL,fm,cJ=false,false,nil,false,false,false
ao.AimbotEnabled=false ao.AimbotFOVCircleEnabled=false ao.MasterFlightEnabled=false ao.MasterUtilityEnabled=false
ao.NoclipEnabled=false ao.CountdownBypass=false ao.AntiFlingEnabled=false ao.AntiCheatBypass=false ao.AntiAFK=false
ao.InstantPrompt=false ao.ESPEnabled=false ao.FullbrightEnabled=false ao.AutoSelectFling=false ao.LockedTime=nil
fS() if kP then kP()end if bA then for _,thread in ipairs(bA)do pcall(function()task.cancel(thread)end)end bA={} end
_L0(false) b0,ah=nil,nil pcall(function()cs:UnbindFromRenderStep("Aimbot_v2")end)
pcall(function()cs:UnbindFromRenderStep("TR_ShiftLock_Pre")end)
if aG then pcall(function()aG.Visible=false aG:Destroy()end)aG=nil end cO() bQ()
for _,conn in ipairs(bn)do pcall(function()conn:Disconnect()end)end bn={} pcall(function() local char=aY.Character
if char then local fd=char:FindFirstChildOfClass("Humanoid") local bT=bm(char) if fd then fd.PlatformStand=false
fd.AutoRotate=true fd.CameraOffset=V3(0,0,0) fd.WalkSpeed=16 fd.JumpPower=50 fd:SetStateEnabled(HST.FallingDown,true)
fd:SetStateEnabled(HST.Ragdoll,true) fd:SetStateEnabled(HST.Seated,true) fd:ChangeState(HST.GettingUp)
if workspace.CurrentCamera then workspace.CurrentCamera.CameraSubject=fd end end if bT then
for _,ch in ipairs(bT:GetChildren())do if ch:IsA("BodyVelocity")then ch:Destroy()end end
bT.AssemblyLinearVelocity=V3(0,0,0) bT.AssemblyAngularVelocity=V3(0,0,0) end for _,fX in ipairs(char:GetDescendants())do
if fX:IsA("BasePart")then fX.CanCollide=true fX.Velocity,fX.RotVelocity=V3(0,0,0),V3(0,0,0) end end end end) pcall(function()
if workspace.CurrentCamera then workspace.CurrentCamera.FieldOfView=ek.FOV end aY.CameraMode=ek.CameraMode
aY.CameraMinZoomDistance=ek.MinZoom aY.CameraMaxZoomDistance=ek.MaxZoom workspace.FallenPartsDestroyHeight=ih.FPDH
bM.ClockTime=bF.ClockTime bM.Brightness=bF.Brightness bM.GlobalShadows=bF.GlobalShadows bM.OutdoorAmbient=bF.OutdoorAmbient
end) d3(false,gy) a8=true tdelay(0.24,gy) end) gX(ao.Theme) fb(ao.CameraOverrideMode) c0() bY() bQ() cv() ih.TRHub={
["ScreenGui"]=dX,["MainFrame"]=aF,["Tabs"]=j6,["Config"]=ao, ["SavedConfig"]=ae,["SaveConfig"]=aj,["Connections"]=bn,
["CreateTab"]=dc,["CreateSectionHeader"]=aq,["CreateCard"]=aW, ["CreateToggle"]=a1,["CreateSlider"]=c7,["MakeButton"]=az,
["AddCorner"]=aB,["RegisterThemeObject"]=aa,["GetTheme"]=cQ, ["ApplyTheme"]=gX,["_L4"]=aZ,["GetRootPart"]=bm }
for _,addonFile in ipairs({"TRScripts_Part2.lua","TRScripts_Part3.lua","TRScripts_Addons.lua"})do pcall(function()
if g0(addonFile)then local k7=g3(addonFile) if k7 and #k7>0 then local fn=gw(k7) if fn then tspawn(fn)end end end end)
end
