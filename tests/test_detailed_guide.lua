-- Guide detaille : scenarios au niveau 35, reprise et pre-requis.
local currentLevel=35
function UnitLevel(who) assert(who=="player") return currentLevel end
local B={}
assert(loadfile("Addon/WarriorCompanionBuild/Data.lua"))("WarriorCompanionBuild",B)
assert(loadfile("Addon/WarriorCompanionBuild/Planner.lua"))("WarriorCompanionBuild",B)
assert(loadfile("Addon/WarriorCompanionBuild/DetailedGuide.lua"))("WarriorCompanionBuild",B)
assert(loadfile("Addon/WarriorCompanionBuild/DetailedData30_40.lua"))("WarriorCompanionBuild",B)
local audit=B:DetailedAudit()
assert(audit.steps==302 and audit.packs==14,
  "toutes les 302 etapes et 14 sections du guide source sont conservees")
assert(audit.coords==285 and audit.questActions==217,
  "285 coordonnees et 217 actions de quete doivent etre conservees")
assert(audit.unknownMaps==0 and audit.badQuestIDs==0,
  "aucune carte inconnue ni ID numeriquement invalide")
assert(audit.customIDs[98070] and audit.customIDs[93225],
  "les deux ID propres a Forever ne doivent pas etre remplaces")
_G.WCBuildDB=nil
B:InitState()
B.db.detailedMode=true
local turnedIn={}
local active={}
C_Map={GetBestMapForUnit=function() return 1443 end}
C_QuestLog={
 IsQuestFlaggedCompleted=function(id) return turnedIn[id]==true end,
 GetNumQuestLogEntries=function()
   local n=0
   for _ in pairs(active) do n=n+1 end
   return n,0
 end,
 GetInfo=function(i)
   local ids={}
   for id in pairs(active) do ids[#ids+1]=id end
   table.sort(ids)
   local id=ids[i]
   if not id then return nil end
   return {isHeader=false,questID=id,
     isComplete=active[id]=="READY"}
 end,
 IsComplete=function(id) return active[id]=="READY" end,
 GetQuestObjectives=function(id)
   if id==5561 then return {{text="Kodos captures : 2/5",finished=false}} end
   return {}
 end,
 GetTitleForQuestID=function(id)
   if id==5561 then return "Le rassemblement des kodos" end
   return nil
 end
}
B:ReadQuestLog()
local entries=B:DetailedEntries(false)
assert(#entries==302,"un perso sans quetes n'a pas de quete inventee faite")
local first=B:GuideSuggestedStep(entries)
assert(first and first.packMax>=34 and
  B.guidePacks[first.pack].majorMap==1443,
  "reprise au niveau 35 en Desolace")
assert(first.guide and first.mapID==1443 or not first.mapID)
assert(B:GuideTarget(first)==nil or B:GuideTarget(first).mapID==1443)
local accept,complete,turnin=nil,nil,nil
for _,step in ipairs(B.guideSteps) do
 if step.questId==5561 then
  if step.action=="accept" then accept=step end
  if step.action=="complete" then complete=step end
  if step.action=="turnin" then turnin=step end
 end
end
assert(complete and turnin,"les etapes completer/rendre de la quete #5561")
active[5561]="ACTIVE"
B:ReadQuestLog()
assert(B:GuideStepState(complete)=="EN COURS")
assert(B:GuideStepState(turnin)=="OBJECTIFS EN COURS")
assert(B:QuestObjectiveSummary(5561)=="Kodos captures : 2/5")
assert(B:GuideSuggestedStep(B:DetailedEntries(false)).questId==5561,
  "une quete active prime sur une chaine inconnue")
active[5561]="READY"
B:ReadQuestLog()
assert(B:GuideStepDone(complete),"objectifs termines")
assert(not B:GuideStepDone(turnin),"quete pas encore rendue")
assert(B:GuideStepState(turnin)=="À RENDRE")
local nonDone=B:DetailedEntries(false)
for _,entry in ipairs(nonDone) do
 assert(entry.step.id~=complete.id,
   "ne pas recommander les objectifs deja prets")
end
turnedIn[5561]=true
active[5561]=nil
B:ReadQuestLog()
assert(B:GuideStepDone(turnin) and B:GuideStepState(turnin)=="QUÊTE RENDUE")
for _,entry in ipairs(B:DetailedEntries(false)) do
 assert(entry.step.questId~=5561,
   "les actions liees a une quete rendue doivent etre filtrees")
end
local skip=nil
for _,step in ipairs(B.guideSteps) do
 if not step.questId and step.mapID then skip=step break end
end
assert(skip and B:GuideMarkStep(skip))
assert(B:GuideStepState(skip)=="FAIT (MANUEL)" and B:GuideStepDone(skip))
assert(B:GuideMarkStep(skip),"retour arriere possible")
assert(not B:GuideStepDone(skip))
assert(B:GuideMarkStep(complete))
assert(B:GuideStepState(complete)=="IGNORÉE",
  "ignorer une action du guide ne modifie pas le journal WoW")
assert(B:QuestCompletion(5561)==true)
-- Une dependance curatee encore non faite bloque une nouvelle quete.
local prereq=nil
for _,step in ipairs(B.guideSteps) do
 if step.questId then
   for _,curated in ipairs(B.route) do
     if curated.questId==step.questId and curated.requiresAll and
         #curated.requiresAll>0 then
       prereq=step
       break
     end
   end
 end
 if prereq then break end
end
assert(prereq,"le guide source partage des quetes a prerequis connus")
assert(B:GuidePrerequisites(prereq)==false or
  B:GuidePrerequisites(prereq)==nil)
assert(B:GuideText(complete):find("Le rassemblement",1,true),
  "le nom francais du jeu prime sur le texte importe")
print("OK: 302 etapes / 14 sections / 285 coords / 217 actions, niveau 35, journal et reprise")
