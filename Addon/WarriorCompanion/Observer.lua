local _, WC = ...
local function safeNumber(fn)
  if type(fn) ~= "function" then return nil end
  local ok, value = pcall(fn, "player")
  if ok and type(value) == "number" then return value end
  return nil
end

function WC:InitObserver()
  local m = self.metrics
  m.lastLevel = safeNumber(UnitLevel)
  m.lastXP = safeNumber(UnitXP)
  m.lastXPMax = safeNumber(UnitXPMax)
  self:Trace("observer", "initialise")
end

function WC:RecordXP()
  local m = self.metrics
  local level, xp, max = safeNumber(UnitLevel), safeNumber(UnitXP), safeNumber(UnitXPMax)
  if not (level and xp and max and max > 0) then
    self:Trace("observer", "XP indisponible")
    return
  end
  if m.lastLevel and m.lastXP and m.lastXPMax then
    local gain = 0
    if level == m.lastLevel then
      if xp >= m.lastXP then gain = xp - m.lastXP end
    elseif level == m.lastLevel + 1 then
      gain = math.max(0, m.lastXPMax - m.lastXP) + math.max(0, xp)
    else
      self:Trace("observer", "saut de niveau : gain non calcule")
    end
    if gain > 0 then
      m.xpGained = m.xpGained + gain
      self:Trace("xp", "+" .. tostring(gain))
    end
  end
  m.lastLevel, m.lastXP, m.lastXPMax = level, xp, max
end

function WC:OnObservedEvent(event)
  if event == "PLAYER_XP_UPDATE" or event == "PLAYER_LEVEL_UP" then
    self:RecordXP()
  elseif event == "PLAYER_DEAD" then
    self.metrics.deaths = self.metrics.deaths + 1
    self:Trace("death", "mort detectee")
  elseif event == "PLAYER_EQUIPMENT_CHANGED" then
    self:Trace("equipment", "changement d'equipement")
  elseif event == "PLAYER_ENTERING_WORLD" then
    self:RecordXP()
  elseif event == "PLAYER_TALENT_UPDATE" then
    self:Trace("talents", "mise a jour")
  end
end

function WC:ResetSession()
  self.metrics.xpGained = 0
  self.metrics.deaths = 0
  self.metrics.started = self:Now()
  self:InitObserver()
  self:Trace("observer", "session reinitialisee")
  self:Refresh()
end

function WC:XPPerHour()
  local elapsed = self:Now() - (self.metrics.started or self:Now())
  if elapsed < 60 then return nil end
  return math.floor(self.metrics.xpGained * 3600 / elapsed + 0.5)
end
