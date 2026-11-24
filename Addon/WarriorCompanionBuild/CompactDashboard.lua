local _, B = ...
local function safeNumber(value)
  if type(B.SafeNumber)~="function" then return nil end
  return B:SafeNumber(value)
end
-- Portage fidele du HUD original 304x88 : XP, temps, morts, solde, conseil.
-- Le guide complet utilise une fenetre distincte ; minimap toujours accessible.
local function font(parent, x, y, w, h, family, value)
  local t=parent:CreateFontString(nil,"OVERLAY",family)
  t:SetPoint("TOPLEFT",parent,"TOPLEFT",x,y)
  t:SetWidth(w);t:SetHeight(h)
  t:SetJustifyH("LEFT");t:SetJustifyV("MIDDLE")
  if value then t:SetText(value) end
  return t
end
local function block(parent,x,y,w,h,r,g,b)
  local t=parent:CreateTexture(nil,"BACKGROUND")
  t:SetTexture("Interface\\Buttons\\WHITE8X8")
  t:SetPoint("TOPLEFT",parent,"TOPLEFT",x,y);t:SetSize(w,h)
  t:SetVertexColor(r,g,b,1)
  return t
end
local function goodPoint(frame,options)
  if type(options.compactPoint)=="table" then
    local p=options.compactPoint
    local x,y=safeNumber(p.x),safeNumber(p.y)
    if x and y and math.abs(x)<=4000 and math.abs(y)<=4000 then
      frame:SetPoint("CENTER",UIParent,"CENTER",x,y)
      return
    end
  end
  frame:SetPoint("CENTER",UIParent,"CENTER",0,-235)
end
function B:CreateCompactDashboard()
  if self.compactDashboard then return end
  local f=CreateFrame("Frame","WarriorCompanionBuildCompact",UIParent)
  f:SetSize(304,88)
  f:SetFrameStrata("DIALOG")
  f:EnableMouse(true);f:SetMovable(true);f:RegisterForDrag("LeftButton")
  goodPoint(f,self:Profile())
  f:SetScript("OnDragStart",function(frame) frame:StartMoving() end)
  f:SetScript("OnDragStop",function(frame)
    frame:StopMovingOrSizing()
    if type(frame.GetCenter)=="function" and
       type(UIParent.GetCenter)=="function" then
      local ok,x,y=pcall(frame.GetCenter,frame)
      local wok,bx,by=pcall(UIParent.GetCenter,UIParent)
      x,y=safeNumber(x),safeNumber(y)
      bx,by=safeNumber(bx),safeNumber(by)
      if ok and wok and x and y and bx and by then
        local dx,dy=x-bx,y-by
        if math.abs(dx)<=4000 and math.abs(dy)<=4000 then
          self:Profile().compactPoint={x=dx,y=dy}
        end
      end
    end
  end)
  block(f,0,0,304,88,.48,.30,.19)
  block(f,2,-2,300,84,.065,.045,.05)
  block(f,3,-3,298,21,.20,.065,.055)
  block(f,3,-24,298,1,.67,.23,.17)
  font(f,9,-4,252,18,"GameFontNormalSmall",
       "|cffF2D3A0WARRIOR COMPANION|r  |cffB19B8FMini-bilan|r")
  local expand=CreateFrame("Button",nil,f)
  expand:SetPoint("TOPRIGHT",f,"TOPRIGHT",-4,-3)
  expand:SetSize(27,19)
  block(expand,0,0,27,19,.53,.29,.16)
  block(expand,2,-2,23,15,.12,.07,.06)
  font(expand,6,-1,20,17,"GameFontNormalSmall",">>")
  expand:SetScript("OnClick",function() B:OpenFullDashboard() end)
  self.compactExpand=expand
  -- Trois statistiques sur une ligne ; toute la largeur pour la monnaie.
  local names={{"XP",6,20,53},{"TEMPS",83,42,79},{"MORTS",211,40,43}}
  self.compactStats={}
  for i,item in ipairs(names) do
    font(f,item[2],-30,item[3],17,"GameFontNormalSmall",
      "|cffC9A987"..item[1].."|r")
    self.compactStats[i]=font(f,item[2]+item[3],-30,item[4],17,
      "GameFontHighlightSmall")
  end
  block(f,5,-49,294,1,.35,.21,.17)
  font(f,7,-52,59,15,"GameFontNormalSmall","|cffC9A987SOLDE|r")
  self.compactMoneySign=font(f,67,-52,15,15,"GameFontHighlightSmall")
  self.compactMoneyParts={}
  local positions={83,154,225}
  local coins={"Gold","Silver","Copper"}
  for i=1,3 do
    self.compactMoneyParts[i]=font(f,positions[i],-52,38,15,
      "GameFontHighlightSmall")
    local coin=f:CreateTexture(nil,"ARTWORK")
    coin:SetTexture("Interface\\MoneyFrame\\UI-"..coins[i].."Icon")
    coin:SetPoint("TOPLEFT",f,"TOPLEFT",positions[i]+35,-52)
    coin:SetSize(14,14)
  end
  block(f,5,-69,294,1,.35,.21,.17)
  self.compactAdvice=font(f,8,-70,289,14,"GameFontHighlightSmall")
  self.compactDashboard=f
  f:Hide()
  local elapsed=0
  f:SetScript("OnUpdate",function(frame,delta)
    delta=safeNumber(delta)
    if not frame:IsShown() or not delta then return end
    elapsed=elapsed+delta
    if elapsed>=3 then elapsed=0;B:RefreshCompactDashboard() end
  end)
end
-- Solde en cuivre ; deux chiffres minimum par denomination.
local function moneyParts(copper)
  copper=safeNumber(copper)
  if not copper then
    return "", "--", "--", "--", "unknown"
  end
  local n=math.floor(math.abs(copper))
  local sign=copper<0 and "-" or copper>0 and "+" or ""
  local gold=math.floor(n/10000)
  local silver=math.floor(n%10000/100)
  local bronze=n%100
  local state=copper<0 and "negative" or copper>0 and "positive" or "zero"
  return sign,string.format("%02d",gold),string.format("%02d",silver),
    string.format("%02d",bronze),state
end
local moneyColors={
  positive="|cff70DB8B", negative="|cffF17E78",
  zero="|cffD4D4D4",unknown="|cff888888"
}

-- Duree ecoulee depuis le debut de la session ; /wcb reset pour repartir.
local function sessionTime(self)
  local started=safeNumber(self.metrics and self.metrics.started)
  local now=self.Now and safeNumber(self:Now()) or nil
  if not started or not now then return "--:--:--" end
  local seconds=now-started
  if seconds<0 or seconds~=seconds then return "--:--:--" end
  seconds=math.floor(seconds)
  local hours=math.floor(seconds/3600)
  local minutes=math.floor(seconds%3600/60)
  return string.format("%02d:%02d:%02d",hours,minutes,seconds%60)
end
function B:RefreshCompactDashboard()
  if not self.compactDashboard or not self.compactDashboard:IsShown() then return end
  local m=self.metrics or {}
  local balance=self.MoneyDelta and self:MoneyDelta()
  local values={
    tostring(safeNumber(m.xpGained) or 0),sessionTime(self),
    tostring(safeNumber(m.deaths) or 0),
  }
  for i=1,3 do self.compactStats[i]:SetText(values[i]) end
  local sign,gold,silver,bronze,state=moneyParts(balance)
  local color=moneyColors[state]
  self.compactMoneySign:SetText(color..sign.."|r")
  for i,part in ipairs({gold,silver,bronze}) do
    self.compactMoneyParts[i]:SetText(color..part.."|r")
  end
  local advice=self.AdviceLines and self:AdviceLines() or ""
  local first=advice:match("([^\n]+)") or ""
  if first=="" or first=="Aucun conseil verifie pour le moment." then
    first="Aucune alerte prioritaire."
  end
  -- Un seule ligne sans texte multi-lignes pour tenir dans 304 px.
  if #first>68 then first=first:sub(1,65).."..." end
  self.compactAdvice:SetText(first)
end
-- Controle unifie des vues : aucun panneau complet impose a la connexion.
function B:Profile()
  return self.db or {}
end
function B:ShowCompact()
  if not self.compactDashboard then self:CreateCompactDashboard() end
  if self.frame then self.frame:Hide() end
  self.compactDashboard:Show()
  if self.db then self.db.displayMode="compact" end
  self:RefreshCompactDashboard()
end
function B:OpenFullDashboard()
  if not self.frame then self:CreateUI() end
  self.restoreMiniOnClose=self.compactDashboard and
    self.compactDashboard:IsShown() or false
  if self.compactDashboard then self.compactDashboard:Hide() end
  self:UpdateLevel()
  self.frame:Show()
  if self.db then self.db.displayMode="full" end
  self:Refresh()
end
function B:CloseFull()
  if self.frame then self.frame:Hide() end
  if self.restoreMiniOnClose then self:ShowCompact()
  elseif self.db then self.db.displayMode="hidden" end
  self.restoreMiniOnClose=false
end
function B:HideDashboard()
  if self.frame then self.frame:Hide() end
  if self.compactDashboard then self.compactDashboard:Hide() end
  self.restoreMiniOnClose=false
  if self.db then self.db.displayMode="hidden" end
end
-- Toggle minimap clic gauche : la grande application s'ouvre/ferme.
function B:ToggleDashboard()
  if self.frame and self.frame:IsShown() then
    self:CloseFull()
  else
    self:OpenFullDashboard()
  end
end
function B:ToggleCompact()
  if self.compactDashboard and self.compactDashboard:IsShown() then
    self:HideDashboard()
  else
    self:ShowCompact()
  end
end
function B:AutoOpenDashboard()
  if self.didAutoOpen then return end
  self.didAutoOpen=true
  if not self.db or self.db.autoOpen~=true then return end
  if self.db.displayMode=="full" then self:OpenFullDashboard()
  elseif self.db.displayMode=="compact" then self:ShowCompact() end
end
