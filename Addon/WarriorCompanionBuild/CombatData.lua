local addon,B=...
-- Guide de combat Fury pour leveling, conditionnel aux sorts et talents.
-- Source: Wowhead / Icy Veins / Mobalytics Forever, 23 novembre 2026.
-- Les sections visuelles ne lancent jamais les sorts elles-memes.
-- {name, spellId, level, condition, talent?, maxLevel?}
B.combatGuide={
  mono={
    maintain={
      {"Cri de guerre",6673,1,"Maintenir le bonus de puissance d'attaque."},
    },
    opener={
      {"Charge",100,4,"Ouvrir hors combat sur une cible isolee."},
      {"Rage sanguinaire",2687,10,"HORS GCD : si rage insuffisante et PV suffisants (cout en sante)."},
    },
    cycle={
      {"Sanguinaire",23881,40,"Tourbillon et Sanguinaire sur leurs CD selon la rage.","Bloodthirst"},
      {"Tourbillon",1680,36,"A lancer si posture Berserker et rage suffisante."},
      {"Pourfendre",772,4,"En debut de combat sur ennemis qui vivent assez longtemps.",nil,35},
      {"Frappe heroique",78,1,"Uniquement en surplus de rage, pas en boucle permanente."},
    },
    reactive={
      {"Fulgurance",7384,12,"Apres esquive, passer en posture de combat si possible. GCD 1,5 s."},
      {"Ivresse de la victoire",34428,20,"Apres un ennemi tue : profiter de la fenetre avant expiration."},
      {"Execution",5308,24,"En dessous de 20% PV de la cible; coute toute la rage."},
    },
    offense={
      {"Souhait mortel",12328,30,"Sur ennemi durable et avec PV securises (+5% degats recus).","Death Wish"},
      {"Coups dechaines",1329555,34,"Gagne de la rage en consommant de la sante; eviter le cumul de couts.","Reckless Swings"},
    },
    defense={
      {"Cri d'intimidation",5246,22,"Interrompre une situation dangereuse, attention a la fuite des monstres."},
      {"Mur protecteur",871,28,"Necessite bouclier + posture defensive; temps de recharge important."},
    },
  },
  multi={
    maintain={
      {"Cri de guerre",6673,1,"Maintenir le bonus de puissance d'attaque."},
      {"Cri demoralisant",1160,14,"Reduire les degats physiques recus de plusieurs adversaires."},
    },
    opener={
      {"Charge",100,4,"Engager seulement un groupe maitrisable."},
      {"Rage sanguinaire",2687,10,"HORS GCD : si rage necessaire et PV securises."},
    },
    cycle={
      {"Tourbillon",1680,36,"Attaque de zone si posture et rage le permettent."},
      {"Enchainement",845,20,"Sur surplus de rage contre deux cibles."},
      {"Coup de tonnerre",6343,6,"En posture compatible, utile pour ralentir les attaques.",nil,35},
    },
    reactive={
      {"Ivresse de la victoire",34428,20,"Une cible vient de mourir : profiter de l'ouverture."},
      {"Execution",5308,24,"Finir vite une cible dangereuse si ses PV sont faibles."},
    },
    offense={
      {"Souhait mortel",12328,30,"Seulement si le groupe est controle et les PV suffisants.","Death Wish"},
      {"Coups dechaines",1329555,34,"Si besoin de rage, eviter sous forte pression de degats.","Reckless Swings"},
    },
    defense={
      {"Mur protecteur",871,28,"Bouclier + posture defensive, si risque majeur."},
      {"Cri d'intimidation",5246,22,"Sortie d'urgence, peut disperser les ennemis."},
    },
  },
}
-- Enchainement concret a memoriser; procs et CD sont volontairement a part.
function B:RotationCycleSummaryAt(level,mode)
  if type(level)~="number" then return nil end
  if mode=="multi" then
    if level>=36 then
      return "Boucle : Tourbillon > autos > Enchainement si rage en trop."
    elseif level>=20 then
      return "Boucle : autos > Enchainement si rage en trop."
    end
    return "Boucle : autos ; Coup de tonnerre si necessaire."
  end
  local plan=self:PlanAt(level)
  if level>=40 and plan and (plan.ranks["Bloodthirst"] or 0)>0 then
    return "Boucle : Sanguinaire > Tourbillon > autos ; selon rage et CD."
  elseif level>=36 then
    return "Boucle : Tourbillon > autos ; economiser la rage pour son CD."
  elseif level>=4 then
    return "Boucle : Pourfendre si combat long > autos ; Frappe heroique si surplus."
  end
  return "Boucle : autos ; Frappe heroique si surplus de rage."
end
function B:CombatSectionAt(level,mode,section)
  local modeData=self.combatGuide[mode]
  local list=modeData and modeData[section] or {}
  local result={}
  local plan=self:PlanAt(level)
  for _,entry in ipairs(list) do
    local requiredTalent=entry[5]
    if level>=entry[3] and (not entry[6] or level<=entry[6])
        and (not requiredTalent or
           (plan and (plan.ranks[requiredTalent] or 0)>0)) then
      result[#result+1]={
        name=entry[1],spellId=entry[2],level=entry[3],
        note=entry[4],talent=requiredTalent,
        section=section
      }
    end
  end
  return result
end
