local _, WC = ...
-- Integration non intrusive avec GearQuest Forever (addon tiers optionnel).
-- AUCUNE copie de ses donnees, calculs ou tables : pas d'API publique
-- documentee pour exporter les recommandations par slot.
-- Les seuls faits affiches viennent de l'etat de chargement de l'addon.

local ADDON = "GearQuestForever"

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

function WC:AddGearQuestAdvice(items)
  if type(items) ~= "table" or self.inCombat
      or not self.IsWarrior or not self:IsWarrior() then return end
  if self:GearQuestAvailability() ~= true then return end
  -- Ne pas transformer l'existence de GearQuest en faux classement.
  -- Le rappel est pertinent uniquement quand un besoin d'arme est observe.
  local needsReview = false
  for _,item in ipairs(items) do
    if item.id == "fury-offhand-empty"
        or item.id == "fury-offhand-not-weapon"
        or item.id == "fury-slow-combat" then
      needsReview = true
      break
    end
  end
  if not needsReview then return end
  items[#items+1] = {
    id = "gearquest-review", priority = "info",
    message = "Pour comparer tes armes au niveau actuel en Furie, " ..
      "ouvre GearQuest (/gq), choisis Guerrier / Furie et consulte " ..
      "les armes et leurs sources. Aucun gain ni prix n'est garanti."
  }
end

function WC:ShowGearQuestStatus()
  local loaded = self:GearQuestAvailability()
  if loaded == true then
    self:Print("GearQuest Forever est charge. Ouvre /gq pour voir " ..
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
