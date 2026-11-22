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
assert(WC.dashboard.w==600 and WC.dashboard.h==360,"dimensions")
assert(not WC.dashboard:IsShown(),"ferme au depart")
assert(WC.dashboardPage=="overview")
assert(WC.dashboardPages.overview:IsShown())
assert(WC.dashboardPages.overview.w==515 and WC.dashboardPages.overview.h==285,
  "overview fits inside compact window")
local sky, crest, gold, silver, copper=false,false,false,false,false
for _, t in ipairs(textures) do
  if t.path=="Interface\\AddOns\\WarriorCompanion\\Textures\\HordeSky" then sky=true end
  if t.path=="Interface\\AddOns\\WarriorCompanion\\Textures\\Warcrest" then crest=true end
  if t.path=="Interface\\MoneyFrame\\UI-GoldIcon" then gold=true end
  if t.path=="Interface\\MoneyFrame\\UI-SilverIcon" then silver=true end
  if t.path=="Interface\\MoneyFrame\\UI-CopperIcon" then copper=true end
end
assert(sky and crest,"assets Horde originaux")
assert(gold and silver and copper,"icones monnaie natives")
assert(#buttons>=9,"five navigation tabs, quest filters and close")
WC:ToggleDashboard()
assert(WC.dashboard:IsShown() and notices==1)
assert(WC.dashboardXP.text=="516")
assert(WC.dashboardSessionRate.text=="10961")
assert(WC.dashboardRecentRate.text=="10800")
assert(WC.dashboardQuests.text=="32")
assert(WC.dashboardMoney.sign.text=="-")
assert(WC.dashboardMoney.digits[1].text=="123")
assert(WC.dashboardMoney.digits[2].text=="45")
assert(WC.dashboardMoney.digits[3].text=="67")
assert(WC.dashboardCombat.text:find("28 s",1,true))
assert(WC.dashboardAdvice.text:find("talents",1,true))
assert(WC.dashboardActivity.text:find("+285 XP",1,true))
assert(WC.dashboardActivity.text:find("+231 XP",1,true))
WC.dashboardTabs.combat.handlers.OnClick()
assert(WC.dashboardPages.combat:IsShown() and not WC.dashboardPages.overview:IsShown())
assert(WC.dashboardCombatDetail.text:find("Interrompus",1,true))
WC.dashboardTabs.advice.handlers.OnClick()
assert(WC.dashboardAdviceDetail.text:find("talents",1,true))
WC.dashboardTabs.quests.handlers.OnClick()
assert(WC.dashboardPages.quests:IsShown())
assert(WC.dashboardQuestButtons.journal and WC.dashboardQuestButtons.discover
  and WC.dashboardQuestButtons.route and WC.dashboardQuestButtons.guide)
WC.dashboardQuestButtons.guide.handlers.OnClick()
assert(WC.dashboardQuestTitle.text:find("Guide",1,true))
assert(WC.dashboardGuidePrev and WC.dashboardGuideNext)
WC.dashboardTabs.activity.handlers.OnClick()
assert(WC.dashboardActivityDetail.text:find("+285 XP",1,true))
WC:ShowDashboardPage("invalid")
assert(WC.dashboardPage=="activity")
WC:ShowDashboardPage("overview")
WC.metrics.xpGained=999
WC.dashboard.handlers.OnUpdate(WC.dashboard,1)
assert(WC.dashboardXP.text=="516","3 secondes")
WC.dashboard.handlers.OnUpdate(WC.dashboard,2.2)
assert(WC.dashboardXP.text=="999")
assert(notices==1,"rafraichissement sans notification")

WC:ToggleDashboard()
WC.activity={}
WC.metrics.questCount=nil
WC.metrics.xpAvailable=false
WC.XPPerHour=function() return nil end
WC.RecentXPPerHour=function() return nil end
WC.MoneyDelta=function() return nil end
WC:ToggleDashboard()
assert(WC.dashboardSessionRate.text=="--")
assert(WC.dashboardRecentRate.text=="--")
assert(WC.dashboardMoney.sign.text=="")
assert(WC.dashboardMoney.digits[1].text=="--")
assert(WC.dashboardActivity.text:find("Aucune activite",1,true))
WC:CreateDashboard()
assert(WC.dashboard.w==600,"pas de duplication")
print("OK: art Horde, navigation, combat, argent, valeurs absentes, cadence et regression")
