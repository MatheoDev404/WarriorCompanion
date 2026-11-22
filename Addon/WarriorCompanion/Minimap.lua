local _, WC = ...
-- Bouton de minimap autonome et toujours accessible.
-- Utilise uniquement les textures livrees avec l'addon et les API Frame de WoW.
local CREST = "Interface\\AddOns\\WarriorCompanion\\Textures\\Warcrest"
local BORDER = "Interface\\Minimap\\MiniMap-TrackingBorder"
local RADIUS = 78
local DEFAULT_ANGLE = 45

local function validAngle(angle)
  return type(angle) == "number" and angle == angle
    and angle ~= math.huge and angle ~= -math.huge
end

-- Compatible Lua 5.1: calcul sur les quatre quadrants.
local function angleFromCursor(dx, dy)
  if dx == 0 then return dy >= 0 and 90 or 270 end
  local angle = math.deg(math.atan(dy / dx))
  if dx < 0 then angle = angle + 180 end
  if angle < 0 then angle = angle + 360 end
  return angle
end

function WC:PositionMinimapButton(angle)
  if not self.minimapButton then return end
  if not validAngle(angle) then angle = DEFAULT_ANGLE end
  angle = angle % 360
  self:Profile().minimapAngle = angle
  local radians = math.rad(angle)
  self.minimapButton:ClearAllPoints()
  self.minimapButton:SetPoint("CENTER", Minimap, "CENTER",
    math.cos(radians) * RADIUS, math.sin(radians) * RADIUS)
end

function WC:DragMinimapButton()
  if not self.minimapButton or not Minimap
      or type(GetCursorPosition) ~= "function"
      or type(Minimap.GetCenter) ~= "function"
      or type(Minimap.GetEffectiveScale) ~= "function" then return end
  local ok, mx, my = pcall(Minimap.GetCenter, Minimap)
  local scaleOk, scale = pcall(Minimap.GetEffectiveScale, Minimap)
  local cursorOk, cx, cy = pcall(GetCursorPosition)
  if not ok or not scaleOk or not cursorOk
      or type(mx) ~= "number" or type(my) ~= "number"
      or type(scale) ~= "number" or scale <= 0
      or type(cx) ~= "number" or type(cy) ~= "number" then return end
  local dx, dy = cx / scale - mx, cy / scale - my
  if dx == 0 and dy == 0 then return end
  self:PositionMinimapButton(angleFromCursor(dx, dy))
end


function WC:CreateMinimapButton()
  if self.minimapButton then return self.minimapButton end
  if not Minimap or type(CreateFrame) ~= "function" then
    self:Trace("minimap","Minimap non disponible")
    return nil
  end
  local button = CreateFrame("Button", "WarriorCompanionMinimapButton", Minimap)
  button:SetSize(33,33)
  button:SetPoint("CENTER", Minimap, "CENTER", 0, RADIUS)
  button:SetFrameStrata("MEDIUM")
  button:EnableMouse(true)
  button:RegisterForClicks("LeftButtonUp")
  button:RegisterForDrag("LeftButton")
  button:SetScript("OnDragStart", function()
    button.dragging = true
    WC:DragMinimapButton()
  end)
  button:SetScript("OnDragStop", function()
    WC:DragMinimapButton()
    button.dragging = false
    button.justDragged = true
  end)
  button:SetScript("OnUpdate", function()
    if button.dragging then WC:DragMinimapButton() end
  end)

  local background = button:CreateTexture(nil, "BACKGROUND")
  background:SetTexture("Interface\\Buttons\\WHITE8X8")
  background:SetAllPoints(button)
  background:SetVertexColor(0.08,0.03,0.03,0.96)

  local crest = button:CreateTexture(nil, "ARTWORK")
  crest:SetTexture(CREST)
  crest:SetPoint("CENTER", button, "CENTER", 0,0)
  crest:SetSize(27,27)

  local border = button:CreateTexture(nil, "OVERLAY")
  border:SetTexture(BORDER)
  border:SetSize(54,54)
  border:SetPoint("TOPLEFT", button, "TOPLEFT", -11, 11)

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
    if not GameTooltip then return end
    GameTooltip:SetOwner(frame, "ANCHOR_LEFT")
    GameTooltip:SetText("Warrior Companion")
    if GameTooltip.AddLine then
      GameTooltip:AddLine("Clic gauche : ouvrir/fermer le tableau",1,1,1)
      GameTooltip:AddLine("Glisser : deplacer autour de la minimap",0.8,0.7,0.5)
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
  -- Une seule ouverture automatique par chargement d'addon, pas a chaque zonage.
  if self.didAutoOpen then return end
  self.didAutoOpen = true
  if not self:Profile().autoOpen then return end
  if not self.dashboard then
    self:Trace("minimap","Tableau de bord absent a l'ouverture")
    return
  end
  if not self.dashboard:IsShown() then
    self.dashboard:Show()
    self:RefreshDashboard()
  end
end
