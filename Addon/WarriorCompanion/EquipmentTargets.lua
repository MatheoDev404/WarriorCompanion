local _, WC = ...
-- Petit catalogue autonome de recompenses de quetes Horde documentees
-- pour WoW Classic / Forever. Des pistes a verifier, pas des gains simules.
-- Sources factuelles :
-- https://www.forever-xp.com/quests/6565/
-- https://foreverdb.net/fr/quest/2950-noggs-ring-redo
-- https://foreverchanges.pro/fr/quest/1848/brutal-hauberk
-- https://wowforever.gg/en/atlas/knowledge/quests/service-to-the-horde-q7541/
local TARGETS = {
  {id=17694, label="Anneau du poing", slot="anneau", min=17, max=36,
   quest=6565, level=28,
   source="Quete Allégeance aux Dieux tres anciens - Profondeurs de Brassenoire",
   risk="DONJON / groupe"},
  {id=9588, label="Anneau d'or de Nogg", slot="anneau", min=28, max=46,
   quest=2950, level=35,
   source="Suite de quetes de l'anneau de Gnomeregan - Nogg, Orgrimmar",
   risk="DONJON / materiaux necessaires"},
  {id=18585, label="Anneau d'allegeance", slot="anneau", min=30, max=53,
   quest=7541, level=35,
   source="Suite Un service pour la Horde - Marecage d'Aprefange",
   risk="LONGUE SUITE DE QUETES"},
  {id=7133, label="Haubert de brutalite", slot="torse", min=20, max=39,
   quest=1848, level=30,
   source="Quete de classe guerrier Le haubert de brutalite - Horde",
   risk="SUITE DE CLASSE / combat a verifier"},
}
local function readable(n)
  if type(n)~="number" or n~=n or n==math.huge then return false end
  if type(issecretvalue)=="function" then
    local ok,hidden=pcall(issecretvalue,n)
    if not ok or hidden then return false end
  end
  return true
end
local function slotInfo(slot)
  if type(GetInventoryItemID)~="function" then return nil end
  local ok,id=pcall(GetInventoryItemID,"player",slot)
  if not ok or (id~=nil and not readable(id)) then return nil end
  if not id then return {empty=true} end
  if type(GetItemInfo)~="function" then return nil end
  local success,_,_,_,itemLevel=pcall(GetItemInfo,id)
  if not success or not readable(itemLevel) then return nil end
  return {id=id,level=itemLevel}
end
local function completed(quest)
  if type(C_QuestLog)~="table" or
     type(C_QuestLog.IsQuestFlaggedCompleted)~="function" then return false end
  local ok,value=pcall(C_QuestLog.IsQuestFlaggedCompleted,quest)
  return ok and value==true
end
local function nameOf(target)
  if type(GetItemInfo)=="function" then
    local ok,name,link=pcall(GetItemInfo,target.id)
    if ok and type(name)=="string" and name~="" then
      return type(link)=="string" and link or name
    end
  end
  return target.label
end
function WC:EquipmentQuestTargets(limit)
  if not self.IsWarrior or not self:IsWarrior() then return {} end
  if type(UnitLevel)~="function" then return {} end
  local ok,level=pcall(UnitLevel,"player")
  if not ok or not readable(level) then return {} end
  local ring1,ring2=slotInfo(11),slotInfo(12)
  local chest=slotInfo(5)
  local ring
  if ring1 and ring2 then
    if ring1.empty then ring=ring1
    elseif ring2.empty then ring=ring2
    elseif ring1.level<=ring2.level then ring=ring1
    else ring=ring2 end
  end
  local out={}
  for _,target in ipairs(TARGETS) do
    local current=target.slot=="anneau" and ring or chest
    if current and level>=target.min and level<=target.max
        and not completed(target.quest) and
        (current.empty or (current.level and current.level<target.level)) then
      out[#out+1]={
        name=nameOf(target),source=target.source,risk=target.risk,
        slot=target.slot,quest=target.quest,
        reason=current.empty and "emplacement vide" or
          "niveau objet plus eleve (statistiques a verifier)",
      }
    end
  end
  local capped={}
  for i=1,math.min(limit or 3,#out) do capped[i]=out[i] end
  return capped
end
