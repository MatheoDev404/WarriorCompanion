local addon,B=...
local min,max,huge=math.min,math.max,math.huge
local function numberLevel(v)
  return type(v)=="number" and v==math.floor(v) and v>=1 and v<=60
end
function B:ObservedLevel()
  if type(UnitLevel)=="function" then
    local ok,n=pcall(UnitLevel,"player")
    if ok and numberLevel(n) then return n end
  end
  return self.realLevel or 1
end
function B:InitState()
  local db=_G.WCBuildDB
  if type(db)~="table" then db={} _G.WCBuildDB=db end
  if type(db.done)~="table" then db.done={} end
  self.db=db
  self.realLevel=self:ObservedLevel()
  self.viewLevel=(db.preview and numberLevel(db.preview)) and db.preview
    or self.realLevel
  self.mode=(db.preview and numberLevel(db.preview)) and "preview" or "follow"
  self.page="talents"
  self.selectedTree=(db.selectedTree and self.talentTrees and
    self.talentTrees[db.selectedTree]) and db.selectedTree or "Furie"
  self.planVariant=(db.planVariant and self.talentPlans and
    self.talentPlans[db.planVariant]) and db.planVariant or "fury"
  local savedScale=tonumber(db.scale) or 0.82
  self.scale=max(0.65,min(1.15,savedScale))
  self.routeIndex=nil
  self.routeSegment=nil
  self.routeSelectedId=nil
  self.routeScroll=0
  self.showCompleted=db.showCompleted==true
  self.questLog=nil
end
function B:UpdateLevel()
  local level=self:ObservedLevel()
  self.realLevel=level
  if self.mode~="preview" then self.viewLevel=level end
end
function B:SetPreview(level)
  if not numberLevel(level) then return false end
  self.viewLevel=level
  self.mode="preview"
  self.routeForced=false
  self.routeIndex=nil
  self.routeSegment=nil
  self.routeSelectedId=nil
  self.routeScroll=0
  self.selectedItem=nil
  if self.pages and self.pages.equipement then
    self.pages.equipement.gearOffset=0
    self.pages.equipement.gearFuture=false
  end
  if self.db then self.db.preview=level end
  return true
end
function B:ReturnToReal()
  self.mode="follow"
  self.routeForced=false
  self.routeIndex=nil
  self.viewLevel=self.realLevel or 1
  self.selectedItem=nil
  if self.pages and self.pages.equipement then
    self.pages.equipement.gearOffset=0
    self.pages.equipement.gearFuture=false
  end
  if self.db then self.db.preview=nil end
end
function B:ChangeScale(delta)
  self.scale=max(0.65,min(1.15,math.floor(((self.scale or 0.82)+delta)*100+0.5)/100))
  if self.db then self.db.scale=self.scale end
  if self.frame then self.frame:SetScale(self.scale) end
  return self.scale
end
function B:CurrentTalentBlocks()
  return (self.talentPlans and self.talentPlans[self.planVariant or "fury"])
    or self.talentBlocks
end
function B:SelectPlanVariant(id)
  if not self.talentPlans or not self.talentPlans[id] then return false end
  self.planVariant=id
  if self.db then self.db.planVariant=id end
  self.selectedTalent=nil
  return true
end
-- Les trois arbres partagent les memes 51 points. Le plan peut donc
-- allouer sur n'importe quel arbre sans modifier le moteur.
function B:PlanAt(level,blocks)
  if not numberLevel(level) then return nil end
  local meta=self:TalentMetadata()
  local ranks,ranksByTree={},{}
  for _,tree in ipairs(self.talentTreeOrder) do ranksByTree[tree]=0 end
  local nextPoint,nextTree=nil,nil
  for _,block in ipairs(blocks or self:CurrentTalentBlocks()) do
    local tree=block[4] or self:TreeForTalent(block[3]) or "Furie"
    for l=block[1],block[2] do
      if l<=level then
        ranks[block[3]]=(ranks[block[3]] or 0)+1
        ranksByTree[tree]=ranksByTree[tree]+1
      elseif not nextPoint then nextPoint=block[3] nextTree=tree end
    end
  end
  return {ranks=ranks,nextKey=nextPoint,nextTree=nextTree,
    level=level,metadata=meta,pointsByTree=ranksByTree}
end
function B:TalentPointAt(level,blocks)
  if type(level)~="number" or level<10 or level>60 then return nil end
  for _,block in ipairs(blocks or self:CurrentTalentBlocks()) do
    if level>=block[1] and level<=block[2] then
      local plan=self:PlanAt(level,blocks)
      return {key=block[3],rank=plan.ranks[block[3]],
        tree=block[4] or self:TreeForTalent(block[3]) or "Furie",
        level=level,metadata=plan.metadata[block[3]]}
    end
  end
  return nil
end

function B:SelectTree(tree)
  if not self.talentTrees or not self.talentTrees[tree] then return false end
  self.selectedTree=tree
  self.selectedTalent=nil
  if self.db then self.db.selectedTree=tree end
  return true
end

function B:RotationAt(level,mode)
  if type(level)~="number" or (mode~="mono" and mode~="multi") then
    return {}
  end
  local result={}
  for _,entry in ipairs(self.rotation[mode] or {}) do
    if level>=entry[3] then
      result[#result+1]={name=entry[1],spellId=entry[2],
        level=entry[3],note=entry[4]}
    end
  end
  return result
end
function B:ValidateBuild(blocks)
  local metadata=self:TalentMetadata()
  local keys={}
  for _,tree in ipairs(self.talentTreeOrder) do
    for _,node in ipairs(self.talentTrees[tree]) do
      if keys[node[1]] then return false,"Talent en double : "..node[1] end
      keys[node[1]]=tree
    end
  end
  local rankByKey,rowCount={},{}
  for _,tree in ipairs(self.talentTreeOrder) do rowCount[tree]={} end
  local level=10
  for _,block in ipairs(blocks or self.talentBlocks) do
    if block[1]~=level or block[2]<block[1] then
      return false,"Point manquant / intervalle talent au niveau "..level
    end
    for l=block[1],block[2] do
      local node=metadata[block[3]]
      local tree=block[4] or keys[block[3]]
      if not node or not rowCount[tree] or keys[block[3]]~=tree then
        return false,"Talent inconnu ou mauvais arbre : "..tostring(block[3])
      end
      local count=rankByKey[block[3]] or 0
      if count>=node[4] then return false,"Rang excessif "..block[3] end
      local earlier=0
      for row,n in pairs(rowCount[tree]) do
        if row<node[2] then earlier=earlier+n end
      end
      if earlier<5*(node[2]-1) then
        return false,"Palier verrouille "..block[3].." au niveau "..l
      end
      local dep=self.talentDependencies[block[3]]
      if dep and (rankByKey[dep[1]] or 0)<dep[2] then
        return false,"Prerequis "..dep[1].." pour "..block[3]
      end
      rankByKey[block[3]]=count+1
      rowCount[tree][node[2]]=(rowCount[tree][node[2]] or 0)+1
    end
    level=block[2]+1
  end
  if level~=61 then return false,"51 points non couverts" end
  return true
end
function B:OrderedRoute()
  local out={}
  for i,step in ipairs(self.route) do
    out[#out+1]={step=step,order=i}
  end
  table.sort(out,function(a,b)
    return a.step.level==b.step.level and a.order<b.order
      or a.step.level<b.step.level
  end)
  return out
end
function B:ValidateContent()
  local ok,why=self:ValidateBuild()
  if not ok then return false,why end
  if self.talentPlans then
    for name,blocks in pairs(self.talentPlans) do
      local valid,issue=self:ValidateBuild(blocks)
      if not valid then return false,"Variante "..name.." : "..tostring(issue) end
    end
  end
  local routes,gear={},{}
  for _,step in ipairs(self.route) do
    if routes[step.id] then return false,"Etape en double "..step.id end
    if not numberLevel(step.level) then return false,"Niveau etape invalide" end
    routes[step.id]=step
  end
  for _,item in ipairs(self.gear) do
    if gear[item.id] then return false,"Objet en double" end
    gear[item.id]=item
    if not numberLevel(item.minLevel) then
      return false,"Niveau objet invalide"
    end
    if item.source~="quest" and item.source~="craft" then
      return false,"Source objet interdite"
    end
    local step=routes[item.routeId]
    if not step or step.gearId~=item.id then
      return false,"Objet absent du parcours : "..item.name
    end
    if item.source=="quest" and
      (step.questId~=item.questId or step.kind~="quest" or
        step.level<item.minLevel) then
      return false,"Quete mal liee : "..item.name
    end
    if item.source=="craft" and
      (step.kind~="craft" or type(item.recipe)~="number" or
       type(item.skill)~="number") then
      return false,"Recette mal liee : "..item.name
    end
  end
  return true
end
-- L'ordre d'affichage n'est pas l'ordre du fichier. Les armes proches du
-- palier consulte passent avant les anciennes pieces et les futurs donjons.
function B:GearScore(item,level)
  local difference=level-item.minLevel
  local score=40-math.abs(difference)*4
  if item.slot=="Arme 1 main" then
    score=score+25
    -- Base objective provenant des fiches d'armes, mais sans simuler
    -- la rage / cadence / statistiques du personnage.
    if type(item.dps)=="number" then
      score=score+math.min(30,item.dps)
    end
  end
  if item.group then score=score-15 end
  if difference<0 then score=score-25 end
  if item.questMinLevel and difference<0 then score=score-20 end
  if difference>8 then score=score-65 end
  if difference< -4 then score=score-90 end
  if self.db and self.db.done and self.db.done[item.routeId] then
    score=score-50
  end
  return score
end
-- Le premier ecran propose uniquement des objets du palier consulte.
-- Les recompenses futures restent visibles mais dans une liste distincte,
-- sans pretendre qu'elles sont deja obtenables.
function B:GearListAt(level,mode)
  if not numberLevel(level) then return {} end
  local future=mode=="future"
  local result={}
  for _,item in ipairs(self.gear) do
    local accessible=item.minLevel<=level and
      (not item.requiredLevel or item.requiredLevel<=level)
    if (future and not accessible) or (not future and accessible) then
      result[#result+1]=item
    end
  end
  table.sort(result,function(a,b)
    if future then
      if a.minLevel==b.minLevel then
        return self:GearScore(a,level)>self:GearScore(b,level)
      end
      return a.minLevel<b.minLevel
    end
    local x,y=self:GearScore(a,level),self:GearScore(b,level)
    if x==y then return a.minLevel>b.minLevel end
    return x>y
  end)
  return result
end
function B:GearRelevance(item,level)
  if item.minLevel>level then
    return "Prochain palier ("..item.minLevel.."+)"
  elseif level-item.minLevel>8 then
    return "Ancien palier - comparer avant de fabriquer"
  elseif item.group then
    return item.questMinLevel and "Longue chaine de quetes / reputation / groupe" or
      "Option groupe / donjon"
  end
  return "A evaluer pour le niveau "..level
end
function B:ItemEligible(item,level)
  if item.minLevel>level then
    if item.questMinLevel then
      return false,"Objet portable "..item.requiredLevel..
        "+ mais chaine prevue vers "..item.minLevel..
        " (quete minimum "..item.questMinLevel..")"
    end
    return false,"Palier cible "..item.minLevel.." pas encore atteint"
  end
  if item.source=="quest" then
    if item.group then return true,"GROUPE : quete non obligatoire" end
    return true,"Quete : verifier les prerequis"
  end
  if item.source=="craft" then
    return true,"Forge "..item.skill.." : recette et materiaux a verifier"
  end
  return false,"Source refusee"
end
-- Les segments sont explicites et non superposes (30-40 est inclusif).
-- Les autres segments restent indiques comme partiellement documentes.
B.levelSegments={
  {1,9,"1-9"},{10,19,"10-19"},{20,29,"20-29"},
  {30,40,"30-40"},{41,50,"41-50"},{51,60,"51-60"},
}
function B:SegmentAt(level)
  for i,segment in ipairs(self.levelSegments) do
    if level>=segment[1] and level<=segment[2] then return i end
  end
  return 1
end
function B:CurrentRouteSegment()
  return self.routeSegment or self:SegmentAt(self.viewLevel or 1)
end
function B:SelectRouteSegment(index)
  if not self.levelSegments[index] then return false end
  self.routeSegment=index
  self.routeSelectedId=nil
  self.routeScroll=0
  self.routeForced=false
  return true
end
local function questSafe(fn,...)
  if type(fn)~="function" then return nil end
  local ok,value=pcall(fn,...)
  if ok then return value end
  return nil
end
-- Forever 1.60 utilise le C_QuestLog moderne : un objectif pret a rendre
-- n'est PAS une quete deja rendue. On les garde distincts.
function B:ReadQuestLog()
  local api=C_QuestLog
  if type(api)~="table" or
     type(api.GetNumQuestLogEntries)~="function" or
     type(api.GetInfo)~="function" then
    self.questLog=nil
    return nil
  end
  local n=questSafe(api.GetNumQuestLogEntries)
  if type(n)~="number" or n<0 or n>1000 then
    self.questLog=nil
    return nil
  end
  local states={}
  for i=1,n do
    local info=questSafe(api.GetInfo,i)
    if type(info)=="table" and not info.isHeader and
       type(info.questID)=="number" then
      local finished=info.readyForTurnIn==true or info.isComplete==true
      if not finished then
        finished=questSafe(api.IsComplete,info.questID)==true
      end
      states[info.questID]=finished and "READY" or "ACTIVE"
    end
  end
  self.questLog=states
  return states
end
function B:QuestCompletion(questId)
  if type(questId)~="number" then return nil end
  local api=C_QuestLog
  if type(api)~="table" then return nil end
  local completed=questSafe(api.IsQuestFlaggedCompleted,questId)
  if completed==true then return true end
  if completed==false then return false end
  return nil
end
function B:QuestLiveState(questId)
  if type(questId)~="number" then return nil end
  if self:QuestCompletion(questId)==true then return "DONE" end
  local book=self.questLog
  if not book then book=self:ReadQuestLog() end
  if book and book[questId] then return book[questId] end
  local api=C_QuestLog
  if type(api)=="table" and type(api.GetLogIndexForQuestID)=="function" and
      type(api.GetInfo)=="function" then
    local index=questSafe(api.GetLogIndexForQuestID,questId)
    if type(index)=="number" and index>0 then
      local info=questSafe(api.GetInfo,index)
      if type(info)=="table" and info.questID==questId then
        return (info.isComplete==true or info.readyForTurnIn==true) and
          "READY" or "ACTIVE"
      end
    end
  end
  return nil -- non observe, pas automatiquement absent.
end
function B:IsStepDone(step)
  if step.questId and self:QuestCompletion(step.questId)==true then
    return true
  end
  return not step.questId and self.db and self.db.done and
    self.db.done[step.id]==true or false
end
-- Ordre de passage pilote : regroupe les hubs sans imposer de donjon ni
-- de chaine longue. Il ne pretend pas mesurer un trajet in-game.
local visitRank={
  ["warrior-islander"]=1,["warrior-affray"]=2,
  ["horde-regthar"]=3,["alliance-rel-1"]=4,
  ["lvl30"]=10,["lvl33"]=20,["salt-hardened-shells"]=21,
  ["salt-road"]=22,["salt-flat-venom"]=23,
  ["lvl34"]=30,["desolace-quest-hub"]=31,
  ["desolace-kodo"]=32,["desolace-shadowprey"]=40,
  ["desolace-cookbook"]=41,["desolace-kolkar"]=42,
  ["alliance-rel-2"]=43,["alliance-rel-3"]=44,
  ["desolace-satyr"]=45,["desolace-burning"]=46,
  ["desolace-khan-dez"]=47,["desolace-centaur-bounty"]=48,
  ["desolace-gelkis"]=49,["desolace-supplies"]=50,
  ["desolace-catch-day"]=51,["lvl36"]=65,["lvl37"]=70,
  ["lvl39"]=80,["lvl40"]=90,
}
function B:RouteSegmentEntries(index,showCompleted)
  local segment=self.levelSegments[index or self:CurrentRouteSegment()]
  if not segment then return {} end
  local result={}
  for i,step in ipairs(self.route) do
    if step.level>=segment[1] and step.level<=segment[2] and
        (showCompleted or not self:IsStepDone(step)) then
      result[#result+1]={step=step,order=i,state=self:StepState(step)}
    end
  end
  table.sort(result,function(a,b)
    local ka,kb=visitRank[a.step.id],visitRank[b.step.id]
    if ka or kb then
      -- Donner la priorite aux objectifs solo des hubs; les options
      -- de groupe non contraintes restent en fin de segment.
      local va=ka or (a.step.group and 900 or 200+a.step.level)
      local vb=kb or (b.step.group and 900 or 200+b.step.level)
      if va~=vb then return va<vb end
    end
    if a.step.level~=b.step.level then
      return a.step.level<b.step.level
    end
    if a.step.group~=b.step.group then return not a.step.group end
    if a.step.optional~=b.step.optional then return not a.step.optional end
    return a.order<b.order
  end)
  return result
end
function B:FirstSuggestedStep(entries)
  local level=self.realLevel or 1
  -- Ne pas conseiller en premier les quetes groupe, les prerequis
  -- incertains, ou les ennemis d'un palier futur.
  for _,entry in ipairs(entries) do
    local state=entry.state
    if entry.step.level<=level and not entry.step.optional and
       not entry.step.group and state~="PREREQUIS MANQUANT" and
       state~="CHAINE A VERIFIER" and state~="CHAINE / GROUPE" then
      return entry.step
    end
  end
  for _,entry in ipairs(entries) do
    if entry.step.level<=level and not entry.step.group and
        entry.state~="PREREQUIS MANQUANT" then
      return entry.step
    end
  end
  return entries[1] and entries[1].step or nil
end
-- nil: donnees manquantes; false: preuve de prerequis non rempli.
function B:PrerequisitesMet(step)
  -- La chaine a ete identifiee mais les prerequis serveur ne sont pas
  -- verifies un par un. Toujours afficher un statut incertain.
  if step.chainUnverified then return nil end
  if type(step.requiresAll)~="table" or #step.requiresAll==0 then
    return true
  end
  local uncertain=false
  for _,questId in ipairs(step.requiresAll) do
    local done=self:QuestCompletion(questId)
    if not done and self.db and self.db.done then
      for _,candidate in ipairs(self.route) do
        if candidate.questId==questId and self.db.done[candidate.id] then
          done=true
          break
        end
      end
    end
    if done==false then return false end
    if done==nil then uncertain=true end
  end
  if uncertain then return nil end
  return true
end
function B:StepState(step)
  if step.questId then
    local live=self:QuestLiveState(step.questId)
    if live=="DONE" then return "QUETE TERMINEE" end
    if live=="READY" then return "A RENDRE" end
    if live=="ACTIVE" then return "EN COURS" end
  elseif self.db and self.db.done and self.db.done[step.id] then
    return "FAIT (MANUEL)"
  end
  if step.level>(self.realLevel or 1) then return "PLUS TARD" end
  local prerequisites=self:PrerequisitesMet(step)
  if prerequisites==false then return "PREREQUIS MANQUANT" end
  if prerequisites==nil then
    return step.group and "CHAINE / GROUPE" or "CHAINE A VERIFIER"
  end
  if step.group then return "OPTION GROUPE" end
  if step.optional then return "OPTION" end
  if step.questId then return "A PRENDRE / VERIFIER" end
  return "A FAIRE / VERIFIER"
end
function B:GoToGear(id)
  for i,entry in ipairs(self:OrderedRoute()) do
    if entry.step.gearId==id then
      self.routeIndex=i
      self.routeSelectedId=entry.step.id
      self.routeSegment=self:SegmentAt(entry.step.level)
      self.routeScroll=0
      self.routeForced=true
      self.page="parcours"
      return true,entry.step
    end
  end
  return false
end
function B:FocusRoute()
  local route=self:OrderedRoute()
  if #route==0 then return nil end
  if self.routeIndex and route[self.routeIndex] then return self.routeIndex end
  for i,entry in ipairs(route) do
    if entry.step.level >= (self.viewLevel or 1) then
      self.routeIndex=i
      return i
    end
  end
  self.routeIndex=#route
  return self.routeIndex
end
function B:MarkStep()
  if self.chapterMode then return false end
  local steps=self:OrderedRoute()
  local current=steps[self:FocusRoute()]
  if not current or not self.db or not self.db.done then return false end
  local step=current.step
  if step.questId or step.group or
      step.level>(self.realLevel or 1) then return false end
  self.db.done[step.id]=not self.db.done[step.id]
  return true
end
