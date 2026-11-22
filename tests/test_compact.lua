-- HUD compact autonome et navigation vers l'interface complete.
local frames={}
local function frame()
  local f={visible=true,scripts={}}
  function f:SetSize(w,h) self.w,self.h=w,h end
  function f:SetPoint(...) self.point={...} end
  function f:SetFrameStrata() end
  function f:EnableMouse() end
  function f:SetMovable() end
  function f:RegisterForDrag() end
  function f:StartMoving() end
  function f:StopMovingOrSizing() end
  function f:SetScript(k,fn) self.scripts[k]=fn end
  function f:IsShown() return self.visible end
  function f:Show() self.visible=true end
  function f:Hide() self.visible=false end
  function f:GetCenter() return 530,330 end
  function f:CreateTexture()
    local t=frame()
    function t:SetTexture() end
    function t:SetVertexColor() end
    return t
  end
  function f:CreateFontString()
    local t=frame()
    function t:SetText(s) self.text=s end
    function t:SetWidth() end
    function t:SetHeight() end
    function t:SetJustifyH() end
    function t:SetJustifyV() end
    return t
  end
  return f
end
function CreateFrame()
  local f=frame();frames[#frames+1]=f;return f
end
UIParent={GetCenter=function()return 500,500 end}
local options={autoOpen=true}
local WC={metrics={xpGained=120,deaths=2,questCount=19,xpAvailable=true}}
function WC:Profile() return options end
function WC:XPPerHour() return 3456 end
function WC:MoneyDelta() return -12345 end
function WC:AdviceLines() return "Attention : deux points de talent inutilises." end
function WC:RefreshDashboard() self.fullRefresh=(self.fullRefresh or 0)+1 end
WC.dashboard=frame();WC.dashboard:Hide()
assert(loadfile("Addon/WarriorCompanion/CompactDashboard.lua"))("WarriorCompanion",WC)
WC:CreateCompactDashboard()
assert(WC.compactDashboard.w==304 and WC.compactDashboard.h==88,"HUD vraiment compact")
assert(not WC.compactDashboard:IsShown(),"pas de double apparition")
WC:AutoOpenDashboard()
assert(WC.compactDashboard:IsShown() and not WC.dashboard:IsShown())
assert(WC.compactStats[1].text=="120" and WC.compactStats[2].text=="3456")
assert(WC.compactStats[3].text=="2" and WC.compactStats[4].text=="-1.23")
WC.MoneyDelta=function() return 25678 end
WC:RefreshCompactDashboard()
assert(WC.compactStats[4].text=="+2.57","solde positif")
WC.MoneyDelta=function() return 0 end
WC:RefreshCompactDashboard()
assert(WC.compactStats[4].text=="+0.00","solde nul")
WC.MoneyDelta=function() return nil end
WC:RefreshCompactDashboard()
assert(WC.compactStats[4].text=="--","montant indisponible")
assert(WC.compactAdvice.text:find("talent",1,true))
WC.compactExpand.scripts.OnClick()
assert(WC.dashboard:IsShown() and not WC.compactDashboard:IsShown())
assert(options.displayMode=="full")
WC:ToggleDashboard()
assert(WC.compactDashboard:IsShown() and not WC.dashboard:IsShown())
assert(options.displayMode=="compact")
WC.compactDashboard.scripts.OnDragStop(WC.compactDashboard)
assert(options.compactPoint.x==30 and options.compactPoint.y==-170)
WC.metrics.xpGained=250
WC.compactDashboard.scripts.OnUpdate(WC.compactDashboard,1)
assert(WC.compactStats[1].text=="120")
WC.compactDashboard.scripts.OnUpdate(WC.compactDashboard,2.1)
assert(WC.compactStats[1].text=="250")
WC:CreateCompactDashboard()
assert(WC.compactDashboard.w==304)
-- Reconnexion avec l'option de fenetre et sa position memorisees.
local old=WC.compactDashboard
WC.compactDashboard=nil
WC:CreateCompactDashboard()
assert(WC.compactDashboard~=old and WC.compactDashboard.point[4]==30)
options.displayMode="full"
WC.didAutoOpen=nil
WC:AutoOpenDashboard()
assert(WC.dashboard:IsShown() and not WC.compactDashboard:IsShown())
print("OK: mini HUD 304x88, indicateurs, ouverture, repli, position, reprise et actualisation")
