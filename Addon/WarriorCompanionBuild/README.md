# Warrior Companion | Build Planner — 0.2.0-test

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
- **Survol des icônes** : infobulle de sort côté client lorsque l'API le permet, avec rangs prévus et prérequis. Le talent attribué au **niveau consulté** possède un contour doré distinct des points déjà acquis.
- **Équipement** : icône, nom, niveau et description de l'objet ; infobulle du client au survol. Choisir une pièce puis **Voir dans Parcours** pour rejoindre la quête ou la fabrication correspondante.
- **Parcours** : grande carte d'étape actuelle et liste des étapes suivantes à la manière de PexGuide ; navigation Avant/Après, validation manuelle uniquement sur des étapes éligibles et non-groupes. Les quêtes de groupe sont toujours marquées optionnelles.

- **Rotation** : quatrième onglet distinct avec priorités indicatives monocible et multicible, sorts affichés selon le niveau et infobulles au survol. Aucun sort lancé automatiquement.

**Police :** sans empattement `Fonts\\ARIALN.TTF`, déjà présente dans le client WoW, proche visuellement de Roboto ; aucun fichier de police distribué.

### Couverture réelle

**Validé structurellement par tests :** 18 noeuds de talents Furie en positions 4×7 issues de Zephras, 51 allocations sans rang ou palier impossible, niveaux d'équipement minimum, exactement quatre premières pistes d'équipement quête/fabrication, lien obligatoire à une étape du Parcours, saut vers cette étape, aperçu de niveau manuel, états « plus tard »/« groupe ».

**Pilote documenté : niveaux 30–40**. L'ordre des hubs a été recoupé entre ForeverTavern et plusieurs guides Horde; les **PNJ et quêtes individuelles non confirmées** restent explicitement « à vérifier ». En-dessous de 30 ou au-dessus de 40 : **simple vue d'ensemble des zones 1–60**, non une route de quêtes exhaustivement validée. Les options donjon (Monastère écarlate / Maraudon à 45+) ne sont pas obligatoires en solo.

**Non encore validé en jeu :** la lecture des icônes par FileDataID, la récupération des icônes d'objets via le cache client sur la version du client, l'apparence des infobulles, l'échelle selon résolution, les noms français, les récompenses locales et les raccourcis `/wcb`. Le build Furie pur est un point de départ, **pas une démonstration du DPS maximum**. Les descriptions de rang exactes proviennent du tooltip jeu lorsqu'il est accessible.

Aucun achat, déplacement, allocation de talent ou lancement de sort automatique.

## Sources et attribution

- **Talents :** Zephras, `zephras-talents/1`, build `1.60.1.70938`, https://zephras.com/data/ — arrangement et valeurs dérivées sous **CC BY 4.0**, adaptation manuelle (Furie seulement, libellés français de secours). Noms, sorts et icônes © Blizzard Entertainment.
- **Quêtes et route :** https://forevertavern.net/guides/leveling/horde/thousand-needles-33-34 , https://forevertavern.net/guides/leveling/horde/desolace-34-36 , https://wowforeverleveling.com/guides/wow-forever-horde-leveling-guide .
- **Arme de quête :** https://www.wowhead.com/forever/quest=1048 — Sword of Omen (6802), niveau minimum 33, quête Horde de donjon. À vérifier en jeu.
- **Maraudon (après 45) :** https://www.wowhead.com/forever/quest=7064 — Thrash Blade (17705). Groupe requis ; la disponibilité exacte côté Horde doit être confirmée.
- **Forge :** https://www.wowhead.com/forever/spell=3508 — Green Iron Hauberk (3844), niveau requis 31, Forge 155 selon WoW Forever. https://www.wowhead.com/forever/spell=3507 — Golden Scale Leggings (3843), niveau requis 29, Forge 170 selon la fiche courante. Des sites de comparaison de builds montrent d'autres seuils ; prendre le nombre affiché dans le client comme arbitre.
- **Comparaison :** https://www.wowhead.com/forever/guide/classes/warrior/fury/dps-leveling-tips et https://mobalytics.gg/wow-forever/classes/1-60-fury-warrior-leveling-guide (priorités/variantes). Leur itinéraire n'est pas copié.

Les documents de conception sont dans `docs/` au niveau du dépôt.
