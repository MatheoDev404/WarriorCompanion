# Warrior Companion

Warrior Companion observe la session de ton guerrier dans WoW Forever. Il fonctionne de façon autonome, sans trafic réseau ni itinéraire de quêtes. Le **mini-bilan de 304 × 88 pixels** s'ouvre automatiquement à la connexion. Son bouton `>>` ouvre le tableau complet, et la fermeture du tableau revient au mini-bilan. **Aucun bouton de minimap n'est créé.**

## Ce que mesure la version 0.5.6-rc1

| Activité | Comportement |
| --- | --- |
| XP | Gain mesuré depuis le chargement ou `/wc reset`. L’XP/h est une moyenne de session affichée après une minute si la barre d’XP est lisible et active. Les transitions ambiguës peuvent retarder le total. Les niveaux intermédiaires manqués ne sont pas estimés. |
| Morts et combats | Compteur de morts et conseil dans le tableau après trois morts. L’état de combat suspend les notifications. La durée et le nombre d'intervalles d'état de combat sont maintenant suivis. Un intervalle n'est pas un ennemi tué ; les dégâts et la récupération restent non mesurés. |
| Quêtes et argent | Nombre de quêtes du journal, en excluant les en-têtes, et variation convertie en pièces d'or, d'argent et de cuivre avec leurs icônes, depuis la première lecture disponible de la session. |
| Talents | Les points libres de classe et de spécialisation déclenchent une alerte hors combat, au plus une fois toutes les cinq minutes par session. Les autres conseils se lisent dans le tableau. |
| Armes guerrier Furie | Observe les emplacements main droite/gauche et le type d'arme via les API WoW. Si le guerrier est au moins niveau 20 et porte une arme à une main, peut suggérer de vérifier une deuxième arme en main gauche. Ignore les armes à deux mains et les types indisponibles. Ne compare pas les DPS. |
| Grimoire de sorts | Observe les sorts et les rangs présents via `C_SpellBook`. Lorsqu'un nouvel élément est détecté depuis une référence fiable, conseille au guerrier Furie de vérifier ses barres d'action. Ne prétend pas connaître les sorts achetables chez le maître. |
| Conseils guerrier Furie | Lorsque la classe guerrier est confirmée, le mode Furie cible conseille la récupération avec bandages ou nourriture en cas de PV bas et le contrôle des armes si au moins cinq phases de combat durent en moyenne 45 secondes ou plus. Ce sont des conseils informatifs, sans prétendre détecter la spécialisation actuelle. |
| Points de vie | Lecture sécurisée des PV du personnage, conseil de récupération **dans le tableau de bord uniquement** sous 35 % hors combat. Ne suggère pas de soin lorsqu'il est mort ou lorsque les valeurs sont indisponibles. |
| Compétences, métiers et équipement | Le journal de diagnostic peut signaler un changement de compétences ou d’équipement. L’analyse des rangs de métier et la comparaison des pièces restent à développer. |

L'analyse XP/h récente utilise une fenêtre glissante de 10 minutes, après au moins une minute d'observation, et inclut les périodes sans gain d'XP. Sa mémoire est limitée à 600 échantillons ; si cette limite masque un échantillon encore pertinent, le taux reste indisponible jusqu'à retrouver une fenêtre complète. Aucun conseil causal n'est déduit de ce chiffre.

L'historique d'activité conserve en mémoire vive les 60 derniers événements utiles : XP mesurée, niveaux, morts, modifications d'équipement, mises à jour des compétences et changements du nombre de quêtes. Il ne déduit ni l'objet obtenu ni la quête terminée. Utiliser `/wc history` pour afficher les 12 derniers événements. Un gain mesuré au changement de zone apparaît une seule fois. Pour l’équipement, deux emplacements lisibles distincts peuvent apparaître dans la même seconde. Les répétitions de la même description d’équipement ou de compétences sont filtrées pendant huit secondes parmi les entrées conservées. Le journal des activités est distinct du journal de debug et est effacé à `/wc reset`.

## Tableau de bord — direction artistique D (0.5.6-rc1)

Cette version reprend la direction **D : HUD WoW moderne, guerrier Horde** au-delà de la simple disposition. Elle embarque deux textures originales (`Textures/HordeSky.tga`, paysage rouge avec silhouettes de forteresse, et `Textures/Warcrest.tga`, bouclier guerrier) dans le ZIP. L'interface possède une armature métallique avec angles et rivets, des cartes cerclées de bronze, un bandeau illustré et une navigation latérale compacte.

Le **Bilan** montre simultanément quatre statistiques, les quêtes, la variation d'argent (or, argent, cuivre, signe global), les combats, le conseil prioritaire et les deux dernières activités. Les pages **Combat**, **Conseils** et **Journal** complètent les détails.

Les textures n'utilisent pas de code propriétaire de tiers. Le rendu exact, les proportions et la prise en charge TGA de Forever doivent être vérifiés en jeu : la CI ne teste pas le moteur graphique WoW.

## Deux affichages : mini-bilan et interface complète

Le mini-bilan mesure **304 × 88 pixels** et présente uniquement l'XP gagnée, l'XP/h, les morts, la balance nette de la session (gains moins dépenses), en or, argent et cuivre avec les icônes WoW et un code couleur : vert pour gain, rouge pour perte, gris clair pour zéro et une ligne de conseil. Il est déplaçable, avec position mémorisée. Le bouton `>>` agrandit vers la fenêtre complète **600 × 360** ; le bouton X de celle-ci revient au mini-bilan. Les onglets Combat, Conseils, Journal et Quêtes restent dans la fenêtre complète.

Le mode compact est affiché au premier démarrage. Le choix compact/complet et la position du mini-bilan sont enregistrés dans WC_DB. La commande `/wc` alterne les deux vues, `/wc mini` force la vue réduite et `/wc full` force la vue complète. Aucun bouton de minimap n'est installé.

## Démarrage automatique

L'affichage sauvegardé est rétabli une fois à la connexion. L'ouverture automatique est activée par défaut, et se contrôle avec `/wc autostart on` et `/wc autostart off`.

## Provenance des armes (GearQuest Forever)

GearQuest Forever est une source externe spécialisée pour rechercher des améliorations selon la classe, la spécialisation, le niveau, l'équipement porté, les quêtes, les boss et les vendeurs. Son classement dépend de pondérations internes et peut évoluer avec les mises à jour de Forever.

Warrior Companion ne recopie pas son catalogue ni son scoring et **n'affirme pas qu'un objet particulier est un meilleur choix** : son dépôt public ne comporte pas de licence clairement déclarée et aucune API publique stable d'export des recommandations n'a été identifiée. Lorsque GearQuest est chargé, un conseil informatif renvoie vers `/gq` après un changement de niveau ou d'équipement observé, afin de revoir **tous les emplacements** (armes, armure, bijoux et accessoires). Ce rappel expire après dix minutes. Cela évite les fausses informations, les prix HDV inventés et la duplication d'un système de classement complet.

Pour vérifier l'intégration, utiliser `/wc gear` puis ouvrir GearQuest avec `/gq`. **GearQuest est optionnel** et Warrior Companion reste autonome sans lui. Le suivi des armes demeure disponible avec `/wc weapons`.

Références : [GearQuest Forever](https://github.com/Henrik8210/gear-quest-forever) et [fiche de l'addon](https://www.curseforge.com/wow/addons/gearquest-forever).

## Points de talents (0.6.3-rc1)

Le module `TalentObserver.lua` utilise `C_ClassTalents.HasUnspentTalentPoints` lorsque disponible pour afficher les points disponibles (classe + spécialisation). Il retient les changements observés après des événements de talents, sans les présenter comme un talent précis dépensé : une respécialisation ou une mise à jour serveur peut aussi expliquer la différence. Si la lecture échoue, aucun chiffre n'est inventé.

Commande `/wc talents` pour vérifier les compteurs et le nombre de changements observés. Le rappel déjà existant des points non dépensés continue de fonctionner. **L'arbre Furie et la recommandation d'un talent précis ne sont pas encore validés dans le client Forever.**

## Conseiller de quêtes Horde Furie (0.6.3-rc1)

Le module `QuestAdvisor.lua` classe **les quêtes déjà acceptées** et présentes dans le journal du personnage guerrier Horde. Il distingue les quêtes prêtes à rendre, les candidates solo en dessous du niveau du joueur, les quêtes proches du niveau nécessitant de la prudence, les quêtes plus hautes, et les marqueurs explicitement signalés groupe/donjon/élite. Si le client ne fournit pas un type fiable, le statut reste **inconnu**, sans être converti en solo.

Le niveau d'une quête **n'est pas** le niveau précis de ses ennemis ; aucune récompense, difficulté réelle, temps de trajet, XP/h ou prérequis d'une quête non acceptée n'est inventé. Le journal du personnage Horde ne prouve pas qu'une quête soit exclusive à la Horde.

**Questie** conserve l'affichage de ses marqueurs sur minimap et carte. Warrior Companion n'en crée aucun deuxième. L'intégration optionnelle utilise `Questie.API.isReady`, `RegisterOnReady` et `RegisterForQuestUpdates` documentés publiquement pour actualiser nos conseils, avec un repli sur `QUEST_LOG_UPDATE` du client si Questie n'est pas disponible. Aucun accès aux tables internes de Questie et aucune dépendance obligatoire.

Commandes : `/wc quests` affiche un classement prudent jusqu'à cinq quêtes ; `/wc questie` vérifie si Questie est détecté et prêt.

**À développer ensuite** : propositions de quêtes *non encore acceptées* avec faction, prérequis, chaîne et source contrôlés via une base de données compatible Forever, et validation du niveau réel des ennemis pour un guerrier Furie prudent.

Sources de l'API : [Questie — API publique](https://github.com/Questie/Questie/blob/master/Public/README.md), [Questie — notifications](https://github.com/Questie/Questie/blob/master/Public/RegisterForQuestUpdates.lua).

## Découverte de quêtes non encore acceptées — V0.6.1

Avec **QuestieDB compatible Forever** installé, la commande `/wc discover` cherche *à la demande* des pistes de quêtes qui ne figurent pas déjà dans le journal. Ce n'est pas une promesse d'accessibilité immédiate, ni un itinéraire.

Les filtres vérifient sur le client la classe guerrier, la faction Horde, la race et le niveau, puis utilisent **l'API publique QuestieDB sous contrat 4** pour vérifier les restrictions de race/classe, le niveau requis, un PNJ de départ et l'absence de conditions complexes non évaluées. Les quêtes déjà acceptées et terminées sont écartées. Un fournisseur de données absent, des valeurs incohérentes ou une information indisponible entraînent une exclusion ou un message explicite.

La sortie classe au maximum sept pistes selon la proximité de leur niveau de quête avec *niveau du personnage − 2*. **Le niveau de quête ne garantit pas celui des monstres ni une difficulté solo :** la disponibilité réelle, la localisation, les objectifs, les adversaires, l'XP/h et les récompenses doivent être confirmés dans Questie. Les quêtes à prérequis de chaîne, de réputation, de métier et à indicateurs spéciaux non évalués sont exclues par sécurité ; certaines quêtes intéressantes pourront donc manquer.

La recherche n'a lieu qu'à la demande via `/wc discover`, hors combat : aucun parcours du catalogue à chaque actualisation ou à la connexion. Questie conserve entièrement ses marqueurs.

Sources de contrat : [API QuestieDB](https://github.com/Questie/QuestieDB/blob/main/docs/api.md), [schéma des quêtes](https://github.com/Questie/QuestieDB/blob/main/src/meta/questMeta.lua) et [limites des données Forever](https://github.com/Questie/QuestieDB/blob/main/docs/forever.md).

## Regroupement des départs de quêtes — V0.6.2

La commande **`/wc route`** regroupe les quêtes candidates déjà filtrées par `/wc discover` selon la **zone QuestieDB** et les **positions des PNJ de départ proches**. La lecture utilise l'API publique de QuestieDB pour `Quest.startedBy`, `Npc.friendlyToFaction` et `Npc.spawns`. Seuls les PNJ de départ qui acceptent la Horde sont retenus, avec coordonnées numériques vérifiables. Le calcul compare des pourcentages de carte dans **une même zone**, jamais des kilomètres ni un temps de trajet.

L'algorithme privilégie les groupes contenant le plus de quêtes, puis les quêtes de niveau proche de `niveau du joueur − 2`. Il ne déplace pas les marqueurs de Questie et ne calcule pas encore l'itinéraire des objectifs ou la marche entre zones. **PNJ de départ proches ≠ objectifs proches ou quêtes solo sûres** : disponibilité réelle, donjon/élite, niveau des ennemis, distances et récompenses restent à confirmer. Les données absentes ne génèrent pas de position inventée.

Recherche sur commande seulement, **hors combat**, limitée à 40 pistes et 4 groupes affichés. Si QuestieDB ou ses positions sont indisponibles, un message explicite remplace les recommandations.

Références : [API publique QuestieDB](https://github.com/Questie/QuestieDB/blob/main/docs/api.md), [schéma PNJ](https://github.com/Questie/QuestieDB/blob/main/src/meta/npcMeta.lua), [limites Forever](https://github.com/Questie/QuestieDB/blob/main/docs/forever.md).

## Correctif de prudence — Duskwood (V0.6.3)

La capture en jeu a montré que `/wc route` pouvait mettre en avant les 18 missions de l'incursion cauchemardesque du Bois de la Pénombre comme un groupe intéressant pour le leveling. Les quêtes **81730 à 81747** sont toutes répertoriées comme **Élite** dans [la base WoW Forever d'Icy Veins](https://db.icy-veins.com/wow-forever/quests/zones/duskwood/). Elles sont désormais **exclues du classement de quêtes solo prudent**, même lorsque QuestieDB ne fournit pas un marqueur de difficulté exploitable. Les tags explicites d'élite/groupe/donjon disponibles dans le client sont également exclus.

`/wc route` précise qu'il s'agit de **pistes regroupées par PNJ de départ**, pas d'un itinéraire : le nombre de quêtes d'un même PNJ n'est ni une preuve de sécurité ni un rendement XP/h.

Ces exclusions concernent seulement les faits identifiés ; les autres quêtes doivent toujours être vérifiées dans Questie. Un niveau de quête inférieur au niveau du personnage ne prouve pas que les ennemis soient faciles.

## Affichage des quetes dans l'addon (V0.6.3)

Un cinquieme onglet compact **QUETES** est ajoute au tableau sans agrandir la fenetre. Les boutons **JOURNAL**, **A PRENDRE**, **PARCOURS** permettent de consulter des informations ordonnees plutot que de recevoir une longue sortie dans la fenetre de chat. Les commandes `/wc quests`, `/wc discover`, `/wc route` ouvrent directement ce panneau et sa vue correspondante. Les scans QuestieDB ne sont faits **qu'au clic**, hors combat, pour eviter les ralentissements.

La vue **PARCOURS** reste deliberement un **regroupement de PNJ de depart**, et ne pretend pas definir un itineraire entre objectifs. Un repere de zones issu du guide Horde de ForeverTavern est affiche pour les niveaux 30–37 lorsque pertinent, avec mention explicite qu'il doit etre recoupe avec QuestieDB et le client. Cette reference ne remplace pas un guide et aucune suite de quetes n'est recopiee ou inventee.

Sources de recherche pour les prochaines etapes verifiees : [ForeverTavern — routes Horde](https://forevertavern.net/guides/leveling/horde), [Bind on Forever — routes Horde](https://bindonforever.com/fr/leveling/horde), [QuestieDB — schema des quetes](https://github.com/Questie/QuestieDB/blob/main/src/meta/questMeta.lua). Il reste a verifier les **objectifs**, les quetes qui se debloquent mutuellement, les trajets réels et les ennemis avant de proposer une route pas-a-pas.

## Installation et commandes

Copier le dossier `Addon/WarriorCompanion` dans `Interface/AddOns/` du client Forever. Le fichier `WarriorCompanion.toc` doit se trouver directement dans `Interface/AddOns/WarriorCompanion/`. L’interface ciblée est `16001`.

| Commande | Effet |
| --- | --- |
| `/wc autostart on`, `/wc autostart off` | Activer/désactiver l'ouverture automatique à la prochaine connexion |
| `/wc` | Basculer entre mini-bilan et interface complète |
| `/wc status` | Afficher la version, les mesures, les options et la présence des fonctions d’API |
| `/wc reset` | Recommencer les mesures et effacer l'historique de session |
| `/wc performance` | Comparer XP/h globale et XP/h des dix dernières minutes |
| `/wc mini`, `/wc full` | Choisir directement la vue réduite ou complète |
| `/wc route` | Regrouper les PNJ de départ de quêtes Horde proches dans la même zone |
| `/wc discover` | Proposer jusqu'à sept pistes de quêtes non acceptées avec les filtres QuestieDB stricts |
| `/wc quests` | Classement prudent des quêtes du journal du guerrier Horde |
| `/wc questie` | Vérifier l'état de l'intégration optionnelle avec Questie |
| `/wc talents` | Diagnostic des points de talents disponibles et de leurs changements |
| `/wc gear` | Diagnostic de présence de GearQuest et explication des données vérifiables |
| `/wc weapons` | Afficher les identifiants d'équipement et les types lus en mains droite/gauche |
| `/wc spells` | Afficher le diagnostic du grimoire et la dernière nouveauté observée |
| `/wc fury` | Diagnostiquer si la classe guerrier est lisible et si les conseils Furie sont applicables |
| `/wc health` | Afficher les PV du personnage et la fiabilité de leur lecture |
| `/wc combat` | Voir les intervalles de combat et leur durée moyenne |
| `/wc history` | Afficher les 12 dernières activités réellement détectées |
| `/wc alerts on`, `/wc alerts off` | Activer ou couper les notifications automatiques |
| `/wc debug on`, `/wc debug off` | Activer le journal en mémoire ou le désactiver et l’effacer. Il est désactivé par défaut et limité à 100 entrées. |
| `/wc logs`, `/wc clear` | Afficher les 15 dernières traces ou vider le journal |
| `/wc help` | Retrouver les commandes en jeu |

## Compatibilité et tests

Les signatures ont été vérifiées dans les sources d’interface de Forever 1.60.1, build 71037. Les essais automatisés chargent les modules dans l’ordre du TOC et simulent les appels du client. La validation en jeu de la version 0.5.6-rc1 reste à faire. [Sources consultées et protocole en jeu](docs/TEST_PLAN.md)

Pour reproduire les contrôles de GitHub Actions depuis la racine du dépôt, installer Python 3, Lua 5.1 et Lua 5.4, puis exécuter le bloc dans un shell POSIX.

```sh
set -e
python3 tests/check_structure.py
for version in 5.1 5.4; do
  for file in Addon/WarriorCompanion/*.lua tests/*.lua; do
    "luac$version" -p "$file"
  done
  "lua$version" tests/test_addon.lua
  "lua$version" tests/test_activity.lua
  "lua$version" tests/test_combat.lua
  "lua$version" tests/test_performance.lua
  "lua$version" tests/test_dashboard.lua
done
```
