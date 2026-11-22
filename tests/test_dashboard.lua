-- Tests HUD et art WoW (Lua 5.1 / 5.4).
local textures, buttons = {}, {}
local function frame()
  local f={shown=true,handlers={}}
  function f:SetSize(w,h) self.w,self.h=w,h end
  function f:SetPoint() end
  function f:SetFrameStrata() end
  function f:EnableMouse() end
  function f:SetMovable() end
  function f:RegisterForDrag() end
  function f:StartMoving() end
  function f:StopMovingOrSizing() end
  function f:SetScript(name, fn) self.handlers[name]=fn end
  function f:Show() self.shown=true end
  function f:Hide() self.shown=false end
  function f:IsShown() return self.shown end
  function f:CreateTexture()
    local t={}
    function t:SetTexture(path) self.path=path end
    function t:SetPoint() end
    function t:SetSize() end
    function t:SetAllPoints() end
    function t:SetVertexColor(...) self.color={...} end
    textures[#textures+1]=t
    return t
  end
  function f:CreateFontString()
    local t={}
    function t:SetPoint() end
    function t:SetWidth() end
    function t:SetHeight() end
    function t:SetJustifyH() end
    function t:SetJustifyV() end
    function t:SetText(value) self.text=value end
    return t
  end
  return f
end
function CreateFrame(kind)
  local f=frame()
  if kind=="Button" then buttons[#buttons+1]=f end
  return f
end
UIParent={}
local notices=0
local WC = { metrics={xpGained=516, deaths=0, questCount=32, xpAvailable=true},
  activity={{description="+285 XP"},{description="+231 XP"}} }
function WC:XPPerHour() return 10961 end
function WC:RecentXPPerHour() return 10800 end
function WC:MoneyDelta() return -1234567 end
function WC:GetCombatSummary()
  return {completed=1,interrupted=0,average=28,deathsInCombat=0,active=false}
end
function WC:AdviceLines() return "Verifier les talents du guerrier." end
function WC:UpdateAdvice() notices=notices+1 end
function WC:Print() end
function WC:SelectQuestPlan(mode)
  self.questPlanMode=mode
  self.dashboardQuestTitle:SetText("Guide de leveling")
  self.dashboardQuestDetail:SetText("Pas de parcours verifie")
end
assert(loadfile("Addon/WarriorCompanion/Dashboard.lua"))("WarriorCompanion",WC)

local sign, g, s, c=WC:MoneyParts(-10005)
assert(sign=="-" and g==1 and s==0 and c==5, "monnaie negative")
sign,g,s,c=WC:MoneyParts(1234567)
assert(sign=="+" and g==123 and s==45 and c==67, "monnaie positive")
sign,g,s,c=WC:MoneyParts(0)
assert(sign=="" and g==0 and s==0 and c==0, "zero")
assert(WC:MoneyParts(nil)==nil and WC:MoneyParts(0/0)==nil)

WC:CreateDashboard()
assert(WC.dashboard.w==720 and WC.dashboard.h==460,"grande fenetre lisible")
assert(not WC.dashboard:IsShown())
assert(WC.dashboardPage=="quests","guide par defaut")
assert(WC.dashboardPages.quests.w==626 and WC.dashboardPages.quests.h==380)
assert(WC.dashboardPages.combat and WC.dashboardPages.advice)
assert(not WC.dashboardPages.overview and not WC.dashboardPages.activity,
  "bilan et journal retires de la grande fenetre")
assert(not WC.dashboardTabs.overview and not WC.dashboardTabs.activity)
local sky,crest,header=false,false,false
for _,t in ipairs(textures) do
  if t.path and t.path:find("HordeSky",1,true) then sky=true end
  if t.path and t.path:find("Warcrest",1,true) then crest=true end
  if t.path and t.path:find("HeaderPlate",1,true) then header=true end
end
assert(sky and crest and header,"theme visuel Horde conserve")
assert(#buttons>=8,"3 onglets et boutons du guide")
WC.dashboard:Show()
WC:RefreshDashboard()
assert(WC.dashboard:IsShown() and notices==0)
assert(WC.dashboardQuestButtons.guide and WC.dashboardQuestButtons.journal
  and WC.dashboardQuestButtons.discover and not WC.dashboardQuestButtons.route)
assert(WC.dashboardGuidePrev and WC.dashboardGuideNext)
WC.dashboardTabs.combat.handlers.OnClick()
assert(WC.dashboardPage=="combat" and WC.dashboardPages.combat:IsShown())
assert(WC.dashboardCombatDetail.text:find("Combats",1,true))
assert(WC.dashboardCombatDetail.text:find("28 secondes",1,true))
WC.dashboardTabs.advice.handlers.OnClick()
assert(WC.dashboardAdviceDetail.text:find("talents",1,true))
WC.dashboardTabs.quests.handlers.OnClick()
assert(WC.dashboardPage=="quests" and WC.dashboardPages.quests:IsShown())
WC.dashboardQuestButtons.guide.handlers.OnClick()
assert(WC.dashboardQuestTitle.text:find("Guide",1,true))
WC:ShowDashboardPage("overview")
assert(WC.dashboardPage=="quests","ancien onglet inaccessible")
WC:ShowDashboardPage("activity")
assert(WC.dashboardPage=="quests","journal masque")
WC.dashboard.handlers.OnUpdate(WC.dashboard,3.1)
assert(notices==0,"rafraichissement sans conseil notifie")
WC:CreateDashboard()
assert(WC.dashboard.w==720,"pas de duplication")
print("OK: interface 720x460, trois onglets, guide par defaut, combat, conseils")
