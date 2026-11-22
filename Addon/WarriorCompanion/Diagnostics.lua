local _, WC = ...
local entries = {}
local maxEntries = 80

function WC:Print(message)
  local text = "|cff80caff[Warrior Companion]|r " .. tostring(message)
  if DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.AddMessage then
    DEFAULT_CHAT_FRAME:AddMessage(text)
  elseif print then
    print(text)
  end
end

function WC:Trace(category, message)
  if not self:Profile().debug then return end
  entries[#entries + 1] = {
    t = self:Now(),
    category = tostring(category),
    message = tostring(message)
  }
  if #entries > maxEntries then table.remove(entries, 1) end
end

function WC:Status()
  local xp = self:XPPerHour()
  self:Print("Version " .. self.version .. " | XP session : " ..
    tostring(self.metrics.xpGained) .. " | XP/h : " ..
    (xp and tostring(xp) or "calcul en attente") .. " | Morts : " ..
    tostring(self.metrics.deaths))
  self:Print("API niveau: " .. tostring(type(UnitLevel) == "function") ..
    " | XP: " .. tostring(type(UnitXP) == "function") ..
    " | Talents: " .. tostring(type(GetUnspentTalentPoints) == "function"))
  self:Print("Debug: " .. (self:Profile().debug and "ON" or "OFF") ..
    " | traces en memoire: " .. tostring(#entries))
  if self:Profile().debug then
    local start = math.max(1, #entries - 7)
    for i = start, #entries do
      local e = entries[i]
      self:Print(string.format("[%.0f] %s : %s", e.t, e.category, e.message))
    end
  end
end
