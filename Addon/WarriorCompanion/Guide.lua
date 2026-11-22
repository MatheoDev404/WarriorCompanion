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
  return true
end

function WC:GuideMove(delta)
  if not self.activeGuide or (delta ~= -1 and delta ~= 1) then return false end
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
  if not confirmed or self.guideIndex >= #self.activeGuide.steps then
    return false
  end
  return self:GuideMove(1)
end

function WC:GetGuideView()
  local guide = self.activeGuide
  if not guide then return nil end
  local i = math.max(1, math.min(#guide.steps, self.guideIndex or 1))
  local lines = {}
  for n = math.max(1,i-1),math.min(#guide.steps,i+2) do
    local prefix = n < i and "  " or (n == i and "> " or "  ")
    local line = tostring(n)..". "..guide.steps[n].text
    if n == i then line = "|cffEBC487"..prefix..line.."|r"
    else line = prefix..line end
    lines[#lines+1] = line
  end
  return {
    title = guide.title,
    status = "Etape "..i.."/"..#guide.steps.."  |  Source : "..guide.source,
    steps = table.concat(lines, "\n\n"),
  }
end
