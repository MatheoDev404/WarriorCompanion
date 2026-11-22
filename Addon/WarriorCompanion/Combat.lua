local _, WC = ...
-- Compteur prudent d'intervalles d'etat de combat, pas de combats/ennemis individuels.
local MAX_SECONDS = 3600

function WC:ResetCombatMetrics()
  self.combat = {
    started = nil, completed = 0, interrupted = 0,
    totalSeconds = 0, deathsInCombat = 0
  }
end

function WC:StartCombat()
  if not self.combat then self:ResetCombatMetrics() end
  if self.combat.started ~= nil then return end
  self.combat.started = self:Now()
  self:Trace("combat", "entree en combat")
end

function WC:EndCombat(reason)
  local combat = self.combat
  if not combat or combat.started == nil then return end
  local elapsed = self:Now() - combat.started
  combat.started = nil
  if type(elapsed) ~= "number" or elapsed < 0 or elapsed > MAX_SECONDS then
    combat.interrupted = combat.interrupted + 1
    self:Trace("combat", "intervalle invalide")
    return
  end
  if reason ~= "normal" then
    combat.interrupted = combat.interrupted + 1
    if reason == "death" then combat.deathsInCombat = combat.deathsInCombat + 1 end
    self:Trace("combat", "intervalle interrompu : " .. tostring(reason))
  else
    combat.completed = combat.completed + 1
    combat.totalSeconds = combat.totalSeconds + elapsed
    self:Trace("combat", "fin : " .. tostring(math.floor(elapsed)) .. " sec")
  end
end

function WC:OnCombatObservedEvent(event)
  if event == "PLAYER_DEAD" then
    self:EndCombat("death")
  elseif event == "PLAYER_ENTERING_WORLD" then
    self:EndCombat("loading")
  end
end

function WC:GetCombatSummary()
  if not self.combat then self:ResetCombatMetrics() end
  local c = self.combat
  local average = nil
  if c.completed > 0 then
    average = math.floor(c.totalSeconds / c.completed + 0.5)
  end
  return { completed = c.completed, interrupted = c.interrupted,
    average = average, totalSeconds = c.totalSeconds,
    deathsInCombat = c.deathsInCombat, active = c.started ~= nil }
end

function WC:ShowCombatStatus()
  local c = self:GetCombatSummary()
  self:Print("Intervalles de combat termines : " .. tostring(c.completed)
    .. " | moyenne : " .. (c.average and tostring(c.average) .. " s" or "indisponible")
    .. " | interrompus : " .. tostring(c.interrupted)
    .. " | morts en combat : " .. tostring(c.deathsInCombat))
  self:Print("Un intervalle correspond a l'etat de combat du joueur, pas a un ennemi tue.")
end
