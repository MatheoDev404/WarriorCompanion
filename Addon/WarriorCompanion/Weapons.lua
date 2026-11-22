local _, WC = ...
-- Diagnostic prudent des emplacements 16/17 (armes, bouclier, main gauche).
-- L'observation de la specialisation Furie est une preference de projet.
-- Jamais de DPS ni d'amelioration d'objet deduits sans statistiques fiables.

local function safeNumber(value)
  if type(value) ~= "number" or value ~= value
      or value == math.huge or value == -math.huge then return false end
  if type(issecretvalue) == "function" then
    local ok, secret = pcall(issecretvalue, value)
    if not ok or secret then return false end
  end
  return true
end

local function safeString(value)
  if type(value) ~= "string" then return false end
  if type(issecretvalue) == "function" then
    local ok, secret = pcall(issecretvalue, value)
    if not ok or secret then return false end
  end
  return true
end

local function readEquipped(slot)
  if type(GetInventoryItemID) ~= "function" then
    return nil, "API equipement absente"
  end
  local ok, id = pcall(GetInventoryItemID, "player", slot)
  if not ok then return nil, "Lecture equipement echouee" end
  if id ~= nil and (not safeNumber(id) or id <= 0) then
    return nil, "Identifiant equipement illisible"
  end
  return {id = id}
end

local function itemType(item)
  if not item or not item.id then return nil, "Emplacement vide" end
  local api = C_Item and C_Item.GetItemInfoInstant
  if type(api) ~= "function" then return nil, "Type d'objet indisponible" end
  local ok, _, _, _, loc = pcall(api, item.id)
  if not ok or not safeString(loc) then
    return nil, "Type d'objet illisible"
  end
  return loc
end

function WC:ReadWeapons()
  local main, mainErr = readEquipped(16)
  local off, offErr = readEquipped(17)
  if not main or not off then
    self.weapons = { available=false, reason=mainErr or offErr }
    return false
  end
  local mainType, mainTypeErr = itemType(main)
  local offType, offTypeErr = itemType(off)
  local state = {
    available = true,
    main = main.id, off = off.id,
    mainType = mainType, offType = offType,
    mainReason = mainTypeErr, offReason = offTypeErr,
  }
  -- Une main droite vide ne suffit pas a caracteriser un choix de build.
  -- Le classement de la main droite exige une lecture de type valide.
  self.weapons = state
  return true
end

function WC:InitWeaponObserver()
  self.weapons = nil
  self:ReadWeapons()
end

function WC:ShowWeaponStatus()
  local w = self.weapons
  if not w or not w.available then
    self:Print("Armes : indisponibles (" ..
      tostring(w and w.reason or "non initialise") .. ").")
    return
  end
  self:Print("Main droite : " .. (w.main and tostring(w.main) or "vide") ..
    " (" .. tostring(w.mainType or w.mainReason or "type inconnu") .. ")")
  self:Print("Main gauche : " .. (w.off and tostring(w.off) or "vide") ..
    " (" .. tostring(w.offType or w.offReason or "type inconnu") .. ")")
  self:Print("Ces identifiants ne permettent pas de comparer le DPS des armes.")
end

function WC:AddWeaponAdvice(items)
  if not self:IsWarrior() or type(items) ~= "table" then return end
  local w = self.weapons
  if not w or not w.available then return end
  local ok, level = false, nil
  if type(UnitLevel) == "function" then ok, level = pcall(UnitLevel, "player") end
  if not ok or not safeNumber(level) then return end
  -- En leveling classique, le double maniement est accessible a partir du
  -- niveau 20 si la competence correspondante est apprise.
  if level < 20 or not w.main or not w.mainType then return end
  if w.mainType == "INVTYPE_2HWEAPON" then return end
  if w.mainType ~= "INVTYPE_WEAPON"
      and w.mainType ~= "INVTYPE_WEAPONMAINHAND" then return end

  if w.off == nil then
    items[#items+1] = {
      id="fury-offhand-empty",
      priority="info",
      message="Guerrier Furie : main gauche vide. Si tu as appris le double maniement, " ..
        "equipe une deuxieme arme a une main pour ton style de leveling."
    }
  elseif w.offType == "INVTYPE_SHIELD" or w.offType == "INVTYPE_HOLDABLE" then
    items[#items+1] = {
      id="fury-offhand-not-weapon",
      priority="info",
      message="Guerrier Furie : main gauche non offensive detectee. " ..
        "Pour le double maniement, verifie si une arme a une main te convient mieux."
    }
  end
end
