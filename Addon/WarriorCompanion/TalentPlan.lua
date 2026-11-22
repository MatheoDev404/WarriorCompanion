local _, WC = ...
-- Parcours 10-60 Guerrier Furie ambidextre, inspire d'un guide specifique Forever.
-- Attribution des donnees de progression : wowforeverclasses.com
-- https://wowforeverclasses.com/classes/warrior/fury/talents
-- Un point par niveau de 10 a 60. Pas de validation des rangs equipee
-- tant que l'API Forever pour les talents individuels n'est pas verifiee.
local GROUPS={
  {10,14,"fury","Cruaute","Cruelty",5},
  {15,19,"fury","Rage debridee","Unbridled Wrath",5},
  {20,22,"fury","Precision furieuse","Furious Precision",3},
  {23,24,"fury","Enrager","Enrage",5},
  {25,29,"fury","Specialisation Ambidextrie","Dual Wield Specialization",5},
  {30,30,"fury","Souhait mortel","Death Wish",1},
  {31,33,"fury","Enrager","Enrage",5},
  {34,34,"fury","Coups imprudents","Reckless Swings",1},
  {35,37,"fury","Rafale","Flurry",3},
  {38,39,"fury","Tourbillon ameliore","Improved Whirlwind",2},
  {40,40,"fury","Sanguinaire","Bloodthirst",1},
  {41,43,"fury","Folie sanguinaire","Blood Craze",3},
  {44,45,"fury","Buveur de sang","Gore Drinker",2},
  {46,47,"fury","Rage berserker amelioree","Improved Berserker Rage",2},
  {48,49,"fury","Execution amelioree","Improved Execute",2},
  {50,54,"fury","Rage persistante","Lingering Rage",5},
  {55,55,"fury","Hurlement percant","Piercing Howl",1},
  {56,57,"fury","Interception amelioree","Improved Intercept",2},
  {58,60,"fury","Voix tonitruante","Booming Voice",5},
}
local ORDER={}
local TALENTS={}
local function key(name) return name end
for _,g in ipairs(GROUPS) do
  local talent=key(g[5])
  if not TALENTS[talent] then
    TALENTS[talent]={nameFR=g[4],nameEN=g[5],tree=g[3],max=g[6]}
  end
  for level=g[1],g[2] do
    local rank=0
    for l=10,level-1 do
      if ORDER[l] and ORDER[l].key==talent then rank=rank+1 end
    end
    ORDER[level]={level=level,key=talent,rank=rank+1}
  end
end
-- Grille visuelle des talents Furie (paliers verifies pour Forever).
-- Les colonnes sont un rangement lisible dans Warrior Companion, non des
-- coordonnees officielles extraites de l'interface Blizzard.
local FURY_GRID={
  {"Booming Voice","Voix tonitruante",1,1},
  {"Cruelty","Cruaute",1,3},
  {"Lingering Rage","Rage persistante",2,1},
  {"Unbridled Wrath","Rage debridee",2,3},
  {"Furious Precision","Precision furieuse",3,1},
  {"Piercing Howl","Hurlement percant",3,2},
  {"Blood Craze","Folie sanguinaire",3,3},
  {"Enrage","Enrager",3,4},
  {"Dual Wield Specialization","Ambidextrie",4,1},
  {"Reckless Swings","Coups imprudents",4,2},
  {"Improved Execute","Execution amelioree",4,4},
  {"Improved Berserker Rage","Rage berserker",5,1},
  {"Death Wish","Souhait mortel",5,2},
  {"Gore Drinker","Buveur de sang",5,3},
  {"Improved Intercept","Interception",5,4},
  {"Improved Whirlwind","Tourbillon ameliore",6,1},
  {"Flurry","Rafale",6,3},
  {"Bloodthirst","Sanguinaire",7,2},
}
function WC:TalentTreeGrid(level)
  local plan=self:TalentPlanLevel(level)
  if not plan then return nil end
  local ranks={}
  for l=10,level do
    local point=ORDER[l]
    ranks[point.key]=(ranks[point.key] or 0)+1
  end
  local nodes={}
  for _,item in ipairs(FURY_GRID) do
    local meta=TALENTS[item[1]]
    -- Tous les talents de la grille figurent dans le parcours propose.
    local rank=ranks[item[1]] or 0
    nodes[#nodes+1]={
      key=item[1],label=item[2],row=item[3],column=item[4],
      rank=rank,maximum=meta.max,
      status=plan.current.english==item[1] and "current"
        or (rank>0 and "planned" or "future"),
    }
  end
  return nodes
end

WC.talentPlan=ORDER
function WC:TalentPlanLevel(level)
  if type(level)~="number" or level~=math.floor(level)
      or level<10 or level>60 then return nil end
  local current=ORDER[level]
  if not current then return nil end
  local ranks,treePoints={}, {arms=0,fury=0,protection=0}
  for l=10,level do
    local item=ORDER[l]
    if item then
      ranks[item.key]=(ranks[item.key] or 0)+1
      treePoints[TALENTS[item.key].tree]=treePoints[TALENTS[item.key].tree]+1
    end
  end
  local talent=TALENTS[current.key]
  local nextStep=ORDER[level+1]
  local nextTalent=nextStep and TALENTS[nextStep.key] or nil
  local unspent=self.talentState and self.talentState.points
  local free=unspent and unspent.total
  if type(free)~="number" or free<0 then free=nil end
  local recent={}
  local seen={}
  for l=level,10,-1 do
    local item=ORDER[l]
    if item and not seen[item.key] then
      seen[item.key]=true
      local meta=TALENTS[item.key]
      recent[#recent+1]={
        name=meta.nameFR, english=meta.nameEN,
        rank=ranks[item.key], maximum=meta.max, tree=meta.tree,
        current=item.key==current.key
      }
    end
    if #recent>=7 then break end
  end
  return {
    level=level,total=level-9,treePoints=treePoints,
    current={name=talent.nameFR,english=talent.nameEN,
      rank=current.rank,maximum=talent.max,tree=talent.tree},
    next=nextStep and {
      level=nextStep.level,name=nextTalent.nameFR,
      rank=nextStep.rank,maximum=nextTalent.max,
    } or nil,
    unspent=free,recent=recent,
    checked=false, -- le nombre de points libres ne prouve pas les rangs.
  }
end
function WC:CurrentTalentPlanLevel()
  local level
  if type(UnitLevel)=="function" then
    local ok,n=pcall(UnitLevel,"player")
    if ok and type(n)=="number" and n==math.floor(n) then level=n end
  end
  if not level then return 10 end
  return math.max(10,math.min(60,level))
end
function WC:SetTalentPlanLevel(level)
  if not self:TalentPlanLevel(level) then return false end
  self.talentPlanSelection=level
  return true
end
function WC:TalentPlanText()
  local level=self.talentPlanSelection or self:CurrentTalentPlanLevel()
  local plan=self:TalentPlanLevel(level)
  if not plan then return nil end
  local rows={}
  for i=1,#plan.recent do
    local t=plan.recent[i]
    local marker=t.current and "|cff73D394> |r" or "  "
    rows[#rows+1]=marker..t.name.."   "..t.rank.."/"..t.maximum
  end
  local upcoming={}
  for l=level+1,math.min(60,level+5) do
    local point=ORDER[l]
    local talent=TALENTS[point.key]
    upcoming[#upcoming+1]="Niv. "..l.."   "..talent.nameFR..
      "  "..point.rank.."/"..talent.max
  end
  return {
    plan=plan,
    upcoming=#upcoming>0 and table.concat(upcoming,"\n") or
      "Tous les points du parcours ont ete places.",
    current="Niv. "..level.."  |  "..plan.current.name.."  "..
      plan.current.rank.."/"..plan.current.maximum,
    next=plan.next and
      ("Niv. "..plan.next.level.." : "..plan.next.name.." "..
       plan.next.rank.."/"..plan.next.maximum) or "Parcours termine au niveau 60",
    distribution="Armes "..plan.treePoints.arms..
      "  /  Furie "..plan.treePoints.fury..
      "  /  Protection "..plan.treePoints.protection,
    recent=table.concat(rows,"\n"),
    notice=(plan.unspent~=nil and
      ("Points disponibles : "..plan.unspent.."  |  ") or "")..
      "Ordre conseille - rangs en jeu non verifies",
  }
end
