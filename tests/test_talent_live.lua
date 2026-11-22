-- Lecture de noms localises et de rangs actifs via C_Traits.
local nodes={100,101,102,103}
local entries={
  [100]={entry=201,spell=301,name="Cruauté",rank=5},
  [101]={entry=202,spell=302,name="Colère déchaînée",rank=4},
  [102]={entry=203,spell=303,name="Sanguinaire",rank=1},
  [103]={entry=204,spell=304,name="Nom non reference",rank=0},
}
local fail=false
local secret=987654
function issecretvalue(v) return v==secret end
C_SpecializationInfo={
  GetActiveSpecGroup=function()return 1 end,
  GetCombatConfigIDForSpecGroup=function(group)
    assert(group==1)
    return fail and nil or 900
  end,
}
C_Traits={
  GetConfigInfo=function(id)
    assert(id==900)
    return {treeIDs={888}}
  end,
  GetTreeNodes=function(id)
    assert(id==888)
    return nodes
  end,
  GetNodeInfo=function(id,node)
    local e=entries[node]
    return {entryIDs={e.entry},activeRank=e.rank}
  end,
  GetEntryInfo=function(id,entry)
    for _,e in pairs(entries) do
      if e.entry==entry then return {definitionID=e.spell} end
    end
  end,
  GetDefinitionInfo=function(id)return {spellID=id} end,
}
C_Spell={
  GetSpellName=function(id)
    for _,e in pairs(entries) do
      if e.spell==id then return e.name end
    end
  end,
}
local WC={}
assert(loadfile("Addon/WarriorCompanion/TalentLive.lua"))("WarriorCompanion",WC)
local snapshot,reason=WC:ReadLiveFuryTalents()
assert(snapshot and reason==nil and snapshot.count==3 and not snapshot.complete)
assert(snapshot.talents["Cruelty"].rank==5)
assert(snapshot.talents["Unbridled Wrath"].rank==4)
assert(snapshot.talents["Bloodthirst"].rank==1)
assert(snapshot.talents["Cruelty"].name=="Cruauté","nom du client")
assert(WC:ObserveLiveFuryTalents())
assert(WC:LiveFuryTalent("Cruelty").rank==5)
assert(WC:LiveFuryTalent("Improved Whirlwind")==nil)
-- La lecture du rang actif ne doit pas etre remplacee par le rang en attente.
C_Traits.GetNodeInfo=function(id,node)
  local e=entries[node]
  return {entryIDs={e.entry},activeRank=e.rank,ranksPurchased=9}
end
assert(WC:ReadLiveFuryTalents().talents["Cruelty"].rank==5)
-- Repli sur les rangs achetes seulement si activeRank n'est pas fourni.
C_Traits.GetNodeInfo=function(id,node)
  local e=entries[node]
  return {entryIDs={e.entry},ranksPurchased=e.rank}
end
assert(WC:ReadLiveFuryTalents().talents["Cruelty"].rank==5)
-- Un doublon de nom francais ne doit pas etre suppose fiable.
nodes[5]=104
entries[104]={entry=205,spell=305,name="Cruauté",rank=1}
assert(WC:ReadLiveFuryTalents()==nil)
nodes[5]=nil;entries[104]=nil
-- Une valeur protegee ou une API refusee annule le resultat.
C_SpecializationInfo.GetActiveSpecGroup=function()return secret end
assert(WC:ReadLiveFuryTalents()==nil)
C_SpecializationInfo.GetActiveSpecGroup=function()return 1 end
fail=true
assert(WC:ReadLiveFuryTalents()==nil)
fail=false
C_Traits.GetConfigInfo=function()error("API inaccessible") end
assert(WC:ReadLiveFuryTalents()==nil)
assert(not WC:ObserveLiveFuryTalents() and WC.liveFuryTalents==nil)
print("OK: C_Traits, noms francais, rangs actifs, cas partiels, secrets et API refusées")
