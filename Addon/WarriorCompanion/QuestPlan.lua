local _, WC = ...
-- Vues de guide, talents et quetes ; aucun calcul de route concurrent.
-- Les recommandations sont calculees uniquement sur une action du joueur ;
-- aucune recherche globale QuestieDB dans OnUpdate ou au login.
local function validLine(value)
  return type(value)=="string" and value~=""
end

function WC:BuildQuestPlan(mode)
  if mode=="talents" then
    local view=self.TalentPlanText and self:TalentPlanText()
    return "Talents - Furie",view and view.current or "Plan de talents indisponible."
  end
  if mode=="guide" then
    local view=self.GetGuideView and self:GetGuideView()
    if not view then
      return "Guide de leveling", "Aucun guide source verifie n'est encore charge.\nLes vues Journal et A prendre restent disponibles."
    end
    return view.title, (view.status or "").."\n\n"..(view.steps or "")
  end
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
  if mode=="discover" then
    self:UpdateQuestAdvice()
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
  return "Plan de leveling","Choisis GUIDE pour suivre une route, Journal pour tes quetes ou A prendre."
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
  if self.RefreshTalentGuidePanel then self:RefreshTalentGuidePanel() end
  -- Affichage etape par etape pour GUIDE, texte libre pour les autres vues.
  if self.dashboardGuideLocation and self.dashboardGuideNextText then
    if self.dashboardQuestDetail and self.dashboardQuestDetail.SetHeight then
      self.dashboardQuestDetail:SetHeight(mode=="guide" and 77 or 163)
    end
    if mode=="guide" and self.GetGuideView then
      local view=self:GetGuideView()
      self.dashboardQuestDetail:SetText(view and
        ("|cffEBC487A FAIRE MAINTENANT|r\n"..(view.actionText or "")) or
        "Aucun guide disponible.")
      self.dashboardGuideLocation:SetText(view and
        ("|cffA0C8EEOU ALLER|r  "..(view.locationText or "")) or "")
      self.dashboardGuideNextText:SetText(view and
        ("|cffBAAA91ENSUITE|r  "..(view.nextText or "")) or "")
    else
      self.dashboardGuideLocation:SetText("")
      self.dashboardGuideNextText:SetText("")
    end
  end
end

function WC:OpenQuestPlan(mode)
  if not self.dashboard then return end
  if self.OpenFullDashboard then self:OpenFullDashboard()
  elseif not self.dashboard:IsShown() then self.dashboard:Show() end
  self:ShowDashboardPage("quests")
  self:SelectQuestPlan(mode or "journal")
end
