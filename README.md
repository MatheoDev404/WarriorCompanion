# Warrior Companion | Build Planner

**Addon standalone WoW Forever, test 0.2.0.** Un guide de progression pour Guerrier mort-vivant Furie double maniement, pas un tableau de bord de combat.

## Installation

Télécharger la branche [`feature/build-planner`](https://github.com/MatheoDev404/WarriorCompanion/tree/feature/build-planner) puis copier le dossier `Addon/WarriorCompanionBuild` dans le dossier `Interface/AddOns/` de WoW Forever. Le dossier final doit contenir `WarriorCompanionBuild.toc`. Redémarrer le client.

**Commande :** `/wcb` ouvre ou ferme le guide. `/wcb talents`, `/wcb equipement`, `/wcb parcours`, `/wcb rotation`, `/wcb reel` naviguent ou remettent le niveau automatique. **La taille se règle avec les boutons `+` et `-`, sans mode compact séparé.**

### Onglets
1. **Talents** : arbre Furie avec icônes, info-bulles, rangs, **point gagné au niveau consulté surligné en or**, prévisualisation de tous les niveaux.
2. **Équipement** : quêtes et fabrication seulement, objets avec icônes et infobulles du client, niveau et source, bouton **Voir dans Parcours**.
3. **Parcours** : grande carte de l'étape active, étapes suivantes comme PexGuide. Le pilote 30–40 est indicatif et les quêtes de groupe sont optionnelles. Hors 30–40, simple plan de zones 1–60 marqué non vérifié.
4. **Rotation** : priorités **monocible / multicible** selon le niveau, sorts et conditions, jamais d'autocast.

### Important
- Ne pas confondre le pilote testable et une route de quêtes 1–60 intégralement validée.
- La disponibilité des descriptions et icônes d'objets dépend du cache du client WoW Forever. Les notes de secours ne se substituent pas aux statistiques du client.
- Police sans empattement WoW `Fonts\\ARIALN.TTF`, proche visuellement de Roboto, sans fichier externe fourni.
- Ancien addon archivé dans `main`. Seul le nouveau `WarriorCompanionBuild` est présent dans ce paquet.
- Licence et sources : [README du module](Addon/WarriorCompanionBuild/README.md), [recherche](docs/RESEARCH_FOREVER.md), [audit legacy](docs/LEGACY_AUDIT.md).

**À valider en jeu** : quatre onglets, taille, infobulles, noms locaux, icônes d'objets, absence de superpositions. Tests de règles et maquettes Lua 5.1/5.4 ne remplacent pas les captures du client.
