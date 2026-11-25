local addon,B=...
-- Bouton autonome autour de la minimap, sans LibDBIcon externe.
local floor,cos,sin,pi=math.floor,math.cos,math.sin,math.pi
-- Meme regle de placement que GearQuest : centre de l'icone sur le
-- pourtour reel de la minimap, y compris si un addon la redimensionne.
local function minimapRadius()
  local width,height=nil,nil
  if Minimap and type(Minimap.GetWidth)=="function" then
    local ok,value=pcall(Minimap.GetWidth,Minimap)
    width=ok and B.SafeNumber and B:SafeNumber(value) or nil
  end
  if Minimap and type(Minimap.GetHeight)=="function" then
    local ok,value=pcall(Minimap.GetHeight,Minimap)
    height=ok and B.SafeNumber and B:SafeNumber(value) or nil
  end
  if not width or width<=0 then width=140 end
  if not height or height<=0 then height=width end
  return math.min(width,height)/2+5
end
local function angleCoordinates(angle)
  local radians=angle*pi/180
  local radius=minimapRadius()
  return floor(cos(radians)*radius+0.5),
    floor(sin(radians)*radius+0.5)
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
  -- Presentation native identique aux boutons de GearQuest/LibDBIcon.
  -- Ne pas appliquer de masque de portrait a une texture d'icone brute.
  local b=CreateFrame("Button","WarriorCompanionBuildMinimap",Minimap)
  b:SetSize(31,31)
  b:SetFrameStrata("HIGH")
  if type(b.SetFrameLevel)=="function" then b:SetFrameLevel(20) end
  if type(b.SetHighlightTexture)=="function" then
    b:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
  end
  local icon=b:CreateTexture(nil,"BACKGROUND")
  -- Lire l'icone de Cri de guerre directement dans le client si possible.
  -- Eviter un nom de fichier d'icone non confirme sur Forever.
  local artwork="Interface\\Icons\\Ability_Warrior_BattleShout"
  if type(C_Spell)=="table" and type(C_Spell.GetSpellTexture)=="function" then
    local ok,result=pcall(C_Spell.GetSpellTexture,6673)
    if ok and result then artwork=result end
  end
  icon:SetTexture(artwork)
  icon:SetSize(20,20)
  icon:SetPoint("CENTER",b,"CENTER",0,1)
  if type(icon.SetTexCoord)=="function" then
    icon:SetTexCoord(.06,.94,.06,.94)
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
  -- L'icone est un lanceur, pas un interrupteur : cliquer plusieurs
  -- fois sur une vue deja ouverte ne doit jamais la fermer.
  b:SetScript("OnClick",function(_,mouse)
    if mouse=="RightButton" then B:ShowCompact()
    else B:OpenFullDashboard() end
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
  -- Les addons de carte peuvent modifier la taille de la minimap apres
  -- l'initialisation. Recalculer alors le rayon de l'icone.
  if type(Minimap.HookScript)=="function" then
    pcall(Minimap.HookScript,Minimap,"OnSizeChanged",function()
      B:UpdateMinimapButton()
    end)
  end
  return b
end
function B:SetMinimapVisible(show)
  if self.db then self.db.minimapVisible=show==true end
  if not self.minimapButton and show then self:CreateMinimapButton() end
  self:UpdateMinimapButton()
end
