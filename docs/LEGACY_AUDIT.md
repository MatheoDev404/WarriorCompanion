# Ancien Warrior Companion — conservation et retrait du package test

Date : 23 novembre 2026.

## Choix utilisateur
Ne conserver qu'un addon de progression de build actif. Retirer le vieux dashboard et ses tests du **nouvel ensemble de livraison**. L'ancien code demeure dans la branche `main` (commit de référence `457a3c4`), et dans l'archive non fusionnée de la PR #25. **Aucune suppression de `main` ni des historiques Git.**

## Fonctionnalités réutilisables à extraire explicitement à l'avenir
- `Guide.lua` + `Guides/Horde_*.lua` : structure historique de parcours OpenXP (licence CC BY-NC-SA 4.0, ne pas reprendre sans conservation de la licence / attribution).
- `TalentPlan.lua`, `TalentLive.lua`, `TalentObserver.lua` : accès protégé à `C_Traits` et vérification des rangs en jeu, à adapter au nouveau planner après audit des API Forever.
- `EquipmentReview.lua`, `EquipmentTargets.lua`, `WeaponTargets.lua` : premiers essais de comparaison des armes et statistiques, non utilisés dans le nouveau GearPlanner.
- `QuestAdvisor.lua`, `QuestDiscovery.lua`, `QuestieBridge.lua` : extraction conservatrice des données de quêtes de Questie et journal, réutilisation envisagée quand la route 1–60 aura été documentée.
- `CompactDashboard.lua`, `Activity.lua`, `Performance.lua` : statistiques de session hors sujet pour le nouveau guide ; **non portées**.
- `Dashboard.lua`, `Textures/*` : ancienne interface et ses visuels retirés de la nouvelle branche ; seule l'idée d'un thème sobre est conservée.

## Statut de migration
L'interface, le plan 51 points, les données d'équipement/route pilotes, les fonctionnalités de prévisualisation, les liens quêtes–objets, les infobulles de talent et les priorités de rotation sont **réimplémentés** dans `Addon/WarriorCompanionBuild/`. Le catalogue complet des quêtes 1–60, le comparateur automatique d'équipement et le lecteur complet `C_Traits` ne sont **pas** portés. Leur absence doit rester clairement documentée.

Le retrait est limité à la branche `feature/build-planner`. Pour réutiliser une ancienne fonction, choisir le fichier depuis `main`, contrôler sa licence, ne porter que le comportement requis et ajouter des tests indépendants.
