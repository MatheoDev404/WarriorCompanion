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
  -- Arial Narrow est une police sans empattement incluse dans WoW.
  -- Approche visuelle proche de Roboto, sans distribuer de fichier de police.
  if t.SetFont then
    local size=font=="GameFontNormalLarge" and 17 or
      (font=="GameFontHighlightSmall" or font=="GameFontNormalSmall") and 12 or 14
    pcall(t.SetFont,t,"Fonts\\ARIALN.TTF",size,"")
  end
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
-- Important : un panneau doit etre une texture derriere les textes.
-- Un Frame enfant couvre les FontStrings de son parent dans le client !
local function panel(p,x,y,w,h)
  return rect(p,x,y,w,h,PANEL)
end
-- Partage des composants avec l'onglet Rotation, sans dependance externe.
B.uiKit={rect=rect,label=label,button=button,panel=panel,
  BG=BG,PANEL=PANEL,CARD=CARD,GOLD=GOLD,WHITE=WHITE,MUTED=MUTED}

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
  label(page,16,-8,305,25,"GameFontNormalLarge","Arbres du Guerrier",WHITE)
  label(page,375,-10,308,24,"GameFontNormalLarge","Plan de progression",WHITE)
  page.treeTabs={}
  page.trees={}
  for tabIndex,treeName in ipairs(self.talentTreeOrder) do
    page.treeTabs[treeName]=button(page,16+(tabIndex-1)*108,-38,103,27,
      treeName,function()
        B:SelectTree(treeName)
        B:Refresh()
      end)
    local holder=CreateFrame("Frame",nil,page)
    holder:SetPoint("TOPLEFT",page,"TOPLEFT",0,0)
    holder:SetSize(349,347)
    local tree={frame=holder,nodes={},connections={}}
    page.trees[treeName]=tree
    local positions={}
    for _,node in ipairs(self.talentTrees[treeName]) do
      positions[node[1]]=node
    end
    for _,link in ipairs(self.talentArrows[treeName] or {}) do
      local from,to=positions[link[1]],positions[link[2]]
      if from and to and from[3]==to[3] then
        local col=from[3]
        local x=16+(col-1)*78+17
        local y=-67-(from[2]-1)*36-32
        local endY=-67-(to[2]-1)*36
        local line=holder:CreateTexture(nil,"ARTWORK")
        line:SetTexture("Interface\\Buttons\\WHITE8X8")
        line:SetPoint("TOPLEFT",holder,"TOPLEFT",x,y)
        line:SetSize(2,math.max(2,y-endY))
        line:SetVertexColor(GOLD[1],GOLD[2],GOLD[3],0.7)
        tree.connections[#tree.connections+1]=line
      end
    end
    for _,node in ipairs(self.talentTrees[treeName]) do
      local x=16+(node[3]-1)*78
      local y=-67-(node[2]-1)*36
      local b=CreateFrame("Button",nil,holder)
      b:SetPoint("TOPLEFT",holder,"TOPLEFT",x,y)
      b:SetSize(35,33)
      b.bg=rect(b,0,0,35,33,CARD)
      b.edges={
        rect(b,0,0,35,2,GOLD),
        rect(b,0,-31,35,2,GOLD),
        rect(b,0,0,2,33,GOLD),
        rect(b,33,0,2,33,GOLD),
      }
      local icon=b:CreateTexture(nil,"ARTWORK")
      icon:SetPoint("TOPLEFT",b,"TOPLEFT",3,-3)
      icon:SetSize(29,27)
      local ok=pcall(icon.SetTexture,icon,node[6])
      if not ok then icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark") end
      b.icon=icon
      b.rank=label(b,35,-2,40,27,"GameFontHighlightSmall","",MUTED)
      b:SetScript("OnEnter",function() B:TooltipTalent(b,node) end)
      b:SetScript("OnLeave",dismissTip)
      b:SetScript("OnClick",function()
        B.selectedTalent=node[1]
        B:Refresh()
      end)
      tree.nodes[node[1]]=b
    end
    holder:Hide()
  end
  page.nodes=page.trees.Furie.nodes
  page.connections=page.trees.Furie.connections
  page.levelPoint=label(page,376,-44,310,60,"GameFontNormal","",GOLD)
  page.nextLabel=label(page,376,-101,320,55,"GameFontHighlight","",GOLD)
  page.desc=label(page,376,-168,310,171,"GameFontHighlight","",WHITE)
end
-- Informations de fiche obtenues du client, avec repli pour les objets
-- non encore charges en cache. Ne jamais inventer leurs statistiques.
local function itemIcon(itemID)
  if type(C_Item)=="table" and type(C_Item.GetItemIconByID)=="function" then
    local ok,icon=pcall(C_Item.GetItemIconByID,itemID)
    if ok and icon then return icon end
  end
  if type(GetItemIcon)=="function" then
    local ok,icon=pcall(GetItemIcon,itemID)
    if ok and icon then return icon end
  end
  if type(GetItemInfoInstant)=="function" then
    local ok,_,_,_,_,icon=pcall(GetItemInfoInstant,itemID)
    if ok and icon then return icon end
  end
  if type(C_Item)=="table" and type(C_Item.RequestLoadItemDataByID)=="function" then
    pcall(C_Item.RequestLoadItemDataByID,itemID)
  end
  return "Interface\\Icons\\INV_Misc_QuestionMark"
end
local function itemName(item)
  if type(GetItemInfo)=="function" then
    local ok,name=pcall(GetItemInfo,item.id)
    if ok and type(name)=="string" and name~="" then return name end
  end
  return item.name
end
function B:TooltipItem(btn,item)
  if type(GameTooltip)~="table" or type(GameTooltip.SetOwner)~="function" then return end
  local tooltip=GameTooltip
  tooltip:SetOwner(btn,"ANCHOR_RIGHT")
  local ok=false
  if type(tooltip.SetItemByID)=="function" then
    ok=pcall(tooltip.SetItemByID,tooltip,item.id)
  elseif type(tooltip.SetHyperlink)=="function" then
    ok=pcall(tooltip.SetHyperlink,tooltip,"item:"..item.id)
  end
  if type(tooltip.AddLine)=="function" then
    if not ok then tooltip:AddLine(itemName(item),1,0.8,0.4) end
    tooltip:AddLine("Niveau requis : "..item.minLevel,0.9,0.9,0.95)
    tooltip:AddLine(item.source=="quest" and "Source : recompense de quete" or
      "Source : fabrication "..(item.profession or ""),0.7,0.85,0.98)
    if item.group then tooltip:AddLine("OPTION GROUPE / DONJON",1,0.63,0.35) end
    tooltip:AddLine(self.gearDescriptions[item.id] or item.note or
      "Description indisponible",0.74,0.78,0.85,true)
  end
  if type(tooltip.Show)=="function" then tooltip:Show() end
end
function B:CreateGearPage(page)
  panel(page,0,0,700,347)
  label(page,16,-10,650,23,"GameFontNormalLarge",
    "Equipement par paliers",WHITE)
  label(page,16,-34,660,19,"GameFontHighlightSmall",
    "Recompenses de quetes ou objets fabriques uniquement.",MUTED)
  page.items={}
  page.gearOffset=0
  page.displayed={}
  for i,item in ipairs(self.gear) do
    local y=-61-(i-1)*62
    local row=button(page,16,y,411,56,"",function()
      B.selectedItem=item.id
      B:Refresh()
    end)
    row.icon=row:CreateTexture(nil,"ARTWORK")
    row.icon:SetPoint("TOPLEFT",row,"TOPLEFT",10,-8)
    row.icon:SetSize(40,40)
    row.icon:SetTexture(itemIcon(item.id))
    row.name=label(row,60,-5,342,23,"GameFontNormal","",WHITE)
    row.detail=label(row,60,-29,342,20,"GameFontHighlightSmall","",MUTED)
    row:SetScript("OnEnter",function()
      row.bg:SetVertexColor(0.24,0.29,0.34,1)
      B:TooltipItem(row,item)
    end)
    row:SetScript("OnLeave",function()
      dismissTip()
      B:RefreshGear()
    end)
    page.items[item.id]=row
  end
  panel(page,439,-61,244,238)
  page.previewIcon=page:CreateTexture(nil,"ARTWORK")
  page.previewIcon:SetPoint("TOPLEFT",page,"TOPLEFT",455,-78)
  page.previewIcon:SetSize(42,42)
  page.previewName=label(page,505,-76,165,44,"GameFontNormal","",WHITE)
  page.previewLevel=label(page,455,-130,211,21,"GameFontHighlightSmall","",GOLD)
  page.previewSource=label(page,455,-153,213,30,"GameFontHighlightSmall","",MUTED)
  page.previewDescription=label(page,455,-187,209,110,
    "GameFontHighlightSmall","",WHITE)
  if page.previewDescription.SetWordWrap then
    page.previewDescription:SetWordWrap(true)
  end
  page.gearStatus=label(page,18,-318,288,27,"GameFontHighlightSmall","",GOLD)
  page.moreButton=button(page,313,-312,179,31,"Autres paliers",function()
    local count=#B.gear
    page.gearOffset=(page.gearOffset+4)%math.max(1,count)
    B:RefreshGear()
  end)
  page.gotoButton=button(page,502,-312,181,31,"Voir dans Parcours",function()
    if B.selectedItem and B:GoToGear(B.selectedItem) then
      B:ShowPage("parcours")
    end
  end)
end
function B:CreateRoutePage(page)
  panel(page,0,0,700,347)
  label(page,16,-8,340,26,"GameFontNormalLarge","Parcours de progression",WHITE)
  page.count=label(page,367,-8,311,26,"GameFontHighlightSmall","",MUTED)
  -- Une grande carte active, puis les etapes suivantes : lecture PexGuide.
  page.activeBg=rect(page,15,-39,669,109,CARD)
  page.activeAccent=rect(page,15,-39,3,109,GOLD)
  page.zone=label(page,30,-46,625,25,"GameFontNormal","",GOLD)
  page.note=label(page,30,-72,627,66,"GameFontHighlight","",WHITE)
  if page.note.SetWordWrap then page.note:SetWordWrap(true) end
  label(page,18,-150,300,22,"GameFontNormal","ETAPES SUIVANTES",MUTED)
  page.rows={}
  for i=1,4 do
    local row=button(page,16,-177-(i-1)*34,669,31,"",function()
      local index=(B.routeWindowStart or 1)+i-1
      if B.chapterMode then
        if B.chapters[index] then B.selectedChapter=index B:Refresh() end
      else
        local route=B:OrderedRoute()
        if route[index] then B.routeIndex=index B:Refresh() end
      end
    end)
    row.num=label(row,10,-2,31,27,"GameFontHighlightSmall","",GOLD)
    row.name=label(row,47,-2,480,27,"GameFontHighlight","",WHITE)
    row.state=label(row,534,-2,128,27,"GameFontHighlightSmall","",MUTED)
    page.rows[i]=row
  end
  page.previous=button(page,16,-317,98,27,"Precedent",function()
    if B.chapterMode then
      B.selectedChapter=math.max(1,(B.selectedChapter or 1)-1)
    else B.routeIndex=math.max(1,(B:FocusRoute() or 1)-1) end
    B:Refresh()
  end)
  page.next=button(page,125,-317,97,27,"Suivant",function()
    if B.chapterMode then
      B.selectedChapter=math.min(#B.chapters,(B.selectedChapter or 1)+1)
    else B.routeIndex=math.min(#B:OrderedRoute(),(B:FocusRoute() or 1)+1) end
    B:Refresh()
  end)
  page.done=button(page,486,-317,198,27,"Marquer comme fait",function()
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
  local tabs={{"talents","Talents"},{"equipement","Equipement"},
    {"parcours","Parcours"},{"rotation","Rotation"}}
  for i,tab in ipairs(tabs) do
    local key=tab[1]
    local b=button(f,22+(i-1)*180,-50,174,35,tab[2],function()
      B:ShowPage(key)
    end)
    self.tabs[key]=b
  end
  self.pages={}
  for _,key in ipairs({"talents","equipement","parcours","rotation"}) do
    local page=CreateFrame("Frame",nil,f)
    page:SetPoint("TOPLEFT",f,"TOPLEFT",30,-96)
    page:SetSize(700,347)
    self.pages[key]=page
  end
  self:CreateTalentPage(self.pages.talents)
  self:CreateGearPage(self.pages.equipement)
  self:CreateRoutePage(self.pages.parcours)
  if self.CreateRotationPage then
    self:CreateRotationPage(self.pages.rotation)
  end
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
  local selectedTree=self.selectedTree or "Furie"
  local point=self:TalentPointAt(self.viewLevel)
  for _,treeName in ipairs(self.talentTreeOrder) do
    local tree=page.trees[treeName]
    local tab=page.treeTabs[treeName]
    local visible=treeName==selectedTree
    if visible then tree.frame:Show() else tree.frame:Hide() end
    local color=visible and GOLD or CARD
    tab.bg:SetVertexColor(color[1],color[2],color[3],color[4])
    if tab.txt.SetTextColor then
      tab.txt:SetTextColor(visible and 0.12 or 0.93,
        visible and 0.15 or 0.94,visible and 0.21 or 0.97)
    end
    for _,node in ipairs(self.talentTrees[treeName]) do
      local b=tree.nodes[node[1]]
      local rank=plan.ranks[node[1]] or 0
      b.rank:SetText(rank.."/"..node[4])
      local c=rank>0 and {0.21,0.26,0.30,1} or CARD
      b.bg:SetVertexColor(c[1],c[2],c[3],c[4])
      local active=point and point.tree==treeName and point.key==node[1]
      for _,edge in ipairs(b.edges) do
        edge:SetVertexColor(GOLD[1],GOLD[2],GOLD[3],active and 1 or 0)
      end
      if b.rank.SetTextColor then
        b.rank:SetTextColor(active and 1 or 0.69,
          active and 0.77 or 0.74,active and 0.36 or 0.81)
      end
    end
  end
  page.nodes=page.trees[selectedTree].nodes
  page.connections=page.trees[selectedTree].connections
  local distribution=string.format("Armes %d / Furie %d / Protection %d",
    plan.pointsByTree.Armes or 0,plan.pointsByTree.Furie or 0,
    plan.pointsByTree.Protection or 0)
  page.levelPoint:SetText(point and
    ("Niveau "..point.level.." - "..point.tree.."\n"..
      textWithFallback(point.metadata).."  ("..point.rank.."/"..
      point.metadata[4]..")")
    or "Aucun point avant le niveau 10")
  local nextKey=plan.nextKey
  local nextNode=nextKey and plan.metadata[nextKey]
  page.nextLabel:SetText((nextNode and
    ("Prochain point : "..textWithFallback(nextNode)..
      " ("..(plan.nextTree or "Furie")..")")
      or "Plan termine au niveau 60").."\n"..distribution)
  local selected=plan.metadata[self.selectedTalent or
    (point and point.tree==selectedTree and point.key) or
    (plan.nextTree==selectedTree and nextKey) or
    self.talentTrees[selectedTree][1][1]]
  if selected then
    local rank=plan.ranks[selected[1]] or 0
    local dep=self.talentDependencies[selected[1]]
    page.desc:SetText(textWithFallback(selected).."\n\nRang : "..rank.."/"..
      selected[4].."\nPalier "..selected[2].." | Colonne "..selected[3]..
      (dep and ("\nRequis : "..dep[1].." "..dep[2].." rang(s)") or "")..
      "\n\n"..(self:TalentHint(selected[1],math.max(1,rank)) or
        "Survole l'icone pour plus de details."))
  end
end
function B:RefreshGear()
  local page=self.pages and self.pages.equipement
  if not page then return end
  local level=self.viewLevel
  self.selectedItem=self.selectedItem or self.gear[1].id
  local ordered=self:GearListAt(level)
  local start=(page.gearOffset or 0)+1
  if start>#ordered then
    start=1
    page.gearOffset=0
  end
  local shown={}
  page.displayed={}
  for pos=1,4 do
    local item=ordered[start+pos-1]
    if item then
      shown[item.id]=pos
      page.displayed[pos]=item
    end
  end
  local current=nil
  for _,item in ipairs(self.gear) do
    local row=page.items[item.id]
    local pos=shown[item.id]
    if pos then
      row:ClearAllPoints()
      row:SetPoint("TOPLEFT",page,"TOPLEFT",16,-61-(pos-1)*62)
      row:Show()
      row.icon:SetTexture(itemIcon(item.id))
      row.name:SetText(itemName(item))
      local levelLabel=item.requiredLevel and
        ("Niv. requis "..item.requiredLevel) or
        ("Quete min. "..item.minLevel)
      row.detail:SetText(item.slot.."  |  "..levelLabel.."  |  "..
        (item.source=="quest" and "Quete" or "Forge")..
        (item.group and " (GROUPE)" or ""))
      local selected=self.selectedItem==item.id
      local eligible=self:ItemEligible(item,level)
      local color=selected and {0.28,0.30,0.32,1} or
        (eligible and CARD or {0.14,0.16,0.18,1})
      row.bg:SetVertexColor(color[1],color[2],color[3],color[4])
      if row.name.SetTextColor then
        row.name:SetTextColor(selected and GOLD[1] or WHITE[1],
          selected and GOLD[2] or WHITE[2],
          selected and GOLD[3] or WHITE[3])
      end
    else
      row:Hide()
    end
    if self.selectedItem==item.id then current=item end
  end
  if current then
    local eligible,reason=self:ItemEligible(current,level)
    page.previewIcon:SetTexture(itemIcon(current.id))
    page.previewName:SetText(itemName(current))
    page.previewLevel:SetText(current.requiredLevel and
      ("Niveau requis : "..current.requiredLevel) or
      ("Acces quete des le niv. "..current.minLevel))
    local source=current.source=="quest" and
      ("Quete #"..current.questId..(current.group and " | Groupe" or ""))
      or ("Forge "..current.skill.." | Recette #"..current.recipe)
    page.previewSource:SetText(source)
    page.previewDescription:SetText((self.gearDescriptions[current.id] or
      current.note or "Fiche indisponible.")..
      "\n\n"..self:GearRelevance(current,level).."\n"..reason)
    page.gearStatus:SetText(eligible and
      "Cible potentielle : comparer les statistiques en jeu."
      or ("Non accessible : "..reason))
  end
  page.moreButton.txt:SetText((start+3>=#ordered) and
    "Retour aux cibles" or ("Paliers suivants ("..start.."/"..#ordered..")"))
end
local function routeText(text,maxLen)
  if type(text)~="string" then return "" end
  if #text>maxLen then return text:sub(1,maxLen-3).."..." end
  return text
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
  page.count:SetText("PLAN 1-60 | Chapitres indicatifs")
  page.zone:SetText("Niveaux "..chapter[1].."-"..chapter[2].."  |  "..chapter[3])
  page.note:SetText(chapter[4]..
    "\nEtapes de quetes non encore validees pour ce chapitre.")
  page.activeAccent:SetVertexColor(MUTED[1],MUTED[2],MUTED[3],1)
  local start=math.max(1,math.min(#self.chapters-3,index+1))
  self.routeWindowStart=start
  for j,row in ipairs(page.rows) do
    local c=self.chapters[start+j-1]
    if c then
      row:Show()
      row.num:SetText(tostring(start+j-1))
      row.name:SetText(routeText(c[1].."-"..c[2].."  "..c[3],70))
      row.state:SetText("APERÇU")
      row.bg:SetVertexColor(CARD[1],CARD[2],CARD[3],1)
    else row:Hide() end
  end
  page.done.txt:SetText("Non disponible")
end
function B:RefreshRoute()
  self.chapterMode=(self.viewLevel<30 or self.viewLevel>40)
    and not self.routeForced
  if self.chapterMode then self:RefreshChapters() return end
  self.selectedChapter=nil
  local page=self.pages and self.pages.parcours
  if not page then return end
  local ordered=self:OrderedRoute()
  local i=self:FocusRoute()
  if not i then return end
  local step=ordered[i].step
  local state=self:StepState(step)
  page.count:SetText("Pilote 30-40  |  "..i.."/"..#ordered)
  page.zone:SetText("Niv. "..step.level.."  |  "..step.zone.."   ["..state.."]")
  local link=""
  if step.gearId then
    for _,item in ipairs(self.gear) do
      if item.id==step.gearId then
        link="\nEquipement : "..item.name
        break
      end
    end
  end
  page.note:SetText(step.text.."\n"..(step.note or "")..link)
  page.activeAccent:SetVertexColor(GOLD[1],GOLD[2],GOLD[3],1)
  local start=math.min(#ordered+1,i+1)
  self.routeWindowStart=start
  for j,row in ipairs(page.rows) do
    local entry=ordered[start+j-1]
    if entry then
      row:Show()
      local nextStep=entry.step
      row.num:SetText(tostring(start+j-1))
      row.name:SetText(routeText(nextStep.text,77))
      row.state:SetText(self:StepState(nextStep))
      row.bg:SetVertexColor(CARD[1],CARD[2],CARD[3],1)
    else row:Hide() end
  end
  if step.group or step.level>(self.realLevel or 1) then
    page.done.txt:SetText("Option / plus tard")
  elseif self.db and self.db.done and self.db.done[step.id] then
    page.done.txt:SetText("Retirer validation")
  else
    page.done.txt:SetText("Marquer comme fait")
  end
end
function B:Refresh()
  if not self.frame then return end
  self.levelText:SetText("Niv "..(self.viewLevel or "?")..
    (self.mode=="preview" and " (apercu)" or ""))
  self:RefreshTalents()
  self:RefreshGear()
  self:RefreshRoute()
  if self.RefreshRotation then self:RefreshRotation() end
  self.footer:SetText("Pilote 30-40 : sources verifiees pour les objets ; route et DPS a tester en jeu.  "..self.dataVersion)
end
