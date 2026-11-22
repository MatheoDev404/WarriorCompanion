-- Conseils de leveling Furie, sans supposer les API ou la spec reelle.
local token="WARRIOR"
local restricted=987654
function UnitClass(unit) assert(unit=="player"); return "Guerrier",token end
function issecretvalue(v) return v == restricted end
local printed={}
local WC={metrics={deaths=0,xpGained=15},health={percent=25},inCombat=false,
  alerts={},combat={completed=4,interrupted=0,totalSeconds=100}}
function WC:IsReadableNumber(v) return type(v)=="number" and v~=restricted end
function WC:GetCombatSummary() return self.combat end
function WC:Now() return 100 end
function WC:Print(s) printed[#printed+1]=s end
function WC:Trace() end
function WC:Profile() return {showAlerts=true} end
assert(loadfile("Addon/WarriorCompanion/FuryAdvisor.lua"))("WarriorCompanion",WC)
assert(loadfile("Addon/WarriorCompanion/Advisor.lua"))("WarriorCompanion",WC)
assert(WC:IsWarrior())
WC:UpdateAdvice()
assert(#WC.alerts==1 and WC.alerts[1].id=="health-low")
assert(WC.alerts[1].message:find("Furie",1,true))
assert(WC.alerts[1].message:find("bandages",1,true))
assert(WC.alerts[1].priority=="info")
WC:NotifyImportant()
assert(#printed==0, "aucun spam de conseils")
WC.combat.completed=5
WC.combat.average=45
WC:UpdateAdvice()
assert(#WC.alerts==2 and WC.alerts[2].id=="fury-slow-combat")
WC.combat.average=44
WC:UpdateAdvice()
assert(#WC.alerts==1, "pas de conseil combat rapide")
WC.inCombat=true
WC:UpdateAdvice()
assert(#WC.alerts==0, "pas de conseil de recuperation en combat")
WC.inCombat=false
token="MAGE"
WC:UpdateAdvice()
assert(#WC.alerts==1 and WC.alerts[1].id=="health-low" and not WC.alerts[1].message:find("Furie"))
WC.combat.average=60
WC:UpdateAdvice()
assert(#WC.alerts==1, "ne pas conseiller Furie a un autre joueur")
token=restricted
WC:UpdateAdvice()
assert(#WC.alerts==1)
UnitClass=nil
WC:UpdateAdvice()
assert(#WC.alerts==1, "fallback sans API")
WC:ShowFuryStatus()
assert(printed[#printed]:find("indisponible",1,true))
token="WARRIOR"
UnitClass=function() return "Guerrier",token end
WC:ShowFuryStatus()
assert(printed[#printed]:find("Specialisation non verifiee",1,true))
print("OK: conseils Furie lies aux PV et combats, seuil, non-guerrier et API restreinte")
