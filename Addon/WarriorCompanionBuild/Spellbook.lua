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
  if type(name)~="string" then return nil end
  return name:lower():gsub("%s*%([^)]*%)%s*$",""):gsub("^%s+",""):gsub("%s+$","")
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
function B:BuildSpellbookCache()
  local book=C_SpellBook
  local bank=type(Enum)=="table" and type(Enum.SpellBookSpellBank)=="table"
    and Enum.SpellBookSpellBank.Player or 0
  if type(book)~="table" or
     type(book.GetNumSpellBookSkillLines)~="function" or
     type(book.GetSpellBookSkillLineInfo)~="function" or
     type(book.GetSpellBookItemInfo)~="function" then
    self.knownSpells=nil
    return nil
  end
  local count=safe(book.GetNumSpellBookSkillLines)
  if type(count)~="number" or count<1 or count>100 then
    self.knownSpells=nil return nil
  end
  local known={byName={},byId={}}
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
          if type(info)=="table" and info.itemType~="FLYOUT" and
              type(info.spellID)=="number" then
            known.byId[info.spellID]=true
            local name=safe(book.GetSpellBookItemName,slot,bank)
            if type(name)~="string" then name=info.name or named(info.spellID) end
            if normalize(name) then known.byName[normalize(name)]=true end
            found=found+1
          end
        end
      end
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
  return nil -- Jamais "non appris" sur le seul ID du rang 1.
end
function B:SpellStatus(entry)
  if self.viewLevel and self.realLevel and
      self.viewLevel>self.realLevel and entry.level>self.realLevel then
    return "Prevu au niveau "..entry.level
  end
  local known=self:IsKnownSpell(entry)
  if known==true then return "Dans le grimoire" end
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
