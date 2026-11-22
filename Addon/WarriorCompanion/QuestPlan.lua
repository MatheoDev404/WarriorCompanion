local _, WC = ...
-- Vue lisible pour les quetes et pistes de route.
-- Les recommandations sont calculees uniquement sur une action du joueur ;
-- aucune recherche globale QuestieDB dans OnUpdate ou au login.
local function validLine(value)
  return type(value)=="string" and value~=""
end

function WC:BuildQuestPlan(mode)
  if self.inCombat then return "En combat","Preparation du parcours uniquement hors combat." end
  if mode=="journal" then
    self:UpdateQuestAdvice()
    local snapshot=self.questAdvice
    if not snapshot or snapshot.reason then
      return "Mon journal","Lecture des quetes indisponible : "..
        tostring(snapshot and snapshot.reason or "non initialise")
    end
    if #snapshot.rows==0 then return "Mon journal","Aucune quete acceptee." end
    local lines={"Quetes acceptees - priorite de rendu / prudence :"}
    local names={ready="A RENDRE",["solo-candidate"]="PISTE SOLO",
      caution="PRUDENCE",hard="DIFFICILE",group="GROUPE / DONJON",
      low="XP A VERIFIER",unknown="TYPE INCONNU",failed="ECHOUEE"}
    for i=1,math.min(7,#snapshot.rows) do
      local row=snapshot.rows[i]
      lines[#lines+1]="["..tostring(row.level).."] "..row.name..
        "  -  "..(names[row.category] or "A VERIFIER")
    end
    lines[#lines+1]="Niveau de quete ~= niveau des ennemis ; confirmer dans Questie."
    return "Mon journal",table.concat(lines,"\n")
  end
  self:UpdateQuestAdvice()
  if mode=="discover" then
    local found,reason=self:DiscoverQuests(7)
    if not found then return "Quetes a prendre","Indisponible : "..tostring(reason) end
    if #found.rows==0 then
      return "Quetes a prendre","Aucune piste suffisamment documentee."
    end
    local lines={"Pistes QuestieDB (non acceptees, a verifier en jeu) :"}
    for _,row in ipairs(found.rows) do
      lines[#lines+1]="["..tostring(row.level).."] "..row.name..
        "  (#"..tostring(row.id)..")"
    end
    lines[#lines+1]="Accessibilite, objectifs, danger et trajet non garantis."
    return "Quetes a prendre",table.concat(lines,"\n")
  end
  if mode=="route" then
    local found,reason=self:DiscoverQuests(40)
    if not found then return "Parcours / pistes","Indisponible : "..tostring(reason) end
    local groups,why=self:BuildQuestClusters(found)
    if not groups then return "Parcours / pistes","Indisponible : "..tostring(why) end
    if #groups==0 then
      return "Parcours / pistes","Aucun regroupement de PNJ confirme par QuestieDB."
    end
    local lines={"DEPARTS REGROUPES - pas encore un itineraire d'objectifs"}
    for i=1,math.min(3,#groups) do
      local g=groups[i]
      lines[#lines+1]="Zone #"..tostring(g.zone)..
        " : "..tostring(#g.rows).." piste(s) a confirmer"
      for j=1,math.min(2,#g.rows) do
        local q=g.rows[j]
        lines[#lines+1]="  ["..tostring(q.level).."] "..q.name
      end
    end
    lines[#lines+1]="Pas de garantie solo, de distance ou de temps de trajet."
    return "Parcours / pistes",table.concat(lines,"\n")
  end
  return "Plan de leveling","Choisis Journal, A prendre ou Parcours."
end

function WC:SelectQuestPlan(mode)
  local title,detail=self:BuildQuestPlan(mode)
  self.questPlanTitle=validLine(title) and title or "Plan de leveling"
  self.questPlanText=validLine(detail) and detail or "Aucune donnee verifiee."
  self.questPlanMode=mode
  if self.dashboardQuestDetail then
    self.dashboardQuestDetail:SetText(self.questPlanText)
  end
  if self.dashboardQuestTitle then
    self.dashboardQuestTitle:SetText(self.questPlanTitle)
  end
end

function WC:OpenQuestPlan(mode)
  if not self.dashboard then return end
  if not self.dashboard:IsShown() then self.dashboard:Show() end
  self:ShowDashboardPage("quests")
  self:SelectQuestPlan(mode or "journal")
end
