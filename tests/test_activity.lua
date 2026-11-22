-- Tests autonomes de la chronologie de session (Lua 5.1 et 5.4).
local now, printed = 100, {}
local WC = { ready = true, metrics = { xpGained = 0, questCount = 4 } }
function WC:Now() return now end
function WC:IsReadableNumber(x) return type(x) == "number" and x ~= 999999 end
function WC:Print(s) printed[#printed + 1] = s end
assert(loadfile("Addon/WarriorCompanion/Activity.lua"))("WarriorCompanion", WC)
WC:ClearActivity()
assert(#WC.activity == 0)
WC:ShowActivity()
assert(printed[#printed]:find("vide", 1, true))
WC:OnActivityEvent("PLAYER_XP_UPDATE", 0, 4)
assert(#WC.activity == 0, "Ne pas inventer un gain")
WC.metrics.xpGained = 150
WC:OnActivityEvent("PLAYER_XP_UPDATE", 0, 4)
assert(#WC.activity == 1 and WC.activity[1].description == "+150 XP")
WC:OnActivityEvent("PLAYER_XP_UPDATE", 150, 4)
assert(#WC.activity == 1, "Pas de doublon XP")
WC:OnActivityEvent("PLAYER_DEAD", 150, 4)
assert(WC.activity[#WC.activity].kind == "mort")
WC:OnActivityEvent("PLAYER_LEVEL_UP", 150, 4, 14)
assert(WC.activity[#WC.activity].description == "Niveau 14")
WC:OnActivityEvent("PLAYER_EQUIPMENT_CHANGED", 150, 4, 16)
local n = #WC.activity
WC:OnActivityEvent("PLAYER_EQUIPMENT_CHANGED", 150, 4, 16)
assert(#WC.activity == n, "Anti-spam")
WC:OnActivityEvent("PLAYER_EQUIPMENT_CHANGED", 150, 4, 17)
assert(#WC.activity == n + 1 and WC.activity[#WC.activity].description:find("(emplacement 17)", 1, true),
  "Deux emplacements distincts doivent apparaître même dans la même seconde")
n = #WC.activity
now = now + 7
WC:OnActivityEvent("PLAYER_EQUIPMENT_CHANGED", 150, 4, 16)
assert(#WC.activity == n, "Doublon intercalé dans les huit secondes")
now = now + 1
WC:OnActivityEvent("PLAYER_EQUIPMENT_CHANGED", 150, 4, 16)
assert(#WC.activity == n + 1)
WC:OnActivityEvent("QUEST_LOG_UPDATE", 150, 4)
assert(#WC.activity == n + 1, "Quete sans variation")
WC.metrics.questCount = 5
WC:OnActivityEvent("QUEST_LOG_UPDATE", 150, 4)
assert(WC.activity[#WC.activity].description == "Nombre de quetes : 5")
n = #WC.activity
WC.metrics.questCount = nil
WC:OnActivityEvent("QUEST_LOG_UPDATE", 150, 5)
assert(#WC.activity == n, "API indisponible ne cree pas d'activite")
now = now + 9
WC:OnActivityEvent("PLAYER_EQUIPMENT_CHANGED", 150, 5, 999999)
assert(WC.activity[#WC.activity].description == "Equipement modifie", "Valeur restreinte sans slot")
for i = 1, 100 do
  now = now + 1
  WC:AddActivity("test", "Evenement " .. tostring(i))
end
assert(#WC.activity == 60, "Limite du tampon")
assert(WC.activity[1].description == "Evenement 41")
local before = #printed
WC:ShowActivity()
assert(#printed == before + 13, "En-tete + 12 dernieres activites")
assert(printed[before + 2]:match("Evenement 89$") and printed[#printed]:match("Evenement 100$"))
WC:OnActivityEvent("SKILL_LINES_CHANGED", 150, nil)
WC:OnActivityEvent("SKILL_LINES_CHANGED", 150, nil)
assert(WC.activity[59].kind == "test" and WC.activity[60].kind == "competences")
WC:ClearActivity()
assert(#WC.activity == 0)
WC:OnActivityEvent("SKILL_LINES_CHANGED", 150, nil)
assert(#WC.activity == 1, "Reset du délai anti-répétition avec l'historique")
WC:ClearActivity()
WC.ready = false
WC:OnActivityEvent("PLAYER_DEAD", 0, 0)
assert(#WC.activity == 0, "Aucun enregistrement avant initialisation")
print("OK: chronologie, XP, mort, niveau, equipement, anti-spam, quetes, limites, reset")
