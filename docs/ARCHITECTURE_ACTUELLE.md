# Warrior Companion Build — Architecture maintenue

Version du présent inventaire : 26 novembre 2026. **Cette description concerne
la branche `feature/build-planner`** ; le code legacy est conservé dans `main`.

## Installation et dépendances

Le seul addon livrable se trouve dans `Addon/WarriorCompanionBuild/`.
`WarriorCompanionBuild.toc` est la **source de vérité** pour l'ordre de chargement
des scripts Lua. L'addon n'importe ni l'ancien `WarriorCompanion`, ni des images
`.tga`, polices, bibliothèques Lua tierces ou dépendances d'installation.
Les icônes et polices disponibles dans le client WoW sont utilisées.

`LICENSE-GUIDE.txt` est **indispensable** : le guide 30–40 historique et
ses attributions ne doivent jamais être distribués sans sa licence
CC BY-NC-SA 4.0. Pour les arbres de talents, voir également les crédits
Zephras et CC BY 4.0 dans le README. Les sources de recettes sont documentées
dans `ProfessionData.lua`.

## Carte des modules (tous conservés)

| Module | Responsabilité | Consommé par |
|---|---|---|
| `Data.lua`, `TalentTrees.lua` | talents, équipement, quêtes synthétiques | `Planner.lua`, `UI.lua` |
| `Spellbook.lua`, `CombatData.lua`, `Rotation.lua` | sorts appris, rotations mono/multi | `UI.lua`, `Core.lua` |
| `Planner.lua` | prévisualisation, validation build, équipement et journal | `UI.lua`, `DetailedGuide.lua` |
| `DetailedData30_40.lua` | données OpenXP conservées, 302 étapes | `DetailedGuide.lua` |
| `DetailedGuide.lua`, `AdaptiveRoute.lua` | états de quêtes, prérequis, hubs, mode XP/Sécurité | `UI.lua` |
| `Compass.lua` | flèche, coordonnées et distance protégées | `UI.lua`, `Core.lua`, `Settings.lua` |
| `ProfessionData.lua`, `ProfessionRuntime.lua`, `ProfessionPlanner.lua` | référentiels, lecture des métiers/sacs/banque, coûts de lots | `ProfessionUI.lua` |
| `UI.lua`, `ProfessionUI.lua` | talents, équipements, parcours, rotation et quatre guides | `Settings.lua`, `Core.lua` |
| `Session.lua`, `CompactDashboard.lua` | statistiques de session et mini-bilan | `Core.lua` |
| `Settings.lua`, `MinimapButton.lua` | réglages cliquables et accès minimap | `Core.lua` |
| `Core.lua` | démarrage, événements, commandes de secours | dernier module du `.toc` |

`WCBuildDB` contient les préférences et la progression. Ne pas purger les anciennes
clés des sauvegardes lors d'un nettoyage : elles peuvent provenir d'une version
déjà installée. Les valeurs protégées du client doivent rester filtrées avant
tout calcul ou comparaison.

## Conventions de performance

- Un seul calcul des statuts des **302 étapes** par rendu de l'onglet Parcours ;
  les listes visibles sont filtrées à partir de ce résultat.
- Un seul calcul de la liste de **recettes et matériaux** par rendu du guide
  Minage/Forge (pas deux appels à la même construction).
- Boussole mise à jour par cadence limitée ; totalement masquée sans objectif.
- Les scans de sacs et de banque ne s'exécutent que sur événements pertinents ;
  un stock illisible n'est jamais considéré comme zéro, une banque fermée
  reste périmée.
- Les événements non pris en charge par WoW Forever 1.60.1 ne doivent pas
  empêcher `PLAYER_ENTERING_WORLD` de fonctionner.

## Code historique, provenance et nettoyage

Le **vieux addon complet** demeure dans `main` (point de référence
`457a3c4`). Les essais d'UI, les anciennes textures et les tests legacy ne
font **pas** partie du paquet actuel. Le matériel réutilisé est copié
explicitement dans le nouveau module avec revue des licences et tests.

Anciens éléments à consulter si nécessaire : `Guide.lua` /
`Guides/Horde_*.lua` (OpenXP) ; `TalentPlan.lua`, `TalentLive.lua` ;
`EquipmentReview.lua`, `EquipmentTargets.lua`, `WeaponTargets.lua` ;
`QuestAdvisor.lua`, `QuestDiscovery.lua`, `QuestieBridge.lua`.
Le mini-bilan a été réimplémenté (ne pas restaurer l'ancien tableau de bord).
Aucune suppression du code de `main`, de commits ou de branches historiques
n'est effectuée par ce nettoyage.

## Vérification et distribution

- `python3 tests/check_structure.py` : manifeste, présence des dépendances,
  absence de dossiers legacy et de textures inutiles.
- `python3 scripts/package_addon.py --check` : vérifier les fichiers inclus.
- `python3 scripts/package_addon.py --output dist/WarriorCompanionBuild.zip` :
  archive **installable directement** dans `Interface/AddOns/`, ne contenant
  que `.toc`, modules Lua, README et licence, sans tests ni documents source.
- CI GitHub : contrôles syntaxiques `luac` et tests Lua **5.1 / 5.4**, audit
  des 302 étapes et scénario Minage/Forge.
- Confirmation dans WoW Forever nécessaire : API du client, HUD,
  navigabilité, prix/recettes/coordonnées, états de quêtes.
