local _,B=...
-- Planification par petites etapes, et NON liste d'achats 1-300 figee.
-- Les matieres ne sont considerees possedees que si un inventaire a pu
-- etre lu ; un stock inconnu n'est jamais traite comme zero.
local floor,ceil,min,max=math.floor,math.ceil,math.min,math.max
local function bandAt(bands,rank)
 if type(rank)~="number" then return nil end
 for _,stage in ipairs(bands) do
  if rank>=stage.from and rank<stage.to then return stage end
 end
 return nil
end
function B:MiningStage(rank) return bandAt(self.miningBands,rank) end
function B:SmithingStage(rank) return bandAt(self.smithingBands,rank) end
function B:ProfessionTrainer(key,rank,cap)
 if type(rank)~="number" or type(cap)~="number" then return nil end
 for _,tier in ipairs(self.professionTrainers[key] or {}) do
  if rank>=tier.skill and cap<tier.cap then return tier end
 end
 return nil
end
function B:ProfessionMiningZone(stage)
 if not stage then return nil end
 local current=self.GuideCurrentMap and self:GuideCurrentMap()
 local level=self.realLevel or 1
 local safe=self.AdaptiveMode and self:AdaptiveMode()~="xp"
 local best,bestScore=nil,math.huge
 for _,zone in ipairs(stage.zones or {}) do
  local score=(zone.minLevel or 99)>level and 1000 or
    (safe and (zone.minLevel or 99)>level-2 and 300 or 0)
  score=score+(zone.minLevel or 1)*0.1
  if current and current==zone.map then score=score-160 end
  if score<bestScore then best,bestScore=zone,score end
 end
 return best,bestScore>=300
end
function B:ProfessionCraftBatch(stage,skill)
 if not stage or type(skill)~="number" then return nil end
 return max(1,min(5,stage.to-skill))
end
function B:ProfessionRecipeInfo(stage)
 if not stage then return nil end
 return self:ProfessionRecipeByItem("smithing",stage.item)
end
function B:ProfessionMaterials(stage,crafts)
 local learned=self:ProfessionRecipeInfo(stage)
 local mats=(learned and learned.mats) or stage.mats
 if type(mats)~="table" or #mats==0 then return nil end
 local requirements={}
 for _,entry in ipairs(mats) do
  requirements[entry[1]]=(requirements[entry[1]] or 0)+entry[2]*crafts
 end
 local result={}
 for id,required in pairs(requirements) do
  local count,bag,bank,when=self:ProfessionStock(id,true)
  result[#result+1]={id=id,required=required,owned=count,
    missing=count and max(0,required-count) or nil,
    inBag=bag,inBank=bank,bankWhen=when}
 end
 table.sort(result,function(a,b) return a.id<b.id end)
 return result
end
function B:ProfessionItemName(itemID)
 local name=nil
 if type(C_Item)=="table" and type(C_Item.GetItemNameByID)=="function" then
  local ok,value=pcall(C_Item.GetItemNameByID,itemID)
  if ok and type(value)=="string" then name=value end
 end
 if not name and type(GetItemInfo)=="function" then
  local ok,value=pcall(GetItemInfo,itemID)
  if ok and type(value)=="string" then name=value end
 end
 if name then return name end
 local names={
  [2835]="Pierre brute",[2841]="Barre de bronze",[2838]="Pierre lourde",
  [3575]="Barre de fer",[2605]="Teinture verte",[3478]="Pierre a broyer grossiere",
  [7912]="Pierre solide",[3860]="Barre de mithril",
  [4338]="Etoffe de tisse-mage",[12365]="Pierre dense",
  [6037]="Barre de vrai-argent",[7910]="Rubis etoile",
  [7966]="Pierre a broyer solide",[4304]="Cuir epais",
  [12359]="Barre de thorium",[12799]="Grande opale",
  [12644]="Pierre a broyer dense",[8170]="Cuir robuste",
  [2772]="Minerai de fer",[3858]="Minerai de mithril",
  [2770]="Minerai de cuivre",[2771]="Minerai d'etain",
  [10620]="Minerai de thorium",
 }
 return names[itemID] or ("Objet #"..itemID)
end
function B:ProfessionStockBreakdown(materials)
 if not materials then return "Composants non confirmes dans le client." end
 local lines={}
 for _,m in ipairs(materials) do
  local line=self:ProfessionItemName(m.id)..": "..
    (m.owned and (m.owned.."/"..m.required) or
      ("?/"..m.required))
  if m.missing and m.missing>0 then
    line=line.." (manque "..m.missing..")"
  end
  if m.inBank and m.inBank>0 then line=line.." [banque]" end
  lines[#lines+1]=line
 end
 if self.db and self.db.professionBank and
    self.db.professionBank.stale==true then
  lines[#lines+1]="Banque non actualisee (exclue du calcul)"
 end
 return table.concat(lines," ; ")
end
-- Calcul récursif unique avec stock partage : les barres non possedees
-- sont converties en intrants si le Minage requis est atteint. Chaque
-- objet du stock n'est consommé qu'une fois pour le lot de cinq crafts max.
function B:ProfessionSupplyPlan(materials,miningSkill)
 local result={missing={},smelt={},unknown=false}
 if not materials then result.unknown=true return result end
 local inventory={}
 local function count(id)
  if inventory[id]~=nil then return inventory[id] end
  local n=self:ProfessionStock(id,true)
  inventory[id]=n or -1
  return inventory[id]
 end
 local function consume(id,required,depth)
  if depth>7 or required<=0 then return end
  local owned=count(id)
  if owned<0 then result.unknown=true return end
  local use=min(required,owned)
  inventory[id]=owned-use
  local need=required-use
  if need<=0 then return end
  local smelt=self.smelting[id]
  if smelt and type(miningSkill)=="number" and
      miningSkill>=smelt.skill then
   local crafts=ceil(need/smelt.q)
   result.smelt[id]=(result.smelt[id] or 0)+crafts
   for _,mat in ipairs(smelt.mats) do
    consume(mat[1],crafts*mat[2],depth+1)
   end
  else
   result.missing[id]=(result.missing[id] or 0)+need
  end
 end
 for _,m in ipairs(materials) do consume(m.id,m.required,0) end
 return result
end
function B:ProfessionSupplySummary(plan)
 if not plan then return "Quantites indisponibles." end
 if plan.unknown then
  return "Sacs non lisibles : verifier le stock avant toute recolte ou achat."
 end
 local lines={}
 for id,c in pairs(plan.smelt) do
  lines[#lines+1]="Fondre "..c.."x "..self:ProfessionItemName(id)
 end
 for id,c in pairs(plan.missing) do
  lines[#lines+1]="Manque "..c.."x "..self:ProfessionItemName(id)
 end
 table.sort(lines)
 return #lines>0 and table.concat(lines," ; ") or
   "Composants suffisants dans les sacs et banque ouverte."
end
local function entry(id,kind,text,state,detail,skill,goal,optional)
 return {step={id=id,profession=true,kind=kind,text=text,
   help=detail,skill=skill,goal=goal,optional=optional==true},
   state=state}
end
function B:ProfessionMiningEntries(key)
 local rank,cap=self:ProfessionSkill("mining")
 local out={}
 if rank==nil then
  out[#out+1]=entry(key..":mining:detect","check",
    "Lire le Minage dans la fiche Metiers","A VERIFIER",
    "Ouvrir les metiers ou /wcb metier set minage N CAP.")
 end
 local trainer=rank and self:ProfessionTrainer("mining",rank,cap)
 if trainer then
  out[#out+1]=entry(key..":mining:trainer:"..trainer.cap,"trainer",
   "Apprendre Minage "..trainer.name.." (maximum "..trainer.cap..")",
   "FORMATEUR",self.professionTrainersHorde.mining,rank,trainer.cap)
 end
 for _,band in ipairs(self.miningBands) do
  local done=rank and rank>=band.to
  local zone,risky=self:ProfessionMiningZone(band)
  local place=zone and zone.name or "zone a confirmer"
  local active=rank and rank>=band.from and rank<band.to
  local status=done and "TERMINE" or
    (active and (risky and "PRUDENCE" or "EN COURS") or "A VENIR")
  local detail="Gisement : "..band.node.." (Minage "..band.required..
    "+). Recolter jusqu'a "..band.to..". Zone conseillée : "..place..
    (risky and " ; ennemis potentiellement dangereux, choisir une alternative." or "")..
    " Pas de coordonnees de filon garanties."
  out[#out+1]=entry(key..":mining:"..band.from,"gather",
   "Minage "..band.from.."-"..band.to.." : "..band.node..
    " — "..place,status,detail,rank,band.to)
 end
 return out
end
function B:ProfessionSmithingEntries(key)
 local rank,cap=self:ProfessionSkill("smithing")
 local out={}
 if rank==nil then
  out[#out+1]=entry(key..":smith:detect","check",
   "Lire la Forge dans la fiche Metiers","A VERIFIER",
   "Ouvrir les metiers ou /wcb metier set forge N CAP.")
 end
 local trainer=rank and self:ProfessionTrainer("smithing",rank,cap)
 if trainer then
  out[#out+1]=entry(key..":smith:trainer:"..trainer.cap,"trainer",
   "Apprendre Forge "..trainer.name.." (maximum "..trainer.cap..")",
   "FORMATEUR",self.professionTrainersHorde.smithing,rank,trainer.cap)
 end
 for _,band in ipairs(self.smithingBands) do
  local done=rank and rank>=band.to
  local active=rank and rank>=band.from and rank<band.to
  local status=done and "TERMINE" or
    (active and "EN COURS" or "A VENIR")
  local qty=active and self:ProfessionCraftBatch(band,rank) or 1
  local mats=self:ProfessionMaterials(band,qty)
  local learned=self:ProfessionRecipeInfo(band)
  local detail="Objectif Forge "..band.to..". Lot initial "..qty..
    " fabrication(s), puis relire la competence. "..band.source..
    " ; "..self:ProfessionStockBreakdown(mats)..
    ". Les gains jaunes/verts ne sont pas garantis."
  if band.note then detail=detail.." "..band.note end
  if band.kind=="armor" or band.kind=="weapon" then
   local equipped=self:ProfessionIsEquipped(band.item)
   if equipped==true then
    detail=detail.." Equipement deja porte : eviter un doublon pour l'usage personnel."
   elseif equipped==false then
    detail=detail.." Comparer au materiel actuellement porte avant de le garder."
   end
  end
  if active and not learned then
   status="RECETTE A VERIFIER"
   detail=detail.." Ouvrir la Forge pour confirmer la recette connue."
  end
  out[#out+1]=entry(key..":smith:"..band.from,"craft",
   "Forge "..band.from.."-"..band.to.." : "..band.name..
     (active and (" ×"..qty) or ""),status,detail,rank,band.to)
 end
 return out
end
function B:ProfessionComboEntries()
 local mining,capM=self:ProfessionSkill("mining")
 local smith,capS=self:ProfessionSkill("smithing")
 local out={}
 if not mining or not smith then
  out[#out+1]=entry("combo:observe","check",
   "Lire les competences Minage et Forge","A VERIFIER",
   "Ouvrir les deux metiers, ou saisir leurs valeurs manuellement.")
  return out
 end
 local mt=self:ProfessionTrainer("mining",mining,capM)
 local st=self:ProfessionTrainer("smithing",smith,capS)
 if mt then
  out[#out+1]=entry("combo:trainer:mining","trainer",
    "Apprendre Minage "..mt.name.." (cap "..mt.cap..")",
    "FORMATEUR",self.professionTrainersHorde.mining,mining,mt.cap)
 end
 if st then
  out[#out+1]=entry("combo:trainer:smith","trainer",
    "Apprendre Forge "..st.name.." (cap "..st.cap..")",
    "FORMATEUR",self.professionTrainersHorde.smithing,smith,st.cap)
 end
 -- L'objectif utilisateur 169 -> 175 : d'abord permettre l'acces aux
 -- gisements de mithril, mais seulement lorsqu'on en est proche.
 if mining>=160 and mining<175 then
  local stage=self:MiningStage(mining)
  local zone=self:ProfessionMiningZone(stage)
  out[#out+1]=entry("combo:threshold:175","gather",
    "Minage "..mining.."/175 : terminer le palier fer",
    "PRIORITAIRE","Puis, au seuil 175, le mithril devient recoltable. "..
      "Zone : "..(zone and zone.name or "a choisir")..
      ". Ne pas partir miner le mithril avant la competence 175.",
      mining,175)
 end
 local stage=self:SmithingStage(smith)
 if not stage then
  if smith>=300 then
   out[#out+1]=entry("combo:complete","complete",
     "Forge 300/300 atteinte","TERMINE","Le Minage peut continuer seul.")
  end
  return out
 end
 local batch=self:ProfessionCraftBatch(stage,smith)
 local mats=self:ProfessionMaterials(stage,batch)
 local plan=self:ProfessionSupplyPlan(mats,mining)
 local learned=self:ProfessionRecipeInfo(stage)
 local details="Forge "..smith.."/"..stage.to.." : "..
   stage.name.." (premier lot "..batch.."x). "..
   self:ProfessionStockBreakdown(mats)
 if stage.kind=="armor" or stage.kind=="weapon" then
  local equipped=self:ProfessionIsEquipped(stage.item)
  if equipped==true then
   details=details.." Deja porte : fabriquer seulement pour progresser en Forge."
  elseif equipped==false then
   details=details.." Comparer l'objet a l'equipement porte au survol."
  end
 end
 if not learned then
  out[#out+1]=entry("combo:recipe","recipe",
    "Verifier que le plan "..stage.name.." est appris","A VERIFIER",
    "Ouvrir la Forge, puis confirmer la recette, son rang et ses composants. "..
    (stage.source=="plan" and "Plan a obtenir, ne pas acheter les materiaux avant." or
     "Si la recette manque, contacter le maitre correspondant."))
 end
 if plan.unknown then
  out[#out+1]=entry("combo:inventory","check",
    "Lire les sacs avant le calcul des materiaux","A VERIFIER",
    "Les sacs n'ont pas renvoye un inventaire exploitable : "..
    "ne pas en deduire un besoin de recolte.")
 else
  local shortages={}
  for id,qty in pairs(plan.missing) do
   shortages[#shortages+1]={id=id,count=qty}
  end
  table.sort(shortages,function(a,b)return a.id<b.id end)
  if #shortages>0 then
   out[#out+1]=entry("combo:recolte","gather",
    "Completer les composants manquants de Forge","MATERIAUX",
    "A recuperer, sans excedent pour ce lot : "..
     self:ProfessionSupplySummary(plan)..". "..
     "Regrouper la recolte avec le leveling quand la zone est sure.")
  end
  local smeltCount=0
  for _,qty in pairs(plan.smelt) do smeltCount=smeltCount+qty end
  if smeltCount>0 then
   out[#out+1]=entry("combo:smelt","smelt",
    "Fondre les barres necessaires a l'atelier","FONTE",
    self:ProfessionSupplySummary(plan)..
     ". Retourner a une forge seulement avec les intrants reunis.")
  end
 end
 out[#out+1]=entry("combo:craft","craft",
    "Fabriquer "..batch.."x "..stage.name,
    (learned and not plan.unknown and next(plan.missing)==nil and
       "DISPONIBLE" or "A PREPARER"),
    details..". Le gain de points n'est pas garanti ; "..
    "recalcul automatique apres chaque gain.",smith,stage.to)
 out[#out+1]=entry("combo:milestone","check",
    "Verifier la competence apres le lot","SUIVI AUTO",
    "Le prochain lot et ses materiaux sont recalcules apres progression.",
    smith,stage.to)
 return out
end
function B:ProfessionEntries(id,showDone)
 id=id or self:ActiveGuide()
 local out={}
 if id=="mining" then out=self:ProfessionMiningEntries(id)
 elseif id=="smithing" then out=self:ProfessionSmithingEntries(id)
 elseif id=="combo" then out=self:ProfessionComboEntries()
 else return {} end
 local filtered={}
 for _,e in ipairs(out) do
  local marked=self.db and self.db.professionProgress and
    self.db.professionProgress[id] and
    self.db.professionProgress[id].done
  if marked and marked[e.step.id] then
   e.state="FAIT (MANUEL)"
  end
  if showDone or (e.state~="TERMINE" and e.state~="FAIT (MANUEL)") then
   filtered[#filtered+1]=e
  end
 end
 return filtered
end
function B:ProfessionSuggestedStep(entries)
 if #entries==0 then return nil end
 local progress=self.db and self.db.professionProgress[self:ActiveGuide()]
 local selected=progress and progress.selected
 if selected then
  for _,e in ipairs(entries) do
   if e.step.id==selected then return e.step end
  end
 end
 return entries[1].step
end
function B:ProfessionMarkStep(step)
 if not step or not step.profession or not self.db then return false end
 local id=self:ActiveGuide()
 local p=self.db.professionProgress[id] or {}
 self.db.professionProgress[id]=p
 p.done=p.done or {}
 p.done[step.id]=not p.done[step.id] or nil
 p.selected=nil
 self.routeSelectedId=nil
 return true
end
function B:ProfessionProgressSummary(id)
 local mining,capM,srcM=self:ProfessionSkill("mining")
 local smith,capS,srcS=self:ProfessionSkill("smithing")
 if id=="mining" then
  return "Minage "..(mining or "?").."/"..(capM or "?"), mining,capM
 elseif id=="smithing" then
  return "Forge "..(smith or "?").."/"..(capS or "?"),smith,capS
 else
  return "Minage "..(mining or "?").."/"..(capM or "?")..
    " | Forge "..(smith or "?").."/"..(capS or "?"),
    mining,capM,smith,capS
 end
end
