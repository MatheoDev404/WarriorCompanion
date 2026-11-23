# Warrior Companion | Build Planner — 0.3.1-test

**Addon autonome de test**, distinct du vieux `WarriorCompanion`, pour **WoW Forever** (interface `16001`). Il ne remplace pas l'ancien projet et peut être supprimé sans perdre ses sauvegardes.

## Installation

1. Depuis la branche GitHub `feature/build-planner`, télécharger l'archive ZIP.
2. Extraire **uniquement** `Addon/WarriorCompanionBuild` vers `World of Warcraft/Interface/AddOns/WarriorCompanionBuild/`.
3. Vérifier que `Interface/AddOns/WarriorCompanionBuild/WarriorCompanionBuild.toc` existe.
4. Pour tester sans chevauchement, désactiver temporairement l'ancien addon `WarriorCompanion` dans le sélecteur d'addons. Redémarrer WoW Forever.
5. Utiliser `/wcb` pour ouvrir/fermer le nouveau planner.

### Contrôles

- **Talents / Équipement / Parcours / Rotation** : les 4 onglets.
- `<` et `>` en haut : visualiser le plan à un autre niveau **sans changer le niveau réel**.
- **Niv réel** : revenir au niveau actuel et à son suivi automatique.
- **− / +** : réduire / agrandir l'interface. Par défaut 82 %, plage 65–115 %. La position et l'échelle sont sauvegardées. En-tête déplaçable au clic gauche.
- Les boutons **− / +** suffisent pour ajuster l’échelle : aucun préréglage compact ou grand.
- **Talents** : sous-onglets **Armes / Furie / Protection** avec les 53 talents ; le point investi au niveau consulté est bordé d'or. Le bouton du bas compare **Furie pure** et une variante expérimentale **Armes/Furie** (13/38) sans modifier le personnage. Survol des icônes pour les rangs et prérequis.
- **Équipement** : les 4 objets les plus pertinents **accessibles au palier prévisualisé**. Les autres objets du même niveau puis les **paliers futurs** sont consultables séparément. Icône, nom, niveau et fiche au survol. **Voir dans Parcours** ouvre la quête/fabrication liée. Les classements sont heuristiques, pas une comparaison de DPS avec ton équipement.
- **Parcours** : grande carte d'étape actuelle et liste des étapes suivantes à la manière de PexGuide ; navigation Avant/Après, validation manuelle uniquement sur des étapes éligibles et non-groupes. Les quêtes de groupe sont toujours marquées optionnelles.

- **Rotation** : onglet **Monocible / Multicible** avec **buffs à maintenir**, **ouverture**, **boucle principale**, **réactions/procs** (Fulgurance déclenche le GCD), **CD offensifs** et **défensifs**. Rage sanguinaire est identifiée **hors GCD**, tandis que Fulgurance reste réactive **sur GCD**. Une ligne de boucle réelle est donnée selon le niveau, avec les trois réactions affichables. Le grimoire est lu avec les noms de familles de sorts et leurs rangs (y compris sans accents et quand une API facultative manque), plutôt que de déclarer « non appris » à tort. Aucune automatisation de sorts.

**Police :** sans empattement `Fonts\\ARIALN.TTF`, déjà présente dans le client WoW, proche visuellement de Roboto ; aucun fichier de police distribué.

### Couverture réelle

**Validé structurellement par tests :** les 3 arbres (17 Armes, 18 Furie, 18 Protection) avec leurs 51 allocations Furie pure et hybride vérifiées par palier, niveaux d'équipement et sources quête/forge seulement, chaque objet relié à une étape de route, sauts vers cette étape, prévisualisation du niveau, états « plus tard »/« groupe »/« chaîne à vérifier ».

**Pilote documenté : niveaux 30–40, avec les quêtes de classe Guerrier #1718/#1719, les objectifs de Désolace #5561 et #5386, l'arrêt Wulan (Cuisine experte), et une chaîne Gelkis facultative jusqu'aux niveaux 42–43**. L'ordre des hubs a été recoupé entre ForeverTavern et plusieurs guides Horde; les **PNJ et quêtes individuelles non confirmées** restent explicitement « à vérifier ». En-dessous de 30 ou au-dessus de 40 : **simple vue d'ensemble des zones 1–60**, non une route de quêtes exhaustivement validée. Les options donjon (Monastère écarlate / Maraudon à 45+) ne sont pas obligatoires en solo.

**Non encore validé en jeu :** la lecture des icônes par FileDataID, la récupération des icônes d'objets via le cache client sur la version du client, l'apparence des infobulles, l'échelle selon résolution, les noms français, les récompenses locales et les raccourcis `/wcb`. Le build Furie pur et la variante 13/38 sont des points de comparaison, **pas une démonstration du DPS maximum**. Les descriptions de rang exactes proviennent du tooltip jeu lorsqu'il est accessible.

Aucun achat, déplacement, allocation de talent ou lancement de sort automatique.

**Avertissement de fiabilité :** l'arme Bludgeon of Betrayed Virtues #271802 vient de la quête Forever **Khan Jehn #93128** (longue chaîne Gelkis, réputation Honoré, objectif prévu vers le niveau 43), et non de la quête classique homonyme #1374. Voir [l'audit](../../docs/QUEST_AUDIT_30_45.md). La base de talents a été extraite du build 70938, alors que la base en ligne mentionne 71037 : les changements futurs doivent être confrontés au client.

## Sources et attribution

- **Talents :** Zephras, `zephras-talents/1`, build `1.60.1.70938`, https://zephras.com/data/ — arrangement et valeurs dérivées sous **CC BY 4.0**, adaptation manuelle (Furie seulement, libellés français de secours). Noms, sorts et icônes © Blizzard Entertainment.
- **Quêtes et route :** https://forevertavern.net/guides/leveling/horde/thousand-needles-33-34 , https://forevertavern.net/guides/leveling/horde/desolace-34-36 , https://wowforeverleveling.com/guides/wow-forever-horde-leveling-guide .
- **Arme de quête :** https://www.wowhead.com/forever/quest=1048 — Sword of Omen (6802), niveau minimum 33, quête Horde de donjon. À vérifier en jeu.
- **Maraudon (après 45) :** https://www.wowhead.com/forever/quest=7064 — Thrash Blade (17705). Groupe requis ; la disponibilité exacte côté Horde doit être confirmée.
- **Forge :** https://www.wowhead.com/forever/spell=3508 — Green Iron Hauberk (3844), niveau requis 31, Forge 155 selon WoW Forever. https://www.wowhead.com/forever/spell=3507 — Golden Scale Leggings (3843), niveau requis 29, Forge 170 selon la fiche courante. Des sites de comparaison de builds montrent d'autres seuils ; prendre le nombre affiché dans le client comme arbitre.
- **Comparaison :** https://www.wowhead.com/forever/guide/classes/warrior/fury/dps-leveling-tips et https://mobalytics.gg/wow-forever/classes/1-60-fury-warrior-leveling-guide (priorités/variantes). Leur itinéraire n'est pas copié.

Les documents de conception sont dans `docs/` au niveau du dépôt.
