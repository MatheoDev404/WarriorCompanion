local _, WC = ...
-- Lecture prudente : pas d'interprétation d'une valeur manquante/protégée.
-- Informations purement locales, aucune donnée de santé sauvegardée.

function WC:IsReadableUnit(unit)
  if type(unit) ~= "string" then return false end
  if type(issecretvalue) == "function" then
    local ok, secret = pcall(issecretvalue, unit)
    if not ok or secret then return false end
  end
  return unit == "player"
end

local function safeHealth(fn)
  if type(fn) ~= "function" then return nil end
  local ok, value = pcall(fn, "player")
  if not ok or not WC:IsReadableNumber(value) then return nil end
  if value ~= value or value == math.huge or value == -math.huge then return nil end
  return value
end

function WC:InitHealthObserver()
  self.health = { current = nil, maximum = nil, percent = nil }
  self:ReadHealth()
end

function WC:ReadHealth()
  if not self.health then self.health = {} end
  local current = safeHealth(UnitHealth)
  local maximum = safeHealth(UnitHealthMax)
  local percent
  if current and maximum and maximum > 0 and current >= 0 and current <= maximum then
    percent = math.floor(current * 100 / maximum + 0.5)
  end
  local previous = self.health.percent
  self.health.current = current
  self.health.maximum = maximum
  self.health.percent = percent
  if (previous == nil) ~= (percent == nil) then
    self:Trace("health", percent and "lecture disponible" or "lecture indisponible")
  end
  return percent
end

function WC:ShowHealthStatus()
  local h = self.health or {}
  if h.percent == nil then
    self:Print("Points de vie : indisponibles (API absente ou valeur protegee).")
  else
    self:Print("Points de vie : " .. tostring(h.current) .. " / " ..
      tostring(h.maximum) .. " (" .. tostring(h.percent) .. "%).")
  end
end
