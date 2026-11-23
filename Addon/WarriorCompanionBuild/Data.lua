local addon, B = ...
-- Donnees compactes de WoW Forever; travail de comparaison initial 23/11/2026.
-- Talents: Zephras (https://zephras.com/data/) CC BY 4.0 pour l'arrangement.
-- Noms, icones et sorts World of Warcraft © Blizzard Entertainment.
B.dataVersion="forever-1.60.1.70938"
-- key, row, col, max, spellId, iconFileDataID, libelle francais de repli
B.talents={
 {"Booming Voice",1,2,5,12321,136075,"Voix tonitruante"},
 {"Cruelty",1,3,5,12320,132292,"Cruaute"},
 {"Lingering Rage",2,2,5,1323964,132356,"Rage remanente"},
 {"Unbridled Wrath",2,3,5,12322,136097,"Colere dechainee"},
 {"Furious Precision",3,1,3,1323963,236309,"Precision furieuse"},
 {"Piercing Howl",3,2,1,12323,136147,"Hurlement percant"},
 {"Blood Craze",3,3,3,16487,136218,"Folie sanguinaire"},
 {"Enrage",3,4,5,12317,136224,"Enrager"},
 {"Dual Wield Specialization",4,1,5,23584,132147,"Specialisation Ambidextrie"},
 {"Reckless Swings",4,2,1,1329555,132334,"Coups dechaines"},
 {"Improved Execute",4,4,2,20502,135358,"Execution amelioree"},
 {"Improved Berserker Rage",5,1,2,20500,136009,"Rage berserker amelioree"},
 {"Death Wish",5,2,1,12328,136146,"Souhait mortel"},
 {"Gore Drinker",5,3,2,1323967,135727,"Tripes desalterantes"},
 {"Improved Intercept",5,4,2,20504,132307,"Interception amelioree"},
 {"Improved Whirlwind",6,1,2,1310315,132369,"Tourbillon ameliore"},
 {"Flurry",6,3,3,12319,132152,"Rafale"},
 {"Bloodthirst",7,2,1,23881,136012,"Sanguinaire"},
}
B.talentDependencies={
 ["Gore Drinker"]={"Blood Craze",3},
 ["Bloodthirst"]={"Death Wish",1},
}
-- Sequence explicite 10..60. Ce premier plan Furie pur est valide pour les
-- pre-requis connus mais n'est PAS certifie optimum DPS / temps de leveling.
B.talentBlocks={
 {10,14,"Cruelty"},{15,19,"Unbridled Wrath"},
 {20,22,"Furious Precision"},{23,24,"Enrage"},
 {25,29,"Dual Wield Specialization"},{30,30,"Death Wish"},
 {31,33,"Enrage"},{34,34,"Reckless Swings"},
 {35,37,"Flurry"},{38,39,"Improved Whirlwind"},
 {40,40,"Bloodthirst"},{41,43,"Blood Craze"},
 {44,45,"Gore Drinker"},{46,47,"Improved Berserker Rage"},
 {48,49,"Improved Execute"},{50,54,"Lingering Rage"},
 {55,55,"Piercing Howl"},{56,57,"Improved Intercept"},
 {58,60,"Booming Voice"},
}
-- La carte globale est indicatrice, PAS une suite de quetes suffisamment verifiee.
B.chapters={
 {1,12,"Clairieres de Tirisfal","Depart mort-vivant; etapes precises a auditer."},
 {13,17,"Foret des Pins-Argentes","Preparation aux quetes de la Horde."},
 {18,25,"Tarides / Collines de Hautebrande","Changer de zone selon les quetes disponibles."},
 {26,29,"Orneval / Mille pointes","Verifier les etapes de classe et les niveaux."},
 {30,32,"Hautebrande / Arathi","Quetes solo plutot que donjons."},
 {33,34,"Mille pointes","Finir les objectifs rentables, eviter Gnomeregan en solo."},
 {34,36,"Desolace","Village des Proies-de-l'Ombre et Poste des Marche-fantomes."},
 {36,38,"Vallee de Strangleronce / Marecage","Priorite aux quetes solo de niveau prudent."},
 {38,40,"Arathi / Terres ingrates","Preparer le palier 40."},
 {41,48,"Tanaris / Feralas / Strangleronce","Chapitre a documenter."},
 {49,54,"Cratere d'Un'Goro / Gorge des Vents brulants","Chapitre a documenter."},
 {55,60,"Gangrebois / Berceau-de-l'Hiver / Maleterres","Chapitre a documenter."},
}
-- source="quest" ou "craft" EXCLUSIVEMENT.
-- Une quete offrant une arme est referencee par routeId, dans B.route.
-- Aucune etiquette "disponible" sans tester le niveau et les contraintes.
B.gear={
 {id=3844,slot="Torse",name="Green Iron Hauberk",
  minLevel=31,source="craft",profession="Forge",skill=155,recipe=3508,
  routeId="craft-hauberk",group=false,
  note="Armure de mailles; fabrication personnelle ou artisan tiers si objet non lie.",
  sourceUrl="https://www.wowhead.com/forever/item=3844"},
 {id=3843,slot="Jambes",name="Golden Scale Leggings",
  minLevel=29,source="craft",profession="Forge",skill=170,recipe=3507,
  routeId="craft-leggings",group=false,
  note="Plan et composants a confirmer; alternative artisanale a envisager.",
  sourceUrl="https://www.wowhead.com/forever/item=3843"},
 {id=6802,slot="Arme 1 main",name="Sword of Omen",
  minLevel=33,source="quest",questId=1048,routeId="quest-scarlet",
  group=true,note="Option groupe uniquement : plusieurs ailes du Monastere ecarlate.",
  sourceUrl="https://www.wowhead.com/forever/quest=1048"},
 {id=17705,slot="Arme 1 main",name="Thrash Blade",
  minLevel=45,source="quest",questId=7064,routeId="quest-maraudon",
  group=true,note="Option tardive en groupe : Maraudon, non accessible au niveau 34.",
  sourceUrl="https://www.wowhead.com/forever/quest=7064"},
}
-- Les etapes individuelles pilotes sont des actions verifiables ou des
-- recommandations de hub, jamais des quetes inventees.
-- id, minLevel, zone, type, texte, optional?, group?, questId?, gearId?
B.route={
 {id="lvl30",level=30,zone="Hautebrande",kind="travel",
  text="Terminer les quetes de Hautebrande et Arathi adaptees au niveau.",
  note="Le plan d'ensemble des guides n'est pas une liste de quetes exacte."},
 {id="lvl33",level=33,zone="Mille pointes",kind="travel",
  text="Rejoindre les Salines et terminer les objectifs solo deja acceptes.",
  note="Sources comparees : ForeverTavern / Wowdee."},
 {id="quest-scarlet",level=33,zone="Fossoyeuse / Monastere ecarlate",
  kind="quest",text="Option groupe : Into the Scarlet Monastery (epee Sword of Omen).",
  questId=1048,gearId=6802,optional=true,group=true,
  note="Prendre chez Varimathras; plusieurs boss dans plusieurs ailes. Ne pas tenter en solo."},
 {id="lvl34",level=34,zone="Desolace",kind="travel",
  text="Rejoindre le Poste des Marche-fantomes, verifier les quetes locales.",
  note="Progresser en priorite contre des ennemis plus faibles."},
 {id="craft-leggings",level=29,zone="Atelier de forge",kind="craft",
  text="Si utile : faire fabriquer les Golden Scale Leggings (Forge 170).",
  gearId=3843,optional=true,
  note="Recette 3507 (Forge 170 selon Wowhead Forever). Niveau requis 29; verifier plan et composants."},
 {id="craft-hauberk",level=31,zone="Atelier de forge",kind="craft",
  text="Si utile : faire fabriquer la Green Iron Hauberk (Forge 180).",
  gearId=3844,optional=true,
  note="Recette 3508 (Forge 155), niveau requis 31. Demande aussi une armure de cuir vert; artisan tiers possible."},
 {id="desolace-quest-hub",level=34,zone="Desolace",kind="travel",
  text="Regrouper les quetes du Poste des Marche-fantomes.",
  note="Verifier la chaine Alliance Relations avant ses suites."},
 {id="desolace-shadowprey",level=35,zone="Desolace",kind="travel",
  text="Passer au Village des Proies-de-l'Ombre et apprendre le trajet aerien.",
  note="Les quetes Stealing Supplies et Hand of Iruxos peuvent necessiter le niveau 35+."},
 {id="lvl36",level=36,zone="Strangleronce",kind="travel",
  text="Poursuivre avec les hubs solo de Strangleronce.",
  note="Eviter les grands packs; sous-niveau necessitant une transition sure."},
 {id="lvl37",level=37,zone="Marecage d'Aprefange",kind="travel",
  text="Comparer les quetes solo du Marecage a celles restantes a Strangleronce.",
  note="Ne pas imposer un trajet si aucune quete verifiee n'y est accessible."},
 {id="lvl39",level=39,zone="Terres ingrates",kind="travel",
  text="Envisager les Terres ingrates pour les dernieres quetes avant 40.",
  note="Verifier les prerequisites et les ennemis sur place."},
 {id="lvl40",level=40,zone="Capitale / Maitre de classe",kind="train",
  text="Verifier l'apprentissage de Sanguinaire et les nouveaux rangs de sorts.",
  note="Rester Furie double maniement; plan non optimise tant que non mesure."},
 {id="quest-maraudon",level=45,zone="Maraudon",kind="quest",
  text="Option groupe : Corruption of Earth and Seed (Thrash Blade).",
  questId=7064,gearId=17705,optional=true,group=true,
  note="Quete 45+, plusieurs versions 7064/7065 : revalider la faction et l'entree."},
}
B.references={
 "https://forevertavern.net/guides/leveling/horde/thousand-needles-33-34",
 "https://forevertavern.net/guides/leveling/horde/desolace-34-36",
 "https://wowforeverleveling.com/guides/wow-forever-horde-leveling-guide",
 "https://www.wowhead.com/forever/quest=1048",
 "https://www.wowhead.com/forever/quest=7064",
 "https://www.wowhead.com/forever/item=3844",
 "https://www.wowhead.com/forever/item=3843",
 "https://zephras.com/data/",
}
