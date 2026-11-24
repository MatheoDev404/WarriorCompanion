local addon,B=...
-- Bouton autonome autour de la minimap, sans LibDBIcon externe.
local floor,cos,sin,pi=math.floor,math.cos,math.sin,math.pi
local RADIUS=79
local function angleCoordinates(angle)
  local radians=angle*pi/180
  return floor(cos(radians)*RADIUS+0.5),
    floor(sin(radians)*RADIUS+0.5)
end
function B:UpdateMinimapButton()
  local button=self.minimapButton
  if not button then return end
  local angle=self.db and self.db.minimapAngle or nil
  angle=self.SafeNumber and self:SafeNumber(angle) or nil
  angle=angle or 225
  angle=angle%360
  local x,y=angleCoordinates(angle)
  if type(button.ClearAllPoints)=="function" then
    button:ClearAllPoints()
  end
  button:SetPoint("CENTER",Minimap,"CENTER",x,y)
  if self.db and self.db.minimapVisible==false then
    button:Hide()
  else
    button:Show()
  end
end
local function atan2(y,x)
  if type(math.atan2)=="function" then return math.atan2(y,x) end
  if type(_G.atan2)=="function" then return _G.atan2(y,x) end
  if x==0 then return y>=0 and pi/2 or -pi/2 end
  local result=math.atan(y/x)
  if x<0 then result=result+(y>=0 and pi or -pi) end
  return result
end
function B:CreateMinimapButton()
  if self.minimapButton then return self.minimapButton end
  if not Minimap or type(Minimap.GetCenter)~="function" or
      type(CreateFrame)~="function" then
    return nil
  end
  -- Apparence standard LibDBIcon/Questie : fond rond, icone 20px recadree,
  -- liseré dore natif. Aucune texture carrée 32px en NormalTexture.
  local b=CreateFrame("Button","WarriorCompanionBuildMinimap",Minimap)
  b:SetSize(31,31)
  b:SetFrameStrata("MEDIUM")
  if type(b.SetFrameLevel)=="function" then b:SetFrameLevel(8) end
  if type(b.SetHighlightTexture)=="function" then
    b:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
  end
  local background=b:CreateTexture(nil,"BACKGROUND")
  background:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
  background:SetSize(20,20)
  background:SetPoint("TOPLEFT",b,"TOPLEFT",7,-5)
  b.background=background
  local icon=b:CreateTexture(nil,"ARTWORK")
  icon:SetTexture("Interface\\Icons\\Ability_Warrior_BattleShout")
  icon:SetSize(20,20)
  icon:SetPoint("TOPLEFT",b,"TOPLEFT",7,-5)
  if type(icon.SetTexCoord)=="function" then
    icon:SetTexCoord(0.05,0.95,0.05,0.95)
  end
  -- Masque rond sur les versions qui l'autorisent ; sinon une icone
  -- recadree de 20px reste contenue dans la bordure ronde Blizzard.
  local masked=false
  if type(icon.SetMask)=="function" then
    masked=pcall(icon.SetMask,icon,
      "Interface\\CharacterFrame\\TempPortraitAlphaMask")
  end
  if not masked and type(SetPortraitToTexture)=="function" then
    pcall(SetPortraitToTexture,icon,
      "Interface\\Icons\\Ability_Warrior_BattleShout")
  end
  b.icon=icon
  local border=b:CreateTexture(nil,"OVERLAY")
  border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
  border:SetPoint("TOPLEFT",b,"TOPLEFT",0,0)
  border:SetSize(53,53)
  b.border=border
  if type(b.RegisterForClicks)=="function" then
    b:RegisterForClicks("LeftButtonUp","RightButtonUp")
  end
  if type(b.RegisterForDrag)=="function" then b:RegisterForDrag("LeftButton") end
  b:SetScript("OnClick",function(_,mouse)
    if mouse=="RightButton" then B:ToggleCompact()
    else B:ToggleDashboard() end
  end)
  b:SetScript("OnEnter",function(frame)
    local tip=GameTooltip
    if tip and type(tip.SetOwner)=="function" then
      tip:SetOwner(frame,"ANCHOR_LEFT")
      if type(tip.AddLine)=="function" then
        tip:AddLine("Warrior Companion Build",1,0.78,0.35)
        tip:AddLine("Clic gauche : guide complet",0.9,0.9,0.9)
        tip:AddLine("Clic droit : mini-bilan",0.9,0.9,0.9)
        tip:AddLine("Glisser : deplacer autour de la minimap",0.7,0.8,0.9)
      end
      if type(tip.Show)=="function" then tip:Show() end
    end
  end)
  b:SetScript("OnLeave",function()
    if GameTooltip and type(GameTooltip.Hide)=="function" then
      GameTooltip:Hide()
    end
  end)
  local function onDrag(_,elapsed)
    if type(GetCursorPosition)~="function" or
        type(Minimap.GetCenter)~="function" then return end
    local ok,x,y=pcall(GetCursorPosition)
    local centerOK,cx,cy=pcall(Minimap.GetCenter,Minimap)
    if not ok or not centerOK or not B.SafeNumber then return end
    x,y=B:SafeNumber(x),B:SafeNumber(y)
    cx,cy=B:SafeNumber(cx),B:SafeNumber(cy)
    if not x or not y or not cx or not cy then return end
    local scale=1
    if type(Minimap.GetEffectiveScale)=="function" then
      local good,value=pcall(Minimap.GetEffectiveScale,Minimap)
      value=good and B:SafeNumber(value) or nil
      if value and value>0 then scale=value end
    end
    local angle=(atan2(y/scale-cy,x/scale-cx)*180/pi)%360
    if B.db then B.db.minimapAngle=angle end
    B:UpdateMinimapButton()
  end
  b:SetScript("OnDragStart",function()
    b:SetScript("OnUpdate",onDrag)
  end)
  b:SetScript("OnDragStop",function()
    b:SetScript("OnUpdate",nil)
  end)
  self.minimapButton=b
  self:UpdateMinimapButton()
  return b
end
function B:SetMinimapVisible(show)
  if self.db then self.db.minimapVisible=show==true end
  if not self.minimapButton and show then self:CreateMinimapButton() end
  self:UpdateMinimapButton()
end
