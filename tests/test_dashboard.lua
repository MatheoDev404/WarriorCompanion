-- Tests du HUD compact WoW et de l'argent en or/argent/cuivre (Lua 5.1 / 5.4).
local messages, textures, labels = {}, {}, {}
local function frame()
  local f = {shown=false, handlers={}}
  function f:SetSize(w,h) self.w,self.h=w,h end
  function f:SetPoint() end
  function f:SetFrameStrata() end
  function f:EnableMouse() end
  function f:SetMovable() end
  function f:RegisterForDrag() end
  function f:SetScript(k,fn) self.handlers[k]=fn end
  function f:Show() self.shown=true end
  function f:Hide() self.shown=false end
  function f:IsShown() return self.shown end
  function f:StartMoving() end
  function f:StopMovingOrSizing() end
  function f:CreateTexture()
    local t={}
    function t:SetTexture(s) self.path=s end
    function t:SetAllPoints() end
    function t:SetPoint() end
    function t:SetSize() end
    function t:SetVertexColor(r,g,b,a) self.color={r,g,b,a} end
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
    function t:SetText(v) self.text=v end
    labels[#labels+1]=t
    return t
  end
  return f
end
function CreateFrame() return frame() end
UIParent={}
local count=0
local WC={metrics={xpGained=516,deaths=0,questCount=32,xpAvailable=true},
  activity={{description="+285 XP"},{description="+231 XP"}}}
function WC:XPPerHour() return 10961 end
function WC:RecentXPPerHour() return 10961 end
function WC:MoneyDelta() return -1234567 end
function WC:GetCombatSummary()
  return {completed=1,interrupted=0,average=28,deathsInCombat=0,active=false}
end
function WC:AdviceLines() return "Aucun conseil verifie pour le moment." end
function WC:UpdateAdvice() count=count+1 end
function WC:Print(msg) messages[#messages+1]=msg end
assert(loadfile("Addon/WarriorCompanion/Dashboard.lua"))("WarriorCompanion",WC)

local sign,g,s,c=WC:MoneyParts(1234567)
assert(sign=="+" and g==123 and s==45 and c==67, "conversion g/s/c")
sign,g,s,c=WC:MoneyParts(-10005)
assert(sign=="-" and g==1 and s==0 and c==5, "perte g/s/c")
sign,g,s,c=WC:MoneyParts(0)
assert(sign=="" and g==0 and s==0 and c==0, "zero monnaie")
assert(WC:MoneyParts(nil)==nil and WC:MoneyParts(0/0)==nil, "monnaie indisponible")

WC:CreateDashboard()
assert(WC.dashboard.w==560 and WC.dashboard.h==438,"dimensions HUD compact")
assert(not WC.dashboard:IsShown(),"fenetre masquee au depart")
assert(WC.dashboardPage=="overview","page initiale")
assert(WC.dashboardPages.overview:IsShown(),"resume actif")
assert(not WC.dashboardPages.combat:IsShown(),"page secondaire masquee")
local gold,silver,copper=false,false,false
for _,t in ipairs(textures) do
  if t.path=="Interface\\MoneyFrame\\UI-GoldIcon" then gold=true end
  if t.path=="Interface\\MoneyFrame\\UI-SilverIcon" then silver=true end
  if t.path=="Interface\\MoneyFrame\\UI-CopperIcon" then copper=true end
end
assert(gold and silver and copper,"trois icones de monnaie natives")

WC:ToggleDashboard()
assert(WC.dashboard:IsShown() and count==1)
assert(WC.dashboardXP.text=="516")
assert(WC.dashboardSessionRate.text=="10961")
assert(WC.dashboardRecentRate.text=="10961")
assert(WC.dashboardMoney.sign.text=="-")
assert(WC.dashboardMoney.digits[1].text=="123")
assert(WC.dashboardMoney.digits[2].text=="45")
assert(WC.dashboardMoney.digits[3].text=="67")
assert(WC.dashboardCombat.text:find("28 s",1,true))
assert(WC.dashboardAdvice.text:find("Aucun conseil",1,true))
assert(WC.dashboardActivity.text:find("+231 XP",1,true))
WC:ShowDashboardPage("combat")
assert(WC.dashboardPages.combat:IsShown() and not WC.dashboardPages.overview:IsShown())
assert(WC.dashboardCombatDetail.text:find("Interrompus",1,true))
WC:ShowDashboardPage("advice")
assert(WC.dashboardAdviceDetail.text:find("Aucun conseil",1,true))
WC:ShowDashboardPage("activity")
assert(WC.dashboardActivityDetail.text:find("+285 XP",1,true))
WC:ShowDashboardPage("invalid")
assert(WC.dashboardPage=="activity", "page inconnue ignoree")
WC:ShowDashboardPage("overview")

local old=WC.dashboardXP.text
WC.metrics.xpGained=999
WC.dashboard.handlers.OnUpdate(WC.dashboard,1)
assert(WC.dashboardXP.text==old,"cadence 3 secondes")
WC.dashboard.handlers.OnUpdate(WC.dashboard,2.2)
assert(WC.dashboardXP.text=="999","rafraichissement visible")
assert(count==1,"ne pas declencher alertes sur mise a jour visuelle")
WC:ToggleDashboard()
assert(not WC.dashboard:IsShown())

WC.metrics.xpAvailable=false
WC.activity={}
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
assert(WC.dashboard.w==560,"pas de duplication")

print("OK: HUD moderne, navigation, g/s/c, monnaie negative, stats, cadence et erreurs de lecture")
