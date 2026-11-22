local _, WC = ...

-- Theme original "Horde guerrier" : textures et polices fournies par WoW uniquement.
-- Aucune dependance ni texture externe. Interface discrète hors combat.
local THEME = {
  iron = { 0.055, 0.045, 0.045, 0.97 },
  plate = { 0.13, 0.09, 0.08, 0.97 },
  blood = { 0.52, 0.075, 0.055, 1 },
  ember = { 0.83, 0.34, 0.13, 1 },
  bronze = { 0.55, 0.39, 0.22, 1 },
  muted = { 0.26, 0.18, 0.15, 1 },
}

local function colored(text, color)
  return "|cff" .. color .. tostring(text) .. "|r"
end

local function plate(parent, anchorX, anchorY, width, height, color)
  local bg = parent:CreateTexture(nil, "BACKGROUND")
  bg:SetTexture("Interface\\Buttons\\WHITE8X8")
  bg:SetPoint("TOPLEFT", parent, "TOPLEFT", anchorX, anchorY)
  bg:SetSize(width, height)
  bg:SetVertexColor(color[1], color[2], color[3], color[4])
  return bg
end

local function textAt(frame, style, x, y, width, height)
  local label = frame:CreateFontString(nil, "OVERLAY", style)
  label:SetPoint("TOPLEFT", frame, "TOPLEFT", x, y)
  label:SetWidth(width)
  label:SetHeight(height)
  label:SetJustifyH("LEFT")
  label:SetJustifyV("TOP")
  return label
end

local function section(frame, title, y, height)
  plate(frame, 12, y, 404, height, THEME.plate)
  plate(frame, 12, y, 4, height, THEME.blood)
  plate(frame, 16, y, 400, 2, THEME.bronze)
  textAt(frame, "GameFontNormal", 24, y - 10, 370, 18):SetText(colored(title, "E9B267"))
end

local function displayNumber(value, fallback)
  if type(value) == "number" then return tostring(value) end
  return fallback or "--"
end

function WC:CreateDashboard()
  if self.dashboard then return end
  local f = CreateFrame("Frame", "WarriorCompanionDashboard", UIParent)
  f:SetSize(428, 475)
  f:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
  f:SetFrameStrata("DIALOG")
  f:EnableMouse(true)
  f:SetMovable(true)
  f:RegisterForDrag("LeftButton")
  f:SetScript("OnDragStart", function(frame) frame:StartMoving() end)
  f:SetScript("OnDragStop", function(frame) frame:StopMovingOrSizing() end)

  local base = f:CreateTexture(nil, "BACKGROUND")
  base:SetTexture("Interface\\Buttons\\WHITE8X8")
  base:SetAllPoints(f)
  base:SetVertexColor(THEME.iron[1], THEME.iron[2], THEME.iron[3], THEME.iron[4])
  plate(f, 0, 0, 428, 54, THEME.plate)
  plate(f, 0, -52, 428, 3, THEME.blood)
  plate(f, 0, -471, 428, 4, THEME.bronze)
  plate(f, 0, 0, 4, 475, THEME.bronze)
  plate(f, 424, 0, 4, 475, THEME.bronze)

  -- Emblème de classe embarqué dans l'interface du jeu.
  local emblem = f:CreateTexture(nil, "ARTWORK")
  emblem:SetTexture("Interface\\Icons\\Ability_Warrior_BattleShout")
  emblem:SetPoint("TOPLEFT", f, "TOPLEFT", 14, -10)
  emblem:SetSize(34, 34)

  textAt(f, "GameFontNormalLarge", 60, -10, 308, 23)
    :SetText(colored("WARRIOR COMPANION", "F1C17B"))
  textAt(f, "GameFontHighlightSmall", 61, -33, 310, 17)
    :SetText(colored("HORDE  /  RAPPORT DE CAMPAGNE", "C47C68"))

  local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
  close:SetPoint("TOPRIGHT", f, "TOPRIGHT", -3, -5)
  close:SetScript("OnClick", function() f:Hide() end)

  section(f, "PROGRESSION", -68, 119)
  self.dashboardStats = textAt(f, "GameFontHighlight", 27, -96, 375, 78)
  section(f, "COMBAT", -197, 89)
  self.dashboardCombat = textAt(f, "GameFontHighlight", 27, -225, 375, 54)
  section(f, "CONSEILS DU GUERRIER", -296, 92)
  self.dashboardAdvice = textAt(f, "GameFontHighlightSmall", 27, -324, 375, 57)
  section(f, "DERNIERES ACTIVITES", -398, 62)
  self.dashboardActivity = textAt(f, "GameFontHighlightSmall", 27, -425, 375, 32)
  self.dashboardFooter = textAt(f, "GameFontHighlightSmall", 16, -463, 400, 12)
  self.dashboardFooter:SetText(colored("/wc help   |   /wc reset   |   /wc history", "B28F74"))

  -- Rafraîchit les durées affichées sans répéter les alertes ou relire le journal.
  local elapsed = 0
  f:SetScript("OnUpdate", function(frame, delta)
    if not frame:IsShown() or type(delta) ~= "number" then return end
    elapsed = elapsed + delta
    if elapsed >= 3 then
      elapsed = 0
      WC:RefreshDashboard()
    end
  end)

  f:Hide()
  self.dashboard = f
end

function WC:RefreshDashboard()
  if not self.dashboard or not self.dashboard:IsShown() then return end
  local m = self.metrics
  local sessionXP = self:XPPerHour()
  local recentXP = self:RecentXPPerHour()
  local combat = self:GetCombatSummary()
  local money = self:MoneyDelta()

  self.dashboardStats:SetText(
    colored("XP GAGNEE", "DFA06D") .. "  " .. colored(displayNumber(m.xpGained, "0"), "FFF0D4") ..
    "     " .. colored("MORTS", "DFA06D") .. "  " .. displayNumber(m.deaths, "0") ..
    "\n" .. colored("XP/H SESSION", "DFA06D") .. "  " ..
    colored(displayNumber(sessionXP, m.xpAvailable and "calcul..." or "indisponible"), "FFF0D4") ..
    "\n" .. colored("XP/H 10 MIN", "DFA06D") .. "  " ..
    colored(displayNumber(recentXP, "calcul..."), "FFF0D4") ..
    "\n" .. colored("QUETES", "DFA06D") .. "  " .. displayNumber(m.questCount) ..
    "     " .. colored("ARGENT", "DFA06D") .. "  " ..
    (type(money) == "number" and (money >= 0 and "+" or "") .. tostring(money) .. " cuivre" or "--")
  )

  self.dashboardCombat:SetText(
    colored("INTERVALLES TERMINES", "DFA06D") .. "  " ..
      colored(displayNumber(combat.completed, "0"), "FFF0D4") ..
    "     " .. colored("INTERROMPUS", "DFA06D") .. "  " .. displayNumber(combat.interrupted, "0") ..
    "\n" .. colored("DUREE MOYENNE", "DFA06D") .. "  " ..
      (combat.average and tostring(combat.average) .. " s" or "--") ..
    "     " .. colored("ETAT", "DFA06D") .. "  " ..
      (combat.active and colored("EN COMBAT", "FF6E58") or "Repos")
  )

  local advice = self:AdviceLines()
  if not advice or advice == "" then advice = "Aucun conseil verifie pour le moment." end
  self.dashboardAdvice:SetText(advice)

  local activities = self.activity or {}
  local lines = {}
  for i = #activities, math.max(1, #activities - 1), -1 do
    local row = activities[i]
    if row and type(row.description) == "string" then
      lines[#lines + 1] = colored("> ", "C96845") .. row.description
    end
  end
  if #lines == 0 then lines[1] = "Aucune activite enregistree." end
  self.dashboardActivity:SetText(table.concat(lines, "\n"))
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
