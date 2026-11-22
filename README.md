# Warrior Companion

Warrior Companion observe la session de ton guerrier dans WoW Forever. Il fonctionne de façon autonome, sans trafic réseau ni itinéraire de quêtes. Le tableau de bord **s'ouvre automatiquement à la connexion**, et un bouton portant l'écusson du guerrier est disponible sur le bord de la minimap pour le rouvrir ou le fermer.

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

## Fenêtre compacte et recalage minimap

Le tableau est désormais dessiné en **600 × 360 unités WoW** (contre 710 × 448), avec les mêmes statistiques et onglets. Les espacements et éléments décoratifs ont été réduits ; les conseils complets restent consultables dans l'onglet **Conseils**. L'écran Bilan montre seulement la première ligne du conseil pour éviter l'encombrement.

La position du bouton tient compte de la taille réelle de la minimap lorsque l'API est disponible. Une ancienne position peut être remise à l'angle de départ avec `/wc minimap reset`. Le glisser-déposer et la persistance sont conservés.

## Démarrage et icône de minimap

Le tableau de bord s'ouvre automatiquement **une fois à la connexion** (pas à chaque changement de zone). Une icône circulaire de 31 pixels s’attache au bord de la minimap comme les boutons des autres addons. Maintiens le clic gauche et glisse-la autour de la minimap pour choisir sa position ; elle est sauvegardée. Un clic gauche normal ouvre ou ferme la fenêtre. L'icône est créée au chargement, puis une nouvelle tentative est faite lors de l'entrée dans le monde si la minimap n'était pas encore disponible.

Le bouton utilise une icône guerrier native recadrée à 20 pixels, la bordure et le survol standard WoW ; il respecte aussi les minimaps carrées lorsque `GetMinimapShape` est disponible. Le démarrage automatique est activé par défaut. L'option est sauvegardée et peut être désactivée avec `/wc autostart off`, puis réactivée avec `/wc autostart on`. La commande `/wc` reste toujours disponible. Décocher l'addon dans l'écran AddOns empêche naturellement son chargement.

## Provenance des armes (GearQuest Forever)

GearQuest Forever est une source externe spécialisée pour rechercher des améliorations selon la classe, la spécialisation, le niveau, l'équipement porté, les quêtes, les boss et les vendeurs. Son classement dépend de pondérations internes et peut évoluer avec les mises à jour de Forever.

Warrior Companion ne recopie pas son catalogue ni son scoring et **n'affirme pas qu'un objet particulier est un meilleur choix** : son dépôt public ne comporte pas de licence clairement déclarée et aucune API publique stable d'export des recommandations n'a été identifiée. Lorsque GearQuest est chargé, un conseil informatif renvoie vers `/gq` après un changement de niveau ou d'équipement observé, afin de revoir **tous les emplacements** (armes, armure, bijoux et accessoires). Ce rappel expire après dix minutes. Cela évite les fausses informations, les prix HDV inventés et la duplication d'un système de classement complet.

Pour vérifier l'intégration, utiliser `/wc gear` puis ouvrir GearQuest avec `/gq`. **GearQuest est optionnel** et Warrior Companion reste autonome sans lui. Le suivi des armes demeure disponible avec `/wc weapons`.

Références : [GearQuest Forever](https://github.com/Henrik8210/gear-quest-forever) et [fiche de l'addon](https://www.curseforge.com/wow/addons/gearquest-forever).

## Points de talents (0.6.0-rc1)

Le module `TalentObserver.lua` utilise `C_ClassTalents.HasUnspentTalentPoints` lorsque disponible pour afficher les points disponibles (classe + spécialisation). Il retient les changements observés après des événements de talents, sans les présenter comme un talent précis dépensé : une respécialisation ou une mise à jour serveur peut aussi expliquer la différence. Si la lecture échoue, aucun chiffre n'est inventé.

Commande `/wc talents` pour vérifier les compteurs et le nombre de changements observés. Le rappel déjà existant des points non dépensés continue de fonctionner. **L'arbre Furie et la recommandation d'un talent précis ne sont pas encore validés dans le client Forever.**

## Conseiller de quêtes Horde Furie (0.6.0-rc1)

Le module `QuestAdvisor.lua` classe **les quêtes déjà acceptées** et présentes dans le journal du personnage guerrier Horde. Il distingue les quêtes prêtes à rendre, les candidates solo en dessous du niveau du joueur, les quêtes proches du niveau nécessitant de la prudence, les quêtes plus hautes, et les marqueurs explicitement signalés groupe/donjon/élite. Si le client ne fournit pas un type fiable, le statut reste **inconnu**, sans être converti en solo.

Le niveau d'une quête **n'est pas** le niveau précis de ses ennemis ; aucune récompense, difficulté réelle, temps de trajet, XP/h ou prérequis d'une quête non acceptée n'est inventé. Le journal du personnage Horde ne prouve pas qu'une quête soit exclusive à la Horde.

**Questie** conserve l'affichage de ses marqueurs sur minimap et carte. Warrior Companion n'en crée aucun deuxième. L'intégration optionnelle utilise `Questie.API.isReady`, `RegisterOnReady` et `RegisterForQuestUpdates` documentés publiquement pour actualiser nos conseils, avec un repli sur `QUEST_LOG_UPDATE` du client si Questie n'est pas disponible. Aucun accès aux tables internes de Questie et aucune dépendance obligatoire.

Commandes : `/wc quests` affiche un classement prudent jusqu'à cinq quêtes ; `/wc questie` vérifie si Questie est détecté et prêt.

**À développer ensuite** : propositions de quêtes *non encore acceptées* avec faction, prérequis, chaîne et source contrôlés via une base de données compatible Forever, et validation du niveau réel des ennemis pour un guerrier Furie prudent.

Sources de l'API : [Questie — API publique](https://github.com/Questie/Questie/blob/master/Public/README.md), [Questie — notifications](https://github.com/Questie/Questie/blob/master/Public/RegisterForQuestUpdates.lua).

## Installation et commandes

Copier le dossier `Addon/WarriorCompanion` dans `Interface/AddOns/` du client Forever. Le fichier `WarriorCompanion.toc` doit se trouver directement dans `Interface/AddOns/WarriorCompanion/`. L’interface ciblée est `16001`.

| Commande | Effet |
| --- | --- |
| `/wc autostart on`, `/wc autostart off` | Activer/désactiver l'ouverture automatique à la prochaine connexion |
| `/wc` | Ouvrir ou fermer le tableau des mesures et conseils |
| `/wc status` | Afficher la version, les mesures, les options et la présence des fonctions d’API |
| `/wc reset` | Recommencer les mesures et effacer l'historique de session |
| `/wc performance` | Comparer XP/h globale et XP/h des dix dernières minutes |
| `/wc minimap reset` | Replacer le bouton sur le bord de la minimap à sa position par défaut |
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
