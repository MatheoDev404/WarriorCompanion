local addonName, WC = ...
_G.WarriorCompanion = WC
WC.version = "0.6.4-rc1"
WC.metrics = { xpGained = 0, deaths = 0, started = nil, lastXP = nil, lastXPMax = nil, lastLevel = nil, moneyStart = nil, moneyNow = nil, questCount = nil }
WC.alerts = {}
WC.inCombat = false
WC.ready = false

function WC:Profile()
  if type(WC_DB) ~= "table" then WC_DB = {} end
  if type(WC_DB.options) ~= "table" then WC_DB.options = {} end
  local options = WC_DB.options
  if type(options.debug) ~= "boolean" then options.debug = false end
  if type(options.showAlerts) ~= "boolean" then options.showAlerts = true end
  if type(options.autoOpen) ~= "boolean" then options.autoOpen = true end
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
  "TRAIT_CONFIG_UPDATED", "TRAIT_NODE_CHANGED", "ACTIVE_TALENT_GROUP_CHANGED",
  "PLAYER_MONEY", "QUEST_LOG_UPDATE", "SKILL_LINES_CHANGED",
  "UNIT_HEALTH", "UNIT_MAXHEALTH", "PLAYER_ALIVE", "PLAYER_UNGHOST",
  "SPELLS_CHANGED", "LEARNED_SPELL_IN_SKILL_LINE"
}
for _, event in ipairs(events) do frame:RegisterEvent(event) end

frame:SetScript("OnEvent", function(_, event, ...)
  if event == "PLAYER_LOGIN" then
    if WC.ready then return end
    WC:Profile()
    WC.inCombat = InCombatLockdown()
    WC:InitObserver()
    WC:ResetCombatMetrics()
    WC:ResetPerformance()
    WC:InitHealthObserver()
    WC:InitSpellbookObserver()
    WC:InitWeaponObserver()
    WC:InitTalentObserver()
    if WC.ObserveLiveFuryTalents then WC:ObserveLiveFuryTalents() end
    WC:UpdateQuestAdvice()
    if WC.GuideStart then WC:GuideStart() end
    WC:BindQuestie()
    WC:CreateDashboard()
    WC:CreateCompactDashboard()
    WC.ready = true
    WC:Trace("core", "initialise")
    WC:Refresh()
    WC:AutoOpenDashboard()
  elseif not WC.ready then
    return
  elseif event == "PLAYER_REGEN_DISABLED" then
    WC.inCombat = true
    WC:StartCombat()
  elseif event == "PLAYER_REGEN_ENABLED" then
    WC:EndCombat("normal")
    WC.inCombat = false
    WC:ReadHealth()
    WC:Refresh()
  else
    local priorXP = WC.metrics.xpGained
    local priorQuests = WC.metrics.questCount
    WC:OnObservedEvent(event, ...)
    if event == "PLAYER_ENTERING_WORLD" then WC:BindQuestie() end
    if event == "PLAYER_EQUIPMENT_CHANGED" or event == "PLAYER_ENTERING_WORLD" then
      WC:ReadWeapons()
    end
    WC:RecordPerformanceGain(WC.metrics.xpGained - priorXP)
    WC:OnActivityEvent(event, priorXP, priorQuests, ...)
    WC:ObserveGearReviewEvent(event)
    if event == "QUEST_LOG_UPDATE" or event == "PLAYER_LEVEL_UP" then
      WC:UpdateQuestAdvice()
      if event == "QUEST_LOG_UPDATE" and WC.GuideAdvanceFromJournal then
        WC:GuideAdvanceFromJournal()
      end
    end
    if event == "PLAYER_TALENT_UPDATE" or event == "CHARACTER_POINTS_CHANGED"
        or event == "TRAIT_CONFIG_UPDATED" or event == "TRAIT_NODE_CHANGED"
        or event == "ACTIVE_TALENT_GROUP_CHANGED" then
      WC:ObserveTalents(true)
      if WC.ObserveLiveFuryTalents then WC:ObserveLiveFuryTalents() end
    elseif event == "PLAYER_ENTERING_WORLD" then
      WC:ObserveTalents(false)
      if WC.ObserveLiveFuryTalents then WC:ObserveLiveFuryTalents() end
    end
    WC:OnCombatObservedEvent(event)
    if event == "SPELLS_CHANGED" or event == "LEARNED_SPELL_IN_SKILL_LINE" then
      WC:ObserveSpellbook()
    end
    if event == "UNIT_HEALTH" or event == "UNIT_MAXHEALTH" then
      local unit = ...
      if WC:IsReadableUnit(unit) then WC:ReadHealth() else return end
    elseif event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_DEAD"
        or event == "PLAYER_ALIVE" or event == "PLAYER_UNGHOST" then
      WC:ReadHealth()
    end
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
  elseif msg == "history" then WC:ShowActivity()
  elseif msg == "combat" then WC:ShowCombatStatus()
  elseif msg == "health" then WC:ShowHealthStatus()
  elseif msg == "fury" then WC:ShowFuryStatus()
  elseif msg == "spells" then WC:ShowSpellbookStatus()
  elseif msg == "weapons" then WC:ShowWeaponStatus()
  elseif msg == "gear" then
    WC:OpenFullDashboard()
    WC:ShowDashboardPage("advice")
  elseif msg == "talents" then
    WC:ShowTalentStatus()
    if WC.ObserveLiveFuryTalents then WC:ObserveLiveFuryTalents() end
    if WC.OpenQuestPlan then WC:OpenQuestPlan("talents") end
  elseif msg == "quests" then WC:OpenQuestPlan("journal")
  elseif msg == "questie" then WC:BindQuestie(); WC:ShowQuestieStatus()
  elseif msg == "discover" then WC:OpenQuestPlan("discover")
  elseif msg == "guide" then WC:OpenQuestPlan("guide")
  elseif msg == "mini" then WC:ShowCompact()
  elseif msg == "full" then WC:OpenFullDashboard()
  elseif msg == "autostart on" then
    WC:Profile().autoOpen = true; WC:Print("Ouverture automatique activee a la connexion.")
  elseif msg == "autostart off" then
    WC:Profile().autoOpen = false; WC:Print("Ouverture automatique desactivee.")
  elseif msg == "performance" then WC:ShowPerformance()
  elseif msg == "clear" then WC:ClearLogs(); WC:Print("Traces effacees.")
  elseif msg == "status" then WC:Status()
  elseif msg == "reset" then WC:ResetSession()
  elseif msg == "alerts on" then WC:Profile().showAlerts = true; WC:Print("Alertes actives."); WC:Refresh()
  elseif msg == "alerts off" then WC:Profile().showAlerts = false; WC:Print("Alertes desactivees.")
  elseif msg == "help" then
    WC:Print("/wc : tableau | status | reset | debug on/off | logs | history | combat | health | fury | spells | weapons | gear | talents | quests | questie | discover | guide | mini | full | autostart on/off | performance | clear | alerts on/off")
  else WC:ToggleDashboard() end
end
