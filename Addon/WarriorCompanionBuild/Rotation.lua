local addon,B=...
-- Quatrieme onglet : enchainements conseilles selon mono / multicible.
-- Donnees sans lancement de sort automatique ; chaque priorite est conditionnelle.
local W=B.uiKit
local GOLD,WHITE,MUTED,CARD=W.GOLD,W.WHITE,W.MUTED,W.CARD
local function spellIcon(id)
  if type(C_Spell)=="table" then
    if type(C_Spell.GetSpellTexture)=="function" then
      local ok,icon=pcall(C_Spell.GetSpellTexture,id)
      if ok and icon then return icon end
    end
    if type(C_Spell.GetSpellInfo)=="function" then
      local ok,info=pcall(C_Spell.GetSpellInfo,id)
      if ok and type(info)=="table" and info.iconID then return info.iconID end
    end
  end
  if type(GetSpellTexture)=="function" then
    local ok,icon=pcall(GetSpellTexture,id)
    if ok and icon then return icon end
  end
  return "Interface\\Icons\\INV_Misc_QuestionMark"
end
local function knownSpell(id)
  if type(IsPlayerSpell)=="function" then
    local ok,value=pcall(IsPlayerSpell,id)
    if ok and type(value)=="boolean" then return value end
  end
  if type(C_Spell)=="table" and type(C_Spell.IsSpellKnown)=="function" then
    local ok,value=pcall(C_Spell.IsSpellKnown,id)
    if ok and type(value)=="boolean" then return value end
  end
  return nil
end
function B:SpellTooltip(btn,entry)
  local t=GameTooltip
  if type(t)~="table" or type(t.SetOwner)~="function" then return end
  t:SetOwner(btn,"ANCHOR_RIGHT")
  local found=false
  if type(t.SetSpellByID)=="function" then
    found=pcall(t.SetSpellByID,t,entry.spellId)
  end
  if type(t.AddLine)=="function" then
    if not found then t:AddLine(entry.name) end
    t:AddLine("Priorite du guide a partir du niveau "..entry.level,1,.78,.34)
    t:AddLine(entry.note,.78,.85,.92,true)
    local known=knownSpell(entry.spellId)
    if known==false then
      t:AddLine("Sort non observe dans le grimoire : verifier l'apprentissage.",1,.60,.40,true)
    end
  end
  if type(t.Show)=="function" then t:Show() end
end
function B:CreateRotationPage(page)
  W.panel(page,0,0,700,347)
  W.label(page,15,-7,666,25,"GameFontNormalLarge",
    "Priorites de combat selon le niveau",WHITE)
  W.label(page,15,-30,665,20,"GameFontHighlightSmall",
    "Ce sont des priorites conditionnelles, pas une macro automatique.",MUTED)
  page.rows={mono={},multi={}}
  for col,descriptor in ipairs({
    {"mono","MONOCIBLE"},
    {"multi","MULTICIBLE"},
  }) do
    local key,name=descriptor[1],descriptor[2]
    local x=14+(col-1)*348
    W.label(page,x,-56,325,24,"GameFontNormal",name,GOLD)
    for i=1,7 do
      local row=W.button(page,x,-82-(i-1)*36,332,33,"",function()
        local list=B:RotationAt(B.viewLevel,key)
        if list[i] then B.selectedSpell=list[i].spellId end
      end)
      row.index=W.label(row,8,-2,20,27,"GameFontHighlightSmall",
        tostring(i),GOLD)
      row.icon=row:CreateTexture(nil,"ARTWORK")
      row.icon:SetPoint("TOPLEFT",row,"TOPLEFT",30,-4)
      row.icon:SetSize(25,25)
      row.name=W.label(row,64,-1,256,19,"GameFontNormal","",WHITE)
      row.note=W.label(row,64,-18,257,14,"GameFontHighlightSmall","",MUTED)
      row:SetScript("OnEnter",function()
        row.bg:SetVertexColor(.24,.29,.34,1)
        local list=B:RotationAt(B.viewLevel,key)
        if list[i] then B:SpellTooltip(row,list[i]) end
      end)
      row:SetScript("OnLeave",function()
        row.bg:SetVertexColor(CARD[1],CARD[2],CARD[3],CARD[4])
        if type(GameTooltip)=="table" and
            type(GameTooltip.Hide)=="function" then GameTooltip:Hide() end
      end)
      page.rows[key][i]=row
    end
  end
end
function B:RefreshRotation()
  if not self.pages or not self.pages.rotation then return end
  local page=self.pages.rotation
  for _,key in ipairs({"mono","multi"}) do
    local list=self:RotationAt(self.viewLevel,key)
    for i,row in ipairs(page.rows[key]) do
      local e=list[i]
      if not e then row:Hide()
      else
        row:Show()
        row.icon:SetTexture(spellIcon(e.spellId))
        row.name:SetText(e.name)
        local known=knownSpell(e.spellId)
        local status=known==false and "Non appris" or "Si disponible"
        row.note:SetText(status.." - niv. "..e.level.."+")
      end
    end
  end
end
