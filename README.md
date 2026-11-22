# Warrior Companion

Warrior Companion observe la session de ton guerrier dans WoW Forever. Il fonctionne de façon autonome, sans trafic réseau ni itinéraire de quêtes. Le tableau de bord reste fermé jusqu’à la commande `/wc`.

## Ce que mesure la version 0.5.1-rc1

| Activité | Comportement |
| --- | --- |
| XP | Gain mesuré depuis le chargement ou `/wc reset`. L’XP/h est une moyenne de session affichée après une minute si la barre d’XP est lisible et active. Les transitions ambiguës peuvent retarder le total. Les niveaux intermédiaires manqués ne sont pas estimés. |
| Morts et combats | Compteur de morts et conseil dans le tableau après trois morts. L’état de combat suspend les notifications. La durée et le nombre d'intervalles d'état de combat sont maintenant suivis. Un intervalle n'est pas un ennemi tué ; les dégâts et la récupération restent non mesurés. |
| Quêtes et argent | Nombre de quêtes du journal, en excluant les en-têtes, et variation convertie en pièces d'or, d'argent et de cuivre avec leurs icônes, depuis la première lecture disponible de la session. |
| Talents | Les points libres de classe et de spécialisation déclenchent une alerte hors combat, au plus une fois toutes les cinq minutes par session. Les autres conseils se lisent dans le tableau. |
| Conseils guerrier Furie | Lorsque la classe guerrier est confirmée, le mode Furie cible conseille la récupération avec bandages ou nourriture en cas de PV bas et le contrôle des armes si au moins cinq phases de combat durent en moyenne 45 secondes ou plus. Ce sont des conseils informatifs, sans prétendre détecter la spécialisation actuelle. |
| Points de vie | Lecture sécurisée des PV du personnage, conseil de récupération **dans le tableau de bord uniquement** sous 35 % hors combat. Ne suggère pas de soin lorsqu'il est mort ou lorsque les valeurs sont indisponibles. |
| Compétences, métiers et équipement | Le journal de diagnostic peut signaler un changement de compétences ou d’équipement. L’analyse des rangs de métier et la comparaison des pièces restent à développer. |

L'analyse XP/h récente utilise une fenêtre glissante de 10 minutes, après au moins une minute d'observation, et inclut les périodes sans gain d'XP. Sa mémoire est limitée à 600 échantillons ; si cette limite masque un échantillon encore pertinent, le taux reste indisponible jusqu'à retrouver une fenêtre complète. Aucun conseil causal n'est déduit de ce chiffre.

L'historique d'activité conserve en mémoire vive les 60 derniers événements utiles : XP mesurée, niveaux, morts, modifications d'équipement, mises à jour des compétences et changements du nombre de quêtes. Il ne déduit ni l'objet obtenu ni la quête terminée. Utiliser `/wc history` pour afficher les 12 derniers événements. Un gain mesuré au changement de zone apparaît une seule fois. Pour l’équipement, deux emplacements lisibles distincts peuvent apparaître dans la même seconde. Les répétitions de la même description d’équipement ou de compétences sont filtrées pendant huit secondes parmi les entrées conservées. Le journal des activités est distinct du journal de debug et est effacé à `/wc reset`.

## Tableau de bord — direction artistique D (0.5.1-rc1)

Cette version reprend la direction **D : HUD WoW moderne, guerrier Horde** au-delà de la simple disposition. Elle embarque deux textures originales (`Textures/HordeSky.tga`, paysage rouge avec silhouettes de forteresse, et `Textures/Warcrest.tga`, bouclier guerrier) dans le ZIP. L'interface possède une armature métallique avec angles et rivets, des cartes cerclées de bronze, un bandeau illustré et une navigation latérale compacte.

Le **Bilan** montre simultanément quatre statistiques, les quêtes, la variation d'argent (or, argent, cuivre, signe global), les combats, le conseil prioritaire et les deux dernières activités. Les pages **Combat**, **Conseils** et **Journal** complètent les détails.

Les textures n'utilisent pas de code propriétaire de tiers. Le rendu exact, les proportions et la prise en charge TGA de Forever doivent être vérifiés en jeu : la CI ne teste pas le moteur graphique WoW.

## Installation et commandes

Copier le dossier `Addon/WarriorCompanion` dans `Interface/AddOns/` du client Forever. Le fichier `WarriorCompanion.toc` doit se trouver directement dans `Interface/AddOns/WarriorCompanion/`. L’interface ciblée est `16001`.

| Commande | Effet |
| --- | --- |
| `/wc` | Ouvrir ou fermer le tableau des mesures et conseils |
| `/wc status` | Afficher la version, les mesures, les options et la présence des fonctions d’API |
| `/wc reset` | Recommencer les mesures et effacer l'historique de session |
| `/wc performance` | Comparer XP/h globale et XP/h des dix dernières minutes |
| `/wc fury` | Diagnostiquer si la classe guerrier est lisible et si les conseils Furie sont applicables |
| `/wc health` | Afficher les PV du personnage et la fiabilité de leur lecture |
| `/wc combat` | Voir les intervalles de combat et leur durée moyenne |
| `/wc history` | Afficher les 12 dernières activités réellement détectées |
| `/wc alerts on`, `/wc alerts off` | Activer ou couper les notifications automatiques |
| `/wc debug on`, `/wc debug off` | Activer le journal en mémoire ou le désactiver et l’effacer. Il est désactivé par défaut et limité à 100 entrées. |
| `/wc logs`, `/wc clear` | Afficher les 15 dernières traces ou vider le journal |
| `/wc help` | Retrouver les commandes en jeu |

## Compatibilité et tests

Les signatures ont été vérifiées dans les sources d’interface de Forever 1.60.1, build 71037. Les essais automatisés chargent les modules dans l’ordre du TOC et simulent les appels du client. La validation en jeu de la version 0.5.1-rc1 reste à faire. [Sources consultées et protocole en jeu](docs/TEST_PLAN.md)

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
