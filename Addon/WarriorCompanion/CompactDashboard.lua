local _, WC = ...
-- Fenetre reduite permanente : 304 x 88 pixels, sans bouton de minimap.
-- Le tableau complet reste un frame distinct (600 x 360).
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
    if type(p.x)=="number" and type(p.y)=="number" and
       p.x==p.x and p.y==p.y and math.abs(p.x)<=4000 and math.abs(p.y)<=4000 then
      frame:SetPoint("CENTER",UIParent,"CENTER",p.x,p.y)
      return
    end
  end
  frame:SetPoint("CENTER",UIParent,"CENTER",0,-235)
end
function WC:CreateCompactDashboard()
  if self.compactDashboard then return end
  local f=CreateFrame("Frame","WarriorCompanionCompact",UIParent)
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
      if ok and wok and type(x)=="number" and type(y)=="number" and
         type(bx)=="number" and type(by)=="number" then
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
  expand:SetScript("OnClick",function() WC:OpenFullDashboard() end)
  self.compactExpand=expand
  -- Trois statistiques sur une ligne ; toute la largeur pour la monnaie.
  local names={{"XP",6,22},{"TEMPS",103,39},{"MORTS",210,43}}
  self.compactStats={}
  for i,item in ipairs(names) do
    font(f,item[2],-30,item[3],17,"GameFontNormalSmall",
      "|cffC9A987"..item[1].."|r")
    self.compactStats[i]=font(f,item[2]+item[3],-30,72,17,
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
    if not frame:IsShown() or type(delta)~="number" then return end
    elapsed=elapsed+delta
    if elapsed>=3 then elapsed=0;WC:RefreshCompactDashboard() end
  end)
end
-- Solde en cuivre ; deux chiffres minimum par denomination.
local function moneyParts(copper)
  if type(copper)~="number" or copper~=copper
      or copper==math.huge or copper==-math.huge then
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

-- Duree ecoulee depuis le debut de la session ; remise a zero avec /wc reset.
local function sessionTime(self)
  local started=self.metrics and self.metrics.started
  if type(started)~="number" or
      not self.Now or type(self:Now())~="number" then return "--:--:--" end
  local seconds=self:Now()-started
  if seconds<0 or seconds~=seconds then return "--:--:--" end
  seconds=math.floor(seconds)
  local hours=math.floor(seconds/3600)
  local minutes=math.floor(seconds%3600/60)
  return string.format("%02d:%02d:%02d",hours,minutes,seconds%60)
end
function WC:RefreshCompactDashboard()
  if not self.compactDashboard or not self.compactDashboard:IsShown() then return end
  local m=self.metrics or {}
  local balance=self.MoneyDelta and self:MoneyDelta()
  local values={
    tostring(m.xpGained or 0),sessionTime(self),
    tostring(m.deaths or 0),
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
function WC:ShowCompact()
  if not self.compactDashboard then self:CreateCompactDashboard() end
  if self.dashboard then self.dashboard:Hide() end
  self.compactDashboard:Show()
  self:Profile().displayMode="compact"
  self:RefreshCompactDashboard()
end
function WC:OpenFullDashboard()
  if not self.dashboard then return end
  if self.UpdateAdvice then self:UpdateAdvice() end
  if self.compactDashboard then self.compactDashboard:Hide() end
  self.dashboard:Show()
  self:Profile().displayMode="full"
  self:RefreshDashboard()
end
function WC:ToggleDashboard()
  if self.dashboard and self.dashboard:IsShown() then
    self:ShowCompact()
  else
    self:OpenFullDashboard()
  end
end
function WC:AutoOpenDashboard()
  if self.didAutoOpen then return end
  self.didAutoOpen=true
  if not self:Profile().autoOpen then return end
  if self:Profile().displayMode=="full" then self:OpenFullDashboard()
  else self:ShowCompact() end
end
