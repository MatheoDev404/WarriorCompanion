# Changelog — Warrior Companion Build Planner

## 0.2.0-test — 23 novembre 2026

- Police sans empattement `Fonts\\ARIALN.TTF` (police intégrée au client, style moderne proche Roboto).
- Correction du problème de panneaux qui pouvaient masquer les textes : fonds rendus comme textures, sous les contrôles.
- **Talents :** contour doré sur le point obtenu exactement au niveau prévisualisé ; rangs déjà acquis plus discrets, détails accessibles et infobulles par rang.
- **Équipement :** icônes d'objets depuis l'API client, infobulles des vrais objets, détails de source, niveau et fabrication, lien direct avec l'étape du Parcours.
- **Parcours :** grande carte d'étape active et liste de suivantes lisibles, à la manière de PexGuide. Les quêtes de donjon restent facultatives.
- **Rotation :** quatrième onglet avec priorités indicatives monocible/multicible, icônes, conditions et infobulles ; pas de lancement automatique.
- Boutons `+` et `-` conservés pour adapter la taille. Suppression des commandes de mode `compact` et `grand`.
- L'ancien addon et ses tests sont conservés historiquement sur `main` mais retirés du contenu actif de la branche de développement.
- Tests de syntaxe et de comportement Lua 5.1/5.4 mis à jour.

## 0.1.0-test — 23 novembre 2026

- Prototype autonome à trois onglets Talents, Équipement et Parcours, profil Furie 1–60 et pilote de niveaux 30–40.
- Validation structurelle des 51 allocations, des seuils d'équipement et de la correspondance obligatoire équipement → quête/fabrication du parcours.

L'ancien historique du tableau de bord Warrior Companion est disponible dans la branche `main` et dans l'historique Git.
