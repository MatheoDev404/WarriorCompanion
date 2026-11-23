-- Simulations de la nouvelle interface WoW (sans client graphique).
local function frame()
  local f={shown=true,handlers={}}
  function f:SetPoint(...) self.point={...} end
  function f:ClearAllPoints() self.point=nil end
  function f:SetSize(w,h) self.width=w self.height=h end
  function f:SetScale(v) self.scale=v end
  function f:SetFrameStrata(v) self.strata=v end
  function f:SetMovable(v) end
  function f:EnableMouse(v) end
  function f:EnableMouseWheel(v) self.wheelEnabled=v end
  function f:RegisterForDrag(v) end
  function f:SetClampedToScreen(v) end
  function f:StartMoving() end
  function f:StopMovingOrSizing() end
  function f:GetPoint() return "CENTER",UIParent,"CENTER",0,0 end
  function f:SetScript(k,fn) self.handlers[k]=fn end
  function f:Show() self.shown=true end
  function f:Hide() self.shown=false end
  function f:IsShown() return self.shown end
  function f:CreateTexture()
    local t={}
    function t:SetTexture(v) self.texture=v end
    function t:ClearAllPoints() self.point=nil end
    function t:SetPoint(...) self.point={...} end
    function t:SetSize(w,h) self.width=w self.height=h end
    function t:SetVertexColor(...) self.color={...} end
    function t:Hide() self.hidden=true end
    return t
  end
  function f:CreateFontString()
    local t={}
    function t:SetPoint(...) end
    function t:SetSize(w,h) end
    function t:SetJustifyH() end
    function t:SetJustifyV() end
    function t:SetText(v) self.text=v end
    function t:SetTextColor(...) self.color={...} end
    function t:SetFont(path,size) self.fontPath=path self.fontSize=size end
    function t:SetWordWrap(value) self.wordWrap=value end
    return t
  end
  return f
end
UIParent=frame()
function CreateFrame(kind)
  local result=frame()
  if kind=="Slider" then
    function result:SetOrientation(value) self.orientation=value end
    function result:SetMinMaxValues(low,high) self.low=low self.high=high end
    function result:SetValueStep(step) self.step=step end
    function result:SetThumbTexture(texture)
      self.thumb={path=texture}
      function self.thumb:SetVertexColor(...) self.color={...} end
    end
    function result:GetThumbTexture() return self.thumb end
    function result:SetValue(value)
      self.value=value
      if self.handlers.OnValueChanged then
        self.handlers.OnValueChanged(self,value)
      end
    end
  end
  return result
end
function UnitLevel() return 34 end
local lastTooltipSpell, lastTooltipItem
Enum={SpellBookSpellBank={Player=0}}
C_Spell={GetSpellInfo=function(id)
  local names={[6673]="Cri de guerre",[100]="Charge",
    [23881]="Sanguinaire",[1680]="Tourbillon"}
  return {name=names[id],spellID=id}
end}
-- Dans le vrai grimoire, le rang 2 de Cri de guerre est connu,
-- meme si le rang 1 (6673) n'est pas signale par IsPlayerSpell.
function IsPlayerSpell() return false end
C_SpellBook={
  GetNumSpellBookSkillLines=function()return 1 end,
  GetSpellBookSkillLineInfo=function()return {
    itemIndexOffset=0,numSpellBookItems=3
  }end,
  GetSpellBookItemInfo=function(slot)
    return {spellID=slot==1 and 5242 or (slot==2 and 100 or 1160),itemType="SPELL"}
  end,
  GetSpellBookItemName=function(slot)
    return slot==1 and "Cri de guerre" or
      (slot==2 and "Charge" or "Cri démoralisant")
  end,
}
C_UnitAuras={GetAuraDataByIndex=function(_,index)
  if index==1 then return {name="Cri de guerre",spellId=5242} end
  return nil
end}
C_Item={GetItemIconByID=function(id) return 100000+id end}
GameTooltip={
  SetOwner=function() end,
  SetSpellByID=function(_,id) lastTooltipSpell=id end,
  SetItemByID=function(_,id) lastTooltipItem=id end,
  AddLine=function()end, Show=function()end, Hide=function()end,
}
local B={}
assert(loadfile("Addon/WarriorCompanionBuild/Data.lua"))("WarriorCompanionBuild",B)
assert(loadfile("Addon/WarriorCompanionBuild/TalentTrees.lua"))("WarriorCompanionBuild",B)
assert(loadfile("Addon/WarriorCompanionBuild/Spellbook.lua"))("WarriorCompanionBuild",B)
assert(loadfile("Addon/WarriorCompanionBuild/Planner.lua"))("WarriorCompanionBuild",B)
assert(loadfile("Addon/WarriorCompanionBuild/CombatData.lua"))("WarriorCompanionBuild",B)
assert(loadfile("Addon/WarriorCompanionBuild/UI.lua"))("WarriorCompanionBuild",B)
assert(loadfile("Addon/WarriorCompanionBuild/Rotation.lua"))("WarriorCompanionBuild",B)
B:InitState()
assert(B:ValidateContent())
assert(B:BuildSpellbookCache())
assert(B:IsKnownSpell({name="Cri de guerre",spellId=6673})==true,
  "le rang 2 appris est reconnu malgre le rang 1 inconnu")
assert(B:IsKnownSpell({name="Cri demoralisant",spellId=1160})==true,
  "les noms francais avec/sans accents doivent correspondre")
local getInfo=C_SpellBook.GetSpellBookItemInfo
C_SpellBook.GetSpellBookItemInfo=nil
assert(B:BuildSpellbookCache(),"l'API grimoire sans ItemInfo reste lisible")
assert(B:IsKnownSpell({name="Cri de guerre",spellId=6673})==true,
  "une lecture par noms suffit si GetSpellBookItemInfo manque")
C_SpellBook.GetSpellBookItemInfo=getInfo
B:BuildSpellbookCache()
assert(B:PlayerBuffStatus("Cri de guerre",6673)==true)
B.realLevel=34
assert(B:SpellStatus({name="Cri de guerre",spellId=6673,level=1}):find("rang 3",1,true),
  "un rang plus eleve est signale sans declarer le sort non appris")
assert(B:SpellStatus({name="Charge",spellId=100,level=4})=="",
  "un sort appris sans amelioration cache son statut")
B:CreateUI()
assert(B.frame.width==760 and B.frame.scale==0.82)
assert(B.page=="talents" and B.pages.talents:IsShown())
assert(B.pages.talents.trees.Armes and B.pages.talents.trees.Furie
  and B.pages.talents.trees.Protection,
  "les trois arbres doivent etre accessibles")
assert(B.pages.talents.trees.Armes.frame:IsShown() and
  B.pages.talents.trees.Furie.frame:IsShown() and
  B.pages.talents.trees.Protection.frame:IsShown(),
  "les trois arbres s'affichent simultanement")
assert(B.pages.talents.trees.Armes.nodes["Deep Wounds"] and
  B.pages.talents.trees.Protection.nodes["Shield Slam"],
  "tous les talents ont une icone et une infobulle")
assert(B.pages.talents.desc==nil and B.pages.talents.treeTabs==nil,
  "suppression du descriptif et des boutons de sous-arbres")
assert(B.tabs.rotation and B.pages.rotation,"4eme onglet Rotation")
assert(B.pages.talents.levelPoint.text:find("Coups",1,true),
  "point de talent gagne au niveau 34 indique")
assert(B.pages.talents.nodes["Reckless Swings"].edges[1].color[4]==1,
  "seul le talent gagne au niveau consulte est souligne")
assert(B.pages.talents.nodes["Cruelty"].edges[1].color[4]==0,
  "les points plus anciens ne sont pas tous soulignes")
assert(B.pages.talents.nodes["Bloodthirst"])
assert(#B.pages.talents.connections==2,"pre-requis visuels de l arbre Furie")
B.pages.talents.nodes["Bloodthirst"].handlers.OnEnter()
assert(lastTooltipSpell==23881,"tooltip de talent depuis le spellID")
B:ShowPage("equipement")
assert(B.pages.equipement:IsShown() and not B.pages.talents:IsShown())
B.pages.equipement.items[6802].handlers.OnEnter()
assert(lastTooltipItem==6802,"infobulle vraie de l'objet dans le client")
B.pages.equipement.items[6802].handlers.OnLeave()
B.pages.equipement.items[6802].handlers.OnClick()
assert(B.pages.equipement.previewName.text:find("Epee",1,true),
  "nom de l'objet selectionne dans la fiche")
assert(B.pages.equipement.previewIcon.texture==106802,
  "icone d'objet recuperee par son ID")
assert(B.pages.equipement.previewDescription.text:find("donjon",1,true)
  or B.pages.equipement.previewDescription.text:find("groupe",1,true)
  or B.pages.equipement.previewDescription.text:find("GROUPE",1,true),
  "conditions de groupe explicites")
assert(B.selectedItem==6802)
B.pages.equipement.gotoButton.handlers.OnClick()
assert(B.page=="parcours" and B.pages.parcours:IsShown())
assert(B:OrderedRoute()[B.routeIndex].step.id=="quest-scarlet")
assert(B.pages.parcours.zone.text:find("Monastere",1,true))
assert(B.pages.parcours.activeKind.text=="EQUIPEMENT",
  "les etapes d'equipement sont reconnaissables visuellement")
assert(B.pages.parcours.rows[1].kind.text~=nil,
  "les etapes suivantes ont un marqueur par type")
B:SetPreview(39)
B:ShowPage("equipement")
local gearPanel=B.pages.equipement
assert(gearPanel.moreButton==nil and gearPanel.wheelEnabled and
  gearPanel.scrollBar and gearPanel.scrollBar.orientation=="VERTICAL",
  "la molette et le curseur vertical remplacent la pagination")
assert(gearPanel.gearOffset==0)
for _,item in ipairs(gearPanel.displayed) do
  assert(item.minLevel<=39,"les premieres cibles correspondent au niveau")
end
gearPanel.handlers.OnMouseWheel(gearPanel,-1)
assert(gearPanel.gearOffset==1,"defilement vertical d'une ligne")
gearPanel.handlers.OnMouseWheel(gearPanel,-1)
gearPanel.handlers.OnMouseWheel(gearPanel,-1)
local sawFuture=false
for _,item in ipairs(gearPanel.displayed) do
  if item.minLevel>39 then sawFuture=true end
end
assert(sawFuture,"les paliers futurs apparaissent a la fin de la liste")
assert(gearPanel.scrollBar.value==gearPanel.gearOffset)
gearPanel.scrollBar:SetValue(1)
assert(gearPanel.gearOffset==1,"le curseur glissable deplace la liste")
gearPanel.handlers.OnMouseWheel(gearPanel,-1)
assert(gearPanel.gearOffset==2,"la molette repart du curseur")
gearPanel.handlers.OnMouseWheel(gearPanel,1)
assert(gearPanel.gearOffset==1,"defilement vers le haut")
B:SetPreview(34)
B:ShowPage("talents")
assert(B.pages.talents.nextLabel.text:find("Rafale",1,true))
B:SetPreview(40)
B:Refresh()
assert(B.pages.talents.nodes["Bloodthirst"].edges[1].color[4]==1,
  "le talent de niveau 40 est en surbrillance")
assert(B.pages.talents.nodes["Reckless Swings"].edges[1].color[4]==0)
B:ShowPage("rotation")
assert(B.pages.rotation:IsShown()
  and B.pages.rotation.rows.cycle[1].name.text=="Sanguinaire")
assert(B.pages.rotation.rows.maintain[1].note.text:find("Buff actif",1,true),
  "Cri de guerre deja actif est detecte avec le rang du grimoire")
assert(not B.pages.rotation.rows.maintain[1].note.text:find("Non appris",1,true))
B.pages.rotation.rows.cycle[1].handlers.OnEnter()
assert(lastTooltipSpell==23881,"infobulle du sort de la rotation")
B.pages.rotation.rows.cycle[1].handlers.OnLeave()
assert(B.pages.rotation.rows.cycle[4]:IsShown() and
  B.pages.rotation.rows.cycle[3].name.text=="Fracasser armure",
  "la rotation monocible contient Fracasser armure")
assert(B.pages.rotation.rows.reactive[2].entry.spellId==402927,
  "identifiant Forever de l'Ivresse de la victoire")
assert(B.pages.rotation.rows.defense[2]:IsShown(),
  "le deuxieme cooldown defensif est visible")
assert(B.pages.rotation.rows.reactive[3]:IsShown(),
  "Fulgurance, Ivresse et Execution visibles en meme temps")
assert(B.pages.rotation.rotationSummary.text:find("Sanguinaire",1,true),
  "la boucle niveau 40 apparait independamment des procs")
B.pages.rotation.modeButtons.multi.handlers.OnClick()
assert(B.rotationMode=="multi" and
 B.pages.rotation.rows.cycle[1].name.text=="Tourbillon")
B.pages.rotation.modeButtons.mono.handlers.OnClick()
assert(B.rotationMode=="mono")
B:ShowPage("talents")
B.pages.talents.variantButton.handlers.OnClick()
assert(B.planVariant=="hybrid" and B:PlanAt(60).pointsByTree.Armes==13,
  "variante hybride accessible et plan partage entre 3 arbres")
B:SetPreview(60)
B:SelectTree("Armes")
B:Refresh()
assert(B.pages.talents.trees.Armes.nodes["Deep Wounds"].edges[1].color[4]==1,
  "point actuel hybride surligne dans l'arbre Armes")
B:SelectPlanVariant("fury")
B:SelectTree("Furie")
B:Refresh()
B:SetPreview(60)
B:Refresh()
assert(B.pages.talents.nextLabel.text:find("places",1,true))
assert(B.chapterMode and B.pages.parcours.count.text:find("1-60",1,true),
  "les niveaux hors pilote affichent un plan de zones sans fausses quetes")
assert(not B:MarkStep(),"pas de validation manuelle dans l'apercu non verifie")

B:ChangeScale(-0.08)
assert(B.frame.scale==0.74)
B:ReturnToReal()
B:Refresh()
assert(B.levelText.text:find("34",1,true))
print("OK: 3 tree panels, hybrid points, learned rank-2 spells, buff state, gear and real mono/aoe loops")
