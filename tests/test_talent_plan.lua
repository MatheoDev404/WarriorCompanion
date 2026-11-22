-- Progression Guerrier Furie 10-60 et reprise au niveau actuel.
local WC={}
local playerLevel=33
function UnitLevel() return playerLevel end
assert(loadfile("Addon/WarriorCompanion/TalentPlan.lua"))("WarriorCompanion",WC)
assert(WC:TalentPlanLevel(9)==nil and WC:TalentPlanLevel(61)==nil)
local totals={}
for level=10,60 do
  local plan=WC:TalentPlanLevel(level)
  assert(plan and plan.level==level and plan.total==level-9,
    "un point par niveau : "..level)
  assert(plan.current.rank>=1 and
         plan.current.rank<=plan.current.maximum,"rang incoherent "..level)
  assert(plan.treePoints.fury==level-9 and plan.treePoints.arms==0
    and plan.treePoints.protection==0,
    "repartition Fury sans respec niveau "..level)
  if level<60 then assert(plan.next and plan.next.level==level+1) end
  totals[plan.current.english]=(totals[plan.current.english] or 0)+1
end
assert(WC:TalentPlanLevel(10).current.english=="Cruelty")
assert(WC:TalentPlanLevel(14).current.rank==5)
assert(WC:TalentPlanLevel(15).current.english=="Unbridled Wrath")
assert(WC:TalentPlanLevel(25).current.english=="Dual Wield Specialization")
assert(WC:TalentPlanLevel(30).current.english=="Death Wish")
assert(WC:TalentPlanLevel(35).current.english=="Flurry")
assert(WC:TalentPlanLevel(40).current.english=="Bloodthirst")
assert(WC:TalentPlanLevel(60).next==nil)
assert(totals.Enrage==5 and totals["Dual Wield Specialization"]==5)
assert(totals["Unbridled Wrath"]==5 and totals.Flurry==3)
local view=WC:TalentPlanText()
assert(view and view.plan.level==33,"ouvre sur le niveau du personnage")
assert(view.current:find("Niv. 33",1,true))
assert(view.notice:find("non verifies",1,true),"pas de promesse de detection")
assert(WC:SetTalentPlanLevel(34) and WC:TalentPlanText().plan.level==34)
assert(not WC:SetTalentPlanLevel(61) and WC.talentPlanSelection==34)
WC.talentState={points={total=2}}
assert(WC:TalentPlanText().notice:find("Points disponibles : 2",1,true))
WC.talentState={points=nil}
assert(not WC:TalentPlanText().notice:find("Points disponibles",1,true))
print("OK: talents Furie 10-60, 51 points, rangs, niveaux et lecture prudente")
