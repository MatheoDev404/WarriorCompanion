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
  -- Trois arbres visibles simultanement, aucune zone de texte superflue.
  page.trees={}
  page.treeHeadings={}
  local width,spacing=226,10
  for i,treeName in ipairs(self.talentTreeOrder) do
    local left=(i-1)*(width+spacing)
    panel(page,left,0,width,305)
    page.treeHeadings[treeName]=label(page,left+12,-4,width-20,27,
      "GameFontNormalLarge",treeName,WHITE)
    local holder=CreateFrame("Frame",nil,page)
    holder:SetPoint("TOPLEFT",page,"TOPLEFT",left,-34)
    holder:SetSize(width,270)
    local tree={frame=holder,nodes={},connections={}}
    page.trees[treeName]=tree
    local positions={}
    for _,node in ipairs(self.talentTrees[treeName]) do
      positions[node[1]]=node
    end
    -- Relations visibles dans les trois panneaux, pas seulement Furie.
    for _,link in ipairs(self.talentArrows[treeName] or {}) do
      local from,to=positions[link[1]],positions[link[2]]
      if from and to and from[3]==to[3] then
        local x=14+(from[3]-1)*52+14
        local y=-8-(from[2]-1)*37-26
        local length=math.max(2,(to[2]-from[2])*37-10)
        local line=holder:CreateTexture(nil,"ARTWORK")
        line:SetTexture("Interface\\Buttons\\WHITE8X8")
        line:SetPoint("TOPLEFT",holder,"TOPLEFT",x,y)
        line:SetSize(2,length)
        line:SetVertexColor(GOLD[1],GOLD[2],GOLD[3],0.6)
        tree.connections[#tree.connections+1]=line
      end
    end
    for _,node in ipairs(self.talentTrees[treeName]) do
      local x=14+(node[3]-1)*52
      local y=-8-(node[2]-1)*37
      local b=CreateFrame("Button",nil,holder)
      b:SetPoint("TOPLEFT",holder,"TOPLEFT",x,y)
      b:SetSize(38,35)
      b.bg=rect(b,0,0,30,28,CARD)
      b.edges={
        rect(b,0,0,30,2,GOLD),rect(b,0,-26,30,2,GOLD),
        rect(b,0,0,2,28,GOLD),rect(b,28,0,2,28,GOLD),
      }
      local icon=b:CreateTexture(nil,"ARTWORK")
      icon:SetPoint("TOPLEFT",b,"TOPLEFT",2,-2)
      icon:SetSize(26,24)
      local ok=pcall(icon.SetTexture,icon,node[6])
      if not ok then
        icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
      end
      b.icon=icon
      b.rank=label(b,-1,-27,38,11,"GameFontHighlightSmall","",MUTED)
      -- Marqueur visible meme quand plusieurs arbres sont compares.
      -- Investi (ambre), non investi (gris), point de niveau (or vif).
      b.allocatedMarker=b:CreateTexture(nil,"OVERLAY")
      b.allocatedMarker:SetTexture("Interface\\Buttons\\WHITE8X8")
      b.allocatedMarker:SetPoint("TOPLEFT",b,"TOPLEFT",28,-1)
      b.allocatedMarker:SetSize(7,7)
      b.allocatedMarker:SetVertexColor(0,0,0,0)
      b:SetScript("OnEnter",function() B:TooltipTalent(b,node) end)
      b:SetScript("OnLeave",dismissTip)
      tree.nodes[node[1]]=b
    end
  end
  page.nodes=page.trees.Furie.nodes
  page.connections=page.trees.Furie.connections
  page.variantButton=button(page,2,-310,294,31,
    "Plan : Furie pure",function()
      if B.planVariant=="hybrid" then
        B:SelectPlanVariant("fury")
      else
        B:SelectPlanVariant("hybrid")
      end
      B:Refresh()
    end)
  page.levelPoint=label(page,309,-309,387,18,
    "GameFontHighlightSmall","",GOLD)
  page.nextLabel=label(page,309,-325,387,17,
    "GameFontHighlightSmall","",MUTED)
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
    tooltip:AddLine("Niveau requis : "..(item.requiredLevel or item.minLevel),0.9,0.9,0.95)
    if item.requiredLevel and item.minLevel~=item.requiredLevel then
      tooltip:AddLine("Palier conseille pour la quete : "..item.minLevel,0.9,0.7,0.4)
    end
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
  label(page,16,-10,654,23,"GameFontNormalLarge",
    "Equipement par paliers",WHITE)
  label(page,16,-34,654,19,"GameFontHighlightSmall",
    "Quetes, Forge et butins de boss utiles au Guerrier Furie ; survol : fiche complete.",MUTED)
  page.items={}
  page.gearOffset=0
  page.displayed={}
  local visibleRows=5
  local function orderedGear()
    local list=B:GearListAt(B.viewLevel)
    for _,item in ipairs(B:GearListAt(B.viewLevel,"future")) do
      list[#list+1]=item
    end
    return list
  end
  local function scrollGear(_,delta)
    if type(delta)~="number" then return end
    local list=orderedGear()
    local maximum=math.max(0,#list-visibleRows)
    page.gearOffset=math.max(0,math.min(maximum,
      (page.gearOffset or 0)-(delta>0 and 1 or -1)))
    B:RefreshGear()
  end
  if type(page.EnableMouseWheel)=="function" then page:EnableMouseWheel(true) end
  page:SetScript("OnMouseWheel",scrollGear)
  for _,item in ipairs(self.gear) do
    local row=button(page,16,-61,650,47,"",function()
      B.selectedItem=item.id
      B:RefreshGear()
    end)
    row.icon=row:CreateTexture(nil,"ARTWORK")
    row.icon:SetPoint("TOPLEFT",row,"TOPLEFT",8,-7)
    row.icon:SetSize(34,34)
    row.icon:SetTexture(itemIcon(item.id))
    row.name=label(row,49,-4,588,21,"GameFontNormal","",WHITE)
    row.detail=label(row,49,-25,588,18,"GameFontHighlightSmall","",MUTED)
    if type(row.EnableMouseWheel)=="function" then row:EnableMouseWheel(true) end
    row:SetScript("OnMouseWheel",scrollGear)
    row:SetScript("OnEnter",function()
      row.bg:SetVertexColor(0.25,0.29,0.34,1)
      B:TooltipItem(row,item)
    end)
    row:SetScript("OnLeave",function()
      dismissTip()
      B:RefreshGear()
    end)
    row:Hide()
    page.items[item.id]=row
  end
  page.gearStatus=label(page,18,-315,288,27,
    "GameFontHighlightSmall","",GOLD)
  page.scrollHint=label(page,313,-315,190,24,
    "GameFontHighlightSmall","Molette : faire defiler",MUTED)
  page.scrollTrack=rect(page,675,-61,5,240,{0.26,0.29,0.32,1})
  page.scrollThumb=rect(page,675,-61,5,70,GOLD)
  local slider=CreateFrame("Slider",nil,page)
  if type(slider.SetOrientation)=="function" and
      type(slider.SetMinMaxValues)=="function" and
      type(slider.SetThumbTexture)=="function" then
    slider:SetPoint("TOPLEFT",page,"TOPLEFT",671,-61)
    slider:SetSize(13,240)
    slider:SetOrientation("VERTICAL")
    slider:SetMinMaxValues(0,0)
    if type(slider.SetValueStep)=="function" then slider:SetValueStep(1) end
    slider:SetThumbTexture("Interface\\Buttons\\WHITE8X8")
    local thumb=type(slider.GetThumbTexture)=="function" and
      slider:GetThumbTexture() or nil
    if thumb and type(thumb.SetVertexColor)=="function" then
      thumb:SetVertexColor(GOLD[1],GOLD[2],GOLD[3],1)
    end
    page.scrollBar=slider
    if type(page.scrollThumb.Hide)=="function" then page.scrollThumb:Hide() end
    slider:SetScript("OnValueChanged",function(_,value)
      if page.updatingScroll or type(value)~="number" then return end
      page.gearOffset=math.max(0,math.floor(value+0.5))
      B:RefreshGear()
    end)
  end
  page.gotoButton=button(page,502,-310,181,31,"Voir dans Parcours",function()
    if B.selectedItem and B:GoToGear(B.selectedItem) then
      B:ShowPage("parcours")
    end
  end)
end
-- Marqueurs explicites : distinguent XP, amelioration facultative et donjon.
local function routeBadge(step)
  if not step then return "APERCU",MUTED end
  if step.gearId then return "EQUIPEMENT",{0.87,0.67,0.97,1} end
  if step.group then return "GROUPE",RED end
  if step.kind=="craft" then return "FORGE",GOLD end
  if step.kind=="train" then return "MAITRE",{0.55,0.78,0.98,1} end
  if step.optional then return "OPTION",{0.95,0.74,0.39,1} end
  if step.kind=="quest" then return "QUETE XP",GREEN end
  return "TRAJET",{0.61,0.77,0.96,1}
end
function B:CreateRoutePage(page)
  panel(page,0,0,700,347)
  page.segmentLabel=label(page,13,-5,272,28,"GameFontNormalLarge",
    "Parcours par segment",WHITE)
  page.prevSegment=button(page,288,-5,90,27,"< Tranche",function()
    B:SelectRouteSegment(math.max(1,B:CurrentRouteSegment()-1))
    B:RefreshRoute()
  end)
  page.nextSegment=button(page,384,-5,91,27,"Tranche >",function()
    B:SelectRouteSegment(math.min(#B.levelSegments,B:CurrentRouteSegment()+1))
    B:RefreshRoute()
  end)
  page.count=label(page,483,-5,205,27,"GameFontHighlightSmall","",MUTED)
  page.activeBg=rect(page,13,-39,673,101,CARD)
  page.activeAccent=rect(page,13,-39,3,101,GOLD)
  page.zone=label(page,27,-43,474,23,"GameFontNormal","",GOLD)
  page.activeKind=label(page,520,-43,158,23,"GameFontNormal","",GREEN)
  page.note=label(page,27,-68,642,67,"GameFontHighlight","",WHITE)
  if page.note.SetWordWrap then page.note:SetWordWrap(true) end
  page.listTitle=label(page,17,-144,350,23,"GameFontNormal",
    "OBJECTIFS DU SEGMENT",MUTED)
  page.toggleCompleted=button(page,505,-145,181,25,
    "Afficher les terminees",function()
      B.showCompleted=not B.showCompleted
      if B.db then B.db.showCompleted=B.showCompleted end
      B.routeScroll=0
      B:RefreshRoute()
    end)
  page.rows={}
  local function onWheel(_,delta)
    if type(delta)~="number" then return end
    B.routeScroll=math.max(0,(B.routeScroll or 0)-
      (delta>0 and 1 or -1))
    B:RefreshRoute()
  end
  page:SetScript("OnMouseWheel",onWheel)
  if type(page.EnableMouseWheel)=="function" then
    page:EnableMouseWheel(true)
  end
  for i=1,5 do
    local row=button(page,16,-174-(i-1)*27,656,25,"",function()
      local entry=B.routeVisible and B.routeVisible[(B.routeScroll or 0)+i]
      if entry then B.routeSelectedId=entry.step.id B:RefreshRoute() end
    end)
    row.marker=rect(row,0,0,3,25,GOLD)
    row.num=label(row,7,-2,36,22,"GameFontHighlightSmall","",GOLD)
    row.kind=label(row,43,-2,103,22,"GameFontHighlightSmall","",GREEN)
    row.name=label(row,145,-2,398,22,"GameFontHighlight","",WHITE)
    row.state=label(row,544,-2,106,22,"GameFontHighlightSmall","",MUTED)
    row:SetScript("OnMouseWheel",onWheel)
    if type(row.EnableMouseWheel)=="function" then row:EnableMouseWheel(true) end
    page.rows[i]=row
  end
  page.scrollTrack=rect(page,680,-174,4,134,{0.28,0.31,0.35,1})
  page.scrollThumb=rect(page,680,-174,4,32,GOLD)
  local slider=CreateFrame("Slider",nil,page)
  if type(slider.SetOrientation)=="function" and
      type(slider.SetMinMaxValues)=="function" and
      type(slider.SetThumbTexture)=="function" then
    slider:SetPoint("TOPLEFT",page,"TOPLEFT",675,-174)
    slider:SetSize(14,134)
    slider:SetOrientation("VERTICAL")
    slider:SetMinMaxValues(0,0)
    if type(slider.SetValueStep)=="function" then slider:SetValueStep(1) end
    slider:SetThumbTexture("Interface\\Buttons\\WHITE8X8")
    local thumb=type(slider.GetThumbTexture)=="function" and
      slider:GetThumbTexture() or nil
    if thumb and type(thumb.SetVertexColor)=="function" then
      thumb:SetVertexColor(GOLD[1],GOLD[2],GOLD[3],1)
    end
    page.scrollBar=slider
    if type(page.scrollThumb.Hide)=="function" then page.scrollThumb:Hide() end
    slider:SetScript("OnValueChanged",function(_,value)
      if page.updatingScroll or type(value)~="number" then return end
      B.routeScroll=math.max(0,math.floor(value+0.5))
      B:RefreshRoute()
    end)
  end
  page.nextAvailable=button(page,16,-317,184,27,"Objectif conseille",function()
    B.routeSelectedId=nil
    B.routeScroll=0
    B:RefreshRoute()
  end)
  page.scrollHint=label(page,208,-317,266,27,
    "GameFontHighlightSmall","",MUTED)
  page.done=button(page,492,-317,194,27,"Marquer comme fait",function()
    local selected=B.activeRouteStep
    if selected then B:MarkRouteSelection(selected) end
    B:RefreshRoute()
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
  button(f,681,-7,62,28,"Fermer",function() B:CloseFull() end)
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
  local point=self:TalentPointAt(self.viewLevel)
  for _,treeName in ipairs(self.talentTreeOrder) do
    local tree=page.trees[treeName]
    tree.frame:Show()
    local allocated=plan.pointsByTree[treeName] or 0
    page.treeHeadings[treeName]:SetText(treeName.."  "..allocated.." pts")
    for _,node in ipairs(self.talentTrees[treeName]) do
      local b=tree.nodes[node[1]]
      local rank=plan.ranks[node[1]] or 0
      b.rank:SetText(rank.."/"..node[4])
      local invested=rank>0
      local active=point and point.tree==treeName and point.key==node[1]
      local color=active and {0.58,0.37,0.12,1} or
        (invested and {0.39,0.29,0.17,1} or {0.11,0.13,0.16,1})
      b.bg:SetVertexColor(color[1],color[2],color[3],color[4])
      if b.icon.SetDesaturated then b.icon:SetDesaturated(not invested) end
      if b.icon.SetVertexColor then
        local bright=invested and 1 or 0.42
        b.icon:SetVertexColor(bright,bright,bright,1)
      end
      for _,edge in ipairs(b.edges) do
        edge:SetVertexColor(active and 1 or 0.84,
          active and 0.85 or 0.57,
          active and 0.27 or 0.21,
          active and 1 or (invested and 0.96 or 0))
      end
      b.allocatedMarker:SetVertexColor(active and 1 or 0.88,
        active and 0.89 or 0.63,active and 0.21 or 0.34,
        invested and 1 or 0)
      if b.rank.SetTextColor then
        b.rank:SetTextColor(active and 1 or (invested and 0.99 or 0.57),
          active and 0.90 or (invested and 0.75 or 0.62),
          active and 0.35 or (invested and 0.40 or 0.67))
      end
    end
  end
  page.nodes=page.trees.Furie.nodes
  page.connections=page.trees.Furie.connections
  page.variantButton.txt:SetText(self.talentPlanLabels[self.planVariant or "fury"])
  local pointNode=point and point.metadata
  page.levelPoint:SetText(point and
    ("Niv "..point.level.." : "..textWithFallback(pointNode)..
      " ("..point.rank.."/"..pointNode[4]..")")
    or "Aucun point avant le niveau 10")
  local nextNode=plan.nextKey and plan.metadata[plan.nextKey]
  page.nextLabel:SetText(nextNode and
    ("Ensuite : "..textWithFallback(nextNode).." ("..plan.nextTree..")")
    or "Tous les points sont places")
end
function B:RefreshGear()
  local page=self.pages and self.pages.equipement
  if not page then return end
  local level=self.viewLevel
  local ordered=self:GearListAt(level)
  local availableCount=#ordered
  for _,item in ipairs(self:GearListAt(level,"future")) do
    ordered[#ordered+1]=item
  end
  local count=#ordered
  local visibleRows=5
  local maxOffset=math.max(0,count-visibleRows)
  page.gearOffset=math.max(0,math.min(page.gearOffset or 0,maxOffset))
  local start=page.gearOffset+1
  local shown={}
  page.displayed={}
  for pos=1,visibleRows do
    local item=ordered[start+pos-1]
    if item then shown[item.id]=pos page.displayed[pos]=item end
  end
  if not self.selectedItem or not shown[self.selectedItem] then
    self.selectedItem=page.displayed[1] and page.displayed[1].id or nil
  end
  for _,item in ipairs(self.gear) do
    local row=page.items[item.id]
    local pos=shown[item.id]
    if pos then
      row:ClearAllPoints()
      row:SetPoint("TOPLEFT",page,"TOPLEFT",16,-61-(pos-1)*49)
      row:Show()
      row.icon:SetTexture(itemIcon(item.id))
      row.name:SetText(itemName(item))
      local eligible=self:ItemEligible(item,level)
      local levelLabel=item.requiredLevel and
        ("Niv. requis "..item.requiredLevel) or
        ("Quete min. "..item.minLevel)
      local source=item.source=="dungeon" and
        ("Donjon : "..(item.boss or "boss")) or
        (item.source=="quest" and "Quete" or "Forge")
      row.detail:SetText((not eligible and "PLUS TARD  |  " or "")..
        item.slot.."  |  "..levelLabel.."  |  "..source..
        (item.dps and ("  |  "..string.format("%.1f",item.dps).." DPS") or "")..
        (item.group and "  [GROUPE]" or ""))
      local selected=self.selectedItem==item.id
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
  end
  if not self.selectedItem then
    page.gearStatus:SetText("Aucun objet valide pour ce palier.")
  else
    local chosen=nil
    for _,item in ipairs(self.gear) do
      if item.id==self.selectedItem then chosen=item break end
    end
    if chosen and chosen.source=="dungeon" then
      page.gearStatus:SetText("Butin de boss facultatif, non garanti.")
    elseif chosen and chosen.source=="craft" then
      page.gearStatus:SetText("Forge : recette et materiaux dans Parcours.")
    else
      page.gearStatus:SetText("Quete : voir les objectifs dans Parcours.")
    end
  end
  page.scrollHint:SetText("Molette | "..(count==0 and "0/0" or
    (start.."-"..math.min(count,start+visibleRows-1).."/"..count))..
    " | "..availableCount.." actuels")
  if page.scrollBar then
    page.updatingScroll=true
    page.scrollBar:SetMinMaxValues(0,maxOffset)
    page.scrollBar:SetValue(page.gearOffset)
    page.updatingScroll=false
  end
  local height=240
  local thumb=count>0 and math.max(22,math.floor(
    height*math.min(visibleRows,count)/count)) or height
  page.scrollThumb:SetSize(5,thumb)
  if type(page.scrollThumb.ClearAllPoints)=="function" then
    page.scrollThumb:ClearAllPoints()
  end
  page.scrollThumb:SetPoint("TOPLEFT",page,"TOPLEFT",675,
    -61-math.floor((height-thumb)*(page.gearOffset/math.max(1,maxOffset))))
end
local function routeText(text,maxLen)
  if type(text)~="string" then return "" end
  if #text>maxLen then return text:sub(1,maxLen-3).."..." end
  return text
end
-- Segment toujours complet en memoire ; la fenetre ne montre que 5
-- lignes a la fois. Les quetes rendues sont filtrees sauf demande explicite.
function B:RefreshRoute()
  local page=self.pages and self.pages.parcours
  if not page then return end
  self.chapterMode=false
  local segmentIndex=self:CurrentRouteSegment()
  local segment=self.levelSegments[segmentIndex]
  local entries=self:RouteSegmentEntries(segmentIndex,self.showCompleted)
  local all=self:RouteSegmentEntries(segmentIndex,true)
  self.routeVisible=entries
  local doneCount=0
  for _,entry in ipairs(all) do
    if self:IsStepDone(entry.step) then doneCount=doneCount+1 end
  end
  page.segmentLabel:SetText("Segment "..segment[3])
  page.count:SetText((#all-doneCount).." restants / "..#all.." objectifs")
  page.toggleCompleted.txt:SetText(self.showCompleted and
    "Masquer les terminees" or "Afficher les terminees")
  local selected=nil
  if self.routeSelectedId then
    for _,entry in ipairs(entries) do
      if entry.step.id==self.routeSelectedId then
        selected=entry.step
        break
      end
    end
  end
  if not selected then
    selected=self:FirstSuggestedStep(entries)
    self.routeSelectedId=selected and selected.id or nil
  end
  self.activeRouteStep=selected
  if selected and self.routeForced then
    for index,entry in ipairs(entries) do
      if entry.step.id==selected.id then
        self.routeScroll=math.max(0,index-3)
        break
      end
    end
    self.routeForced=false
  end
  if selected then
    local state=self:StepState(selected)
    local tag,shade=routeBadge(selected)
    page.zone:SetText("Niv. "..selected.level.." | "..
      selected.zone.." ["..state.."]")
    page.activeKind:SetText(tag)
    page.activeKind:SetTextColor(shade[1],shade[2],shade[3])
    local gear=""
    if selected.gearId then
      for _,item in ipairs(self.gear) do
        if item.id==selected.gearId then
          gear=" | Gain : "..item.name
          break
        end
      end
    end
    local objective=selected.questId and
      self:QuestObjectiveSummary(selected.questId) or nil
    page.note:SetText(selected.text..
      "\n"..(objective and ("En cours : "..objective) or
        (selected.note or ""))..gear)
    page.activeAccent:SetVertexColor(shade[1],shade[2],shade[3],1)
    if selected.questId then
      page.done.txt:SetText("Suivi auto (journal)")
    elseif selected.group or selected.level>(self.realLevel or 1) then
      page.done.txt:SetText("Plus tard / option")
    elseif self.db and self.db.done and self.db.done[selected.id] then
      page.done.txt:SetText("Annuler validation")
    else
      page.done.txt:SetText("Marquer comme fait")
    end
  else
    page.zone:SetText("Aucun objectif actif dans cette tranche")
    page.activeKind:SetText("APERCU")
    page.activeKind:SetTextColor(MUTED[1],MUTED[2],MUTED[3])
    local chapter=nil
    for _,c in ipairs(self.chapters) do
      if c[2]>=segment[1] and c[1]<=segment[2] then
        chapter=c
        break
      end
    end
    if #all>0 and #entries==0 then
      page.note:SetText("Tous les objectifs suivis sont termines."..
        "\nActive « Afficher les terminees » pour les consulter.")
    elseif #all>0 then
      page.note:SetText("Aucun objectif XP solo prioritaire documente ici."..
        "\nLes options, donjons et objectifs futurs restent consultables."..
        "\nSelectionne une ligne pour voir ses conditions.")
    else
      page.note:SetText(chapter and
        ("Apercu : "..chapter[3].."\n"..chapter[4]..
          "\nQuetes individuelles non encore verifiees.") or
        "Cette tranche de niveaux reste a documenter.")
    end
    page.activeAccent:SetVertexColor(MUTED[1],MUTED[2],MUTED[3],1)
    page.done.txt:SetText("Aucun objectif")
  end
  local count=#entries
  local maxOffset=math.max(0,count-5)
  self.routeScroll=math.max(0,math.min(self.routeScroll or 0,maxOffset))
  local visibleStart=self.routeScroll+1
  for i,row in ipairs(page.rows) do
    local index=visibleStart+i-1
    local entry=entries[index]
    if entry then
      row:Show()
      local step=entry.step
      local tag,shade=routeBadge(step)
      row.num:SetText(tostring(step.level))
      row.kind:SetText(tag)
      row.kind:SetTextColor(shade[1],shade[2],shade[3])
      row.marker:SetVertexColor(shade[1],shade[2],shade[3],1)
      row.name:SetText(routeText(step.text,65))
      row.state:SetText(self:StepState(step))
      local active=selected and selected.id==step.id
      local color=active and {0.28,0.31,0.34,1} or CARD
      row.bg:SetVertexColor(color[1],color[2],color[3],color[4])
      if row.name.SetTextColor then
        row.name:SetTextColor(active and GOLD[1] or WHITE[1],
          active and GOLD[2] or WHITE[2],active and GOLD[3] or WHITE[3])
      end
    else
      row:Hide()
    end
  end
  page.scrollHint:SetText(count==0 and "0/0" or
    ("Molette : "..visibleStart.."-"..
      math.min(count,visibleStart+4).."/"..count))
  if page.scrollBar then
    page.updatingScroll=true
    page.scrollBar:SetMinMaxValues(0,maxOffset)
    page.scrollBar:SetValue(self.routeScroll)
    page.updatingScroll=false
  end
  local barSize=count>0 and math.max(20,math.floor(134*
    math.min(5,count)/count)) or 134
  page.scrollThumb:SetSize(4,barSize)
  if type(page.scrollThumb.ClearAllPoints)=="function" then
    page.scrollThumb:ClearAllPoints()
  end
  page.scrollThumb:SetPoint("TOPLEFT",page,"TOPLEFT",680,
    -174-math.floor((134-barSize)*(self.routeScroll/math.max(1,maxOffset))))
end
function B:Refresh()
  if not self.frame then return end
  self.levelText:SetText("Niv "..(self.viewLevel or "?")..
    (self.mode=="preview" and " (apercu)" or ""))
  self:RefreshTalents()
  self:RefreshGear()
  self:RefreshRoute()
  if self.RefreshRotation then self:RefreshRotation() end
end
