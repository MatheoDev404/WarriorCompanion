local addonName, WC = ...
_G.WarriorCompanion = WC
WC.version = "0.2.0"
WC.metrics = { xpGained = 0, deaths = 0, started = nil, lastXP = nil, lastXPMax = nil, lastLevel = nil, moneyStart = nil, moneyNow = nil, questCount = nil }
WC.alerts = {}
WC.inCombat = false
WC.ready = false

function WC:Profile()
  WC_DB = WC_DB or {}
  WC_DB.options = WC_DB.options or {}
  local options = WC_DB.options
  if options.debug == nil then options.debug = false end
  if options.showAlerts == nil then options.showAlerts = true end
  return options
end

function WC:IsReadableNumber(value)
  return type(value) == "number" and not (issecretvalue and issecretvalue(value))
end

function WC:Now()
  if type(GetTime) == "function" then return GetTime() end
  return 0
end

function WC:Refresh()
  if not self.ready then return end
  self:UpdateAdvice()
  self:NotifyImportant()
  self:RefreshDashboard()
end

local frame = CreateFrame("Frame")
WC.eventFrame = frame
local events = {
  "PLAYER_LOGIN", "PLAYER_ENTERING_WORLD", "PLAYER_XP_UPDATE", "PLAYER_LEVEL_UP",
  "PLAYER_DEAD", "PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED",
  "PLAYER_EQUIPMENT_CHANGED", "PLAYER_TALENT_UPDATE", "CHARACTER_POINTS_CHANGED",
  "PLAYER_MONEY", "QUEST_LOG_UPDATE", "SKILL_LINES_CHANGED"
}
for _, event in ipairs(events) do frame:RegisterEvent(event) end

frame:SetScript("OnEvent", function(_, event, ...)
  if event == "PLAYER_LOGIN" then
    if WC.ready then return end
    WC:Profile()
    WC.inCombat = InCombatLockdown()
    WC:InitObserver()
    WC:CreateDashboard()
    WC.ready = true
    WC:Trace("core", "initialise")
    WC:Refresh()
  elseif not WC.ready then
    return
  elseif event == "PLAYER_REGEN_DISABLED" then
    WC.inCombat = true
  elseif event == "PLAYER_REGEN_ENABLED" then
    WC.inCombat = false
    WC:Refresh()
  else
    WC:OnObservedEvent(event, ...)
    if not WC.inCombat then WC:Refresh() end
  end
end)

SLASH_WARRIORCOMPANION1 = "/wc"
SlashCmdList = SlashCmdList or {}
SlashCmdList.WARRIORCOMPANION = function(msg)
  msg = (msg or ""):lower():match("^%s*(.-)%s*$")
  if msg == "debug on" then
    WC:Profile().debug = true
    WC:Print("Journal de diagnostic active.")
  elseif msg == "debug off" then
    WC:Profile().debug = false
    WC:ClearLogs()
    WC:Print("Journal desactive et efface.")
  elseif msg == "logs" then WC:ShowLogs()
  elseif msg == "clear" then WC:ClearLogs(); WC:Print("Traces effacees.")
  elseif msg == "status" then WC:Status()
  elseif msg == "reset" then WC:ResetSession()
  elseif msg == "alerts on" then WC:Profile().showAlerts = true; WC:Print("Alertes actives."); WC:Refresh()
  elseif msg == "alerts off" then WC:Profile().showAlerts = false; WC:Print("Alertes desactivees.")
  elseif msg == "help" then
    WC:Print("/wc : tableau | status | reset | debug on/off | logs | clear | alerts on/off")
  else WC:ToggleDashboard() end
end
