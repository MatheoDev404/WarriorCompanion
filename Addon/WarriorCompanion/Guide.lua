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
