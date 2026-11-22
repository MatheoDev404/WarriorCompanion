local _, WC = ...
local function playerNumber(fn)
  if type(fn) ~= "function" then return nil end
  local ok, n = pcall(fn, "player")
  if ok and WC:IsReadableNumber(n) then return n end
  return nil
end
local function plainNumber(fn)
  if type(fn) ~= "function" then return nil end
  local ok, n = pcall(fn)
  if ok and WC:IsReadableNumber(n) then return n end
  return nil
end

function WC:InitObserver()
  local m = self.metrics
  m.started = self:Now()
  m.lastLevel = playerNumber(UnitLevel)
  m.lastXP = playerNumber(UnitXP)
  m.lastXPMax = playerNumber(UnitXPMax)
  m.moneyStart = plainNumber(GetMoney)
  m.moneyNow = m.moneyStart
  m.questCount = self:ReadQuestCount()
  self:Trace("observer", "session demarree")
end

function WC:RecordXP(event, newLevel)
  local m = self.metrics
  local level, xp, xpMax = playerNumber(UnitLevel), playerNumber(UnitXP), playerNumber(UnitXPMax)
  if not (level and xp and xpMax and xpMax > 0) then
    self:Trace("xp", "API indisponible")
    return
  end
  local beforeLevel, beforeXP, beforeMax = m.lastLevel, m.lastXP, m.lastXPMax
  if beforeLevel and beforeXP and beforeMax then
    local gain = 0
    if level == beforeLevel and xp >= beforeXP then
      gain = xp - beforeXP
    elseif level == beforeLevel + 1 then
      gain = math.max(0, beforeMax - beforeXP) + math.max(0, xp)
    elseif event == "PLAYER_LEVEL_UP" and type(newLevel) == "number" and newLevel == beforeLevel + 1 then
      -- L'API peut encore afficher l'ancien niveau dans cet evenement.
      self:Trace("xp", "transition de niveau en attente")
      return
    else
      self:Trace("xp", "transition ambigue : aucun gain estime")
    end
    if gain > 0 then
      m.xpGained = m.xpGained + gain
      self:Trace("xp", "+" .. tostring(gain))
    end
  end
  m.lastLevel, m.lastXP, m.lastXPMax = level, xp, xpMax
end

function WC:ReadQuestCount()
  local read = C_QuestLog and C_QuestLog.GetNumQuestLogEntries
  if type(read) ~= "function" then return nil end
  local ok, _, count = pcall(read)
  if ok and self:IsReadableNumber(count) and count >= 0 then return count end
  return nil
end

function WC:OnObservedEvent(event, ...)
  local m = self.metrics
  if event == "PLAYER_XP_UPDATE" or event == "PLAYER_LEVEL_UP" then
    self:RecordXP(event, ...)
  elseif event == "PLAYER_DEAD" then
    m.deaths = m.deaths + 1
    self:Trace("death", "mort")
  elseif event == "PLAYER_MONEY" then
    m.moneyNow = plainNumber(GetMoney)
    self:Trace("money", "mise a jour")
  elseif event == "QUEST_LOG_UPDATE" then
    local count = self:ReadQuestCount()
    if count ~= m.questCount then
      m.questCount = count
      self:Trace("quests", "journal actualise")
    end
  elseif event == "PLAYER_EQUIPMENT_CHANGED" then
    self:Trace("equipment", "changement d'equipement")
  elseif event == "PLAYER_TALENT_UPDATE" or event == "CHARACTER_POINTS_CHANGED" then
    self:Trace("talents", "mise a jour")
  elseif event == "SKILL_LINES_CHANGED" then
    self:Trace("skills", "competences actualisees")
  elseif event == "PLAYER_ENTERING_WORLD" then
    self:RecordXP(event)
  end
end

function WC:ResetSession()
  local m = self.metrics
  m.xpGained, m.deaths = 0, 0
  self:InitObserver()
  self:Trace("observer", "session reinitialisee")
  self:Print("Session reinitialisee.")
  self:Refresh()
end

function WC:XPPerHour()
  local m = self.metrics
  if not m.started then return nil end
  local elapsed = self:Now() - m.started
  if elapsed < 60 then return nil end
  return math.floor(m.xpGained * 3600 / elapsed + 0.5)
end

function WC:MoneyDelta()
  local m = self.metrics
  if type(m.moneyStart) ~= "number" or type(m.moneyNow) ~= "number" then return nil end
  return m.moneyNow - m.moneyStart
end
