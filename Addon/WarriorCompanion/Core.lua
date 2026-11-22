local addonName, WC = ...
_G.WarriorCompanion = WC
WC.version = "0.1.0-dev"
WC.metrics = { xpGained = 0, deaths = 0, elapsed = 0, started = 0, lastXP = nil, lastXPMax = nil, lastLevel = nil }
WC.alerts = {}
WC.inCombat = false

function WC:Profile()
  WC_DB = WC_DB or {}
  WC_DB.options = WC_DB.options or { debug = false, showAlerts = true }
  return WC_DB.options
end

function WC:Now()
  return (GetTime and GetTime()) or 0
end

function WC:Refresh()
  if self.UpdateAdvice then self:UpdateAdvice() end
  if self.RefreshDashboard then self:RefreshDashboard() end
end

local frame = CreateFrame("Frame")
WC.eventFrame = frame
for _, event in ipairs({
  "PLAYER_LOGIN", "PLAYER_ENTERING_WORLD", "PLAYER_XP_UPDATE", "PLAYER_LEVEL_UP",
  "PLAYER_DEAD", "PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED",
  "PLAYER_EQUIPMENT_CHANGED", "PLAYER_TALENT_UPDATE"
}) do
  frame:RegisterEvent(event)
end

frame:SetScript("OnEvent", function(_, event, ...)
  if event == "PLAYER_LOGIN" then
    WC:Profile()
    WC.metrics.started = WC:Now()
    WC:InitObserver()
    WC:CreateDashboard()
    WC:Refresh()
  elseif event == "PLAYER_REGEN_DISABLED" then
    WC.inCombat = true
  elseif event == "PLAYER_REGEN_ENABLED" then
    WC.inCombat = false
    WC:Refresh()
  else
    if WC.OnObservedEvent then WC:OnObservedEvent(event, ...) end
    if not WC.inCombat then WC:Refresh() end
  end
end)

SLASH_WARRIORCOMPANION1 = "/wc"
SlashCmdList.WARRIORCOMPANION = function(msg)
  msg = (msg or ""):lower():match("^%s*(.-)%s*$")
  if msg == "debug on" then WC:Profile().debug = true; WC:Print("Debug actif")
  elseif msg == "debug off" then WC:Profile().debug = false; WC:Print("Debug inactif")
  elseif msg == "status" then WC:Status()
  elseif msg == "reset" then WC:ResetSession()
  elseif WC.ToggleDashboard then WC:ToggleDashboard() end
end
