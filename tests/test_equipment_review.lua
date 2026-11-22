local ids={[1]=500,[3]=503,[5]=505,[6]=506,[7]=507,[8]=508,[9]=509,[10]=510,[11]=511,[12]=512,[13]=513,[14]=514,[15]=515,[16]=516}
local info={}
for slot,id in pairs(ids) do info[id]={"Objet "..slot,2,25} end
info[505]={"Vieille cuirasse",1,7}
info[507]={"Pantalon ancien",0,12}
function UnitLevel() return 30 end
function GetInventoryItemID(_,slot) return ids[slot] end
function GetItemInfo(id)
  local i=info[id]
  if not i then return nil end
  return i[1],nil,i[2],i[3]
end
local WC={}
function WC:IsWarrior() return true end
assert(loadfile("Addon/WarriorCompanion/EquipmentReview.lua"))("WarriorCompanion",WC)
local report=WC:ReadEquipmentReview()
assert(report and #report.rows>=3)
assert(report.rows[1].reason=="emplacement vide","emplacement vide")
local text=WC:EquipmentReviewText()
assert(text:find("Torse",1,true) and text:find("Jambes",1,true))
assert(text:find("pistes",1,true),"n'affirme pas une vraie amelioration")
local list={}
WC:AddEquipmentReviewAdvice(list)
assert(#list==1 and list[1].id=="equipment-review")
ids[2]=502; info[502]={"Collier",2,30}
ids[3]=503; info[503]={"Epaules",2,30}
info[505]={"Torse correct",2,30};info[507]={"Jambes correctes",2,30}
report=WC:ReadEquipmentReview()
assert(#report.rows==0)
list={};WC:AddEquipmentReviewAdvice(list);assert(#list==0)
GetItemInfo=function() return nil end
report=WC:ReadEquipmentReview()
assert(report.unknown>0 and #report.rows==0)
WC.IsWarrior=function() return false end
assert(WC:ReadEquipmentReview()==nil)
-- Propositions directes et localisees d'objets presents dans les sacs.
WC.IsWarrior=function() return true end
GetItemInfo=function(id)
  if id==600 then return "Anneau de test","|cffffffff|Hitem:600|h[Anneau de test]|h|r",
    2,28,20,"Armor","Misc",1,"INVTYPE_FINGER" end
  if id==601 then return "Torse neuf","|cffffffff|Hitem:601|h[Torse neuf]|h|r",
    2,40,25,"Armor","Mail",1,"INVTYPE_CHEST" end
  if id==505 then return "Torse ancien","|cffffffff|Hitem:505|h[Torse ancien]|h|r",
    1,20,1,"Armor","Mail",1,"INVTYPE_CHEST" end
  if id==511 or id==512 then return "Anneau equipe",nil,2,15,10,"Armor","Misc",1,"INVTYPE_FINGER" end
  return nil
end
ids[5]=505;ids[11]=511;ids[12]=512
C_Container={
 GetContainerNumSlots=function(b) return b==0 and 2 or 0 end,
 GetContainerItemID=function(b,slot)
   if b~=0 then return nil end
   return slot==1 and 600 or 601
 end
}
local upgrades=WC:EquipmentBagSuggestions(5)
assert(#upgrades>=2,"identifies named bag candidates")
local bySlot={}
for _,row in ipairs(upgrades) do bySlot[row.slot]=row end
assert(bySlot["Torse"] and bySlot["Torse"].item=="Torse neuf")
assert(bySlot["Anneau 1"] and bySlot["Anneau 1"].item=="Anneau de test")
assert(WC:EquipmentReviewText():find("Torse neuf",1,true))
assert(not WC:EquipmentReviewText():find("GearQuest",1,true))
local alerts={}
WC:AddEquipmentReviewAdvice(alerts)
assert(alerts[1].id=="bag-upgrades")
print("OK: revue des emplacements, propositions des sacs, prudence et sans dependance externe")
