local level=33
function UnitLevel() return level end
local ids={[5]=nil,[11]=nil,[12]=nil}
function GetInventoryItemID(_,slot) return ids[slot] end
function GetItemInfo(id)
  local names={[17694]="Anneau du poing",[9588]="Anneau d'or de Nogg",
    [18585]="Anneau d'allegeance",[7133]="Haubert de brutalite"}
  if names[id] then return names[id] end
  if id==55 then return "Anneau courant",nil,2,40 end
  return nil
end
local completed={}
C_QuestLog={IsQuestFlaggedCompleted=function(id) return completed[id] or false end}
local WC={}
function WC:IsWarrior() return true end
assert(loadfile("Addon/WarriorCompanion/EquipmentTargets.lua"))("WarriorCompanion",WC)
local offers=WC:EquipmentQuestTargets(10)
assert(#offers>=3)
assert(offers[1].name=="Anneau du poing")
assert(offers[1].source:find("Brassenoire",1,true))
assert(offers[1].risk:find("DONJON",1,true))
assert(offers[1].reason=="emplacement vide")
completed[6565]=true
offers=WC:EquipmentQuestTargets(10)
for _,offer in ipairs(offers) do assert(offer.quest~=6565) end
ids[11]=55;ids[12]=55
offers=WC:EquipmentQuestTargets(10)
for _,offer in ipairs(offers) do
  assert(offer.slot~="anneau","un anneau deja meilleur n'est pas signale")
end
ids[5]=55
offers=WC:EquipmentQuestTargets(10)
assert(#offers==0,"aucune fausse proposition sur equipement plus haut")
level=60; ids[5]=nil;ids[11]=nil;ids[12]=nil
assert(#WC:EquipmentQuestTargets(10)==0,"pas de recompenses obsoletes niveau 60")
WC.IsWarrior=function()return false end
level=33
assert(#WC:EquipmentQuestTargets(10)==0,"pas de recommandation pour non-guerrier")
print("OK: cibles equipeement sources, quetes achevees, niveau, emplacements et classe")
