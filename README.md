# Warrior Companion

Warrior Companion observe la session de ton guerrier dans WoW Forever. Il fonctionne de façon autonome, sans trafic réseau ni itinéraire de quêtes. Le tableau de bord reste fermé jusqu’à la commande `/wc`.

## Ce que mesure la version 0.2.2

| Activité | Comportement |
| --- | --- |
| XP | Gain mesuré depuis le chargement ou `/wc reset`. L’XP/h est une moyenne de session affichée après une minute si la barre d’XP est lisible et active. Les transitions ambiguës peuvent retarder le total. Les niveaux intermédiaires manqués ne sont pas estimés. |
| Morts et combats | Compteur de morts et conseil dans le tableau après trois morts. L’état de combat suspend les notifications. Les dégâts, la durée et le nombre de combats restent hors du suivi actuel. |
| Quêtes et argent | Nombre de quêtes du journal, en excluant les en-têtes, et variation en cuivre depuis la première lecture disponible de la session. |
| Talents | Les points libres de classe et de spécialisation déclenchent une alerte hors combat, au plus une fois toutes les cinq minutes par session. Les autres conseils se lisent dans le tableau. |
| Compétences, métiers et équipement | Le journal de diagnostic peut signaler un changement de compétences ou d’équipement. L’analyse des rangs de métier et la comparaison des pièces restent à développer. |

L'historique d'activité conserve en mémoire vive les 60 derniers événements utiles : XP mesurée, niveaux, morts, modifications d'équipement, mises à jour des compétences et changements du nombre de quêtes. Il ne déduit ni l'objet obtenu ni la quête terminée. Utiliser `/wc history` pour afficher les 12 derniers événements. Un gain mesuré au changement de zone apparaît une seule fois. Pour l’équipement, deux emplacements lisibles distincts peuvent apparaître dans la même seconde. Les répétitions de la même description d’équipement ou de compétences sont filtrées pendant huit secondes parmi les entrées conservées. Le journal des activités est distinct du journal de debug et est effacé à `/wc reset`.

## Installation et commandes

Copier le dossier `Addon/WarriorCompanion` dans `Interface/AddOns/` du client Forever. Le fichier `WarriorCompanion.toc` doit se trouver directement dans `Interface/AddOns/WarriorCompanion/`. L’interface ciblée est `16001`.

| Commande | Effet |
| --- | --- |
| `/wc` | Ouvrir ou fermer le tableau des mesures et conseils |
| `/wc status` | Afficher la version, les mesures, les options et la présence des fonctions d’API |
| `/wc reset` | Recommencer les mesures et effacer l'historique de session |
| `/wc history` | Afficher les 12 dernières activités réellement détectées |
| `/wc alerts on`, `/wc alerts off` | Activer ou couper les notifications automatiques |
| `/wc debug on`, `/wc debug off` | Activer le journal en mémoire ou le désactiver et l’effacer. Il est désactivé par défaut et limité à 100 entrées. |
| `/wc logs`, `/wc clear` | Afficher les 15 dernières traces ou vider le journal |
| `/wc help` | Retrouver les commandes en jeu |

## Compatibilité et tests

Les signatures ont été vérifiées dans les sources d’interface de Forever 1.60.1, build 71037. Les essais automatisés chargent les modules dans l’ordre du TOC et simulent les appels du client. La validation en jeu de la version 0.2.2 reste à faire. [Sources consultées et protocole en jeu](docs/TEST_PLAN.md)

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
done
```
