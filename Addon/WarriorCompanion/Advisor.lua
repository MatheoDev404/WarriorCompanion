local _, WC = ...
local lastShown = {}
local cooldown = 300

local function unspentPoints()
  local read = C_ClassTalents and C_ClassTalents.HasUnspentTalentPoints
  if type(read) ~= "function" then return nil end
  local ok, hasPoints, class, spec = pcall(read)
  if ok and not (issecretvalue and issecretvalue(hasPoints)) and hasPoints == true
      and WC:IsReadableNumber(class) and WC:IsReadableNumber(spec)
      and class >= 0 and spec >= 0 then
    return class + spec
  end
  return nil
end

function WC:UpdateAdvice()
  local alerts = {}
  -- Les conseils se basent sur une lecture FRAICHE, jamais sur un cache
  -- potentiellement perime si des points ont change sans evenement de talents.
  local points
  if self.ReadTalentPoints then
    local observed = self:ReadTalentPoints()
    points = observed and observed.total or nil
  else
    points = unspentPoints()
  end
  if points and points > 0 then
    alerts[#alerts + 1] = {
      id = "talents",
      priority = "important",
      message = tostring(points) .. " point(s) de talent non depense(s)."
    }
  end
  local health = self.health and self.health.percent
  if health and not self.inCombat and health > 0 and health < 35 then
    alerts[#alerts + 1] = {
      id = "health-low",
      priority = "info",
      message = "Vie basse (" .. tostring(health) .. "%) : recupere avant un nouveau combat."
    }
  end
  local deaths = self.metrics.deaths
  if deaths >= 3 then
    alerts[#alerts + 1] = {
      id = "deaths",
      priority = "info",
      message = tostring(deaths) .. " morts cette session : envisage des ennemis moins difficiles."
    }
  end
  if self.metrics.xpObservedSince and self.metrics.xpGained == 0
      and self:Now() - self.metrics.xpObservedSince >= 600 then
    alerts[#alerts + 1] = {
      id = "xp-idle",
      priority = "info",
      message = "Aucune XP mesuree sur la session ; verifie ton activite ou le suivi XP."
    }
  end
  -- Les conseils Furie sont exclusivement informatifs et demandent une classe verifiee.
  if self.AddFuryAdvice then self:AddFuryAdvice(alerts) end
  if self.AddEquipmentReviewAdvice then self:AddEquipmentReviewAdvice(alerts) end
  -- Une condition non verifiable ne devient jamais une alerte certaine.
  self.alerts = alerts
end

function WC:NotifyImportant()
  if self.inCombat or not self:Profile().showAlerts then return end
  local now = self:Now()
  for _, alert in ipairs(self.alerts) do
    if alert.priority == "important" then
      local last = lastShown[alert.id]
      if last == nil or now - last >= cooldown then
        lastShown[alert.id] = now
        self:Print(alert.message)
        self:Trace("advisor", "affiche " .. alert.id)
      end
    end
  end
end

function WC:AdviceLines(includeEquipment)
  local lines = {}
  for _, alert in ipairs(self.alerts) do
    if includeEquipment ~= false or
        (alert.id ~= "equipment-review" and alert.id ~= "bag-upgrades") then
      lines[#lines + 1] = alert.message
    end
  end
  if #lines == 0 then
    lines[1] = "Aucun conseil verifie pour le moment."
  end
  return table.concat(lines, "\n")
end
