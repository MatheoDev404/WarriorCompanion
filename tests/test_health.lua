-- Tests des conseils de points de vie, hors combat (Lua 5.1 / 5.4).
local health, maximum, restricted = 250, 1000, 987654
local logs = {}
function UnitHealth(unit) assert(unit=="player"); return health end
function UnitHealthMax(unit) assert(unit=="player"); return maximum end
function issecretvalue(v) return v == restricted end
local WC = { inCombat=false, metrics={deaths=0,xpGained=50}, alerts={} }
function WC:Now() return 300 end
function WC:IsReadableNumber(v)
  return type(v)=="number" and not issecretvalue(v)
end
function WC:Trace() end
function WC:Print(s) logs[#logs+1]=s end
function WC:Profile() return {showAlerts=true} end
assert(loadfile("Addon/WarriorCompanion/Health.lua"))("WarriorCompanion",WC)
assert(loadfile("Addon/WarriorCompanion/Advisor.lua"))("WarriorCompanion",WC)

WC:InitHealthObserver()
assert(WC.health.percent==25)
assert(WC:IsReadableUnit("player") and not WC:IsReadableUnit("target"))
WC:UpdateAdvice()
assert(#WC.alerts==1 and WC.alerts[1].id=="health-low")
assert(WC.alerts[1].priority=="info", "aucune notification automatique")
assert(WC:AdviceLines():find("25%%"),"pourcentage visible")
WC:NotifyImportant()
assert(#logs==0,"conseil de sante dans le tableau seulement")
WC:ShowHealthStatus()
assert(logs[#logs]:find("250 / 1000",1,true))

health=349
WC:ReadHealth()
assert(WC.health.percent==35,"arrondi a 35")
WC:UpdateAdvice()
assert(#WC.alerts==0,"seuil strict")
health=350
WC:ReadHealth()
WC:UpdateAdvice()
assert(#WC.alerts==0)
health=0
WC:ReadHealth()
WC:UpdateAdvice()
assert(#WC.alerts==0,"un mort ne doit pas recevoir ce conseil")
health=100
WC.inCombat=true
WC:ReadHealth()
WC:UpdateAdvice()
assert(#WC.alerts==0,"pas de conseil recuperation pendant le combat")
WC.inCombat=false
WC:UpdateAdvice()
assert(#WC.alerts==1)

health=restricted
WC:ReadHealth()
assert(WC.health.percent==nil)
WC:UpdateAdvice()
assert(#WC.alerts==0,"donnee protegee")
maximum=0
health=150
WC:ReadHealth()
assert(WC.health.percent==nil,"PV max invalides")
maximum=100
WC:ReadHealth()
assert(WC.health.percent==nil,"PV impossibles")
health=0/0
WC:ReadHealth()
assert(WC.health.percent==nil,"NaN")
health=200
maximum=1000
UnitHealth = function() error("unavailable") end
WC:ReadHealth()
assert(WC.health.percent==nil,"erreur API")
UnitHealth=nil
WC:ReadHealth()
assert(WC.health.percent==nil,"API absente")
WC:ShowHealthStatus()
assert(logs[#logs]:find("indisponibles",1,true))
print("OK: PV, seuil, combat, mort, API absente, secret, erreur, NaN")
