local _, WC = ...
-- Recherche A LA DEMANDE de quetes non acceptees depuis l'API publique QuestieDB.
-- Une piste n'est pas une quete garantie disponible, solo, ni proche du joueur.
-- Refus prudent quand les restrictions, le statut ou les donnees sont incertains.
local MAX_IDS = 30000
local MAX_RESULTS = 7
-- WoW Forever, Duskwood Nightmare Incursions 81730..81747:
-- classées Elite dans le catalogue Forever daté du 22 novembre 2026.
-- Confirmation : https://db.icy-veins.com/wow-forever/quests/zones/duskwood/
-- L'API QuestieDB ne fournit pas de champ stable "difficulte solo".
-- Ne jamais les promouvoir dans un parcours de leveling solo prudent.
local function dangerousQuest(id, questApi)
  if id >= 81730 and id <= 81747 then return true end
  if type(questApi.GetQuestTagInfo)=="function" then
    local ok,tag=pcall(questApi.GetQuestTagInfo,id)
    if ok and type(tag)=="table" then
      if tag.isElite==true then return true end
      local kind=tag.tagID or tag.tagId
      if type(kind)=="number" and (kind==81 or kind==62 or kind==82
          or kind==83 or kind==88 or kind==89 or kind==1) then
        return true
      end
      -- Les tags inconnus ne prouvent jamais qu'une quête soit solo.
    end
  end
  return false
end
local function number(n, lo, hi)
  if type(n) ~= "number" or n ~= n or n ~= math.floor(n)
      or n < lo or n > hi then return false end
  if type(issecretvalue) == "function" then
    local ok, secret = pcall(issecretvalue,n)
    if not ok or secret then return false end
  end
  return true
end
local function plain(value)
  if type(issecretvalue) == "function" then
    local ok, secret = pcall(issecretvalue,value)
    if not ok or secret then return false end
  end
  return true
end
local function hasBit(mask, bit)
  return number(mask,0,9007199254740991) and number(bit,1,9007199254740991)
    and math.floor(mask/bit)%2 == 1
end
local function empty(list)
  return list == nil or (type(list)=="table" and next(list)==nil)
end
local function read(db,id,key)
  local ok, result = pcall(db.Get,id,key)
  if not ok or not plain(result) then return nil,false end
  return result,true
end
local function noConditions(db,id)
  -- Conditions de métier, réputation, spécialisation, sorts, famille,
  -- chaîne, phase et exclusion : si présentes, elles nécessitent un
  -- moteur de vérification séparé avant toute recommandation.
  local tables = {
    "preQuestGroup","preQuestSingle","exclusiveTo",
    "requiredSkill","requiredMinRep","requiredMaxRep",
    "requiredSourceItems","breadcrumbs","requiredRanks"
  }
  local scalars = {
    "parentQuest","requiredSpell","requiredSpecialization",
    "requiredMaxLevel","availableUntilCompleted",
    "availableStartingWith","disabledByQuest",
    "questFlags","specialFlags","nextQuestInChain"
  }
  for _,key in ipairs(tables) do
    local v,valid=read(db,id,key)
    if not valid or not empty(v) then return false end
  end
  for _,key in ipairs(scalars) do
    local v,valid=read(db,id,key)
    if not valid or v~=0 then return false end
  end
  return true
end
local function starterExists(value)
  if type(value)~="table" then return false end
  -- {npcIds, objectIds, itemIds}; only NPC starter for conservative first pass.
  if type(value[1])~="table" then return false end
  for _,id in ipairs(value[1]) do
    if number(id,1,10000000) then return true end
  end
  return false
end

function WC:DiscoverQuests(limit)
  if not self.IsWarrior or not self:IsWarrior()
      or type(UnitFactionGroup)~="function"
      or type(UnitRace)~="function"
      or type(UnitLevel)~="function" then
    return nil,"Personnage guerrier Horde illisible"
  end
  local okFaction, faction = pcall(UnitFactionGroup,"player")
  local okRace, _, _, raceId = pcall(UnitRace,"player")
  local okLevel, level = pcall(UnitLevel,"player")
  if not okFaction or faction~="Horde" or not okRace
      or not number(raceId,1,999) or not okLevel
      or not number(level,1,60) then
    return nil,"Faction, race ou niveau non confirmes"
  end
  local lib = _G and _G.LibQuestieDB
  if type(lib)~="table" or type(lib.RequireContract)~="function"
      or type(lib.Quest)~="table" or type(lib.Quest.Get)~="function"
      or type(lib.Quest.GetAllIds)~="function"
      or type(lib.Enum)~="table" or type(lib.Enum.raceMaskById)~="table"
      or type(lib.Enum.classKeys)~="table"
      or type(lib.Enum.factionRaceMasks)~="table" then
    return nil,"QuestieDB public indisponible"
  end
  local contractOK, supported = pcall(lib.RequireContract,4)
  if not contractOK or supported~=true then return nil,"Contrat QuestieDB v4 incompatible" end
  local raceMask=lib.Enum.raceMaskById[raceId]
  local warriorMask=lib.Enum.classKeys.WARRIOR
  local hordeMask=lib.Enum.factionRaceMasks.Horde
  if not number(raceMask,1,9007199254740991)
      or not number(warriorMask,1,9007199254740991)
      or not number(hordeMask,1,9007199254740991)
      or not hasBit(hordeMask,raceMask) then
    return nil,"Masque Horde ou classe non verifiable"
  end
  local questApi=C_QuestLog
  if type(questApi)~="table"
      or type(questApi.IsQuestFlaggedCompleted)~="function" then
    return nil,"Etat des quetes terminees non verifiable"
  end
  -- L'état du journal est indispensable pour exclure les quetes acceptees.
  local accepted=self.questAdvice
  if not accepted or accepted.reason then return nil,"Journal des quetes indisponible" end
  local active={}
  for _,row in ipairs(accepted.rows) do
    if number(row.id,1,10000000) then active[row.id]=true end
  end
  local listOK, ids=pcall(lib.Quest.GetAllIds)
  if not listOK or type(ids)~="table" or #ids>MAX_IDS then
    return nil,"Liste QuestieDB indisponible ou trop importante"
  end
  local result={}
  local examined=0
  for _,id in ipairs(ids) do
    examined=examined+1
    if examined>MAX_IDS then break end
    if number(id,1,10000000) and not active[id]
        and not dangerousQuest(id,questApi) then
      local required, reqOK=read(lib.Quest,id,"requiredLevel")
      local qLevel, lvlOK=read(lib.Quest,id,"questLevel")
      if reqOK and lvlOK and number(required,1,60)
          and number(qLevel,1,60) and required<=level
          and qLevel>=math.max(1,level-6) and qLevel<=level then
        local races,racesOK=read(lib.Quest,id,"requiredRaces")
        local classes,classesOK=read(lib.Quest,id,"requiredClasses")
        if racesOK and classesOK
            and number(races,0,9007199254740991)
            and number(classes,0,9007199254740991)
            and (races==0 or hasBit(races,raceMask))
            and (classes==0 or hasBit(classes,warriorMask))
            and noConditions(lib.Quest,id) then
          local starters,starterOK=read(lib.Quest,id,"startedBy")
          local name,nameOK=read(lib.Quest,id,"name")
          if starterOK and starterExists(starters)
              and nameOK and type(name)=="string" and name~=""
              and #name<=150 then
            local doneOK,done=pcall(questApi.IsQuestFlaggedCompleted,id)
            if doneOK and done==false then
              result[#result+1]={
                id=id,name=name,level=qLevel,requiredLevel=required,
                distance=math.abs(qLevel-(level-2))
              }
            end
          end
        end
      end
    end
  end
  table.sort(result,function(a,b)
    if a.distance~=b.distance then return a.distance<b.distance end
    if a.level~=b.level then return a.level<b.level end
    return a.id<b.id
  end)
  local maxRows=MAX_RESULTS
  if type(limit)=="number" and limit==math.floor(limit) and limit>=1 and limit<=40 then
    maxRows=limit
  end
  local top={}
  for i=1,math.min(maxRows,#result) do top[i]=result[i] end
  return {rows=top,matched=#result,level=level,scanned=examined},nil
end

function WC:ShowQuestDiscovery()
  -- Uniquement commande explicite : ne pas parcourir des milliers de fiches
  -- QuestieDB au login, a chaque refresh, ou pendant un combat.
  if self.inCombat then
    self:Print("Recherche de quetes disponible hors combat.")
    return
  end
  self:UpdateQuestAdvice()
  local result,reason=self:DiscoverQuests()
  if not result then
    self:Print("Quetes a decouvrir : indisponible ("..tostring(reason)..").")
    return
  end
  self:Print("QuestieDB : "..tostring(result.matched)..
    " piste(s) filtrees, "..tostring(result.scanned).." fiches examinees ; "..
    "top "..tostring(#result.rows).." au niveau "..tostring(result.level)..".")
  if #result.rows==0 then self:Print("Aucune piste suffisamment documentee.") end
  for _,row in ipairs(result.rows) do
    self:Print("["..tostring(row.level).."] "..row.name..
      " (#"..tostring(row.id)..") : niveau requis "..tostring(row.requiredLevel)..
      ". Voir Questie pour la localisation, la disponibilite et la difficulte.")
  end
  self:Print("Candidats, pas quetes garanties solo/Horde exclusives. "..
    "Pre-requis complexes exclus ; niveau des ennemis, trajet et recompenses inconnus.")
end
