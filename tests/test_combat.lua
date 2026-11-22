local now = 10
local printed = {}
local WC = {}
function WC:Now() return now end
function WC:Trace() end
function WC:Print(m) printed[#printed + 1] = m end
assert(loadfile("Addon/WarriorCompanion/Combat.lua"))("WarriorCompanion",WC)
WC:ResetCombatMetrics()
local c=WC:GetCombatSummary()
assert(c.completed==0 and c.interrupted==0 and c.average==nil)
WC:EndCombat("normal")
assert(WC:GetCombatSummary().completed==0)
WC:StartCombat()
WC:StartCombat()
now=25
WC:EndCombat("normal")
c=WC:GetCombatSummary()
assert(c.completed==1 and c.totalSeconds==15 and c.average==15)
WC:EndCombat("normal")
assert(WC:GetCombatSummary().completed==1,"pas de double sortie")
WC:StartCombat()
now=30
WC:OnCombatObservedEvent("PLAYER_DEAD")
c=WC:GetCombatSummary()
assert(c.completed==1 and c.interrupted==1 and c.deathsInCombat==1)
WC:EndCombat("normal")
assert(WC:GetCombatSummary().interrupted==1,"pas de double mort")
WC:StartCombat()
now=33
WC:OnCombatObservedEvent("PLAYER_ENTERING_WORLD")
assert(WC:GetCombatSummary().interrupted==2)
WC:StartCombat()
now=33+3601
WC:EndCombat("normal")
assert(WC:GetCombatSummary().interrupted==3,"durée aberrante")
WC:StartCombat()
now=now-10
WC:EndCombat("normal")
assert(WC:GetCombatSummary().interrupted==4,"horloge incohérente")
WC:ShowCombatStatus()
assert(#printed==2)
WC:ResetCombatMetrics()
c=WC:GetCombatSummary()
assert(c.completed==0 and c.interrupted==0 and c.deathsInCombat==0)
print("OK: combats doubles, duree, interruption, mort, chargement, horloge, reset")
