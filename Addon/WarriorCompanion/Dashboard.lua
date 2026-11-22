local _, WC = ...
local function makeLabel(parent, font, x, y, width, height)
  local text = parent:CreateFontString(nil, "OVERLAY", font)
  text:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
  text:SetWidth(width)
  text:SetHeight(height)
  text:SetJustifyH("LEFT")
  text:SetJustifyV("TOP")
  return text
end

function WC:CreateDashboard()
  if self.dashboard then return end
  local f = CreateFrame("Frame", "WarriorCompanionDashboard", UIParent)
  f:SetSize(350, 238)
  f:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
  f:SetFrameStrata("DIALOG")
  f:EnableMouse(true)
  f:SetMovable(true)
  f:RegisterForDrag("LeftButton")
  f:SetScript("OnDragStart", function(frame) frame:StartMoving() end)
  f:SetScript("OnDragStop", function(frame) frame:StopMovingOrSizing() end)
  local background = f:CreateTexture(nil, "BACKGROUND")
  background:SetAllPoints(f)
  background:SetTexture("Interface\\Buttons\\WHITE8X8")
  background:SetVertexColor(0.05, 0.07, 0.10, 0.94)
  makeLabel(f, "GameFontNormalLarge", 12, -14, 310, 22):SetText("Warrior Companion")
  self.dashboardStats = makeLabel(f, "GameFontHighlight", 12, -51, 320, 70)
  self.dashboardAdvice = makeLabel(f, "GameFontHighlightSmall", 12, -137, 320, 78)
  local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
  close:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, 0)
  close:SetScript("OnClick", function() f:Hide() end)
  f:Hide()
  self.dashboard = f
end

function WC:RefreshDashboard()
  if not self.dashboard then return end
  local m = self.metrics
  local xp = self:XPPerHour()
  local money = self:MoneyDelta()
  self.dashboardStats:SetText(
    "XP gagnee : " .. tostring(m.xpGained) ..
    "   |   XP/h : " .. (xp and tostring(xp) or "attente") ..
    "\nMorts : " .. tostring(m.deaths) ..
    "   |   Quetes (journal) : " .. (m.questCount and tostring(m.questCount) or "inconnu") ..
    "\nVariation d'argent : " .. (money and tostring(money) .. " cuivre" or "indisponible"))
  self.dashboardAdvice:SetText("Conseils :\n" .. self:AdviceLines())
end

function WC:ToggleDashboard()
  if not self.dashboard then
    self:Print("Interface non initialise.")
    return
  end
  if self.dashboard:IsShown() then self.dashboard:Hide()
  else self:RefreshDashboard(); self.dashboard:Show() end
end
