local addon,B=...
-- Comptage de session du mini-bilan, adapte de l'Observer.lua historique.
-- Aucune statistique inventee : si une API est absente, on indique "--".
-- type(secret) est bien "number" sur Forever. Verifier issecretvalue
-- AVANT toute comparaison, addition, formatage ou conversion.
local function secret(value)
  if type(issecretvalue)~="function" then return false end
  local ok,result=pcall(issecretvalue,value)
  return not ok or result==true
end
local function numeric(value)
  if type(value)~="number" or secret(value) then return nil end
  -- Garde de secours pour les builds ou issecretvalue est absent.
  local ok,valid=pcall(function()
    return value==value and value~=math.huge and value~=-math.huge
  end)
  if not ok or not valid then return nil end
  return value
end
function B:SafeNumber(value)
  return numeric(value)
end
local function read(fn,...)
  if type(fn)~="function" then return nil end
  local ok,value=pcall(fn,...)
  return ok and numeric(value) or nil
end
local function readBool(fn,...)
  if type(fn)~="function" then return nil end
  local ok,value=pcall(fn,...)
  if not ok or type(value)~="boolean" or secret(value) then return nil end
  local safe,result=pcall(function() return value and true or false end)
  return safe and result or nil
end
function B:Now()
  return read(GetTime)
end
function B:StartSession()
  if self.metrics then return end
  local m={xpGained=0,deaths=0,started=self:Now(),moneyStart=nil,
    moneyNow=nil,lastXP=nil,lastXPMax=nil,lastLevel=nil,pendingLevel=nil,
    xpAvailable=false}
  self.metrics=m
  m.moneyNow=read(GetMoney)
  m.moneyStart=m.moneyNow
  self:ObserveXP()
end
function B:ResetSession()
  self.metrics=nil
  self:StartSession()
  if self.RefreshCompactDashboard then self:RefreshCompactDashboard() end
end
function B:ObserveXP(event,newLevel)
  local m=self.metrics
  if not m then return end
  local level=read(UnitLevel,"player")
  local xp=read(UnitXP,"player")
  local xpMax=read(UnitXPMax,"player")
  newLevel=numeric(newLevel)
  if event=="PLAYER_LEVEL_UP" and newLevel and newLevel>0 then
    m.pendingLevel=newLevel
  end
  m.xpAvailable=level~=nil and level>0 and xp~=nil and xp>=0 and
    xpMax~=nil and xpMax>0 and xp<=xpMax
  if not m.xpAvailable then return end
  if m.pendingLevel and level<m.pendingLevel then return end
  local beforeLevel,beforeXP,beforeMax=m.lastLevel,m.lastXP,m.lastXPMax
  if beforeLevel and beforeXP and beforeMax then
    local gain=0
    if level==beforeLevel then
      if xp<beforeXP or xpMax~=beforeMax then return end
      gain=xp-beforeXP
    elseif level==beforeLevel+1 then
      if xpMax==beforeMax or
          (xp==beforeXP and event=="PLAYER_LEVEL_UP") then
        return
      end
      gain=beforeMax-beforeXP+xp
    end
    if gain>0 then m.xpGained=m.xpGained+gain end
  end
  m.pendingLevel=nil
  m.lastLevel,m.lastXP,m.lastXPMax=level,xp,xpMax
end
function B:MoneyDelta()
  local m=self.metrics
  if not m or type(m.moneyStart)~="number" or
      type(m.moneyNow)~="number" then return nil end
  return m.moneyNow-m.moneyStart
end
function B:OnSessionEvent(event,arg1)
  if not self.metrics then return end
  if event=="PLAYER_XP_UPDATE" or event=="PLAYER_LEVEL_UP" then
    self:ObserveXP(event,arg1)
  elseif event=="PLAYER_DEAD" then
    self.metrics.deaths=self.metrics.deaths+1
  elseif event=="PLAYER_MONEY" or event=="PLAYER_ENTERING_WORLD" then
    self.metrics.moneyNow=read(GetMoney)
    if self.metrics.moneyStart==nil then
      self.metrics.moneyStart=self.metrics.moneyNow
    end
    if event=="PLAYER_ENTERING_WORLD" then self:ObserveXP(event) end
  end
  if self.compactDashboard and self.compactDashboard:IsShown() and
      self.RefreshCompactDashboard then
    self:RefreshCompactDashboard()
  end
end
local function unspentTalents()
  local talents=C_ClassTalents
  if type(talents)~="table" or
      type(talents.HasUnspentTalentPoints)~="function" then return nil end
  local ok,has,class,spec=pcall(talents.HasUnspentTalentPoints)
  if not ok or secret(has) or has~=true then return nil end
  class,spec=numeric(class),numeric(spec)
  if class==nil or spec==nil then return nil end
  if class+spec>0 then return class+spec end
  return nil
end
function B:AdviceLines()
  if self.db and self.db.showAlerts==false then
    return "Conseils desactives."
  end
  local talents=unspentTalents()
  if talents then
    return talents.." point(s) de talent non depense(s)."
  end
  local health,maxHealth=read(UnitHealth,"player"),read(UnitHealthMax,"player")
  local inCombat=readBool(InCombatLockdown)
  if health and maxHealth and maxHealth>0 and health>0 and
      health/maxHealth<0.35 and
      (type(InCombatLockdown)~="function" or inCombat==false) then
    return "Vie basse : recupere avant le prochain combat."
  end
  local m=self.metrics or {}
  if (m.deaths or 0)>=3 then
    return "Morts frequentes : privilegie des ennemis plus faibles."
  end
  return "Aucune alerte prioritaire."
end
