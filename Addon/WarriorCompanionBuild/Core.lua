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
  if msg=="compact" then
    B.scale=0.70 B.db.scale=0.70 B.frame:SetScale(0.70)
    B.frame:Show()
  elseif msg=="grand" or msg=="full" then
    B.scale=1.0 B.db.scale=1.0 B.frame:SetScale(1.0)
    B.frame:Show()
  elseif msg=="talents" or msg=="equipement" or msg=="parcours" then
    B.frame:Show() B:ShowPage(msg)
  elseif msg=="reel" then
    B:ReturnToReal() B.frame:Show() B:Refresh()
  elseif msg=="help" then
    message("/wcb : ouvrir/fermer | /wcb compact | grand | talents | equipement | parcours | reel")
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
  end
end)
