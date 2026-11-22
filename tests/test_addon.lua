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
function GetNumQuestLogEntries() return 4 end
function GetUnspentTalentPoints() return talents end

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
for _, name in ipairs({"Core.lua","Diagnostics.lua","Observer.lua","Advisor.lua","Dashboard.lua"}) do
  assert(loadfile(dir .. name))("WarriorCompanion", WC)
end
local function event(name, ...)
  WC.eventFrame.scripts.OnEvent(WC.eventFrame, name, ...)
end
event("PLAYER_LOGIN")
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
talents = 2
event("CHARACTER_POINTS_CHANGED")
assert(#WC.alerts == 1 and WC.alerts[1].id == "talents")
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
