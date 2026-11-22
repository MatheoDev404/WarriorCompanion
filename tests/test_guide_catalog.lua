-- Validation de la couverture 1-60 depuis les vrais fichiers convertis.
local options={}
local WC={}
function WC:Profile() return options end
local current=13
function UnitLevel() return current end
assert(loadfile("Addon/WarriorCompanion/Guide.lua"))("WarriorCompanion",WC)
local paths={
 "Horde_01_14.lua","Horde_12_22.lua","Horde_22_30.lua",
 "Horde_30_40.lua","Horde_40_50.lua","Horde_50_60.lua"
}
for _,name in ipairs(paths) do
 assert(loadfile("Addon/WarriorCompanion/Guides/"..name))("WarriorCompanion",WC)
end
assert(#WC.guideOrder>=60,"sections de guide insuffisantes")
local total=0
for _,id in ipairs(WC.guideOrder) do
 local pack=WC.guideCatalog[id]
 assert(pack and pack.source:find("OpenXP",1,true))
 assert(pack.steps and #pack.steps>0)
 assert(#pack.steps<=2000)
 total=total+#pack.steps
 for _,step in ipairs(pack.steps) do
   assert(type(step.text)=="string" and #step.text>0 and #step.text<=240)
   if step.action then
     assert(step.questID and step.questID>0)
     assert(step.action=="accept" or step.action=="complete" or step.action=="turnin")
   end
 end
end
assert(total>=1500,"conversion trop incomplete")
for level=1,60 do
  current=level
  options.guideProgress=nil
  assert(WC:GuideStart(),"niveau sans guide "..level)
  local guide=WC.activeGuide
  assert(guide.minLevel<=level and guide.primary)
  assert(guide.maxLevel>=level or level==28 or level==52 or level==60,
    "tranche inattendue pour "..level)
end
current=13
options.guideProgress=nil
assert(WC:GuideStart())
assert(WC.activeGuide.title:find("Barrens",1,true),"depart niveau 13 aux Tarides")
assert(WC.guideIndex==1)
WC:GuideMove(1)
local remembered=WC.activeGuide.id
local step=WC.guideIndex
assert(WC:GuideStart() and WC.activeGuide.id==remembered and WC.guideIndex==step)
print("OK: "..#WC.guideOrder.." sections, "..total.." etapes, couverture Horde 1-60 et reprise au niveau 13")
