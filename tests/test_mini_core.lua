-- Demarrage et commandes /wcb sans client, en particulier absence d'auto-open.
local registered={}
local eventFrame={handlers={}}
function eventFrame:RegisterEvent(name)
  assert(name~="LEARNED_SPELL_IN_TAB","evenement inconnu Forever interdit")
  registered[name]=true
end
function eventFrame:SetScript(name,handler) self.handlers[name]=handler end
function CreateFrame()
  return eventFrame
end
SlashCmdList={}
local B={db=nil,metrics=nil,frame=nil,compactDashboard=nil,minimapButton=nil}
function B:InitState() self.db={} end
function B:ValidateContent() return true end
function B:UpdateLevel() self.levelUpdated=(self.levelUpdated or 0)+1 end
function B:StartSession()
  self.metrics=self.metrics or {xpGained=0}
  self.started=(self.started or 0)+1
end
function B:OnSessionEvent(name)
  self.events=self.events or {}
  self.events[#self.events+1]=name
end
local function displayFrame()
  return {shown=false,Show=function(s) s.shown=true end,
    Hide=function(s) s.shown=false end,
    IsShown=function(s) return s.shown end}
end
function B:CreateUI()
  self.frame=displayFrame()
  self.uiCreated=(self.uiCreated or 0)+1
end
function B:CreateCompactDashboard()
  self.compactDashboard=displayFrame()
  self.compactCreated=(self.compactCreated or 0)+1
end
function B:CreateMinimapButton()
  self.minimapButton=displayFrame()
  self.minimapButton:Show()
  self.iconCreated=(self.iconCreated or 0)+1
end
function B:AutoOpenDashboard()
  self.didAutoOpen=true
  if self.db.autoOpen then
    if self.db.displayMode=="compact" then self:ShowCompact()
    else self:OpenFullDashboard() end
  end
end
function B:OpenFullDashboard()
  self.frame:Show()
  self.compactDashboard:Hide()
  self.db.displayMode="full"
end
function B:ShowCompact()
  self.frame:Hide()
  self.compactDashboard:Show()
  self.db.displayMode="compact"
end
function B:HideDashboard()
  self.frame:Hide()
  self.compactDashboard:Hide()
  self.db.displayMode="hidden"
end
function B:ToggleDashboard()
  if self.frame:IsShown() then self:HideDashboard() else self:OpenFullDashboard() end
end
function B:ResetSession()
  self.resets=(self.resets or 0)+1
end
function B:Refresh() self.refreshed=(self.refreshed or 0)+1 end
function B:RefreshGear() end
function B:RefreshRotation() end
function B:RefreshRoute() end
function B:ReadQuestLog() end
function B:ReturnToReal() end
function B:ShowPage(key)
  self.selectedPage=key
end
function B:SetMinimapVisible(value)
  self.db.minimapVisible=value
  if value then self.minimapButton:Show() else self.minimapButton:Hide() end
end
function B:RefreshCompactDashboard() end
assert(loadfile("Addon/WarriorCompanionBuild/Core.lua"))("WarriorCompanionBuild",B)
assert(registered.ADDON_LOADED and registered.PLAYER_ENTERING_WORLD and
  registered.PLAYER_XP_UPDATE and registered.PLAYER_DEAD and
  registered.PLAYER_MONEY,"events XP, mort, monnaie et lancement")
local fire=eventFrame.handlers.OnEvent
fire(eventFrame,"ADDON_LOADED","OtherAddon")
assert(B.db==nil,"ignorer chargement d'autres addons")
fire(eventFrame,"ADDON_LOADED","WarriorCompanionBuild")
assert(B.db.autoOpen==false and B.db.displayMode=="hidden" and
  B.db.minimapVisible==true and B.db.showAlerts==true)
fire(eventFrame,"PLAYER_ENTERING_WORLD")
assert(B.iconCreated==1 and B.started==1 and B.uiCreated==1 and
  B.compactCreated==1,"initialisation de tous les modules")
assert(not B.frame:IsShown() and not B.compactDashboard:IsShown(),
  "ne pas ouvrir de grande fenetre au login")
assert(B.minimapButton:IsShown())
fire(eventFrame,"PLAYER_XP_UPDATE")
fire(eventFrame,"PLAYER_DEAD")
fire(eventFrame,"PLAYER_MONEY")
assert(B.events[2]=="PLAYER_XP_UPDATE" and
  B.events[3]=="PLAYER_DEAD" and B.events[4]=="PLAYER_MONEY")
local slash=SlashCmdList.WARRIORCOMPANIONBUILD
assert(type(slash)=="function")
slash("")
assert(B.frame:IsShown() and B.db.displayMode=="full")
slash("mini")
assert(not B.frame:IsShown() and B.compactDashboard:IsShown())
slash("hide")
assert(not B.compactDashboard:IsShown() and B.db.displayMode=="hidden")
slash("autostart on")
assert(B.db.autoOpen==true and B.db.displayMode=="compact")
slash("autostart off")
assert(B.db.autoOpen==false)
slash("alerts off")
assert(B.db.showAlerts==false)
slash("alerts on")
assert(B.db.showAlerts==true)
slash("minimap off")
assert(not B.minimapButton:IsShown())
slash("minimap on")
assert(B.minimapButton:IsShown())
slash("reset")
assert(B.resets==1)
slash("parcours")
assert(B.selectedPage=="parcours" and B.frame:IsShown())
fire(eventFrame,"PLAYER_ENTERING_WORLD")
assert(B.started==1 and B.iconCreated==1,
  "le changement de zone ne recree pas les fenetres ni la session")
print("OK: demarrage uniquement minimap, commandes mini/full, autostart, alertes, reset")
