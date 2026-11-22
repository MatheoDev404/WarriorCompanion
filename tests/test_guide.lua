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
print("OK: guide source, navigation, bornes et reprise")
