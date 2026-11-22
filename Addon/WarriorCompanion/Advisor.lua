local _, WC = ...
local lastShown = {}
local cooldown = 300

local function unspentPoints()
  if type(GetUnspentTalentPoints) == "function" then
    local ok, n = pcall(GetUnspentTalentPoints)
    if ok and type(n) == "number" then return n end
  end
  return nil
end

function WC:UpdateAdvice()
  local alerts = {}
  local points = unspentPoints()
  if points and points > 0 then
    alerts[#alerts + 1] = {
      id = "talents",
      priority = "important",
      message = tostring(points) .. " point(s) de talent non depense(s)."
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
  local xph = self:XPPerHour()
  if xph == 0 and self.metrics.started and self:Now() - self.metrics.started >= 600 then
    alerts[#alerts + 1] = {
      id = "xp-idle",
      priority = "info",
      message = "Aucune XP mesuree sur la session ; verifie ton activite ou le suivi XP."
    }
  end
  -- Une condition non verifiable ne devient jamais une alerte certaine.
  self.alerts = alerts
  self:NotifyImportant()
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

function WC:AdviceLines()
  local lines = {}
  for _, alert in ipairs(self.alerts) do lines[#lines + 1] = alert.message end
  if #lines == 0 then
    lines[1] = "Aucun conseil verifie pour le moment."
  end
  return table.concat(lines, "\n")
end
