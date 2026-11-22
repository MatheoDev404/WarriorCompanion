local _, WC = ...

-- Petites pistes de materiel avec une provenance auditable, figée lors
-- de la livraison. Ce module ne fait AUCUN appel web en jeu.
-- Un objet est une PISTE A COMPARER, jamais une amelioration prouvee.
-- Sources et preuves du jeu: docs/WEAPON_SOURCES.md.
local VERIFIED_AT = "2026-11-22"
local BUILD = "1.60.1.71037"

local SOURCES = {
  {
    id=6504, name="Wingblade", source="quest",
    sourceName="Leaders of the Fang", place="Wailing Caverns / Thunder Bluff",
    minLevel=22, maxLevel=26, requiredLevel=0,
    hand="main", dungeon=true, usableByWarrior=true,
    itemConfirmed=true, sourceConfirmed=true,
    evidence={
      "https://foreverchanges.pro/item/6504/wingblade",
      "https://guide.wow4ever.se/en/items/6504"
    },
    sourceNote="Recompense au choix, quete de donjon Horde; etat de quete non lu."
  },
  {
    id=6472, name="Stinging Viper", source="boss",
    sourceName="Lord Pythas", place="Wailing Caverns",
    minLevel=19, maxLevel=26, requiredLevel=19,
    hand="onehand", dungeon=true, usableByWarrior=true,
    itemConfirmed=true, sourceConfirmed=true,
    evidence={
      "https://foreverchanges.pro/item/6472/stinging-viper",
      "https://foreverchanges.pro/dungeons/wailing-caverns"
    },
    sourceNote="Butin aleatoire sur un boss; taux de drop non garanti."
  },
  {
    id=7786, name="Headsplitter", source="auction_search",
    sourceName="Hotel des ventes (recherche)", place="Capitale",
    minLevel=25, maxLevel=35, requiredLevel=25,
    hand="onehand", dungeon=false, usableByWarrior=true,
    itemConfirmed=true, sourceConfirmed=true,
    evidence={
      "https://foreverchanges.pro/item/7786/headsplitter",
      "https://foreverchanges.pro/bis/level-40/warrior/tank"
    },
    sourceNote="Objet lie quand equipe; verifier prix, vendeur et stock a l'HDV."
  },
}

local function goodNumber(v)
  if type(v) ~= "number" or v ~= v
      or v == math.huge or v == -math.huge then return false end
  if type(issecretvalue) == "function" then
    local ok, secret = pcall(issecretvalue, v)
    if not ok or secret then return false end
  end
  return true
end

local function classAndLevel(self)
  if not self.IsWarrior or not self:IsWarrior() then return nil end
  if type(UnitLevel) ~= "function" then return nil end
  local ok, level = pcall(UnitLevel,"player")
  if not ok or not goodNumber(level) or level < 1 or level > 60 then return nil end
  return level
end

local function verified(row)
  if type(row) ~= "table" or row.itemConfirmed ~= true
      or row.sourceConfirmed ~= true or row.usableByWarrior ~= true
      or type(row.id) ~= "number" or type(row.name) ~= "string"
      or type(row.minLevel) ~= "number" or type(row.maxLevel) ~= "number"
      or type(row.requiredLevel) ~= "number" or type(row.evidence) ~= "table"
      or #row.evidence < 2 or type(row.sourceName) ~= "string"
      or type(row.sourceNote) ~= "string" then return false end
  if row.minLevel > row.maxLevel or row.minLevel < row.requiredLevel then
    return false
  end
  for _, source in ipairs(row.evidence) do
    if type(source) ~= "string" or not source:match("^https://") then return false end
  end
  return row.source == "quest" or row.source == "boss" or
    row.source == "auction_search"
end

local function alreadyEquipped(self,id)
  local w = self.weapons
  return w and w.available and (w.main == id or w.off == id)
end

function WC:GetVerifiedWeaponTargets()
  local level = classAndLevel(self)
  if not level then return {} end
  local candidates={}
  for _,row in ipairs(SOURCES) do
    if verified(row) and level >= row.minLevel and level <= row.maxLevel
        and level >= row.requiredLevel and not alreadyEquipped(self,row.id) then
      candidates[#candidates+1]=row
    end
  end
  table.sort(candidates,function(a,b)
    local weights={quest=1,boss=2,auction_search=3}
    if weights[a.source] ~= weights[b.source] then
      return weights[a.source] < weights[b.source]
    end
    return a.id < b.id
  end)
  return candidates
end

function WC:AddVerifiedWeaponTargetAdvice(alerts)
  if type(alerts) ~= "table" or self.inCombat then return end
  local candidates=self:GetVerifiedWeaponTargets()
  if #candidates == 0 then return end
  local best=candidates[1]
  local kind=best.source=="auction_search" and "a rechercher a l'HDV"
    or best.source=="quest" and "recompense de quete" or "butin de boss"
  alerts[#alerts+1]={
    id="fury-verified-weapon-target", priority="info",
    message="Piste d'arme verifiee : "..best.name.." ("..kind..", "..
      best.sourceName.."). A comparer a tes armes, pas un upgrade garanti."
  }
end

function WC:ShowWeaponTargets()
  local level=classAndLevel(self)
  if not level then
    self:Print("Armes cibles : guerrier ou niveau indisponible.")
    return
  end
  local candidates=self:GetVerifiedWeaponTargets()
  if #candidates == 0 then
    self:Print("Aucune piste d'arme suffisamment verifiee pour ton niveau : "..tostring(level)..".")
    self:Print("Ne remplace pas une comparaison d'armes par une supposition.")
    return
  end
  self:Print("Armes a comparer (niveau "..tostring(level)..", sources verifiees le "..
    VERIFIED_AT..", client "..BUILD..") :")
  for i=1,math.min(#candidates,3) do
    local row=candidates[i]
    self:Print(row.name.." [objet "..tostring(row.id).."] — "..
      row.sourceName.." — "..row.place..". "..row.sourceNote)
    self:Print("Preuves : "..row.evidence[1].." | "..row.evidence[2])
  end
  self:Print("Disponibilite HDV, progression des quetes et gain reel de DPS non confirmes.")
end
