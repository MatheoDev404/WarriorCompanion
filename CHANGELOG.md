# Changelog — Warrior Companion Build Planner

Les changements ci-dessous décrivent les **étapes fonctionnelles** du nouvel
addon. Les détails de chaque correctif restent consultables dans les commits
de la branche `feature/build-planner` et dans la PR #29. L'historique Git
conserve les anciennes versions de ce document.

## 0.6.4-test — 26 novembre 2026 — regroupement et reprise

- Le parcours détaillé ne recommande plus automatiquement les chapitres
  dont la fin est à plus de trois niveaux derrière le niveau réel. Les quêtes
  en cours ou prêtes à rendre, l'historique et la sélection manuelle restent
  accessibles ; aucune progression n'est modifiée.
- Avant de partir vers un objectif de combat distant, récupérer les quêtes
  du même chapitre dans un rayon de 5 points de carte si l'objectif actif
  est à plus de 10 points. Aucun regroupement entre cartes, en l'absence de
  position lisible, sur prérequis bloqué ou au détriment du rendu prioritaire.
- Les statuts des lignes visibles et de l'objectif sélectionné réutilisent
  le résultat du calcul de parcours ; tests de non-régression supplémentaires.
- Les 302 étapes sources, 20 modules, sauvegardes et licences restent intacts.
  Seuils heuristiques à ajuster après essai sur le client réel.

## 0.6.3-test — 26 novembre 2026 — audit et nettoyage

- Dépendances vérifiées depuis le `.toc` : **les 20 modules Lua, tous les
  outils développés, les sauvegardes et la licence historique sont conservés**.
  Le code de l'ancien `WarriorCompanion` demeure dans `main`.
- **Parcours optimisé** : une seule construction des 302 états de quêtes par
  rendu, avec réutilisation des statuts pour filtrer et choisir le prochain
  objectif. La logique des prérequis, de la sécurité et des étapes facultatives
  est conservée.
- **Métiers optimisés** : une seule construction des recettes/matériaux
  pour chaque mise à jour visuelle ; les stocks restent protégés en cas
  d'API illisible et la banque fermée n'est pas considérée disponible.
- Suppression du doublon documentaire dans l'addon, des spécifications
  d'architecture dépassées et des descriptions devenues incompatibles
  avec l'interface actuelle.
- **Paquet installable minimal** : `scripts/package_addon.py` produit un ZIP
  contenant uniquement l'addon, son manifeste, ses modules, sa licence et
  sa courte notice. La CI le publie en artefact après les tests.
- Nouvelle architecture consolidée dans
  `docs/ARCHITECTURE_ACTUELLE.md` et contrôles de non-régression enrichis.
- **À valider** : fonctionnement réel sur WoW Forever 1.60.1, interactions
  avec la minimap, glisser-déposer, API des métiers et flèche de direction.

## 0.6.2-test — 26 novembre 2026 — démarrage Forever

- Retrait de l'événement inconnu `PLAYERBANKBAGSLOTS_CHANGED`, responsable
  d'une erreur Lua lors de `RegisterEvent`.
- Enregistrement protégé des événements facultatifs et maintien du
  rafraîchissement du stock bancaire lors de l'ouverture et des événements
  pris en charge.
- Tests de refus d'événements et de fermeture/réouverture de la banque.

## 0.6.1-test — 26 novembre 2026 — HUD et réglages

- Flèche géométrique en trois traits bronze sans panneau opaque ni halo,
  zoom et position mémorisés, masquage complet sans cible.
- Réglages cliquables depuis le grand guide, le mini-bilan (OPT) et
  le clic molette de la minimap : modes, visibilité, alertes et saisie
  manuelle de secours des métiers.

## 0.6.0-test — 26 novembre 2026 — métiers

- Quatre guides de l'onglet Parcours : Leveling, Minage 1–300,
  Forge 1–300 et guide combiné Minage + Forge.
- Lecture des compétences, recettes, sacs, banque et équipements
  lorsque les API Forever sont disponibles.
- Calcul par petits lots, fonte intermédiaire, suivi de matériaux
  et données inconnues affichées comme telles.

## 0.5.0-test — 25 novembre 2026 — adaptation

- Modes Sécurité / XP rapide, regroupement des objectifs locaux,
  reprise après déviation et épingles manuelles.
- Détours facultatifs pour armes, armures, métiers et donjons ;
  pas de groupe imposé au joueur solo.

## 0.4.0–0.4.1-test — 25 novembre 2026 — guide et boussole

- Réintégration de **302 étapes historiques** du niveau 30–40,
  **285 coordonnées** et **217 actions de quêtes**.
- Conservation de la licence CC BY-NC-SA 4.0 du guide et suivi
  prudent des quêtes, prérequis et états du journal.
- Première boussole, puis HUD transparent.

## 0.3.0–0.3.7-test — 23–25 novembre 2026 — interfaces

- Trois arbres de talents côte à côte ; simulation et rangs réellement appris.
- Équipement par palier, infobulles natives, options de donjon et liens
  vers Parcours.
- Rotations mono/multi, buffs, priorités et temps de recharge.
- Mini-bilan de session, icône de minimap et protection contre les
  valeurs secrètes de Forever.

## 0.1.0–0.2.0-test — 23 novembre 2026 — fondations

- Nouveau `WarriorCompanionBuild` autonome, distinct du code historique.
- Plan de talents et équipement, premiers tests Lua 5.1/5.4,
  démarrage simple et sélection de niveau.

**Ce changelog n'est pas une preuve de validation in-game :** les
propositions de quêtes, coordonnées et recettes doivent toujours être
contrôlées sur le client Forever réel.
