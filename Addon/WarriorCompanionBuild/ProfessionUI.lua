local _,B=...
-- Interface des guides de metiers sur la page Parcours existante.
-- Talents / Equipement / Rotations et boussole ne sont pas reimplementes.
local kit=B.uiKit
local GOLD=kit.GOLD
local WHITE=kit.WHITE
local MUTED=kit.MUTED
local GREEN={0.48,0.84,0.62,1}
local CARD=kit.CARD
local oldCreate=B.CreateRoutePage
local oldRefresh=B.RefreshRoute
local oldTooltip=B.TooltipRoute
local function brief(s,n)
 s=type(s)=="string" and s or ""
 if #s<=n then return s end
 local cut=s:sub(1,n-3)
 return (cut:match("^(.*)%s+") or cut).."..."
end
local guideNames={}
for _,g in ipairs(B:GuideRegistry()) do guideNames[g.id]=g.name end
function B:CreateRoutePage(page)
 oldCreate(self,page)
 -- Conserver les scripts et objets existants ; le selecteur s'affiche
 -- par-dessus l'ancien titre de segment en reprenant les boutons bronze.
 page.segmentLabel:Hide()
 page.guideSelector=kit.button(page,13,-5,268,27,
   "Guide : Leveling 1-60  v",function()
    if page.guideMenu:IsShown() then
      page.guideMenu:Hide()
    else
      page.guideMenu:Show()
    end
   end)
 local menu=CreateFrame("Frame",nil,page)
 menu:SetPoint("TOPLEFT",page,"TOPLEFT",13,-34)
 menu:SetSize(268,129)
 if type(menu.SetFrameStrata)=="function" then menu:SetFrameStrata("TOOLTIP") end
 if type(menu.SetFrameLevel)=="function" then menu:SetFrameLevel(50) end
 kit.rect(menu,0,0,268,129,kit.PANEL)
 page.guideOptions={}
 for i,guide in ipairs(self:GuideRegistry()) do
  page.guideOptions[guide.id]=kit.button(menu,5,-4-(i-1)*30,
    258,28,guide.name,function()
   B:SetActiveGuide(guide.id)
   menu:Hide()
   B:RefreshRoute()
  end)
 end
 menu:Hide()
 page.guideMenu=menu
 page.skillCaption=kit.label(page,27,-116,553,17,
   "GameFontHighlightSmall","",MUTED)
 page.skillBar1=kit.rect(page,27,-135,268,3,{.24,.27,.31,1})
 page.skillFill1=kit.rect(page,27,-135,0,3,GOLD)
 page.skillBar2=kit.rect(page,304,-135,268,3,{.24,.27,.31,1})
 page.skillFill2=kit.rect(page,304,-135,0,3,GREEN)
 page.skillCaption:Hide()
 page.skillBar1:Hide()
 page.skillFill1:Hide()
 page.skillBar2:Hide()
 page.skillFill2:Hide()
 -- Rediriger uniquement les commandes contextuelles vers le guide actif.
 for i,row in ipairs(page.rows) do
  row:SetScript("OnClick",function()
   local entry=B.routeVisible and B.routeVisible[(B.routeScroll or 0)+i]
   if not entry then return end
   B.routeSelectedId=entry.step.id
   if entry.step.profession then
    B:SaveGuideSelection()
   elseif entry.step.guide and B.AdaptiveChoose then
    B:AdaptiveChoose(entry.step,true)
   elseif entry.step.guide then
    B:GuideSelect(entry.step)
   end
   B:RefreshRoute()
  end)
 end
 page.done:SetScript("OnClick",function()
  local step=B.activeRouteStep
  if not step then return end
  if step.profession then
   B:ProfessionMarkStep(step)
  elseif step.guide then B:GuideMarkStep(step)
  else B:MarkRouteSelection(step) end
  B:RefreshRoute()
 end)
 page.nextAvailable:SetScript("OnClick",function()
  if B:ActiveGuide()=="leveling" then
   if B.AdaptiveResume then B:AdaptiveResume() end
  else
   local progress=B.db.professionProgress[B:ActiveGuide()]
   if progress then progress.selected=nil end
   B.routeSelectedId=nil
   B:RefreshProfessionObservations("BAG_UPDATE_DELAYED")
  end
  B.routeScroll=0
  B:RefreshRoute()
 end)
 page.toggleCompleted:SetScript("OnClick",function()
  if B:ActiveGuide()=="leveling" then
   B.showCompleted=not B.showCompleted
   if B.db then B.db.showCompleted=B.showCompleted end
  else
   local id=B:ActiveGuide()
   local progress=B.db.professionProgress[id] or {}
   progress.showCompleted=not progress.showCompleted
   B.db.professionProgress[id]=progress
  end
  B.routeScroll=0
  B:RefreshRoute()
 end)
end
function B:TooltipRoute(btn,step)
 if not step or not step.profession then return oldTooltip(self,btn,step) end
 if not GameTooltip or type(GameTooltip.SetOwner)~="function" then return end
 local tip=GameTooltip
 tip:SetOwner(btn,"ANCHOR_RIGHT")
 if type(tip.ClearLines)=="function" then tip:ClearLines() end
 if type(tip.AddLine)~="function" then return end
 tip:AddLine(step.text or "Objectif",1,.77,.34,true)
 tip:AddLine(step.help or "Informations non disponibles",.86,.9,.95,true)
 if type(tip.Show)=="function" then tip:Show() end
end
local function show(page,widget,active)
 if not widget then return end
 if active then widget:Show() else widget:Hide() end
end
local function progressBars(self,page,id)
 local caption,rankA,capA,rankB,capB=self:ProfessionProgressSummary(id)
 page.skillCaption:SetText(caption or "Compétences indisponibles")
 local sizeA=type(rankA)=="number" and
   math.max(0,math.min(268,268*rankA/300)) or 0
 page.skillFill1:SetSize(sizeA,3)
 if id=="combo" then
  local sizeB=type(rankB)=="number" and
    math.max(0,math.min(268,268*rankB/300)) or 0
  page.skillFill2:SetSize(sizeB,3)
  show(page,page.skillBar2,true)
  show(page,page.skillFill2,true)
 else
  show(page,page.skillBar2,false)
  show(page,page.skillFill2,false)
 end
 show(page,page.skillCaption,true)
 show(page,page.skillBar1,true)
 show(page,page.skillFill1,true)
end
local function renderProfession(self,page,id)
 local progress=self.db.professionProgress[id] or {}
 local entries=self:ProfessionEntries(id,progress.showCompleted==true)
 local all=self:ProfessionEntries(id,true)
 self.routeVisible=entries
 local selected=nil
 if self.routeSelectedId then
  for _,e in ipairs(entries) do
   if e.step.id==self.routeSelectedId then selected=e.step break end
  end
 end
 if not selected then
  selected=self:ProfessionSuggestedStep(entries)
  self.routeSelectedId=selected and selected.id or nil
 end
 self.activeRouteStep=selected
 if selected and self.routeForced then
  for n,e in ipairs(entries) do
   if e.step.id==selected.id then self.routeScroll=math.max(0,n-3) break end
  end
  self.routeForced=false
 end
 page.count:SetText(#entries.."/"..#all.." etapes")
 page.listTitle:SetText("OBJECTIFS METIERS")
 page.toggleCompleted.txt:SetText(progress.showCompleted and
   "Masquer terminees" or "Afficher terminees")
 page.nextAvailable.txt:SetText("Actualiser")
 page.done.txt:SetText("Valider / annuler")
 page.zone:SetText(self:ProfessionProgressSummary(id))
 page.activeKind:SetText(selected and selected.kind or "METIERS")
 page.activeKind:SetTextColor(GOLD[1],GOLD[2],GOLD[3])
 local display=selected and (selected.text.."\n"..(selected.help or "")) or
  "Tous les objectifs actuellement visibles sont termines."
 page.note:SetText(brief(display,220))
 page.activeAccent:SetVertexColor(GOLD[1],GOLD[2],GOLD[3],1)
 page.routeItem:Hide()
 if self.SetCompassTarget then self:SetCompassTarget(nil) end
 progressBars(self,page,id)
 local count=#entries
 local maximum=math.max(0,count-5)
 self.routeScroll=math.max(0,math.min(self.routeScroll or 0,maximum))
 for i,row in ipairs(page.rows) do
  local e=entries[self.routeScroll+i]
  if e then
   row:Show()
   local step=e.step
   row.num:SetText(tostring(step.goal or i))
   local kinds={gather="RECOLTE",craft="FORGE",smelt="FONTE",
      recipe="PLAN",trainer="MAITRE",check="SUIVI",
      complete="TERMINE"}
   row.kind:SetText(kinds[step.kind] or "ETAPE")
   row.kind:SetTextColor(GOLD[1],GOLD[2],GOLD[3])
   row.marker:SetVertexColor(GOLD[1],GOLD[2],GOLD[3],1)
   row.name:SetText(brief(step.text,62))
   row.state:SetText(e.state)
   local focus=selected and selected.id==step.id
   local c=focus and {.28,.31,.34,1} or CARD
   row.bg:SetVertexColor(c[1],c[2],c[3],c[4])
   row.name:SetTextColor(focus and GOLD[1] or WHITE[1],
     focus and GOLD[2] or WHITE[2],focus and GOLD[3] or WHITE[3])
  else row:Hide() end
 end
 page.scrollHint:SetText(count==0 and "0/0" or
   ((self.routeScroll+1).."-"..math.min(count,self.routeScroll+5)..
    "/"..count))
 if page.scrollBar then
  page.updatingScroll=true
  page.scrollBar:SetMinMaxValues(0,maximum)
  page.scrollBar:SetValue(self.routeScroll)
  page.updatingScroll=false
 end
 local size=count>0 and math.max(20,math.floor(134*
    math.min(5,count)/count)) or 134
 page.scrollThumb:SetSize(4,size)
 page.scrollThumb:ClearAllPoints()
 page.scrollThumb:SetPoint("TOPLEFT",page,"TOPLEFT",680,
   -174-math.floor((134-size)*(self.routeScroll/math.max(1,maximum))))
 self:SaveGuideSelection()
end
function B:RefreshRoute()
 local page=self.pages and self.pages.parcours
 if not page then return end
 local id=self:ActiveGuide()
 page.guideSelector.txt:SetText(brief("Guide : "..
   (guideNames[id] or id).."  v",38))
 page.segmentLabel:Hide()
 local leveling=id=="leveling"
 for _,widget in ipairs({page.prevSegment,page.nextSegment,page.modeButton,
    page.switchGuide}) do show(page,widget,leveling) end
 for _,widget in pairs(page.optionButtons) do show(page,widget,leveling) end
 if leveling then
  for _,widget in ipairs({page.skillCaption,page.skillBar1,
    page.skillFill1,page.skillBar2,page.skillFill2}) do widget:Hide() end
  page.listTitle:SetText("OBJECTIFS")
  return oldRefresh(self)
 end
 return renderProfession(self,page,id)
end
