-- Integration prudente GearQuest Forever : aucune donnée tiers inventee.
local loaded = true
C_AddOns = {IsAddOnLoaded = function(name)
  assert(name=="GearQuestForever")
  return loaded
end}
local messages={}
local WC={inCombat=false}
function WC:Print(s) messages[#messages+1]=s end
function WC:IsWarrior() return true end
assert(loadfile("Addon/WarriorCompanion/WeaponTargets.lua"))("WarriorCompanion",WC)
assert(WC:GearQuestAvailability()==true)
function WC:Now() return self.now or 100 end
local empty={}
WC:AddGearQuestAdvice(empty)
assert(#empty==0,"no unprompted full-gear reminder")
WC:ObserveGearReviewEvent("PLAYER_EQUIPMENT_CHANGED")
WC:AddGearQuestAdvice(empty)
assert(#empty==1 and empty[1].id=="gearquest-review")
assert(empty[1].message:find("tous les emplacements",1,true))
assert(empty[1].message:find("armure",1,true))
assert(empty[1].message:find("bijoux",1,true))
assert(empty[1].priority=="info")
assert(empty[1].message:find("Aucun gain ni prix",1,true))
WC:ShowGearQuestStatus()
assert(messages[#messages]:find("n'importe aucun score",1,true))
WC.inCombat=true
local during={}
WC:AddGearQuestAdvice(during)
assert(#during==0,"no additional in-combat notice")
WC.inCombat=false
WC.now=701
WC:AddGearQuestAdvice(during)
assert(#during==0,"short-lived advice")
WC.now=710
WC:ObserveGearReviewEvent("PLAYER_LEVEL_UP")
WC:AddGearQuestAdvice(during)
assert(#during==1 and during[1].message:find("changement de niveau",1,true))
loaded=false
local absent={}
WC:AddGearQuestAdvice(absent)
assert(#absent==0,"no GearQuest no claimed recommendations")
WC:ShowGearQuestStatus()
assert(messages[#messages]:find("non charge",1,true))
C_AddOns.IsAddOnLoaded=function() error("API unavailable") end
assert(WC:GearQuestAvailability()==nil)
C_AddOns=nil
IsAddOnLoaded=nil
assert(WC:GearQuestAvailability()==nil)
WC:ShowGearQuestStatus()
assert(messages[#messages]:find("inconnu",1,true))
IsAddOnLoaded=function(name) return name=="GearQuestForever" end
assert(WC:GearQuestAvailability()==true,"legacy fallback")
WC.IsWarrior=function() return false end
local notWarrior={}
WC:ObserveGearReviewEvent("PLAYER_LEVEL_UP")
WC:AddGearQuestAdvice(notWarrior)
assert(#notWarrior==0)
WC.IsWarrior=function() return true end
IsAddOnLoaded=function() return 987654 end
issecretvalue=function(x) return x==987654 end
assert(WC:GearQuestAvailability()==nil,"no secret assumptions")
print("OK: GearQuest optional, whole-equipment suggestions, event gating, no false recommendations")
