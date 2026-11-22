-- Vue integree des quetes, rafraichissement sur clic uniquement.
local level=33
function UnitLevel() return level end
function issecretvalue() return false end
local WC={inCombat=false,questAdvice={rows={
  {id=12,name="Quete terminee",level=31,category="ready"},
  {id=20,name="Quete de groupe",level=32,category="group"}
}}}
local scans=0
function WC:UpdateQuestAdvice() scans=scans+1 end
function WC:DiscoverQuests(limit)
 if limit==7 then return {rows={{id=101,name="Quete non acceptee",level=31}}} end
 if limit==40 then return {rows={{id=101,name="Quete non acceptee",level=31}}} end
 error("unexpected limit")
end
local titleValue,bodyValue="",""
WC.dashboardQuestTitle={SetText=function(_,v) titleValue=v end}
WC.dashboardQuestDetail={SetText=function(_,v) bodyValue=v end}
assert(loadfile("Addon/WarriorCompanion/QuestPlan.lua"))("WarriorCompanion",WC)
assert(scans==0,"no scan on module load")
WC:SelectQuestPlan("journal")
assert(titleValue=="Mon journal" and bodyValue:find("A RENDRE",1,true))
WC:SelectQuestPlan("discover")
assert(titleValue=="Quetes a prendre" and bodyValue:find("Quete non acceptee",1,true))
assert(scans==2)
WC.inCombat=true
WC:SelectQuestPlan("discover")
assert(bodyValue:find("hors combat",1,true),
  "ne pas rechercher des quetes en combat")
WC.inCombat=false
local shownPage=nil
local shown=false
WC.dashboard={IsShown=function() return shown end,Show=function() shown=true end}
function WC:ShowDashboardPage(p) shownPage=p end
WC:OpenQuestPlan("journal")
assert(shown and shownPage=="quests" and titleValue=="Mon journal")
print("OK: vues des quetes et decouverte, aucun scan en combat")
