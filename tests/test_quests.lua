-- Test classement de quetes et intégration Questie, Lua 5.1/5.4.
local level,faction=24,"Horde"
local rows={
 {isHeader=true,title="Les Tarides"},
 {isHeader=false,questID=1001,title="Livrer la lettre",level=22,isComplete=1},
 {isHeader=false,questID=1002,title="Chasser les sangliers",level=22,isComplete=0},
 {isHeader=false,questID=1003,title="Arche dure",level=28,isComplete=0},
 {isHeader=false,questID=1004,title="Boss du donjon",level=23,isComplete=0},
 {isHeader=false,questID=1005,title="Elite",level=22,isComplete=0},
 {isHeader=false,questID=1006,title="Groupe demande",level=22,isComplete=0,suggestedGroup=3},
 {isHeader=false,questID=1007,title="Classe inconnue",level=24,isComplete=0}
}
local tag={
 [1001]={tagID=0},[1002]={tagID=0},[1003]={tagID=0},
 [1004]={tagID=81},[1005]={tagID=0,isElite=true},
 [1006]={tagID=0},[1007]=nil
}
function UnitLevel() return level end
function UnitFactionGroup() return faction end
function issecretvalue(v) return v==987654 end
C_QuestLog={
 GetNumQuestLogEntries=function() return #rows,1 end,
 GetInfo=function(index) return rows[index] end,
 GetQuestTagInfo=function(id) return tag[id] end
}
local printout={}
local WC={inCombat=false,ready=true}
function WC:IsWarrior() return true end
function WC:Print(s) printout[#printout+1]=s end
function WC:Refresh() self.refreshes=(self.refreshes or 0)+1 end
assert(loadfile("Addon/WarriorCompanion/QuestAdvisor.lua"))("WarriorCompanion",WC)
assert(loadfile("Addon/WarriorCompanion/QuestieBridge.lua"))("WarriorCompanion",WC)
assert(WC:UpdateQuestAdvice())
local data=WC.questAdvice
assert(data.level==24 and #data.rows==7)
local byID={}
for _,row in ipairs(data.rows) do byID[row.id]=row end
assert(byID[1001].category=="ready")
assert(byID[1002].category=="solo-candidate")
assert(byID[1003].category=="hard")
assert(byID[1004].category=="group")
assert(byID[1005].category=="group")
assert(byID[1006].category=="group")
assert(byID[1007].category=="unknown")
local alerts={}
WC:AddQuestAdvice(alerts)
assert(#alerts==1 and alerts[1].id=="quest-ready")
assert(alerts[1].priority=="info")
WC:ShowQuestAdvice()
assert(table.concat(printout,"\n"):find("donjon",1,true))
assert(table.concat(printout,"\n"):find("Journal du joueur Horde",1,true))
WC.inCombat=true
WC:AddQuestAdvice(alerts)
assert(#alerts==1)
WC.inCombat=false
faction="Alliance"
assert(not WC:UpdateQuestAdvice())
assert(#WC.questAdvice.rows==0 and WC.questAdvice.reason:find("Horde"))
alerts={}
WC:AddQuestAdvice(alerts)
assert(#alerts==0)
faction="Horde"
WC.IsWarrior=function() return false end
assert(not WC:UpdateQuestAdvice())
WC.IsWarrior=function() return true end
rows[2].questID=987654
assert(not WC:UpdateQuestAdvice(),"protected ids not classified")
rows[2].questID=1001
C_QuestLog.GetInfo=function(index)
 if index==4 then error("secret API") end
 return rows[index]
end
assert(not WC:UpdateQuestAdvice(),"partial scan must fail entirely")
C_QuestLog.GetInfo=function(index) return rows[index] end
assert(WC:UpdateQuestAdvice())
-- Questie API : ready callbacks and quest update events (public surface).
_G.Questie={API={isReady=false}}
local onReady,onQuest
_G.Questie.API.RegisterOnReady=function(cb) onReady=cb end
_G.Questie.API.RegisterForQuestUpdates=function(cb) onQuest=cb end
assert(WC:QuestieStatus()=="loading")
WC:BindQuestie()
WC:BindQuestie()
assert(type(onReady)=="function" and not WC.questieBound)
_G.Questie.API.isReady=true
onReady()
assert(WC.questieBound and WC.questieUpdates)
assert(WC:QuestieStatus()=="ready")
local initial=WC.refreshes or 0
onQuest(1002,nil,0)
assert(WC.refreshes==initial+1 and WC.questAdvice.level==24)
onQuest("invalid",nil,0)
assert(WC.refreshes==initial+1)
WC:ShowQuestieStatus()
assert(printout[#printout]:find("pistes non acceptees",1,true))
_G.Questie=nil
assert(WC:QuestieStatus()=="absent")
WC:ShowQuestieStatus()
assert(printout[#printout]:find("pistes non acceptees",1,true))
print("OK: Horde, quests, level, group, dungeon, elite, unknown, Questie readiness and callbacks")
