local B={}
local playerLevel=34
function UnitLevel(who) assert(who=="player") return playerLevel end
assert(loadfile("Addon/WarriorCompanionBuild/Data.lua"))("WarriorCompanionBuild",B)
assert(loadfile("Addon/WarriorCompanionBuild/Planner.lua"))("WarriorCompanionBuild",B)
_G.WCBuildDB=nil
B:InitState()
assert(B.realLevel==34 and B.viewLevel==34 and B.mode=="follow")
assert(B:ValidateContent(),"talents et lien equipement-quêtes")
local plan=B:PlanAt(34)
assert(plan.ranks["Cruelty"]==5 and plan.ranks["Enrage"]==5
  and plan.ranks["Reckless Swings"]==1)
assert(plan.nextKey=="Flurry")
assert(B:PlanAt(9).nextKey=="Cruelty")
assert(B:PlanAt(60).nextKey==nil)
assert(B:SetPreview(40) and B.viewLevel==40)
playerLevel=35
B:UpdateLevel()
assert(B.realLevel==35 and B.viewLevel==40,"ne pas ecraser l'apercu manuel")
B:ReturnToReal()
assert(B.mode=="follow" and B.viewLevel==35)
local questSource,craftSource=0,0
for _,g in ipairs(B.gear) do
  if g.source=="quest" then questSource=questSource+1
  elseif g.source=="craft" then craftSource=craftSource+1
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
assert(questSource==2 and craftSource==2)
local t
for _,g in ipairs(B.gear) do if g.id==17705 then t=g end end
assert(not B:ItemEligible(t,34),"Thrash Blade ne doit pas etre conseillee au 34")
assert(B:ItemEligible(t,45))
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
assert(B:ChangeScale(1)==1.15 and B:ChangeScale(-9)==0.65)
print("OK: build planner 1-60, plan 51 points, level preview, craft/quest sources, transitions, risk and gear links")
