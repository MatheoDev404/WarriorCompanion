local _,B=...
-- Etape B : decision XP / Securite et reprise apres deviation.
-- Heuristiques de choix, PAS un calcul de trajet ni une estimation garantie
-- de l'XP/h. Les paliers du guide ne sont pas des niveaux de monstres.
local abs,huge,min,max=math.abs,math.huge,math.min,math.max
local categoryOrder={"weapons","armor","professions","dungeons"}
local labels={weapons="Armes",armor="Armure",
  professions="Metiers",dungeons="Donjons"}
local mapZones={
  ["Desolace"]=1443,["Désolace"]=1443,
  ["Mille pointes"]=1441,["Tarides"]=1413,
  ["Strangleronce"]=1434,["Hautebrande"]=1424,
  ["Arathi"]=1417,["Aprefange"]=1445,
  ["Âprefange"]=1445,["Orgrimmar"]=1454,
  ["Pitons-du-Tonnerre"]=1456,["Terres ingrates"]=1418,
  ["Serres-Rocheuses"]=1442,
}
local function safe(v)
  if type(issecretvalue)=="function" then
    local ok,secret=pcall(issecretvalue,v)
    if not ok or secret then return nil end
  end
  return v
end
local function number(v)
  v=safe(v)
  if type(v)~="number" then return nil end
  local ok,valid=pcall(function()
    return v==v and v~=huge and v~=-huge
  end)
  return (ok and valid) and v or nil
end
local function zoneMap(name)
  if type(name)~="string" then return nil end
  for label,id in pairs(mapZones) do
    if name:find(label,1,true) then return id end
  end
  return nil
end
local function isWeapon(item)
  return item and type(item.slot)=="string" and
    item.slot:find("Arme",1,true)~=nil
end
function B:AdaptiveInit()
  if not self.db then return end
  if self.db.routeMode~="xp" then self.db.routeMode="safe" end
  if type(self.db.routeOptions)~="table" then self.db.routeOptions={} end
  for _,category in ipairs(categoryOrder) do
    if type(self.db.routeOptions[category])~="boolean" then
      self.db.routeOptions[category]=category~="dungeons"
    end
  end
  -- Anciennes selections automatiques 0.4.0 : ne pas les traiter comme
  -- des epingles. Une selection manuelle sera explicitement marquee.
  if self.db.guidePinned~=true then
    self.db.guidePinned=false
    self.db.guideSelectedId=nil
  end
end
function B:AdaptiveMode()
  if not self.db then return "safe" end
  return self.db.routeMode=="xp" and "xp" or "safe"
end
function B:AdaptiveSetMode(mode)
  if mode~="safe" and mode~="xp" then return false end
  self:AdaptiveInit()
  if not self.db then return false end
  if self.db.routeMode~=mode then
    self.db.routeMode=mode
    self:AdaptiveInvalidate("preference")
  end
  return true
end
function B:AdaptiveToggleMode()
  return self:AdaptiveSetMode(self:AdaptiveMode()=="safe" and "xp" or "safe")
end
function B:AdaptiveOptionEnabled(category)
  self:AdaptiveInit()
  return self.db and self.db.routeOptions and
    self.db.routeOptions[category]==true or false
end
function B:AdaptiveSetOption(category,enabled)
  if not labels[category] or type(enabled)~="boolean" then return false end
  self:AdaptiveInit()
  if not self.db then return false end
  self.db.routeOptions[category]=enabled
  self:AdaptiveInvalidate("preference")
  return true
end
function B:AdaptiveToggleOption(category)
  return self:AdaptiveSetOption(category,not self:AdaptiveOptionEnabled(category))
end
function B:AdaptiveOptionCategory(source)
  if not source or not (source.optional or source.group or
      source.kind=="craft") then return nil end
  local item=self:FindGearForStep(source)
  if source.kind=="dungeon" or source.group then return "dungeons" end
  if item and isWeapon(item) then return "weapons" end
  if item then return "armor" end
  if source.kind=="craft" or
      (source.id=="desolace-cookbook") then return "professions" end
  return nil
end
local function bestPack(self,step,map)
  local best,rank=nil,huge
  for index,pack in ipairs(self.guidePacks or {}) do
    local gap=0
    if step.level<pack.minLevel then gap=pack.minLevel-step.level
    elseif step.level>pack.maxLevel then gap=step.level-pack.maxLevel end
    local score=gap*30
    if map and pack.majorMap==map then score=score-65 end
    if score<rank then best,rank=index,score end
  end
  return best
end
function B:AdaptiveDetours()
  if self.adaptiveDetours then return self.adaptiveDetours end
  local out={}
  for index,source in ipairs(self.route or {}) do
    local category=self:AdaptiveOptionCategory(source)
    if category and source.level>=30 and source.level<=40 then
      local map=zoneMap(source.zone)
      local pack=bestPack(self,source,map)
      if pack then
        local step={
          id="detour:"..source.id,guide=true,detour=true,category=category,
          sourceStep=source,level=source.level,pack=pack,
          packID=self.guidePacks[pack].id,
          packMax=self.guidePacks[pack].maxLevel,
          guideIndex=#(self.guideSteps or {})+index,
          questId=source.questId,gearId=source.gearId,
          mapID=nil,zone=source.zone,kind=source.kind,
          text=source.text,group=source.group==true,optional=true,
        }
        out[#out+1]=step
      end
    end
  end
  self.adaptiveDetours=out
  return out
end
function B:AdaptiveStepState(step)
  if not step then return "INDISPONIBLE" end
  if not step.detour then return self:GuideStepState(step) end
  local marked=self.db and self.db.guideManual and self.db.guideManual[step.id]
  if marked=="done" then return "FAIT (MANUEL)" end
  if marked=="skip" then return "IGNORÉE" end
  local src=step.sourceStep
  if step.questId then
    local live=self:QuestLiveState(step.questId)
    if live=="DONE" then return "QUÊTE RENDUE" end
    if live=="READY" then return "À RENDRE" end
    if live=="ACTIVE" then return "EN COURS" end
    local prereq=self:PrerequisitesMet(src)
    if prereq==false then return "PRÉREQUIS MANQUANT" end
    if prereq==nil then return "CHAÎNE À VÉRIFIER" end
  end
  if step.category=="dungeons" then return "OPTION GROUPE" end
  if step.category=="professions" then return "OPTION MÉTIER" end
  return step.category=="weapons" and "OPTION ARME" or "OPTION ÉQUIPEMENT"
end
-- Un seul calcul de statut par étape lors du rendu du parcours.
-- Les quêtes en attente de rendu ne sont jamais considérées comme faites.
function B:AdaptiveStatusDone(step,state)
  if not step then return false end
  if state=="FAIT (MANUEL)" or state=="IGNORÉE" or
      state=="QUÊTE RENDUE" then return true end
  return not step.detour and
    (state=="QUÊTE ACCEPTÉE" or state=="OBJECTIFS FAITS")
end
function B:AdaptiveStepDone(step)
  if not step then return false end
  return self:AdaptiveStatusDone(step,self:AdaptiveStepState(step))
end
function B:AdaptiveText(step)
  if not step then return "" end
  return step.detour and step.text or self:GuideText(step)
end
function B:AdaptiveStepHelp(step)
  if not step then return nil end
  if not step.detour then return self:GuideStepHelp(step) end
  local source=step.sourceStep
  local lines={step.text,self:AdaptiveStepState(step)}
  local help=self:RouteHelp(source)
  if help then lines[#lines+1]=help end
  if source.note and source.note~=help then
    lines[#lines+1]=source.note
  end
  lines[#lines+1]="Détour facultatif : un choix, jamais une étape XP imposée."
  return table.concat(lines,"\n")
end
function B:AdaptiveTarget(step)
  if not step or step.detour then return nil end
  return self:GuideTarget(step)
end
function B:AdaptiveEntries(showDone)
  self:AdaptiveInit()
  local all={}
  local lastByPack={}
  for i,step in ipairs(self.guideSteps or {}) do
    lastByPack[step.pack]=i
  end
  local addAfter={}
  local enabled=self.db and self.db.routeOptions or {}
  for _,step in ipairs(self:AdaptiveDetours()) do
    if enabled[step.category]==true then
      local anchor=lastByPack[step.pack]
      if anchor then
        if not addAfter[anchor] then addAfter[anchor]={} end
        addAfter[anchor][#addAfter[anchor]+1]=step
      end
    end
  end
  local function add(step)
    local state=self:AdaptiveStepState(step)
    if showDone or not self:AdaptiveStatusDone(step,state) then
      all[#all+1]={step=step,state=state,order=#all+1}
    end
  end
  for i,step in ipairs(self.guideSteps or {}) do
    add(step)
    for _,extra in ipairs(addAfter[i] or {}) do add(extra) end
  end
  return all
end
local function currentPosition(self,map)
  if not map or type(C_Map)~="table" or
      type(C_Map.GetPlayerMapPosition)~="function" then return nil end
  local ok,position=pcall(C_Map.GetPlayerMapPosition,map,"player")
  if not ok or not position then return nil end
  local okXY,x,y=pcall(function()
    if type(position.GetXY)=="function" then
      return position:GetXY()
    end
    return position.x,position.y
  end)
  x,y=number(x),number(y)
  if not okXY or not x or not y then return nil end
  if x<0 or x>1 or y<0 or y>1 then return nil end
  return x*100,y*100
end
function B:AdaptiveEligibility(step,state)
  if not step or self:AdaptiveStepDone(step) then return false,"fait" end
  if state=="PRÉREQUIS MANQUANT" then return false,"prérequis" end
  if step.group then return false,"groupe facultatif" end
  if step.detour then
    if not self:AdaptiveOptionEnabled(step.category) then
      return false,"option désactivée"
    end
    if state=="CHAÎNE À VÉRIFIER" then return false,"chaîne incertaine" end
    -- Les détours sont toujours proposés dans la liste, mais
    -- jamais imposés par la recommandation automatique.
    return false,"détour facultatif"
  end
  if step.questId then
    if state=="NON ACCEPTÉE" or state=="OBJECTIFS EN COURS" or
        state=="À VÉRIFIER" then return false,"quête non prête" end
    if state=="PRÉREQUIS MANQUANT" then return false,"prérequis" end
  end
  local level=self.realLevel or 1
  if step.level>level+1 and state~="EN COURS" and
      state~="À RENDRE" then return false,"palier supérieur" end
  if self:AdaptiveMode()=="safe" and step.level>level and
      state~="EN COURS" and state~="À RENDRE" then
    return false,"palier supérieur en sécurité"
  end
  return true
end
function B:AdaptiveScore(step,state,ctx)
  local level,map=ctx.level,ctx.map
  local gap=abs(level-step.level)
  local score=gap*(self:AdaptiveMode()=="safe" and 34 or 24)
  -- La préférence géographique ne vaut que pour une zone identifiée :
  -- jamais de distance inter-zone ou de temps de trajet inventé.
  local pack=self.guidePacks and self.guidePacks[step.pack]
  local place=step.mapID or (pack and pack.majorMap)
  if map and place==map then score=score-165
  elseif map and place and place~=map then score=score+80 end
  if map and step.mapID==map and ctx.x and ctx.y and
      step.x and step.y then
    local dx,dy=step.x-ctx.x,step.y-ctx.y
    score=score+math.sqrt(dx*dx+dy*dy)*1.7
  end
  if state=="À RENDRE" then score=score-700
  elseif state=="EN COURS" then score=score-530
  elseif state=="À ACCEPTER" then score=score-90 end
  if step.level>level-2 and self:AdaptiveMode()=="safe" then
    score=score+55*(step.level-level+3)
  end
  -- Conserver un bloc d'objectifs proche du même hub après un rendu.
  if self.adaptiveLastPack and step.pack==self.adaptiveLastPack then
    score=score-32
  end
  if self.routeSelectedId==step.id then score=score-15 end
  -- Départager sans perdre l'ordre du guide historique.
  return score+(step.guideIndex or 0)*0.02
end
function B:AdaptiveSuggestedStep(entries)
  if #entries==0 then return nil end
  self:AdaptiveInit()
  local byId={}
  for _,entry in ipairs(entries) do byId[entry.step.id]=entry end
  local pinned=self.db and self.db.guidePinned and
      self.db.guideSelectedId
  if pinned and byId[pinned] then
    local entry=byId[pinned]
    -- Un choix utilisateur reste libre même pour un donjon ; il cesse
    -- d'être épinglé après accomplissement ou sortie de sa zone.
    if not self:AdaptiveStepDone(entry.step) then
      return entry.step
    end
  end
  if self.db then
    self.db.guidePinned=false
    self.db.guideSelectedId=nil
  end
  local map=self:GuideCurrentMap()
  local px,py=currentPosition(self,map)
  local ctx={level=self.realLevel or 1,map=map,x=px,y=py}
  local best,bestScore=nil,huge
  for _,entry in ipairs(entries) do
    local step=entry.step
    local ok=self:AdaptiveEligibility(step,entry.state)
    if ok then
      local score=self:AdaptiveScore(step,entry.state,ctx)
      if score<bestScore then
        best,bestScore=step,score
      end
    end
  end
  return best
end
function B:AdaptiveInvalidate(reason)
  if not self.db then return end
  local pinned=self.db.guidePinned==true
  if pinned and reason=="zone" then
    local selected
    for _,step in ipairs(self.guideSteps or {}) do
      if step.id==self.db.guideSelectedId then selected=step break end
    end
    if not selected then
      for _,step in ipairs(self:AdaptiveDetours()) do
        if step.id==self.db.guideSelectedId then selected=step break end
      end
    end
    local map=self:GuideCurrentMap()
    -- Un objectif épinglé qui n'existe plus dans le catalogue ne doit
    -- jamais immobiliser la reprise automatique après un changement de zone.
    if not selected then pinned=false
    elseif selected.detour and not selected.mapID then
      -- Les détours sans waypoint ne doivent pas immobiliser le
      -- navigateur lorsque le joueur quitte sa région.
      pinned=false
    elseif selected.mapID and map and selected.mapID~=map then
      pinned=false
    end
  end
  if not pinned then
    self.db.guidePinned=false
    self.db.guideSelectedId=nil
    self.routeSelectedId=nil
  end
  self.adaptiveLastPack=nil
end
function B:AdaptiveChoose(step,manual)
  if not step then return false end
  self.routeSelectedId=step.id
  self.adaptiveLastPack=step.pack
  if self.db then
    if manual==true then
      self.db.guidePinned=true
      self.db.guideSelectedId=step.id
    elseif self.db.guidePinned~=true then
      self.db.guideSelectedId=nil
    end
  end
  return true
end
function B:AdaptiveResume()
  if self.db then
    self.db.guidePinned=false
    self.db.guideSelectedId=nil
  end
  self.routeSelectedId=nil
  self.routeScroll=0
  self.adaptiveLastPack=nil
  return self:AdaptiveSuggestedStep(self:AdaptiveEntries(false))
end
