local _, WC = ...
-- Etat des points de talents via C_ClassTalents.
-- Les changements detectes ne prouvent pas le nom du talent choisi :
-- respecialisation et mises a jour serveur peuvent aussi modifier les compteurs.
local function validPoints(n)
  if type(n) ~= "number" or n ~= math.floor(n) or n < 0 or n > 120 then
    return false
  end
  if type(issecretvalue) == "function" then
    local ok, secret = pcall(issecretvalue, n)
    if not ok or secret then return false end
  end
  return true
end

function WC:ReadTalentPoints()
  local api = C_ClassTalents and C_ClassTalents.HasUnspentTalentPoints
  if type(api) ~= "function" then return nil, "API de talents absente" end
  local ok, has, class, spec = pcall(api)
  if not ok then return nil, "API de talents inaccessible" end
  if type(issecretvalue) == "function" then
    local verified, hidden = pcall(issecretvalue, has)
    if not verified or hidden then return nil, "Etat de talents protege" end
  end
  if type(has) ~= "boolean" or not validPoints(class)
      or not validPoints(spec) then return nil, "Valeurs de talents illisibles" end
  local total = class + spec
  if (has and total == 0) or (not has and total > 0) then
    return nil, "Compteurs de talents incoherents"
  end
  return {total=total,class=class,spec=spec}, nil
end

function WC:InitTalentObserver()
  self.talentState = {points=nil,reason=nil,changes=0,lastChange=nil}
  self:ObserveTalents(false)
end

function WC:ObserveTalents(record)
  if not self.talentState then
    self.talentState = {points=nil,changes=0}
  end
  local state=self.talentState
  local points,reason=self:ReadTalentPoints()
  if not points then
    state.points=nil
    state.reason=reason
    return false
  end
  local prior=state.points
  state.points=points
  state.reason=nil
  if record and prior and prior.total~=points.total then
    state.changes=state.changes+1
    state.lastChange={before=prior.total,after=points.total}
    if self.AddActivity then
      self:AddActivity("talents",
        "Points de talent disponibles : "..tostring(prior.total)..
        " -> "..tostring(points.total),true)
    end
  end
  return true
end

function WC:ShowTalentStatus()
  local state=self.talentState
  if not state or not state.points then
    self:Print("Talents : indisponibles (" ..
      tostring(state and state.reason or "non initialise") .. ").")
    return
  end
  local p=state.points
  self:Print("Talents : "..tostring(p.total).." point(s) non depense(s)."..
    " Classe : "..tostring(p.class)..", specialisation : "..tostring(p.spec)..".")
  self:Print("Changements observes : "..tostring(state.changes or 0)..
    ". Aucun talent precis ni arbre Furie detecte.")
end
