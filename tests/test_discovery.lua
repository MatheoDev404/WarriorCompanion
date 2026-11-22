-- QuestieDB v4 discovery: candidates only, never assert quest availability/solo.
local raceId,level,faction=5,24,"Horde"
local inCombat=false
function UnitRace() return "Mort-vivant","Scourge",raceId end
function UnitLevel() return level end
function UnitFactionGroup() return faction end
function issecretvalue(v) return v==987654 end
local entries={
 [100]={name="Quete conseillee",requiredLevel=20,questLevel=22,
    requiredRaces=16,requiredClasses=1,startedBy={{88},{},{}},questFlags=0},
 [101]={name="Alliances seulement",requiredLevel=20,questLevel=22,
    requiredRaces=1,requiredClasses=1,startedBy={{11}},questFlags=0},
 [102]={name="Classe incompatible",requiredLevel=20,questLevel=22,
    requiredRaces=16,requiredClasses=2,startedBy={{11}},questFlags=0},
 [103]={name="Prerequis inconnu",requiredLevel=20,questLevel=22,
    requiredRaces=16,requiredClasses=1,startedBy={{11}},questFlags=0,
    preQuestSingle={4}},
 [104]={name="Quete active",requiredLevel=20,questLevel=22,
    requiredRaces=16,requiredClasses=1,startedBy={{11}},questFlags=0},
 [105]={name="Quete terminee",requiredLevel=20,questLevel=22,
    requiredRaces=16,requiredClasses=1,startedBy={{11}},questFlags=0},
 [106]={name="Elite incertaine",requiredLevel=20,questLevel=22,
    requiredRaces=16,requiredClasses=1,startedBy={{11}},questFlags=8},
 [107]={name="Pas de donnees starter",requiredLevel=20,questLevel=22,
    requiredRaces=16,requiredClasses=1,startedBy={},questFlags=0},
 [108]={name="Niveau trop eleve",requiredLevel=25,questLevel=25,
    requiredRaces=16,requiredClasses=1,startedBy={{11}},questFlags=0},
 [109]={name="Candidat secondaire",requiredLevel=22,questLevel=20,
    requiredRaces=0,requiredClasses=0,startedBy={{12}},questFlags=0},
 [110]={name="Quete a recompense conditionnelle",requiredLevel=23,questLevel=22,
    requiredRaces=16,requiredClasses=1,startedBy={{12}},questFlags=0,
    requiredSkill={164,100}},
}
local fields={requiredLevel=true,questLevel=true,requiredRaces=true,requiredClasses=true,
  startedBy=true,name=true}
local complete={[105]=true}
C_QuestLog={IsQuestFlaggedCompleted=function(id) return complete[id]==true end}
local ids={}
for id in pairs(entries) do ids[#ids+1]=id end
table.sort(ids)
local contract=4
local qdb={}
function qdb.GetAllIds() return ids end
function qdb.Get(id,key)
  local v=entries[id] and entries[id][key]
  if v==nil and not fields[key] and key~="preQuestSingle" and key~="requiredSkill" then
    if key=="nextQuestInChain" or key=="questFlags" or key=="specialFlags"
      or key=="parentQuest" or key=="requiredSpell"
      or key=="requiredSpecialization" or key=="requiredMaxLevel"
      or key=="availableUntilCompleted" or key=="availableStartingWith"
      or key=="disabledByQuest" then return 0 end
  end
  return v
end
_G.LibQuestieDB={
 RequireContract=function(n) return n==contract end,
 Quest=qdb,Enum={raceMaskById={[5]=16},classKeys={WARRIOR=1},
   factionRaceMasks={Horde=16}}
}
local messages={}
local WC={inCombat=false,questAdvice={rows={{id=104}}}}
function WC:IsWarrior() return true end
function WC:Print(s) messages[#messages+1]=s end
function WC:UpdateQuestAdvice()
  -- Stand-in: the full refresh reads only the game's accepted-quest journal.
  self.questAdvice={rows={{id=104}}}
end
assert(loadfile("Addon/WarriorCompanion/QuestDiscovery.lua"))("WarriorCompanion",WC)
local result,reason=WC:DiscoverQuests()
assert(result and not reason and result.matched==2 and #result.rows==2)
assert(result.rows[1].id==100 and result.rows[2].id==109,
  "must rank closer to player level minus two")
WC:ShowQuestDiscovery()
assert(messages[#messages]:find("pas quetes garanties solo",1,true))
assert(table.concat(messages,"\n"):find("Questie",1,true))
assert(not table.concat(messages,"\n"):find("Alliances seulement",1,true))
WC.inCombat=true
local n=#messages
WC:ShowQuestDiscovery()
assert(#messages==n+1 and messages[#messages]:find("hors combat",1,true))
WC.inCombat=false
faction="Alliance"
assert(WC:DiscoverQuests()==nil,"reject Alliance")
faction="Horde"
raceId=987654
assert(WC:DiscoverQuests()==nil,"protected race rejected")
raceId=5
contract=3
assert(WC:DiscoverQuests()==nil,"contract 4 mandatory")
contract=4
C_QuestLog.IsQuestFlaggedCompleted=nil
assert(WC:DiscoverQuests()==nil,"cannot recommend completed quests without status")
C_QuestLog.IsQuestFlaggedCompleted=function(id) return complete[id]==true end
WC.questAdvice={reason="API indisponible"}
assert(WC:DiscoverQuests()==nil,"journal accepted ids must be verified")
WC.questAdvice={rows={{id=104}}}
entries[100].requiredRaces=987654
result=WC:DiscoverQuests()
assert(result.matched==1 and result.rows[1].id==109,"secret fields excluded")
entries[100].requiredRaces=16
entries[100].parentQuest=200
result=WC:DiscoverQuests()
assert(result.matched==1,"parent quest excluded")
entries[100].parentQuest=nil
qdb.GetAllIds=function() error("broken provider") end
assert(WC:DiscoverQuests()==nil,"db read error handled")
print("OK: QuestieDB contract, Horde, race, class, prereqs, source, journal, completion, ranking, fail-closed")
