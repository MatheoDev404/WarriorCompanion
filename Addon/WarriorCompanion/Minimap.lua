local _, WC = ...
-- Bouton de minimap autonome : apparence et interactions similaires aux
-- boutons Blizzard/LibDBIcon. Aucun chargement d'une bibliotheque externe.
local ICON = "Interface\\Icons\\Ability_Warrior_BattleShout"
local BORDER = "Interface\\Minimap\\MiniMap-TrackingBorder"
local BACKGROUND = "Interface\\Minimap\\UI-Minimap-Background"
local HIGHLIGHT = "Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight"
local DEFAULT_ANGLE = 225
local ROUND_RADIUS = 80
local SQUARE_RADIUS = 80
local DIAGONAL_RADIUS = 103.13708498985

-- Formes de minimaps courantes des addons (GetMinimapShape).
-- Index : bas-droite, bas-gauche, haut-droite, haut-gauche.
local SHAPES = {
  ROUND = {true, true, true, true},
  SQUARE = {false, false, false, false},
  ["CORNER-TOPLEFT"] = {true, false, false, false},
  ["CORNER-TOPRIGHT"] = {false, false, true, false},
  ["CORNER-BOTTOMLEFT"] = {false, true, false, false},
  ["CORNER-BOTTOMRIGHT"] = {false, false, false, true},
  ["SIDE-LEFT"] = {true, true, false, false},
  ["SIDE-RIGHT"] = {false, false, true, true},
  ["SIDE-TOP"] = {false, false, true, true},
  ["SIDE-BOTTOM"] = {true, true, false, false},
}

local function validNumber(n)
  return type(n) == "number" and n == n
    and n ~= math.huge and n ~= -math.huge
end

local function angleFromCursor(dx, dy)
  if dx == 0 then return dy >= 0 and 90 or 270 end
  local a = math.deg(math.atan(dy / dx))
  if dx < 0 then a = a + 180 end
  return a % 360
end

local function minimapShape()
  if type(GetMinimapShape) ~= "function" then return "ROUND" end
  local ok, shape = pcall(GetMinimapShape)
  if not ok or type(shape) ~= "string" or not SHAPES[shape] then
    return "ROUND"
  end
  return shape
end

function WC:PositionMinimapButton(angle)
  local button = self.minimapButton
  if not button or not Minimap then return end
  if not validNumber(angle) then angle = DEFAULT_ANGLE end
  angle = angle % 360
  self:Profile().minimapAngle = angle

  local rad = math.rad(angle)
  local x, y = math.cos(rad), math.sin(rad)
  local quadrant = 1
  if x < 0 then quadrant = quadrant + 1 end
  if y > 0 then quadrant = quadrant + 2 end

  local shape = minimapShape()
  local xx, yy
  if SHAPES[shape][quadrant] then
    xx, yy = x * ROUND_RADIUS, y * ROUND_RADIUS
  else
    xx = math.max(-SQUARE_RADIUS, math.min(x * DIAGONAL_RADIUS, SQUARE_RADIUS))
    yy = math.max(-SQUARE_RADIUS, math.min(y * DIAGONAL_RADIUS, SQUARE_RADIUS))
  end
  button:ClearAllPoints()
  button:SetPoint("CENTER", Minimap, "CENTER", xx, yy)
end

function WC:DragMinimapButton()
  if not self.minimapButton or not Minimap
      or type(GetCursorPosition) ~= "function"
      or type(Minimap.GetCenter) ~= "function"
      or type(Minimap.GetEffectiveScale) ~= "function" then return end
  local ok, mx, my = pcall(Minimap.GetCenter, Minimap)
  local scaleOk, scale = pcall(Minimap.GetEffectiveScale, Minimap)
  local cursorOk, cx, cy = pcall(GetCursorPosition)
  if not ok or not scaleOk or not cursorOk or not validNumber(mx)
      or not validNumber(my) or not validNumber(scale) or scale <= 0
      or not validNumber(cx) or not validNumber(cy) then return end
  local dx, dy = cx / scale - mx, cy / scale - my
  if dx == 0 and dy == 0 then return end
  self:PositionMinimapButton(angleFromCursor(dx, dy))
end

function WC:CreateMinimapButton()
  if self.minimapButton then return self.minimapButton end
  if not Minimap or type(CreateFrame) ~= "function" then
    self:Trace("minimap", "Minimap non disponible")
    return nil
  end
  local button = CreateFrame("Button", "WarriorCompanionMinimapButton", Minimap)
  button:SetSize(31, 31)
  button:SetPoint("CENTER", Minimap, "CENTER", 0, ROUND_RADIUS)
  button:SetFrameStrata("MEDIUM")
  if type(button.SetFrameLevel) == "function" then button:SetFrameLevel(8) end
  button:EnableMouse(true)
  button:RegisterForClicks("LeftButtonUp")
  button:RegisterForDrag("LeftButton")
  if type(button.SetHighlightTexture) == "function" then
    button:SetHighlightTexture(HIGHLIGHT)
  end

  local background = button:CreateTexture(nil, "BACKGROUND")
  background:SetTexture(BACKGROUND)
  background:SetSize(20, 20)
  background:SetPoint("TOPLEFT", button, "TOPLEFT", 7, -5)

  local icon = button:CreateTexture(nil, "ARTWORK")
  icon:SetTexture(ICON)
  icon:SetSize(20, 20)
  icon:SetPoint("TOPLEFT", button, "TOPLEFT", 7, -5)
  icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
  button.icon = icon

  local border = button:CreateTexture(nil, "OVERLAY")
  border:SetTexture(BORDER)
  border:SetSize(53, 53)
  border:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)

  -- Le meme comportement de pression visuelle et de survol que les boutons
  -- circulaires courants, sans changer l'etat du tableau.
  button:SetScript("OnMouseDown", function()
    button.justDragged = false
    icon:SetTexCoord(0, 1, 0, 1)
  end)
  button:SetScript("OnMouseUp", function()
    icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
  end)
  button:SetScript("OnDragStart", function()
    button.dragging = true
    WC:DragMinimapButton()
    if GameTooltip then GameTooltip:Hide() end
  end)
  button:SetScript("OnDragStop", function()
    WC:DragMinimapButton()
    button.dragging = false
    button.justDragged = true
    icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
  end)
  button:SetScript("OnUpdate", function()
    if button.dragging then WC:DragMinimapButton() end
  end)
  button:SetScript("OnClick", function(_, mouse)
    if button.justDragged then
      button.justDragged = false
      return
    end
    if mouse == "LeftButton" or mouse == nil then
      WC:ToggleDashboard()
    end
  end)
  button:SetScript("OnEnter", function(frame)
    if not GameTooltip or button.dragging then return end
    GameTooltip:SetOwner(frame, "ANCHOR_LEFT")
    GameTooltip:SetText("Warrior Companion")
    if type(GameTooltip.AddLine) == "function" then
      GameTooltip:AddLine("Clic gauche : ouvrir/fermer", 1, 1, 1)
      GameTooltip:AddLine("Glisser : deplacer sur la minimap", 0.8, 0.7, 0.5)
    end
    GameTooltip:Show()
  end)
  button:SetScript("OnLeave", function()
    if GameTooltip then GameTooltip:Hide() end
  end)
  self.minimapButton = button
  self:PositionMinimapButton(self:Profile().minimapAngle)
  return button
end

function WC:AutoOpenDashboard()
  if self.didAutoOpen then return end
  self.didAutoOpen = true
  if not self:Profile().autoOpen then return end
  if not self.dashboard then
    self:Trace("minimap", "Tableau de bord absent a l'ouverture")
    return
  end
  if not self.dashboard:IsShown() then
    self.dashboard:Show()
    self:RefreshDashboard()
  end
end
