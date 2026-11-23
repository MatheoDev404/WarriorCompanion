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
    function t:SetPoint(...) self.point={...} end
    function t:SetSize(w,h) self.width=w self.height=h end
    function t:SetVertexColor(...) self.color={...} end
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
function CreateFrame() return frame() end
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
    itemIndexOffset=0,numSpellBookItems=2
  }end,
  GetSpellBookItemInfo=function(slot)
    return {spellID=slot==1 and 5242 or 100,itemType="SPELL"}
  end,
  GetSpellBookItemName=function(slot)
    return slot==1 and "Cri de guerre" or "Charge"
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
assert(B:PlayerBuffStatus("Cri de guerre",6673)==true)
B:CreateUI()
assert(B.frame.width==760 and B.frame.scale==0.82)
assert(B.page=="talents" and B.pages.talents:IsShown())
assert(B.pages.talents.trees.Armes and B.pages.talents.trees.Furie
  and B.pages.talents.trees.Protection,
  "les trois arbres doivent etre accessibles")
B.pages.talents.treeTabs.Armes.handlers.OnClick()
assert(B.selectedTree=="Armes"
  and B.pages.talents.nodes["Deep Wounds"],"arbre Armes visible")
B.pages.talents.treeTabs.Protection.handlers.OnClick()
assert(B.selectedTree=="Protection"
  and B.pages.talents.nodes["Shield Slam"],"arbre Protection visible")
B.pages.talents.treeTabs.Furie.handlers.OnClick()
assert(B.selectedTree=="Furie")
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
B.pages.talents.nodes["Cruelty"].handlers.OnClick()
assert(B.selectedTalent=="Cruelty")
B:ShowPage("equipement")
assert(B.pages.equipement:IsShown() and not B.pages.talents:IsShown())
B.pages.equipement.items[6802].handlers.OnEnter()
assert(lastTooltipItem==6802,"infobulle vraie de l'objet dans le client")
B.pages.equipement.items[6802].handlers.OnLeave()
B.pages.equipement.items[6802].handlers.OnClick()
assert(B.pages.equipement.previewName.text:find("Sword",1,true),
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
assert(B.pages.rotation.rows.cycle[3]:IsShown(),
  "trois techniques de cycle restent visibles quand elles existent")
assert(B.pages.rotation.rows.defense[2]:IsShown(),
  "le deuxieme cooldown defensif est visible")
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
assert(B.pages.talents.nodes["Deep Wounds"].edges[1].color[4]==1,
  "point actuel hybride surligne dans l'arbre Armes")
B:SelectPlanVariant("fury")
B:SelectTree("Furie")
B:Refresh()
B:SetPreview(60)
B:Refresh()
assert(B.pages.talents.nextLabel.text:find("termine",1,true))
assert(B.chapterMode and B.pages.parcours.count.text:find("1-60",1,true),
  "les niveaux hors pilote affichent un plan de zones sans fausses quetes")
assert(not B:MarkStep(),"pas de validation manuelle dans l'apercu non verifie")

B:ChangeScale(-0.08)
assert(B.frame.scale==0.74)
B:ReturnToReal()
B:Refresh()
assert(B.levelText.text:find("34",1,true))
print("OK: 3 tree panels, hybrid points, learned rank-2 spells, buff state, gear and real mono/aoe loops")
