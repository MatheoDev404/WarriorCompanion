local B={}
local playerLevel=34
function UnitLevel(who) assert(who=="player") return playerLevel end
assert(loadfile("Addon/WarriorCompanionBuild/Data.lua"))("WarriorCompanionBuild",B)
assert(loadfile("Addon/WarriorCompanionBuild/TalentTrees.lua"))("WarriorCompanionBuild",B)
assert(loadfile("Addon/WarriorCompanionBuild/Spellbook.lua"))("WarriorCompanionBuild",B)
assert(loadfile("Addon/WarriorCompanionBuild/Planner.lua"))("WarriorCompanionBuild",B)
assert(loadfile("Addon/WarriorCompanionBuild/CombatData.lua"))("WarriorCompanionBuild",B)
_G.WCBuildDB=nil
B:InitState()
assert(B.realLevel==34 and B.viewLevel==34 and B.mode=="follow")
assert(B:ValidateContent(),"talents et lien equipement-quêtes")
local plan=B:PlanAt(34)
assert(plan.ranks["Cruelty"]==5 and plan.ranks["Enrage"]==5
  and plan.ranks["Reckless Swings"]==1)
assert(plan.nextKey=="Flurry")
assert(B:TalentPointAt(34).key=="Reckless Swings" and
  B:TalentPointAt(34).rank==1)
assert(B:TalentPointAt(40).key=="Bloodthirst")
assert(B:TalentPointAt(9)==nil,"pas de points avant le niveau 10")
assert(#B:RotationAt(19,"mono")==4,"aucun sort de niveau 36/40 annonce au 19")
assert(B:RotationAt(40,"mono")[1].name=="Sanguinaire")
assert(B:RotationAt(40,"multi")[1].name=="Tourbillon")
assert(#B:RotationAt(40,"multi")==7)

assert(B:PlanAt(9).nextKey=="Cruelty")
assert(B:PlanAt(60).nextKey==nil)
assert(B:SetPreview(40) and B.viewLevel==40)
playerLevel=35
B:UpdateLevel()
assert(B.realLevel==35 and B.viewLevel==40,"ne pas ecraser l'apercu manuel")
B:ReturnToReal()
assert(B.mode=="follow" and B.viewLevel==35)
local questSource,craftSource,dungeonSource=0,0,0
for _,g in ipairs(B.gear) do
  if g.source=="quest" then questSource=questSource+1
  elseif g.source=="craft" then craftSource=craftSource+1
  elseif g.source=="dungeon" then dungeonSource=dungeonSource+1
  else error("source interdite") end
  local found=false
  for _,step in ipairs(B.route) do
    if g.routeId==step.id then
      assert(step.gearId==g.id)
      if g.source=="quest" then assert(g.questId==step.questId) end
      found=true
    end
  end
  assert(found,"objet sans quete ou forge dans le parcours")
end
assert(questSource==4 and craftSource==3 and dungeonSource==2)
assert(B:FindGearForStep({gearId=7719}).boss=="Herode")
assert(B:FindGearForStep({gearId=7718}).source=="dungeon")
assert(B:RouteHelp({gearId=7719}):find("Butin aleatoire",1,true),
  "aucun butin de boss garanti")
assert(B:RouteHelp({gearId=250607}):find("251459",1,true),
  "la recette doit indiquer le plan et l'acquisition prudente")
assert(#B.talentTrees.Armes==17 and #B.talentTrees.Furie==18
  and #B.talentTrees.Protection==18,
  "trois arbres complets du guerrier Forever")
assert(B:ValidateBuild(B.talentPlans.hybrid),
  "variante 13/38 valide par prerequis et paliers")
local hybrid=B:PlanAt(60,B.talentPlans.hybrid)
assert(hybrid.pointsByTree.Armes==13 and hybrid.pointsByTree.Furie==38
  and hybrid.pointsByTree.Protection==0)
assert(B:TalentPointAt(60,B.talentPlans.hybrid).key=="Deep Wounds"
  and B:TalentPointAt(60,B.talentPlans.hybrid).tree=="Armes")
assert(B:SelectPlanVariant("hybrid"))
assert(B:TalentPointAt(60).key=="Deep Wounds")
assert(B:SelectPlanVariant("fury"))
assert(B:TalentPointAt(60).key=="Booming Voice")
assert(B:SelectTree("Protection") and B.selectedTree=="Protection")
assert(B:SelectTree("Furie"))
local t
for _,g in ipairs(B.gear) do if g.id==17705 then t=g end end
assert(not B:ItemEligible(t,34),"Thrash Blade ne doit pas etre conseillee au 34")
assert(B:ItemEligible(t,45))
local relevant=B:GearListAt(39)
for _,item in ipairs(relevant) do
  assert(item.minLevel<=39 and (not item.requiredLevel or item.requiredLevel<=39),
    "le premier panneau ne doit pas recommander de futures recompenses")
end
assert(#B:GearListAt(20)==0,"aucun objet invente au niveau 20")
local future=B:GearListAt(39,"future")
assert(#future==2 and future[1].id==271802 and future[2].id==17705,
  "les objets du niveau 43/45 restent consultables dans un panneau separe")
assert(relevant[1].id==250607,"Dague de Forge 180 visee au niveau 39")
assert(B:ItemEligible(B:FindGearForStep({gearId=7719}),37))
assert(not B:ItemEligible(B:FindGearForStep({gearId=7719}),35),
  "butin du boss non accessible au niveau 35")
local delayed
for _,item in ipairs(B.gear) do
  if item.id==271802 then delayed=item end
end
assert(delayed and delayed.questId==93128 and delayed.requiredLevel==35
  and delayed.minLevel==43)
assert(not B:ItemEligible(delayed,39),
  "l'arme ne doit pas etre obtenable a 39 sans la longue chaine Gelkis")
local finalQuest
for _,step in ipairs(B.route) do
  if step.gearId==271802 then finalQuest=step end
end
assert(finalQuest and finalQuest.questId==93128 and
  finalQuest.requiresAll[3]==93122,
  "le vrai Khan Jehn doit suivre Checking Things Out, pas quest 1374")

for i=1,4 do
  assert(relevant[i].id~=3843,
    "Jambieres du niveau 29 ne doivent pas masquer les armes 35-39")
end
assert(B:GearRelevance(B.gear[2],39):find("Ancien palier",1,true))
local chain
for _,step in ipairs(B.route) do
  if step.questId==1366 then chain=step end
end
assert(chain and #chain.requiresAll==1 and chain.requiresAll[1]==1365)
local routeById={}
for _,step in ipairs(B.route) do routeById[step.id]=step end
assert(routeById["warrior-islander"].questId==1718 and
  routeById["warrior-affray"].questId==1719 and
  routeById["warrior-affray"].requiresAll[1]==1718,
  "la posture Berserker passe par les quetes de classe 30")
assert(routeById["salt-hardened-shells"].questId==1105 and
  routeById["salt-road"].questId==1175 and
  not routeById["salt-road"].group and
  routeById["salt-road"].kind=="quest",
  "les Salines incluent deux quetes XP sans donjon impose")
assert(routeById["desolace-kodo"].questId==5561 and
  routeById["desolace-catch-day"].questId==5386,
  "les quetes supplementaires de Desolace sont identifiees")
assert(routeById["desolace-cookbook"].optional and
  routeById["desolace-cookbook"].note:find("Wulan",1,true),
  "le vendeur de Cuisine expert reste une etape optionnelle")

assert(B:GoToGear(6802))
local ordered=B:OrderedRoute()
assert(ordered[B.routeIndex].step.id=="quest-scarlet")
assert(B:StepState(ordered[B.routeIndex].step)=="OPTION GROUPE")
assert(not B:MarkStep(),"impossible de valider un donjon optionnel")
local crafted
assert(B:GoToGear(3844))
crafted=B:OrderedRoute()[B.routeIndex].step
assert(B:MarkStep() and B.db.done[crafted.id])
assert(B:StepState(crafted)=="FAIT (MANUEL)")
assert(B:MarkStep() and not B.db.done[crafted.id])
B.routeIndex=nil
B:ReturnToReal()
assert(B:FocusRoute() and B:OrderedRoute()[B.routeIndex].step.level>=35)
-- Un objet de quete sans etape correspondante DOIT invalider le pack.
local old=B.gear[1].routeId
B.gear[1].routeId="route-inexistante"
local ok,why=B:ValidateContent()
assert(not ok and why:find("absent du parcours",1,true))
B.gear[1].routeId=old
-- Interdire de conseiller un objet de niveau 45 au niveau 34.
assert(B:ValidateContent())
assert(B:CombatSectionAt(19,"mono","cycle")[1].name=="Pourfendre")
assert(B:CombatSectionAt(40,"mono","cycle")[1].name=="Sanguinaire")
local foundSunder=false
for _,spell in ipairs(B:CombatSectionAt(34,"mono","cycle")) do
  if spell.name=="Fracasser armure" and spell.spellId==7386 then
    foundSunder=true
  end
end
assert(foundSunder,"Fracasser armure est utile en monocible sur cible robuste")
assert(B:CombatSectionAt(40,"multi","cycle")[1].name=="Tourbillon")
assert(#B:CombatSectionAt(40,"mono","reactive")==3,
  "Fulgurance, Ivresse et Execution ne doivent pas etre masquees")
assert(B:CombatSectionAt(40,"mono","reactive")[1].name=="Fulgurance")
assert(B:RotationCycleSummaryAt(20,"mono"):find("Pourfendre",1,true))
assert(B:RotationCycleSummaryAt(40,"mono"):find("Sanguinaire",1,true))
assert(B:RotationCycleSummaryAt(40,"multi"):find("Enchainement",1,true))
assert(B:ChangeScale(1)==1.15 and B:ChangeScale(-9)==0.65)
print("OK: 3 talent trees, mixed 51 points, gear at level, quest prereqs, rotation steps, route linking")
