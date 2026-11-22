-- Tests isolés de fenêtre glissante (Lua 5.1 / 5.4).
local now = 100
local rows = {}
local WC = { metrics = { started = now, xpAvailable = true, xpGained = 0 } }
function WC:Now() return now end
function WC:Print(s) rows[#rows + 1] = s end
function WC:XPPerHour() return 800 end
assert(loadfile("Addon/WarriorCompanion/Performance.lua"))("WarriorCompanion", WC)
WC:ResetPerformance()
assert(WC:RecentXPPerHour() == nil, "minute insuffisante")
WC:RecordPerformanceGain(100)
now = 160
assert(WC:RecentXPPerHour() == 6000, "premiere minute")
now = 400
WC:RecordPerformanceGain(50)
assert(WC:RecentXPPerHour() == 1800, "XP/h depuis depart")
now = 760
assert(WC:RecentXPPerHour() == 300, "fenetre 10 minutes: seul 50 reste")
now = 1001
assert(WC:RecentXPPerHour() == 0, "absence de XP recente est un taux de 0")
WC:ShowPerformance()
assert(#rows == 2)
WC:RecordPerformanceGain(0)
WC:RecordPerformanceGain(-1)
assert(#WC.performance.samples == 0, "ignorer valeurs non positives")
WC.metrics.xpAvailable = false
assert(WC:RecentXPPerHour() == nil, "API indisponible")
WC.metrics.xpAvailable = true
WC:ResetPerformance()
now = 1100
for i=1,601 do
  WC:RecordPerformanceGain(1)
end
assert(#WC.performance.samples == 600, "memoire bornee")
assert(WC:RecentXPPerHour() == nil, "ne pas sous-estimer une fenetre incomplete")
now = 1701
assert(WC:RecentXPPerHour() == 0, "fenetre complete retrouvee")
WC.metrics.started = now
WC:ResetPerformance()
assert(WC:RecentXPPerHour() == nil, "reset de session")
print("OK: XP glissante, 10 minutes, duree, donnees absentes, limite, reset")
