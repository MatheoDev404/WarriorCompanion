# Warrior Companion | Build Planner

Addon autonome de leveling **Guerrier Furie Horde** pour **WoW Forever 1.60.1**.
Version de test **0.6.4-test** (regroupement de quêtes et reprise adaptative).
La branche `feature/build-planner` est indépendante de l'ancien addon
`WarriorCompanion` conservé dans `main`.

## Installation

1. Télécharger l'archive optimisée depuis les **artefacts du dernier test GitHub
   réussi** : [Actions — Build Planner validation](https://github.com/MatheoDev404/WarriorCompanion/actions/workflows/tests.yml).
   L'artefact `WarriorCompanionBuild-installable` contient uniquement l'addon.
   En secours : [ZIP de toute la branche](https://github.com/MatheoDev404/WarriorCompanion/archive/refs/heads/feature/build-planner.zip)
   puis extraire **uniquement** `Addon/WarriorCompanionBuild/`.
2. Mettre `WarriorCompanionBuild` dans `World of Warcraft/Interface/AddOns/`.
   Le fichier `Interface/AddOns/WarriorCompanionBuild/WarriorCompanionBuild.toc`
   doit être présent directement dans ce dossier.
3. Désactiver temporairement l'ancien `WarriorCompanion` si installé, puis
   **redémarrer** le client.
4. Si un message Lua apparaît, relever le texte exact et la première ligne
   de la pile, pour notre campagne de tests en jeu.

Les options et progressions de `WCBuildDB` sont conservées lors d'une mise
à jour du dossier de l'addon.

## Utilisation sans commandes

- **Icône minimap** : gauche = grande fenêtre ; droit = mini-bilan ; molette =
  réglages. L'icône est déplaçable.
- **Grande fenêtre** : quatre onglets **Talents**, **Équipement**, **Parcours**,
  **Rotation** ; prévisualisation de niveau, infobulles et navigation.
- **Parcours** : choisir parmi **Leveling 1–60**, **Minage 1–300**,
  **Forge 1–300**, **Minage + Forge 1–300**. Pour le leveling : segment
  détaillé 30–40 (302 étapes), mode Sécurité ou XP rapide, étapes Armes,
  Armure, Métiers, Donjons facultatives, suivi du journal et bouton Reprendre.
- **Boussole** : flèche géométrique transparente, distance en ligne droite,
  déplaçable ; masquée s'il n'y a pas d'objectif. Taille configurable.
- **Mini-bilan** : XP, temps, morts, solde de session et conseil contextuel.
  Le bouton **OPT** ouvre les réglages.
- **Réglages** : boussole, minimap, affichage, mode de parcours, audit,
  réinitialisation de session et saisie des métiers si le jeu ne les fournit
  pas. Pas besoin de saisir une commande.

En secours : `/wcb help`, `/wcb guide`, `/wcb mini`,
`/wcb mode securite`, `/wcb mode xp`, `/wcb reprendre`,
`/wcb compass on/off`, `/wcb guide mixte`.

## Fiabilité et limites

- Les **302 étapes du segment 30–40** sont issues d'une ancienne adaptation
  OpenXP/RestedXP. **285** contiennent une position et **217** une action de
  quête ; les coordonnées, PNJ et prérequis restent à valider individuellement
  en jeu. Les autres tranches de leveling ne sont pas exhaustives.
- Les modes Sécurité/XP rapide utilisent des **heuristiques de palier et de
  distance**, pas une mesure XP/heure ni le niveau exact de chaque ennemi.
  Le guide écarte des suggestions automatiques les chapitres dont la fin
  est à plus de 3 niveaux derrière le joueur (sauf quêtes actives ou à rendre).
  Avant de quitter un hub, il propose les prises de quêtes proches du même
  chapitre si les objectifs actifs sont éloignés. Seuils heuristiques exprimés
  en points de carte, jamais en mètres. Les choix manuels restent disponibles.
- Le guide Minage/Forge recalcule des lots courts avec le stock lisible,
  les recettes connues et les seuils de métier ; les plans rares et les
  zones de récolte restent des propositions à vérifier. Pas d'achats ni
  d'actions de jeu automatiques.
- Les API renvoyant une valeur secrète ou manquante doivent être ignorées
  sans inventer des coordonnées ou un solde. Les événements facultatifs
  incompatibles avec Forever sont protégés.

## Maintenance et provenance

- [Architecture et dépendances](docs/ARCHITECTURE_ACTUELLE.md)
- [Rapport de revue et nettoyage](docs/REVUE_NETTOYAGE_2026-11-26.md)
- [Recherche spécifique WoW Forever](docs/RESEARCH_FOREVER.md)
- [Audit de quêtes 30–45](docs/QUEST_AUDIT_30_45.md)
- [Tests du pilote](docs/PILOT_30_40_TEST.md)
- [Méthode GitHub](docs/GITHUB_WORKFLOW.md)
- [Changelog](CHANGELOG.md)

Le guide historique est distribué avec `LICENSE-GUIDE.txt`, sous **CC BY-NC-SA
4.0**, avec conservation de l'attribution dans `DetailedData30_40.lua`.
Les données adaptées des arbres de talents proviennent notamment de
[Zephras](https://zephras.com/data/) (arrangement sous **CC BY 4.0**).
Les noms, graphismes et sorts du jeu appartiennent à Blizzard Entertainment.

**Validation automatique :** syntaxe et tests Lua 5.1/5.4, guide, métiers,
interface, minimap et boussole. Cela **ne remplace pas** un test sur le client
WoW Forever réel.
