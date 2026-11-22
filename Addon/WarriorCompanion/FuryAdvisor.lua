local _, WC = ...
-- Conseils prudents pour le guerrier joue en Furie.
-- Le mode Furie est le choix du projet, pas une specialisation detectee en jeu.
-- Les conseils contextuels exigent l'identifiant de classe WARRIOR.

local function warriorClass()
  if type(UnitClass) ~= "function" then return nil end
  local ok, _, token = pcall(UnitClass, "player")
  if not ok then return nil end
  if type(issecretvalue) == "function" then
    local safe, secret = pcall(issecretvalue, token)
    if not safe or secret then return nil end
  end
  if type(token) ~= "string" then return nil end
  return token == "WARRIOR"
end

function WC:IsWarrior()
  return warriorClass() == true
end

function WC:AddFuryAdvice(items)
  if not self:IsWarrior() or type(items) ~= "table" then return end
  local combat = self:GetCombatSummary()
  local h = self.health and self.health.percent
  if not self.inCombat and type(h) == "number" and h > 0 and h < 35 then
    -- Le conseil generique "vie basse" est deja affiche : pas de doublon.
    -- Une indication Furie precise remplace le texte generique.
    for _, item in ipairs(items) do
      if item.id == "health-low" then
        item.message = "Guerrier Furie : " .. tostring(h) ..
          "% de vie. Recupere avec bandages ou nourriture avant de repartir."
        break
      end
    end
  end
  if combat and type(combat.completed) == "number"
      and combat.completed >= 5 and type(combat.average) == "number"
      and combat.average >= 45 then
    items[#items + 1] = {
      id = "fury-slow-combat",
      priority = "info",
      message = "Guerrier Furie : tes phases de combat durent en moyenne " ..
        tostring(combat.average) .. " s. Verifie tes armes et essaie des ennemis moins difficiles."
    }
  end
  local learned = self.spellbook and self.spellbook.learned or {}
  local t = self:Now()
  if #learned > 0 and type(t) == "number" and t >= learned[#learned].time
      and t - learned[#learned].time <= 600 then
    local newest = learned[#learned]
    items[#items + 1] = {
      id = "fury-new-spell",
      priority = "info",
      message = "Guerrier Furie : nouveau sort ou rang observe (" ..
        newest.name .. "). Verifie tes barres d'action et son utilisation."
    }
  end
  if self.AddWeaponAdvice then self:AddWeaponAdvice(items) end
  if self.AddGearQuestAdvice then self:AddGearQuestAdvice(items) end
  -- Ne pas deduire la specialisation reelle, le DPS des armes ou la maitrise de
  -- Premiers secours d'une API non validee.
end

function WC:ShowFuryStatus()
  local state = warriorClass()
  if state == nil then
    self:Print("Conseils Furie : classe indisponible, conseils contextuels suspendus.")
  elseif not state then
    self:Print("Conseils Furie : personnage non guerrier, conseils suspendus.")
  else
    self:Print("Conseils Furie : mode du projet actif pour guerrier. Specialisation non verifiee.")
  end
end
