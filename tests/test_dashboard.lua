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
    function t:SetTexCoord(...) self.texCoord={...} end
    function t:SetPoint() end
    function t:SetSize() end
    function t:SetWidth(w) self.width=w end
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
    function t:Show() self.shown=true end
    function t:Hide() self.shown=false end
    function t:IsShown() return self.shown~=false end
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
local settings={autoOpen=true,showAlerts=true}
function WC:Profile() return settings end
function WC:ResetSession() self.sessionReset=(self.sessionReset or 0)+1 end
function WC:EquipmentReviewText() return "Objet a examiner dans le sac." end
WC.health={current=75,maximum=100,percent=75}
WC.weapons={available=true,main=123,off=456,
  mainType="INVTYPE_WEAPON",offType="INVTYPE_WEAPON"}
WC.spellbook={known={a=true,b=true},learned={{name="Frappe",time=1}}}
function UnitLevel() return 33 end
assert(loadfile("Addon/WarriorCompanion/TalentPlan.lua"))("WarriorCompanion",WC)
function WC:SelectQuestPlan(mode)
  self.questPlanMode=mode
  self.dashboardQuestTitle:SetText("Guide de leveling")
  self.dashboardQuestDetail:SetText("Pas de parcours verifie")
  if self.RefreshTalentGuidePanel then self:RefreshTalentGuidePanel() end
end
assert(loadfile("Addon/WarriorCompanion/Dashboard.lua"))("WarriorCompanion",WC)
assert(loadfile("Addon/WarriorCompanion/GuideTracker.lua"))("WarriorCompanion",WC)
WC.activeGuide={title="33-34 Desolace",steps={
  {text="Go to Shadowprey Village"},
  {text="Talk to the innkeeper"},
  {text="Accept a quest"},
  {text="Kill 10 enemies"},
  {text="Return to the camp"},
  {text="Rest and repair"},
}}
WC.guideIndex=2
function WC:GuideStepText(step) return step.text end
function WC:GetGuideView() return {
  title="33-34 Desolace",actionText="Talk to the innkeeper",
  locationText="Desolace",nextText="Accept a quest"
} end

WC:CreateDashboard()
assert(WC.dashboard.w==720 and WC.dashboard.h==520,"grande fenetre lisible")
assert(not WC.dashboard:IsShown())
assert(WC.dashboardPage=="quests","guide par defaut")
assert(WC.dashboardPages.quests.w==626 and WC.dashboardPages.quests.h==380)
assert(WC.dashboardPages.combat and WC.dashboardPages.advice
  and WC.dashboardPages.settings)
assert(not WC.dashboardPages.overview and not WC.dashboardPages.activity,
  "bilan et journal retires de la grande fenetre")
assert(not WC.dashboardTabs.overview and not WC.dashboardTabs.activity)
local crest,oldDecoration=false,false
for _,t in ipairs(textures) do
  if t.path and t.path:find("Warcrest",1,true) then crest=true end
  if t.path and (t.path:find("HordeSky",1,true) or
      t.path:find("HeaderPlate",1,true)) then oldDecoration=true end
end
assert(crest and not oldDecoration,"en-tete sobre, blason conserve")
assert(#buttons>=8,"onglets et boutons du guide")
WC.dashboard:Show()
WC:RefreshDashboard()
assert(WC.dashboard:IsShown() and notices==0)
assert(WC.dashboardQuestButtons.guide and WC.dashboardQuestButtons.journal
  and WC.dashboardQuestButtons.discover and not WC.dashboardQuestButtons.route)
assert(WC.dashboardGuidePrev and WC.dashboardGuideNext)
assert(WC.dashboardQuestButtons.talents,"vue talents dans le guide")
assert(WC.dashboardQuestButtons.guide.base.color[1]~=nil)
local guideAccent=WC.dashboardQuestButtons.guide.accent.color
assert(guideAccent and guideAccent[1]>0.7,
  "bouton du guide actif en bronze")
WC.dashboardQuestButtons.talents.handlers.OnClick()
assert(WC.questPlanMode=="talents")
assert(WC.dashboardQuestButtons.talents.accent.color[1]>0.7,
  "talents actif en bronze")
assert(WC.dashboardQuestButtons.guide.accent.color[1]<0.5,
  "etapes inactive sur fond anthracite")
assert(WC.dashboardTalentHeader:IsShown() and
       not WC.dashboardQuestDetail:IsShown(),"vue talents distincte")
assert(WC.dashboardTalentCurrent.text:find("Niv. 33",1,true))
assert(#WC.dashboardTalentGrid==28,"arbre graphique de 7 lignes x 4 colonnes")
local enrage=WC.dashboardTalentGrid[12]
assert(enrage.name.text:find("Enrager",1,true) and
       enrage.rank.text:find("5/5",1,true),"talent actuel visible dans l'arbre")
WC.dashboardGuideNext.handlers.OnClick()
assert(WC.talentPlanSelection==34)
assert(WC.dashboardTalentCurrent.text:find("Niv. 34",1,true))
local swings=WC.dashboardTalentGrid[14]
assert(swings.name.text:find("Coups dechaines",1,true) and
       swings.rank.text:find("1/1",1,true),
       "mise a jour du talent visible en changeant de niveau")
WC.dashboardGuidePrev.handlers.OnClick()
assert(WC.talentPlanSelection==33)
WC.dashboardQuestButtons.guide.handlers.OnClick()
assert(not WC.dashboardTalentHeader:IsShown() and
  not WC.dashboardTalentGrid[12]:IsShown()
  and not WC.dashboardQuestDetail:IsShown()
  and WC.guideTracker:IsShown(),"retour aux cartes d'etapes sans superposition")
assert(WC.guideTracker.rows[1].title.text=="Talk to the innkeeper")
assert(WC.guideTracker.rows[2].title.text=="Accept a quest")
assert(WC.guideTracker.count.text=="2 / 6")
assert(WC.guideTracker.progressFill.width==182,
  "avancement du guide affiche")
WC.guideIndex=3
WC:RefreshGuideTracker()
assert(WC.guideTracker.rows[1].title.text=="Accept a quest")
assert(WC.guideTracker.rows[1].accent.color[1]==1,
  "carte courante distingable en or")
WC.dashboardTabs.combat.handlers.OnClick()
assert(WC.dashboardPage=="combat" and WC.dashboardPages.combat:IsShown())
assert(WC.dashboardCombatDetail.text:find("Combats",1,true))
assert(WC.dashboardCombatDetail.text:find("28 secondes",1,true))
WC.dashboardTabs.advice.handlers.OnClick()
assert(WC.dashboardAdviceDetail.text:find("talents",1,true))
WC.dashboardTabs.advice.handlers.OnClick()
WC.dashboardAdviceButtons.equipment.handlers.OnClick()
assert(WC.adviceMode=="equipment" and
  WC.dashboardAdviceDetail.text:find("Objet a examiner",1,true))
assert(WC.dashboardAdviceButtons.equipment.accent.color[1]>0.7,
  "sous-onglet selectionne bronze")
assert(WC.dashboardAdviceButtons.advice.accent.color[1]<0.5,
  "sous-onglet inactif discret")
WC.dashboardAdviceButtons.health.handlers.OnEnter()
assert(WC.dashboardAdviceButtons.health.base.color[1]>0.2,
  "survol sous-onglet")
WC.dashboardAdviceButtons.health.handlers.OnLeave()
assert(WC.dashboardAdviceButtons.health.base.color[1]<0.2,
  "fin du survol")
WC.dashboardAdviceButtons.health.handlers.OnClick()
assert(WC.dashboardAdviceDetail.text:find("75 %",1,true))
WC.dashboardAdviceButtons.weapons.handlers.OnClick()
assert(WC.dashboardAdviceDetail.text:find("MAIN GAUCHE",1,true))
WC.dashboardAdviceButtons.spells.handlers.OnClick()
assert(WC.dashboardAdviceDetail.text:find("2 sorts",1,true))
WC.dashboardAdviceButtons.advice.handlers.OnClick()
WC.dashboardTabs.combat.handlers.OnClick()
WC.dashboardCombatButtons.performance.handlers.OnClick()
assert(WC.combatMode=="performance" and
  WC.dashboardCombatDetail.text:find("XP/h session",1,true))
WC.dashboardCombatButtons.combat.handlers.OnClick()
WC.dashboardTabs.settings.handlers.OnClick()
assert(WC.dashboardSettingsInfo.text:find("ACTIF",1,true))
WC.dashboardSettingsButtons.autostart.handlers.OnClick()
assert(settings.autoOpen==false and
  WC.dashboardSettingsInfo.text:find("INACTIF",1,true))
assert(WC.dashboardSettingsButtons.autostart.accent.color[1]<0.5,
  "option inactive grisee")
WC.dashboardSettingsButtons.alerts.handlers.OnClick()
assert(settings.showAlerts==false and
  WC.dashboardSettingsInfo.text:find("DESACTIVEES",1,true))
WC.dashboardSettingsButtons.reset.handlers.OnClick()
assert(WC.sessionReset==nil and WC.settingsResetPending,
  "premier clic demande confirmation")
WC.dashboardSettingsButtons.reset.handlers.OnClick()
assert(WC.sessionReset==1 and not WC.settingsResetPending,
  "second clic reinitialise la session")
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
print("OK: interface ardoise a navigation horizontale, 4 onglets, etats actifs, survol, guide et conseils")
