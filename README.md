# Warrior Companion | Build Planner

**Addon standalone WoW Forever, test 0.3.0.** Un guide de progression pour Guerrier mort-vivant Furie double maniement, pas un tableau de bord de combat.

## Installation

Télécharger la branche [`feature/build-planner`](https://github.com/MatheoDev404/WarriorCompanion/tree/feature/build-planner) puis copier le dossier `Addon/WarriorCompanionBuild` dans le dossier `Interface/AddOns/` de WoW Forever. Le dossier final doit contenir `WarriorCompanionBuild.toc`. Redémarrer le client.

**Commande :** `/wcb` ouvre ou ferme le guide. `/wcb talents`, `/wcb equipement`, `/wcb parcours`, `/wcb rotation`, `/wcb reel` naviguent ou remettent le niveau automatique. **La taille se règle avec les boutons `+` et `-`, sans mode compact séparé.**

### Onglets
1. **Talents** : 3 arbres Armes/Furie/Protection, icônes et infobulles, **point du niveau consulté surligné en or**, plan Fury pure ou hybride 13/38, prévisualisation libre.
2. **Équipement** : quêtes et fabrication seulement, **4 objets classés par pertinence du palier choisi**, icônes/infobulles, niveau, source et bouton **Voir dans Parcours**. L'estimation n'est pas un calcul de DPS.
3. **Parcours** : grande carte active, étapes suivantes façon PexGuide, plusieurs chaînes Horde 30–40 (Désolace) sourcées, Gelkis longue option 42–43 ; quêtes de groupe facultatives. Hors pilote, zones 1–60 non validées.
4. **Rotation** : mode **monocible / multicible**, enchaînement d'ouverture, buffs à maintenir, boucle, réactions, gros CD offensifs/défensifs ; grimoire par familles/rangs, jamais d'autocast.

### Important
- Ne pas confondre le pilote testable et une route de quêtes 1–60 intégralement validée.
- La disponibilité des descriptions et icônes d'objets dépend du cache du client WoW Forever. Les notes de secours ne se substituent pas aux statistiques du client.
- Police sans empattement WoW `Fonts\\ARIALN.TTF`, proche visuellement de Roboto, sans fichier externe fourni.
- Ancien addon archivé dans `main`. Seul le nouveau `WarriorCompanionBuild` est présent dans ce paquet.
- Licence et sources : [README du module](Addon/WarriorCompanionBuild/README.md), [recherche](docs/RESEARCH_FOREVER.md), [audit legacy](docs/LEGACY_AUDIT.md).

**À valider en jeu** : quatre onglets, taille, infobulles, noms locaux, icônes d'objets, absence de superpositions. Tests de règles et maquettes Lua 5.1/5.4 ne remplacent pas les captures du client.
