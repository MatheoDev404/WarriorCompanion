local _, WC = ...
local function makeText(parent, size)
  local label = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  label:SetFont(STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF", size)
  label:SetJustifyH("LEFT")
  return label
end

function WC:CreateDashboard()
  if self.dashboard then return end
  local f = CreateFrame("Frame", "WarriorCompanionDashboard", UIParent)
  f:SetSize(310, 188)
  f:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
  f:SetFrameStrata("DIALOG")
  f:EnableMouse(true)
  f:SetMovable(true)
  f:RegisterForDrag("LeftButton")
  f:SetScript("OnDragStart", function(frame) frame:StartMoving() end)
  f:SetScript("OnDragStop", function(frame) frame:StopMovingOrSizing() end)
  local bg = f:CreateTexture(nil, "BACKGROUND")
  bg:SetAllPoints(f)
  bg:SetTexture("Interface\\Buttons\\WHITE8X8")
  bg:SetVertexColor(0.06, 0.08, 0.12, 0.94)

  local title = makeText(f, 14)
  title:SetPoint("TOPLEFT", f, "TOPLEFT", 12, -14)
  title:SetText("Warrior Companion")
  local subtitle = makeText(f, 11)
  subtitle:SetPoint("TOPLEFT", f, "TOPLEFT", 12, -43)
  subtitle:SetWidth(286)
  local stats = makeText(f, 12)
  stats:SetPoint("TOPLEFT", f, "TOPLEFT", 12, -68)
  stats:SetWidth(286)
  local advice = makeText(f, 11)
  advice:SetPoint("TOPLEFT", f, "TOPLEFT", 12, -109)
  advice:SetWidth(286)
  advice:SetHeight(56)
  advice:SetJustifyV("TOP")

  local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
  close:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, 0)
  close:SetScript("OnClick", function() f:Hide() end)
  f:Hide()
  self.dashboard = f
  self.dashboardSubtitle = subtitle
  self.dashboardStats = stats
  self.dashboardAdvice = advice
end

function WC:RefreshDashboard()
  if not self.dashboard then return end
  local xp = self:XPPerHour()
  self.dashboardSubtitle:SetText("Session en cours - " .. self.version)
  self.dashboardStats:SetText("XP gagnee : " .. tostring(self.metrics.xpGained) ..
    "  |  XP/h : " .. (xp and tostring(xp) or "attente") ..
    "\nMorts : " .. tostring(self.metrics.deaths))
  local first = self.alerts and self.alerts[1]
  self.dashboardAdvice:SetText(first and first.message or
    "Aucun conseil prioritaire verifie pour l'instant.")
end

function WC:ToggleDashboard()
  if not self.dashboard then return end
  if self.dashboard:IsShown() then self.dashboard:Hide()
  else self:RefreshDashboard(); self.dashboard:Show() end
end
