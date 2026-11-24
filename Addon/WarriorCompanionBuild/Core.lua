local addon,B=...
local function message(value)
  if type(DEFAULT_CHAT_FRAME)=="table" and
      type(DEFAULT_CHAT_FRAME.AddMessage)=="function" then
    DEFAULT_CHAT_FRAME:AddMessage("|cffEFC06DWarrior Build|r  "..tostring(value))
  end
end
-- Ancienne commande /wcb et nouveaux controles de la minimap.
function B:Toggle()
  self:ToggleDashboard()
end
local function ensureReady()
  if not B.db then B:InitState() end
  if not B.metrics then B:StartSession() end
  if not B.frame then B:CreateUI() end
  if not B.compactDashboard then B:CreateCompactDashboard() end
  if not B.minimapButton then B:CreateMinimapButton() end
end
local function slash(msg)
  msg=(msg or ""):lower():match("^%s*(.-)%s*$")
  ensureReady()
  if msg=="talents" or msg=="equipement" or msg=="parcours" or
      msg=="rotation" then
    B:OpenFullDashboard()
    B:ShowPage(msg)
  elseif msg=="reel" then
    B:ReturnToReal()
    B:OpenFullDashboard()
  elseif msg=="mini" then
    B:ShowCompact()
  elseif msg=="full" then
    B:OpenFullDashboard()
  elseif msg=="hide" then
    B:HideDashboard()
  elseif msg=="reset" then
    B:ResetSession()
    message("Mini-bilan de session reinitialise.")
  elseif msg=="autostart on" then
    B.db.autoOpen=true
    if B.db.displayMode=="hidden" or not B.db.displayMode then
      B.db.displayMode="compact"
    end
    message("Ouverture automatique activee pour la prochaine connexion.")
  elseif msg=="autostart off" then
    B.db.autoOpen=false
    message("Ouverture automatique desactivee.")
  elseif msg=="alerts on" then
    B.db.showAlerts=true
    B:RefreshCompactDashboard()
    message("Conseils du mini-bilan actives.")
  elseif msg=="alerts off" then
    B.db.showAlerts=false
    B:RefreshCompactDashboard()
    message("Conseils du mini-bilan desactives.")
  elseif msg=="minimap on" then
    B:SetMinimapVisible(true)
  elseif msg=="minimap off" then
    B:SetMinimapVisible(false)
  elseif msg=="help" then
    message("/wcb : ouvrir/fermer | mini | full | hide | talents | equipement | parcours | rotation | reel")
    message("/wcb reset | autostart on/off | alerts on/off | minimap on/off")
  else
    B:ToggleDashboard()
  end
end
SLASH_WARRIORCOMPANIONBUILD1="/wcb"
SlashCmdList.WARRIORCOMPANIONBUILD=slash

local events=CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_ENTERING_WORLD")
events:RegisterEvent("PLAYER_LEVEL_UP")
events:RegisterEvent("PLAYER_XP_UPDATE")
events:RegisterEvent("PLAYER_DEAD")
events:RegisterEvent("PLAYER_MONEY")
events:RegisterEvent("GET_ITEM_INFO_RECEIVED")
events:RegisterEvent("SPELLS_CHANGED")
events:RegisterEvent("QUEST_LOG_UPDATE")
events:RegisterEvent("QUEST_ACCEPTED")
events:RegisterEvent("QUEST_REMOVED")
events:RegisterEvent("QUEST_TURNED_IN")
events:RegisterEvent("UNIT_AURA")
events:SetScript("OnEvent",function(_,event,arg1)
  if event=="ADDON_LOADED" then
    if arg1~=addon then return end
    B:InitState()
    if type(B.db.autoOpen)~="boolean" then B.db.autoOpen=false end
    if type(B.db.showAlerts)~="boolean" then B.db.showAlerts=true end
    if type(B.db.minimapVisible)~="boolean" then
      B.db.minimapVisible=true
    end
    if not B.db.displayMode then B.db.displayMode="hidden" end
    local valid,why=B:ValidateContent()
    if not valid then
      B.invalidPlan=why
      message("Plan invalide : "..tostring(why))
    end
    return
  end
  if not B.db or B.invalidPlan then return end
  if event=="PLAYER_ENTERING_WORLD" then
    B:UpdateLevel()
    B:StartSession()
    B:OnSessionEvent(event,arg1)
    if B.ReadQuestLog then B:ReadQuestLog() end
    if not B.frame then B:CreateUI() end
    if not B.compactDashboard then B:CreateCompactDashboard() end
    B:CreateMinimapButton()
    B:AutoOpenDashboard()
    if B.frame and B.frame:IsShown() then B:Refresh() end
  elseif event=="PLAYER_LEVEL_UP" then
    B:OnSessionEvent(event,arg1)
    B:UpdateLevel()
    if B.frame then B:Refresh() end
  elseif event=="PLAYER_XP_UPDATE" or event=="PLAYER_DEAD" or
      event=="PLAYER_MONEY" then
    B:OnSessionEvent(event,arg1)
  elseif event=="QUEST_LOG_UPDATE" or event=="QUEST_ACCEPTED" or
      event=="QUEST_REMOVED" or event=="QUEST_TURNED_IN" then
    if B.ReadQuestLog then B:ReadQuestLog() end
    if B.frame and B.frame:IsShown() and B.page=="parcours" then
      B:RefreshRoute()
    end
  elseif event=="GET_ITEM_INFO_RECEIVED" then
    if B.frame and B.frame:IsShown() then B:RefreshGear() end
  elseif event=="SPELLS_CHANGED" then
    if B.BuildSpellbookCache then B:BuildSpellbookCache() end
    if B.frame then B:RefreshRotation() end
  elseif event=="UNIT_AURA" and arg1=="player" then
    if B.frame and B.frame:IsShown() and B.page=="rotation" then
      B:RefreshRotation()
    end
  end
end)
