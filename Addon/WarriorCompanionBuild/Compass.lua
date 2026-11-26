local _,B=...
-- Boussole 30-40 : direction du waypoint, distance en ligne droite.
-- Aucune trajectoire à travers les obstacles ou changements de continent.
-- Les APIs de WoW Forever peuvent renvoyer des valeurs secretes.
local abs,pi,sqrt,floor=math.abs,math.pi,math.sqrt,math.floor
local atan2=math.atan2 or function(y,x)
  if x==0 then return y>=0 and pi/2 or -pi/2 end
  local a=math.atan(y/x)
  if x<0 then a=a+(y>=0 and pi or -pi) end
  return a
end
local function num(v)
  if type(issecretvalue)=="function" then
    local ok,secret=pcall(issecretvalue,v)
    if not ok or secret then return nil end
  end
  if type(v)~="number" then return nil end
  local ok,valid=pcall(function()
    return v==v and v~=math.huge and v~=-math.huge
  end)
  return ok and valid and v or nil
end
local function call(fn,...)
  if type(fn)~="function" then return nil end
  local ok,a,b,c,d=pcall(fn,...)
  if not ok then return nil end
  return a,b,c,d
end
local function vectorXY(v)
  if v==nil then return nil end
  local ok,x,y=pcall(function()
    if type(v.GetXY)=="function" then return v:GetXY() end
    return v.x,v.y
  end)
  if not ok then return nil end
  return num(x),num(y)
end
function B:CompassDirection(target)
  if not target or type(C_Map)~="table" then
    return {reason="Aucun objectif avec coordonnées"}
  end
  local mapID,x,y=num(target.mapID),num(target.x),num(target.y)
  if not mapID or not x or not y or x<0 or x>100 or
      y<0 or y>100 then
    return {reason="Coordonnées indisponibles"}
  end
  local facing=num(call(GetPlayerFacing))
  if not facing then return {reason="Orientation indisponible"} end
  local worldMap=C_Map.GetWorldPosFromMapPos
  local px,py,instance=num(nil),num(nil),nil
  local tx,ty,ti=nil,nil,nil
  if type(CreateVector2D)=="function" and
      type(worldMap)=="function" and type(UnitPosition)=="function" then
    local v=call(CreateVector2D,x/100,y/100)
    if v then
      local targetInst,targetVector=call(worldMap,mapID,v)
      tx,ty=vectorXY(targetVector)
      ti=num(targetInst)
      local a,b,c,d=call(UnitPosition,"player")
      px,py,instance=num(a),num(b),num(d)
    end
  end
  local dx,dy,distance,method
  if px and py and tx and ty and ti and instance then
    if ti~=instance then
      return {reason="Autre continent / instance : trajet requis"}
    end
    dx,dy=tx-px,ty-py
    distance=sqrt(dx*dx+dy*dy)
    method="world"
  else
    -- Repli possible uniquement si la carte du joueur == celle du
    -- waypoint. Jamais de distance intercontinentale inventée.
    local current=num(call(C_Map.GetBestMapForUnit,"player"))
    if current~=mapID then
      return {reason="Changer de zone : distance indisponible"}
    end
    local position=call(C_Map.GetPlayerMapPosition,mapID,"player")
    local cx,cy=vectorXY(position)
    local width,height=call(C_Map.GetMapWorldSize,mapID)
    width,height=num(width),num(height)
    if not cx or not cy or not width or not height or
        width<=0 or height<=0 then
      return {reason="Position ou dimensions de carte indisponibles"}
    end
    -- Axe monde X vers le nord, axe monde Y vers l'ouest.
    dx=(cy-y/100)*height
    dy=(cx-x/100)*width
    distance=sqrt(dx*dx+dy*dy)
    method="map"
  end
  local relative=atan2(dy,dx)-facing
  while relative>pi do relative=relative-2*pi end
  while relative< -pi do relative=relative+2*pi end
  return {angle=relative,distance=distance,method=method,
    reached=distance<=18}
end
local function label(parent,width,offsetY,size,color)
  local f=parent:CreateFontString(nil,"OVERLAY",size or "GameFontHighlightSmall")
  f:SetPoint("TOP",parent,"TOP",0,offsetY)
  f:SetWidth(width)
  if type(f.SetJustifyH)=="function" then f:SetJustifyH("CENTER") end
  if color and type(f.SetTextColor)=="function" then
    f:SetTextColor(color[1],color[2],color[3])
  end
  -- Ombre du texte pour le contraste en plein jeu, sans panneau opaque.
  if type(f.SetShadowColor)=="function" then
    f:SetShadowColor(0,0,0,0.95)
  end
  if type(f.SetShadowOffset)=="function" then
    f:SetShadowOffset(1,-1)
  end
  return f
end
-- Dessin net, sans image agrandie : trois traits de couleur unie.
-- Les textures 1x1 de WoW restent lisses quelle que soit l'echelle.
local cos,sin=math.cos,math.sin
local function arrowStroke(frame,width,height,dx,dy,baseRotation)
  local texture=frame:CreateTexture(nil,"OVERLAY")
  texture:SetTexture("Interface\\Buttons\\WHITE8X8")
  texture:SetSize(width,height)
  texture:SetVertexColor(0.99,0.78,0.35,1)
  return {texture=texture,dx=dx,dy=dy,base=baseRotation}
end
function B:CompassDraw(angle)
  local f=self.compassFrame
  if not f or not f.arrowParts then return end
  -- Le guide retourne un angle relatif; le signe inverse correspond
  -- a la convention de rotation des textures du client.
  local theta=-angle
  local c,s=cos(theta),sin(theta)
  for _,part in ipairs(f.arrowParts) do
    local x=part.dx*c-part.dy*s
    local y=part.dx*s+part.dy*c
    local tex=part.texture
    if type(tex.ClearAllPoints)=="function" then tex:ClearAllPoints() end
    tex:SetPoint("CENTER",f,"TOP",x,-38+y)
    if type(tex.SetRotation)=="function" then
      tex:SetRotation(part.base+theta)
    end
  end
end
function B:SetCompassScale(value)
  local scale=num(value)
  if not scale then return false end
  scale=math.max(0.75,math.min(1.35,math.floor(scale*20+0.5)/20))
  if self.db then self.db.compassScale=scale end
  if self.compassFrame and type(self.compassFrame.SetScale)=="function" then
    self.compassFrame:SetScale(scale)
  end
  return true
end
function B:CreateCompass()
  if self.compassFrame then return self.compassFrame end
  if type(CreateFrame)~="function" or not UIParent then return nil end
  local f=CreateFrame("Frame","WarriorCompanionBuildCompass",UIParent)
  f:SetSize(180,108)
  local p=self.db and self.db.compassPoint
  local x=(type(p)=="table" and num(p.x)) or 0
  local y=(type(p)=="table" and num(p.y)) or 160
  f:SetPoint("CENTER",UIParent,"CENTER",x,y)
  f:SetFrameStrata("MEDIUM")
  f:SetMovable(true)
  f:EnableMouse(false)

  local drag=CreateFrame("Button",nil,f)
  drag:SetSize(68,68)
  drag:SetPoint("TOP",f,"TOP",0,-1)
  if type(drag.EnableMouse)=="function" then drag:EnableMouse(true) end
  if type(drag.RegisterForDrag)=="function" then
    drag:RegisterForDrag("LeftButton")
  end
  drag:SetScript("OnDragStart",function()
    if type(f.StartMoving)=="function" then f:StartMoving() end
  end)
  drag:SetScript("OnDragStop",function()
    if type(f.StopMovingOrSizing)=="function" then f:StopMovingOrSizing() end
    if not B.db or type(f.GetCenter)~="function" or
        type(UIParent.GetCenter)~="function" then return end
    local x1,y1=call(f.GetCenter,f)
    local x2,y2=call(UIParent.GetCenter,UIParent)
    x1,y1,x2,y2=num(x1),num(y1),num(x2),num(y2)
    if x1 and y1 and x2 and y2 then
      B.db.compassPoint={x=x1-x2,y=y1-y2}
    end
  end)
  f.dragHandle=drag

  -- Fleche 68 px composee de trois traits precision, sans halo,
  -- ombre geante, icone minimap et surtout sans panneau.
  local stem=arrowStroke(f,4,43,0,-12,0)
  local left=arrowStroke(f,4.5,28,-9,12,math.pi/4)
  local right=arrowStroke(f,4.5,28,9,12,-math.pi/4)
  f.arrowParts={stem,left,right}
  f.arrow=stem.texture
  f.arrowLeft=left.texture
  f.arrowRight=right.texture

  f.distance=label(f,178,-76,"GameFontNormal",{0.99,0.83,0.47})
  f.description=label(f,178,-94,"GameFontHighlightSmall",{0.9,0.93,0.97})
  self.compassFrame=f
  self:SetCompassScale((self.db and self.db.compassScale) or 1)
  self:CompassDraw(0)
  local tick=0
  f:SetScript("OnUpdate",function(_,delta)
    delta=num(delta)
    if not delta then return end
    tick=tick+delta
    if tick<0.2 then return end
    tick=0
    B:UpdateCompass()
  end)
  self:UpdateCompass()
  return f
end
function B:SetCompassEnabled(enabled)
  if not self.db then return end
  self.db.compassEnabled=enabled==true
  if enabled and not self.compassFrame then self:CreateCompass() end
  self:UpdateCompass()
end
function B:SetCompassTarget(target)
  self.compassTarget=target
  if self.compassFrame then self:UpdateCompass() end
end
function B:UpdateCompass()
  local f=self.compassFrame
  if not f then return end
  if not self.db or self.db.compassEnabled==false or
      not self.compassTarget then
    -- Aucune cible : ne pas couvrir le jeu avec un message inutile.
    f:Hide()
    return
  end
  f:Show()
  local result=self:CompassDirection(self.compassTarget)
  if not result or not result.angle then
    for _,part in ipairs(f.arrowParts or {}) do
      part.texture:Hide()
    end
    f.distance:SetText(result and result.reason or "Pas de destination")
  else
    for _,part in ipairs(f.arrowParts or {}) do
      part.texture:Show()
    end
    self:CompassDraw(result.angle)
    f.distance:SetText(result.reached and "Destination atteinte" or
      ("~"..floor(result.distance+0.5).." m (ligne droite)"))
    if result.reached and self.compassTarget and self.compassTarget.travel and
        self.compassTarget.id and self.guideSteps then
      for _,step in ipairs(self.guideSteps) do
        if step.id==self.compassTarget.id and not self:GuideStepDone(step) then
          self:GuideMarkStep(step)
          if self.page=="parcours" and self.frame and
              self.frame:IsShown() and self.RefreshRoute then self:RefreshRoute() end
          break
        end
      end
    end
  end
  local name=self.compassTarget and self.compassTarget.label or
    "Guide 30-40"
  if type(name)~="string" then name="Guide 30-40" end
  if #name>31 then name=name:sub(1,28).."..." end
  f.description:SetText(name)
end
