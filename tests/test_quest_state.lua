-- Contrats de suivi des quetes sur WoW Forever (API moderne C_QuestLog).
local playerLevel=34
function UnitLevel(who) assert(who=="player") return playerLevel end
local B={}
assert(loadfile("Addon/WarriorCompanionBuild/Data.lua"))("WarriorCompanionBuild",B)
assert(loadfile("Addon/WarriorCompanionBuild/TalentTrees.lua"))("WarriorCompanionBuild",B)
assert(loadfile("Addon/WarriorCompanionBuild/Planner.lua"))("WarriorCompanionBuild",B)
_G.WCBuildDB=nil
B:InitState()
assert(B:SegmentAt(30)==4 and B:SegmentAt(40)==4 and
  B:SegmentAt(41)==5 and B:SegmentAt(60)==6,
  "les tranches ne se chevauchent pas")
local completed={[1718]=true,[1105]=true}
local log={
  {questID=5561,isHeader=false,isComplete=false},
  {questID=1362,isHeader=false,readyForTurnIn=true},
  {isHeader=true,title="Desolace"},
}
C_QuestLog={
  IsQuestFlaggedCompleted=function(id)
    return completed[id]==true
  end,
  GetNumQuestLogEntries=function() return #log,2 end,
  GetInfo=function(index) return log[index] end,
  IsComplete=function(id) return false end,
  GetQuestObjectives=function(id)
    if id==5561 then
      return {{text="Kodos captures : 2/5",finished=false},
        {text="Retour au donneur de quete",finished=false}}
    end
    return {}
  end,
  GetLogIndexForQuestID=function(id)
    for i,entry in ipairs(log) do
      if entry.questID==id then return i end
    end
    return nil
  end,
}
assert(B:ReadQuestLog())
assert(B:QuestLiveState(5561)=="ACTIVE")
assert(B:QuestObjectiveSummary(5561)=="Kodos captures : 2/5",
  "la progression vient de l'objectif actif lu dans le journal")
assert(B:QuestLiveState(1362)=="READY")
assert(B:QuestLiveState(1105)=="DONE")
local byId={}
for _,step in ipairs(B.route) do byId[step.id]=step end
assert(B:StepState(byId["desolace-kodo"])=="EN COURS")
assert(B:StepState(byId["desolace-kolkar"])=="A RENDRE")
assert(B:StepState(byId["salt-hardened-shells"])=="QUETE TERMINEE")
local hidden=B:RouteSegmentEntries(4,false)
local full=B:RouteSegmentEntries(4,true)
assert(#full==#hidden+2,
  "les deux quetes rendues restent en historique, pas a refaire")
for _,entry in ipairs(hidden) do
  assert(entry.step.questId~=1105 and entry.step.questId~=1718)
end
local first=B:FirstSuggestedStep(hidden)
assert(first and first.questId==1362,
  "la quete a rendre prime sur les objectifs nouvellement proposes")
assert(not B:MarkRouteSelection(byId["desolace-kodo"]),
  "une quete ne peut pas etre validee manuellement")
assert(B:MarkRouteSelection(byId["lvl33"]),
  "un deplacement peut etre valide manuellement")
assert(B:IsStepDone(byId["lvl33"]))
assert(B:MarkRouteSelection(byId["lvl33"]))
assert(not B:IsStepDone(byId["lvl33"]))
assert(not B:MarkRouteSelection(byId["quest-scarlet"]),
  "un donjon reste une option non validable automatiquement")
assert(B:SelectRouteSegment(5) and B:CurrentRouteSegment()==5)
assert(#B:RouteSegmentEntries(6,false)==0,
  "50-60 ne doit pas inventer d'etapes de quete")
-- Mise a jour : accepter, finir sans rendre, puis rendre.
log={{questID=5561,isComplete=true,isHeader=false}}
B:ReadQuestLog()
assert(B:StepState(byId["desolace-kodo"])=="A RENDRE",
  "terminer les objectifs ne vaut pas rendu de quete")
completed[5561]=true
log={}
B:ReadQuestLog()
assert(B:StepState(byId["desolace-kodo"])=="QUETE TERMINEE")
for _,entry in ipairs(B:RouteSegmentEntries(4,false)) do
  assert(entry.step.questId~=5561,"une quete rendue disparait du segment actif")
end
assert(B:QuestCompletion(99999)==false,
  "une API disponible peut confirmer la non-completion")
-- API degradee : ne jamais conclure a la completion ou a l'acceptation.
C_QuestLog=nil
B.questLog=nil
assert(B:QuestCompletion(1105)==nil and B:QuestLiveState(5561)==nil)
assert(B:StepState(byId["desolace-kodo"])~="QUETE TERMINEE")
print("OK: Forever quest log, 30-40 segment, active/ready/done, fallback")
