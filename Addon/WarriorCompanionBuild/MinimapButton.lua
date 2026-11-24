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
  local angle=self.db and tonumber(self.db.minimapAngle) or 225
  if angle~=angle then angle=225 end
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
  local b=CreateFrame("Button","WarriorCompanionBuildMinimap",Minimap)
  b:SetSize(32,32)
  b:SetFrameStrata("MEDIUM")
  if type(b.SetNormalTexture)=="function" then
    b:SetNormalTexture("Interface\\Icons\\Ability_Warrior_BattleShout")
  else
    local icon=b:CreateTexture(nil,"ARTWORK")
    icon:SetAllPoints(b)
    icon:SetTexture("Interface\\Icons\\Ability_Warrior_BattleShout")
    b.icon=icon
  end
  if type(b.SetHighlightTexture)=="function" then
    b:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
  end
  local border=b:CreateTexture(nil,"OVERLAY")
  border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
  border:SetPoint("TOPLEFT",b,"TOPLEFT",-10,10)
  border:SetSize(52,52)
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
    if type(tip)=="table" and type(tip.SetOwner)=="function" then
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
    if type(GameTooltip)=="table" and
        type(GameTooltip.Hide)=="function" then GameTooltip:Hide() end
  end)
  local function onDrag(_,elapsed)
    if type(GetCursorPosition)~="function" or
        type(Minimap.GetCenter)~="function" then return end
    local x,y=GetCursorPosition()
    local cx,cy=Minimap:GetCenter()
    if type(x)~="number" or type(y)~="number" or
        type(cx)~="number" or type(cy)~="number" then return end
    local scale=1
    if UIParent and type(UIParent.GetEffectiveScale)=="function" then
      local value=UIParent:GetEffectiveScale()
      if type(value)=="number" and value>0 then scale=value end
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
