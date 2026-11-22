local _, WC = ...
-- Presentation compacte du parcours, inspiree des principes UX du
-- tracker PexGuide : cartes lisibles, etape active, prochaines actions,
-- progression. Aucun fichier graphique tiers ni logique de quetes copie.
local C={
  bg={0.067,0.075,0.094,0.97},
  card={0.122,0.133,0.165,0.98},
  active={0.175,0.185,0.205,1},
  border={0.26,0.29,0.34,1},
  gold={1,0.784,0.341,1},
  white={0.93,0.94,0.96,1},
  muted={0.58,0.61,0.68,1},
  green={0.40,0.85,0.52,1},
}
local FONT=STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF"
local function rect(parent,x,y,w,h,color)
  local t=parent:CreateTexture(nil,"ARTWORK")
  t:SetTexture("Interface\\Buttons\\WHITE8X8")
  t:SetPoint("TOPLEFT",parent,"TOPLEFT",x,y)
  t:SetSize(w,h)
  t:SetVertexColor(color[1],color[2],color[3],color[4])
  return t
end
local function label(parent,x,y,w,h,sz,color)
  local fs=parent:CreateFontString(nil,"OVERLAY","GameFontHighlight")
  fs:SetPoint("TOPLEFT",parent,"TOPLEFT",x,y)
  fs:SetWidth(w)
  fs:SetHeight(h)
  fs:SetJustifyH("LEFT")
  fs:SetJustifyV("MIDDLE")
  if fs.SetFont then fs:SetFont(FONT,sz,"") end
  if fs.SetTextColor then
    fs:SetTextColor(color[1],color[2],color[3],color[4])
  end
  if fs.SetWordWrap then fs:SetWordWrap(false) end
  return fs
end
local function cleanText(value)
  if type(value)~="string" then return "" end
  return value:gsub("|c%x%x%x%x%x%x%x%x",""):gsub("|r","")
end
function WC:CreateGuideTracker(page)
  if self.guideTracker then return end
  local root=CreateFrame("Frame",nil,page)
  root:SetSize(570,255)
  root:SetPoint("TOPLEFT",page,"TOPLEFT",24,-91)
  rect(root,0,0,570,255,C.bg)
  root.heading=label(root,10,-5,450,23,14,C.white)
  root.count=label(root,464,-5,98,23,11,C.muted)
  rect(root,10,-31,550,1,C.border)
  root.rows={}
  local positions={-39,-108,-149,-190}
  for n=1,4 do
    local row=CreateFrame("Frame",nil,root)
    local height=n==1 and 65 or 37
    row:SetSize(548,height)
    row:SetPoint("TOPLEFT",root,"TOPLEFT",11,positions[n])
    row.bg=rect(row,0,0,548,height,C.card)
    row.accent=rect(row,0,0,3,height,C.border)
    row.number=label(row,12,-5,30,height-10,n==1 and 14 or 12,C.muted)
    row.title=label(row,48,-5,488,height-10,n==1 and 13 or 12,C.white)
    if row.title.SetWordWrap then row.title:SetWordWrap(true) end
    root.rows[n]=row
  end
  root.location=label(root,12,-230,540,17,11,C.muted)
  root.progressBack=rect(root,12,-250,546,4,C.border)
  root.progressFill=rect(root,12,-250,1,4,C.gold)
  self.guideTracker=root
  root:Hide()
end
function WC:RefreshGuideTracker()
  local root=self.guideTracker
  if not root then return end
  local guide=self.activeGuide
  local current=self.guideIndex
  if not guide or type(guide.steps)~="table" or not current then
    root.heading:SetText("Aucun parcours charge")
    root.count:SetText("")
    root.location:SetText("Ouvre GUIDE pour choisir un parcours disponible.")
    for _,row in ipairs(root.rows) do row:Hide() end
    root.progressFill:SetWidth(1)
    return
  end
  local total=#guide.steps
  if total<1 then return end
  current=math.max(1,math.min(total,current))
  root.heading:SetText(guide.title or "Guide Horde")
  root.count:SetText(current.." / "..total)
  -- On garde l'etape actuelle en premier : aucun espace gache.
  for i,row in ipairs(root.rows) do
    local index=current+i-1
    local step=guide.steps[index]
    if step then
      row:Show()
      row.number:SetText(tostring(index))
      local content=self.GuideStepText and self:GuideStepText(step)
        or step.text or ""
      row.title:SetText(cleanText(content))
      local active=i==1
      local color=active and C.active or C.card
      row.bg:SetVertexColor(color[1],color[2],color[3],color[4])
      local accent=active and C.gold or C.border
      row.accent:SetVertexColor(accent[1],accent[2],accent[3],accent[4])
      if row.title.SetTextColor then
        local col=active and C.white or C.muted
        row.title:SetTextColor(col[1],col[2],col[3],col[4])
      end
      if row.number.SetTextColor then
        local col=active and C.gold or C.muted
        row.number:SetTextColor(col[1],col[2],col[3],col[4])
      end
    else row:Hide() end
  end
  local view=self.GetGuideView and self:GetGuideView()
  root.location:SetText("Position : "..(view and view.locationText or "non precisee"))
  root.progressFill:SetWidth(math.max(1,math.floor(546*current/total)))
end
