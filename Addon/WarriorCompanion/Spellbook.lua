local _, WC = ...
-- C_SpellBook uniquement : les fonctions Classic globales sont absentes de Forever.
-- Pas de catalogue de sorts achetables invente. Les donnees sont volatiles.
local MAX_LINES, MAX_SLOTS, MAX_RECENT = 32, 700, 5

local function readable(value, kind)
  if type(value) ~= kind then return false end
  if type(issecretvalue) == "function" then
    local ok, secret = pcall(issecretvalue, value)
    if not ok or secret then return false end
  end
  return true
end

local function scan()
  local api = C_SpellBook
  if type(api) ~= "table" or type(api.GetNumSpellBookSkillLines) ~= "function"
      or type(api.GetSpellBookSkillLineInfo) ~= "function"
      or type(api.GetSpellBookItemName) ~= "function" then
    return nil, "API C_SpellBook incomplete"
  end
  local group = Enum and Enum.SpellBookSpellBank
  local bank = type(group) == "table" and group.Player or nil
  if not readable(bank, "number") then return nil, "Banque de sorts indisponible" end
  local ok, n = pcall(api.GetNumSpellBookSkillLines)
  if not ok or not readable(n, "number") or n < 0 or n > MAX_LINES
      or n ~= math.floor(n) then return nil, "Nombre d'onglets invalide" end
  local known, total = {}, 0
  for i = 1, n do
    local lineOk, info = pcall(api.GetSpellBookSkillLineInfo, i)
    if not lineOk or type(info) ~= "table" then return nil, "Onglet illisible" end
    local offset, count = info.itemIndexOffset, info.numSpellBookItems
    if not readable(offset, "number") or not readable(count, "number")
        or offset < 0 or count < 0 or offset ~= math.floor(offset)
        or count ~= math.floor(count) or offset + count > MAX_SLOTS then
      return nil, "Index du grimoire invalide"
    end
    total = total + count
    if total > MAX_SLOTS then return nil, "Grimoire trop volumineux" end
    for slot = offset + 1, offset + count do
      local nameOk, name, rank = pcall(api.GetSpellBookItemName, slot, bank)
      if not nameOk then return nil, "Nom de sort indisponible" end
      if name ~= nil then
        if not readable(name, "string") then return nil, "Nom de sort protege" end
        if rank ~= nil and not readable(rank, "string") then
          return nil, "Rang de sort protege"
        end
        known[name .. "\001" .. (rank or "")] = {name=name,rank=rank}
      end
    end
  end
  return known
end

function WC:InitSpellbookObserver()
  self.spellbook = {known=nil, learned={}, reason="Initialisation"}
  self:ObserveSpellbook()
end

function WC:ObserveSpellbook()
  if not self.spellbook then self.spellbook = {known=nil,learned={}} end
  local current, reason = scan()
  if not current then
    self.spellbook.reason = reason
    self:Trace("spells", reason)
    self.spellbook.known = nil
    self.spellbook.learned = {}
    return false
  end
  local s = self.spellbook
  local previous = s.known
  s.known, s.reason = current, nil
  if not previous then return true end
  local additions = {}
  for key, entry in pairs(current) do
    if not previous[key] then additions[#additions+1] = entry end
  end
  -- Plus de quatre additions en une lecture : reconfiguration possiblement
  -- massive, donc aucun conseil d'apprentissage individuel.
  if #additions > 0 and #additions <= 4 then
    table.sort(additions,function(a,b)
      return a.name .. (a.rank or "") < b.name .. (b.rank or "")
    end)
    for _,entry in ipairs(additions) do
      local caption = entry.name
      if entry.rank and entry.rank ~= "" then
        caption = caption .. " (" .. entry.rank .. ")"
      end
      local now = self:Now()
      if type(now) == "number" then
        s.learned[#s.learned+1] = {name=caption,time=now}
        if #s.learned > MAX_RECENT then table.remove(s.learned,1) end
        self:Trace("spells","nouveau : " .. caption)
      end
    end
  elseif #additions > 4 then
    self:Trace("spells","changement massif, apprentissage non deduit")
  end
  return true
end

function WC:ShowSpellbookStatus()
  local s = self.spellbook
  if not s or not s.known then
    self:Print("Grimoire : indisponible (" .. tostring(s and s.reason or "non initialise") .. ").")
    return
  end
  local count=0
  for _ in pairs(s.known) do count=count+1 end
  self:Print("Grimoire observe : " .. tostring(count) ..
    " sorts/rangs ; nouveaux depuis cette session : " .. tostring(#s.learned) .. ".")
  if #s.learned > 0 then
    self:Print("Derniere nouveaute : " .. s.learned[#s.learned].name)
  end
  self:Print("Ce diagnostic ne determine pas les sorts disponibles chez le maitre.")
end
