-- Scenarios Minage/Forge 1-300 pour WoW Forever 1.60.1.
local B={}
local base="Addon/WarriorCompanionBuild/"
assert(loadfile(base.."ProfessionData.lua"))("WarriorCompanionBuild",B)
assert(loadfile(base.."ProfessionRuntime.lua"))("WarriorCompanionBuild",B)
assert(loadfile(base.."ProfessionPlanner.lua"))("WarriorCompanionBuild",B)
_G.WCBuildDB={}
B.db=_G.WCBuildDB
B.realLevel=35
B:ProfessionsInit()
assert(#B:GuideRegistry()==4)
assert(B:ActiveGuide()=="leveling")
assert(B:SetActiveGuide("mining"))
B.routeSelectedId="mining:foo"
B.routeScroll=11
B:SaveGuideSelection()
assert(B:SetActiveGuide("smithing"))
assert(B:SetActiveGuide("mining"))
assert(B.routeSelectedId=="mining:foo" and B.routeScroll==11,
 "les parcours ont des progressions independantes")
assert(B:SetActiveGuide("combo"))
assert(B:GuideDefinition("invalid")==nil and not B:SetActiveGuide("invalid"))

-- Valeurs du personnage fournies : détecter sans saisir les 1-168 niveaux.
function GetProfessions() return 1,2 end
function GetProfessionInfo(index)
 if index==1 then return "Minage",1,169,225,0,0,186 end
 if index==2 then return "Forge",1,127,225,0,0,164 end
end
assert(B:ReadProfessionSkills())
local rank,cap,source=B:ProfessionSkill("mining")
assert(rank==169 and cap==225 and source=="jeu")
assert(B:ProfessionSkill("smithing")==127)
assert(not B:SetProfessionManualSkill("smithing",180,225),
 "une valeur lue dans le jeu doit primer la saisie manuelle")

local content={
 [0]={{itemID=3575,stackCount=3},{itemID=2772,stackCount=6},
      {itemID=2605,stackCount=2}},
 [-1]={{itemID=3575,stackCount=10}},
}
C_Container={
 GetContainerNumSlots=function(bag)
  local items=content[bag]
  return items and #items or 0
 end,
 GetContainerItemInfo=function(bag,slot)
  return content[bag] and content[bag][slot] or nil
 end,
}
assert(B:ReadProfessionBags())
GetInventoryItemID=function(who,slot)
 assert(who=="player")
 if slot==9 then return 3835 end
 if slot==16 then return 10823 end
 return nil
end
assert(B:ReadProfessionEquipment())
assert(B:ProfessionIsEquipped(3835) and
 B:ProfessionIsEquipped(10823)==true and
 B:ProfessionIsEquipped(7919)==false,
 "les objets portes sont detectes et conserves")
local total,inBag,bank=B:ProfessionStock(3575,true)
assert(total==3 and inBag==3 and bank==nil,
 "ne pas comptabiliser la banque sans lecture")
B.professionBankOpen=true
assert(B:ReadProfessionBank())
total,inBag,bank=B:ProfessionStock(3575,true)
assert(total==13 and bank==10,"lire la banque quand elle est ouverte")
B:RefreshProfessionObservations("BANKFRAME_CLOSED")
assert(B.db.professionBank.stale==true and
  B:ProfessionStock(3575,true)==3,
 "une banque fermee est exclue des avoirs garantis")

-- Livre de Forge Forever : schema reel quand le metier est ouvert.
C_TradeSkillUI={
 GetBaseProfessionInfo=function() return {professionID=164} end,
 GetAllRecipeIDs=function() return {9001,9002} end,
 GetRecipeInfo=function(id)
  return {name=id==9001 and "Boucle en fer" or "Autre",
    learned=id==9001,relativeDifficulty=1}
 end,
 GetRecipeSchematic=function(id)
  return {outputItemID=id==9001 and 7071 or 999,
   reagentSlotSchematics={
    {quantityRequired=1,reagents={{itemID=3575,quantityRequired=1}}}
   }}
 end,
}
assert(B:ReadProfessionRecipes())
assert(B:ProfessionRecipeByItem("smithing",7071).id==9001)
assert(B:ProfessionRecipeByItem("smithing",7071).mats[1][1]==3575)
local forge=B:SmithingStage(127)
assert(forge and forge.item==7071 and forge.to==129)
local count=B:ProfessionCraftBatch(forge,127)
assert(count==2,"proposer un petit lot plutot qu'un achat pour tout 1-300")
local mats=B:ProfessionMaterials(forge,count)
assert(#mats==1 and mats[1].required==2 and mats[1].owned==3)
local plan=B:ProfessionSupplyPlan(mats,169)
assert(not plan.unknown and next(plan.missing)==nil,
 "ne pas demander de minerais quand les barres suffisent")
local stage=B:SmithingStage(140)
local materials=B:ProfessionMaterials(stage,5)
assert(materials and #materials==2)
local supply=B:ProfessionSupplyPlan(materials,169)
assert(supply.smelt[3575]==27,
 "30 barres necessaires moins 3 barres connues, puis fonte 27")
assert(supply.missing[2772]==21,
 "27 minerais requis moins 6 en sacs")
assert(supply.missing[2605]==3,"teinture manquante hors minage")
assert(B:MiningStage(169).to==175)
assert(B:MiningStage(175).required==175)
assert(B:MiningStage(300)==nil and B:SmithingStage(300)==nil)
local guide=B:ProfessionEntries("combo",false)
assert(#guide>=3)
assert(guide[1].step.id=="combo:threshold:175",
 "priorite utilisateur : Minage 169 vers 175")
assert(B:ProfessionEntries("mining",false)[1].step.kind=="gather")
assert(B:ProfessionEntries("smithing",false)[1].step.kind=="craft")
assert(B:ProfessionProgressSummary("combo"):find("Minage 169/225",1,true))
assert(B:ProfessionProgressSummary("combo"):find("Forge 127/225",1,true))

-- Métiers inconnus : diagnostic au lieu d'inventer une valeur 0.
B.db.professionSkills={}
GetProfessions=nil
assert(not B:ReadProfessionSkills())
assert(B:ProfessionSkill("smithing")==nil)
assert(B:ProfessionEntries("combo",false)[1].step.kind=="check")
assert(B:SetProfessionManualSkill("smithing",127,225))
assert(B:SetProfessionManualSkill("mining",169,225))
assert(B:ProfessionSkill("mining")==169)
assert(B:ProfessionSkill("smithing")==127)
-- Recettes non lues : calcul statique référence, avec information explicite.
C_TradeSkillUI=nil
B.db.professionRecipes={}
B:SetActiveGuide("smithing")
local smith=B:ProfessionEntries("smithing",false)
assert(smith[1].state=="RECETTE A VERIFIER",
 "ne pas pretendre qu'une recette de Forge est apprise")
local flagged=smith[1].step
assert(B:ProfessionMarkStep(flagged))
assert(B.db.professionProgress.smithing.done[flagged.id])
assert(B:ProfessionMarkStep(flagged))
assert(not B.db.professionProgress.smithing.done[flagged.id])
-- Garde-fou : valeur secrete ou malformee rejetee.
issecretvalue=function(value) return value==777 end
assert(not B:SetProfessionManualSkill("mining",777,300))
issecretvalue=nil
assert(not B:SetProfessionManualSkill("mining",301,300))
print("OK: 4 guides, detection, banque, recettes, stocks et scenario 35 / 169 / 127")
