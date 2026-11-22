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
local empty={}
WC:AddGearQuestAdvice(empty)
assert(#empty==0,"no unsolicited recommendations")
local actionable={{id="fury-offhand-empty",priority="info"}}
WC:AddGearQuestAdvice(actionable)
assert(#actionable==2 and actionable[2].id=="gearquest-review")
assert(actionable[2].message:find("/gq",1,true))
assert(actionable[2].message:find("Aucun gain ni prix",1,true))
assert(not actionable[2].message:find("Wingblade",1,true))
WC:ShowGearQuestStatus()
assert(messages[#messages]:find("n'importe aucun score",1,true))
WC:AddGearQuestAdvice(actionable)
assert(#actionable==3,"decision based on real source observations")
WC.inCombat=true
WC:AddGearQuestAdvice(actionable)
assert(#actionable==3,"no new reminder in combat")
WC.inCombat=false
loaded=false
local absent={{id="fury-slow-combat"}}
WC:AddGearQuestAdvice(absent)
assert(#absent==1,"missing GearQuest cannot supply items")
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
local notWarrior={{id="fury-offhand-empty"}}
WC:AddGearQuestAdvice(notWarrior)
assert(#notWarrior==1)
WC.IsWarrior=function() return true end
IsAddOnLoaded=function() return 987654 end
issecretvalue=function(x) return x==987654 end
assert(WC:GearQuestAvailability()==nil,"no secret assumptions")
print("OK: GearQuest optional, no third-party copied data, source gating, no fake weapons")
