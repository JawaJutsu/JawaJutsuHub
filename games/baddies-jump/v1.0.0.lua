-- Baddies Jump by JawaJutsu V1 | UI release built on the unchanged V7 jump controller.

-- Any streak drop or death counts as failure; reinforcement is not a success.

-- Configurable keys; auto-upgrade uses existing card/reroll buttons. No automatic run restart.

local Players=game:GetService("Players")

local UIS=game:GetService("UserInputService")

local RS=game:GetService("RunService")

local GS=game:GetService("GuiService")

local TweenService=game:GetService("TweenService")

local VirtualUser=game:GetService("VirtualUser")

-- Use the same press/release callbacks as the game input handler.

local P=Players.LocalPlayer

local PG=P:WaitForChild("PlayerGui")

local client=P.PlayerScripts:WaitForChild("Client")

local Session=require(client.Systems.SkippingSystem.Session)

local Input=require(client.ClientModules.ScarletInput)

for _,name in ipairs({string.char(66,97,100,100,105,101,65,117,116,111,74,117,109,112),string.char(66,97,100,100,105,101,65,100,97,112,116,105,118,101,74,117,109,112)}) do

 local old=PG:FindFirstChild(name);if old then old:Destroy() end

end

local gui=Instance.new("ScreenGui")

gui.IgnoreGuiInset=true;gui.Name=string.char(66,97,100,100,105,101,65,100,97,112,116,105,118,101,74,117,109,112);gui:SetAttribute("Version","V1");gui:SetAttribute("AppName",string.char(66,97,100,100,105,101,115,32,74,117,109,112,32,98,121,32,74,97,119,97,74,117,116,115,117));gui.ResetOnSpawn=false;gui.DisplayOrder=100;gui.Parent=PG

-- Presentation layer. The V7 jump planner below is unchanged.

local C={bg=Color3.fromRGB(17,22,31),surface=Color3.fromRGB(26,33,45),

 border=Color3.fromRGB(47,58,73),text=Color3.fromRGB(239,245,250),

 muted=Color3.fromRGB(151,167,183),accent=Color3.fromRGB(105,231,195),danger=Color3.fromRGB(247,133,148)}

local function round(o,n)
 local state=1
 local r
 while state~=3 do
  if state==1 then r=Instance.new("UICorner");state=2
  elseif state==2 then r.CornerRadius=UDim.new(0,n);r.Parent=o;state=3 end
 end
end

local function label(parent,name,value,x,y,w,h,size,color)

 local t=Instance.new("TextLabel");t.Name=name;t.Text=value;t.Position=UDim2.fromOffset(x,y)

 t.Size=UDim2.fromOffset(w,h);t.BackgroundTransparency=1;t.TextColor3=color or C.text

 t.Font=Enum.Font.Gotham;t.TextSize=size or 12;t.TextXAlignment=Enum.TextXAlignment.Left

 t.TextTruncate=Enum.TextTruncate.AtEnd;t.Parent=parent;return t

end

local function button(parent,name,value,x,y,w,h)

 local t=Instance.new("TextButton");t.Name=name;t.Text=value;t.Position=UDim2.fromOffset(x,y)

 t.Size=UDim2.fromOffset(w,h);t.BackgroundColor3=C.surface;t.TextColor3=C.text

 t.BorderSizePixel=0;t.Font=Enum.Font.GothamMedium;t.TextSize=14;t.AutoButtonColor=true

 t.Parent=parent;round(t,8);return t

end

local panel=Instance.new("Frame");panel.Name="Panel"

panel.Size=UDim2.fromOffset(324,480);panel.Position=UDim2.new(1,-344,.5,-240)

panel.BackgroundColor3=C.bg;panel.BorderSizePixel=0;panel.ClipsDescendants=true;panel.Parent=gui;round(panel,14)

local border=Instance.new("UIStroke");border.Color=C.border;border.Transparency=.2;border.Parent=panel

local uiScale=Instance.new("UIScale");uiScale.Parent=panel

local header=Instance.new("Frame");header.Name="DragHandle";header.Size=UDim2.new(1,-88,0,64)

header.BackgroundTransparency=1;header.Active=true;header.Parent=panel

local logo=Instance.new("ImageLabel");logo.Name="DeerLogo"

logo.Position=UDim2.fromOffset(12,12);logo.Size=UDim2.fromOffset(38,40)

logo.BackgroundColor3=C.surface;logo.BorderSizePixel=0;logo.ScaleType=Enum.ScaleType.Fit

logo.Parent=header;round(logo,8)

task.spawn(function()

 local ok,asset=pcall(function() return getcustomasset("JawaJutsu/deer.jpg") end)

 if ok and logo.Parent then

  logo.Image=asset

  pcall(function() game:GetService("ContentProvider"):PreloadAsync({logo}) end)

 else warn("JAWAJUTSU_UI|deer_asset_unavailable|"..tostring(asset)) end

end)

local title=label(header,"Title",string.char(66,97,100,100,105,101,115,32,74,117,109,112),56,7,174,22,14);title.Font=Enum.Font.GothamBold

label(header,"Author",string.char(98,121,32,74,97,119,97,74,117,116,115,117),56,28,174,15,10,C.muted)

local badge=label(header,"Version","V1",56,45,30,14,9,C.muted)

local compact=label(header,"CompactState","ACTIVE",92,45,138,14,9,C.accent)

local minimize=button(panel,"Minimize","−",240,18,30,28)

local close=button(panel,"Close","×",278,18,30,28);close.TextColor3=C.muted

local content=Instance.new("ScrollingFrame");content.Name="Content";content.Position=UDim2.fromOffset(0,64)

content.Size=UDim2.fromOffset(324,416);content.CanvasSize=UDim2.fromOffset(0,416);content.ScrollBarThickness=3;content.ScrollBarImageColor3=C.border;content.BorderSizePixel=0;content.ScrollingDirection=Enum.ScrollingDirection.Y;content.BackgroundTransparency=1;content.Parent=panel

local pageViewport=Instance.new("Frame");pageViewport.Name="PageViewport"

pageViewport.Position=UDim2.fromOffset(16,54);pageViewport.Size=UDim2.fromOffset(292,332)

pageViewport.BackgroundTransparency=1;pageViewport.ClipsDescendants=true;pageViewport.Parent=content

local tabHighlight=Instance.new("Frame");tabHighlight.Name="TabHighlight"

tabHighlight.Size=UDim2.fromOffset(92,32);tabHighlight.Position=UDim2.fromOffset(16,8)

tabHighlight.BackgroundColor3=C.border;tabHighlight.BorderSizePixel=0;tabHighlight.Parent=content;round(tabHighlight,8)

local tabs,pages={},{}  

for i,name in ipairs({"Play","Run","Settings"}) do

 tabs[name]=button(content,"Tab"..name,name,16+(i-1)*100,8,92,32);tabs[name].TextSize=12;tabs[name].BackgroundTransparency=1;tabs[name].ZIndex=2

 local page=Instance.new("Frame");page.Name=name.."Page";page.Position=UDim2.fromOffset(0,0)

 page.Size=UDim2.fromOffset(292,332);page.BackgroundTransparency=1;page.Visible=name=="Play";page.Parent=pageViewport

 pages[name]=page

end

local play,runPage,settings=pages.Play,pages.Run,pages.Settings

local modeLabel=label(play,"Mode","ADAPTIVE CONTROL  ·  ANTI-AFK ON",0,0,292,16,10,C.muted)

local status=label(play,"Status","Reading the rhythm…",0,23,292,24,14)

local values={}

for i,item in ipairs({{"Streak","STREAK"},{"Skips","SKIPS"},{"Ropes","ROPES"}}) do

 local card=Instance.new("Frame");card.Name=item[1].."Card";card.Position=UDim2.fromOffset((i-1)*100,59)

 card.Size=UDim2.fromOffset(92,66);card.BackgroundColor3=C.surface;card.BorderSizePixel=0;card.Parent=play;round(card,9)

 label(card,"Caption",item[2],12,8,70,14,9,C.muted)

 values[item[1]]=label(card,"Value","—",12,27,72,30,23,i==1 and C.accent or C.text)

 values[item[1]].Font=Enum.Font.GothamBold

end

local toggle=button(play,"Toggle","Pause auto jump",0,139,292,42)

toggle.BackgroundColor3=C.accent;toggle.TextColor3=C.bg;toggle.Font=Enum.Font.GothamBold

label(play,"UpgradeTitle","UPGRADE SELECTION",0,203,292,16,10,C.muted)

local manualUpgrade=button(play,"ManualUpgrade","Manual",0,229,142,36)

local upgradeToggle=button(play,"AutoUpgrade","Auto",150,229,142,36)

local upgradeDescription=label(play,"UpgradeDescription","Picks upgrades and rerolls for you.",0,276,292,34,11,C.muted)

upgradeDescription.TextWrapped=true;upgradeDescription.TextTruncate=Enum.TextTruncate.None

local upgradeNote=label(play,"UpgradeNote","Waiting for upgrade choices",0,314,292,16,10,C.accent)

local function surface(parent,name,y,height)

 local f=Instance.new("Frame");f.Name=name;f.Position=UDim2.fromOffset(0,y);f.Size=UDim2.fromOffset(292,height)

 f.BackgroundColor3=C.surface;f.BorderSizePixel=0;f.Parent=parent;round(f,10)

 local stroke=Instance.new("UIStroke");stroke.Color=C.border;stroke.Transparency=.55;stroke.Parent=f

 return f

end

local summaryTitle=label(runPage,"SummaryTitle","CURRENT RUN",0,0,292,16,10,C.muted)

local bestCard=surface(runPage,"BestCard",28,74)

label(bestCard,"Caption","PERSONAL BEST",14,10,264,14,9,C.muted)

local summaryBest=label(bestCard,"SummaryBest","Best streak —   ·   Level —",14,32,264,28,15,C.accent)

summaryBest.Font=Enum.Font.GothamBold

local perfectCard=surface(runPage,"PerfectCard",112,66)

label(perfectCard,"Caption","PRECISION",14,9,264,14,9,C.muted)

local summaryPerfect=label(perfectCard,"SummaryPerfect","Perfects —   ·   Rate —",14,29,264,26,12)

local timeCard=surface(runPage,"TimeCard",188,60)

label(timeCard,"Caption","TIME IN GAME",14,8,264,14,9,C.muted)

local summaryTime=label(timeCard,"SummaryTime","Game time —",14,28,264,24,14)

local runHelp=label(runPage,"RunHelp","If your streak resets, we count it as a failed run.",4,266,284,52,12,C.muted)

runHelp.TextWrapped=true;runHelp.TextTruncate=Enum.TextTruncate.None

local shortcutsCard=surface(settings,"ShortcutsCard",0,139)

label(shortcutsCard,"ShortcutTitle","SHORTCUTS",12,10,268,16,10,C.accent)

label(shortcutsCard,"ShortcutHelp","Click a shortcut to change its key.",12,31,268,18,11,C.muted)

local keyButtons={}

for i,item in ipairs({{"pause","Pause"},{"minimize","Minimize"},{"hide","Hide"}}) do

 keyButtons[item[1]]=button(shortcutsCard,"Key_"..item[1],item[2],12+(i-1)*91,57,86,40)

 keyButtons[item[1]].TextSize=10

 keyButtons[item[1]].BackgroundColor3=Color3.fromRGB(45,66,91)

 keyButtons[item[1]].TextColor3=Color3.fromRGB(200,225,255)

end

local keyHint=label(shortcutsCard,"KeyHint","Press F8 to bring this panel back.",12,102,268,32,10,C.muted)

keyHint.TextWrapped=true;keyHint.TextTruncate=Enum.TextTruncate.None

local timingCard=surface(settings,"TimingCard",149,83)

label(timingCard,"OffsetLabel","Timing offset",12,12,160,28,13)

local offsetBox=Instance.new("TextBox");offsetBox.Name="TimingOffset"

offsetBox.Size=UDim2.fromOffset(64,36);offsetBox.Position=UDim2.fromOffset(184,9)

offsetBox.BackgroundColor3=C.bg;offsetBox.BorderSizePixel=0;offsetBox.TextColor3=C.text

offsetBox.Font=Enum.Font.Gotham;offsetBox.TextSize=13;offsetBox.Text="0";offsetBox.ClearTextOnFocus=false

offsetBox.Parent=timingCard;round(offsetBox,7)

label(timingCard,"OffsetUnit","ms",255,15,25,22,11,C.muted)

label(timingCard,"OffsetHelp","Default: 0 · Adjust only when needed",12,53,268,18,11,C.muted)

local hideButton=button(settings,"HideUI","Hide interface  ·  F5",0,246,292,42);hideButton.TextSize=12

local settingsHelp=label(settings,"SettingsHelp","Hiding this panel keeps auto-jump running.",2,297,288,34,11,C.muted)

settingsHelp.TextWrapped=true;settingsHelp.TextTruncate=Enum.TextTruncate.None

local footer=label(content,"Footer","Anti-AFK stays on while hidden.",16,397,292,12,9,C.muted)

local shortcutKeys={pause=Enum.KeyCode.F6,minimize=Enum.KeyCode.F7,hide=Enum.KeyCode.F5}

local shortcutNames={pause="Pause",minimize="Minimize",hide="Hide"}

local captureKey=nil

local function refreshShortcuts()

 for action,control in pairs(keyButtons) do

  control.Text=shortcutNames[action].."  ["..shortcutKeys[action].Name.."]"

  gui:SetAttribute("Key_"..action,shortcutKeys[action].Name)

 end

 hideButton.Text="Hide interface  ·  "..shortcutKeys.hide.Name

end

local autoUpgrade=true

local telemetry=Instance.new("TextLabel");telemetry.Name="Telemetry";telemetry.Visible=false;telemetry.Parent=content

local uiTweens={}

local function animate(target,properties,duration)

 local previous=uiTweens[target]

 if previous then previous:Cancel() end

 local tween=TweenService:Create(target,TweenInfo.new(duration or .16,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),properties)

 uiTweens[target]=tween;tween:Play();return tween

end

local expandedHeight=480

local minimized=false

local function minimizeUI(v)

 minimized=v;content.Visible=not v

 header.Author.Visible=not v;badge.Visible=not v

 animate(logo,{Position=UDim2.fromOffset(12,v and 10 or 12),Size=UDim2.fromOffset(38,v and 38 or 40)},.22)

 animate(title,{Position=UDim2.fromOffset(56,v and 9 or 7)},.22)

 animate(compact,{Position=UDim2.fromOffset(v and 56 or 92,v and 32 or 45)},.22)

 animate(minimize,{Position=UDim2.fromOffset(v and 218 or 240,v and 12 or 18),Size=UDim2.fromOffset(v and 52 or 30,v and 34 or 28)},.22)

 animate(close,{Position=UDim2.fromOffset(278,v and 12 or 18),Size=UDim2.fromOffset(30,v and 34 or 28)},.22)

 animate(panel,{Size=UDim2.fromOffset(324,v and 58 or expandedHeight)},.24)

 header.Size=UDim2.new(1,v and -110 or -88,0,v and 58 or 64)

 minimize.Text=v and "Open" or "−";minimize.TextSize=v and 11 or 14

 gui:SetAttribute("Minimized",v)

end

local active,closed,focused,menu=true,false,true,false

local down=false

local releaseAt=0

local offset=0

local nextAllowed=0

local lastSim=nil

local samples={}

local connections={}

local TAU=2*math.pi

local function bind(signal,fn) local c=signal:Connect(fn);table.insert(connections,c);return c end

local currentPage=nil

local pageOrder={Play=1,Run=2,Settings=3}

local function showPage(name)

 if currentPage==name then return end

 captureKey=nil;refreshShortcuts();content.CanvasPosition=Vector2.zero

 keyHint.Text="Press F8 to bring this panel back."

 currentPage=name

 for pageName,page in pairs(pages) do

  page.Visible=pageName==name

  page.Position=UDim2.fromOffset(0,0)

  animate(tabs[pageName],{TextColor3=pageName==name and C.text or C.muted},.18)

 end

 animate(tabHighlight,{Position=UDim2.fromOffset(16+(pageOrder[name]-1)*100,8)},.26)

 gui:SetAttribute("Page",name)

end

for name,control in pairs(tabs) do bind(control.Activated,function() showPage(name) end) end

showPage("Play")

local function key(v)

 return pcall(function()

  local cb=Input.callbacks and Input.callbacks[v and "OnPress" or "OnRelease"]

  assert(type(cb)=="function","Game input callback unavailable")

  cb()

 end)

end

local function release() if down then key(false);down=false end end

local function refresh()

 toggle.Text=active and "Pause auto jump" or "Resume auto jump"

 toggle.BackgroundColor3=active and C.accent or C.surface

 toggle.TextColor3=active and C.bg or C.text

 compact.Text=active and "ACTIVE" or "PAUSED";compact.TextColor3=active and C.accent or C.muted

 gui:SetAttribute("Active",active)

end

local function setActive(v) active=v;release();nextAllowed=os.clock()+0.15;refresh() end

local function shown(n)

 if not n then return false end

 while n and n~=PG do

 if n:IsA("GuiObject") and not n.Visible then return false end

 if n:IsA("ScreenGui") and not n.Enabled then return false end

 n=n.Parent

 end

 return true

end

local function pause(sim)

 if not focused then return "Paused · Roblox unfocused" end

 if menu then return "Paused · Roblox menu" end

 if UIS:GetFocusedTextBox() then return "Paused · typing" end

 if Session.Spectating or not Session.InRun then return "Ready · press PLAY" end

 if not sim or not sim.run or not sim.run.alive then return "Waiting for a new run" end

 if sim.paused or (Session.PendingLevelUps or 0)>0 then return "Paused · choose a card" end

 local cards=PG:FindFirstChild("Cards")

 if cards and shown(cards:FindFirstChild("UpgradeCards")) then return "Paused · choose a card" end

 return nil

end

-- Anti-AFK adapted from the user's clean Anti-AFK Remake.

-- Owned connection only: other scripts' idle handlers are left intact.

local function onIdle()

 if closed then return end

 local ok,err=pcall(function()

  VirtualUser:CaptureController()

  VirtualUser:ClickButton2(Vector2.new(0,0))

 end)

 if closed then return end

 gui:SetAttribute("AntiAFKLastSuccess",ok)

 if ok then

  gui:SetAttribute("AntiAFKPulses",(gui:GetAttribute("AntiAFKPulses") or 0)+1)

 else

  modeLabel.Text="ADAPTIVE CONTROL  ·  ANTI-AFK ERROR"

  warn("JAWAJUTSU_AFK|input_failed|"..tostring(err))

 end

end

bind(P.Idled,onIdle)

gui:SetAttribute("AntiAFKEnabled",true)

-- A separate tint preserves selected/active button colors during transitions.

for _,control in ipairs({toggle,minimize,close,hideButton,keyButtons.pause,keyButtons.minimize,keyButtons.hide,upgradeToggle,manualUpgrade,tabs.Play,tabs.Run,tabs.Settings}) do

 control.AutoButtonColor=false

 local tint=Instance.new("Frame");tint.Name="HoverTint";tint.Size=UDim2.fromScale(1,1)

 tint.BackgroundColor3=C.accent;tint.BackgroundTransparency=1;tint.BorderSizePixel=0

 tint.Active=false;tint.ZIndex=control.ZIndex+1;tint.Parent=control;round(tint,8)

 local stroke=Instance.new("UIStroke");stroke.Color=C.accent;stroke.Transparency=1;stroke.Parent=control

 local hovering=false

 local function state(pressed)

  animate(tint,{BackgroundTransparency=pressed and .78 or (hovering and .9 or 1)},.14)

  animate(stroke,{Transparency=hovering and .4 or 1},.14)

 end

 bind(control.MouseEnter,function() hovering=true;state(false) end)

 bind(control.MouseLeave,function() hovering=false;state(false) end)

 bind(control.InputBegan,function(input)

  if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then state(true) end

 end)

 bind(control.InputEnded,function(input)

  if input.UserInputType==Enum.UserInputType.Touch then hovering=false;state(false)

  elseif input.UserInputType==Enum.UserInputType.MouseButton1 then state(false) end

 end)

end

panel.BackgroundTransparency=.55

border.Transparency=1

animate(panel,{BackgroundTransparency=0},.28)

animate(border,{Transparency=.2},.35)

-- UI interactions do not alter planner timing or pause the controller.

local dragging=false

local dragStart,dragPosition,dragTouch=nil,nil,nil

local function fitPanel()

 local camera=workspace.CurrentCamera;if not camera then return end

 local viewport=camera.ViewportSize

 local scale=math.clamp((viewport.X-24)/324,.65,1)

 uiScale.Scale=scale

 expandedHeight=math.clamp((viewport.Y-24)/scale,220,480)

 content.Size=UDim2.fromOffset(324,expandedHeight-64)

 panel.Size=UDim2.fromOffset(324,minimized and 58 or expandedHeight)

 -- Stay in parent-local coordinates. AbsolutePosition includes screen insets
 -- on some clients and must not be repeatedly written back into Position.
 local position=panel.Position

 local x=position.X.Scale*viewport.X+position.X.Offset

 local y=position.Y.Scale*viewport.Y+position.Y.Offset

 -- Preserve the user's position, including coordinates beyond the viewport.
 panel.Position=UDim2.fromOffset(x,y)

end

local function cancelDrag()

 dragging=false;dragTouch=nil;dragStart=nil;dragPosition=nil

end

local function beginDrag(input)

 if dragging then return end

 if input.UserInputType~=Enum.UserInputType.MouseButton1 and input.UserInputType~=Enum.UserInputType.Touch then return end

 local point=input.Position

 local p,size=header.AbsolutePosition,header.AbsoluteSize

 if point.X<p.X or point.Y<p.Y or point.X>=p.X+size.X or point.Y>=p.Y+size.Y then return end

 fitPanel()

 dragging=true;dragStart=point

 dragPosition=Vector2.new(panel.Position.X.Offset,panel.Position.Y.Offset)

 dragTouch=input.UserInputType==Enum.UserInputType.Touch and input or nil

end

local function moveDrag(input)

 if not dragging then return end

 if dragTouch then

  if input~=dragTouch then return end

 elseif input.UserInputType~=Enum.UserInputType.MouseMovement then

  return

 elseif not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then

  cancelDrag();return

 end

 local delta=input.Position-dragStart

 panel.Position=UDim2.fromOffset(dragPosition.X+delta.X,dragPosition.Y+delta.Y)

end

local function endDrag(input)

 if not dragging then return end

 if (dragTouch and input==dragTouch) or

  (not dragTouch and input.UserInputType==Enum.UserInputType.MouseButton1) then

  cancelDrag();fitPanel()

 end

end

bind(minimize.Activated,function() cancelDrag();fitPanel();minimizeUI(not minimized) end)

bind(header.InputBegan,beginDrag)

bind(UIS.InputChanged,moveDrag)

bind(UIS.InputEnded,endDrag)

bind(UIS.WindowFocusReleased,cancelDrag)

local function restorePanel()

 cancelDrag();panel.Visible=true;gui:SetAttribute("Hidden",false)

 local camera=workspace.CurrentCamera;if not camera then return end

 local viewport=camera.ViewportSize

 fitPanel()

 panel.Position=UDim2.fromOffset(math.max(8,viewport.X-324*uiScale.Scale-20),48)

end

local function hideUI(value)

 cancelDrag();captureKey=nil;refreshShortcuts()

 keyHint.Text="Press F8 to bring this panel back."

 panel.Visible=not value;gui:SetAttribute("Hidden",value)

end

bind(hideButton.Activated,function() hideUI(true) end)

for action,control in pairs(keyButtons) do

 bind(control.Activated,function()

  refreshShortcuts();captureKey=action;control.Text="Press a key…"

  keyHint.Text="Press a new key. Esc cancels; F8 is reserved."

 end)

end

local function handleShortcut(input,processed)

 if input.UserInputType~=Enum.UserInputType.Keyboard or UIS:GetFocusedTextBox() then return end

 local code=input.KeyCode

 if captureKey then

  if code==Enum.KeyCode.Escape then

   captureKey=nil;refreshShortcuts();keyHint.Text="Shortcut change cancelled.";return

  end

  if code==Enum.KeyCode.F8 or code==Enum.KeyCode.Unknown or

   code==Enum.KeyCode.LeftShift or code==Enum.KeyCode.RightShift or

   code==Enum.KeyCode.LeftControl or code==Enum.KeyCode.RightControl or

   code==Enum.KeyCode.LeftAlt or code==Enum.KeyCode.RightAlt then

   keyHint.Text="Choose another key; F8 and modifiers are reserved.";return

  end

  for action,assigned in pairs(shortcutKeys) do

   if action~=captureKey and assigned==code then

    keyHint.Text="Key already assigned. Choose another key.";return

   end

  end

  shortcutKeys[captureKey]=code;captureKey=nil;refreshShortcuts()

  keyHint.Text="Shortcut updated for this session.";return

 end

 -- UI shortcuts intentionally accept processed input, but never while typing.
 if code==Enum.KeyCode.F8 then restorePanel();return end

 if code==shortcutKeys.hide then hideUI(panel.Visible);return end

 if code==shortcutKeys.minimize then cancelDrag();fitPanel();minimizeUI(not minimized);return end

 if code==shortcutKeys.pause and not processed then setActive(not active) end

end

bind(UIS.InputBegan,handleShortcut)

refreshShortcuts()

local uiTick=0

bind(RS.Heartbeat,function(dt)

 uiTick+=dt;if uiTick<.15 then return end;uiTick=0

 local sim=Session.Simulation

 local run=sim and sim.run

 values.Streak.Text=tostring(run and run.combo or 0)

 values.Skips.Text=tostring(run and run.skips or 0)

 values.Ropes.Text=tostring(sim and sim.ropes and #sim.ropes or 0)

 local count=gui:GetAttribute("DetectedHits") or 0

 footer.Text="Observed session failures: "..count.."  ·  Anti-AFK ON"

 summaryTitle.Text=run and not run.alive and "COMPLETED RUN" or "CURRENT RUN"

 summaryBest.Text=string.format("Best streak %d   ·   Level %d",run and run.bestCombo or 0,run and run.level or 0)

 local skips=run and run.skips or 0

 local perfects=run and run.perfects or 0

 summaryPerfect.Text=string.format("Perfects %d / %d   ·   %.1f%%",perfects,skips,skips>0 and perfects/skips*100 or 0)

 local duration=math.floor(run and run.elapsed or 0)

 summaryTime.Text=string.format("Game time %02d:%02d",math.floor(duration/60),duration%60)

 footer.TextColor3=count>0 and C.danger or C.muted

 compact.Text=not active and "PAUSED" or (run and run.alive and Session.InRun and ("STREAK "..tostring(run.combo or 0)) or "READY")

end)

local camera=workspace.CurrentCamera

if camera then bind(camera:GetPropertyChangedSignal("ViewportSize"),fitPanel) end

task.defer(fitPanel)

bind(toggle.Activated,function() setActive(not active) end)

bind(close.Activated,function() gui:Destroy() end)

bind(offsetBox.FocusLost,function()

 local n=tonumber(offsetBox.Text)

 if n and n==n then offset=math.clamp(n,-150,150)/1000 end

 offsetBox.Text=tostring(math.floor(offset*1000))

end)

bind(UIS.WindowFocusReleased,function() focused=false;release() end)

bind(UIS.WindowFocused,function() focused=true end)

bind(GS.MenuOpened,function() menu=true;release() end)

bind(GS.MenuClosed,function() menu=false end)

bind(gui.Destroying,function()

 closed=true;active=false;release()

 gui:SetAttribute("AntiAFKEnabled",false)

 for _,tween in pairs(uiTweens) do tween:Cancel() end

 table.clear(uiTweens)

 for _,c in ipairs(connections) do c:Disconnect() end

 print("BADDIE_AJ7|unloaded")

end)

-- Predict using the game's body integrator on isolated scalar-only state.

local Body=require(game:GetService("ReplicatedStorage").Shared.Modules.ScarletSkips.RunSimulation.Body)

local RopeModel=require(game:GetService("ReplicatedStorage").Shared.Modules.ScarletSkips.RunSimulation.Ropes)

local function dummyBody(stats)

 local b={stats=stats,height=0,velocity=stats.jumpVelocity,grounded=false,

  holding=true,holdTime=0,hangLeft=0,hangGranted=false,bufferLeft=0,

  flying=false,fuelLeft=stats.flightFuel or 0,slamming=false,airTime=0,drift=0}

 function b:StopFlight() self.flying=false end

 function b:Land()

  self.height=0;self.velocity=0;self.grounded=true;self.flying=false

  self.airTime=0;self.hangLeft=0;self.hangGranted=false;self.holdTime=0

 end

 return b

end

local function makeProfiles(stats,clearance,frameStep)

 local profiles={}

 local options={}

 for i=0,22 do options[#options+1]={hold=math.max(.001,(stats.maxHoldTime or .22)*i/22)} end

 if (stats.flightClimb or 0)>0 and (stats.flightFuel or 0)>0 and (stats.airJumps or 0)==0 then

  for _,duration in ipairs({.04,.08,.12,.16,.20,.24,.28}) do

   options[#options+1]={hold=.22,flight=.24,duration=math.min(duration,stats.flightFuel)}

  end

 end

 if (stats.slamGravity or 0)>1 and (stats.airJumps or 0)==0 and (stats.flightClimb or 0)==0 then

  for _,moment in ipairs({.35,.5,.65}) do options[#options+1]={hold=.22,slam=moment} end

 end

 for _,option in ipairs(options) do

  local body=dummyBody(stats)

  local t=0;local step=frameStep

  local heights={0};local first,last,apex,top=nil,nil,0,0

  local fired,slammed=false,false

  local flightStop=nil

  for frame=1,math.ceil(5/step) do

   body.holding=t<option.hold

   if option.flight and not fired and t>=option.flight then

    fired=true;flightStop=t+option.duration;body.flying=true;body.hangLeft=0

   end

   if fired and t>=flightStop-1e-8 then body:StopFlight() end

   if option.slam and not slammed and t>=option.slam and body.height>=1.2 then

    slammed=true;body.slamming=true;body.velocity=math.min(body.velocity,0);body.hangLeft=0

   end

   Body.StepBody(body,step)

   t+=step;heights[#heights+1]=body.height

   if body.height>top then top=body.height;apex=t end

   if body.height>=clearance then first=first or t;last=t end

   if body.grounded then break end

  end

  if first and body.grounded then

   profiles[#profiles+1]={hold=option.hold,land=t,first=first,last=last,apex=apex,

    heights=heights,step=step,slam=slammed and option.slam or nil,flight=option.flight,duration=option.duration}

  end

 end

 return profiles

end

local function heightAt(profile,t)

 if t<0 or t>=profile.land then return 0 end

 local x=t/profile.step

 local index=math.floor(x)+1

 local alpha=x-math.floor(x)

 local lo=profile.heights[index] or 0

 local hi=profile.heights[index+1] or 0

 return lo+(hi-lo)*alpha

end

-- Beam search: all rope crossings before landing must be safe, including

-- crossings that happen after the first target. Replan after every landing.

local function choosePlan(events,profiles,clearance)

 local beam={{i=1,ready=0,quality=0}}

 local best=nil

 for depth=1,10 do

  local nextBeam={}

  for _,node in ipairs(beam) do

   if node.i>#events then

    if not best or node.quality>best.quality then best=node end

   else

    local firstEvent=events[node.i]

    for _,p in ipairs(profiles) do

     local ages={p.apex}

     for count=1,math.min(12,#events-node.i+1) do

      local span=events[node.i+count-1]-firstEvent

      if span<=p.last-p.first then

       ages[#ages+1]=(p.first+p.last-span)/2

       ages[#ages+1]=p.first+0.02

       ages[#ages+1]=p.last-span-0.02

      end

     end

     for _,age in ipairs(ages) do

      local start=firstEvent-age

      if start>=node.ready-0.012 then

       start=math.ceil(math.max(start,node.ready)/p.step-1e-6)*p.step

       local landing=start+p.land

       local j=node.i

       local margin=math.huge

       local valid=true

       while j<=#events and events[j]<=landing+0.018 do

        local age=events[j]-start

        local y=math.min(heightAt(p,age-.018),heightAt(p,age),heightAt(p,age+.018))

        if y<clearance then valid=false;break end

        margin=math.min(margin,y-clearance)

        j=j+1

       end

       if valid and j>node.i then

        local candidate={i=j,ready=landing+p.step,

         quality=node.quality+math.min(margin,2)-0.05*p.hold,

         start=node.start or start,hold=node.hold or p.hold,

         group=node.group or (j-node.i),slam=node.slam or (not node.start and p.slam or nil),

         flight=node.flight or (not node.start and p.flight or nil),duration=node.duration or (not node.start and p.duration or nil)}

        nextBeam[#nextBeam+1]=candidate

       end

      end

     end

    end

   end

  end

  if #nextBeam==0 then break end

  table.sort(nextBeam,function(a,b)

   if a.i~=b.i then return a.i>b.i end

   return a.quality>b.quality

  end)

  beam={}

  local seen={}

  for _,candidate in ipairs(nextBeam) do

   local key=tostring(candidate.i)..":"..tostring(math.floor(candidate.ready*120+.5))

   if not seen[key] then

    seen[key]=true;beam[#beam+1]=candidate

    if #beam>=12 then break end

   end

  end

 end

 for _,node in ipairs(beam) do

  if node.i>#events and (not best or node.quality>best.quality) then best=node end

 end

 if best then return best end

 -- A partial plan is explicitly marked; it is not proof of sustainable timing.
 table.sort(beam,function(a,b) if a.i~=b.i then return a.i>b.i end return a.quality>b.quality end)

 if beam[1] and beam[1].start then beam[1].partial=true;return beam[1] end

 return nil

end

-- Streak-first upgrade policy. Scores are heuristic, not a global optimum.

local UpgradeCatalog=require(game.ReplicatedStorage.Shared.Modules.ScarletSkips.Upgrades)

local UpgradeModifiers=require(game.ReplicatedStorage.Shared.Modules.ScarletSkips.Modifiers)

local CardView=require(client.ClientModules.CardView)

local upgradeByName={}

for _,definition in pairs(UpgradeCatalog.All()) do upgradeByName[definition.name]=definition end

local priority={low_rope=90,long_rope=80,rocket_boots=85,sky_hook=66,better_legs=60,

 helium=63,steady_hands=58,phase_step=58,clutch=56,afterimage=72,

 reroll=52,perfect_pitch=42,four_leaf=40,fire_rope=34,slipstream=48,

 midas=33,jackpot=32,windfall=32,cascade=34,clockwork=39,bullet_time=45,

 reinforced=18,ironclad=22,phoenix=16,bonfire=30,stomp=38,

 double_dutch=10,whip_crack=-35,overclock=-40}

local function rankUpgrade(sim,definition)

 local id=definition.id

 local stacks=sim.run.stacks or {}

 local owned=stacks[id] or 0

 if definition.maxStacks and owned>=definition.maxStacks then return -1000,"Already at maximum" end

 local future=table.clone(sim.run);future.stacks=table.clone(stacks)

 future.stacks[id]=owned+1

 -- Compute creates fresh stats; acquisition hooks are never run on live state.
 local nextStats=UpgradeModifiers.Compute(future,sim.ownedSkills,sim.skin)

 local base=sim.stats

 local score=(priority[id] or 20)/(1+owned*.3)

 local reason="Best remaining build value"

 if id=="low_rope" then reason="Lower clearance protects the streak"

 elseif id=="long_rope" then reason="More time between rope crossings"

 elseif id=="rocket_boots" then

  reason="Flight gives control over landing"

  if (base.flightClimb or 0)<=0 then score+=20 else score-=15 end

 elseif id=="slipstream" and (base.flightClimb or 0)<=0 then score=8;reason="Needs Rocket Boots first"

 elseif id=="sky_hook" then reason="Longer safe airborne window"

 elseif id=="afterimage" or id=="phase_step" then reason="Can prevent a rope hit"

 elseif id=="reinforced" or id=="ironclad" or id=="phoenix" then reason="Backup survival; does not guarantee streak"

 elseif id=="reroll" then reason="More choices at future upgrades"

 elseif id=="double_dutch" then reason="Extra reward, but tighter rope spacing"

 elseif id=="whip_crack" or id=="overclock" then reason="Higher rope speed increases timing risk"

 end

 local oldGap=TAU/math.max(.001,(base.ropeSpeed or 1)*(base.ropeCount or 1))

 local newGap=TAU/math.max(.001,(nextStats.ropeSpeed or 1)*(nextStats.ropeCount or 1))

 score+=math.clamp((newGap/oldGap-1)*110,-55,35)

 score+=math.clamp(((base.ropeClearance or .8)-(nextStats.ropeClearance or .8))*60,-30,30)

 if id=="steady_hands" and (base.ropeSpeedPerLevel or 0)<=0 then score=22;reason="Little level-speed growth to reduce" end

 if id=="stomp" and (base.flightClimb or 0)>0 then score=8;reason="Flight takes priority over the air-press action" end

 if id=="double_dutch" and (base.ropeCount or 1)>=5 then score-=25 end

 if id=="reroll" and (base.rerolls or 0)>=5 then score-=20 end

 -- Check changed movement against several evenly spaced rope phases.
 local motionChanged=false

 for _,field in ipairs({"jumpVelocity","gravity","hangTime","ropeCount","ropeSpeed","ropeClearance","flightClimb","flightFuel","slamGravity"}) do

  if nextStats[field]~=base[field] then motionChanged=true;break end

 end

 if motionChanged then

  local clearance=(nextStats.ropeClearance or .8)+.16

  local options=makeProfiles(nextStats,clearance,1/60)

  local feasible=0

  for _,phase in ipairs({.35,.7}) do

   local events={}

   for i=0,math.min(12,math.max(3,(nextStats.ropeCount or 1)*3))-1 do events[#events+1]=newGap*(phase+i) end

   local plan=choosePlan(events,options,clearance)

   if plan and not plan.partial then feasible+=1 end

  end

  score+=feasible*8

  if feasible==0 then score-=35;reason=reason.." · uncertain timing" end

 end

 return score,reason

end

local function pickDecision(ranked,rerolls)

 table.sort(ranked,function(a,b) if a.score==b.score then return a.index<b.index end return a.score>b.score end)

 local best=ranked[1]

 if not best then return nil end

 local threshold=rerolls>1 and 60 or 50

 if rerolls>0 and best.score<threshold then return "reroll",best end

 return "pick",best

end

local function readUpgradeHand(sim)

 local cards=PG:FindFirstChild("Cards")

 if not cards or not cards.Enabled or not CardView.IsOpen() or CardView.IsVoting() then return nil end

 local choices={}

 for i=1,12 do

  local btn=CardView.GetSlotButton(i)

  if btn and shown(btn) then

   local holder=btn:FindFirstChild("UpgradeName")

   local name=holder and holder:FindFirstChild("Text")

   local def=name and upgradeByName[name.Text]

   if not def then return nil end

   choices[#choices+1]={index=i,button=btn,definition=def}

  end

 end

 if #choices==0 then return nil end

 local rerolls=math.max(0,tonumber(sim.run.rerollsLeft) or 0)

 local rbutton=cards:FindFirstChild("Reroll")

 -- Only the existing free-reroll button is eligible. Never purchases anything.
 local shownCount=rbutton and tonumber(rbutton.Text:match("%((%d+)%)"))

 if not rbutton or not shown(rbutton) or not shownCount then rerolls=0 else rerolls=math.min(rerolls,shownCount) end

 local parts={tostring(sim),tostring(sim.run.level),tostring(rerolls),tostring(#sim.run.picks)}

 for _,entry in ipairs(choices) do parts[#parts+1]=entry.definition.id end

 return choices,rerolls,rbutton,table.concat(parts,"/")

end

local function activateUpgradeButton(btn)

 if not btn or not btn.Parent or not shown(btn) then error("Upgrade button is not visible") end

 local callbacks={}

 for _,connection in ipairs(getconnections(btn.Activated)) do

  if type(connection.Function)=="function" and connection.Enabled~=false then callbacks[#callbacks+1]=connection.Function end

 end

 assert(#callbacks==1,"Upgrade action has an unexpected callback count")

 callbacks[1]()

end

local upgradeHand=nil

local handSince=0

local lastUpgradeAction=nil

local upgradeSentAt=0

local upgradeBusy=false

local upgradeTick=0

local function setUpgradeMode(enabled)

 autoUpgrade=enabled

 upgradeHand=nil;lastUpgradeAction=nil

 upgradeToggle.BackgroundColor3=enabled and C.accent or C.surface

 upgradeToggle.TextColor3=enabled and C.bg or C.muted

 manualUpgrade.BackgroundColor3=enabled and C.surface or C.accent

 manualUpgrade.TextColor3=enabled and C.muted or C.bg

 upgradeDescription.Text=enabled and "Picks upgrades and rerolls for you." or "Choose your own upgrades. Auto-jump stays on."

 upgradeNote.Text=enabled and "Waiting for upgrade choices" or "You choose cards · reroll is manual"

 gui:SetAttribute("AutoUpgrade",enabled)

end

bind(upgradeToggle.Activated,function() if not autoUpgrade then setUpgradeMode(true) end end)

bind(manualUpgrade.Activated,function() if autoUpgrade then setUpgradeMode(false) end end)

setUpgradeMode(autoUpgrade)

bind(RS.Heartbeat,function(dt)

 upgradeTick+=dt

 if upgradeTick<.2 or upgradeBusy or closed then return end

 upgradeTick=0

 if not autoUpgrade or not active or captureKey then return end

 local sim=Session.Simulation

 if not sim or not Session.InRun or Session.Spectating or not sim.run.alive then upgradeHand=nil;return end

 if not CardView.IsOpen() then upgradeHand=nil;lastUpgradeAction=nil;return end

 upgradeBusy=true

 task.spawn(function()

  local ok,err=pcall(function()

   local choices,rerolls,rbutton,signature=readUpgradeHand(sim)

   if not choices then upgradeNote.Text="Waiting for readable solo upgrade cards";return end

   if signature~=upgradeHand then

    upgradeHand=signature;handSince=os.clock();lastUpgradeAction=nil

    upgradeNote.Text="Reading upgrades…";return

   end

   if os.clock()-handSince<1 then return end

   if lastUpgradeAction==signature then

    if os.clock()-upgradeSentAt>4 then error("Upgrade did not change; automation paused") end

    return

   end

   for _,entry in ipairs(choices) do entry.score,entry.reason=rankUpgrade(sim,entry.definition) end

   local action,best=pickDecision(choices,rerolls)

   if not action then return end

   -- Recheck the live hand immediately before invoking the normal UI callback.
   local _,_,_,fresh=readUpgradeHand(sim)

   if closed or not autoUpgrade or not active or Session.Simulation~=sim or fresh~=signature then return end

   lastUpgradeAction=signature;upgradeSentAt=os.clock()

   gui:SetAttribute("UpgradeDecision",action..":"..best.definition.id)

   upgradeNote.Text=action=="reroll" and ("Rerolling · "..rerolls.." left") or ("Picking "..best.definition.name)

   print(string.format("JAWAJUTSU_UPGRADE|%s|card=%s|score=%.1f|rerolls=%d|reason=%s",action,best.definition.id,best.score,rerolls,best.reason))

   activateUpgradeButton(action=="reroll" and rbutton or best.button)

  end)

  if not ok and not closed then

   setUpgradeMode(false)

   upgradeNote.Text="Auto-pick paused · choose manually"

   warn("JAWAJUTSU_UPGRADE|error|"..tostring(err))

  end

  upgradeBusy=false

 end)

end)

local lastLog=0

local lastPlanAt=0

local committed=nil

local plannedHold=0

local plannedSlam=nil

local plannedFlight=nil

local flightEnd=nil

local forecastAt=-1

local wasAirborne=false

local observedDt=1/60

local lastCombo,lastSkips=0,0

local lastElapsed=nil

local lastAlive=false

local failures=0

local history={}

local lastSnapshot=0

local lastShield=nil

local lastClockSim=nil

local activeJump=false

local profileKey=""

local profiles={}

local function resetPlan()

 committed=nil;lastPlanAt=0;samples={};plannedSlam=nil;plannedFlight=nil;flightEnd=nil;forecastAt=-1;wasAirborne=false

end

bind(RS.Heartbeat,function(dt)

 if closed then return end

 local now=os.clock()

 local sim=Session.Simulation

 local elapsed=sim and sim.run and sim.run.elapsed or 0

 local fresh=sim~=lastSim or (lastElapsed and elapsed<lastElapsed-.001)

 if fresh then

  lastSim=sim;release();resetPlan();nextAllowed=0

  lastCombo=sim and sim.run and sim.run.combo or 0

  lastSkips=sim and sim.run and sim.run.skips or 0

  lastAlive=sim and sim.run and sim.run.alive or false

  lastElapsed=nil;lastShield=nil;history={};activeJump=false

  gui:SetAttribute("RunFailed",false)

 end

 local simDt=lastElapsed and elapsed-lastElapsed or 0

 if simDt>0 and simDt<.15 then

  observedDt=observedDt*.8+simDt*.2

 end

 if sim and sim.run then

  local shield=0

  for _,rope in ipairs(sim.ropes or {}) do

   if rope.shielded then shield=shield+(rope.shieldHits or 1) end

  end

  local combo=sim.run.combo or 0

  local died=lastAlive and not sim.run.alive

  local dropped=combo<lastCombo and (sim.run.skips or 0)>=lastSkips

  local shieldHit=lastShield and shield<lastShield

  if not fresh and (died or dropped or shieldHit) then

   failures=failures+1

   gui:SetAttribute("DetectedHits",failures)

   gui:SetAttribute("RunFailed",true)

   warn(string.format("BADDIE_AJ7|FAIL|death=%s|streak=%d>%d|shield=%s|ropes=%d|h=%.3f|v=%.3f",

    tostring(died),lastCombo,combo,tostring(shieldHit),#sim.ropes,sim.height,sim.velocity))

   for _,line in ipairs(history) do print("BADDIE_AJ7|trace|"..line) end

  end

  lastCombo=combo;lastSkips=sim.run.skips or 0;lastAlive=sim.run.alive;lastShield=shield

  if now-lastSnapshot>=.04 and sim.run.alive and simDt>0 then

   lastSnapshot=now

   local angles={}

   for _,rope in ipairs(sim.ropes or {}) do angles[#angles+1]=string.format("%.3f",rope.angle) end

   history[#history+1]=string.format("t=%.4f,dt=%.4f,h=%.3f,v=%.3f,ground=%s,hold=%s,ht=%.3f,paused=%s,combo=%d,phase=%.3f,plan=%s,angles=%s",

    elapsed,simDt,sim.height,sim.velocity,tostring(sim.grounded),tostring(sim.holding),

    sim.holdTime or 0,tostring(sim.paused),combo,sim.phaseCorrection or 0,

    committed and string.format("%.4f",committed.at) or "-",table.concat(angles,","))

   if #history>75 then table.remove(history,1) end

  end

 end

 lastElapsed=elapsed

 if not active then status.Text="OFF";release();resetPlan();activeJump=false;return end

 local reason=pause(sim)

 if reason then

  status.Text=reason

  -- Card selection freezes simulation time. Preserve the current physical hold.
  if reason=="Paused · choose a card" then committed=nil;lastPlanAt=0;return end

  release();resetPlan();activeJump=false

  if sim and sim.run and not sim.run.alive and gui:GetAttribute("RunFailed") then status.Text="Run ended · failure recorded" end

  return

 end

 if down and not sim.flying and ((sim.holdTime or 0)>=plannedHold or sim.grounded) then release() end

 if flightEnd and (elapsed>=flightEnd-1e-8 or not sim.flying) then release();flightEnd=nil;forecastAt=-1 end

 if plannedFlight and not sim.grounded and sim.airTime>=plannedFlight.at then

  if (sim.airJumpsLeft or 0)==0 and (sim.fuelLeft or 0)>0 then

   release();local ok=key(true)

   if ok and sim.flying then down=true;flightEnd=elapsed+plannedFlight.duration end

  end

  plannedFlight=nil;forecastAt=-1

 end

 if sim.grounded then activeJump=false end

 if plannedSlam and not sim.grounded and sim.airTime>=plannedSlam and sim.height>=1.2

  and (sim.airJumpsLeft or 0)==0 and (sim.stats.flightClimb or 0)==0 then

  release()

  local pressed,err=key(true)

  key(false)

  plannedSlam=nil

  if not pressed then warn("BADDIE_AJ7|stomp_error|"..tostring(err)) end

 end

 local stats=sim.stats

 if not stats or not sim.ropes then status.Text="Waiting for timing data";return end

 local scale=math.max(0.02,tonumber(stats.timeScale) or 1)

 local ok,slow=pcall(sim.SlowScale,sim)

 if ok and type(slow)=="number" then scale=scale*math.max(0.02,slow) end

 local clearance=(tonumber(stats.ropeClearance) or .8)+.16

 local frameStep=observedDt>.020 and 1/30 or (observedDt>.010 and 1/60 or (observedDt>.005 and 1/120 or 1/240))

 local cache=tostring(stats.flightFuel).."/"..tostring(frameStep).."/"..tostring(stats.slamGravity).."/"..tostring(stats.airJumps).."/"..tostring(stats.flightClimb).."/"..string.format("%.4f/%.4f/%.4f/%.4f/%.4f/%.4f/%.4f",

  stats.jumpVelocity or 13,stats.gravity or 49.5,stats.holdGravityScale or .45,

  stats.maxHoldTime or .22,stats.hangTime or 0,stats.fastFall or 1,clearance)

 if cache~=profileKey then

  profileKey=cache;profiles=makeProfiles(stats,clearance,frameStep);committed=nil

 end

 local events={}

 local ropeCount=0

 for _,rope in pairs(sim.ropes) do

  if type(rope.angle)=="number" and type(rope.speed)=="number" then

   ropeCount=ropeCount+1

   local phase=rope.angle%TAU

   local speed=math.max(0,rope.speed+(sim.phaseCorrection or 0))*scale

   if speed>.001 then

    for cycle=0,5 do events[#events+1]=((TAU-phase)+cycle*TAU)/speed*scale end

   end

  end

 end

 table.sort(events)

 local horizon=math.clamp(ropeCount*3,12,36)

 while #events>horizon do table.remove(events) end

 local soonest=events[1] and events[1]/scale or math.huge

 gui:SetAttribute("Ropes",ropeCount);gui:SetAttribute("NextRope",soonest)

 -- Forecast remaining flight on isolated scalar state before landing.
 if not sim.grounded then

  wasAirborne=true

  if elapsed-forecastAt>=(sim.flying and .012 or .04) or forecastAt<0 then

   forecastAt=elapsed

   local function forecast(endTime,ignite)

   local b=dummyBody(stats)

   for _,field in ipairs({"height","velocity","grounded","holding","holdTime","hangLeft","hangGranted","bufferLeft","flying","fuelLeft","slamming","airTime","drift"}) do b[field]=sim[field] end

   b.bufferLeft=0

   if ignite then b.flying=true;b.hangLeft=0;b.holding=true end

   local t=0;local j=1;local safe=true

   local fired=false

   local projectedFlightEnd=nil

   for frame=1,math.ceil(4/frameStep) do

    if not b.flying then b.holding=down and b.holdTime<plannedHold end

    if plannedFlight and not fired and b.airTime>=plannedFlight.at then

     fired=true;projectedFlightEnd=t+plannedFlight.duration;b.flying=true;b.hangLeft=0

    end

    if b.flying and ((endTime and elapsed+t>=endTime) or

      (fired and t>=projectedFlightEnd-1e-8)) then b:StopFlight() end

    if plannedSlam and b.airTime>=plannedSlam and b.height>=1.2 then

     b.slamming=true;b.velocity=math.min(b.velocity,0);b.hangLeft=0

    end

    Body.StepBody(b,frameStep);t+=frameStep

    while events[j] and events[j]<=t do

     local y=math.max(0,b.height-b.velocity*(t-events[j]))

     if y<clearance then safe=false end

     j+=1

    end

    if b.grounded then break end

   end

   if safe and b.grounded then

    local remaining={}

    for n=j,#events do remaining[#remaining+1]=events[n]-t end

    local plan=#remaining>0 and choosePlan(remaining,profiles,clearance)

    if plan then

     return {at=elapsed+t+plan.start,hold=plan.hold,group=plan.group,

      slam=plan.slam,flight=plan.flight,duration=plan.duration,airForecast=true}

    end

   end

   return nil

   end

   committed=forecast(flightEnd)

   if not committed and sim.flying and flightEnd then

    for _,delta in ipairs({-.04,-.02,.02,.04,.08,.12}) do

     local candidateEnd=math.max(elapsed,math.min(flightEnd+delta,elapsed+(sim.fuelLeft or 0)))

     local candidate=forecast(candidateEnd)

     if candidate then

      flightEnd=candidateEnd;committed=candidate

      if flightEnd<=elapsed then release();flightEnd=nil end

      break

     end

    end

   end

   if not committed and not sim.flying and not plannedFlight and (stats.flightClimb or 0)>0

    and (sim.airJumpsLeft or 0)==0 and (sim.fuelLeft or 0)>.04 and sim.velocity>-4 and sim.height>clearance+.3 then

    for _,duration in ipairs({.04,.08,.12,.2,.3}) do

     local candidateEnd=elapsed+math.min(duration,sim.fuelLeft)

     local candidate=forecast(candidateEnd,true)

     if candidate then

      release();local ok=key(true)

      if ok and sim.flying then down=true;flightEnd=candidateEnd;committed=candidate end

      break

     end

    end

   end

   gui:SetAttribute("LandingPlan",committed~=nil)

  end

  status.Text=sim.flying and "Flying · Rocket Boots" or (committed and "Landing planned" or "Finding a landing window")

 elseif now>=nextAllowed then

  if down then release() end

  if wasAirborne then

   wasAirborne=false

   if committed and committed.at<elapsed-.04 then committed=nil end

  end

  if not committed or (committed.at-elapsed>.08 and now-lastPlanAt>.12) then

   lastPlanAt=now

   local plan=choosePlan(events,profiles,clearance)

   if plan then

    committed={at=elapsed+math.max(0,plan.start-offset*scale),hold=plan.hold,group=plan.group,

     slam=plan.slam,flight=plan.flight,duration=plan.duration}

    gui:SetAttribute("PlanPartial",plan.partial==true)

   elseif soonest<.25 then

    -- Explicitly best-effort when no sustainable path exists; never marked safe.
    local best,score=nil,-math.huge

    for _,p in ipairs(profiles) do

     local margin=math.huge

     for _,event in ipairs(events) do

      if event>p.land then break end

      margin=math.min(margin,heightAt(p,event)-clearance)

     end

     if margin>score then score=margin;best=p end

    end

    if best then

     committed={at=elapsed,hold=best.hold,group=0,slam=best.slam,flight=best.flight,duration=best.duration}

     warn("BADDIE_AJ7|NO_SAFE_PLAN|best_effort_jump|margin="..tostring(score))

    end

   else status.Text="Searching for a safe window" end

  end

  if committed and elapsed+math.min(observedDt*.35,.004)>=committed.at then

   local plan=committed;committed=nil

   local success,err=key(true)

   if not success then setActive(false);status.Text="Input unavailable";warn(tostring(err));return end

   plannedHold=plan.hold;plannedSlam=plan.slam

   plannedFlight=plan.flight and {at=plan.flight,duration=plan.duration} or nil

   down=true;activeJump=true;forecastAt=-1

   if sim.grounded then release();status.Text="Waiting for jump input";return end

   nextAllowed=now

   gui:SetAttribute("Jumps",(gui:GetAttribute("Jumps") or 0)+1)

   print(string.format("BADDIE_AJ7|jump|ropes=%d|group=%d|hold=%.3f|eta=%.3f|flight=%s|skips=%d",

    ropeCount,plan.group,plannedHold,soonest,tostring(plan.flight),sim.run.skips or 0))

  end

 end

 telemetry.Text=string.format("%d ropes | streak %d | failures %d",ropeCount,sim.run.combo or 0,failures)

 if now-lastLog>5 then

  lastLog=now

  print(string.format("BADDIE_AJ7|state|ropes=%d|skips=%d|perfects=%d|level=%d|alive=%s",

   ropeCount,sim.run.skips or 0,sim.run.perfects or 0,sim.run.level or 0,tostring(sim.run.alive)))

 end

end)

refresh()

print("BADDIE_AJ7|ready|ON")
