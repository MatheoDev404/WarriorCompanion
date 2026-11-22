local _, WC = ...
-- Intégration optionnelle des seules API PUBLIQUES de Questie.
-- Questie conserve ses marqueurs, carte, coordonnées et base de quêtes.
-- Pas de lecture des tables internes ou de duplication de marqueurs.

function WC:QuestieStatus()
  local q = _G and _G.Questie
  local api = type(q)=="table" and q.API
  if type(api)~="table" then return "absent" end
  if api.isReady ~= true then return "loading" end
  return "ready"
end

function WC:BindQuestie()
  if self.questieBound then return end
  local q = _G and _G.Questie
  local api = type(q)=="table" and q.API
  if type(api)~="table" then return end
  if self.questiePending then return end
  local callback = function()
    local now = _G and _G.Questie
    if type(now)~="table" or type(now.API)~="table"
        or now.API.isReady~=true then return end
    self.questiePending=false
    if self.questieBound then return end
    self.questieBound=true
    if type(now.API.RegisterForQuestUpdates)=="function" then
      local ok=pcall(now.API.RegisterForQuestUpdates,function(questID)
        if type(questID)=="number" and questID>0
            and questID==math.floor(questID) then
          self:UpdateQuestAdvice()
          if self.ready and not self.inCombat then self:Refresh() end
        end
      end)
      self.questieUpdates=ok
    end
    self:UpdateQuestAdvice()
  end
  if api.isReady==true then callback()
  elseif type(api.RegisterOnReady)=="function" then
    self.questiePending=true
    local ok=pcall(api.RegisterOnReady, callback)
    if not ok then self.questiePending=false end
  end
end

function WC:ShowQuestieStatus()
  local status=self:QuestieStatus()
  if status=="ready" then
    self:Print("Questie pret : il gere marqueurs, carte et quetes.")
    self:Print(self.questieUpdates and
      "Mises a jour Questie recues via l'API publique." or
      "API de notification Questie absente : suivi par journal WoW.")
  elseif status=="loading" then
    self:Print("Questie charge mais pas encore pret.")
  else
    self:Print("Questie absent ou interface publique inaccessible. Journal WoW utilise.")
  end
  self:Print("Warrior Companion classe uniquement les quetes acceptees lues sur le client ; "..
    "pas de liste de quetes disponibles garantie ni de nouveaux marqueurs.")
end
