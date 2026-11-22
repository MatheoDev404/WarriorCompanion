local _, WC = ...
-- Vue lisible pour les quetes et pistes de route.
-- Les recommandations sont calculees uniquement sur une action du joueur ;
-- aucune recherche globale QuestieDB dans OnUpdate ou au login.
-- Reperes de zones cites par ForeverTavern, verifications des objectifs
-- et des chaines requises avant toute recommandation de trajet precise.
-- https://forevertavern.net/guides/leveling/horde
local guideStages = {
  {min=30,max=32,label="Contreforts de Hautebrande (30-32)"},
  {min=32,max=33,label="Hautes-terres d'Arathi (32-33)"},
  {min=33,max=34,label="Mille pointes (33-34)"},
  {min=34,max=36,label="Desolace (34-36)"},
  {min=36,max=37,label="Vallee de Strangleronce (36-37)"},
}
local function guideNote()
  if type(UnitLevel)~="function" then return nil end
  local ok,level=pcall(UnitLevel,"player")
  if not ok or type(level)~="number" then return nil end
  if type(issecretvalue)=="function" then
    local clean,hidden=pcall(issecretvalue,level)
    if not clean or hidden then return nil end
  end
  for _,entry in ipairs(guideStages) do
    if level>=entry.min and level<entry.max then
      return "Reference guide Horde : "..entry.label..
        " (ForeverTavern, a verifier avec Questie)."
    end
  end
  return nil
end
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
    local guide=guideNote()
    if guide then lines[#lines+1]=guide end
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
