-- Minimap launcher + automatic opening (Lua 5.1 and 5.4).
local function mkframe()
  local f={shown=false,scripts={}}
  function f:SetSize(w,h) self.w,self.h=w,h end
  function f:SetPoint(...) self.anchor={...} end
  function f:SetFrameStrata(s) self.strata=s end
  function f:EnableMouse(x) self.mouse=x end
  function f:RegisterForClicks(...) self.clicks={...} end
  function f:SetScript(name,fn) self.scripts[name]=fn end
  function f:CreateTexture()
    local t={}
    function t:SetTexture(x) self.path=x end
    function t:SetPoint() end
    function t:SetSize() end
    function t:SetAllPoints() end
    function t:SetVertexColor() end
    return t
  end
  function f:Show() self.shown=true end
  function f:Hide() self.shown=false end
  function f:IsShown() return self.shown end
  return f
end
function CreateFrame(kind, name, parent)
  local f=mkframe()
  f.kind,f.name,f.parent=kind,name,parent
  return f
end
Minimap=mkframe()
local tooltip={shown=false}
function tooltip:SetOwner() end
function tooltip:SetText(value) self.text=value end
function tooltip:AddLine(value) self.line=value end
function tooltip:Show() self.shown=true end
function tooltip:Hide() self.shown=false end
GameTooltip=tooltip

local opts={autoOpen=true}
local wc={dashboard=mkframe(),traceCalls=0}
function wc:Profile() return opts end
function wc:Trace() self.traceCalls=self.traceCalls+1 end
function wc:RefreshDashboard() self.refreshes=(self.refreshes or 0)+1 end
function wc:ToggleDashboard()
  if self.dashboard:IsShown() then self.dashboard:Hide()
  else self.dashboard:Show() end
end
assert(loadfile("Addon/WarriorCompanion/Minimap.lua"))("WarriorCompanion",wc)
local button=wc:CreateMinimapButton()
assert(button and button.parent==Minimap and button.w==33 and button.h==33)
assert(button.name=="WarriorCompanionMinimapButton")
assert(button.anchor[1]=="TOPRIGHT" and button.anchor[2]==Minimap,"anchor at minimap edge")
assert(button.clicks[1]=="LeftButtonUp")
assert(wc:CreateMinimapButton()==button,"no duplicate")
button.scripts.OnClick(button,"LeftButton")
assert(wc.dashboard:IsShown(),"minimap click opens")
button.scripts.OnClick(button,"RightButton")
assert(wc.dashboard:IsShown(),"right click ignored")
button.scripts.OnClick(button,"LeftButton")
assert(not wc.dashboard:IsShown(),"minimap click closes")
button.scripts.OnEnter(button)
assert(tooltip.shown and tooltip.text=="Warrior Companion")
button.scripts.OnLeave(button)
assert(not tooltip.shown)
wc:AutoOpenDashboard()
assert(wc.dashboard:IsShown() and wc.refreshes==1,"automatic opening")
wc.dashboard:Hide()
wc:AutoOpenDashboard()
assert(not wc.dashboard:IsShown(),"do not reopen after closing/zone")
wc.didAutoOpen=nil
opts.autoOpen=false
wc:AutoOpenDashboard()
assert(not wc.dashboard:IsShown(),"persisted autoOpen off")
wc.didAutoOpen=nil
opts.autoOpen=true
wc.dashboard:Show()
wc:AutoOpenDashboard()
assert(wc.refreshes==1,"no double refresh if already visible")

local wc2={dashboard=mkframe()}
function wc2:Profile() return {autoOpen=true} end
function wc2:Trace() end
assert(loadfile("Addon/WarriorCompanion/Minimap.lua"))("WarriorCompanion",wc2)
Minimap=nil
assert(wc2:CreateMinimapButton()==nil,"minimap absence guarded")
Minimap=mkframe()
assert(wc2:CreateMinimapButton()~=nil,"retry once loaded")
print("OK: minimap toggle, tooltip, no duplicates, auto start and deferred minimap")
