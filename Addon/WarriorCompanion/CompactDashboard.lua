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
  local names={{"XP",5},{"XP/H",75},{"MORTS",159},{"OR +/-",228}}
  self.compactStats={}
  for i,item in ipairs(names) do
    local x=item[2]
    font(f,x,-30,66,13,"GameFontNormalSmall","|cffC9A987"..item[1].."|r")
    self.compactStats[i]=font(f,x,-43,70,19,"GameFontHighlightSmall")
  end
  block(f,5,-67,294,1,.35,.21,.17)
  self.compactAdvice=font(f,8,-68,289,16,"GameFontHighlightSmall")
  self.compactDashboard=f
  f:Hide()
  local elapsed=0
  f:SetScript("OnUpdate",function(frame,delta)
    if not frame:IsShown() or type(delta)~="number" then return end
    elapsed=elapsed+delta
    if elapsed>=3 then elapsed=0;WC:RefreshCompactDashboard() end
  end)
end
-- Balance nette de la session, en pieces d'or. Montant de reference en cuivre.
local function goldBalance(copper)
  if type(copper)~="number" or copper~=copper or
      copper==math.huge or copper==-math.huge then return "--" end
  local gold=copper/10000
  local absolute=math.abs(gold)
  if absolute>=1000 then
    return string.format("%s%.1fk",gold<0 and "-" or "+",absolute/1000)
  end
  return string.format("%+.2f",gold)
end

function WC:RefreshCompactDashboard()
  if not self.compactDashboard or not self.compactDashboard:IsShown() then return end
  local m=self.metrics or {}
  local xp=self.XPPerHour and self:XPPerHour()
  local balance=self.MoneyDelta and self:MoneyDelta()
  local values={
    tostring(m.xpGained or 0),xp and tostring(math.floor(xp+.5)) or "--",
    tostring(m.deaths or 0),goldBalance(balance),
  }
  for i=1,4 do self.compactStats[i]:SetText(values[i]) end
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
