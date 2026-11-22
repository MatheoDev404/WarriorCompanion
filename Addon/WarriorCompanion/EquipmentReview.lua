local _, WC = ...
-- Audit prudent du materiel equipe, sans inventer de meilleurs objets.
-- Met en avant les emplacements vides et les pieces peu adaptees au niveau.
local SLOTS = {
  {1,"Tete",10},{2,"Cou",10},{3,"Epaules",15},{5,"Torse",1},
  {6,"Taille",1},{7,"Jambes",1},{8,"Pieds",1},{9,"Poignets",1},
  {10,"Mains",1},{11,"Anneau 1",10},{12,"Anneau 2",10},
  {13,"Bijou 1",20},{14,"Bijou 2",20},{15,"Dos",1},
  {16,"Arme principale",1},{17,"Main gauche",20},
}
local function safeNumber(x)
  if type(x) ~= "number" or x ~= x or x == math.huge or x == -math.huge then
    return false
  end
  if type(issecretvalue) == "function" then
    local ok, secret = pcall(issecretvalue, x)
    if not ok or secret then return false end
  end
  return true
end
local function equipped(slot)
  if type(GetInventoryItemID) ~= "function" then return false, nil end
  local ok, id = pcall(GetInventoryItemID, "player", slot)
  if not ok or (id ~= nil and (not safeNumber(id) or id <= 0)) then
    return false, nil
  end
  return true, id
end
local function itemInfo(id)
  if type(GetItemInfo) ~= "function" then return nil end
  local ok, name, _, quality, itemLevel = pcall(GetItemInfo, id)
  if not ok or type(name) ~= "string" or name == "" then return nil end
  if not safeNumber(quality) then quality = nil end
  if not safeNumber(itemLevel) then itemLevel = nil end
  return {name=name, quality=quality, itemLevel=itemLevel}
end
function WC:ReadEquipmentReview()
  if not self.IsWarrior or not self:IsWarrior() then return nil end
  if type(UnitLevel) ~= "function" then return nil end
  local ok, level = pcall(UnitLevel, "player")
  if not ok or not safeNumber(level) or level < 1 or level > 60 then return nil end
  local rows, unknown = {}, 0
  for _, slot in ipairs(SLOTS) do
    if level >= slot[3] then
      local read, id = equipped(slot[1])
      if not read then
        unknown = unknown + 1
      elseif not id then
        -- La main gauche reste optionnelle (2M ou pas encore double maniement).
        if slot[1] ~= 17 then
          rows[#rows+1] = {slot=slot[2], reason="emplacement vide", severity=1}
        end
      else
        local info = itemInfo(id)
        if not info then
          unknown = unknown + 1
        else
          local reasons = {}
          -- Qualite faible et niveau tres inferieur sont des signaux,
          -- pas des preuves qu'un remplacement ameliore le personnage.
          if info.quality == 0 then
            reasons[#reasons+1] = "qualite mediocre"
          elseif info.quality == 1 and level >= 15 then
            reasons[#reasons+1] = "objet commun"
          end
          if info.itemLevel and level >= 15 and level - info.itemLevel >= 12 then
            reasons[#reasons+1] = "niveau d'objet "..math.floor(info.itemLevel)..
              " pour personnage niveau "..math.floor(level)
          end
          if #reasons > 0 then
            rows[#rows+1] = {slot=slot[2], item=info.name,
              reason=table.concat(reasons,", "), severity=2}
          end
        end
      end
    end
  end
  table.sort(rows,function(a,b)
    if a.severity ~= b.severity then return a.severity < b.severity end
    return a.slot < b.slot
  end)
  return {rows=rows, unknown=unknown, level=level}
end

function WC:EquipmentReviewText()
  local result=self:ReadEquipmentReview()
  if not result then return "Equipement : lecture indisponible sur ce personnage." end
  local lines={}
  if #result.rows==0 then
    lines[#lines+1]="Aucun signal evident parmi les objets lisibles."
  else
    lines[#lines+1]=tostring(#result.rows)..
      " emplacement(s) a verifier en priorite :"
    for i=1,math.min(8,#result.rows) do
      local row=result.rows[i]
      lines[#lines+1]="- "..row.slot.." : "..
        (row.item and row.item.." ("..row.reason..")" or row.reason)
    end
    if #result.rows>8 then
      lines[#lines+1]="... et "..tostring(#result.rows-8).." autre(s)."
    end
  end
  if result.unknown>0 then
    lines[#lines+1]=tostring(result.unknown)..
      " emplacement(s) sans donnees d'objet fiables."
  end
  lines[#lines+1]="Ce sont des pistes, pas des ameliorations garanties."
  if self.GearQuestAvailability and self:GearQuestAvailability()==true then
    lines[#lines+1]="Pour les objets precis : ouvre GearQuest avec /gq."
  end
  return table.concat(lines,"\n")
end

function WC:AddEquipmentReviewAdvice(items)
  if type(items) ~= "table" then return end
  local report=self:ReadEquipmentReview()
  if not report then return end
  if #report.rows > 0 then
    items[#items+1]={
      id="equipment-review",priority="info",
      message="Equipement : "..#report.rows..
        " emplacement(s) a verifier. Consulte l'onglet Conseils pour les details."
    }
  end
end
