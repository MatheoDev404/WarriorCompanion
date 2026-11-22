local _, WC = ...
local history = {}
local maxEntries = 100

function WC:Print(message)
  local t = "|cff80caff[Warrior Companion]|r " .. tostring(message)
  if DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.AddMessage then
    DEFAULT_CHAT_FRAME:AddMessage(t)
  elseif type(print) == "function" then print(t) end
end

function WC:Trace(category, message)
  if not self:Profile().debug then return end
  history[#history + 1] = {
    time = self:Now(), category = tostring(category), message = tostring(message)
  }
  if #history > maxEntries then table.remove(history, 1) end
end

function WC:ClearLogs()
  for i = #history, 1, -1 do history[i] = nil end
end

function WC:ShowLogs()
  if #history == 0 then self:Print("Aucune trace disponible."); return end
  local first = math.max(1, #history - 14)
  for i = first, #history do
    local e = history[i]
    self:Print(string.format("[%.0f] %s: %s", e.time, e.category, e.message))
  end
end

function WC:Status()
  local xp = self:XPPerHour()
  self:Print("v" .. self.version .. " | XP: " .. self.metrics.xpGained ..
    " | XP/h: " .. (xp and tostring(xp) or "attente") ..
    " | morts: " .. self.metrics.deaths)
  local checks = {
    {"XP", UnitXP}, {"Niveau", UnitLevel},
    {"Talents", GetUnspentTalentPoints}, {"Quetes", GetNumQuestLogEntries},
    {"Argent", GetMoney}
  }
  for _, check in ipairs(checks) do
    self:Print(check[1] .. ": " .. (type(check[2]) == "function" and "API presente" or "API absente"))
  end
  self:Print("Debug " .. (self:Profile().debug and "ON" or "OFF") ..
    " | alertes " .. (self:Profile().showAlerts and "ON" or "OFF") ..
    " | traces " .. #history)
end
