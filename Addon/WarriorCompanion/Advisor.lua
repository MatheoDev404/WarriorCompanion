local _, WC = ...
local lastShown = {}
local cooldownSeconds = 180

local function getUnspentTalents()
  if type(GetUnspentTalentPoints) ~= "function" then return nil end
  local ok, n = pcall(GetUnspentTalentPoints)
  if ok and type(n) == "number" then return n end
  return nil
end

function WC:UpdateAdvice()
  self.alerts = {}
  local unspent = getUnspentTalents()
  if unspent and unspent > 0 then
    self.alerts[#self.alerts + 1] = {
      id = "unspent-talents",
      priority = "important",
      message = tostring(unspent) .. " point(s) de talent disponible(s)."
    }
  end
  -- Pas de recommandation de sorts, d'armes ou de metiers sans API verifiee.
  self:NotifyImportant()
end

function WC:NotifyImportant()
  if self.inCombat or not self:Profile().showAlerts then return end
  for _, alert in ipairs(self.alerts or {}) do
    local now = self:Now()
    local last = lastShown[alert.id]
    if alert.priority == "important" and
       (last == nil or now - last >= cooldownSeconds) then
      lastShown[alert.id] = now
      self:Print(alert.message)
      self:Trace("advisor", "alerte " .. alert.id)
    end
  end
end
