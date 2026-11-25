-- Navigation Forever : distance reelle, fallback carte, carte differente,
-- valeurs secretes, affichage du HUD et atteinte des etapes de trajet.
local function frame()
 local f={shown=true,scripts={}}
 function f:SetSize(w,h) self.width=w self.height=h end
 function f:SetPoint(...) self.point={...} end
 function f:SetFrameStrata(v) self.strata=v end
 function f:SetMovable() end
 function f:EnableMouse() end
 function f:RegisterForDrag() end
 function f:SetScript(k,fn) self.scripts[k]=fn end
 function f:IsShown() return self.shown end
 function f:Show() self.shown=true end
 function f:Hide() self.shown=false end
 function f:CreateTexture()
  local t={}
  function t:SetAllPoints() end
  function t:SetTexture(v) self.texture=v end
  function t:SetSize(w,h) self.width=w self.height=h end
  function t:SetPoint(...) self.point={...} end
  function t:SetVertexColor(...) self.color={...} end
  function t:SetColorTexture(...) self.bg={...} end
  function t:SetRotation(v) self.rotation=v end
  function t:Hide() self.visible=false end
  function t:Show() self.visible=true end
  return t
 end
 function f:CreateFontString()
  local t={}
  function t:SetPoint(...) end
  function t:SetWidth(v) self.width=v end
  function t:SetTextColor(...) self.color={...} end
  function t:SetJustifyH(v) self.align=v end
  function t:SetText(v) self.text=v end
  return t
 end
 function f:GetCenter() return 500,500 end
 return f
end
UIParent=frame()
function CreateFrame() return frame() end
function CreateVector2D(x,y)
 return {x=x,y=y,GetXY=function(self) return self.x,self.y end}
end
local CMapID=1443
local targetInstance=1
C_Map={
 GetWorldPosFromMapPos=function(mapID,pos)
  return targetInstance,CreateVector2D(100,80)
 end,
 GetBestMapForUnit=function() return CMapID end,
 GetPlayerMapPosition=function(mapID,unit)
  return CreateVector2D(.5,.6)
 end,
 GetMapWorldSize=function() return 1000,1000 end
}
function UnitPosition() return 90,80,0,1 end
function GetPlayerFacing() return 0 end
local B={db={compassEnabled=true},guideSteps={{id="a",guide=true}}}
local marked=0
function B:GuideStepDone(step) return marked>0 end
function B:GuideMarkStep(step) marked=marked+1 end
assert(loadfile("Addon/WarriorCompanionBuild/Compass.lua"))("WarriorCompanionBuild",B)
local target={mapID=1443,x=60,y=60,id="a",label="Rejoindre Smeed",travel=true}
local result=B:CompassDirection(target)
assert(result.method=="world" and result.distance==10 and
 result.reached and math.abs(result.angle)<0.001,
 "la cible au nord est en face a 10 metres")
local f=B:CreateCompass()
assert(f.width==206 and f.height==92 and f:IsShown())
B:SetCompassTarget(target)
assert(f.distance.text=="Destination atteinte" and marked==1)
B:UpdateCompass()
assert(marked==1,"arrivee detectee une seule fois")
function GetPlayerFacing() return math.pi/2 end
result=B:CompassDirection(target)
assert(math.abs(result.angle+math.pi/2)<0.001)
function GetPlayerFacing() return 0 end
targetInstance=2
result=B:CompassDirection(target)
assert(result.reason:find("Autre continent",1,true),
 "pas de distance en ligne droite a travers les continents")
targetInstance=1
-- Le monde ne donne pas de coordonnees ; fallback de carte locale.
UnitPosition=nil
target={mapID=1443,x=50,y=50,id="b",label="Zone",travel=false}
result=B:CompassDirection(target)
assert(result.method=="map" and math.abs(result.distance-100)<.001)
CMapID=1424
result=B:CompassDirection(target)
assert(result.reason:find("Changer de zone",1,true),
 "jamais de distance map-space dans une autre zone")
CMapID=1443
issecretvalue=function(v) return type(v)=="number" and v==777 end
function GetPlayerFacing() return 777 end
result=B:CompassDirection(target)
assert(result.reason=="Orientation indisponible",
 "ne jamais comparer ni soustraire un secret number")
function GetPlayerFacing() return 0 end
B:SetCompassEnabled(false)
assert(not f:IsShown())
B:SetCompassEnabled(true)
assert(f:IsShown())
B:SetCompassTarget(nil)
assert(f.arrow.visible==false and
 f.distance.text=="Aucun objectif avec coordonnées")
print("OK: boussole, monde et carte, autres zones, secret values et arrivée")
