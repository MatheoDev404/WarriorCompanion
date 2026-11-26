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
  elseif msg=="compass on" then
    B:SetCompassEnabled(true)
  elseif msg=="compass off" then
    B:SetCompassEnabled(false)
  elseif msg=="guide" then
    B:OpenFullDashboard()
    B:SetActiveGuide("leveling")
    if B.db then B.db.detailedMode=true end
    B:ShowPage("parcours")
  elseif msg=="guide minage" or msg=="guide forge" or
      msg=="guide mixte" or msg=="guide leveling" then
    local id=msg=="guide minage" and "mining" or
      msg=="guide forge" and "smithing" or
      msg=="guide mixte" and "combo" or "leveling"
    B:SetActiveGuide(id)
    B:OpenFullDashboard()
    B:ShowPage("parcours")
  elseif msg:match("^metier set ") then
    local name,value,cap=msg:match("^metier set ([%a]+) (%d+) (%d+)$")
    local key=name=="minage" and "mining" or
      name=="forge" and "smithing" or nil
    if key and B:SetProfessionManualSkill(key,tonumber(value),tonumber(cap)) then
      message("Competence manuelle enregistree : "..name.." "..value.."/"..cap)
      if B.frame and B.frame:IsShown() and B.page=="parcours" then
        B:RefreshRoute()
      end
    else
      message("Saisie refusee (valeur du jeu prioritaire). Usage : /wcb metier set forge 127 225")
    end
  elseif msg=="mode xp" or msg=="mode securite" or
      msg=="mode sécurité" then
    B:AdaptiveSetMode(msg=="mode xp" and "xp" or "safe")
    if B.frame and B.frame:IsShown() and B.page=="parcours" then
      B:RefreshRoute()
    end
    message("Mode de parcours : "..(B:AdaptiveMode()=="xp" and
      "XP rapide" or "Sécurité"))
  elseif msg=="reprendre" then
    B:AdaptiveResume()
    B:OpenFullDashboard()
    if B.db then B.db.detailedMode=true end
    B:ShowPage("parcours")
  elseif msg=="guideaudit" then
    local audit=B:DetailedAudit()
    message("Guide 30-40 : "..audit.steps.." etapes, "..
      audit.packs.." sections, "..audit.coords.." points, "..
      audit.questActions.." actions de quetes.")
    if audit.badQuestIDs>0 or audit.unknownMaps>0 then
      message("A verifier : "..audit.badQuestIDs.." identifiants et "..
        audit.unknownMaps.." cartes non resolues.")
    end
  elseif msg=="minimap on" then
    B:SetMinimapVisible(true)
  elseif msg=="minimap off" then
    B:SetMinimapVisible(false)
  elseif msg=="help" then
    message("/wcb : ouvrir/fermer | mini | full | hide | talents | equipement | parcours | rotation | reel")
    message("/wcb reset | autostart on/off | alerts on/off | minimap on/off")
    message("/wcb guide [minage|forge|mixte|leveling] | reprendre")
    message("/wcb metier set minage N CAP | metier set forge N CAP")
    message("/wcb mode xp | mode securite")
    message("/wcb guideaudit | compass on/off")
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
events:RegisterEvent("SKILL_LINES_CHANGED")
events:RegisterEvent("TRADE_SKILL_SHOW")
events:RegisterEvent("TRADE_SKILL_LIST_UPDATE")
events:RegisterEvent("TRADE_SKILL_DATA_SOURCE_CHANGED")
events:RegisterEvent("BAG_UPDATE_DELAYED")
events:RegisterEvent("BANKFRAME_OPENED")
events:RegisterEvent("BANKFRAME_CLOSED")
events:RegisterEvent("PLAYERBANKSLOTS_CHANGED")
events:RegisterEvent("PLAYERBANKBAGSLOTS_CHANGED")
events:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
events:RegisterEvent("QUEST_LOG_UPDATE")
events:RegisterEvent("QUEST_ACCEPTED")
events:RegisterEvent("QUEST_REMOVED")
events:RegisterEvent("QUEST_TURNED_IN")
events:RegisterEvent("ZONE_CHANGED_NEW_AREA")
events:RegisterEvent("UNIT_AURA")
events:SetScript("OnEvent",function(_,event,arg1)
  if event=="ADDON_LOADED" then
    if arg1~=addon then return end
    B:InitState()
    if B.ProfessionsInit then B:ProfessionsInit() end
    if B.AdaptiveInit then B:AdaptiveInit() end
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
    if B.RefreshProfessionObservations then
      B:RefreshProfessionObservations(event)
    end
    if not B.frame then B:CreateUI() end
    if not B.compactDashboard then B:CreateCompactDashboard() end
    B:CreateMinimapButton()
    if B.CreateCompass then B:CreateCompass() end
    B:AutoOpenDashboard()
    if B.frame and B.frame:IsShown() then B:Refresh() end
  elseif event=="PLAYER_LEVEL_UP" then
    B:OnSessionEvent(event,arg1)
    B:UpdateLevel()
    if B.AdaptiveInvalidate then B:AdaptiveInvalidate("level") end
    if B.frame then B:Refresh() end
    if B.UpdateCompass then B:UpdateCompass() end
  elseif event=="PLAYER_XP_UPDATE" or event=="PLAYER_DEAD" or
      event=="PLAYER_MONEY" then
    B:OnSessionEvent(event,arg1)
  elseif event=="QUEST_LOG_UPDATE" or event=="QUEST_ACCEPTED" or
      event=="QUEST_REMOVED" or event=="QUEST_TURNED_IN" then
    if B.ReadQuestLog then B:ReadQuestLog() end
    if B.AdaptiveInvalidate then B:AdaptiveInvalidate("quest") end
    if B.frame and B.frame:IsShown() and B.page=="parcours" then
      B:RefreshRoute()
    end
    if B.UpdateCompass then B:UpdateCompass() end
  elseif event=="ZONE_CHANGED_NEW_AREA" then
    if B.AdaptiveInvalidate then B:AdaptiveInvalidate("zone")
    else B.routeSelectedId=nil end
    if B.frame and B.frame:IsShown() and B.page=="parcours" then
      B:RefreshRoute()
    end
    if B.UpdateCompass then B:UpdateCompass() end
  elseif event=="SKILL_LINES_CHANGED" or
      event=="TRADE_SKILL_SHOW" or
      event=="TRADE_SKILL_LIST_UPDATE" or
      event=="TRADE_SKILL_DATA_SOURCE_CHANGED" or
      event=="BAG_UPDATE_DELAYED" or
      event=="BANKFRAME_OPENED" or event=="BANKFRAME_CLOSED" or
      event=="PLAYERBANKSLOTS_CHANGED" or
      event=="PLAYERBANKBAGSLOTS_CHANGED" or
      event=="PLAYER_EQUIPMENT_CHANGED" then
    if B.RefreshProfessionObservations then
      B:RefreshProfessionObservations(event)
    end
    if B.frame and B.frame:IsShown() and B.page=="parcours" and
      B.ActiveGuide and B:ActiveGuide()~="leveling" then
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
