local _,B=...
-- Moteur du guide detaille : une etape de quete n'est validee que sur
-- preuve du journal (acceptation, objectifs prets, rendu). Les actions
-- non liees a une quete peuvent etre passees manuellement, sans mentir
-- sur l'etat du journal. Les 302 donnees OpenXP sont dans DetailedData30_40.
local zoneMaps={
  ["Thousand Needles"]=1441,["Hillsbrad Foothills"]=1424,
  ["Alterac Mountains"]=1416,["Arathi Highlands"]=1417,
  ["Dustwallow Marsh"]=1445,["Desolace"]=1443,
  ["Stranglethorn Vale"]=1434,["Stonetalon Mountains"]=1442,
  ["Ashenvale"]=1440,["Durotar"]=1411,
  ["The Barrens"]=1413,["Thunder Bluff"]=1456,
  ["Badlands"]=1418,["Swamp of Sorrows"]=1435,
}
local frZones={
  ["Thousand Needles"]="Mille pointes",
  ["Hillsbrad Foothills"]="Contreforts de Hautebrande",
  ["Alterac Mountains"]="Montagnes d'Alterac",
  ["Arathi Highlands"]="Hautes-terres d'Arathi",
  ["Dustwallow Marsh"]="Marécage d'Âprefange",
  ["Desolace"]="Désolace",
  ["Stranglethorn Vale"]="Vallée de Strangleronce",
  ["Stonetalon Mountains"]="Serres-Rocheuses",
  ["Ashenvale"]="Orneval",["Durotar"]="Durotar",
  ["The Barrens"]="Tarides",["Thunder Bluff"]="Pitons-du-Tonnerre",
  ["Badlands"]="Terres ingrates",["Swamp of Sorrows"]="Marais des Chagrins",
}
local actionFR={accept="Accepter",complete="Faire",turnin="Rendre"}
local function safe(fn,...)
  if type(fn)~="function" then return nil end
  local ok,value=pcall(fn,...)
  if ok then return value end
  return nil
end
local function plain(v)
  if type(issecretvalue)=="function" then
    local ok,secret=pcall(issecretvalue,v)
    if not ok or secret then return nil end
  end
  return v
end
local function numeric(v)
  v=plain(v)
  if type(v)~="number" then return nil end
  local ok,valid=pcall(function()
    return v==v and v~=math.huge and v~=-math.huge
  end)
  return ok and valid and v or nil
end
local function readable(raw)
  if type(raw)~="string" then return "Étape à vérifier" end
  local text=raw:gsub("RXP_%u+_",""):gsub("^%s*>>","")
  text=text:gsub("Get to ","Rejoindre "):gsub("Talk to ","Parler à ")
    :gsub("Kill ","Tuer "):gsub("Loot ","Ramasser ")
    :gsub("Use ","Utiliser "):gsub("Fly to ","Voler vers ")
    :gsub("Hearthstone","Pierre de foyer")
    :gsub("Loot them for ","Récupérer sur eux ")
  return text
end
local function questTitle(id)
  local api=C_QuestLog
  if type(api)=="table" then
    local title=plain(safe(api.GetTitleForQuestID,id))
    if type(title)=="string" and title~="" then return title end
  end
  return nil
end
B.guidePacks=B.guidePacks or {}
B.guideSteps=B.guideSteps or {}
function B:RegisterGuidePack(pack)
  if type(pack)~="table" or type(pack.id)~="string" or
      type(pack.steps)~="table" or type(pack.minLevel)~="number" or
      type(pack.maxLevel)~="number" or #pack.steps==0 then return false end
  local index=#self.guidePacks+1
  self.guidePacks[index]=pack
  local mapHits={}
  for k,src in ipairs(pack.steps) do
    local id="guide30:"..pack.id..":"..k
    local raw=src.text or ""
    local map=zoneMaps[src.zone or ""]
    if map then mapHits[map]=(mapHits[map] or 0)+1 end
    local validXY=numeric(src.x) and numeric(src.y) and
      src.x>=0 and src.x<=100 and src.y>=0 and src.y<=100
    local action=src.action
    local step={
      id=id,guide=true,guideIndex=#self.guideSteps+1,pack=index,
      packID=pack.id,level=pack.minLevel,packMax=pack.maxLevel,
      zone=frZones[src.zone] or src.zone or pack.title or "Zone à confirmer",
      sourceZone=src.zone,kind=action and "quest" or "task",
      questId=numeric(src.questID),action=action,rawText=raw,
      x=validXY and src.x or nil,y=validXY and src.y or nil,
      mapID=validXY and map or nil,
      travel=(not action and (raw:find("Get to",1,true) or
        raw:find("Fly to",1,true))) and true or false,
      group=(raw:lower():find("run the ",1,true) or
        raw:lower():find("dungeon",1,true)) and true or false,
    }
    step.optional=step.group
    step.text=readable(raw)
    self.guideSteps[#self.guideSteps+1]=step
  end
  local largest=0
  for map,n in pairs(mapHits) do
    if n>largest then largest=n pack.majorMap=map end
  end
  return true
end
function B:DetailedAudit()
  local a={packs=#self.guidePacks,steps=#self.guideSteps,coords=0,
    questActions=0,badCoords=0,unknownMaps=0,badQuestIDs=0,
    customIDs={},nonQuestSteps=0}
  for _,step in ipairs(self.guideSteps) do
    if step.x and step.mapID then a.coords=a.coords+1 end
    if step.questId then
      a.questActions=a.questActions+1
      if step.questId<1 or step.questId~=math.floor(step.questId) then
        a.badQuestIDs=a.badQuestIDs+1
      end
      if step.questId>=90000 then a.customIDs[step.questId]=true end
    else a.nonQuestSteps=a.nonQuestSteps+1 end
    -- No fabricated map IDs: missing destination remains unknown.
    if step.x and not step.mapID then a.unknownMaps=a.unknownMaps+1 end
  end
  return a
end
function B:GuideText(step)
  if not step then return "" end
  if step.questId and actionFR[step.action] then
    local title=questTitle(step.questId)
    return actionFR[step.action].." : "..(title or "quête #"..step.questId)
  end
  return step.text
end
local function stateOf(self,step)
  local marked=self.db and self.db.guideManual and
    self.db.guideManual[step.id]
  if marked=="done" then return "FAIT (MANUEL)" end
  if marked=="skip" then return "IGNORÉE" end
  if step.questId then
    local live=self:QuestLiveState(step.questId)
    if live=="DONE" then return "QUÊTE RENDUE" end
    if step.action=="accept" then
      if live=="ACTIVE" or live=="READY" then return "QUÊTE ACCEPTÉE" end
      return "À ACCEPTER"
    end
    if step.action=="complete" then
      if live=="READY" then return "OBJECTIFS FAITS" end
      if live=="ACTIVE" then return "EN COURS" end
      return "NON ACCEPTÉE"
    end
    if step.action=="turnin" then
      if live=="READY" then return "À RENDRE" end
      if live=="ACTIVE" then return "OBJECTIFS EN COURS" end
      return "À VÉRIFIER"
    end
  end
  if step.group then return "OPTION GROUPE" end
  return step.travel and "DÉPLACEMENT" or "ÉTAPE À SUIVRE"
end
function B:GuideStepState(step)
  local state=stateOf(self,step)
  if step.questId and state=="À ACCEPTER" and
      self:GuidePrerequisites(step)==false then
    return "PRÉREQUIS MANQUANT"
  end
  return state
end
function B:GuideStepDone(step)
  local s=self:GuideStepState(step)
  return s=="FAIT (MANUEL)" or s=="IGNORÉE" or s=="QUÊTE RENDUE" or
    s=="QUÊTE ACCEPTÉE" or s=="OBJECTIFS FAITS"
end
-- La base source n'inclut pas tous les liens de prérequis. Ne propager
-- que les exigences explicitement renseignées dans le parcours existant.
function B:GuidePrerequisites(step)
  if not step.questId then return true end
  for _,curated in ipairs(self.route or {}) do
    if curated.questId==step.questId and
        (curated.requiresAll or curated.chainUnverified) then
      return self:PrerequisitesMet(curated)
    end
  end
  return nil -- non documenté, PAS un prérequis prouvé satisfait.
end
function B:DetailedEntries(showAll)
  local out={}
  for _,step in ipairs(self.guideSteps) do
    local status=self:GuideStepState(step)
    if showAll or not self:GuideStepDone(step) then
      out[#out+1]={step=step,state=status,order=step.guideIndex}
    end
  end
  return out
end
function B:GuideCurrentMap()
  local api=C_Map
  if type(api)~="table" then return nil end
  return numeric(safe(api.GetBestMapForUnit,"player"))
end
local function matchPack(pack,level,map,guideSteps)
  local distance=0
  if level<pack.minLevel then distance=pack.minLevel-level
  elseif level>pack.maxLevel then distance=level-pack.maxLevel end
  local score=distance*90
  -- Un simple detour dans la zone du personnage ne suffit pas : seul
  -- le hub majoritaire de la section change la priorite.
  if map and pack.majorMap==map then score=score-110 end
  return score
end
function B:GuideSuggestedStep(entries)
  if #entries==0 then return nil end
  local lv=self.realLevel or 30
  local map=self:GuideCurrentMap()
  local index={}
  for _,entry in ipairs(entries) do index[entry.step.id]=entry end
  if self.routeSelectedId and index[self.routeSelectedId] then
    return index[self.routeSelectedId].step
  end
  local saved=self.db and self.db.guideSelectedId
  if saved and index[saved] then
    local step=index[saved].step
    if lv>=step.level-1 and lv<=step.packMax+2 then return step end
  end
  -- Priorité aux quêtes déjà acceptées ou prêtes à rendre, dans la zone.
  local selected,best=nil,math.huge
  for _,entry in ipairs(entries) do
    local step=entry.step
    if not step.group and step.questId and
        (entry.state=="À RENDRE" or entry.state=="EN COURS") then
      local score=math.abs(lv-step.level)*20+
        ((step.mapID and step.mapID==map) and -100 or 0)+
        (entry.state=="À RENDRE" and -20 or 0)
      if score<best then best=score selected=step end
    end
  end
  if selected then return selected end
  local packIndex,packScore=nil,math.huge
  for i,pack in ipairs(self.guidePacks) do
    local score=matchPack(pack,lv,map,self.guideSteps)
    if score<packScore then packScore=score packIndex=i end
  end
  if packIndex then
    for _,entry in ipairs(entries) do
      if entry.step.pack==packIndex and not entry.step.group and
          entry.state~="PRÉREQUIS MANQUANT" then
        return entry.step
      end
    end
  end
  -- Section épuisée : prendre la section non terminée la plus proche.
  for _,entry in ipairs(entries) do
    if not entry.step.group and entry.step.level<=lv+1 and
        entry.state~="PRÉREQUIS MANQUANT" then
      return entry.step
    end
  end
  return nil
end
function B:GuideSelect(step)
  self.routeSelectedId=step and step.id or nil
  if self.db then self.db.guideSelectedId=self.routeSelectedId end
end
function B:GuideMarkStep(step)
  if not step or not step.guide or not self.db then return false end
  if type(self.db.guideManual)~="table" then self.db.guideManual={} end
  local old=self.db.guideManual[step.id]
  if old then
    self.db.guideManual[step.id]=nil
  else
    self.db.guideManual[step.id]=step.questId and "skip" or "done"
  end
  self.routeSelectedId=nil
  self.db.guideSelectedId=nil
  return true
end
function B:GuideTarget(step)
  if not step or not step.guide or not step.mapID or not
      step.x or not step.y then return nil end
  return {mapID=step.mapID,x=step.x,y=step.y,
    label=self:GuideText(step),id=step.id,travel=step.travel}
end
function B:GuideStepHelp(step)
  if not step then return nil end
  local lines={self:GuideText(step)}
  if step.sourceZone then
    lines[#lines+1]="Zone : "..(step.zone or step.sourceZone)
  end
  if step.questId then
    lines[#lines+1]="Quête #"..step.questId.." — "..self:GuideStepState(step)
    local objective=self:QuestObjectiveSummary(step.questId)
    if objective then lines[#lines+1]="Objectif : "..objective end
    local prereq=self:GuidePrerequisites(step)
    if prereq==false then
      lines[#lines+1]="Prérequis manquant : vérifier la chaîne précédente."
    elseif prereq==nil then
      lines[#lines+1]="Chaîne de prérequis non entièrement documentée."
    end
  end
  lines[#lines+1]="Instruction source : "..(step.text or "à confirmer")
  if step.mapID and step.x then
    lines[#lines+1]=string.format("Point : %.1f, %.1f",step.x,step.y)
  else lines[#lines+1]="Pas de coordonnées vérifiées : guidage indisponible." end
  if step.group then lines[#lines+1]="Option groupe : non obligatoire en solo." end
  return table.concat(lines,"\n")
end
