local _, WC = ...

-- HUD Horde : direction artistique originale, textures TGA fournies avec l'addon.
-- Compatible avec Lua 5.1 : pas de backdrops ni d'API Retail obligatoires.
local ROOT = "Interface\\AddOns\\WarriorCompanion\\Textures\\"
local COLORS = {
  black = {0.055, 0.061, 0.067, 0.98},
  steel = {0.093, 0.101, 0.110, 0.97},
  darkPlate = {0.132, 0.144, 0.155, 0.98},
  ridge = {0.245, 0.260, 0.275, 1},
  copper = {0.56, 0.40, 0.25, 1},
  gold = {0.79, 0.59, 0.37, 1},
  blood = {0.26, 0.21, 0.17, 1},
  litBlood = {0.67, 0.49, 0.30, 1},
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

-- Panneau sobre : une surface, un filet de separation, aucun rivet.
local function metalPlate(parent, x, y, width, height, active)
  rectangle(parent, x, y, width, height,
    active and COLORS.darkPlate or COLORS.steel)
  rectangle(parent, x, y, width, 1, COLORS.ridge, "ARTWORK")
  rectangle(parent, x, y-height+1, width, 1, COLORS.ridge, "ARTWORK")
  rectangle(parent, x, y, 1, height, COLORS.ridge, "ARTWORK")
  rectangle(parent, x+width-1, y, 1, height, COLORS.ridge, "ARTWORK")
end

local function fmt(value, fallback)
  if type(value) == "number" then return tostring(value) end
  return fallback or "--"
end

local function tab(parent, key, y, iconPath, name)
  local frame = CreateFrame("Button", nil, parent)
  frame:SetPoint("TOPLEFT", parent, "TOPLEFT", 4, y)
  frame:SetSize(63, 61)
  frame.base = rectangle(frame, 0, 0, 63, 60, COLORS.darkPlate)
  frame.accent = rectangle(frame, 0, 0, 3, 60, COLORS.ridge)
  picture(frame, iconPath, 19, -7, 25, 25)
  text(frame, "GameFontNormalSmall", 2, -37, 59, 18,
    tint(name, "E9D9C4"))
  frame:SetScript("OnClick", function() WC:ShowDashboardPage(key) end)
  frame:SetScript("OnEnter", function()
    if WC.dashboardPage~=key then
      frame.base:SetVertexColor(0.22,0.24,0.25,1)
    end
  end)
  frame:SetScript("OnLeave", function()
    if WC.dashboardPage~=key then
      frame.base:SetVertexColor(COLORS.darkPlate[1],COLORS.darkPlate[2],COLORS.darkPlate[3],COLORS.darkPlate[4])
    end
  end)
  return frame
end

function WC:CreateDashboard()
  if self.dashboard then return end
  local f = CreateFrame("Frame", "WarriorCompanionDashboard", UIParent)
  f:SetSize(720, 460)
  f:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
  f:SetFrameStrata("DIALOG")
  f:EnableMouse(true)
  f:SetMovable(true)
  f:RegisterForDrag("LeftButton")
  f:SetScript("OnDragStart", function(frame) frame:StartMoving() end)
  f:SetScript("OnDragStop", function(frame) frame:StopMovingOrSizing() end)

  rectangle(f, 0, 0, 720, 460, COLORS.ridge)
  rectangle(f, 1, -1, 718, 458, COLORS.black)
  rectangle(f, 1, -1, 718, 51, COLORS.steel)
  rectangle(f, 1, -51, 718, 1, COLORS.copper)
  rectangle(f, 1, -53, 77, 405, COLORS.steel)
  rectangle(f, 77, -53, 1, 405, COLORS.ridge)
  rectangle(f, 1, -457, 718, 2, COLORS.copper)

  picture(f, ROOT .. "Warcrest", 13, -8, 32, 32)
  text(f, "GameFontNormalLarge", 56, -8, 336, 24,
    tint("WARRIOR COMPANION", "E9DFD2"))
  text(f, "GameFontHighlightSmall", 57, -31, 352, 16,
    tint("GUIDE DE PROGRESSION / HORDE", "C9A47B"))
  local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
  close:SetPoint("TOPRIGHT", f, "TOPRIGHT", -1, -2)
  close:SetScript("OnClick", function() WC:ShowCompact() end)

  local function contentPage()
    local p = CreateFrame("Frame", nil, f)
    p:SetSize(626, 380)
    p:SetPoint("TOPLEFT", f, "TOPLEFT", 84, -61)
    return p
  end

  self.dashboardPages = {
    combat = contentPage(), advice = contentPage(),
    quests = contentPage(), settings = contentPage()
  }
  self.dashboardTabs = {}
  local tabs = {
    {"combat", -72, "Interface\\Icons\\Ability_Warrior_Charge", "COMBAT"},
    {"advice", -146, "Interface\\Icons\\Ability_Warrior_BattleShout", "CONSEILS"},
    {"quests", -220, "Interface\\Icons\\INV_Misc_Map_01", "GUIDE"},
    {"settings", -294, "Interface\\Icons\\INV_Misc_Gear_01", "REGL."},
  }
  for _, item in ipairs(tabs) do
    self.dashboardTabs[item[1]] = tab(f, item[1], item[2], item[3], item[4])
  end

  -- Sous-onglets sobres : les actions courantes sont accessibles au clic.
  local function subTabs(page, descriptors, callback)
    local buttons={}
    local x=18
    for _,entry in ipairs(descriptors) do
      local b=CreateFrame("Button",nil,page)
      b:SetSize(entry[3],28)
      b:SetPoint("TOPLEFT",page,"TOPLEFT",x,-54)
      b.base=rectangle(b,0,0,entry[3],28,COLORS.darkPlate)
      b.accent=rectangle(b,0,-26,entry[3],2,COLORS.ridge,"ARTWORK")
      b.label=text(b,"GameFontNormalSmall",9,-5,entry[3]-16,20,
        tint(entry[2],"E9DFD2"))
      b:SetScript("OnClick",function() callback(entry[1]) end)
      b:SetScript("OnEnter",function()
        b.base:SetVertexColor(0.21,0.22,0.23,1)
      end)
      b:SetScript("OnLeave",function()
        local selected=(page==WC.dashboardPages.advice and
          WC.adviceMode==entry[1]) or
          (page==WC.dashboardPages.combat and WC.combatMode==entry[1])
        local c=selected and COLORS.blood or COLORS.darkPlate
        b.base:SetVertexColor(c[1],c[2],c[3],c[4])
      end)
      buttons[entry[1]]=b
      x=x+entry[3]+6
    end
    return buttons
  end

  local combatPage = self.dashboardPages.combat
  metalPlate(combatPage, 0, -4, 620, 344)
  picture(combatPage, "Interface\\Icons\\Ability_Warrior_Charge", 18, -16, 35, 35)
  text(combatPage, "GameFontNormalLarge", 62, -19, 510, 26,
    tint("COMBAT - BILAN ET SECURITE", "F1C98D"))
  rectangle(combatPage, 18, -91, 582, 1, COLORS.ridge, "ARTWORK")
  self.dashboardCombatDetail = text(combatPage, "GameFontHighlight",
    26, -105, 556, 227)
  self.combatMode="combat"
  self.dashboardCombatButtons=subTabs(combatPage,{
    {"combat","COMBATS",124},{"performance","PERFORMANCE",148}
  },function(mode) WC:SelectCombatView(mode) end)
  local advicePage = self.dashboardPages.advice
  metalPlate(advicePage, 0, -4, 620, 344)
  picture(advicePage, "Interface\\Icons\\Ability_Warrior_BattleShout",
    18, -16, 35, 35)
  text(advicePage, "GameFontNormalLarge", 62, -19, 520, 26,
    tint("CONSEILS - GUERRIER FURIE", "F1C98D"))
  rectangle(advicePage, 18, -91, 582, 1, COLORS.ridge, "ARTWORK")
  self.dashboardAdviceDetail = text(advicePage, "GameFontHighlight",
    26, -105, 556, 227)
  self.adviceMode="advice"
  self.dashboardAdviceButtons=subTabs(advicePage,{
    {"advice","CONSEILS",105},{"equipment","EQUIPEMENT",115},
    {"health","SANTE",80},{"weapons","ARMES",80},
    {"spells","SORTS",82}
  },function(mode) WC:SelectAdviceView(mode) end)

  local settingsPage=self.dashboardPages.settings
  metalPlate(settingsPage,0,-4,620,344)
  text(settingsPage,"GameFontNormalLarge",24,-20,562,26,
    tint("REGLAGES DE L'ADDON","F1C98D"))
  self.dashboardSettingsInfo=text(settingsPage,"GameFontHighlight",
    24,-68,552,125)
  self.dashboardSettingsButtons={}
  local function settingButton(key,label,x,y,width,callback)
    local b=CreateFrame("Button",nil,settingsPage)
    b:SetPoint("TOPLEFT",settingsPage,"TOPLEFT",x,y)
    b:SetSize(width,31)
    b.base=rectangle(b,0,0,width,31,COLORS.darkPlate)
    b.accent=rectangle(b,0,-29,width,2,COLORS.ridge,"ARTWORK")
    b.label=text(b,"GameFontNormal",9,-6,width-18,20,
      tint(label,"E9DFD2"))
    b:SetScript("OnClick",callback)
    b:SetScript("OnEnter",function()
      b.base:SetVertexColor(0.21,0.22,0.23,1)
    end)
    b:SetScript("OnLeave",function()
      WC:RefreshSettingsPanel()
    end)
    self.dashboardSettingsButtons[key]=b
    return b
  end
  settingButton("autostart","DEMARRAGE AUTO",24,-202,175,function()
    WC:Profile().autoOpen=not WC:Profile().autoOpen
    WC:RefreshSettingsPanel()
  end)
  settingButton("alerts","NOTIFICATIONS",211,-202,172,function()
    WC:Profile().showAlerts=not WC:Profile().showAlerts
    WC:RefreshSettingsPanel()
  end)
  settingButton("reset","REINITIALISER SESSION",24,-252,250,function()
    if not WC.settingsResetPending then
      WC.settingsResetPending=true
      WC.settingsResetMessage="Confirmer en cliquant de nouveau pour effacer la session."
    else
      WC.settingsResetPending=false
      WC:ResetSession()
      WC.settingsResetMessage="Session reinitialisee."
    end
    WC:RefreshSettingsPanel()
  end)
  text(settingsPage,"GameFontHighlightSmall",24,-291,557,36,
    "La remise a zero efface les compteurs de session, pas le guide ni les options.")

  local questPage = self.dashboardPages.quests
  metalPlate(questPage, 0, -4, 620, 344)
  picture(questPage, "Interface\\Icons\\INV_Misc_Map_01", 18, -13, 34, 34)
  text(questPage, "GameFontNormalLarge", 62, -17, 535, 26,
    tint("GUIDE DE LEVELING - HORDE", "F1C98D"))
  local options = {
    {"guide", "ETAPES", 15, 150},
    {"talents", "TALENTS", 174, 114},
    {"journal", "MES QUETES", 297, 130},
    {"discover", "A PRENDRE", 436, 142},
  }
  self.dashboardQuestButtons = {}
  for _, data in ipairs(options) do
    local button = CreateFrame("Button", nil, questPage)
    button:SetSize(data[4], 26)
    button:SetPoint("TOPLEFT", questPage, "TOPLEFT", data[3], -40)
    button.base=rectangle(button,0,0,data[4],26,COLORS.darkPlate)
    button.accent=rectangle(button,0,-24,data[4],2,COLORS.ridge,"ARTWORK")
    button.label=text(button,"GameFontNormalSmall",9,-5,data[4]-16,18,
      tint(data[2],"E9DFD2"))
    local mode = data[1]
    button:SetScript("OnClick", function() WC:SelectQuestPlan(mode) end)
    self.dashboardQuestButtons[mode] = button
  end
  local function stepButton(label, x, direction)
    local b = CreateFrame("Button", nil, questPage)
    b:SetPoint("TOPLEFT", questPage, "TOPLEFT", x, -348)
    b:SetSize(106, 25)
    b.base=rectangle(b,0,0,106,25,COLORS.darkPlate)
    b.accent=rectangle(b,0,-23,106,2,COLORS.copper,"ARTWORK")
    b.labelText = text(b, "GameFontNormalSmall", 7, -5, 96, 18,
      tint(label, "F0C58A"))
    b:SetScript("OnClick", function()
      if WC.questPlanMode=="talents" and WC.SetTalentPlanLevel then
        local level=WC.talentPlanSelection or WC:CurrentTalentPlanLevel()
        if WC:SetTalentPlanLevel(level+direction) then
          WC:SelectQuestPlan("talents")
        end
      elseif WC.GuideMove and WC:GuideMove(direction) then
        WC:SelectQuestPlan("guide")
      end
    end)
    return b
  end
  self.dashboardGuidePrev = stepButton("< Precedente", 20, -1)
  self.dashboardGuideNext = stepButton("Suivante >", 138, 1)
  rectangle(questPage, 18, -78, 582, 2, COLORS.ridge, "ARTWORK")
  self.dashboardQuestTitle = text(questPage, "GameFontNormalLarge", 24, -91,
    557, 26, tint("Etape en cours", "E9C58D"))
  rectangle(questPage, 18, -123, 582, 91, COLORS.darkPlate)
  rectangle(questPage, 18, -123, 2, 91, COLORS.gold, "ARTWORK")
  self.dashboardQuestDetail = text(questPage, "GameFontHighlight", 33,
    -135, 540, 77, "Ouvre le guide pour voir la prochaine action.")
  rectangle(questPage, 18, -220, 582, 2, COLORS.ridge, "ARTWORK")
  self.dashboardGuideLocation = text(questPage, "GameFontHighlight", 24,
    -225, 554, 36)
  self.dashboardGuideNextText = text(questPage, "GameFontHighlightSmall", 24,
    -265, 554, 33)
  -- Grille graphique de sept paliers, lisible sans ouvrir l'arbre Blizzard.
  -- Les rangs affiches correspondent au PLAN, pas aux talents observes.
  self.dashboardTalentHeader = text(questPage, "GameFontNormalLarge",
    24, -87, 552, 24)
  self.dashboardTalentCurrent = text(questPage, "GameFontHighlight",
    24, -111, 562, 23)
  self.dashboardTalentDistribution = text(questPage, "GameFontHighlightSmall",
    24, -133, 558, 16)
  self.dashboardTalentNext = text(questPage, "GameFontHighlightSmall",
    272, -318, 316, 17)
  self.dashboardTalentNotice = text(questPage, "GameFontHighlightSmall",
    24, -335, 560, 15)
  self.dashboardTalentGrid = {}
  self.dashboardTalentWidgets = {
    self.dashboardTalentHeader,self.dashboardTalentCurrent,
    self.dashboardTalentDistribution,self.dashboardTalentNext,
    self.dashboardTalentNotice,
  }
  -- Ne jamais superposer ces cellules aux textes du guide.
  for row=1,7 do
    local rowTitle=text(questPage,"GameFontNormalSmall",20,
      -150-(row-1)*24,17,18,tint(tostring(row),"A98F73"))
    self.dashboardTalentWidgets[#self.dashboardTalentWidgets+1]=rowTitle
  end
  for row=1,7 do
    for column=1,4 do
      local x=39+(column-1)*138
      local y=-149-(row-1)*24
      local cell=CreateFrame("Frame",nil,questPage)
      cell:SetPoint("TOPLEFT",questPage,"TOPLEFT",x,y)
      cell:SetSize(131,22)
      local background=rectangle(cell,0,0,131,22,COLORS.darkPlate)
      local stripe=rectangle(cell,0,0,3,22,COLORS.ridge,"ARTWORK")
      local name=text(cell,"GameFontNormalSmall",7,-3,96,16)
      local rank=text(cell,"GameFontNormalSmall",104,-3,26,16)
      cell.background=background
      cell.stripe=stripe
      cell.name=name
      cell.rank=rank
      self.dashboardTalentGrid[#self.dashboardTalentGrid+1]=cell
      self.dashboardTalentWidgets[#self.dashboardTalentWidgets+1]=cell
    end
  end
  for _,widget in ipairs(self.dashboardTalentWidgets) do widget:Hide() end
  
  self.dashboardQuestWidgets = {
    self.dashboardQuestTitle,self.dashboardQuestDetail,
    self.dashboardGuideLocation,self.dashboardGuideNextText,
  }

  text(f, "GameFontHighlightSmall", 90, -438, 597, 17,
    tint("GUIDE  /  CONSEILS  /  COMBAT  /  REGLAGES", "B4A391"))
  self.dashboard = f
  self.questPlanMode = "guide"
  if self.SelectQuestPlan then self:SelectQuestPlan("guide") end
  self:ShowDashboardPage("quests")
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
  if page=="quests" and not self.questPlanMode and self.SelectQuestPlan then
    self:SelectQuestPlan("guide")
  end
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

local function refreshGuideButtons(self)
  if not self.dashboardQuestButtons then return end
  local active=self.questPlanMode or "guide"
  for key,b in pairs(self.dashboardQuestButtons) do
    local color=key==active and COLORS.blood or COLORS.darkPlate
    local accent=key==active and COLORS.gold or COLORS.ridge
    b.base:SetVertexColor(color[1],color[2],color[3],color[4])
    b.accent:SetVertexColor(accent[1],accent[2],accent[3],accent[4])
  end
end

function WC:RefreshTalentGuidePanel()
  refreshGuideButtons(self)
  if not self.dashboardTalentWidgets then return end
  local active=self.questPlanMode=="talents"
  for _,t in ipairs(self.dashboardTalentWidgets) do
    if active then t:Show() else t:Hide() end
  end
  for _,t in ipairs(self.dashboardQuestWidgets) do
    if active then t:Hide() else t:Show() end
  end
  if self.dashboardGuidePrev and self.dashboardGuidePrev.labelText then
    self.dashboardGuidePrev.labelText:SetText(
      tint(active and "< Niveau" or "< Precedente","F0C58A"))
    self.dashboardGuideNext.labelText:SetText(
      tint(active and "Niveau >" or "Suivante >","F0C58A"))
  end
  if not active or not self.TalentPlanText then return end
  local view=self:TalentPlanText()
  if not view then
    self.dashboardTalentHeader:SetText("|cffF17E78PLAN DE TALENTS INDISPONIBLE|r")
    self.dashboardTalentCurrent:SetText(
      "Parcours non valide. Aucun point ne peut etre conseille.")
    self.dashboardTalentDistribution:SetText(
      self.talentPlanValidationError or "Donnees de talents absentes.")
    self.dashboardTalentNext:SetText("")
    self.dashboardTalentNotice:SetText(
      "Verifier les talents du jeu avant de depenser un point.")
    for _,cell in ipairs(self.dashboardTalentGrid or {}) do
      cell.name:SetText("")
      cell.rank:SetText("")
    end
    return
  end
  self.dashboardTalentHeader:SetText(
    "|cffEBC487ARBRE FURIE|r  |cffCDBB9B- Niveau "..view.plan.level.."|r")
  self.dashboardTalentCurrent:SetText(
    "|cff75D38APOINT A PLACER|r  "..view.current)
  local live=self.liveFuryTalents
  local source=live and
    (" | Reels : "..live.count.."/18 talents identifies") or
    " | Rangs reels non disponibles"
  self.dashboardTalentDistribution:SetText(
    view.distribution..source)
  local level=self:CurrentTalentPlanLevel()
  local sameLevel=view.plan.level==level
  self.dashboardTalentNext:SetText("|cffA9C8E9ENSUITE|r  "..view.next)
  local caveat=live and
    (sameLevel and
      (live.complete and "Rangs reels (rouge = ecart avec le plan)" or
        "Lecture partielle (rouge = ecart individuel)") or
      "Historique : rangs actuels affiches, pas de comparaison") or
    ("Lecture C_Traits indisponible : "..
      tostring(self.liveFuryReason or "non prise en charge"))
  self.dashboardTalentNotice:SetText("|cffB6AA9C"..caveat.."|r")
  local nodes=self:TalentTreeGrid(view.plan.level)
  if not nodes then return end
  local cells=self.dashboardTalentGrid
  for _,cell in ipairs(cells) do
    cell.name:SetText("")
    cell.rank:SetText("")
    cell.background:SetVertexColor(
      COLORS.darkPlate[1],COLORS.darkPlate[2],
      COLORS.darkPlate[3],COLORS.darkPlate[4])
    cell.stripe:SetVertexColor(
      COLORS.ridge[1],COLORS.ridge[2],
      COLORS.ridge[3],COLORS.ridge[4])
  end
  for _,node in ipairs(nodes) do
    local index=(node.row-1)*4+node.column
    local cell=cells[index]
    if cell then
      local color=node.mismatch and "F17E78" or
        (node.status=="current" and "F7D392" or
        (node.rank>0 and "8FD7A4" or "918A85"))
      local tintColor=node.mismatch and {0.74,0.22,0.22,1} or
        (node.status=="current" and COLORS.gold or
        (node.rank>0 and {0.30,0.56,0.39,1} or COLORS.ridge))
      cell.name:SetText(tint(node.label,color))
      local rankText=node.actualRank~=nil and
        (tostring(node.actualRank).."/"..node.maximum) or
        (tostring(node.rank).."/"..node.maximum)
      cell.rank:SetText(tint(rankText,color))
      cell.stripe:SetVertexColor(
        tintColor[1],tintColor[2],tintColor[3],tintColor[4])
      if node.status=="current" then
        cell.background:SetVertexColor(0.29,0.19,0.10,1)
      end
    end
  end
end

-- Navigation de sous-vues ; aucune fonction ne bascule en mode chat.
local function selectButtons(buttons,chosen)
  if not buttons then return end
  for key,button in pairs(buttons) do
    local c=key==chosen and COLORS.blood or COLORS.darkPlate
    button.base:SetVertexColor(c[1],c[2],c[3],c[4])
    if button.accent then
      local accent=key==chosen and COLORS.gold or COLORS.ridge
      button.accent:SetVertexColor(accent[1],accent[2],accent[3],accent[4])
    end
  end
end
function WC:SelectAdviceView(mode)
  if not self.dashboardAdviceButtons or not
      self.dashboardAdviceButtons[mode] then return end
  self.adviceMode=mode
  selectButtons(self.dashboardAdviceButtons,mode)
  self:RefreshDashboard()
end
function WC:SelectCombatView(mode)
  if not self.dashboardCombatButtons or not
      self.dashboardCombatButtons[mode] then return end
  self.combatMode=mode
  selectButtons(self.dashboardCombatButtons,mode)
  self:RefreshDashboard()
end
function WC:RefreshSettingsPanel()
  if not self.dashboardSettingsInfo then return end
  local options=self:Profile()
  for key,enabled in pairs({
    autostart=options.autoOpen==true,
    alerts=options.showAlerts==true,
    reset=self.settingsResetPending==true,
  }) do
    local b=self.dashboardSettingsButtons and self.dashboardSettingsButtons[key]
    if b then
      local base=enabled and COLORS.blood or COLORS.darkPlate
      local accent=enabled and COLORS.gold or COLORS.ridge
      b.base:SetVertexColor(base[1],base[2],base[3],base[4])
      b.accent:SetVertexColor(accent[1],accent[2],accent[3],accent[4])
    end
  end
  local auto=options.autoOpen and "ACTIF" or "INACTIF"
  local alerts=options.showAlerts and "ACTIVES" or "DESACTIVEES"
  self.dashboardSettingsInfo:SetText(
    "|cffEBC487DEMARRAGE AUTOMATIQUE|r   "..auto..
    "\nLe mini-bilan s'ouvre a la connexion si active."..
    "\n\n|cffEBC487NOTIFICATIONS|r   "..alerts..
    "\nAlertes importantes dans le chat, jamais en combat."..
    (self.settingsResetMessage and
      ("\n\n|cff75D38A"..self.settingsResetMessage.."|r") or ""))
end
function WC:AdviceViewText()
  local mode=self.adviceMode or "advice"
  if mode=="equipment" then
    return self.EquipmentReviewText and self:EquipmentReviewText() or
      "Equipement indisponible."
  end
  if mode=="health" then
    local h=self.health
    if not h or h.percent==nil then
      return "POINTS DE VIE\n\nLecture indisponible ou protegee."
    end
    return "|cffEBC487POINTS DE VIE|r\n\n"..
      tostring(h.current).." / "..tostring(h.maximum)..
      "   ("..tostring(h.percent).." %)"..
      "\n\nSoigne-toi et recupere entre les combats."
  end
  if mode=="weapons" then
    local w=self.weapons
    if not w or not w.available then
      return "ARMES\n\nLecture indisponible : "..
        tostring(w and w.reason or "non initialisee")
    end
    return "|cffEBC487MAIN DROITE|r\n"..tostring(w.main or "Vide")..
      "  -  "..tostring(w.mainType or w.mainReason or "Type inconnu")..
      "\n\n|cffEBC487MAIN GAUCHE|r\n"..tostring(w.off or "Vide")..
      "  -  "..tostring(w.offType or w.offReason or "Type inconnu")..
      "\n\nLe type d'arme ne suffit pas pour evaluer son DPS."
  end
  if mode=="spells" then
    local book=self.spellbook
    if not book or not book.known then
      return "SORTS\n\nGrimoire non disponible : "..
        tostring(book and book.reason or "non initialise")
    end
    local count=0
    for _ in pairs(book.known) do count=count+1 end
    local latest=book.learned and book.learned[#book.learned]
    return "|cffEBC487GRIMOIRE OBSERVE|r\n\n"..
      count.." sorts et rangs identifies"..
      "\n\nNouveaux pendant la session : "..
      tostring(book.learned and #book.learned or 0)..
      (latest and ("\nDernier : "..latest.name) or "")..
      "\n\nLes sorts a acheter au maitre ne sont pas deduits."
  end
  local advice=self:AdviceLines(false)
  return "|cffF0CA90PRIORITES|r\n"..advice..
    "\n\nConsulte EQUIPEMENT pour les objets a comparer."
end
function WC:CombatViewText()
  if self.combatMode=="performance" then
    local total=self.XPPerHour and self:XPPerHour()
    local recent=self.RecentXPPerHour and self:RecentXPPerHour()
    return "|cffEBC487PERFORMANCE XP|r\n\n"..
      "XP/h session : "..(total and tostring(total) or "indisponible")..
      "\nXP/h sur les 10 dernieres minutes : "..
      (recent and tostring(recent) or "indisponible")..
      "\n\nCe sont des moyennes, pas une mesure de quete ou de monstre."
  end
  local combat=self:GetCombatSummary()
  local status=combat.active and tint("EN COMBAT", "FC7A67")
    or tint("HORS COMBAT", "75D483")
  return "|cffF0CA90ETAT ACTUEL|r  "..status..
    "\n\nCombats observes : "..fmt(combat.completed,"0")..
    "\nCombats interrompus : "..fmt(combat.interrupted,"0")..
    "\nDuree moyenne : "..(combat.average and
      tostring(combat.average).." secondes" or "non mesuree")..
    "\nMorts en combat : "..fmt(combat.deathsInCombat,"0")..
    "\n\n|cffBAA18FUn intervalle de combat n'est pas un monstre tue.|r"
end

function WC:RefreshDashboard()
  if not self.dashboard or not self.dashboard:IsShown() then return end
  selectButtons(self.dashboardAdviceButtons,self.adviceMode or "advice")
  selectButtons(self.dashboardCombatButtons,self.combatMode or "combat")
  self.dashboardCombatDetail:SetText(self:CombatViewText())
  self.dashboardAdviceDetail:SetText(self:AdviceViewText())
  self:RefreshSettingsPanel()
  if self.RefreshTalentGuidePanel then self:RefreshTalentGuidePanel() end
  if self.questPlanMode=="guide" and self.GetGuideView then
    local view=self:GetGuideView()
    self.dashboardQuestTitle:SetText(view and view.title or "Guide Horde")
    self.dashboardQuestDetail:SetText(view and
      ("|cffEBC487A FAIRE MAINTENANT|r\n"..(view.actionText or view.steps or "")) or
      "Aucun parcours charge.")
    if self.dashboardGuideLocation then
      self.dashboardGuideLocation:SetText(view and
        ("|cffA0C8EEOU ALLER|r  "..(view.locationText or "")) or "")
    end
    if self.dashboardGuideNextText then
      self.dashboardGuideNextText:SetText(view and
        ("|cffBAAA91ENSUITE|r  "..(view.nextText or "")) or "")
    end
  end
end

-- Le basculement compact / complet est porte par CompactDashboard.lua.
