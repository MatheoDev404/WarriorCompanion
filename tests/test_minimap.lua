-- Test minimap WoW : aspect standard, mouvement et options (Lua 5.1 / 5.4).
local textures={}
local function mkframe()
  local f={shown=false,scripts={}}
  function f:SetSize(w,h) self.w,self.h=w,h end
  function f:SetPoint(...) self.anchor={...} end
  function f:ClearAllPoints() self.anchor=nil end
  function f:RegisterForDrag(...) self.dragButtons={...} end
  function f:GetCenter() return 100,100 end
  function f:GetEffectiveScale() return 1 end
  function f:GetWidth() return self.minimapWidth end
  function f:SetFrameStrata(s) self.strata=s end
  function f:SetFrameLevel(v) self.level=v end
  function f:EnableMouse(v) self.mouse=v end
  function f:RegisterForClicks(...) self.clicks={...} end
  function f:SetHighlightTexture(v) self.highlight=v end
  function f:SetScript(n,fn) self.scripts[n]=fn end
  function f:CreateTexture()
    local t={}
    function t:SetTexture(v) self.path=v end
    function t:SetPoint(...) self.anchor={...} end
    function t:SetSize(w,h) self.w,self.h=w,h end
    function t:SetAllPoints() end
    function t:SetTexCoord(...) self.coords={...} end
    textures[#textures+1]=t
    return t
  end
  function f:Show() self.shown=true end
  function f:Hide() self.shown=false end
  function f:IsShown() return self.shown end
  return f
end
function CreateFrame(kind,name,parent)
  local f=mkframe()
  f.kind,f.name,f.parent=kind,name,parent
  return f
end
Minimap=mkframe()
Minimap.minimapWidth=140
local tip={shown=false}
function tip:SetOwner() end
function tip:SetText(t) self.text=t end
function tip:AddLine(t) self.line=t end
function tip:Show() self.shown=true end
function tip:Hide() self.shown=false end
GameTooltip=tip
local cx,cy=200,100
function GetCursorPosition() return cx,cy end
local shape="ROUND"
function GetMinimapShape() return shape end

local opts={autoOpen=true}
local WC={dashboard=mkframe()}
function WC:Profile() return opts end
function WC:Trace() end
function WC:RefreshDashboard() self.refreshes=(self.refreshes or 0)+1 end
function WC:Print() end
function WC:ToggleDashboard()
  if self.dashboard:IsShown() then self.dashboard:Hide() else self.dashboard:Show() end
end
assert(loadfile("Addon/WarriorCompanion/Minimap.lua"))("WarriorCompanion",WC)
local button=WC:CreateMinimapButton()
assert(button.parent==Minimap and button.w==31 and button.h==31)
assert(button.level==8 and button.strata=="MEDIUM")
assert(button.highlight=="Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
assert(button.dragButtons[1]=="LeftButton")
assert(button.anchor[1]=="CENTER" and button.anchor[2]==Minimap)
assert(math.abs(button.anchor[4]+66.11)<0.2 and math.abs(button.anchor[5]+30.85)<0.2,
  "default position 205 deg")
assert(#textures==3,"background icon border")
assert(textures[1].path=="Interface\\Minimap\\UI-Minimap-Background")
assert(textures[1].w==20 and textures[1].h==20)
assert(button.icon==textures[2] and button.icon.w==20 and button.icon.h==20)
assert(button.icon.path=="Interface\\Icons\\Ability_Warrior_BattleShout",
  "native warrior icon, not square external crest")
assert(button.icon.coords[1]==0.05 and button.icon.coords[2]==0.95)
assert(textures[3].path=="Interface\\Minimap\\MiniMap-TrackingBorder")
assert(textures[3].w==53 and textures[3].h==53)
assert(textures[3].anchor[4]==0 and textures[3].anchor[5]==0,"native border overlay aligned")
assert(WC:CreateMinimapButton()==button,"no duplicates")
button.scripts.OnMouseDown(button)
assert(button.icon.coords[1]==0)
button.scripts.OnMouseUp(button)
assert(button.icon.coords[1]==0.05)
button.scripts.OnClick(button,"LeftButton")
assert(WC.dashboard:IsShown())
button.scripts.OnClick(button,"RightButton")
assert(WC.dashboard:IsShown())
button.scripts.OnClick(button,"LeftButton")
assert(not WC.dashboard:IsShown())
button.scripts.OnEnter(button)
assert(tip.shown and tip.text=="Warrior Companion")
button.scripts.OnLeave(button)
assert(not tip.shown)

button.scripts.OnMouseDown(button)
button.scripts.OnDragStart(button)
assert(button.dragging and math.abs(opts.minimapAngle-0)<0.0001)
cx,cy=100,200
button.scripts.OnUpdate(button)
assert(math.abs(opts.minimapAngle-90)<0.0001)
assert(math.abs(button.anchor[4])<0.01 and math.abs(button.anchor[5]-73)<0.01)
cx,cy=0,100
button.scripts.OnDragStop(button)
assert(math.abs(opts.minimapAngle-180)<0.0001)
button.scripts.OnClick(button,"LeftButton")
assert(not WC.dashboard:IsShown(),"drag should not toggle")
button.scripts.OnMouseDown(button)
button.scripts.OnClick(button,"LeftButton")
assert(WC.dashboard:IsShown(),"next normal click works")
button.scripts.OnClick(button,"LeftButton")
assert(not WC.dashboard:IsShown())

-- Support pour les minimaps carrees : ne pas se baser sur le cercle.
shape="SQUARE"
WC:PositionMinimapButton(45)
assert(math.abs(button.anchor[4]-66.59)<0.2)
assert(math.abs(button.anchor[5]-66.59)<0.2)
WC:PositionMinimapButton(0)
assert(button.anchor[4]==73 and math.abs(button.anchor[5])<0.001)
shape="INVALID"
WC:PositionMinimapButton(90)
assert(math.abs(button.anchor[5]-73)<0.001,"unknown shape fallback")
WC:PositionMinimapButton(0/0)
assert(opts.minimapAngle==205,"invalid saved angle")
WC.minimapButton=nil
button=WC:CreateMinimapButton()
assert(opts.minimapAngle==205 and button.anchor[4]<0,"persisted angle")

WC:AutoOpenDashboard()
assert(WC.dashboard:IsShown() and WC.refreshes==1)
WC.dashboard:Hide()
WC:AutoOpenDashboard()
assert(not WC.dashboard:IsShown(),"no reopen on zone")
WC.didAutoOpen=nil
opts.autoOpen=false
WC:AutoOpenDashboard()
assert(not WC.dashboard:IsShown())
local WC2={dashboard=mkframe()}
function WC2:Profile() return {autoOpen=true} end
function WC2:Trace() end
assert(loadfile("Addon/WarriorCompanion/Minimap.lua"))("WarriorCompanion",WC2)
Minimap=nil
assert(WC2:CreateMinimapButton()==nil)
Minimap=mkframe()
assert(WC2:CreateMinimapButton()~=nil)
print("OK: circular button artwork, border, orbit, square minimap, click, drag, autostart")
