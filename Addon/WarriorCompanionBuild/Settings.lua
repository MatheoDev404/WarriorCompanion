local _,B=...
-- Reglages accessibles dans l'interface, pas seulement avec /wcb.
-- Module charge apres UI.lua/ProfessionUI.lua : reuse le kit graphique.
local function safeNumber(value)
 if type(issecretvalue)=="function" then
  local ok,secret=pcall(issecretvalue,value)
  if not ok or secret then return nil end
 end
 if type(value)~="number" then return nil end
 local ok,valid=pcall(function()
  return value==value and value>=0 and value<=300
 end)
 return ok and valid and value or nil
end
local function field(parent,x,y,w)
 local e=CreateFrame("EditBox",nil,parent,"InputBoxTemplate")
 e:SetPoint("TOPLEFT",parent,"TOPLEFT",x,y)
 e:SetSize(w,23)
 if type(e.SetAutoFocus)=="function" then e:SetAutoFocus(false) end
 if type(e.SetNumeric)=="function" then e:SetNumeric(true) end
 if type(e.SetMaxLetters)=="function" then e:SetMaxLetters(3) end
 if type(e.SetTextInsets)=="function" then e:SetTextInsets(7,7,0,0) end
 if type(e.SetScript)=="function" then
  e:SetScript("OnEnterPressed",function(self)
   if type(self.ClearFocus)=="function" then self:ClearFocus() end
  end)
  e:SetScript("OnEscapePressed",function(self)
   if type(self.ClearFocus)=="function" then self:ClearFocus() end
  end)
 end
 return e
end
local function printSettings(self,message)
 if self.settingsStatus then
  self.settingsStatus:SetText(message or "")
 end
end
function B:CreateSettings()
 if self.settingsFrame then return self.settingsFrame end
 if not self.frame or not self.uiKit then return nil end
 local kit=self.uiKit
 local panel=CreateFrame("Frame",nil,self.frame)
 panel:SetPoint("TOPLEFT",self.frame,"TOPLEFT",24,-48)
 panel:SetSize(712,425)
 if type(panel.SetFrameLevel)=="function" and
    type(self.frame.GetFrameLevel)=="function" then
  panel:SetFrameLevel(self.frame:GetFrameLevel()+22)
 end
 if type(panel.EnableMouse)=="function" then panel:EnableMouse(true) end
 kit.rect(panel,0,0,712,425,{.055,.069,.089,.985})
 kit.rect(panel,0,0,712,42,kit.PANEL)
 kit.rect(panel,0,-41,712,2,kit.GOLD)
 kit.label(panel,18,-7,408,29,"GameFontNormalLarge",
  "RÉGLAGES · WARRIOR COMPANION",kit.WHITE)
 kit.button(panel,612,-8,83,27,"Fermer",function() panel:Hide() end)

 kit.label(panel,18,-50,290,24,"GameFontNormal","NAVIGATION",kit.GOLD)
 kit.label(panel,365,-50,320,24,"GameFontNormal","AFFICHAGE",kit.GOLD)

 self.settingsControls={}
 local c=self.settingsControls
 c.compass=kit.button(panel,18,-77,300,27,"Boussole : afficher",function()
  B:SetCompassEnabled(not (B.db.compassEnabled~=false))
  B:RefreshSettings()
 end)
 c.scaleMinus=kit.button(panel,18,-111,48,27,"-",function()
  B:SetCompassScale((B.db.compassScale or 1)-.10)
  B:RefreshSettings()
 end)
 c.scalePlus=kit.button(panel,267,-111,51,27,"+",function()
  B:SetCompassScale((B.db.compassScale or 1)+.10)
  B:RefreshSettings()
 end)
 c.compassSize=kit.label(panel,77,-111,178,27,
   "GameFontNormal","Flèche : 100 %",kit.WHITE)
 c.compassReset=kit.button(panel,18,-145,300,27,"Recentrer la flèche",function()
  B.db.compassPoint=nil
  local f=B.compassFrame
  if f and type(f.ClearAllPoints)=="function" and
      type(f.SetPoint)=="function" then
   f:ClearAllPoints()
   f:SetPoint("CENTER",UIParent,"CENTER",0,160)
  end
  printSettings(B,"Flèche recentrée. Déplacer en glissant sur la flèche.")
 end)

 c.mini=kit.button(panel,365,-77,330,27,"Ouvrir le mini-bilan",function()
  panel:Hide()
  B:ShowCompact()
 end)
 c.auto=kit.button(panel,365,-111,330,27,"Ouverture automatique",function()
  B.db.autoOpen=not (B.db.autoOpen==true)
  if B.db.autoOpen and B.db.displayMode=="hidden" then
   B.db.displayMode="compact"
  end
  B:RefreshSettings()
 end)
 c.alert=kit.button(panel,365,-145,330,27,"Alertes du mini-bilan",function()
  B.db.showAlerts=not (B.db.showAlerts~=false)
  if B.RefreshCompactDashboard then B:RefreshCompactDashboard() end
  B:RefreshSettings()
 end)
 c.minimap=kit.button(panel,365,-179,330,27,"Icône minimap",function()
  B:SetMinimapVisible(not (B.db.minimapVisible~=false))
  B:RefreshSettings()
 end)

 kit.label(panel,18,-190,320,24,"GameFontNormal","PARCOURS",kit.GOLD)
 c.safe=kit.button(panel,18,-219,145,27,"Sécurité",function()
  B:AdaptiveSetMode("safe")
  B:RefreshSettings()
  if B.RefreshRoute then B:RefreshRoute() end
 end)
 c.xp=kit.button(panel,173,-219,145,27,"XP rapide",function()
  B:AdaptiveSetMode("xp")
  B:RefreshSettings()
  if B.RefreshRoute then B:RefreshRoute() end
 end)
 c.route=kit.button(panel,18,-254,145,27,"Ouvrir Parcours",function()
  panel:Hide()
  B:ShowPage("parcours")
 end)
 c.resume=kit.button(panel,173,-254,145,27,"Reprendre",function()
  if B:ActiveGuide()=="leveling" then
   B:AdaptiveResume()
  else
   local p=B.db.professionProgress[B:ActiveGuide()]
   if p then p.selected=nil end
   B.routeSelectedId=nil
   B.routeScroll=0
   B:RefreshProfessionObservations("BAG_UPDATE_DELAYED")
  end
  panel:Hide()
  B:ShowPage("parcours")
 end)

 kit.label(panel,365,-216,320,24,"GameFontNormal",
  "MÉTIERS · SAISIE DE SECOURS",kit.GOLD)
 kit.label(panel,366,-249,70,23,"GameFontHighlightSmall",
  "Minage",kit.MUTED)
 kit.label(panel,366,-286,70,23,"GameFontHighlightSmall",
  "Forge",kit.MUTED)
 c.miningSkill=field(panel,438,-248,63)
 c.miningCap=field(panel,507,-248,63)
 c.smithSkill=field(panel,438,-285,63)
 c.smithCap=field(panel,507,-285,63)
 local function setManual(key,skill,cap)
  local value=type(skill.GetText)=="function" and
    tonumber(skill:GetText()) or nil
  local limit=type(cap.GetText)=="function" and
    tonumber(cap:GetText()) or nil
  if safeNumber(value) and safeNumber(limit) and
      B:SetProfessionManualSkill(key,value,limit) then
   printSettings(B,"Compétence saisie. Le jeu reste prioritaire.")
   if B.RefreshRoute then B:RefreshRoute() end
  else
   printSettings(B,"Saisie refusée : valeurs invalides ou déjà lues dans le jeu.")
  end
  B:RefreshSettings()
 end
 c.miningApply=kit.button(panel,577,-248,118,26,"Appliquer",function()
  setManual("mining",c.miningSkill,c.miningCap)
 end)
 c.smithApply=kit.button(panel,577,-285,118,26,"Appliquer",function()
  setManual("smithing",c.smithSkill,c.smithCap)
 end)
 kit.label(panel,365,-315,330,31,"GameFontHighlightSmall",
  "Les valeurs détectées automatiquement sont prioritaires.",kit.MUTED)

 c.audit=kit.button(panel,18,-355,210,27,"Audit du guide",function()
  local data=B:DetailedAudit()
  printSettings(B,"Guide : "..data.steps.." étapes, "..
    data.coords.." positions, "..data.questActions.." actions de quêtes.")
 end)
 c.reset=kit.button(panel,238,-355,218,27,"Remettre le bilan à zéro",function()
  B:ResetSession()
  printSettings(B,"Mini-bilan de session réinitialisé.")
 end)
 c.hideAll=kit.button(panel,466,-355,229,27,"Masquer les fenêtres",function()
  panel:Hide()
  B:HideDashboard()
 end)
 self.settingsStatus=kit.label(panel,18,-389,676,27,
  "GameFontHighlightSmall","Réglages disponibles sans saisir de commande.",kit.MUTED)
 self.settingsFrame=panel
 panel:Hide()
 return panel
end
function B:RefreshSettings()
 local c=self.settingsControls
 if not c or not self.db then return end
 local db=self.db
 c.compass.txt:SetText(db.compassEnabled==false and
   "Boussole : masquer (actuellement désactivée)" or
   "Boussole : visible")
 c.compassSize:SetText("Flèche : "..
   math.floor(((db.compassScale or 1)*100)+.5).."%")
 c.auto.txt:SetText(db.autoOpen and
   "Ouverture automatique : oui" or "Ouverture automatique : non")
 c.alert.txt:SetText(db.showAlerts~=false and
   "Alertes mini : actives" or "Alertes mini : désactivées")
 c.minimap.txt:SetText(db.minimapVisible~=false and
   "Icône minimap : visible" or "Icône minimap : masquée")
 c.safe.selected=self:AdaptiveMode()=="safe"
 c.xp.selected=self:AdaptiveMode()=="xp"
 for _,b in ipairs({c.safe,c.xp}) do
  local v=b.selected and self.uiKit.GOLD or self.uiKit.CARD
  b.bg:SetVertexColor(v[1],v[2],v[3],v[4])
 end
 for _,key in ipairs({"mining","smithing"}) do
  local rank,cap,source=self:ProfessionSkill(key)
  local rankField=key=="mining" and c.miningSkill or c.smithSkill
  local capField=key=="mining" and c.miningCap or c.smithCap
  local button=key=="mining" and c.miningApply or c.smithApply
  if type(rankField.SetText)=="function" then
   rankField:SetText(rank and tostring(rank) or "")
  end
  if type(capField.SetText)=="function" then
   capField:SetText(cap and tostring(cap) or "")
  end
  local auto=source=="jeu"
  button.txt:SetText(auto and "Lu en jeu" or "Appliquer")
  if type(button.Enable)=="function" and
      type(button.Disable)=="function" then
   if auto then button:Disable() else button:Enable() end
  end
 end
end
function B:OpenSettings()
 if not self.db then self:InitState() end
 if not self.frame then self:CreateUI() end
 if not self.settingsFrame then self:CreateSettings() end
 if not self.frame:IsShown() then self:OpenFullDashboard() end
 self:RefreshSettings()
 self.settingsFrame:Show()
end
