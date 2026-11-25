# Warrior Companion | Build Planner — 0.3.7-test

**Addon autonome de test**, distinct du vieux `WarriorCompanion`, pour **WoW Forever** (interface `16001`). Il ne remplace pas l'ancien projet et peut être supprimé sans perdre ses sauvegardes.

## Installation

1. Depuis la branche GitHub `feature/build-planner`, télécharger l'archive ZIP.
2. Extraire **uniquement** `Addon/WarriorCompanionBuild` vers `World of Warcraft/Interface/AddOns/WarriorCompanionBuild/`.
3. Vérifier que `Interface/AddOns/WarriorCompanionBuild/WarriorCompanionBuild.toc` existe.
4. Pour tester sans chevauchement, désactiver temporairement l'ancien addon `WarriorCompanion` dans le sélecteur d'addons. Redémarrer WoW Forever.
5. **Par défaut**, aucune fenêtre ne s'ouvre automatiquement ; un bouton guerrier apparaît autour de la minimap. Clic gauche pour ouvrir le guide, clic droit pour ouvrir le mini-bilan, sans fermeture par répétition d'un clic.
6. Utiliser `/wcb` si le bouton est masqué ou si la minimap n'est pas disponible.

### Mini-bilan d'origine et accès depuis la minimap

- Mini-fenêtre **304 × 88 px** reprenant les informations de l'ancien mais avec palette anthracite/bronze cohérente avec la grande interface ; fidèle à l'ancien `CompactDashboard.lua` : XP gagnée, temps écoulé, morts, delta de monnaie de la session (or/argent/cuivre, couleurs positives/négatives) et une ligne d'alerte. Actualisation périodique toutes les trois secondes ou à un événement de session.
- **Déplacement libre**, position du mini mémorisée dans `WCBuildDB.compactPoint`, bouton **>>** pour développer. La fermeture du guide après un développement depuis le mini le restaure.
- **Icône circulaire style LibDBIcon/GearQuest autour de la minimap** (taille réelle de la minimap / 2 + 5, icône de 20 px centrée sans masque déformant, contour Blizzard), position angulaire mémorisée ; clic gauche : ouvrir le guide complet ; clic droit : ouvrir le mini, sans fermer au second clic ; glisser-déposer : repositionner l'icône.
- Le suivi de session recommence à chaque connexion ou avec `/wcb reset`. L'XP est observée par les API de personnage ; les gains lors d'un changement de niveau sont calculés prudemment. Si une API renvoie un nombre secret (mécanisme de protection Forever), l'addon ne le compare ni ne le calcule : il affiche une valeur indisponible au lieu de planter. Les positions et le drag de la minimap appliquent la même protection.
- **Options identiques** : `/wcb mini`, `/wcb full`, `/wcb hide`, `/wcb autostart on/off`, `/wcb reset`, `/wcb alerts on/off`. Ajout de `/wcb minimap on/off`. Par défaut, l'ouverture automatique est **désactivée** ; activable pour retrouver l'ancienne expérience. Les préférences sont dans `WCBuildDB`.
- L'ancienne logique générale de conseils n'est pas importée intégralement : la ligne conserve les alertes sûres (points non dépensés si API présente, vie basse, morts répétées). Le mini reste autonome du vieux dossier `WarriorCompanion`.

### Contrôles

- **Talents / Équipement / Parcours / Rotation** : les 4 onglets.
- `<` et `>` en haut : visualiser le plan à un autre niveau **sans changer le niveau réel**.
- **Niv réel** : revenir au niveau actuel et à son suivi automatique.
- **− / +** : réduire / agrandir l'interface. Par défaut 82 %, plage 65–115 %. La position et l'échelle sont sauvegardées. En-tête déplaçable au clic gauche.
- Les boutons **− / +** suffisent pour ajuster l’échelle : aucun préréglage compact ou grand.
- **Talents** : **trois arbres Armes / Furie / Protection côte à côte** avec les 53 talents, bordures ambrées pour les points déjà attribués et icônes non investies estompées ; le point investi au niveau consulté est bordé d'or. Le bouton du bas compare **Furie pure** et une variante expérimentale **Armes/Furie** (13/38) sans modifier le personnage. Survol des icônes pour les rangs et prérequis.
- **Équipement** : les cibles les plus pertinentes **accessibles au palier prévisualisé**. Liste pleine largeur sans doublon descriptif à droite : cinq cibles visibles, défilement vertical à la molette (ou curseur sur le côté) : objets du niveau d'abord, puis **paliers futurs** grisés et marqués « PLUS TARD ». Le bouton « Paliers suivants » est supprimé. Icône, nom, niveau et fiche au survol. **Voir dans Parcours** ouvre la quête/fabrication ou le boss lié. Deux butins du boss Hérode (casque de berserker, épaulières) et le **Fendoir de Glouton** (#10772, hache une main sur Glouton aux Souilles de Tranchebauge) sont ajoutés comme options de groupe au niveau 37 ; pas de hache à deux mains pour un build double maniement. Classement heuristique, pas de rang GearQuest revendiqué ; la pertinence réelle dépend des armes déjà équipées. Les classements sont heuristiques, pas une comparaison de DPS avec ton équipement.
- **Parcours** : icône d'objet récupéré sur la carte active (infobulle native), bouton **Détails** (comment compléter la quête, objectif du journal, type de butin). Pour une fabrication, Forge requise, ID de recette et indication de son acquisition connue ou à vérifier ; pour un drop, nom du boss et avertissement sur l'aléatoire. Tranches non superposées 1–9, 10–19, 20–29, **30–40**, 41–50 et 51–60. Toute la tranche est en liste, avec molette et glissière; boutons pour passer à une autre tranche. L'API moderne `C_QuestLog` détecte les quêtes acceptées (`EN COURS`), prêtes à rendre (`A RENDRE`) et déjà rendues (masquées par défaut, réaffichables). Les quêtes ne se valident plus manuellement; seuls trajets/ateliers peuvent l'être. Les badges distinguent quêtes XP, option, équipement et groupe. L'ordre 30–40 regroupe prudemment les hubs et favorise le solo, **sans mesure garantie du temps de trajet**. Les autres tranches, notamment 51–60, restent des aperçus non exhaustifs.

- **Rotation** : onglet **Monocible / Multicible** avec **buffs à maintenir**, **ouverture**, **boucle principale**, **réactions/procs** (Fulgurance déclenche le GCD), **CD offensifs** et **défensifs**. Rage sanguinaire est identifiée **hors GCD**, tandis que Fulgurance reste réactive **sur GCD**. Une ligne de boucle réelle est donnée selon le niveau, avec les trois réactions affichables. **Fracasser armure** (rang 1 à 10, nouveaux rangs 22/34/46/58) est ajouté pour les adversaires robustes. L'icône et l'ID d'**Ivresse de la victoire** sont corrigés (#402927). Les sorts appris n'affichent plus « Dans le grimoire » : seuls les apprentissages manquants, rangs supérieurs disponibles ou buffs utiles ont une mention. Le grimoire est lu avec les noms de familles de sorts et leurs rangs (y compris sans accents et quand une API facultative manque), plutôt que de déclarer « non appris » à tort. Aucune automatisation de sorts.

**Police :** sans empattement `Fonts\\ARIALN.TTF`, déjà présente dans le client WoW, proche visuellement de Roboto ; aucun fichier de police distribué.

### Couverture réelle

**Validé structurellement par tests :** les 3 arbres (17 Armes, 18 Furie, 18 Protection) avec leurs 51 allocations Furie pure et hybride vérifiées par palier, niveaux d'équipement et sources quête/forge seulement, chaque objet relié à une étape de route, sauts vers cette étape, prévisualisation du niveau, états « plus tard »/« groupe »/« chaîne à vérifier ».

**Pilote détaillé : niveaux 30–40, avec les quêtes de classe Guerrier #1718/#1719, les objectifs de Désolace #5561 et #5386, l'arrêt Wulan (Cuisine experte), les quêtes XP des Salines #1105/#1175, et une chaîne Gelkis facultative jusqu'aux niveaux 42–43**. L'ordre des hubs a été recoupé entre ForeverTavern et plusieurs guides Horde; les **PNJ et quêtes individuelles non confirmées** restent explicitement « à vérifier ». En-dessous de 30 ou au-dessus de 40 : **simple vue d'ensemble des zones 1–60**, non une route de quêtes exhaustivement validée. Les options donjon (Monastère écarlate / Maraudon à 45+) ne sont pas obligatoires en solo.

**Non encore validé en jeu :** les clics de l'icône, le déplacement autour de la minimap, les compteurs après un changement de niveau, l'état du journal et le défilement sur le client réel, la lecture des icônes par FileDataID, la récupération des icônes d'objets via le cache client sur la version du client, l'apparence des infobulles, l'échelle selon résolution, les traductions des noms qui ne figurent pas dans le client, les récompenses locales et les raccourcis `/wcb`. Le build Furie pur et la variante 13/38 sont des points de comparaison, **pas une démonstration du DPS maximum**. Les descriptions de rang exactes proviennent du tooltip jeu lorsqu'il est accessible.

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
