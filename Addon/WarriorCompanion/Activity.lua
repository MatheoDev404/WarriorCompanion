local _, WC = ...
-- Chronologie de session en RAM, independante des logs de debug.
local MAX_ACTIVITY = 60
local RECENT_DISPLAY = 12
local DEBOUNCE_SECONDS = 8

function WC:ClearActivity()
  self.activity = {}
end

function WC:AddActivity(kind, description, debounce)
  if type(kind) ~= "string" or type(description) ~= "string" then return end
  local now = self:Now()
  self.activity = self.activity or {}
  if debounce then
    for i = #self.activity, 1, -1 do
      local row = self.activity[i]
      local age = now - row.t
      if age >= DEBOUNCE_SECONDS then break end
      if age >= 0 and row.kind == kind and row.description == description then return end
    end
  end
  self.activity[#self.activity + 1] = { t = now, kind = kind, description = description }
  if #self.activity > MAX_ACTIVITY then table.remove(self.activity, 1) end
end

function WC:OnActivityEvent(event, previousXP, previousQuests, ...)
  if not self.ready then return end
  local currentXP = self.metrics.xpGained
  if type(previousXP) == "number" and type(currentXP) == "number" and currentXP > previousXP then
    self:AddActivity("xp", "+" .. tostring(currentXP - previousXP) .. " XP")
  end
  if event == "PLAYER_LEVEL_UP" then
    local level = ...
    if self:IsReadableNumber(level) and level > 0 then
      self:AddActivity("niveau", "Niveau " .. tostring(level))
    end
  elseif event == "PLAYER_DEAD" then
    self:AddActivity("mort", "Mort du personnage")
  elseif event == "PLAYER_EQUIPMENT_CHANGED" then
    -- Slot uniquement : la modification n'indique pas que l'objet est meilleur.
    local slot = ...
    if self:IsReadableNumber(slot) and slot >= 1 then
      self:AddActivity("equipement", "Equipement modifie (emplacement " .. tostring(slot) .. ")", true)
    else
      self:AddActivity("equipement", "Equipement modifie", true)
    end
  elseif event == "SKILL_LINES_CHANGED" then
    self:AddActivity("competences", "Competences mises a jour", true)
  elseif event == "QUEST_LOG_UPDATE" then
    local after = self.metrics.questCount
    if type(previousQuests) == "number" and self:IsReadableNumber(after)
        and after ~= previousQuests then
      self:AddActivity("quetes", "Nombre de quetes : " .. tostring(after))
    end
  end
end

function WC:ShowActivity()
  local rows = self.activity or {}
  if #rows == 0 then
    self:Print("Historique de session vide.")
    return
  end
  self:Print("Activites observees (dernieres " .. tostring(math.min(#rows, RECENT_DISPLAY)) .. ") :")
  for i = math.max(1, #rows - RECENT_DISPLAY + 1), #rows do
    local entry = rows[i]
    self:Print("[" .. tostring(math.floor(entry.t)) .. "] " .. entry.description)
  end
end
