local _, WC = ...
-- Integration non intrusive avec GearQuest Forever (addon tiers optionnel).
-- AUCUNE copie de ses donnees, calculs ou tables : pas d'API publique
-- documentee pour exporter les recommandations par slot.
-- Les seuls faits affiches viennent de l'etat de chargement de l'addon.

local ADDON = "GearQuestForever"
local ADVICE_WINDOW = 600

local function safeBool(value)
  if type(value) ~= "boolean" then return nil end
  if type(issecretvalue) == "function" then
    local ok, secret = pcall(issecretvalue, value)
    if not ok or secret then return nil end
  end
  return value
end

function WC:GearQuestAvailability()
  local read = C_AddOns and C_AddOns.IsAddOnLoaded
  if type(read) ~= "function" then read = IsAddOnLoaded end
  if type(read) ~= "function" then return nil end
  local ok, result = pcall(read, ADDON)
  if not ok then return nil end
  return safeBool(result)
end

function WC:ObserveGearReviewEvent(event)
  if event ~= "PLAYER_LEVEL_UP" and event ~= "PLAYER_EQUIPMENT_CHANGED" then return end
  if not self.IsWarrior or not self:IsWarrior() then return end
  if event == "PLAYER_LEVEL_UP" then
    self.gearReviewCause = "level"
  else
    self.gearReviewCause = "equipment"
  end
  local now = self:Now()
  if type(now) ~= "number" then return end
  self.gearReviewTime = now
end

function WC:AddGearQuestAdvice(items)
  if type(items) ~= "table" or self.inCombat
      or not self.IsWarrior or not self:IsWarrior() then return end
  if self:GearQuestAvailability() ~= true then return end
  local now = self:Now()
  if type(now) ~= "number" then return end
  local eventTime = self.gearReviewTime
  if type(eventTime) ~= "number" or now < eventTime
      or now - eventTime > ADVICE_WINDOW then return end
  local cause = self.gearReviewCause == "level"
      and "apres ton changement de niveau"
      or "apres ton changement d'equipement"
  items[#items+1] = {
    id = "gearquest-review", priority = "info",
    message = "Guerrier Furie : "..cause..
      ", passe en revue tous les emplacements dans GearQuest (/gq) : "..
      "armes, armure, bijoux et accessoires. Compare chaque proposition "..
      "a ton objet actuel et verifie sa source. Aucun gain ni prix n'est garanti."
  }
end

function WC:ShowGearQuestStatus()
  local loaded = self:GearQuestAvailability()
  if loaded == true then
    self:Print("GearQuest Forever est charge. Ouvre /gq pour examiner TOUS les emplacements et voir " ..
      "les recommandations selon niveau, specialisation et equipement.")
    self:Print("Warrior Companion n'importe aucun score, source d'objet " ..
      "ou prix sans interface de donnees publique verifiable.")
  elseif loaded == false then
    self:Print("GearQuest Forever non charge : aucun conseil " ..
      "de provenance n'est invente. L'addon est optionnel.")
  else
    self:Print("Etat de GearQuest inconnu : API de chargement indisponible.")
  end
end
