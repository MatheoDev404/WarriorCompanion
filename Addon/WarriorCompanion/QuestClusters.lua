local _, WC = ...
-- Regroupement spatial de PNJ DONNANT des quetes, pas un itineraire
-- d'objectifs ni un calcul de temps de trajet. Questie gere les marqueurs.
local MAX_CANDIDATES=40
local MAX_GROUPS=4
local CLOSE_COORD=15 -- pourcentage cartographique, PAS une distance/metres
local function safe(value,kind)
  if type(value)~=kind then return false end
  if type(issecretvalue)=="function" then
    local ok,hidden=pcall(issecretvalue,value)
    if not ok or hidden then return false end
  end
  if kind=="number" then
    return value==value and value~=math.huge and value~=-math.huge
  end
  return true
end
local function int(n,lo,hi)
  return safe(n,"number") and n==math.floor(n) and n>=lo and n<=hi
end
local function questField(api,id,key)
  local ok,value=pcall(api.Get,id,key)
  if not ok or (value~=nil and not safe(value,type(value))) then return nil end
  return value
end
local function checkSpawn(zone,list)
  if not int(zone,1,100000) or type(list)~="table" then return nil end
  for _,spot in ipairs(list) do
    if type(spot)=="table" and safe(spot[1],"number")
        and safe(spot[2],"number")
        and spot[1]>=0 and spot[1]<=100
        and spot[2]>=0 and spot[2]<=100 then
      return spot[1],spot[2]
    end
  end
  return nil
end
local function findStarter(lib,questID)
  local starters=questField(lib.Quest,questID,"startedBy")
  if type(starters)~="table" or type(starters[1])~="table" then
    return nil
  end
  if type(lib.Npc)~="table" or type(lib.Npc.Get)~="function" then return nil end
  local found={}
  for _,npcID in ipairs(starters[1]) do
    if int(npcID,1,10000000) then
      local friendly=questField(lib.Npc,npcID,"friendlyToFaction")
      if friendly=="H" or friendly=="AH" then
        local spawns=questField(lib.Npc,npcID,"spawns")
        if type(spawns)=="table" then
          for zone,locations in pairs(spawns) do
            local x,y=checkSpawn(zone,locations)
            if x then
              found[#found+1]={zone=zone,x=x,y=y,npc=npcID}
            end
          end
        end
      end
    end
  end
  table.sort(found,function(a,b)
    if a.zone~=b.zone then return a.zone<b.zone end
    if a.npc~=b.npc then return a.npc<b.npc end
    if a.x~=b.x then return a.x<b.x end
    return a.y<b.y
  end)
  return found[1]
end

function WC:BuildQuestClusters(candidates)
  local lib=_G and _G.LibQuestieDB
  if type(lib)~="table" or type(lib.Quest)~="table"
      or type(lib.Npc)~="table" then
    return nil,"QuestieDB absent ou sans donnees de PNJ"
  end
  if type(candidates)~="table" or type(candidates.rows)~="table" then
    return nil,"Quetes candidates non verifiees"
  end
  local groups={}
  for _,row in ipairs(candidates.rows) do
    if int(row.id,1,10000000) and type(row.name)=="string"
        and int(row.level,1,60) then
      local starter=findStarter(lib,row.id)
      if starter then
        local found
        for _,g in ipairs(groups) do
          if g.zone==starter.zone then
            local dx=g.x-starter.x
            local dy=g.y-starter.y
            if dx*dx+dy*dy <= CLOSE_COORD*CLOSE_COORD then
              found=g
              break
            end
          end
        end
        if not found then
          found={zone=starter.zone,x=starter.x,y=starter.y,rows={}}
          groups[#groups+1]=found
        end
        found.rows[#found.rows+1]={
          id=row.id,name=row.name,level=row.level,
          npc=starter.npc,x=starter.x,y=starter.y,
          zone=starter.zone,distance=row.distance or 99
        }
      end
    end
  end
  for _,group in ipairs(groups) do
    table.sort(group.rows,function(a,b)
      if a.distance~=b.distance then return a.distance<b.distance end
      return a.id<b.id
    end)
  end
  table.sort(groups,function(a,b)
    if #a.rows~=#b.rows then return #a.rows>#b.rows end
    local ad,bd=0,0
    for _,q in ipairs(a.rows) do ad=ad+q.distance end
    for _,q in ipairs(b.rows) do bd=bd+q.distance end
    if ad~=#a.rows*bd/#b.rows then
      return ad/#a.rows < bd/#b.rows
    end
    return a.zone<b.zone
  end)
  return groups
end

function WC:ShowQuestClusters()
  if self.inCombat then
    self:Print("Regroupement de quetes disponible hors combat.")
    return
  end
  if self.UpdateQuestAdvice then self:UpdateQuestAdvice() end
  local candidates,reason=self:DiscoverQuests(MAX_CANDIDATES)
  if not candidates then
    self:Print("Groupes de quetes : indisponibles ("..tostring(reason)..").")
    return
  end
  local groups,why=self:BuildQuestClusters(candidates)
  if not groups then
    self:Print("Groupes de quetes : indisponibles ("..tostring(why)..").")
    return
  end
  if #groups==0 then
    self:Print("Aucun groupe de PNJ de depart avec position et faction verifiees.")
    return
  end
  self:Print("Regroupements de PNJ de depart QuestieDB (pas des parcours d'objectifs) :")
  for i=1,math.min(MAX_GROUPS,#groups) do
    local group=groups[i]
    self:Print("Zone ID "..tostring(group.zone).." : "..tostring(#group.rows)..
      " quete(s), PNJ proches en coordonnees de carte. Verifier dans Questie.")
    for j=1,math.min(3,#group.rows) do
      local row=group.rows[j]
      self:Print("  ["..tostring(row.level).."] "..row.name..
        " (#"..tostring(row.id)..", PNJ "..tostring(row.npc)..")")
    end
  end
  self:Print("Groupe par zone et proximite de PNJ (seuil 15 points de carte) ; "..
    "aucun trajet, acces, ennemi, temps de route ou difficulte solo garanti.")
end
