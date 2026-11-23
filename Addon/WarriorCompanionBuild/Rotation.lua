local addon,B=...
-- Rotation lisible par categorie : maintenance, ouverture, cycle,
-- opportunites (dont Fulgurance avec GCD), offensifs et defensifs.
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
    t:AddLine("Guide a partir du niveau "..entry.level,1,.78,.34)
    t:AddLine(entry.note,.78,.85,.92,true)
    local status=self:SpellStatus(entry)
    if status and status~="" then
      t:AddLine(status,.95,.73,.44)
    end
  end
  if type(t.Show)=="function" then t:Show() end
end
local layout={
  maintain={x=14,y=-75,w=326,count=2,dy=31},
  opener={x=14,y=-163,w=326,count=2,dy=31},
  cycle={x=14,y=-244,w=326,count=4,dy=24,h=23},
  reactive={x=358,y=-75,w=326,count=3,dy=27,h=26},
  offense={x=358,y=-184,w=326,count=2,dy=28,h=26},
  defense={x=358,y=-263,w=326,count=2,dy=28,h=26},
}
local function makeRow(page,section,i)
  local cfg=layout[section]
  local row=W.button(page,cfg.x,cfg.y-((i-1)*(cfg.dy or 36)),
    cfg.w,cfg.h or 33,"",function()
      local item=page.rows[section][i].entry
      if item then B.selectedSpell=item.spellId end
    end)
  row.icon=row:CreateTexture(nil,"ARTWORK")
  local small=cfg.h~=nil
  row.icon:SetPoint("TOPLEFT",row,"TOPLEFT",7,-3)
  row.icon:SetSize(small and 20 or 25,small and 20 or 25)
  row.name=W.label(row,small and 34 or 41,-1,cfg.w-(small and 42 or 49),
    small and 14 or 18,"GameFontNormal","",WHITE)
  row.note=W.label(row,small and 34 or 41,small and -15 or -18,
    cfg.w-(small and 42 or 49),small and 10 or 13,
    "GameFontHighlightSmall","",MUTED)
  row:SetScript("OnEnter",function()
    row.bg:SetVertexColor(.24,.29,.34,1)
    if row.entry then B:SpellTooltip(row,row.entry) end
  end)
  row:SetScript("OnLeave",function()
    row.bg:SetVertexColor(CARD[1],CARD[2],CARD[3],CARD[4])
    if type(GameTooltip)=="table" and
        type(GameTooltip.Hide)=="function" then GameTooltip:Hide() end
  end)
  return row
end
function B:CreateRotationPage(page)
  W.panel(page,0,0,700,347)
  W.label(page,14,-8,330,23,"GameFontNormalLarge",
    "Enchainement de combat",WHITE)
  page.modeButtons={}
  for i,data in ipairs({{"mono","Monocible"},{"multi","Multicible"}}) do
    local key=data[1]
    page.modeButtons[key]=W.button(page,440+(i-1)*123,-7,117,26,
      data[2],function()
        B.rotationMode=key
        B:RefreshRotation()
      end)
  end
  page.rotationSummary=W.label(page,14,-35,665,19,"GameFontHighlightSmall",
    "Boucle selon le niveau ; buffs, procs et CD se gerent a part.",MUTED)
  W.label(page,14,-56,317,19,"GameFontNormal","A MAINTENIR",GOLD)
  W.label(page,14,-143,317,18,"GameFontNormal","OUVERTURE",GOLD)
  W.label(page,14,-224,317,18,"GameFontNormal","BOUCLE PRINCIPALE",GOLD)
  W.label(page,358,-56,328,18,"GameFontNormal","REACTIONS ET PROCS",GOLD)
  W.label(page,358,-163,328,18,"GameFontNormal","GROS CD OFFENSIFS",GOLD)
  W.label(page,358,-242,328,18,"GameFontNormal","CD DEFENSIFS",GOLD)
  page.rows={}
  for _,section in ipairs({"maintain","opener","cycle","reactive","offense","defense"}) do
    local cfg=layout[section]
    page.rows[section]={}
    for i=1,cfg.count do
      page.rows[section][i]=makeRow(page,section,i)
    end
  end
  page.warning=W.label(page,359,-324,325,16,"GameFontHighlightSmall",
    "Fulgurance : reaction qui declenche le GCD.",MUTED)
end
function B:RefreshRotation()
  if not self.pages or not self.pages.rotation then return end
  local page=self.pages.rotation
  local mode=self.rotationMode or "mono"
  if page.rotationSummary and self.RotationCycleSummaryAt then
    page.rotationSummary:SetText(self:RotationCycleSummaryAt(self.viewLevel,mode))
  end
  for key,btn in pairs(page.modeButtons) do
    local c=key==mode and GOLD or CARD
    btn.bg:SetVertexColor(c[1],c[2],c[3],c[4])
    if btn.txt.SetTextColor then
      btn.txt:SetTextColor(key==mode and .12 or .92,
        key==mode and .16 or .94,key==mode and .22 or .97)
    end
  end
  for section,rows in pairs(page.rows) do
    local list=self:CombatSectionAt(self.viewLevel,mode,section)
    for i,row in ipairs(rows) do
      local item=list[i]
      row.entry=item
      if not item then row:Hide()
      else
        row:Show()
        row.icon:SetTexture(spellIcon(item.spellId))
        row.name:SetText(item.name)
        local status=self:SpellStatus(item)
        if section=="maintain" and item.spellId==6673 then
          local aura=self:PlayerBuffStatus(item.name,item.spellId)
          local buff=aura==true and "Buff actif" or
            (aura==false and "A renouveler" or "Maintenir le buff")
          status=(status and status~="") and (status.." | "..buff) or buff
        end
        local hint=item.note and item.note:sub(1,35) or ""
        if #hint>32 then hint=hint.."..." end
        row.note:SetText((status and status~="") and
          (status.." - "..hint) or hint)
      end
    end
  end
  page.warning:SetText(mode=="mono" and
    "Fulgurance : reaction apres esquive, GCD 1,5 s."
    or "Eviter les gros packs en solo : garder une defense.")
end
