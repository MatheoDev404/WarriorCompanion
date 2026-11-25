-- Simulation autonome du mini-bilan original et du bouton minimap.
local function frame()
  local f={shown=true,scripts={}}
  function f:SetSize(w,h) self.width=w self.height=h end
  function f:SetPoint(...) self.point={...} end
  function f:ClearAllPoints() self.point=nil end
  function f:SetFrameStrata(value) self.strata=value end
  function f:SetFrameLevel(value) self.frameLevel=value end
  function f:SetMovable(value) self.movable=value end
  function f:EnableMouse(value) self.mouseEnabled=value end
  function f:RegisterForDrag(value) self.dragButton=value end
  function f:RegisterForClicks(...) self.clickButtons={...} end
  function f:SetNormalTexture(v) self.normalTexture=v end
  function f:SetHighlightTexture(v) self.highlightTexture=v end
  function f:SetScript(name,fn) self.scripts[name]=fn end
  function f:StartMoving() self.moving=true end
  function f:StopMovingOrSizing() self.moving=false end
  function f:Show() self.shown=true end
  function f:Hide() self.shown=false end
  function f:IsShown() return self.shown end
  function f:GetCenter() return 530,330 end
  function f:CreateTexture()
    local texture={}
    function texture:SetTexture(v) self.texture=v end
    function texture:SetPoint(...) self.point={...} end
    function texture:SetAllPoints(...) self.allPoints={...} end
    function texture:SetSize(w,h) self.width=w self.height=h end
    function texture:SetVertexColor(...) self.color={...} end
    function texture:SetTexCoord(...) self.texCoord={...} end
    function texture:SetMask(path) self.mask=path end
    return texture
  end
  function f:CreateFontString()
    local t={}
    function t:SetPoint(...) self.point={...} end
    function t:SetWidth(v) self.width=v end
    function t:SetHeight(v) self.height=v end
    function t:SetText(v) self.text=v end
    function t:SetJustifyH(v) self.justifyH=v end
    function t:SetJustifyV(v) self.justifyV=v end
    return t
  end
  return f
end
UIParent=frame()
function UIParent:GetCenter() return 500,500 end
function UIParent:GetEffectiveScale() return 1 end
Minimap=frame()
function Minimap:GetCenter() return 800,600 end
function Minimap:GetWidth() return self.mapWidth or 140 end
function Minimap:GetHeight() return self.mapHeight or 140 end
function Minimap:HookScript(name,handler) self.scripts[name]=handler end
function CreateFrame() return frame() end
local clock=100
local xp=50
local level=34
local money=254321
local hp=100
local cursorX,cursorY=700,580
function GetTime() return clock end
function UnitLevel() return level end
function UnitXP() return xp end
function UnitXPMax() return 1000 end
function GetMoney() return money end
function UnitHealth() return hp end
function UnitHealthMax() return 100 end
function GetCursorPosition() return cursorX,cursorY end
local B={db={autoOpen=false,displayMode="hidden",showAlerts=true,
  minimapVisible=true},viewLevel=34}
function B:UpdateLevel() self.updateLevel=(self.updateLevel or 0)+1 end
function B:Refresh() self.fullRefreshed=(self.fullRefreshed or 0)+1 end
B.frame=frame()
B.frame:Hide()
assert(loadfile("Addon/WarriorCompanionBuild/Session.lua"))("WarriorCompanionBuild",B)
assert(loadfile("Addon/WarriorCompanionBuild/CompactDashboard.lua"))("WarriorCompanionBuild",B)
assert(loadfile("Addon/WarriorCompanionBuild/MinimapButton.lua"))("WarriorCompanionBuild",B)
B:StartSession()
B:CreateCompactDashboard()
B:CreateMinimapButton()
assert(B.compactDashboard.width==304 and B.compactDashboard.height==88,
  "dimensions originales 304x88 du mini-bilan")
assert(B.compactExpand and #B.compactStats==3 and
  #B.compactMoneyParts==3 and B.compactAdvice)
assert(not B.frame:IsShown() and not B.compactDashboard:IsShown() and
  B.minimapButton:IsShown(),
  "connexion par defaut : icone seulement, pas de grande fenetre")
B:AutoOpenDashboard()
assert(not B.frame:IsShown() and not B.compactDashboard:IsShown(),
  "ne jamais ouvrir automatiquement par defaut")
assert(B.minimapButton.normalTexture==nil,
  "aucune icone carree en texture de bouton")
assert(B.minimapButton.icon and B.minimapButton.icon.width==20
    and B.minimapButton.icon.height==20 and
    B.minimapButton.icon.texture:find("BerserkerRage",1,true),
  "icone de guerrier centree de 20px")
assert(B.minimapButton.icon.point[1]=="CENTER" and
  B.minimapButton.border and B.minimapButton.border.width==53,
  "icone centree et contour Blizzard comme les autres addons")
assert(B.minimapButton.icon.mask==nil,
  "pas de masque de portrait deformant l'icone")
assert(B.minimapButton.highlightTexture:find("ZoomButton",1,true),
  "surbrillance circulaire Blizzard")
assert(B.minimapButton.point[2]==Minimap,"bouton ancre a la minimap")
local xBefore,yBefore=B.minimapButton.point[4],B.minimapButton.point[5]
Minimap.mapWidth,Minimap.mapHeight=200,200
if Minimap.scripts.OnSizeChanged then Minimap.scripts.OnSizeChanged() end
assert(B.minimapButton.point[4]~=xBefore and
  B.minimapButton.point[5]~=yBefore,
  "le rayon suit le redimensionnement de la minimap")
Minimap.mapWidth,Minimap.mapHeight=140,140
B:UpdateMinimapButton()
assert(B.minimapButton.clickButtons[2]=="RightButtonUp")
B.minimapButton.scripts.OnClick(B.minimapButton,"LeftButton")
assert(B.frame:IsShown() and B.db.displayMode=="full")
B.minimapButton.scripts.OnClick(B.minimapButton,"LeftButton")
assert(not B.frame:IsShown() and B.db.displayMode=="hidden")
B.minimapButton.scripts.OnClick(B.minimapButton,"RightButton")
assert(B.compactDashboard:IsShown() and not B.frame:IsShown() and
  B.db.displayMode=="compact")
clock=161
xp=75
money=241976
B:OnSessionEvent("PLAYER_XP_UPDATE")
B:OnSessionEvent("PLAYER_MONEY")
B:OnSessionEvent("PLAYER_DEAD")
assert(B.metrics.xpGained==25 and B.metrics.deaths==1)
assert(B:MoneyDelta()==-12345)
assert(B.compactStats[1].text=="25" and
  B.compactStats[2].text=="00:01:01" and
  B.compactStats[3].text=="1","XP temps morts comme dans le mini original")
assert(B.compactMoneySign.text:find("-",1,true))
assert(B.compactMoneyParts[1].text:find("01",1,true) and
  B.compactMoneyParts[2].text:find("23",1,true) and
  B.compactMoneyParts[3].text:find("45",1,true))
assert(B.compactMoneyParts[1].text:find("F17E78",1,true),
  "solde negatif en rouge")
money=274321
B:OnSessionEvent("PLAYER_MONEY")
assert(B.compactMoneySign.text:find("+",1,true) and
  B.compactMoneyParts[1].text:find("70DB8B",1,true),
  "solde positif en vert")
B.compactExpand.scripts.OnClick()
assert(B.frame:IsShown() and not B.compactDashboard:IsShown())
B:CloseFull()
assert(B.compactDashboard:IsShown() and not B.frame:IsShown(),
  "fermer le guide ouvert depuis mini restaure le mini")
B.compactDashboard.scripts.OnDragStop(B.compactDashboard)
assert(B.db.compactPoint.x==30 and B.db.compactPoint.y==-170,
  "position du mini memorisee")
local old=B.compactDashboard
B.compactDashboard=nil
B:CreateCompactDashboard()
assert(B.compactDashboard~=old and B.compactDashboard.point[4]==30)
B:ShowCompact()
hp=20
B:RefreshCompactDashboard()
assert(B.compactAdvice.text:find("Vie basse",1,true))
B.db.showAlerts=false
B:RefreshCompactDashboard()
assert(B.compactAdvice.text:find("desactives",1,true))
B.db.showAlerts=true
hp=100
B:OnSessionEvent("PLAYER_DEAD")
B:OnSessionEvent("PLAYER_DEAD")
assert(B.compactAdvice.text:find("Morts frequentes",1,true))
B:ResetSession()
assert(B.metrics.xpGained==0 and B.metrics.deaths==0 and
  B.metrics.moneyStart==money,"reinitialisation des statistiques")
B:SetMinimapVisible(false)
assert(not B.minimapButton:IsShown() and B.db.minimapVisible==false)
B:SetMinimapVisible(true)
assert(B.minimapButton:IsShown() and B.db.minimapVisible==true)
B.minimapButton.scripts.OnDragStart()
assert(type(B.minimapButton.scripts.OnUpdate)=="function")
B.minimapButton.scripts.OnUpdate(B.minimapButton,0.016)
assert(type(B.db.minimapAngle)=="number")
B.minimapButton.scripts.OnDragStop()
assert(B.minimapButton.scripts.OnUpdate==nil)
-- Simuler les numeros opaques de Forever : type(secret) reste number,
-- mais le code de l'addon ne doit jamais les comparer ni les soustraire.
issecretvalue=function(value)
  return type(value)=="number" and value==777
end
assert(B:SafeNumber(777)==nil and B:SafeNumber(42)==42,
  "une valeur numerique secrete est rejetee avant calcul")
local validMoney=money
money=777
B:OnSessionEvent("PLAYER_MONEY")
assert(B:MoneyDelta()==nil and
  B.compactMoneyParts[1].text:find("%-%-"),
  "montant secret : solde indisponible, sans exception Lua")
money=validMoney
B:OnSessionEvent("PLAYER_MONEY")
local clockFunction=GetTime
GetTime=function() return 777 end
B:RefreshCompactDashboard()
assert(B.compactStats[2].text=="--:--:--",
  "temps secret : chronometre indisponible")
GetTime=clockFunction
B:ResetSession()
local healthFunction=UnitHealth
UnitHealth=function() return 777 end
assert(B:AdviceLines()=="Aucune alerte prioritaire.",
  "PV secrets : aucune comparaison interdite ni fausse alerte")
UnitHealth=healthFunction
local xpFunction=UnitXP
UnitXP=function() return 777 end
B:OnSessionEvent("PLAYER_XP_UPDATE")
assert(B.metrics.xpAvailable==false,"XP secrete : suivi en attente")
UnitXP=xpFunction
local cursorFunction=GetCursorPosition
local beforeAngle=B.db.minimapAngle
GetCursorPosition=function() return 777,580 end
B.minimapButton.scripts.OnDragStart()
B.minimapButton.scripts.OnUpdate(B.minimapButton,0.016)
assert(B.db.minimapAngle==beforeAngle,
  "curseur secret : conserver la position sans erreur")
B.minimapButton.scripts.OnDragStop()
GetCursorPosition=cursorFunction
issecretvalue=nil
B:HideDashboard()
B.db.autoOpen=true
B.db.displayMode="compact"
B.didAutoOpen=nil
B:AutoOpenDashboard()
assert(B.compactDashboard:IsShown() and not B.frame:IsShown(),
  "option autostart memorisee et mini privilegie")
print("OK: minimap, mini original 304x88, XP, temps, morts, solde, conseil, autostart et position")
