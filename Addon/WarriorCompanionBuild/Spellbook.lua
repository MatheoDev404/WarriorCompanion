local addon,B=...
-- WoW Forever: les ID du rang 1 ne sont PAS un test fiable de
-- l'apprentissage de toute la famille de sorts. Lire le grimoire moderne.
-- Aucune conclusion "non appris" lorsque les donnees sont incompletes.
local function safe(fn,...)
  if type(fn)~="function" then return nil end
  local ok,a,b=pcall(fn,...)
  if ok then return a,b end
end
local function normalize(name)
  if type(name)~="string" or name=="" then return nil end
  -- Les libelles de repli sont parfois sans accents, le grimoire en VF.
  local value=name:lower():gsub("%s*%([^)]*%)%s*$","")
  local accents={
    ["é"]="e",["è"]="e",["ê"]="e",["ë"]="e",
    ["à"]="a",["â"]="a",["ä"]="a",
    ["î"]="i",["ï"]="i",["ô"]="o",["ö"]="o",
    ["ù"]="u",["û"]="u",["ü"]="u",["ç"]="c",
  }
  for accented,plain in pairs(accents) do
    value=value:gsub(accented,plain)
  end
  return value:gsub("%s+"," "):gsub("^%s+",""):gsub("%s+$","")
end
local function named(id)
  if type(C_Spell)=="table" then
    local info=safe(C_Spell.GetSpellInfo,id)
    if type(info)=="table" and type(info.name)=="string" then return info.name end
    local name=safe(C_Spell.GetSpellName,id)
    if type(name)=="string" and name~="" then return name end
  end
  return nil
end
-- Rangs documentes pour Forever 1.60.1 : annoncer une amelioration
-- seulement si le rang reel peut etre identifie dans le grimoire.
local families={
  [7386]={{7386,10},{7405,22},{8380,34},{11596,46},{11597,58}},
  [6673]={{6673,1},{5242,12},{6192,22},{11549,32},
          {11550,42},{11551,52},{25289,60}},
  [78]={{78,1},{284,8},{285,16},{1608,24},{11564,32},
        {11565,40},{11566,48},{11567,56},{25286,60}},
}
local function parsedRank(label)
  if type(label)~="string" then return nil end
  local n=tonumber(label:match("%d+"))
  if n and n>=1 and n<=20 then return n end
  return nil
end
function B:BuildSpellbookCache()
  local book=C_SpellBook
  local bank=type(Enum)=="table" and type(Enum.SpellBookSpellBank)=="table"
    and Enum.SpellBookSpellBank.Player or 0
  if type(book)~="table" or
     type(book.GetNumSpellBookSkillLines)~="function" or
     type(book.GetSpellBookSkillLineInfo)~="function" or
     (type(book.GetSpellBookItemInfo)~="function" and
      type(book.GetSpellBookItemName)~="function") then
    self.knownSpells=nil
    return nil
  end
  local count=safe(book.GetNumSpellBookSkillLines)
  if type(count)~="number" or count<1 or count>100 then
    self.knownSpells=nil return nil
  end
  local known={byName={},byId={},rankByName={},complete=true}
  local found=0
  for i=1,count do
    local line=safe(book.GetSpellBookSkillLineInfo,i)
    if type(line)=="table" then
      local offset=line.itemIndexOffset
      local amount=line.numSpellBookItems
      if type(offset)=="number" and type(amount)=="number" and
          amount>=0 and amount<500 then
        for slot=offset+1,offset+amount do
          local info=safe(book.GetSpellBookItemInfo,slot,bank)
          if not (type(info)=="table" and info.itemType=="FLYOUT") then
            local spellId=type(info)=="table" and info.spellID or nil
            local name,rank=safe(book.GetSpellBookItemName,slot,bank)
            if type(name)~="string" then
              name=type(info)=="table" and info.name or nil
            end
            if type(name)~="string" and type(spellId)=="number" then
              name=named(spellId)
            end
            local normalized=normalize(name)
            if normalized then
              known.byName[normalized]=true
              local value=parsedRank(rank)
              if value and value>(known.rankByName[normalized] or 0) then
                known.rankByName[normalized]=value
              end
            end
            if type(spellId)=="number" then known.byId[spellId]=true end
            if normalized or type(spellId)=="number" then
              found=found+1
            else
              known.complete=false
            end
          end
        end
      else
        known.complete=false
      end
    else
      known.complete=false
    end
  end
  -- 0 sorts donne un grimoire non initialise et non une preuve d'absence.
  if found==0 then self.knownSpells=nil return nil end
  self.knownSpells=known
  return known
end
function B:IsKnownSpell(entry)
  if not entry or type(entry.spellId)~="number" then return nil end
  if type(IsPlayerSpell)=="function" then
    local yes=safe(IsPlayerSpell,entry.spellId)
    if yes==true then return true end
  end
  local c=C_Spell
  if type(c)=="table" then
    local yes=safe(c.IsSpellKnown,entry.spellId)
    if yes==true then return true end
  end
  local book=self.knownSpells or self:BuildSpellbookCache()
  if book then
    if book.byId[entry.spellId] then return true end
    -- Comparer le nom localise de la FAMILLE, toutes versions/rangs confondus.
    local localName=named(entry.spellId)
    if localName and book.byName[normalize(localName)] then return true end
    if book.byName[normalize(entry.name)] then return true end
  end
  if book and book.complete then return false end
  return nil
end
function B:SpellStatus(entry)
  if self.viewLevel and self.realLevel and
      self.viewLevel>self.realLevel and entry.level>self.realLevel then
    return "Prevu au niveau "..entry.level
  end
  local known=self:IsKnownSpell(entry)
  if known==true then
    local series=families[entry.spellId]
    local book=self.knownSpells
    if series and book then
      local learned=0
      local name=normalize(named(entry.spellId) or entry.name)
      if name then learned=book.rankByName[name] or 0 end
      for i,rank in ipairs(series) do
        if book.byId[rank[1]] and i>learned then learned=i end
      end
      if learned>0 and learned<#series then
        local nextRank=series[learned+1]
        if nextRank[2]<=(self.realLevel or 1) then
          return "Maitre : rang "..(learned+1)..
            " disponible (niv "..nextRank[2]..")"
        end
      end
    end
    return "" -- Sort connu : ne rien afficher d'inutile.
  end
  if known==false and entry.level<=(self.realLevel or 1) then
    return "Non appris : verifier chez le maitre"
  end
  return "Apprentissage a verifier"
end
function B:PlayerBuffStatus(name,spellId)
  -- Ne pas exiger un ID de buff fixe : les rangs peuvent varier.
  if type(C_UnitAuras)=="table" and
     type(C_UnitAuras.GetAuraDataByIndex)=="function" then
    local foundAny=false
    for i=1,40 do
      local aura=safe(C_UnitAuras.GetAuraDataByIndex,"player",i,"HELPFUL")
      if type(aura)~="table" then
        if i==1 then return nil end
        return false
      end
      foundAny=true
      if aura.spellId==spellId or
         (normalize(aura.name) and normalize(aura.name)==normalize(name)) then
        return true
      end
    end
    if foundAny then return false end
  end
  return nil
end
