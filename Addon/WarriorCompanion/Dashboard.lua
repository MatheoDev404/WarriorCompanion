local _, WC = ...

-- HUD Horde compact : couleurs sombres et textures embarquees dans WoW.
-- Aucune texture externe, aucun appel reseau.
local C = {
  base = {0.055, 0.052, 0.063, 0.97},
  header = {0.13, 0.071, 0.075, 0.98},
  rail = {0.10, 0.072, 0.082, 0.98},
  panel = {0.115, 0.108, 0.120, 0.97},
  selected = {0.33, 0.085, 0.085, 1},
  bronze = {0.54, 0.34, 0.23, 1},
  red = {0.70, 0.13, 0.11, 1},
  subtle = {0.22, 0.18, 0.19, 0.90},
}

local function colorText(value, hex)
  return "|cff" .. hex .. tostring(value) .. "|r"
end

local function rect(parent, x, y, width, height, color)
  local t = parent:CreateTexture(nil, "BACKGROUND")
  t:SetTexture("Interface\\Buttons\\WHITE8X8")
  t:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
  t:SetSize(width, height)
  t:SetVertexColor(color[1], color[2], color[3], color[4])
  return t
end

local function label(parent, font, x, y, width, height, value)
  local s = parent:CreateFontString(nil, "OVERLAY", font)
  s:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
  s:SetWidth(width)
  s:SetHeight(height)
  s:SetJustifyH("LEFT")
  s:SetJustifyV("TOP")
  if value ~= nil then s:SetText(value) end
  return s
end

local function panel(parent, x, y, width, height)
  rect(parent, x, y, width, height, C.panel)
  rect(parent, x, y, width, 2, C.subtle)
  rect(parent, x, y, 3, height, C.bronze)
end

local function icon(parent, path, x, y, size)
  local t = parent:CreateTexture(nil, "ARTWORK")
  t:SetTexture(path)
  t:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
  t:SetSize(size, size)
  return t
end

local function formatValue(number, fallback)
  if type(number) == "number" then return tostring(number) end
  return fallback or "--"
end

-- Montants internes de WoW en cuivre. Le signe s'applique au montant total.
-- Ainsi -10005 devient "- 1 or 0 argent 5 cuivre", jamais 0 or -1 argent...
function WC:MoneyParts(value)
  if type(value) ~= "number" or value ~= value or value == math.huge
      or value == -math.huge then return nil end
  local abs = math.floor(math.abs(value))
  return value < 0 and "-" or (value > 0 and "+" or ""), 
    math.floor(abs / 10000), math.floor(abs % 10000 / 100), abs % 100
end

local function moneyStrip(parent, x, y)
  panel(parent, x, y, 460, 43)
  label(parent, "GameFontNormalSmall", x + 13, y - 12, 106, 18, "ARGENT")
  local sign = label(parent, "GameFontHighlight", x + 113, y - 10, 22, 20)
  local digits = {}
  local names = {"Gold", "Silver", "Copper"}
  for i = 1, 3 do
    local off = x + 132 + (i - 1) * 100
    digits[i] = label(parent, "GameFontHighlight", off, y - 10, 56, 22, "0")
    icon(parent, "Interface\\MoneyFrame\\UI-" .. names[i] .. "Icon", off + 53, y - 9, 17)
  end
  return {sign = sign, digits = digits}
end

local function card(parent, x, title, value)
  panel(parent, x, -12, 109, 79)
  label(parent, "GameFontNormalSmall", x + 10, -23, 95, 20, title)
  return label(parent, "GameFontHighlightLarge", x + 10, -47, 95, 36, value or "--")
end

function WC:CreateDashboard()
  if self.dashboard then return end
  local f = CreateFrame("Frame", "WarriorCompanionDashboard", UIParent)
  f:SetSize(560, 438)
  f:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
  f:SetFrameStrata("DIALOG")
  f:EnableMouse(true)
  f:SetMovable(true)
  f:RegisterForDrag("LeftButton")
  f:SetScript("OnDragStart", function(frame) frame:StartMoving() end)
  f:SetScript("OnDragStop", function(frame) frame:StopMovingOrSizing() end)

  local bg = f:CreateTexture(nil, "BACKGROUND")
  bg:SetTexture("Interface\\Buttons\\WHITE8X8")
  bg:SetAllPoints(f)
  bg:SetVertexColor(C.base[1], C.base[2], C.base[3], C.base[4])
  rect(f, 0, 0, 560, 59, C.header)
  rect(f, 0, -57, 560, 3, C.red)
  rect(f, 0, -60, 70, 378, C.rail)
  rect(f, 68, -60, 2, 378, C.bronze)
  rect(f, 0, -434, 560, 4, C.bronze)

  icon(f, "Interface\\Icons\\Ability_Warrior_BattleShout", 14, -10, 40)
  label(f, "GameFontNormalLarge", 66, -9, 422, 24, 
    colorText("WARRIOR COMPANION", "F2CE97"))
  label(f, "GameFontHighlightSmall", 67, -35, 422, 16,
    colorText("HORDE  /  ASSISTANT DE COMBAT", "BA8272"))

  local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
  close:SetPoint("TOPRIGHT", f, "TOPRIGHT", -3, -4)
  close:SetScript("OnClick", function() f:Hide() end)

  local function page()
    local p = CreateFrame("Frame", nil, f)
    p:SetSize(478, 363)
    p:SetPoint("TOPLEFT", f, "TOPLEFT", 78, -69)
    return p
  end

  local overview = page()
  self.dashboardPages = {
    overview = overview,
    combat = page(),
    advice = page(),
    activity = page(),
  }
  self.dashboardNav = {}
  local tabs = {
    {"overview", "BILAN", "Interface\\Icons\\INV_Misc_QuestionMark"},
    {"combat", "COMBAT", "Interface\\Icons\\Ability_Warrior_Charge"},
    {"advice", "CONSEILS", "Interface\\Icons\\Ability_Warrior_BattleShout"},
    {"activity", "JOURNAL", "Interface\\Icons\\INV_Misc_Note_01"},
  }
  for i, entry in ipairs(tabs) do
    local key, name, texture = entry[1], entry[2], entry[3]
    local button = CreateFrame("Button", nil, f)
    button:SetSize(64, 72)
    button:SetPoint("TOPLEFT", f, "TOPLEFT", 2, -72 - (i - 1) * 75)
    local active = rect(button, 0, 0, 63, 68, C.rail)
    icon(button, texture, 18, -4, 29)
    label(button, "GameFontNormalSmall", 5, -39, 55, 18, name)
    button:SetScript("OnClick", function() WC:ShowDashboardPage(key) end)
    self.dashboardNav[key] = active
  end

  self.dashboardXP = card(overview, 0, "XP GAGNEE")
  self.dashboardSessionRate = card(overview, 117, "XP/H SESSION")
  self.dashboardRecentRate = card(overview, 234, "XP/H 10 MIN")
  self.dashboardDeaths = card(overview, 351, "MORTS")

  self.dashboardMoney = moneyStrip(overview, 0, -100)
  label(overview, "GameFontHighlightSmall", 16, -164, 220, 18,
    colorText("COMBAT", "F3C37E"))
  panel(overview, 0, -155, 222, 106)
  self.dashboardCombat = label(overview, "GameFontHighlight", 13, -187, 197, 69)

  panel(overview, 234, -155, 226, 106)
  label(overview, "GameFontHighlightSmall", 246, -164, 206, 18,
    colorText("CONSEIL PRIORITAIRE", "F3C37E"))
  self.dashboardAdvice = label(overview, "GameFontHighlightSmall", 246, -187, 200, 69)

  panel(overview, 0, -272, 460, 81)
  label(overview, "GameFontNormalSmall", 12, -284, 425, 18, "DERNIERES ACTIVITES")
  self.dashboardActivity = label(overview, "GameFontHighlightSmall", 13, -305, 427, 42)

  local combatPage = self.dashboardPages.combat
  panel(combatPage, 0, -5, 460, 205)
  label(combatPage, "GameFontNormalLarge", 16, -19, 425, 27, "BILAN DES COMBATS")
  self.dashboardCombatDetail = label(combatPage, "GameFontHighlight", 17, -63, 419, 124)
  label(combatPage, "GameFontHighlightSmall", 17, -159, 417, 34,
    "Intervalles d'etat de combat, pas nombre d'ennemis tues.")

  local advicePage = self.dashboardPages.advice
  panel(advicePage, 0, -5, 460, 230)
  label(advicePage, "GameFontNormalLarge", 16, -19, 425, 27, "CONSEILS DU GUERRIER")
  self.dashboardAdviceDetail = label(advicePage, "GameFontHighlight", 17, -66, 420, 148)

  local activityPage = self.dashboardPages.activity
  panel(activityPage, 0, -5, 460, 286)
  label(activityPage, "GameFontNormalLarge", 16, -19, 425, 27, "JOURNAL DE SESSION")
  self.dashboardActivityDetail = label(activityPage, "GameFontHighlightSmall", 17, -65, 420, 210)

  self.dashboardFooter = label(f, "GameFontHighlightSmall", 87, -425, 460, 12,
    colorText("/wc help     /wc reset     /wc performance", "A99791"))

  -- Interface seule : pas de nouvel appel au moteur de conseils.
  local deltaTotal = 0
  f:SetScript("OnUpdate", function(frame, delta)
    if not frame:IsShown() or type(delta) ~= "number" then return end
    deltaTotal = deltaTotal + delta
    if deltaTotal >= 3 then
      deltaTotal = 0
      WC:RefreshDashboard()
    end
  end)

  self.dashboard = f
  self:ShowDashboardPage("overview")
  f:Hide()
end

function WC:ShowDashboardPage(pageName)
  if not self.dashboardPages or not self.dashboardPages[pageName] then return end
  self.dashboardPage = pageName
  for key, p in pairs(self.dashboardPages) do
    if key == pageName then p:Show() else p:Hide() end
    local color = key == pageName and C.selected or C.rail
    local marker = self.dashboardNav and self.dashboardNav[key]
    if marker then marker:SetVertexColor(color[1],color[2],color[3],color[4]) end
  end
  self:RefreshDashboard()
end

local function activityLines(activities, count)
  if type(activities) ~= "table" or #activities == 0 then
    return "Aucune activite enregistree."
  end
  local lines = {}
  for i = #activities, math.max(1, #activities - count + 1), -1 do
    local entry = activities[i]
    if entry and type(entry.description) == "string" then
      lines[#lines + 1] = colorText("> ", "D65F4D") .. entry.description
    end
  end
  return #lines > 0 and table.concat(lines, "\n") or "Aucune activite enregistree."
end

function WC:RefreshDashboard()
  if not self.dashboard or not self.dashboard:IsShown() then return end
  local m = self.metrics
  local rate = self:XPPerHour()
  local recent = self:RecentXPPerHour()
  local combat = self:GetCombatSummary()
  local amount = self:MoneyDelta()

  self.dashboardXP:SetText(formatValue(m.xpGained, "0"))
  self.dashboardSessionRate:SetText(formatValue(rate, m.xpAvailable and "calcul..." or "--"))
  self.dashboardRecentRate:SetText(formatValue(recent, "--"))
  self.dashboardDeaths:SetText(formatValue(m.deaths, "0"))

  local sign, gold, silver, copper = self:MoneyParts(amount)
  self.dashboardMoney.sign:SetText(sign or "")
  self.dashboardMoney.digits[1]:SetText(formatValue(gold))
  self.dashboardMoney.digits[2]:SetText(formatValue(silver))
  self.dashboardMoney.digits[3]:SetText(formatValue(copper))

  local combatText = "Termines : " .. formatValue(combat.completed, "0") ..
    "\nDuree moyenne : " .. (combat.average and tostring(combat.average) .. " s" or "--") ..
    "\nInterrompus : " .. formatValue(combat.interrupted, "0") ..
    "\nEtat : " .. (combat.active and colorText("En combat", "ED7774") or "Repos")
  self.dashboardCombat:SetText(combatText)
  self.dashboardCombatDetail:SetText(combatText ..
    "\nMorts en combat : " .. formatValue(combat.deathsInCombat, "0"))

  local advice = self:AdviceLines()
  if type(advice) ~= "string" or advice == "" then
    advice = "Aucun conseil verifie pour le moment."
  end
  self.dashboardAdvice:SetText(advice)
  self.dashboardAdviceDetail:SetText(advice)
  self.dashboardActivity:SetText(activityLines(self.activity, 2))
  self.dashboardActivityDetail:SetText(activityLines(self.activity, 8))
end

function WC:ToggleDashboard()
  if not self.dashboard then
    self:Print("Interface non initialise.")
    return
  end
  if self.dashboard:IsShown() then
    self.dashboard:Hide()
  else
    self:UpdateAdvice()
    self.dashboard:Show()
    self:RefreshDashboard()
  end
end
