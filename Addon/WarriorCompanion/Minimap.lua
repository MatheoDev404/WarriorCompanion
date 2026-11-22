local _, WC = ...
-- Bouton de minimap autonome et toujours accessible.
-- Utilise uniquement les textures livrees avec l'addon et les API Frame de WoW.
local CREST = "Interface\\AddOns\\WarriorCompanion\\Textures\\Warcrest"
local BORDER = "Interface\\Minimap\\MiniMap-TrackingBorder"

function WC:CreateMinimapButton()
  if self.minimapButton then return self.minimapButton end
  if not Minimap or type(CreateFrame) ~= "function" then
    self:Trace("minimap","Minimap non disponible")
    return nil
  end
  local button = CreateFrame("Button", "WarriorCompanionMinimapButton", Minimap)
  button:SetSize(33,33)
  button:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", 7, 7)
  button:SetFrameStrata("MEDIUM")
  button:EnableMouse(true)
  button:RegisterForClicks("LeftButtonUp")

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
    end
    GameTooltip:Show()
  end)
  button:SetScript("OnLeave", function()
    if GameTooltip then GameTooltip:Hide() end
  end)
  self.minimapButton = button
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
