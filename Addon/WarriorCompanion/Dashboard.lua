local _, WC = ...

-- HUD Horde : direction artistique originale, textures TGA fournies avec l'addon.
-- Compatible avec Lua 5.1 : pas de backdrops ni d'API Retail obligatoires.
local ROOT = "Interface\\AddOns\\WarriorCompanion\\Textures\\"
local COLORS = {
  black = {0.035, 0.029, 0.034, 0.98},
  steel = {0.090, 0.083, 0.087, 0.97},
  darkPlate = {0.13, 0.096, 0.101, 0.97},
  ridge = {0.34, 0.235, 0.20, 1},
  copper = {0.69, 0.40, 0.24, 1},
  gold = {0.85, 0.64, 0.36, 1},
  blood = {0.46, 0.062, 0.050, 1},
  litBlood = {0.65, 0.115, 0.080, 1},
  faded = {0.20, 0.14, 0.14, 0.95},
}
local function tint(text, hex)
  return "|cff" .. hex .. tostring(text) .. "|r"
end

local function rectangle(parent, x, y, width, height, rgba, layer)
  local t = parent:CreateTexture(nil, layer or "BACKGROUND")
  t:SetTexture("Interface\\Buttons\\WHITE8X8")
  t:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
  t:SetSize(width, height)
  t:SetVertexColor(rgba[1], rgba[2], rgba[3], rgba[4])
  return t
end

local function picture(parent, path, x, y, width, height, layer)
  local t = parent:CreateTexture(nil, layer or "ARTWORK")
  t:SetTexture(path)
  t:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
  t:SetSize(width, height)
  return t
end

local function text(parent, font, x, y, width, height, value)
  local t = parent:CreateFontString(nil, "OVERLAY", font)
  t:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
  t:SetWidth(width)
  t:SetHeight(height)
  t:SetJustifyH("LEFT")
  t:SetJustifyV("TOP")
  if value ~= nil then t:SetText(value) end
  return t
end

-- Armature noire bordée de métal : feuillets empilés, bronze, rivets et angles.
local function metalPlate(parent, x, y, width, height, active)
  rectangle(parent, x, y, width, height, COLORS.ridge)
  rectangle(parent, x + 2, y - 2, width - 4, height - 4, COLORS.black)
  rectangle(parent, x + 4, y - 4, width - 8, height - 8,
    active and COLORS.darkPlate or COLORS.steel)
  rectangle(parent, x + 4, y - 4, width - 8, 2,
    active and COLORS.litBlood or COLORS.copper)
  rectangle(parent, x + 4, y - height + 5, width - 8, 2, COLORS.faded)
  for _, dx in ipairs({8, width - 12}) do
    rectangle(parent, x + dx, y - 8, 4, 4, COLORS.gold, "ARTWORK")
    rectangle(parent, x + dx, y - height + 12, 4, 4, COLORS.ridge, "ARTWORK")
  end
end

local function fmt(value, fallback)
  if type(value) == "number" then return tostring(value) end
  return fallback or "--"
end

function WC:MoneyParts(value)
  if type(value) ~= "number" or value ~= value
      or value == math.huge or value == -math.huge then return nil end
  local n = math.floor(math.abs(value))
  return value < 0 and "-" or (value > 0 and "+" or ""),
    math.floor(n / 10000), math.floor(n % 10000 / 100), n % 100
end

local function stat(parent, x, heading, imagePath)
  metalPlate(parent, x, -4, 121, 57)
  if imagePath then picture(parent, imagePath, x + 9, -12, 19, 19) end
  local offset = imagePath and 32 or 10
  text(parent, "GameFontNormalSmall", x + offset, -11, 90, 17,
    tint(heading, "E5B776"))
  return text(parent, "GameFontHighlightLarge", x + 10, -31, 106, 25)
end

local function tab(parent, key, y, iconPath, name)
  local frame = CreateFrame("Button", nil, parent)
  frame:SetPoint("TOPLEFT", parent, "TOPLEFT", 4, y)
  frame:SetSize(55, 52)
  frame.base = rectangle(frame, 0, 0, 55, 51, COLORS.darkPlate)
  frame.accent = rectangle(frame, 0, 0, 3, 51, COLORS.ridge)
  picture(frame, iconPath, 16, -5, 23, 23)
  text(frame, "GameFontNormalSmall", 2, -31, 52, 17,
    tint(name, "DAB68E"))
  frame:SetScript("OnClick", function() WC:ShowDashboardPage(key) end)
  return frame
end

local function noteBox(parent, x, y, w, h, name, iconPath)
  metalPlate(parent, x, y, w, h)
  if iconPath then picture(parent, iconPath, x + 10, y - 9, 20, 20) end
  text(parent, "GameFontNormal", x + (iconPath and 34 or 11), y - 11,
    w - 45, 18, tint(name, "EBC487"))
end

local function createSubPage(parent, heading, iconPath)
  noteBox(parent, 0, -4, 512, 237, heading, iconPath)
  return text(parent, "GameFontHighlight", 15, -43, 482, 184)
end

function WC:CreateDashboard()
  if self.dashboard then return end
  local f = CreateFrame("Frame", "WarriorCompanionDashboard", UIParent)
  f:SetSize(600, 360)
  f:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
  f:SetFrameStrata("DIALOG")
  f:EnableMouse(true)
  f:SetMovable(true)
  f:RegisterForDrag("LeftButton")
  f:SetScript("OnDragStart", function(frame) frame:StartMoving() end)
  f:SetScript("OnDragStop", function(frame) frame:StopMovingOrSizing() end)

  rectangle(f, 0, 0, 600, 360, COLORS.ridge)
  rectangle(f, 3, -3, 594, 354, COLORS.black)
  rectangle(f, 4, -4, 592, 48, COLORS.darkPlate)
  picture(f, ROOT .. "HordeSky", 322, -4, 274, 48)
  rectangle(f, 4, -51, 592, 3, COLORS.litBlood)
  rectangle(f, 3, -55, 60, 300, COLORS.darkPlate)
  rectangle(f, 63, -55, 2, 300, COLORS.ridge)
  rectangle(f, 3, -356, 594, 4, COLORS.copper)

  picture(f, ROOT .. "Warcrest", 8, -4, 48, 48)
  text(f, "GameFontNormalLarge", 63, -9, 257, 22,
    tint("WARRIOR COMPANION", "F7DCAB"))
  text(f, "GameFontHighlightSmall", 64, -31, 256, 16,
    tint("HORDE  /  RAPPORT DE CAMPAGNE", "D49A7D"))
  local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
  close:SetPoint("TOPRIGHT", f, "TOPRIGHT", -1, -2)
  close:SetScript("OnClick", function() f:Hide() end)

  local function contentPage()
    local p = CreateFrame("Frame", nil, f)
    p:SetSize(515, 285)
    p:SetPoint("TOPLEFT", f, "TOPLEFT", 72, -61)
    return p
  end

  self.dashboardPages = {
    overview = contentPage(), combat = contentPage(),
    advice = contentPage(), activity = contentPage(), quests = contentPage()
  }
  self.dashboardTabs = {}
  local tabs = {
    {"overview", -62, "Interface\\Icons\\INV_Misc_Book_11", "BILAN"},
    {"combat", -120, "Interface\\Icons\\Ability_Warrior_Charge", "COMBAT"},
    {"advice", -178, "Interface\\Icons\\Ability_Warrior_BattleShout", "CONSEILS"},
    {"activity", -236, "Interface\\Icons\\INV_Misc_Note_01", "JOURNAL"},
    {"quests", -294, "Interface\\Icons\\INV_Misc_Map_01", "QUETES"},
  }
  for _, item in ipairs(tabs) do
    self.dashboardTabs[item[1]] = tab(f, item[1], item[2], item[3], item[4])
  end

  local p = self.dashboardPages.overview
  self.dashboardXP = stat(p, 0, "XP GAGNEE", "Interface\\Icons\\INV_Misc_Book_11")
  self.dashboardSessionRate = stat(p, 130, "XP/H SESSION",
    "Interface\\Icons\\Spell_Holy_BorrowedTime")
  self.dashboardRecentRate = stat(p, 260, "XP/H 10 MIN",
    "Interface\\Icons\\Spell_Holy_BorrowedTime")
  self.dashboardDeaths = stat(p, 390, "MORTS",
    "Interface\\Icons\\Ability_Rogue_FeignDeath")

  metalPlate(p, 0, -68, 511, 38)
  picture(p, "Interface\\Icons\\INV_Misc_Note_01", 10, -76, 20, 20)
  text(p, "GameFontNormalSmall", 36, -74, 71, 20,
    tint("QUETES", "E6BC81"))
  self.dashboardQuests = text(p, "GameFontHighlight", 98, -74, 45, 20)
  text(p, "GameFontNormalSmall", 151, -74, 62, 20,
    tint("ARGENT", "E6BC81"))
  self.dashboardMoney = { digits = {} }
  self.dashboardMoney.sign = text(p, "GameFontHighlight", 208, -74, 22, 20)
  for i, coin in ipairs({"Gold", "Silver", "Copper"}) do
    local px = 233 + (i-1)*90
    self.dashboardMoney.digits[i] =
      text(p, "GameFontHighlight", px, -74, 55, 20)
    picture(p, "Interface\\MoneyFrame\\UI-"..coin.."Icon",
      px + 49, -74, 18, 18)
  end

  noteBox(p, 0, -115, 249, 94, "COMBAT",
    "Interface\\Icons\\Ability_Warrior_Charge")
  self.dashboardCombat = text(p, "GameFontHighlight", 13, -147, 229, 59)
  noteBox(p, 259, -115, 252, 94, "CONSEIL DU GUERRIER",
    "Interface\\Icons\\Ability_Warrior_BattleShout")
  self.dashboardAdvice = text(p, "GameFontHighlightSmall", 271, -147, 230, 59)

  noteBox(p, 0, -218, 511, 65, "DERNIERES ACTIVITES",
    "Interface\\Icons\\INV_Misc_Note_01")
  self.dashboardActivity = text(p, "GameFontHighlightSmall", 13, -247, 485, 34)

  self.dashboardCombatDetail = createSubPage(
    self.dashboardPages.combat, "RAPPORT DE COMBAT",
    "Interface\\Icons\\Ability_Warrior_Charge")
  self.dashboardAdviceDetail = createSubPage(
    self.dashboardPages.advice, "CONSEILS DU GUERRIER",
    "Interface\\Icons\\Ability_Warrior_BattleShout")
  self.dashboardActivityDetail = createSubPage(
    self.dashboardPages.activity, "JOURNAL DE SESSION",
    "Interface\\Icons\\INV_Misc_Note_01")

  local questPage = self.dashboardPages.quests
  noteBox(questPage, 0, -4, 512, 237, "PLAN DE LEVELING",
    "Interface\\Icons\\INV_Misc_Map_01")
  local options = {
    {"journal", "JOURNAL", 11, 111},
    {"discover", "A PRENDRE", 130, 117},
    {"route", "PARCOURS", 255, 117},
    {"guide", "GUIDE", 378, 117},
  }
  self.dashboardQuestButtons = {}
  for _, data in ipairs(options) do
    local button = CreateFrame("Button", nil, questPage)
    button:SetSize(data[4], 26)
    button:SetPoint("TOPLEFT", questPage, "TOPLEFT", data[3], -40)
    rectangle(button, 0, 0, data[4], 26, COLORS.ridge)
    rectangle(button, 2, -2, data[4]-4, 22, COLORS.darkPlate)
    text(button, "GameFontNormalSmall", 7, -5, data[4]-12, 18,
      tint(data[2], "F0C58A"))
    local mode = data[1]
    button:SetScript("OnClick", function() WC:SelectQuestPlan(mode) end)
    self.dashboardQuestButtons[mode] = button
  end
  local function stepButton(label, x, direction)
    local b = CreateFrame("Button", nil, questPage)
    b:SetPoint("TOPLEFT", questPage, "TOPLEFT", x, -241)
    b:SetSize(106, 25)
    rectangle(b, 0, 0, 106, 25, COLORS.ridge)
    rectangle(b, 2, -2, 102, 21, COLORS.darkPlate)
    text(b, "GameFontNormalSmall", 7, -5, 96, 18, tint(label, "F0C58A"))
    b:SetScript("OnClick", function()
      if WC.GuideMove and WC:GuideMove(direction) then
        WC:SelectQuestPlan("guide")
      end
    end)
    return b
  end
  self.dashboardGuidePrev = stepButton("< Precedente", 13, -1)
  self.dashboardGuideNext = stepButton("Suivante >", 132, 1)
  self.dashboardQuestTitle = text(questPage, "GameFontNormalSmall", 13, -77,
    484, 17, tint("Choisis une vue de quetes", "E9C58D"))
  self.dashboardQuestDetail = text(questPage, "GameFontHighlightSmall", 13,
    -99, 484, 139, "Journal, quetes a prendre, ou departs regroupes.\n" ..
      "Les parcours ne sont pas encore des itinéraires verifies.")

  text(f, "GameFontHighlightSmall", 75, -343, 507, 15,
    tint("/wc help     /wc reset     /wc performance", "C1A08A"))
  self.dashboard = f
  self:ShowDashboardPage("overview")
  f:Hide()

  -- Rafraichissement visuel uniquement, sans relancer les notifications.
  local since = 0
  f:SetScript("OnUpdate", function(frame, delta)
    if not frame:IsShown() or type(delta) ~= "number" then return end
    since = since + delta
    if since >= 3 then
      since = 0
      WC:RefreshDashboard()
    end
  end)
end

function WC:ShowDashboardPage(page)
  if not self.dashboardPages or not self.dashboardPages[page] then return end
  self.dashboardPage = page
  for key, frame in pairs(self.dashboardPages) do
    if key == page then frame:Show() else frame:Hide() end
    local tabFrame = self.dashboardTabs[key]
    if tabFrame then
      local color = key == page and COLORS.blood or COLORS.darkPlate
      tabFrame.base:SetVertexColor(color[1], color[2], color[3], color[4])
      local metal = key == page and COLORS.gold or COLORS.ridge
      tabFrame.accent:SetVertexColor(metal[1], metal[2], metal[3], metal[4])
    end
  end
  self:RefreshDashboard()
end

local function activityLines(list, limit)
  if type(list) ~= "table" or #list == 0 then
    return "Aucune activite enregistree."
  end
  local lines = {}
  for i = #list, math.max(1, #list - limit + 1), -1 do
    local e = list[i]
    if e and type(e.description) == "string" then
      lines[#lines + 1] = tint("> ", "D9634D") .. e.description
    end
  end
  return #lines > 0 and table.concat(lines, "\n") or
    "Aucune activite enregistree."
end

function WC:RefreshDashboard()
  if not self.dashboard or not self.dashboard:IsShown() then return end
  local m = self.metrics
  local recent = self:RecentXPPerHour()
  local session = self:XPPerHour()
  local combat = self:GetCombatSummary()
  local coins = self:MoneyDelta()
  self.dashboardXP:SetText(fmt(m.xpGained, "0"))
  self.dashboardSessionRate:SetText(fmt(session, m.xpAvailable and "calcul..." or "--"))
  self.dashboardRecentRate:SetText(fmt(recent, "--"))
  self.dashboardDeaths:SetText(fmt(m.deaths, "0"))
  self.dashboardQuests:SetText(fmt(m.questCount))

  local sign, gold, silver, copper = self:MoneyParts(coins)
  self.dashboardMoney.sign:SetText(sign or "")
  self.dashboardMoney.digits[1]:SetText(fmt(gold))
  self.dashboardMoney.digits[2]:SetText(fmt(silver))
  self.dashboardMoney.digits[3]:SetText(fmt(copper))

  local combatText = "Intervalles : " .. fmt(combat.completed, "0") ..
    "     Duree moy. : " ..
    (combat.average and tostring(combat.average) .. " s" or "--") ..
    "\nInterrompus : " .. fmt(combat.interrupted, "0") ..
    "     Etat : " ..
    (combat.active and tint("En combat", "FC7A67") or tint("Repos", "75D483"))
  self.dashboardCombat:SetText(combatText)
  self.dashboardCombatDetail:SetText(combatText ..
    "\nMorts en combat : " .. fmt(combat.deathsInCombat, "0") ..
    "\n\nUn intervalle n'est pas necessairement un ennemi tue.")

  local advice = self:AdviceLines()
  if type(advice) ~= "string" or advice == "" then
    advice = "Aucun conseil verifie pour le moment."
  end
  self.dashboardAdvice:SetText((advice:match("([^\n]+)")) or advice)
  self.dashboardAdviceDetail:SetText(advice)
  self.dashboardActivity:SetText(activityLines(self.activity, 2))
  self.dashboardActivityDetail:SetText(activityLines(self.activity, 8))
  -- Seul le guide charge est relu sans lancer de recherche QuestieDB.
  if self.questPlanMode == "guide" and self.GetGuideView then
    local view = self:GetGuideView()
    self.dashboardQuestTitle:SetText(view and view.title or "Guide : aucun parcours charge")
    self.dashboardQuestDetail:SetText(view and
      ((view.status or "") .. "\n\n" .. (view.steps or "")) or
      "Les guides existants doivent etre importes puis verifies pour Forever.")
  end
  -- Donnees des quetes mises a jour uniquement au clic explicite.
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
