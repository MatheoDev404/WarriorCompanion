local addon,B=...
local function message(text)
  if type(DEFAULT_CHAT_FRAME)=="table" and
      type(DEFAULT_CHAT_FRAME.AddMessage)=="function" then
    DEFAULT_CHAT_FRAME:AddMessage("|cffEFC06DWarrior Build|r  "..tostring(text))
  end
end
function B:Toggle()
  if not self.frame then self:CreateUI() end
  if self.frame:IsShown() then self.frame:Hide()
  else
    self:UpdateLevel()
    self.frame:Show()
    self:Refresh()
  end
end
local function slash(msg)
  msg=(msg or ""):lower():match("^%s*(.-)%s*$")
  if not B.db then B:InitState() end
  if not B.frame then B:CreateUI() end
  if msg=="talents" or msg=="equipement" or msg=="parcours" or
      msg=="rotation" then
    B.frame:Show() B:ShowPage(msg)
  elseif msg=="reel" then
    B:ReturnToReal() B.frame:Show() B:Refresh()
  elseif msg=="help" then
    message("/wcb : ouvrir/fermer | talents | equipement | parcours | rotation | reel  (taille : boutons +/-)")
  else
    B:Toggle()
  end
end
SLASH_WARRIORCOMPANIONBUILD1="/wcb"
SlashCmdList.WARRIORCOMPANIONBUILD=slash
local events=CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_ENTERING_WORLD")
events:RegisterEvent("PLAYER_LEVEL_UP")
events:RegisterEvent("GET_ITEM_INFO_RECEIVED")
events:RegisterEvent("SPELLS_CHANGED")
events:RegisterEvent("UNIT_AURA")
events:SetScript("OnEvent",function(_,event,arg1)
  if event=="ADDON_LOADED" and arg1==addon then
    B:InitState()
    local valid,why=B:ValidateContent()
    if not valid then
      message("Plan invalide : "..tostring(why))
      B.invalidPlan=why
      return
    end
  elseif event=="PLAYER_ENTERING_WORLD" then
    if not B.db then return end
    B:UpdateLevel()
    if not B.invalidPlan then
      if not B.frame then B:CreateUI() end
      if B.db.hidden~=true then B.frame:Show() end
      B:Refresh()
    end
  elseif event=="PLAYER_LEVEL_UP" then
    if not B.db then return end
    B:UpdateLevel()
    if B.frame then B:Refresh() end
  elseif event=="GET_ITEM_INFO_RECEIVED" then
    if B.frame and B.frame:IsShown() then B:RefreshGear() end
  elseif event=="SPELLS_CHANGED" or event=="LEARNED_SPELL_IN_SKILL_LINE" then
    if B.BuildSpellbookCache then B:BuildSpellbookCache() end
    if B.frame then B:RefreshRotation() end
  elseif event=="UNIT_AURA" and arg1=="player" then
    if B.frame and B.frame:IsShown() and B.page=="rotation" then
      B:RefreshRotation()
    end
  end
end)
