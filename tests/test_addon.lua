-- Simulation d'une petite surface de l'API WoW. Exécutée par Lua 5.1 et 5.4.
local now, level, xp, xpMax, money, talents = 100, 13, 200, 1000, 1000, 0
local messages = {}
DEFAULT_CHAT_FRAME = { AddMessage = function(_, msg) messages[#messages + 1] = msg end }
UIParent = {}
SlashCmdList = {}
function GetTime() return now end
function UnitLevel() return level end
function UnitXP() return xp end
function UnitXPMax() return xpMax end
function GetMoney() return money end
local locked = true
function InCombatLockdown() return locked end
-- Marqueur ordinaire pour simuler une lecture restreinte, sans émuler le moteur.
local restricted = 987654
function issecretvalue(value) return value == restricted end
C_QuestLog = { GetNumQuestLogEntries = function() return 9, 4 end }
C_ClassTalents = { HasUnspentTalentPoints = function() return talents > 0, talents, 0 end }

local function frame()
  local f = { visible = false, scripts = {} }
  for _, n in ipairs({"SetSize","SetPoint","SetFrameStrata","EnableMouse","SetMovable","RegisterForDrag","SetAllPoints","SetTexture","SetVertexColor","SetWidth","SetHeight","SetJustifyH","SetJustifyV"}) do f[n] = function() end end
  function f:SetText(value) self.text = value end
  function f:RegisterEvent(name) self.registered = self.registered or {}; self.registered[name] = true end
  function f:SetScript(name, fn) self.scripts[name] = fn end
  function f:CreateTexture() return frame() end
  function f:CreateFontString() return frame() end
  function f:Show() self.visible = true end
  function f:Hide() self.visible = false end
  function f:IsShown() return self.visible end
  function f:StartMoving() end
  function f:StopMovingOrSizing() end
  return f
end
function CreateFrame() return frame() end

local WC = {}
local dir = "Addon/WarriorCompanion/"
for line in io.lines(dir .. "WarriorCompanion.toc") do
  local name = line:match("^%s*([^#%s]+%.lua)%s*$")
  if name then assert(loadfile(dir .. name))("WarriorCompanion", WC) end
end
local function event(name, ...)
  assert(WC.eventFrame.registered[name], "Evenement non enregistre : " .. name)
  WC.eventFrame.scripts.OnEvent(WC.eventFrame, name, ...)
end
WC_DB = { options = "invalide", other = "conserver" }
event("PLAYER_DEAD")
assert(WC.metrics.deaths == 0)
talents = 1
event("PLAYER_LOGIN")
assert(WC.compactDashboard:IsShown() and not WC.dashboard:IsShown(),"mini-bilan ouvert a la connexion")
assert(not WC.minimapButton,"aucun bouton minimap")
SlashCmdList.WARRIORCOMPANION("")
assert(WC.dashboard:IsShown() and not WC.compactDashboard:IsShown(),"agrandissement du mini-bilan")
SlashCmdList.WARRIORCOMPANION("")
assert(WC.compactDashboard:IsShown() and not WC.dashboard:IsShown(),"retour mini-bilan")
assert(WC_DB.other == "conserver")
assert(WC:Profile().debug == false and WC:Profile().showAlerts == true)
assert(WC.inCombat and #messages == 0, "rechargement en combat")
talents, locked = 0, false
event("PLAYER_REGEN_ENABLED")
assert(WC.metrics.questCount == 4, "les en-tetes ne sont pas des quetes")
local questAPI = C_QuestLog
C_QuestLog = nil
event("QUEST_LOG_UPDATE")
assert(WC.metrics.questCount == nil)
C_QuestLog = { GetNumQuestLogEntries = function() return 3, 0 end }
event("QUEST_LOG_UPDATE")
assert(WC.metrics.questCount == 0)
C_QuestLog.GetNumQuestLogEntries = function() error("lecture impossible") end
event("QUEST_LOG_UPDATE")
assert(WC.metrics.questCount == nil)
C_QuestLog.GetNumQuestLogEntries = function() return 4, restricted end
event("QUEST_LOG_UPDATE")
assert(WC.metrics.questCount == nil)
C_QuestLog = questAPI
local talentAPI = C_ClassTalents
for _, read in ipairs({
  function() return false, 1, 1 end,
  function() return true, restricted, 0 end,
  function() error("lecture impossible") end,
  function() return true, 1, nil end,
}) do
  C_ClassTalents = { HasUnspentTalentPoints = read }
  event("PLAYER_TALENT_UPDATE")
  assert(#WC.alerts == 0 and #messages == 0)
end
C_ClassTalents = nil
event("PLAYER_TALENT_UPDATE")
assert(#WC.alerts == 0)
SlashCmdList.WARRIORCOMPANION("status")
assert(table.concat(messages, "\n"):find("Talents: API absente", 1, true))
assert(table.concat(messages, "\n"):find("Quetes: API presente", 1, true))
C_ClassTalents = talentAPI
assert(WC.ready and WC.metrics.started == 100)
assert(WC.metrics.lastXP == 200)
event("PLAYER_XP_UPDATE")
assert(WC.metrics.xpGained == 0)
xp = 350; event("PLAYER_XP_UPDATE")
assert(WC.metrics.xpGained == 150)
event("PLAYER_XP_UPDATE")
assert(WC.metrics.xpGained == 150, "XP duplicate")
now = now + 360
assert(WC:XPPerHour() == 1500)
level, xp, xpMax = 14, 60, 1200
event("PLAYER_LEVEL_UP",14)
assert(WC.metrics.xpGained == 860, "level transition XP")
event("PLAYER_XP_UPDATE")
assert(WC.metrics.xpGained == 860, "double counting level")
event("PLAYER_DEAD")
assert(WC.metrics.deaths == 1)
money = 1250; event("PLAYER_MONEY")
assert(WC:MoneyDelta() == 250)
C_ClassTalents.HasUnspentTalentPoints = function() return true, 2, 1 end
event("CHARACTER_POINTS_CHANGED")
assert(#WC.alerts == 1 and WC.alerts[1].id == "talents")
assert(WC.alerts[1].message:match("^3 point"))
local before = #messages
event("QUEST_LOG_UPDATE")
assert(#messages == before, "should throttle repeat notifications")
event("PLAYER_REGEN_DISABLED")
assert(WC.inCombat)
now = now + 400
before = #messages
event("PLAYER_TALENT_UPDATE")
assert(#messages == before, "combat notification")
event("PLAYER_REGEN_ENABLED")
assert(not WC.inCombat and #messages == before + 1)
SlashCmdList.WARRIORCOMPANION("debug on")
WC:Trace("test", "ok")
SlashCmdList.WARRIORCOMPANION("logs")
SlashCmdList.WARRIORCOMPANION("debug off")
assert(not WC:Profile().debug)
SlashCmdList.WARRIORCOMPANION("")
assert(WC.dashboard:IsShown())
SlashCmdList.WARRIORCOMPANION("")
assert(not WC.dashboard:IsShown() and WC.compactDashboard:IsShown())
SlashCmdList.WARRIORCOMPANION("reset")
assert(WC.metrics.xpGained == 0 and WC.metrics.deaths == 0)
assert(WC:XPPerHour() == nil)
-- XP et niveau peuvent être rafraîchis dans des ordres différents.
local function baseline()
  level, xp, xpMax = 20, 900, 1000
  SlashCmdList.WARRIORCOMPANION("reset")
end
baseline()
xp, xpMax = 50, 1200
event("PLAYER_XP_UPDATE", "player")
event("PLAYER_LEVEL_UP", 21)
level = 21
event("PLAYER_XP_UPDATE", "player")
event("PLAYER_ENTERING_WORLD")
assert(WC.metrics.xpGained == 150, "XP remise à zéro avant UnitLevel")

baseline()
event("PLAYER_LEVEL_UP", 21)
xp = 950
event("PLAYER_XP_UPDATE", "player")
assert(WC.metrics.xpGained == 0, "annonce du niveau avant les lectures")
level, xp, xpMax = 21, 25, 1200
event("PLAYER_XP_UPDATE", "player")
assert(WC.metrics.xpGained == 125)

baseline()
level = 21
event("PLAYER_LEVEL_UP", 21)
assert(WC.metrics.xpGained == 0, "niveau visible avec l'ancienne barre XP")
xp = 100
event("PLAYER_XP_UPDATE", "player")
assert(WC.metrics.xpGained == 0, "seuil encore ancien")
xpMax = 1200
event("PLAYER_XP_UPDATE", "player")
assert(WC.metrics.xpGained == 200)
level, xp, xpMax = 24, 50, 1500
event("PLAYER_LEVEL_UP", 24)
assert(WC.metrics.xpGained == 200, "saut de plusieurs niveaux")
xp = 55
event("PLAYER_XP_UPDATE", "player")
assert(WC.metrics.xpGained == 205)

baseline()
level, xpMax = 21, 1200
event("PLAYER_LEVEL_UP", 21)
assert(WC.metrics.xpGained == 0, "seuil actualisé avant l'XP")
xp = 50
event("PLAYER_XP_UPDATE", "player")
assert(WC.metrics.xpGained == 150)

baseline()
event("PLAYER_LEVEL_UP", 21)
baseline()
xp = 920
event("PLAYER_XP_UPDATE", "player")
assert(WC.metrics.xpGained == 20, "reset d'une transition en attente")
now = now + 200000
event("PLAYER_ENTERING_WORLD")
assert(WC:XPPerHour() == 0)
for _, alert in ipairs(WC.alerts) do assert(alert.id ~= "xp-idle", "taux arrondi") end

for _, unavailable in ipairs({0, restricted, -1}) do
  xp, xpMax = 0, unavailable
  SlashCmdList.WARRIORCOMPANION("reset")
  now = now + 601
  event("PLAYER_XP_UPDATE", "player")
  assert(WC:XPPerHour() == nil, "XP inaccessible ou barre inactive")
  for _, alert in ipairs(WC.alerts) do assert(alert.id ~= "xp-idle") end
end
baseline()
now = now + 601
local beforeOpen = #messages
SlashCmdList.WARRIORCOMPANION("")
assert(WC.dashboardAdviceDetail.text:find("Aucune XP", 1, true), "conseil complet actualise a l'ouverture")
assert(#messages == beforeOpen, "ouvrir le tableau a envoyé une notification")
SlashCmdList.WARRIORCOMPANION("")
-- Un premier échantillon tardif ne couvre pas la période avant sa lecture.
money, xpMax = nil, nil
SlashCmdList.WARRIORCOMPANION("reset")
assert(WC:MoneyDelta() == nil)
now = now + 700
money, xpMax = 1500, 1000
event("PLAYER_ENTERING_WORLD")
assert(WC:MoneyDelta() == 0, "première lecture de monnaie au chargement du monde")
assert(not WC:AdviceLines():find("Aucune XP", 1, true))
money = 1430
event("PLAYER_MONEY")
assert(WC:MoneyDelta() == -70)
money = restricted
event("PLAYER_MONEY")
assert(WC:MoneyDelta() == nil)
money = 1460
event("PLAYER_MONEY")
assert(WC:MoneyDelta() == -40, "référence conservée après une lecture impossible")
now = now + 600
event("PLAYER_ENTERING_WORLD")
assert(WC:AdviceLines():find("Aucune XP", 1, true))
local command = SlashCmdList.WARRIORCOMPANION
-- Chaque commande utilisateur correspond a une vue cliquable identique.
for _,case in ipairs({
  {"combat","combat","combat"},
  {"performance","combat","performance"},
  {"gear","advice","equipment"},
  {"health","advice","health"},
  {"weapons","advice","weapons"},
  {"spells","advice","spells"},
  {"advice","advice","advice"},
  {"settings","settings",nil},
}) do
  command(case[1])
  assert(WC.dashboard:IsShown() and WC.dashboardPage==case[2],
    "commande utilisateur integree : "..case[1])
  if case[2]=="advice" then
    assert(WC.adviceMode==case[3],case[1])
  elseif case[2]=="combat" then
    assert(WC.combatMode==case[3],case[1])
  end
end
command("guide")
assert(WC.dashboardPage=="quests" and WC.questPlanMode=="guide")
command("talents")
assert(WC.dashboardPage=="quests" and WC.questPlanMode=="talents")
command("quests")
assert(WC.dashboardPage=="quests" and WC.questPlanMode=="journal")
-- Une sauvegarde ancienne ou endommagée ne doit pas activer le journal.
WC_DB = "invalide"
assert(WC:Profile().debug == false)
WC_DB.options = { debug = "false", showAlerts = false, other = 12 }
assert(WC:Profile().debug == false and WC:Profile().showAlerts == false)
assert(WC:Profile().other == 12)
WC_DB.options.showAlerts = "false"
assert(WC:Profile().showAlerts == true)

command("debug on")
for i = 1, 115 do WC:Trace("limite", "entree-" .. i) end
command("status")
assert(messages[#messages]:match("traces 100$"), "limite de mémoire")
local start = #messages
command("logs")
assert(#messages == start + 15, "limite d'affichage")
assert(messages[start + 1]:match("entree%-101$") and messages[#messages]:match("entree%-115$"))
command("clear")
command("logs")
assert(messages[#messages]:find("Aucune trace", 1, true))
WC:Trace("test", "avant désactivation")
command("debug off")
WC:Trace("test", "après désactivation")
command("logs")
assert(messages[#messages]:find("Aucune trace", 1, true))

command("alerts off")
start = #messages
for i = 1, 3 do event("PLAYER_DEAD") end
assert(#messages == start)
command("")
assert(WC.dashboardAdviceDetail.text:find("3 morts", 1, true))
command("")
now = now + 300
command("alerts on")
assert(messages[#messages]:find("3 point", 1, true))
start = #messages
now = now + 299
event("PLAYER_TALENT_UPDATE")
assert(#messages == start)
now = now + 1
event("PLAYER_TALENT_UPDATE")
assert(#messages == start + 1, "rappel à cinq minutes")
C_ClassTalents = nil
now = now + 300
start = #messages
event("PLAYER_TALENT_UPDATE")
assert(#messages == start, "un conseil informatif est resté dans le tableau")
-- Le compteur et la chronologie doivent refléter la même mesure après un zonage.
baseline()
command("history")
assert(messages[#messages]:find("Historique de session vide.", 1, true))
start = #messages
xp = xp + 35
event("PLAYER_ENTERING_WORLD")
event("PLAYER_XP_UPDATE", "player")
assert(WC.metrics.xpGained == 35)
assert(#messages == start, "l'historique doit rester silencieux")
command("history")
assert(#messages == start + 2 and messages[#messages]:match("%+35 XP$"),
  "le gain mesuré au changement de zone doit apparaître exactement une fois")
command("debug on")
command("debug off")
command("history")
assert(messages[#messages]:match("%+35 XP$"), "désactiver le debug a effacé l'historique")
command("reset")
command("history")
assert(messages[#messages]:find("Historique de session vide.", 1, true))
print("OK: API Forever simulées, combat, XP, niveaux, alertes, journal, options et tableau")
