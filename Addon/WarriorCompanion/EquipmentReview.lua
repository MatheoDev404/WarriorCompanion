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

-- Comparaison locale des objets déjà présents dans les sacs.
-- L'emplacement, le niveau minimum et le type d'armure doivent correspondre.
-- Un ilvl supérieur constitue une piste, pas une preuve d'un gain de DPS.
local EQUIP_LOCS = {
  [1]="INVTYPE_HEAD", [2]="INVTYPE_NECK", [3]="INVTYPE_SHOULDER",
  [5]="INVTYPE_CHEST", [6]="INVTYPE_WAIST", [7]="INVTYPE_LEGS",
  [8]="INVTYPE_FEET", [9]="INVTYPE_WRIST", [10]="INVTYPE_HAND",
  [11]="INVTYPE_FINGER", [12]="INVTYPE_FINGER",
  [13]="INVTYPE_TRINKET", [14]="INVTYPE_TRINKET",
  [15]="INVTYPE_CLOAK", [16]="INVTYPE_WEAPONMAINHAND",
  [17]="INVTYPE_WEAPONOFFHAND",
}
local function detailedItem(id)
  if type(GetItemInfo) ~= "function" then return nil end
  local ok,name,link,quality,level,minLevel,itemClass,itemSubType,_,equipLoc =
    pcall(GetItemInfo,id)
  if not ok or type(name)~="string" or name=="" or not safeNumber(level)
      or type(equipLoc)~="string" then return nil end
  return {id=id,name=name,link=type(link)=="string" and link or name,
    quality=quality,level=level,
    minLevel=safeNumber(minLevel) and minLevel or nil,
    itemClass=itemClass,itemSubType=itemSubType,equipLoc=equipLoc}
end
local function bagApi()
  local modern=C_Container
  if type(modern)=="table" and
      type(modern.GetContainerNumSlots)=="function" and
      type(modern.GetContainerItemID)=="function" then
    return modern.GetContainerNumSlots, modern.GetContainerItemID
  end
  if type(GetContainerNumSlots)=="function" and
      type(GetContainerItemID)=="function" then
    return GetContainerNumSlots, GetContainerItemID
  end
  return nil,nil
end
local function matchingLocation(slot,location)
  local expected=EQUIP_LOCS[slot]
  if expected==location then return true end
  -- A one-handed weapon can go in either hand, depending on restrictions;
  -- we only offer main-hand candidates in this conservative comparison.
  if slot==16 and location=="INVTYPE_WEAPON" then return true end
  if slot==5 and location=="INVTYPE_ROBE" then return true end
  return false
end
function WC:EquipmentBagSuggestions(maxCount)
  if not self.IsWarrior or not self:IsWarrior() then return {} end
  local getSlots,getItem=bagApi()
  if not getSlots then return {} end
  if type(UnitLevel)~="function" then return {} end
  local ok,level=pcall(UnitLevel,"player")
  if not ok or not safeNumber(level) then return {} end
  local bagItems={}
  for bag=0,4 do
    local success,count=pcall(getSlots,bag)
    if success and safeNumber(count) and count>=0 and count<=100 then
      for slot=1,count do
        local valid,id=pcall(getItem,bag,slot)
        if valid and safeNumber(id) and id>0 then
          local item=detailedItem(id)
          if item and item.minLevel and item.minLevel<=level then
            bagItems[#bagItems+1]=item
          end
        end
      end
    end
  end
  local proposals={}
  for _,slot in ipairs(SLOTS) do
    if level>=slot[3] and slot[1]~=17 then
      local valid,id=equipped(slot[1])
      if valid then
        local current=id and detailedItem(id) or nil
        local best
        -- If an equipped item's metadata is absent, don't infer improvement.
        if not id or current then
          for _,item in ipairs(bagItems) do
            if matchingLocation(slot[1],item.equipLoc) and
                (not current or
                (item.level>current.level and
                 item.itemClass==current.itemClass and
                 item.itemSubType==current.itemSubType)) then
              if not best or item.level>best.level then best=item end
            end
          end
        end
        if best then
          proposals[#proposals+1]={
            slot=slot[2],item=best.name,link=best.link,
            level=best.level,previous=current and current.level or nil,
            empty=id==nil,source="Dans tes sacs",
          }
        end
      end
    end
  end
  table.sort(proposals,function(a,b)
    if a.empty~=b.empty then return a.empty end
    return (a.level-(a.previous or 0))>(b.level-(b.previous or 0))
  end)
  local result={}
  for i=1,math.min(maxCount or 5,#proposals) do result[i]=proposals[i] end
  return result
end

function WC:EquipmentReviewText()
  local result=self:ReadEquipmentReview()
  if not result then return "Equipement : lecture indisponible sur ce personnage." end
  local lines={}
  local bag=self:EquipmentBagSuggestions(3)
  if #bag>0 then
    lines[#lines+1]="OBJETS DISPONIBLES DANS TES SACS :"
    for _,p in ipairs(bag) do
      local reason=p.empty and "emplacement vide" or
        ("niveau objet "..p.previous.." -> "..p.level)
      lines[#lines+1]="- "..p.slot.." : "..p.link.." ("..reason..")"
    end
    lines[#lines+1]="Verifie l'armure, les bonus et les restrictions avant d'equiper."
    lines[#lines+1]=""
  end
  local targets=self.EquipmentQuestTargets and self:EquipmentQuestTargets(2) or {}
  if #targets>0 then
    lines[#lines+1]="OBJETS A OBTENIR (QUETES) :"
    for _,p in ipairs(targets) do
      lines[#lines+1]="- "..p.name.." : "..p.reason
      lines[#lines+1]="  "..p.source.." ["..p.risk.."]"
    end
    lines[#lines+1]="Propositions basees sur des recompenses documentees, pas un meilleur DPS garanti."
    lines[#lines+1]=""
  end
  if #result.rows==0 then
    lines[#lines+1]="Aucun signal evident parmi les objets lisibles."
  else
    lines[#lines+1]=tostring(#result.rows)..
      " emplacement(s) a verifier en priorite :"
    for i=1,math.min(3,#result.rows) do
      local row=result.rows[i]
      lines[#lines+1]="- "..row.slot.." : "..
        (row.item and row.item.." ("..row.reason..")" or row.reason)
    end
    if #result.rows>3 then
      lines[#lines+1]="... et "..tostring(#result.rows-3).." autre(s)."
    end
  end
  if result.unknown>0 then
    lines[#lines+1]=tostring(result.unknown)..
      " emplacement(s) sans donnees d'objet fiables."
  end
  lines[#lines+1]="Ce sont des pistes, pas des ameliorations garanties."
  return table.concat(lines,"\n")
end

function WC:AddEquipmentReviewAdvice(items)
  if type(items) ~= "table" then return end
  local report=self:ReadEquipmentReview()
  if not report then return end
  local bag=self:EquipmentBagSuggestions(5)
  if #bag>0 then
    items[#items+1]={
      id="bag-upgrades",priority="info",
      message="Equipement : "..#bag..
        " objet(s) dans tes sacs a comparer. Ouvre Conseils pour les voir."
    }
  end
  if #report.rows > 0 then
    items[#items+1]={
      id="equipment-review",priority="info",
      message="Equipement : "..#report.rows..
        " emplacement(s) a verifier. Consulte l'onglet Conseils pour les details."
    }
  end
end
