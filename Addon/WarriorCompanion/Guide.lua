local _, WC = ...
-- Affichage d'etapes de guides externes validates; aucun itineraire calcule.
-- Un pack est {id, title, source, steps={{text, questID?, action?}, ...}}.
-- Les textes et l'ordre viennent du guide source, pas de QuestieDB.
local function validPack(pack)
  if type(pack) ~= "table" or type(pack.id) ~= "string"
      or type(pack.title) ~= "string" or type(pack.source) ~= "string"
      or type(pack.steps) ~= "table" or #pack.steps == 0 then return false end
  if #pack.steps > 2000 then return false end
  for _, step in ipairs(pack.steps) do
    if type(step) ~= "table" or type(step.text) ~= "string"
        or step.text == "" or #step.text > 240 then return false end
  end
  return true
end

WC.guideCatalog = WC.guideCatalog or {}
WC.guideOrder = WC.guideOrder or {}

function WC:RegisterGuidePack(pack)
  if not validPack(pack) or self.guideCatalog[pack.id] then return false end
  self.guideCatalog[pack.id] = pack
  self.guideOrder[#self.guideOrder+1] = pack.id
  return true
end

function WC:GuideStart()
  if not self.guideOrder or #self.guideOrder == 0 then return false end
  local options = self:Profile()
  if options and type(options.guideProgress) == "table" then
    local saved = self.guideCatalog[options.guideProgress.id]
    if saved then return self:GuideLoad(saved) end
  end
  local level = nil
  if type(UnitLevel) == "function" then
    local ok, value = pcall(UnitLevel, "player")
    if ok and type(value) == "number" and value == math.floor(value)
      and value >= 1 and value <= 60 then level = value end
  end
  if not level then return false end
  -- Favorise la progression principale plutôt que la branche Silverpine 12-14.
  local candidate, previous
  for _, id in ipairs(self.guideOrder) do
    local pack = self.guideCatalog[id]
    if pack.primary and type(pack.minLevel) == "number"
        and type(pack.maxLevel) == "number" and pack.minLevel <= level then
      if not previous or pack.minLevel > previous.minLevel then previous = pack end
      if level < pack.maxLevel then
        candidate = pack
        break
      end
    end
  end
  -- Certaines sections publiees omettent une tranche de niveau : reprendre
  -- la plus recente plutot que fabriquer un itineraire pour ce niveau.
  candidate = candidate or previous
  if candidate then return self:GuideLoad(candidate) end
  return false
end

function WC:GuideLoad(pack)
  if not validPack(pack) then return false end
  self.activeGuide = pack
  local options = self.Profile and self:Profile()
  local saved = options and options.guideProgress
  if type(saved) == "table" and saved.id == pack.id
      and type(saved.index) == "number" and saved.index == math.floor(saved.index)
      and saved.index >= 1 and saved.index <= #pack.steps then
    self.guideIndex = saved.index
  else
    self.guideIndex = 1
  end
  if options then
    options.guideProgress = {id = pack.id, index = self.guideIndex}
  end
  return true
end

function WC:GuideMove(delta)
  if not self.activeGuide or (delta ~= -1 and delta ~= 1) then return false end
  if delta == 1 and self.guideIndex == #self.activeGuide.steps then
    local nextPack = self.guideCatalog and self.guideCatalog[self.activeGuide.nextID]
    if nextPack then return self:GuideLoad(nextPack) end
  end
  local index = math.max(1, math.min(#self.activeGuide.steps, (self.guideIndex or 1) + delta))
  self.guideIndex = index
  local options = self.Profile and self:Profile()
  if options then options.guideProgress = {id = self.activeGuide.id, index = index} end
  return true
end

-- Avancement conservateur : seules les etapes avec action et questID
-- explicites peuvent etre validees depuis le journal.
function WC:GuideAdvanceFromJournal()
  if not self.activeGuide or not self.guideIndex then return false end
  local step = self.activeGuide.steps[self.guideIndex]
  if type(step) ~= "table" or type(step.questID) ~= "number"
      or step.questID ~= math.floor(step.questID) or step.questID < 1 then
    return false
  end
  local action = step.action
  if action ~= "accept" and action ~= "complete" and action ~= "turnin" then
    return false
  end
  local active = self.questAdvice
  if type(active) ~= "table" or active.reason
      or type(active.rows) ~= "table" then return false end
  local found
  for _, row in ipairs(active.rows) do
    if row.id == step.questID then found = row; break end
  end
  local confirmed = false
  if action == "accept" then
    confirmed = found ~= nil
  elseif action == "complete" then
    confirmed = found ~= nil and found.complete == true
  else
    local api = C_QuestLog
    if type(api) ~= "table" or
        type(api.IsQuestFlaggedCompleted) ~= "function" then return false end
    local ok, done = pcall(api.IsQuestFlaggedCompleted, step.questID)
    confirmed = ok and done == true
  end
  if not confirmed then return false end
  if self.guideIndex >= #self.activeGuide.steps then
    return self.activeGuide.nextID ~= nil and self:GuideMove(1)
  end
  return self:GuideMove(1)
end

-- Traduction de l'action et nom officiel de quete si le client le fournit.
-- Ne jamais inventer une traduction de nom propre ou de PNJ.
local function localQuestTitle(self, id)
  if type(id) ~= "number" then return nil end
  if self.questAdvice and type(self.questAdvice.rows) == "table" then
    for _, row in ipairs(self.questAdvice.rows) do
      if row.id == id and type(row.name) == "string" and row.name ~= "" then
        return row.name
      end
    end
  end
  if type(C_QuestLog) == "table" and type(C_QuestLog.GetTitleForQuestID) == "function" then
    local ok, title = pcall(C_QuestLog.GetTitleForQuestID, id)
    if ok and type(title) == "string" and title ~= "" then return title end
  end
  return nil
end

local actionsFR = {
  accept = "Accepter",
  complete = "Faire les objectifs de",
  turnin = "Rendre",
}

local function readableStep(self, step)
  if step.questID and actionsFR[step.action] then
    local title = localQuestTitle(self, step.questID)
    if title then return actionsFR[step.action] .. " : " .. title end
  end
  -- Le texte de source reste visible si aucune traduction fiable n'existe.
  local value = step.text or ""
  value = value:gsub("^Talk to ", "Parler a ")
    :gsub("^Kill ", "Eliminer ")
    :gsub("^Loot ", "Ramasser ")
    :gsub("^Travel to ", "Aller a ")
    :gsub("^Go to ", "Aller a ")
    :gsub("^Get to ", "Rejoindre ")
    :gsub("^Accept ", "Accepter ")
    :gsub("^Turn in ", "Rendre ")
    :gsub("^Get the ", "Recuperer ")
  return value
end

local function shortLocation(step)
  if type(step.zone) ~= "string" or step.zone == "" then return nil end
  local place = step.zone
  if type(step.x) == "number" and type(step.y) == "number" then
    return place .. " (" .. math.floor(step.x + 0.5) .. ", " ..
      math.floor(step.y + 0.5) .. ")"
  end
  return place
end

function WC:GetGuideView()
  local guide = self.activeGuide
  if not guide then return nil end
  local i = math.max(1, math.min(#guide.steps, self.guideIndex or 1))
  local step = guide.steps[i]
  local nextStep = guide.steps[i + 1]
  local lines = {
    "|cffEBC487A FAIRE MAINTENANT|r",
    readableStep(self, step),
  }
  local location = shortLocation(step)
  if location then
    lines[#lines+1] = "|cffA0C8EEPosition source : " .. location .. "|r"
  else
    lines[#lines+1] = "|cffBB9999Position non precisee par le guide|r"
  end
  if nextStep then
    lines[#lines+1] = ""
    lines[#lines+1] = "|cffBAAA91ENSUITE :|r " .. readableStep(self, nextStep)
  end
  local area = guide.title or "Parcours Horde"
  return {
    title = area,
    status = "Etape "..i.."/"..#guide.steps.."  - Guide Horde 1-60",
    steps = table.concat(lines, "\n"),
  }
end
