-- Simulation d'une petite surface de l'API WoW. Execute par lua 5.4.
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
  for _, n in ipairs({"SetSize","SetPoint","SetFrameStrata","EnableMouse","SetMovable","RegisterForDrag","SetAllPoints","SetTexture","SetVertexColor","SetWidth","SetHeight","SetJustifyH","SetJustifyV","SetText"}) do f[n] = function() end end
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
talents = 1
event("PLAYER_LOGIN")
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
assert(not WC.dashboard:IsShown())
SlashCmdList.WARRIORCOMPANION("reset")
assert(WC.metrics.xpGained == 0 and WC.metrics.deaths == 0)
assert(WC:XPPerHour() == nil)
print("OK: chargement, XP, niveau, morts, argent, talents, combat, cooldown, logs, UI, reset")
