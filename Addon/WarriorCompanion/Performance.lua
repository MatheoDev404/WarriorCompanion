local _, WC = ...
-- XP/h glissante sur dix minutes. Mesures purement observees.
local WINDOW = 600
local MAX_SAMPLES = 600
local MIN_ELAPSED = 60

function WC:ResetPerformance()
  self.performance = { samples = {}, incompleteUntil = nil }
end

function WC:RecordPerformanceGain(gain)
  if type(gain) ~= "number" or gain <= 0 then return end
  if not self.performance then self:ResetPerformance() end
  local now = self:Now()
  local samples = self.performance.samples
  if type(now) ~= "number" then return end
  -- En cas de retour en arriere de l'horloge, la fenetre devient incertaine.
  if #samples > 0 and now < samples[#samples].time then
    self:ResetPerformance()
    samples = self.performance.samples
  end
  samples[#samples + 1] = { time = now, xp = gain }
  self:PrunePerformance(now)
end

function WC:PrunePerformance(now)
  if not self.performance then self:ResetPerformance() end
  local p = self.performance
  local samples = p.samples
  local threshold = now - WINDOW
  while #samples > 0 and samples[1].time < threshold do
    table.remove(samples, 1)
  end
  while #samples > MAX_SAMPLES do
    local removed = table.remove(samples, 1)
    p.incompleteUntil = math.max(p.incompleteUntil or 0, removed.time + WINDOW)
  end
end

function WC:RecentXPPerHour()
  local m = self.metrics
  if not m.started or not m.xpAvailable then return nil end
  local now = self:Now()
  if type(now) ~= "number" then return nil end
  local elapsed = now - m.started
  if elapsed < MIN_ELAPSED then return nil end
  if not self.performance then self:ResetPerformance() end
  self:PrunePerformance(now)
  local p = self.performance
  if p.incompleteUntil and now <= p.incompleteUntil then return nil end
  local duration = math.min(WINDOW, elapsed)
  local xp = 0
  for _, sample in ipairs(p.samples) do
    if sample.time >= now - WINDOW and sample.time <= now then xp = xp + sample.xp end
  end
  return math.floor(xp * 3600 / duration + 0.5)
end

function WC:ShowPerformance()
  local session = self:XPPerHour()
  local recent = self:RecentXPPerHour()
  self:Print("XP/h session : " .. (session and tostring(session) or "indisponible")
    .. " | XP/h recentes (10 min) : " .. (recent and tostring(recent) or "indisponible"))
  self:Print("Les deux taux incluent les periodes sans XP ; aucune attribution a un ennemi ou une quete.")
end
