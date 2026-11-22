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

local function recordMoney(m)
  m.moneyNow = plainNumber(GetMoney)
  if m.moneyStart == nil then m.moneyStart = m.moneyNow end
end

function WC:InitObserver()
  local m = self.metrics
  m.started = self:Now()
  m.lastLevel, m.lastXP, m.lastXPMax, m.pendingLevel = nil, nil, nil, nil
  m.xpObservedSince = nil
  self:RecordXP()
  m.moneyStart = nil
  recordMoney(m)
  m.questCount = self:ReadQuestCount()
  self:Trace("observer", "session demarree")
end

function WC:RecordXP(event, newLevel)
  local m = self.metrics
  local level, xp, xpMax = playerNumber(UnitLevel), playerNumber(UnitXP), playerNumber(UnitXPMax)
  if event == "PLAYER_LEVEL_UP" and self:IsReadableNumber(newLevel) then
    m.pendingLevel = newLevel
  end
  m.xpAvailable = level ~= nil and level > 0 and xp ~= nil and xp >= 0
      and xpMax ~= nil and xpMax > 0 and xp <= xpMax
  if not m.xpAvailable then
    m.xpObservedSince = nil
    self:Trace("xp", "lecture indisponible")
    return
  end
  if m.pendingLevel and level < m.pendingLevel then return end

  local beforeLevel, beforeXP, beforeMax = m.lastLevel, m.lastXP, m.lastXPMax
  if beforeLevel then
    local gain = 0
    if level == beforeLevel then
      -- La nouvelle barre peut arriver avant le nouveau niveau.
      if xp < beforeXP or xpMax ~= beforeMax then return end
      gain = xp - beforeXP
    elseif level == beforeLevel + 1 then
      -- UnitLevel peut aussi changer en premier.
      if xpMax == beforeMax or (xp == beforeXP and event == "PLAYER_LEVEL_UP") then return end
      gain = beforeMax - beforeXP + xp
    else
      self:Trace("xp", "transition ambigue : aucun gain estime")
    end
    if gain > 0 then
      m.xpGained = m.xpGained + gain
      self:Trace("xp", "+" .. tostring(gain))
    end
  end
  m.xpObservedSince = m.xpObservedSince or self:Now()
  m.pendingLevel = nil
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
    recordMoney(m)
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
    recordMoney(m)
  end
end

function WC:ResetSession()
  local m = self.metrics
  m.xpGained, m.deaths = 0, 0
  self:InitObserver()
  self:ClearActivity()
  self:Trace("observer", "session reinitialisee")
  self:Print("Session reinitialisee.")
  self:Refresh()
end

function WC:XPPerHour()
  local m = self.metrics
  if not m.started or not m.xpAvailable then return nil end
  local elapsed = self:Now() - m.started
  if elapsed < 60 then return nil end
  return math.floor(m.xpGained * 3600 / elapsed + 0.5)
end

function WC:MoneyDelta()
  local m = self.metrics
  if type(m.moneyStart) ~= "number" or type(m.moneyNow) ~= "number" then return nil end
  return m.moneyNow - m.moneyStart
end
