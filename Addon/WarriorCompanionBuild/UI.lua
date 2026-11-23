local addon,B=...
-- Interface originale sobre; aucune texture externe necessaire.
local BG={0.062,0.077,0.097,0.97}
local PANEL={0.112,0.140,0.173,1}
local CARD={0.163,0.191,0.226,1}
local GOLD={0.96,0.72,0.33,1}
local WHITE={0.91,0.94,0.97,1}
local MUTED={0.67,0.73,0.79,1}
local RED={0.91,0.40,0.38,1}
local GREEN={0.48,0.84,0.62,1}
local function rect(p,x,y,w,h,c)
  local t=p:CreateTexture(nil,"BACKGROUND")
  t:SetTexture("Interface\\Buttons\\WHITE8X8")
  t:SetPoint("TOPLEFT",p,"TOPLEFT",x,y)
  t:SetSize(w,h)
  t:SetVertexColor(c[1],c[2],c[3],c[4])
  return t
end
local function label(p,x,y,w,h,font,text,c)
  local t=p:CreateFontString(nil,"OVERLAY",font or "GameFontNormal")
  t:SetPoint("TOPLEFT",p,"TOPLEFT",x,y)
  t:SetSize(w,h)
  t:SetJustifyH("LEFT")
  t:SetJustifyV("MIDDLE")
  if c and t.SetTextColor then t:SetTextColor(c[1],c[2],c[3]) end
  if text then t:SetText(text) end
  return t
end
local function button(p,x,y,w,h,title,action)
  local b=CreateFrame("Button",nil,p)
  b:SetPoint("TOPLEFT",p,"TOPLEFT",x,y)
  b:SetSize(w,h)
  b.bg=rect(b,0,0,w,h,CARD)
  b.txt=label(b,10,-2,w-18,h-4,"GameFontNormal",title,WHITE)
  b:SetScript("OnClick",action)
  b:SetScript("OnEnter",function()
    b.bg:SetVertexColor(0.25,0.29,0.34,1)
  end)
  b:SetScript("OnLeave",function()
    local c=b.selected and GOLD or CARD
    b.bg:SetVertexColor(c[1],c[2],c[3],c[4])
  end)
  return b
end
local function panel(p,x,y,w,h)
  local f=CreateFrame("Frame",nil,p)
  f:SetPoint("TOPLEFT",p,"TOPLEFT",x,y)
  f:SetSize(w,h)
  rect(f,0,0,w,h,PANEL)
  return f
end
local function textWithFallback(node)
  local name=node[7]
  if type(C_Spell)=="table" and type(C_Spell.GetSpellName)=="function" then
    local ok,result=pcall(C_Spell.GetSpellName,node[5])
    if ok and type(result)=="string" and result~="" then name=result end
  end
  return name
end
function B:TooltipTalent(btn,node)
  if type(GameTooltip)~="table" then return end
  local tooltip=GameTooltip
  if type(tooltip.SetOwner)~="function" then return end
  tooltip:SetOwner(btn,"ANCHOR_RIGHT")
  local plan=self:PlanAt(self.viewLevel)
  local rank=plan and plan.ranks[node[1]] or 0
  local hasSpell=false
  if type(tooltip.SetSpellByID)=="function" then
    local ok=pcall(tooltip.SetSpellByID,tooltip,node[5])
    hasSpell=ok
  end
  if not hasSpell and type(tooltip.AddLine)=="function" then
    tooltip:AddLine(textWithFallback(node))
  end
  if type(tooltip.AddLine)=="function" then
    tooltip:AddLine("Plan au niveau "..self.viewLevel..": "..rank.."/"..node[4],
      1,0.76,0.30)
    local current=math.max(1,rank)
    local hint=self:TalentHint(node[1],current)
    if hint then tooltip:AddLine("Rang "..current.." : "..hint,0.86,0.91,0.95,true) end
    if rank<node[4] then
      local nextHint=self:TalentHint(node[1],rank+1)
      if nextHint then tooltip:AddLine("Suivant "..(rank+1).." : "..nextHint,
        0.72,0.82,0.91,true) end
    end
    tooltip:AddLine("Palier "..node[2]..
      " - "..(5*(node[2]-1)).." points des paliers precedents",0.77,0.79,0.85)
    local dep=self.talentDependencies[node[1]]
    if dep then tooltip:AddLine(
      "Requis : "..dep[1].." "..dep[2].." rang(s)",0.91,0.63,0.43) end
    tooltip:AddLine("Description et rangs exacts : infobulle du client.",0.67,0.73,0.79)
  end
  if type(tooltip.Show)=="function" then tooltip:Show() end
end
local function dismissTip()
  if type(GameTooltip)=="table" and type(GameTooltip.Hide)=="function" then
    GameTooltip:Hide()
  end
end
function B:CreateTalentPage(page)
  panel(page,0,0,349,347)
  panel(page,359,0,341,347)
  label(page,16,-11,305,24,"GameFontNormalLarge","Arbre Furie",WHITE)
  label(page,375,-11,308,24,"GameFontNormalLarge","Plan de progression",WHITE)
  -- Fleches de pre-requis verifiees (Zephras 1.60.1.70938).
  page.connections={}
  for _,connection in ipairs({
    {3,3,5,3}, -- Blood Craze vers Gore Drinker
    {5,2,7,2}, -- Death Wish vers Bloodthirst
  }) do
    local col=connection[2]
    local x=16+(col-1)*78+16
    local y=-44-(connection[1]-1)*41-32
    local endY=-44-(connection[3]-1)*41
    local h=math.max(2,y-endY)
    local line=page:CreateTexture(nil,"ARTWORK")
    line:SetTexture("Interface\\Buttons\\WHITE8X8")
    line:SetPoint("TOPLEFT",page,"TOPLEFT",x,y)
    line:SetSize(2,h)
    line:SetVertexColor(GOLD[1],GOLD[2],GOLD[3],0.8)
    page.connections[#page.connections+1]=line
  end
  page.nodes={}
  for _,node in ipairs(self.talents) do
    local x=16+(node[3]-1)*78
    local y=-44-(node[2]-1)*41
    local b=CreateFrame("Button",nil,page)
    b:SetPoint("TOPLEFT",page,"TOPLEFT",x,y)
    b:SetSize(35,34)
    b.bg=rect(b,0,0,35,34,CARD)
    local icon=b:CreateTexture(nil,"ARTWORK")
    icon:SetPoint("TOPLEFT",b,"TOPLEFT",3,-3)
    icon:SetSize(29,28)
    local ok=pcall(icon.SetTexture,icon,node[6])
    if not ok then icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark") end
    b.icon=icon
    b.rank=label(b,34,-2,40,28,"GameFontHighlightSmall","",MUTED)
    b:SetScript("OnEnter",function() B:TooltipTalent(b,node) end)
    b:SetScript("OnLeave",dismissTip)
    b:SetScript("OnClick",function()
      B.selectedTalent=node[1]
      B:Refresh()
    end)
    page.nodes[node[1]]=b
  end
  page.nextLabel=label(page,376,-52,320,43,"GameFontHighlight","",GOLD)
  page.desc=label(page,376,-105,315,122,"GameFontHighlight","",WHITE)
  page.rotation=label(page,376,-222,317,105,"GameFontHighlight","",MUTED)
end
function B:CreateGearPage(page)
  panel(page,0,0,700,347)
  label(page,16,-10,640,23,"GameFontNormalLarge",
    "Objets de quete et fabrication",WHITE)
  label(page,16,-33,666,20,"GameFontHighlightSmall",
    "Armes prioritaires; pas de butin aleatoire ni de vendeur comme source.",MUTED)
  page.items={}
  for i,item in ipairs(self.gear) do
    local b=button(page,16,-62-(i-1)*64,664,57,"",function()
      B.selectedItem=item.id
      B:Refresh()
    end)
    b.name=label(b,11,-6,480,21,"GameFontNormal",item.name,WHITE)
    b.detail=label(b,11,-29,610,20,"GameFontHighlightSmall","",MUTED)
    page.items[item.id]=b
  end
  page.gearStatus=label(page,18,-324,470,22,"GameFontHighlightSmall","",GOLD)
  page.gotoButton=button(page,504,-318,176,26,"Voir dans Parcours",function()
    if B.selectedItem and B:GoToGear(B.selectedItem) then
      B:ShowPage("parcours")
    end
  end)
end
function B:CreateRoutePage(page)
  panel(page,0,0,700,347)
  label(page,16,-10,250,26,"GameFontNormalLarge","Parcours ordonne",WHITE)
  page.count=label(page,300,-10,380,23,"GameFontHighlightSmall","",MUTED)
  page.zone=label(page,16,-41,650,22,"GameFontNormal","",GOLD)
  page.note=label(page,16,-65,664,52,"GameFontHighlight","",MUTED)
  page.rows={}
  for i=1,4 do
    local row=button(page,14,-120-(i-1)*44,672,39,"",function()
      local index=(B.routeWindowStart or 1)+i-1
      if B.chapterMode then
        if B.chapters[index] then B.selectedChapter=index B:Refresh() end
      else
        local route=B:OrderedRoute()
        if route[index] then B.routeIndex=index B:Refresh() end
      end
    end)
    row.num=label(row,8,-6,35,25,"GameFontHighlightSmall","",GOLD)
    row.name=label(row,45,-5,500,25,"GameFontHighlight","",WHITE)
    row.state=label(row,548,-5,124,25,"GameFontHighlightSmall","",MUTED)
    page.rows[i]=row
  end
  page.previous=button(page,16,-310,86,27,"Avant",function()
    if B.chapterMode then
      B.selectedChapter=math.max(1,(B.selectedChapter or 1)-1)
    else B.routeIndex=math.max(1,(B:FocusRoute() or 1)-1) end
    B:Refresh()
  end)
  page.next=button(page,115,-310,86,27,"Apres",function()
    if B.chapterMode then
      B.selectedChapter=math.min(#B.chapters,(B.selectedChapter or 1)+1)
    else B.routeIndex=math.min(#B:OrderedRoute(),(B:FocusRoute() or 1)+1) end
    B:Refresh()
  end)
  page.done=button(page,480,-310,200,27,"Valider manuellement",function()
    B:MarkStep()
    B:Refresh()
  end)
end
function B:CreateUI()
  if self.frame then return end
  local f=CreateFrame("Frame","WarriorCompanionBuildFrame",UIParent)
  self.frame=f
  f:SetSize(760,498)
  f:SetFrameStrata("DIALOG")
  f:SetMovable(true)
  f:EnableMouse(true)
  f:RegisterForDrag("LeftButton")
  f:SetClampedToScreen(true)
  f:SetScript("OnDragStart",function(self) self:StartMoving() end)
  f:SetScript("OnDragStop",function(self)
    self:StopMovingOrSizing()
    if B.db and self.GetPoint then
      local point,_,rel,x,y=self:GetPoint(1)
      if type(x)=="number" and type(y)=="number" then
        B.db.position={point or "CENTER",rel or "CENTER",x,y}
      end
    end
  end)
  local pos=self.db and self.db.position
  if type(pos)=="table" and type(pos[3])=="number" and type(pos[4])=="number" then
    f:SetPoint(pos[1],UIParent,pos[2],pos[3],pos[4])
  else f:SetPoint("CENTER",UIParent,"CENTER",0,0) end
  f:SetScale(self.scale or 0.82)
  rect(f,0,0,760,498,BG)
  rect(f,0,0,760,42,PANEL)
  label(f,17,-7,330,27,"GameFontNormalLarge","Warrior Companion | Build",WHITE)
  self.levelText=label(f,328,-8,120,26,"GameFontNormal","",GOLD)
  button(f,458,-7,29,28,"<",function()
    B:SetPreview(math.max(1,(B.viewLevel or 1)-1)); B:Refresh()
  end)
  button(f,492,-7,29,28,">",function()
    B:SetPreview(math.min(60,(B.viewLevel or 1)+1)); B:Refresh()
  end)
  button(f,528,-7,72,28,"Niv reel",function()
    B:ReturnToReal(); B:Refresh()
  end)
  button(f,606,-7,28,28,"-",function() B:ChangeScale(-0.08) end)
  button(f,638,-7,28,28,"+",function() B:ChangeScale(0.08) end)
  button(f,681,-7,62,28,"Fermer",function() f:Hide() end)
  self.tabs={}
  local tabs={{"talents","Talents"},{"equipement","Equipement"},{"parcours","Parcours"}}
  for i,tab in ipairs(tabs) do
    local key=tab[1]
    local b=button(f,22+(i-1)*242,-50,230,35,tab[2],function()
      B:ShowPage(key)
    end)
    self.tabs[key]=b
  end
  self.pages={}
  for _,key in ipairs({"talents","equipement","parcours"}) do
    local page=CreateFrame("Frame",nil,f)
    page:SetPoint("TOPLEFT",f,"TOPLEFT",30,-96)
    page:SetSize(700,347)
    self.pages[key]=page
  end
  self:CreateTalentPage(self.pages.talents)
  self:CreateGearPage(self.pages.equipement)
  self:CreateRoutePage(self.pages.parcours)
  self.footer=label(f,29,-454,706,32,"GameFontHighlightSmall","",MUTED)
  f:Hide()
  self:ShowPage("talents")
end
function B:ShowPage(key)
  if not self.pages or not self.pages[key] then return end
  self.page=key
  if key~="parcours" then self.routeForced=false end
  for id,page in pairs(self.pages) do
    if id==key then page:Show() else page:Hide() end
    local btn=self.tabs[id]
    if btn then
      btn.selected=id==key
      local color=btn.selected and GOLD or CARD
      btn.bg:SetVertexColor(color[1],color[2],color[3],color[4])
      btn.txt:SetTextColor(btn.selected and 0.12 or 0.93,
        btn.selected and 0.15 or 0.94,btn.selected and 0.21 or 0.97)
    end
  end
  self:Refresh()
end
function B:RefreshTalents()
  local page=self.pages and self.pages.talents
  if not page then return end
  local plan=self:PlanAt(self.viewLevel)
  if not plan then return end
  for _,node in ipairs(self.talents) do
    local b=page.nodes[node[1]]
    local rank=plan.ranks[node[1]] or 0
    b.rank:SetText(rank.."/"..node[4])
    local c=(rank>0) and GOLD or CARD
    b.bg:SetVertexColor(c[1],c[2],c[3],c[4])
  end
  local nextKey=plan.nextKey
  local node=nextKey and plan.metadata[nextKey]
  page.nextLabel:SetText(nextKey and
    ("Prochain point : "..textWithFallback(node)) or "Plan termine au niveau 60")
  local selected=plan.metadata[self.selectedTalent or nextKey]
  if selected then
    local rank=plan.ranks[selected[1]] or 0
    local dep=self.talentDependencies[selected[1]]
    page.desc:SetText(textWithFallback(selected).."\n\nPlan : "..rank.."/"..selected[4]..
      "\nPalier "..selected[2].." | Colonne "..selected[3]..
      "\nSort #"..selected[5]..
      (dep and ("\nRequis : "..dep[1].." "..dep[2].."/"..dep[2]) or "")..
      "\n\n"..(self:TalentHint(selected[1],math.max(1,rank)) or
        "Survole l'icone pour obtenir plus de details."))
  end
  local l=self.viewLevel
  local advice=l>=40 and
    "Monocible : Sanguinaire > Tourbillon selon rage et CD ; Execution en finition."
    or l>=36 and "Monocible : Tourbillon si appris ; gerer la rage, eviter le spam Frappe heroique."
    or l>=30 and "Gerer la rage ; posture Berserker si la quete de classe est terminee."
    or l>=20 and "Maintenir Cri de guerre ; profiter de Victory Rush ; gerer les auto-attaques."
    or "Charge, Cri de guerre et attaques connues ; eviter les combats difficiles."
  page.rotation:SetText("PRIORITE DES SORTS (INDICATIVE)\n\n"..advice..
    "\n\nAucun lancement automatique.")
end
function B:RefreshGear()
  local page=self.pages and self.pages.equipement
  if not page then return end
  local level=self.viewLevel
  for _,item in ipairs(self.gear) do
    local row=page.items[item.id]
    local eligible,reason=self:ItemEligible(item,level)
    local prefix=item.source=="quest" and "Quete" or "Fabrication"
    row.name:SetText(item.name.."  |  "..item.slot.."  |  Niveau "..item.minLevel)
    row.detail:SetText(prefix.." : "..reason)
    local c=eligible and (item.group and {0.55,0.39,0.24,1} or CARD)
      or {0.17,0.19,0.21,1}
    row.bg:SetVertexColor(c[1],c[2],c[3],c[4])
  end
  self.selectedItem=self.selectedItem or self.gear[1].id
  page.gearStatus:SetText("Selection : item #"..tostring(self.selectedItem)..
    "   |   Sources : quete ou fabrication uniquement")
end
function B:RefreshChapters()
  local page=self.pages.parcours
  local level=self.viewLevel or 1
  local index=self.selectedChapter
  if not index then
    for i,c in ipairs(self.chapters) do
      if level>=c[1] and level<=c[2] then index=i break end
    end
    index=index or #self.chapters
  end
  index=math.max(1,math.min(#self.chapters,index))
  self.selectedChapter=index
  local chapter=self.chapters[index]
  page.count:SetText("Vue d'ensemble 1-60 | quetes a verifier")
  page.zone:SetText("Niveaux "..chapter[1].."-"..chapter[2].." : "..chapter[3])
  page.note:SetText(chapter[4]..
    "\nApercu de zones : aucune quete individuelle confirmee dans ce chapitre.")
  local start=math.max(1,math.min(#self.chapters-3,index-1))
  self.routeWindowStart=start
  for j,row in ipairs(page.rows) do
    local c=self.chapters[start+j-1]
    if c then
      row:Show()
      row.num:SetText(tostring(start+j-1))
      row.name:SetText(c[1].."-"..c[2].."  "..c[3])
      row.state:SetText("PLAN")
      local color=start+j-1==index and GOLD or CARD
      row.bg:SetVertexColor(color[1],color[2],color[3],color[4])
    else row:Hide() end
  end
  page.done.txt:SetText("Non valide")
end
function B:RefreshRoute()
  self.chapterMode=(self.viewLevel<30 or self.viewLevel>40)
    and not self.routeForced
  if self.chapterMode then self:RefreshChapters() return end
  self.selectedChapter=nil
  self.pages.parcours.done.txt:SetText("Valider manuellement")
  local page=self.pages and self.pages.parcours
  if not page then return end
  local ordered=self:OrderedRoute()
  local i=self:FocusRoute()
  if not i then return end
  local step=ordered[i].step
  page.count:SetText(i.." / "..#ordered.." | Niveau vu "..self.viewLevel)
  page.zone:SetText("Niveau "..step.level.." | "..step.zone)
  page.note:SetText(step.text.."\n"..(step.note or ""))
  local start=math.max(1,math.min(#ordered-3,i-1))
  self.routeWindowStart=start
  for j,row in ipairs(page.rows) do
    local entry=ordered[start+j-1]
    if entry then
      local s=entry.step
      row:Show()
      row.num:SetText(tostring(start+j-1))
      row.name:SetText(s.text)
      row.state:SetText(self:StepState(s))
      local c=start+j-1==i and GOLD or CARD
      row.bg:SetVertexColor(c[1],c[2],c[3],c[4])
    else row:Hide() end
  end
end
function B:Refresh()
  if not self.frame then return end
  self.levelText:SetText("Niv "..(self.viewLevel or "?")..
    (self.mode=="preview" and " (apercu)" or ""))
  self:RefreshTalents()
  self:RefreshGear()
  self:RefreshRoute()
  self.footer:SetText("Pilote 30-40 : sources verifiees pour les objets ; route et DPS a tester en jeu.  "..self.dataVersion)
end
