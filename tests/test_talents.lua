-- Observation prudente des points de talent WoW Forever (Lua 5.1/5.4).
local has, class, spec=false,0,0
local messages,events={},{}
local secret = 987654
C_ClassTalents = {HasUnspentTalentPoints=function() return has,class,spec end}
issecretvalue=function(v) return v==secret end
local WC={}
function WC:AddActivity(kind, text) events[#events+1]={kind=kind,text=text} end
function WC:Print(text) messages[#messages+1]=text end
assert(loadfile("Addon/WarriorCompanion/TalentObserver.lua"))("WarriorCompanion",WC)
WC:InitTalentObserver()
assert(WC.talentState.points.total==0 and WC.talentState.changes==0)
assert(#events==0,"first reading must not become a new allocation")
has=true; class=2; spec=1
assert(WC:ObserveTalents(true))
assert(WC.talentState.points.total==3)
assert(WC.talentState.changes==1 and #events==1)
assert(events[1].text:find("0 -> 3",1,true))
WC:ObserveTalents(true)
assert(#events==1,"duplicate events ignored")
class=1;spec=1
WC:ObserveTalents(true)
assert(#events==2 and events[2].text:find("3 -> 2",1,true))
WC:ShowTalentStatus()
assert(messages[#messages]:find("Aucun talent precis",1,true))
assert(messages[#messages-1]:find("Classe : 1",1,true))
has=false;class=0;spec=0
WC:ObserveTalents(true)
assert(#events==3 and WC.talentState.points.total==0)
has=true;class=0;spec=0
assert(not WC:ObserveTalents(true))
assert(WC.talentState.points==nil)
assert(#events==3,"invalid state never records changes")
has=true;class=3;spec=0
WC:ObserveTalents(true)
assert(#events==3,"recovered read becomes a baseline")
has=true;class=secret;spec=0
assert(not WC:ObserveTalents(true),"protected points rejected")
C_ClassTalents.HasUnspentTalentPoints=function() error("missing API") end
assert(not WC:ObserveTalents(true),"pcall failure guarded")
C_ClassTalents=nil
assert(not WC:ObserveTalents(true),"missing namespace guarded")
WC:ShowTalentStatus()
assert(messages[#messages]:find("indisponibles",1,true))
WC:InitTalentObserver()
assert(WC.talentState.points==nil and WC.talentState.changes==0)
print("OK: reliable points, history, duplicate events, secrets, incoherent values, absent API")
