-- Etape B : verifications des itineraires, options, modes et reprise.
local playerLevel=35
function UnitLevel() return playerLevel end
local currentMap=1443
local characterX,characterY=.5,.5
C_Map={
  GetBestMapForUnit=function() return currentMap end,
  GetPlayerMapPosition=function()
    return {x=characterX,y=characterY,
      GetXY=function(self) return self.x,self.y end}
  end,
}
local finished,active={},{} 
C_QuestLog={
  IsQuestFlaggedCompleted=function(id) return finished[id] or false end,
  GetNumQuestLogEntries=function() return 0,0 end,
  GetInfo=function() return nil end
}
local B={}
assert(loadfile("Addon/WarriorCompanionBuild/Data.lua"))("WarriorCompanionBuild",B)
assert(loadfile("Addon/WarriorCompanionBuild/Planner.lua"))("WarriorCompanionBuild",B)
assert(loadfile("Addon/WarriorCompanionBuild/DetailedGuide.lua"))("WarriorCompanionBuild",B)
assert(loadfile("Addon/WarriorCompanionBuild/DetailedData30_40.lua"))("WarriorCompanionBuild",B)
assert(loadfile("Addon/WarriorCompanionBuild/AdaptiveRoute.lua"))("WarriorCompanionBuild",B)
_G.WCBuildDB=nil
B:InitState()
B:AdaptiveInit()
assert(B:AdaptiveMode()=="safe" and B.db.routeMode=="safe",
  "Sécurité activée par défaut")
assert(B:AdaptiveOptionEnabled("weapons") and
  B:AdaptiveOptionEnabled("armor") and
  B:AdaptiveOptionEnabled("professions") and
  not B:AdaptiveOptionEnabled("dungeons"),
  "les donjons ne sont pas imposés par défaut")
assert(#B.guideSteps==302)
local full=B:AdaptiveEntries(true)
assert(#full>302,"des détours métier et équipement enrichissent le guide")
local categories={}
for _,entry in ipairs(full) do
  if entry.step.detour then categories[entry.step.category]=true end
end
assert(categories.weapons and categories.armor and categories.professions,
  "les catégories métier, arme et armure existent")
assert(not categories.dungeons,"donjons masqués en Sécurité")
assert(B:AdaptiveSetOption("dungeons",true))
local withDungeons=B:AdaptiveEntries(true)
assert(#withDungeons>#full)
local someDungeon=nil
for _,entry in ipairs(withDungeons) do
  if entry.step.detour and entry.step.category=="dungeons" then
    someDungeon=entry.step
    assert(B:AdaptiveEligibility(entry.step,entry.state)==false,
      "un donjon ne devient jamais une étape XP obligatoire")
    break
  end
end
assert(someDungeon and B:AdaptiveTarget(someDungeon)==nil,
  "un détour sans coordonnées ne doit pas inventer de point de navigation")
assert(B:AdaptiveChoose(someDungeon,true) and B.db.guidePinned)
assert(B:AdaptiveSuggestedStep(withDungeons).id==someDungeon.id,
  "l'utilisateur peut consulter explicitement un donjon")
currentMap=1441
B:AdaptiveInvalidate("zone")
assert(not B.db.guidePinned,
  "un donjon sans coordonnées ne doit pas rester bloqué après un voyage")
currentMap=1443
B:AdaptiveResume()
assert(not B.db.guidePinned and B.db.guideSelectedId==nil,
  "reprendre libère le choix manuel")

-- La disponibilité ne doit jamais être supposée : une étape à rendre
-- avant d'avoir fini ses objectifs est bloquée.
local accept={id="a",guide=true,questId=500,action="accept",
 level=35,pack=1,packMax=36,mapID=1443,guideIndex=1}
local objective={id="b",guide=true,questId=500,action="complete",
 level=35,pack=1,packMax=36,mapID=1443,guideIndex=2}
local turnin={id="c",guide=true,questId=500,action="turnin",
 level=35,pack=1,packMax=36,mapID=1443,guideIndex=3}
assert(not B:AdaptiveEligibility(objective,B:AdaptiveStepState(objective)),
  "pas de combat recommandé sans quête acceptée")
assert(not B:AdaptiveEligibility(turnin,B:AdaptiveStepState(turnin)),
  "pas de rendu recommandé sans objectifs terminés")
local curatedPrereq=nil
for _,step in ipairs(B.route) do
  if step.questId==1435 then
    curatedPrereq={id="detour:prereq-test",detour=true,guide=true,
      category="armor",questId=1435,sourceStep=step,level=35}
    break
  end
end
assert(curatedPrereq and
  B:AdaptiveStepState(curatedPrereq)=="PRÉREQUIS MANQUANT",
  "ne pas faire passer une quête à prérequis manquant pour disponible")
assert(not B:AdaptiveEligibility(curatedPrereq,
  B:AdaptiveStepState(curatedPrereq)))
-- La priorité du journal l'emporte sur la distance, mais uniquement
-- pour une quête réellement acceptée ou prête à rendre.
local done={ [700]=false }
local live={ [700]="ACTIVE" }
B.QuestLiveState=function(_,id)
  if done[id] then return "DONE" end
  return live[id]
end
B.QuestCompletion=function(_,id) return done[id] or false end
local inProgress={id="doing",guide=true,questId=700,action="complete",
 level=35,pack=1,packMax=36,mapID=1443,x=80,y=80,guideIndex=4}
local nearer={id="new",guide=true,questId=701,action="accept",
 level=35,pack=1,packMax=36,mapID=1443,x=62,y=62,guideIndex=5}
local function asEntries(steps)
  local result={}
  for i,step in ipairs(steps) do
    result[#result+1]={step=step,state=B:AdaptiveStepState(step),order=i}
  end
  return result
end
local candidates=asEntries({inProgress,nearer})
assert(B:AdaptiveSuggestedStep(candidates).id=="doing",
  "quête active prioritaire avant une nouvelle quête hors du hub")
-- Nouvelle règle de regroupement : ne pas quitter un hub alors qu'une
-- quête du même chapitre est à prendre à quelques points de carte.
nearer.x,nearer.y=52,50
assert(B:AdaptiveSuggestedStep(asEntries({inProgress,nearer})).id=="new",
  "récupérer une quête du même hub avant le trajet vers les objectifs")
nearer.pack=2
assert(B:AdaptiveSuggestedStep(asEntries({inProgress,nearer})).id=="doing",
  "pas de regroupement entre chapitres différents")
nearer.pack=1
nearer.mapID=1441
assert(B:AdaptiveSuggestedStep(asEntries({inProgress,nearer})).id=="doing",
  "pas de distance ni de regroupement entre cartes")
nearer.mapID=1443
characterX,characterY=nil,nil
assert(B:AdaptiveSuggestedStep(asEntries({inProgress,nearer})).id=="doing",
  "position illisible : conserver la priorité du journal")
characterX,characterY=.5,.5
inProgress.x,inProgress.y=54,54
assert(B:AdaptiveSuggestedStep(asEntries({inProgress,nearer})).id=="doing",
  "ne pas interrompre les objectifs déjà proches")
inProgress.x,inProgress.y=80,80
local blocked=asEntries({inProgress,nearer})
blocked[2].state="PRÉREQUIS MANQUANT"
assert(B:AdaptiveSuggestedStep(blocked).id=="doing",
  "ne pas grouper une quête bloquée")
local readyAtHub={id="ready",guide=true,questId=500,action="turnin",
  level=35,pack=1,packMax=36,mapID=1443,x=51,y=51,guideIndex=10}
live[500]="READY"
assert(B:AdaptiveSuggestedStep(asEntries({inProgress,nearer,readyAtHub})).id=="ready",
  "rendu prioritaire sur le regroupement local")
live[500]=nil
B:AdaptiveChoose(inProgress,true)
assert(B:AdaptiveSuggestedStep(asEntries({inProgress,nearer})).id=="doing",
  "le regroupement ne remplace jamais un choix manuel")
B:AdaptiveInvalidate("preference")
B.db.guidePinned=false
B.db.guideSelectedId=nil
B.routeSelectedId=nil
live[700]="READY"
assert(B:AdaptiveStepDone(inProgress),
  "les objectifs finis disparaissent sans marquer la quête rendue")
candidates=asEntries({inProgress,turnin,nearer})
assert(B:AdaptiveSuggestedStep(candidates).id=="new",
  "une étape de rendu non prête n'est pas conseillée")
live[500]="READY"
candidates=asEntries({nearer,turnin})
assert(B:AdaptiveSuggestedStep(candidates).id=="c",
  "rendre une quête prête passe avant accepter une nouvelle quête")
done[500]=true
assert(B:AdaptiveStepDone(turnin),"une quête rendue ne réapparaît pas")
-- L'absence de changement de position doit laisser l'ordre historique
-- stable, sans fabriquer de durée de trajet.
local here={id="here",guide=true,level=35,pack=1,
 packMax=36,mapID=1443,x=49,y=49,guideIndex=7}
local away={id="away",guide=true,level=35,pack=1,
 packMax=36,mapID=1441,x=49,y=49,guideIndex=6}
local far={id="far",guide=true,level=35,pack=1,
 packMax=36,mapID=1443,x=90,y=90,guideIndex=8}
B.routeSelectedId=nil
local sameLevel=asEntries({away,far,here})
assert(B:AdaptiveSuggestedStep(sameLevel).id=="here",
  "regrouper les étapes proches dans la zone courante")
assert(B:AdaptiveSetMode("xp") and B:AdaptiveMode()=="xp")
local future={id="future",guide=true,level=36,pack=1,
 packMax=36,mapID=1443,x=50,y=50,guideIndex=9}
assert(B:AdaptiveEligibility(future,"ÉTAPE À SUIVRE"),
  "XP rapide accepte un palier 1 niveau plus haut")
B:AdaptiveSetMode("safe")
assert(not B:AdaptiveEligibility(future,"ÉTAPE À SUIVRE"),
  "Sécurité n'impose pas de palier au-dessus du niveau réel")
-- Le filtre se base sur la fin du chapitre, pas sur le niveau
-- minimal du chapitre ni sur une estimation du niveau d'un mob.
local obsolete={id="obsolete",guide=true,level=30,packMax=31,
  pack=1,mapID=1443,x=50,y=50,questId=800,action="accept"}
local recent={id="recent",guide=true,level=31,packMax=32,
  pack=1,mapID=1441,questId=801,action="accept"}
assert(not B:AdaptiveEligibility(obsolete,"À ACCEPTER"))
assert(B:AdaptiveEligibility(recent,"À ACCEPTER"))
assert(B:AdaptiveEligibility(obsolete,"EN COURS"))
assert(B:AdaptiveEligibility(obsolete,"À RENDRE"))
assert(B:AdaptiveSuggestedStep(asEntries({obsolete,recent})).id=="recent",
  "un ancien chapitre local ne détourne pas la reprise")
assert(B:AdaptiveSuggestedStep(asEntries({obsolete}))==nil,
  "ne pas inventer d'objectif lorsque seuls les anciens chapitres restent")
B:AdaptiveChoose(obsolete,true)
assert(B:AdaptiveSuggestedStep(asEntries({obsolete,recent})).id=="obsolete",
  "ancien chapitre toujours consultable à la demande")
B.db.guidePinned=false
B.db.guideSelectedId=nil
B.routeSelectedId=nil
assert(B:AdaptiveSetMode("xp"))
assert(not B:AdaptiveEligibility(obsolete,"À ACCEPTER"),
  "XP rapide ne relance pas non plus les anciens chapitres")
B:AdaptiveSetMode("safe")
assert(B:AdaptiveSetMode("invalid")==false)
assert(B:AdaptiveSetOption("dungeons",false))
assert(B:AdaptiveOptionEnabled("dungeons")==false and
 B.db.routeOptions.dungeons==false,"préférences persistées")
-- Reprise manuelle : une sélection explicitement épinglée est libre.
B:AdaptiveChoose(here,true)
assert(B:AdaptiveSuggestedStep(sameLevel).id=="here")
currentMap=1441
B:AdaptiveInvalidate("zone")
assert(not B.db.guidePinned and B.routeSelectedId==nil,
  "une déviation de zone libère l'épingle de l'ancien endroit")
assert(B:AdaptiveSuggestedStep(sameLevel).id=="away",
  "la recommandation repart du hub de la nouvelle zone")
-- Une étape purement géographique ne doit pas inventer des coordonnées.
assert(B:AdaptiveTarget(here)==nil or B:AdaptiveTarget(here).mapID==1443)
assert(B:AdaptiveText(someDungeon):find("Option",1,true))
assert(B:AdaptiveStepHelp(someDungeon):find("facultatif",1,true))
print("OK: mode XP/Sécurité, 4 options, proximité, journal, prérequis et reprise")
