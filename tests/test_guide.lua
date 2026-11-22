local WC = {}
local settings = {}
function WC:Profile() return settings end
assert(loadfile("Addon/WarriorCompanion/Guide.lua"))("WarriorCompanion", WC)
assert(WC:GetGuideView() == nil)
assert(not WC:GuideMove(1))
assert(not WC:GuideLoad({id="missing",title="Invalid",source="source",steps={}}))
local sample = {
  id="test-guide", title="Test Horde", source="Source test",
  steps={{text="Accepter la quete"}, {text="Terminer l'objectif"}, {text="Rendre la quete"}}
}
assert(WC:GuideLoad(sample))
local view = WC:GetGuideView()
assert(view.title=="Test Horde")
assert(view.status:find("1/3",1,true))
assert(view.steps:find("Accepter la quete",1,true))
assert(WC:GuideMove(1) and WC.guideIndex==2)
assert(settings.guideProgress.index==2)
assert(WC:GuideLoad(sample) and WC.guideIndex==2)
assert(WC:GuideMove(-1) and WC.guideIndex==1)
assert(WC:GuideMove(-1) and WC.guideIndex==1)
assert(WC:GuideMove(1) and WC:GuideMove(1))
assert(WC:GuideMove(1) and WC.guideIndex==3)
assert(not WC:GuideMove(2))
assert(not WC:GuideLoad({id="bad",title="Bad",source="source",steps={{text=""}}}))
assert(WC.activeGuide==sample, "un mauvais pack ne remplace pas le guide")
local questGuide = {
  id="quest-test", title="Test journal", source="Source test",
  steps={
    {text="Accepter", action="accept", questID=100},
    {text="Terminer", action="complete", questID=100},
    {text="Rendre", action="turnin", questID=100},
    {text="Etape manuelle"},
  }
}
assert(WC:GuideLoad(questGuide))
assert(not WC:GuideAdvanceFromJournal(), "journal absent")
WC.questAdvice={rows={{id=100,complete=false}}}
assert(WC:GuideAdvanceFromJournal() and WC.guideIndex==2)
assert(not WC:GuideAdvanceFromJournal(), "pas encore terminee")
WC.questAdvice.rows[1].complete=true
assert(WC:GuideAdvanceFromJournal() and WC.guideIndex==3)
C_QuestLog={IsQuestFlaggedCompleted=function() return false end}
assert(not WC:GuideAdvanceFromJournal(), "rendu non confirme")
C_QuestLog.IsQuestFlaggedCompleted=function() return true end
assert(WC:GuideAdvanceFromJournal() and WC.guideIndex==4)
assert(not WC:GuideAdvanceFromJournal(), "etape manuelle")
assert(settings.guideProgress.id=="quest-test" and settings.guideProgress.index==4)
print("OK: guide source, navigation, reprise, validation du journal")
