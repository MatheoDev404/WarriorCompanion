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
  local savedScale=tonumber(db.scale) or 0.82
  self.scale=max(0.65,min(1.15,savedScale))
  self.routeIndex=nil
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
  if self.db then self.db.preview=level end
  return true
end
function B:ReturnToReal()
  self.mode="follow"
  self.routeForced=false
  self.routeIndex=nil
  self.viewLevel=self.realLevel or 1
  if self.db then self.db.preview=nil end
end
function B:ChangeScale(delta)
  self.scale=max(0.65,min(1.15,math.floor(((self.scale or 0.82)+delta)*100+0.5)/100))
  if self.db then self.db.scale=self.scale end
  if self.frame then self.frame:SetScale(self.scale) end
  return self.scale
end
function B:PlanAt(level)
  local meta,ranks={},{}
  if not numberLevel(level) then return nil end
  for _,node in ipairs(self.talents) do meta[node[1]]=node end
  local nextPoint=nil
  for _,block in ipairs(self.talentBlocks) do
    for l=block[1],block[2] do
      if l<=level then ranks[block[3]]=(ranks[block[3]] or 0)+1
      elseif not nextPoint then nextPoint=block[3] end
    end
  end
  return {ranks=ranks,nextKey=nextPoint,level=level,metadata=meta}
end
-- Renvoie le talent EXACTEMENT attribue au niveau consulte.
-- Distinct du prochain point (niveau +1) : important pour le surlignage.
function B:TalentPointAt(level)
  if type(level)~="number" or level<10 or level>60 then return nil end
  for _,block in ipairs(self.talentBlocks) do
    if level>=block[1] and level<=block[2] then
      local plan=self:PlanAt(level)
      return {key=block[3],rank=plan.ranks[block[3]],
        level=level,metadata=plan.metadata[block[3]]}
    end
  end
  return nil
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
function B:ValidateBuild()
  local metadata={}
  for _,node in ipairs(self.talents) do
    if metadata[node[1]] then return false,"Talent en double" end
    metadata[node[1]]=node
  end
  local rankByKey={}
  local rowCount={}
  local level=10
  for _,block in ipairs(self.talentBlocks) do
    if block[1]~=level or block[2]<block[1] then
      return false,"Point manquant / intervalle talent au niveau "..level
    end
    for l=block[1],block[2] do
      local node=metadata[block[3]]
      if not node then return false,"Talent inconnu "..block[3] end
      local count=rankByKey[block[3]] or 0
      if count>=node[4] then return false,"Rang excessif "..block[3] end
      local earlier=0
      for row,n in pairs(rowCount) do
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
      rowCount[node[2]]=(rowCount[node[2]] or 0)+1
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
function B:ItemEligible(item,level)
  if item.minLevel>level then return false,"Niveau "..item.minLevel.." requis" end
  if item.source=="quest" then
    if item.group then return true,"GROUPE : quete non obligatoire" end
    return true,"Quete : verifier les prerequis"
  end
  if item.source=="craft" then
    return true,"Forge "..item.skill.." : recette et materiaux a verifier"
  end
  return false,"Source refusee"
end
function B:QuestCompletion(questId)
  if type(questId)~="number" or
      type(C_QuestLog)~="table" or
      type(C_QuestLog.IsQuestFlaggedCompleted)~="function" then
    return nil
  end
  local ok,value=pcall(C_QuestLog.IsQuestFlaggedCompleted,questId)
  if not ok then return nil end
  if value==true then return true end
  if value==false then return false end
  return nil
end
function B:StepState(step)
  if step.level>(self.realLevel or 1) then return "PLUS TARD" end
  if step.questId and self:QuestCompletion(step.questId)==true then
    return "QUETE TERMINEE"
  end
  if self.db and self.db.done and self.db.done[step.id] then
    return "FAIT (MANUEL)"
  end
  if step.group then return "OPTION GROUPE" end
  if step.optional then return "OPTION" end
  if step.questId then return "QUETE A VERIFIER" end
  return "A FAIRE / VERIFIER"
end
function B:GoToGear(id)
  for i,entry in ipairs(self:OrderedRoute()) do
    if entry.step.gearId==id then
      self.routeIndex=i
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
  if step.group or step.level>(self.realLevel or 1) then return false end
  self.db.done[step.id]=not self.db.done[step.id]
  return true
end
