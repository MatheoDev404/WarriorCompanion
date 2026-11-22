local _, WC = ...
-- Lecture en consultation seule des talents reels du client Forever (C_Traits).
-- Aucune depense de points / modification de configuration.
-- Les rangs et noms restent inconnus si l'API ou une association est ambigue.
local ALIASES={
  ["Cruelty"]={"Cruaute","Cruauté","Cruelty"},
  ["Unbridled Wrath"]={"Colere dechainee","Colère déchaînée","Rage debridee","Unbridled Wrath"},
  ["Furious Precision"]={"Precision furieuse","Précision furieuse","Furious Precision"},
  ["Enrage"]={"Enrager","Enrage"},
  ["Dual Wield Specialization"]={"Specialisation Ambidextrie","Spécialisation Ambidextrie","Dual Wield Specialization"},
  ["Death Wish"]={"Souhait mortel","Death Wish"},
  ["Reckless Swings"]={"Coups dechaines","Coups déchaînés","Coups imprudents","Reckless Swings"},
  ["Flurry"]={"Rafale","Flurry"},
  ["Improved Whirlwind"]={"Tourbillon ameliore","Tourbillon amélioré","Improved Whirlwind"},
  ["Bloodthirst"]={"Sanguinaire","Bloodthirst"},
  ["Blood Craze"]={"Folie sanguinaire","Blood Craze"},
  ["Gore Drinker"]={"Tripes desalterantes","Tripes désaltérantes","Buveur de sang","Gore Drinker"},
  ["Improved Berserker Rage"]={"Rage berserker amelioree","Rage berserker améliorée","Improved Berserker Rage"},
  ["Improved Execute"]={"Execution amelioree","Exécution améliorée","Improved Execute"},
  ["Lingering Rage"]={"Rage remanente","Rage rémanente","Rage persistante","Lingering Rage"},
  ["Piercing Howl"]={"Hurlement percant","Hurlement perçant","Piercing Howl"},
  ["Improved Intercept"]={"Interception amelioree","Interception améliorée","Improved Intercept"},
  ["Booming Voice"]={"Voix tonitruante","Booming Voice"},
}
local function simple(s)
  if type(s)~="string" then return nil end
  s=s:lower()
  for from,to in pairs({["é"]="e",["è"]="e",["ê"]="e",["ë"]="e",
    ["à"]="a",["â"]="a",["î"]="i",["ï"]="i",
    ["ô"]="o",["ù"]="u",["û"]="u",["ç"]="c"}) do
    s=s:gsub(from,to)
  end
  s=s:gsub("[%s%p]+"," ")
  return s:match("^%s*(.-)%s*$")
end
local MATCH={}
for key,names in pairs(ALIASES) do
  for _,name in ipairs(names) do
    local normalized=simple(name)
    if MATCH[normalized] and MATCH[normalized]~=key then
      error("Alias de talents ambigu : "..name)
    end
    MATCH[normalized]=key
  end
end
local function safeNumber(n)
  if type(n)~="number" or n~=n or n<0 or n~=math.floor(n)
      or n>100000000 then return nil end
  if type(issecretvalue)=="function" then
    local ok,hidden=pcall(issecretvalue,n)
    if not ok or hidden then return nil end
  end
  return n
end
local function safeName(n)
  if type(n)~="string" or n=="" or #n>120 then return nil end
  if type(issecretvalue)=="function" then
    local ok,hidden=pcall(issecretvalue,n)
    if not ok or hidden then return nil end
  end
  return n
end
local function call(method,...)
  if type(method)~="function" then return nil end
  local ok,result=pcall(method,...)
  if ok then return result end
  return nil
end
local function configID()
  local specAPI=type(C_SpecializationInfo)=="table" and C_SpecializationInfo
  local group=specAPI and safeNumber(call(specAPI.GetActiveSpecGroup))
  if group==nil then return nil end
  local read=specAPI.GetCombatConfigIDForSpecGroup or
    _G.GetCombatConfigIDForSpecGroup
  return safeNumber(call(read,group))
end
local function extract()
  local traits=type(C_Traits)=="table" and C_Traits
  local id=traits and configID()
  if not id then return nil,"Configuration de talents non lisible" end
  local info=call(traits.GetConfigInfo,id)
  if type(info)~="table" or type(info.treeIDs)~="table" then
    return nil,"Arbres de talents indisponibles"
  end
  local found,all,unmatched,duplicate={},0,0,false
  for _,treeID in ipairs(info.treeIDs) do
    if not safeNumber(treeID) then return nil,"Identifiant d'arbre protege" end
    local nodes=call(traits.GetTreeNodes,treeID)
    if type(nodes)~="table" then return nil,"Noeuds de l'arbre indisponibles" end
    for _,nodeID in ipairs(nodes) do
      if not safeNumber(nodeID) then return nil,"Noeud protege" end
      local node=call(traits.GetNodeInfo,id,nodeID)
      if type(node)=="table" then
        local rank=safeNumber(node.activeRank)
        if rank==nil then rank=safeNumber(node.ranksPurchased) end
        local entries=node.entryIDs
        local entryID=(type(entries)=="table" and entries[1]) or node.activeEntry or node.activeEntryID
        if safeNumber(entryID) then
          local entry=call(traits.GetEntryInfo,id,entryID)
          local definition=type(entry)=="table" and safeNumber(entry.definitionID)
          local data=definition and call(traits.GetDefinitionInfo,definition)
          local spellID=type(data)=="table" and safeNumber(data.spellID)
          local name=spellID and type(C_Spell)=="table" and
            safeName(call(C_Spell.GetSpellName,spellID))
          if not name and spellID and type(C_Spell)=="table" then
            local spell=call(C_Spell.GetSpellInfo,spellID)
            if type(spell)=="table" then name=safeName(spell.name) end
          end
          if name then
            local key=MATCH[simple(name)]
            if key then
              if found[key] then duplicate=true
              elseif rank and rank<=10 then
                found[key]={name=name,rank=rank,spellID=spellID,
                  nodeID=nodeID}
              end
            else
              unmatched=unmatched+1
            end
          end
        end
      end
      all=all+1
      if all>250 then return nil,"Arbre anormalement grand" end
    end
  end
  if duplicate then return nil,"Talents portant des noms ambigus" end
  local count=0
  for _ in pairs(found) do count=count+1 end
  if count==0 then return nil,"Aucun talent Furie reconnu" end
  return {talents=found,count=count,complete=count==18,
    unmatched=unmatched,configID=id},nil
end
function WC:ReadLiveFuryTalents()
  return extract()
end
function WC:ObserveLiveFuryTalents()
  local snapshot,reason=self:ReadLiveFuryTalents()
  self.liveFuryTalents=snapshot
  self.liveFuryReason=reason
  return snapshot~=nil
end
function WC:LiveFuryTalent(key)
  local found=self.liveFuryTalents and self.liveFuryTalents.talents
  return found and found[key] or nil
end
