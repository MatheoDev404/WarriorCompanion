local _, WC = ...
-- Conseiller de quetes pour guerrier Furie Horde.
-- V0.6 : analyse uniquement les quetes presentes dans le journal du client.
-- Une quete acceptee est accessible au personnage, mais cela ne prouve pas
-- qu'elle soit exclusive a la Horde, ni que ses objectifs soient solo.
-- Aucune position, source, recompense, difficulte des ennemis ou XP/h inventee.
local MAX_ENTRIES, MAX_LEVEL = 100, 60
local DUNGEON = {[81]=true}
local RAID = {[62]=true,[82]=true,[83]=true,[88]=true,[89]=true}
local GROUP = {[1]=true}
local RISK = {[85]=true,[98]=true} -- Heroic, scenario : ne jamais traiter comme solo

local function readable(value, kind)
  if type(value) ~= kind then return false end
  if type(issecretvalue) == "function" then
    local ok, secret = pcall(issecretvalue, value)
    if not ok or secret then return false end
  end
  if kind == "number" then
    return value == value and value ~= math.huge and value ~= -math.huge
  end
  return true
end

local function integer(n, lo, hi)
  return readable(n,"number") and n == math.floor(n) and n >= lo and n <= hi
end

local function tagFor(api, id)
  if type(api.GetQuestTagInfo) ~= "function" then return "unknown" end
  local ok, tag = pcall(api.GetQuestTagInfo,id)
  if not ok or tag == nil then return "unknown" end
  if type(tag) ~= "table" then return "unknown" end
  local idValue = tag.tagID or tag.tagId
  if idValue ~= nil and not integer(idValue,0,999) then return "unknown" end
  if tag.isElite ~= nil and not readable(tag.isElite,"boolean") then return "unknown" end
  if tag.isElite then return "elite" end
  if DUNGEON[idValue] then return "dungeon" end
  if RAID[idValue] then return "raid" end
  if GROUP[idValue] then return "group" end
  if RISK[idValue] then return "special" end
  if idValue == 0 then return "normal" end
  if type(tag.tagName) == "string" then
    if not readable(tag.tagName,"string") then return "unknown" end
    local name = tag.tagName:lower()
    if name:find("dungeon",1,true) or name:find("donjon",1,true) then return "dungeon" end
    if name:find("raid",1,true) then return "raid" end
    if name:find("elite",1,true) or name:find("élite",1,true) then return "elite" end
    if name:find("group",1,true) or name:find("groupe",1,true) then return "group" end
  end
  -- Valeur connue mais non reconnue != preuve que la quete est solo.
  return "unknown"
end

local function classify(row, playerLevel)
  if row.complete then return "ready", 1000 end
  if row.failed then return "failed", -1000 end
  if row.type == "dungeon" or row.type == "raid"
      or row.type == "elite" or row.type == "group"
      or row.type == "special" or row.group then
    return "group", -20
  end
  if row.type ~= "normal" then return "unknown", 0 end
  local difference = row.level - playerLevel
  if difference >= 2 then return "hard", -10 end
  if difference >= 0 then return "caution", 20 end
  if difference >= -6 then return "solo-candidate", 100 + difference end
  return "low", 10
end

function WC:ScanQuestLog()
  -- Refuser de classer des quetes pour l'autre faction ou classe.
  if not self.IsWarrior or not self:IsWarrior() then
    return nil, "Classe guerrier non confirmee"
  end
  if type(UnitFactionGroup) ~= "function" then
    return nil, "Faction du joueur indisponible"
  end
  local factionOK, faction = pcall(UnitFactionGroup,"player")
  if not factionOK or not readable(faction,"string") or faction ~= "Horde" then
    return nil, "Conseils reserves a la Horde"
  end
  local api = C_QuestLog
  if type(api) ~= "table" or type(api.GetNumQuestLogEntries) ~= "function"
      or type(api.GetInfo) ~= "function" then
    return nil, "API de quetes C_QuestLog incomplete"
  end
  if type(UnitLevel) ~= "function" then return nil, "Niveau du personnage inaccessible" end
  local levelOK, level = pcall(UnitLevel,"player")
  if not levelOK or not integer(level,1,MAX_LEVEL) then
    return nil, "Niveau illisible"
  end
  local ok, count = pcall(api.GetNumQuestLogEntries)
  if not ok or not integer(count,0,MAX_ENTRIES) then
    return nil, "Taille du journal illisible"
  end
  local rows = {}
  for index=1,count do
    local entryOK, info = pcall(api.GetInfo,index)
    if not entryOK or type(info) ~= "table" then
      return nil, "Lecture du journal incomplete"
    end
    if not readable(info.isHeader,"boolean") then
      return nil, "Ligne du journal illisible"
    end
    if not info.isHeader then
      local id, title, questLevel = info.questID, info.title, info.level
      if not integer(id,1,10000000) or not readable(title,"string")
          or title == "" or not integer(questLevel,1,MAX_LEVEL) then
        return nil, "Metadonnees de quete indisponibles"
      end
      local completed = info.isComplete == 1 or info.isComplete == true
      local failed = info.isComplete == -1
      if info.isComplete ~= nil and info.isComplete ~= 1
          and info.isComplete ~= true and info.isComplete ~= 0
          and info.isComplete ~= false and info.isComplete ~= -1 then
        return nil, "Etat de quete illisible"
      end
      local group = false
      if info.suggestedGroup ~= nil then
        if not integer(info.suggestedGroup,0,40) then
          return nil, "Taille de groupe illisible"
        end
        group = info.suggestedGroup > 1
      end
      local row = {
        id=id, name=title, level=questLevel, complete=completed,
        failed=failed, group=group, type=tagFor(api,id)
      }
      row.category,row.score = classify(row,level)
      rows[#rows+1]=row
    end
  end
  table.sort(rows,function(a,b)
    if a.score ~= b.score then return a.score > b.score end
    if a.level ~= b.level then return a.level < b.level end
    return a.id < b.id
  end)
  return {rows=rows, level=level}
end

function WC:UpdateQuestAdvice()
  local snapshot,reason = self:ScanQuestLog()
  self.questAdvice = snapshot or {rows={},reason=reason}
  return snapshot ~= nil
end

function WC:QuestAdviceLines()
  local scan = self.questAdvice
  if not scan or scan.reason then
    return "Quetes : classement indisponible ("..
      tostring(scan and scan.reason or "non initialise")..")."
  end
  if #scan.rows == 0 then return "Aucune quete dans le journal." end
  local counts = {ready=0,["solo-candidate"]=0,group=0,hard=0,unknown=0}
  for _,row in ipairs(scan.rows) do
    if counts[row.category] ~= nil then counts[row.category]=counts[row.category]+1 end
  end
  local lines={"Quetes du journal au niveau "..tostring(scan.level)..
    " | terminees : "..counts.ready..
    " | solo prudentes : "..counts["solo-candidate"]..
    " | groupe/donjon : "..counts.group..
    " | difficiles : "..counts.hard..
    " | incertaines : "..counts.unknown}
  local labels={
    ready="A rendre",["solo-candidate"]="Candidat solo",
    caution="Proche du niveau - prudence",hard="Trop haute pour un guerrier prudent",
    group="Groupe/donjon/elite - ne pas soloter",low="Bas niveau - XP a verifier",
    unknown="Difficulte non verifiee",failed="Echouee"
  }
  for i=1,math.min(5,#scan.rows) do
    local row=scan.rows[i]
    lines[#lines+1]="["..tostring(row.level).."] "..row.name..
      " (#"..tostring(row.id)..") - "..labels[row.category]
  end
  lines[#lines+1]="Journal du joueur Horde, pas preuve de quete Horde-exclusive. "..
    "Niveau de quete != niveau des ennemis; temps et recompenses inconnus."
  return table.concat(lines,"\n")
end

function WC:ShowQuestAdvice()
  for line in self:QuestAdviceLines():gmatch("[^\n]+") do self:Print(line) end
end

function WC:AddQuestAdvice(items)
  if type(items) ~= "table" or self.inCombat
      or not self.IsWarrior or not self:IsWarrior() then return end
  local snapshot=self.questAdvice
  if not snapshot or snapshot.reason then return end
  for _,row in ipairs(snapshot.rows) do
    if row.category=="ready" then
      items[#items+1]={id="quest-ready",priority="info",
        message="Quete prete a rendre : "..row.name..
          " (niveau "..tostring(row.level).."). Verifie le lieu de remise."}
      return
    end
  end
  for _,row in ipairs(snapshot.rows) do
    if row.category=="solo-candidate" then
      items[#items+1]={id="quest-solo",priority="info",
        message="Piste prudente du journal : "..row.name..
          " (quete niveau "..tostring(row.level).."). "..
          "Verifie le niveau reel des ennemis, les objectifs et les risques avant de partir."}
      return
    end
  end
end
