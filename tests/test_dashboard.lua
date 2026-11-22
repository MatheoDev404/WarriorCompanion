-- Verification autonome de la nouvelle interface et de ses donnees (Lua 5.1 / 5.4).
local messages = {}
local createdTextures, createdLabels = {}, {}
local function frame()
  local f = { shown = false, handlers = {} }
  function f:SetSize(w,h) self.w,self.h=w,h end
  function f:SetPoint() end
  function f:SetFrameStrata() end
  function f:EnableMouse() end
  function f:SetMovable() end
  function f:RegisterForDrag() end
  function f:SetScript(name,func) self.handlers[name]=func end
  function f:Show() self.shown=true end
  function f:Hide() self.shown=false end
  function f:IsShown() return self.shown end
  function f:StartMoving() end
  function f:StopMovingOrSizing() end
  function f:CreateTexture()
    local t = { }
    function t:SetTexture(path) self.path=path end
    function t:SetAllPoints() end
    function t:SetPoint() end
    function t:SetSize() end
    function t:SetVertexColor() end
    createdTextures[#createdTextures+1]=t
    return t
  end
  function f:CreateFontString()
    local t = { }
    function t:SetPoint() end
    function t:SetWidth() end
    function t:SetHeight() end
    function t:SetJustifyH() end
    function t:SetJustifyV() end
    function t:SetText(value) self.text=value end
    createdLabels[#createdLabels+1]=t
    return t
  end
  return f
end
function CreateFrame() return frame() end
UIParent={}
local adviceCalls=0
local WC = { version="0.4.0-rc1", metrics={xpGained=1000,deaths=1,questCount=4,xpAvailable=true},
  alerts={}, activity={{description="Gain d'XP"},{description="Equipement modifie"}} }
function WC:XPPerHour() return 3200 end
function WC:RecentXPPerHour() return 4800 end
function WC:MoneyDelta() return -45 end
function WC:GetCombatSummary() return { completed=4, interrupted=1, average=13, active=false } end
function WC:AdviceLines() return "Aucune XP mesuree sur la session" end
function WC:UpdateAdvice() adviceCalls=adviceCalls+1 end
function WC:Print(text) messages[#messages+1]=text end
assert(loadfile("Addon/WarriorCompanion/Dashboard.lua"))("WarriorCompanion", WC)
WC:CreateDashboard()
assert(WC.dashboard.w == 428 and WC.dashboard.h == 475, "dimensions")
assert(not WC.dashboard:IsShown(), "fermee au depart")
assert(#createdTextures >= 12, "sections graphiques")
local emblem=false
for _,t in ipairs(createdTextures) do
  if t.path=="Interface\\Icons\\Ability_Warrior_BattleShout" then emblem=true end
end
assert(emblem, "icone de guerrier")
WC:ToggleDashboard()
assert(WC.dashboard:IsShown() and adviceCalls == 1)
assert(WC.dashboardStats.text:find("XP/H 10 MIN",1,true))
assert(WC.dashboardStats.text:find("4800",1,true))
assert(WC.dashboardStats.text:find("-45 cuivre",1,true))
assert(WC.dashboardCombat.text:find("INTERROMPUS",1,true))
assert(WC.dashboardAdvice.text:find("Aucune XP",1,true))
assert(WC.dashboardActivity.text:find("Equipement modifie",1,true))
assert(WC.dashboardActivity.text:find("Gain d'XP",1,true))
local first=WC.dashboardStats.text
WC.metrics.xpGained=1100
WC.dashboard.handlers.OnUpdate(WC.dashboard, 1)
assert(WC.dashboardStats.text == first, "refresh cadence")
WC.dashboard.handlers.OnUpdate(WC.dashboard, 2.2)
assert(WC.dashboardStats.text ~= first, "stats evolutives")
assert(adviceCalls==1, "aucune alerte lors du refresh visuel")
WC:ToggleDashboard()
assert(not WC.dashboard:IsShown())
WC.metrics.questCount=nil
WC.metrics.xpAvailable=false
WC.activity={}
WC.XPPerHour=function() return nil end
WC.RecentXPPerHour=function() return nil end
WC.MoneyDelta=function() return nil end
WC:ToggleDashboard()
assert(WC.dashboardStats.text:find("indisponible",1,true))
assert(WC.dashboardStats.text:find("calcul...",1,true))
assert(WC.dashboardActivity.text:find("Aucune activite",1,true))
WC:CreateDashboard()
assert(WC.dashboard.w==428,"pas de duplication")
print("OK: layout Horde, icone, sections, metriques, actualisation, valeurs absentes et toggles")
