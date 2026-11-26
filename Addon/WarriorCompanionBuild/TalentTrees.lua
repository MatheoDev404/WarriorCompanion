local addon,B=...
-- Donnees Warcraft Forever, War 1.60.1.70938.
-- Zephras: https://zephras.com/data/ (CC BY 4.0 pour la disposition)
-- Les traductions francaises courtes ci-dessous sont indicatives.
-- Le client fournit les noms et descriptions localises en priorite.
local function node(name,row,col,maxRank,spell,icon,fr,hint)
  return {name,row,col,maxRank,spell,icon,fr,hint}
end
B.talentTrees={
  ["Armes"]={
    node("Improved Heroic Strike",1,1,3,12282,132282,
      "Frappe heroique amelioree","Reduit le cout en rage de Frappe heroique."),
    node("Deflection",1,2,5,16462,132269,
      "Deviation","Augmente la chance de parer."),
    node("Improved Rend",1,3,3,12286,132155,
      "Pourfendre ameliore","Augmente les degats de saignement de Pourfendre."),
    node("Improved Charge",2,1,2,12285,132337,
      "Charge amelioree","Genere davantage de rage avec Charge."),
    node("Improved Tactical Mastery",2,2,3,12295,136031,
      "Maitrise tactique amelioree","Conserve plus de rage en changeant de posture."),
    node("Improved Overpower",2,4,2,12290,135275,
      "Fulgurance amelioree","Augmente les chances de critique de Fulgurance."),
    node("Anger Management",3,2,1,12296,135881,
      "Maitrise de la colere","Genere de la rage au combat et reduit sa perte hors combat."),
    node("Deep Wounds",3,3,3,12834,132090,
      "Blessures profondes","Les coups critiques provoquent un saignement."),
    node("Spearing Strike",4,1,1,1310222,135124,
      "Frappe perforante","Attaque puissante contre certaines familles d'ennemis."),
    node("Two-Handed Weapon Specialization",4,2,3,12163,132400,
      "Specialisation armes a deux mains","Augmente les degats des armes a deux mains."),
    node("Impale",4,3,2,16493,132312,
      "Empaler","Augmente les degats bonus des coups critiques des techniques."),
    node("Bloodthrill",5,1,2,1289682,135271,
      "Exaltation sanguinaire","Pourfendre peut declencher Fulgurance."),
    node("Sweeping Strikes",5,2,1,12292,132306,
      "Attaques circulaires","Les attaques touchent une cible proche supplementaire."),
    node("Weaponmaster",5,3,5,1290261,1085608,
      "Maitre d'armes","Bonus selon le type d'arme utilise."),
    node("Improved Slam",6,1,2,12862,132340,
      "Heurt ameliore","Reduit recharge, incantation et GCD de Heurt."),
    node("Improved Hamstring",6,3,3,12289,132316,
      "Brise-genou ameliore","Chance d'immobiliser la cible."),
    node("Mortal Strike",7,2,1,12294,132355,
      "Frappe mortelle","Attaque infligeant des degats et reduisant les soins recus."),
  },
  ["Furie"]=B.talents,
  ["Protection"]={
    node("Improved Bloodrage",1,1,2,12301,132277,
      "Rage sanguinaire amelioree","Augmente la rage generee par Rage sanguinaire."),
    node("Shield Specialization",1,2,5,12298,134952,
      "Specialisation Bouclier","Augmente les chances de blocage et genere de la rage."),
    node("Iron Will",1,3,5,12962,135995,
      "Volonte de fer","Reduit la duree des etourdissements et peurs."),
    node("Anticipation",2,1,5,12297,136056,
      "Anticipation","Augmente la competence Defense."),
    node("Improved Revenge",2,3,3,12797,132353,
      "Vengeance amelioree","Augmente les degats de Vengeance."),
    node("Improved Thunder Clap",2,4,3,12287,132326,
      "Coup de tonnerre ameliore","Reduit le cout de Coup de tonnerre."),
    node("Last Stand",3,1,1,12975,135871,
      "Dernier rempart","Augmente temporairement les points de vie maximum."),
    node("Master of Defense",3,2,2,1310316,132359,
      "Maitre de la defense","Chance de generer de la rage sur esquive/parade avec bouclier."),
    node("Improved Disarm",3,3,3,12313,132343,
      "Desarmement ameliore","Reduit la recharge de Desarmement."),
    node("Defiance",3,4,3,12792,132347,
      "Defiance","Augmente la menace en posture defensive avec bouclier."),
    node("Improved Sunder Armor",4,1,3,12308,132363,
      "Fracasser armure ameliore","Reduit le cout de Fracasser armure."),
    node("Vanguard",4,2,1,1310317,4667427,
      "Avant-garde","Permet Charge en posture defensive."),
    node("Improved Shield Bash",4,3,2,12311,132357,
      "Coup de bouclier ameliore","Chance d'appliquer Silence sur Coup de bouclier."),
    node("Improved Shield Wall",5,1,2,12312,132362,
      "Mur protecteur ameliore","Reduit la recharge de Mur protecteur."),
    node("Concussion Blow",5,2,1,12809,132325,
      "Bourrasque","Etourdit la cible pendant 5 secondes."),
    node("Focused Rage",5,3,3,29787,132345,
      "Rage focalisee","Reduit le cout en rage des techniques offensives."),
    node("Bastion",6,3,5,16538,134950,
      "Bastion","Augmente les degats tant qu'un bouclier est equipe."),
    node("Shield Slam",7,2,1,23922,134951,
      "Heurt de bouclier","Frappe au bouclier, provoque de la menace."),
  },
}
B.talentTreeOrder={"Armes","Furie","Protection"}
-- Identifiants nommes par arbre. Garder les fleches dans les donnees pour
-- recharger un pack client different sans toucher au moteur de rendu.
B.talentArrows={
  ["Armes"]={
    {"Improved Rend","Deep Wounds"},
    {"Improved Tactical Mastery","Anger Management"},
    {"Deep Wounds","Impale"},
    {"Sweeping Strikes","Mortal Strike"},
  },
  ["Furie"]={
    {"Blood Craze","Gore Drinker"},
    {"Death Wish","Bloodthirst"},
  },
  ["Protection"]={
    {"Shield Specialization","Master of Defense"},
    {"Concussion Blow","Shield Slam"},
  },
}
B.talentDependencies["Deep Wounds"]={"Improved Rend",3}
B.talentDependencies["Anger Management"]={"Improved Tactical Mastery",3}
B.talentDependencies["Impale"]={"Deep Wounds",3}
B.talentDependencies["Mortal Strike"]={"Sweeping Strikes",1}
B.talentDependencies["Master of Defense"]={"Shield Specialization",5}
B.talentDependencies["Shield Slam"]={"Concussion Blow",1}
-- Variante de comparaison, PAS un build valide comme meilleur DPS.
-- 38 points Furie jusqu'au niveau 47, puis 13 points Armes.
-- Le controle de paliers et de prerequis est fait par Planner.lua.
B.talentPlans={["fury"]=B.talentBlocks,["hybrid"]={}}
for _,block in ipairs(B.talentBlocks) do
  if block[2]<=47 then
    B.talentPlans.hybrid[#B.talentPlans.hybrid+1]=
      {block[1],block[2],block[3],"Furie"}
  end
end
for _,block in ipairs({
  {48,52,"Deflection","Armes"},
  {53,55,"Improved Rend","Armes"},
  {56,57,"Improved Tactical Mastery","Armes"},
  {58,60,"Deep Wounds","Armes"},
}) do
  B.talentPlans.hybrid[#B.talentPlans.hybrid+1]=block
end
B.talentPlanLabels={
  fury="Furie pure (0/51/0)",
  hybrid="Armes/Furie (13/38/0) - experimental",
}
function B:TreeForTalent(key)
  for _,tree in ipairs(self.talentTreeOrder) do
    for _,n in ipairs(self.talentTrees[tree]) do
      if n[1]==key then return tree end
    end
  end
  return nil
end
function B:TalentMetadata()
  local result={}
  for _,tree in ipairs(self.talentTreeOrder) do
    for _,n in ipairs(self.talentTrees[tree]) do
      result[n[1]]=n
    end
  end
  return result
end
