-- Regroupement de PNJ de depart QuestieDB : zones, coordonnees et faction.
local quest={
 [100]={startedBy={{10}}},
 [101]={startedBy={{11}}},
 [102]={startedBy={{12}}},
 [103]={startedBy={{13}}},
 [104]={startedBy={{14}}},
 [105]={startedBy={{15}}},
 [106]={startedBy={{16}}},
 [107]={startedBy={{17}}},
}
local npcs={
 [10]={friendlyToFaction="H",spawns={[17]={{20,25}}}},
 [11]={friendlyToFaction="AH",spawns={[17]={{25,27}}}},
 [12]={friendlyToFaction="H",spawns={[17]={{88,88}}}},
 [13]={friendlyToFaction="A",spawns={[17]={{20,26}}}},
 [14]={friendlyToFaction="H",spawns={[42]={{20,25}}}},
 [15]={friendlyToFaction="H",spawns={[17]={{130,25}}}},
 [16]={friendlyToFaction="H",spawns={[17]={{33,30}}}},
 [17]={friendlyToFaction="H",spawns={[17]={{16,18}}}},
}
_G.LibQuestieDB={
 Quest={Get=function(id,key) return quest[id] and quest[id][key] end},
 Npc={Get=function(id,key) return npcs[id] and npcs[id][key] end},
}
local messages={}
local data={rows={}}
for id=100,107 do
 data.rows[#data.rows+1]={id=id,name="Quete "..id,level=22,distance=math.abs(104-id)}
end
local WC={inCombat=false}
function WC:Print(text) messages[#messages+1]=text end
function WC:UpdateQuestAdvice() self.scanned=(self.scanned or 0)+1 end
function WC:DiscoverQuests(max)
 assert(max==40)
 return data
end
assert(loadfile("Addon/WarriorCompanion/QuestClusters.lua"))("WarriorCompanion",WC)
local groups=WC:BuildQuestClusters(data)
assert(groups and #groups==3,"nearby same-zone starters combine; distant and other zone split")
assert(groups[1].zone==17 and #groups[1].rows==4)
local ids={}
for _,row in ipairs(groups[1].rows) do ids[row.id]=true end
assert(ids[100] and ids[101] and ids[106] and ids[107])
assert(not ids[103],"Alliance starter excluded")
local otherZone=false
for _,g in ipairs(groups) do if g.zone==42 then otherZone=true end end
assert(otherZone,"zone IDs never combined")
WC:ShowQuestClusters()
assert(messages[1]:find("Regroupements",1,true))
assert(messages[#messages]:find("aucun trajet",1,true))
assert(WC.scanned==1)
WC.inCombat=true
local before=#messages
WC:ShowQuestClusters()
assert(#messages==before+1 and WC.scanned==1,"no scans in combat")
WC.inCombat=false
npcs[10].friendlyToFaction="A"
groups=WC:BuildQuestClusters(data)
local count=0
for _,g in ipairs(groups) do
 for _,q in ipairs(g.rows) do if q.id==100 then count=count+1 end end
end
assert(count==0,"must reject alliance-only starter")
npcs[10].friendlyToFaction="H"
npcs[10].spawns={[17]={{987654,24}}}
function issecretvalue(v) return v==987654 end
groups=WC:BuildQuestClusters(data)
for _,g in ipairs(groups) do
 for _,q in ipairs(g.rows) do assert(q.id~=100) end
end
npcs[10].spawns={[17]={{20,25}}}
_G.LibQuestieDB.Npc.Get=function() error("provider unavailable") end
groups=WC:BuildQuestClusters(data)
assert(#groups==0 and WC:BuildQuestClusters(nil)==nil)
_G.LibQuestieDB=nil
assert(WC:BuildQuestClusters(data)==nil)
print("OK: QuestieDB starter clusters, Horde, zone, coord validation, combat and no guessed travel")
