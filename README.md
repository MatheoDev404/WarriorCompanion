# Warrior Companion | Build Planner

**Addon standalone WoW Forever, test 0.4.0.** Un guide de progression pour Guerrier mort-vivant Furie double maniement, pas un tableau de bord de combat.

## Installation

Télécharger la branche [`feature/build-planner`](https://github.com/MatheoDev404/WarriorCompanion/tree/feature/build-planner) puis copier le dossier `Addon/WarriorCompanionBuild` dans le dossier `Interface/AddOns/` de WoW Forever. Le dossier final doit contenir `WarriorCompanionBuild.toc`. Redémarrer le client.

**Minimap :** une icône ronde de guerrier, alignée selon la taille de la minimap comme GearQuest et les autres boutons, apparaît autour de la minimap, déplaçable en la faisant glisser. **Clic gauche** : ouvrir le guide complet ; **clic droit** : ouvrir le mini-bilan (un second clic ne ferme pas la vue, il faut utiliser **Fermer** ou `/wcb hide`) **304 × 88 px** (XP gagnée, temps, morts, solde de session et conseil). Dans le mini, le bouton **>>** ouvre le guide. Les positions sont conservées.

**Commandes :** `/wcb` ouvre/ferme le guide, `/wcb mini`, `/wcb full`, `/wcb hide`, et les onglets `/wcb talents`, `/wcb equipement`, `/wcb parcours`, `/wcb rotation`, `/wcb reel`. Pour les anciennes options : `/wcb reset` (remise à zéro du bilan), `/wcb autostart on/off` (ouverture auto désactivée par défaut), `/wcb alerts on/off` (ligne de conseil), `/wcb minimap on/off`. Taille du guide par `+`/`-` ; le mini conserve son format d'origine.

### Onglets
1. **Talents** : talents investis ambrés et non investis estompés, 3 arbres Armes/Furie/Protection affichés côte à côte, icônes et infobulles, **point du niveau consulté surligné en or**, plan Fury pure ou hybride 13/38, prévisualisation libre.
2. **Équipement** : quêtes, forge et butins de donjons sélectionnés (Hérode : casque/épaulières ; Glouton : hache 1M), **liste pleine largeur à la molette / glissière** (cinq objets visibles ; objets du niveau d'abord, futurs ensuite), icônes/infobulles natives, source du boss et bouton **Voir dans Parcours**. L'estimation n'est pas un calcul de DPS.
3. **Parcours** : **vue Guide détaillé 30–40 (302 étapes dans 14 sections)**, liste scrollable, reprise selon le niveau/les quêtes acceptées/la zone, étapes réellement acceptées, objectifs prêts et quêtes rendues suivis dans le journal. Un bouton bascule vers la vue synthétique précédente, conservée pour les quêtes d'équipement, métiers et donjons. Les autres tranches restent incomplètes.
4. **Rotation** : mode **monocible / multicible**, enchaînement d'ouverture, buffs à maintenir, boucle, réactions, gros CD offensifs/défensifs ; Fracasser armure sur cible résistante, rangs à apprendre chez le maître et grimoire par familles, jamais d'autocast.

### Nouvelle boussole et guide détaillé 30–40

- La flèche dirige vers les coordonnées de l'étape du guide sélectionnée et indique une **distance en ligne droite**, jamais un trajet routier. Si la position, le sens ou la zone est inaccessible, elle affiche une explication plutôt qu'un chiffre inventé. La flèche se déplace par glisser-déposer et sa position est enregistrée. `/wcb compass on/off` permet de l'activer ou la masquer ; `/wcb guide` ouvre directement le guide ; `/wcb guideaudit` affiche son inventaire.
- Les 302 étapes réimportées sont issues d'une adaptation antérieure OpenXP/RestedXP dans le dépôt. Leur licence **CC BY-NC-SA 4.0** et l'attribution sont conservées dans `DetailedData30_40.lua` et `LICENSE-GUIDE.txt`.
- **Audit du contenu** : 285 destinations dans 14 zones cartographiées ; 217 actions de quêtes renvoyant à 108 identifiants distincts, recoupés avec l'export de WoW Forever. Le comportement des 302 étapes **n'est pas encore validé individuellement en jeu**, notamment certains prérequis non documentés et des textes anglais qui subsistent.

### Important
- Ne pas confondre le pilote testable et une route de quêtes 1–60 intégralement validée.
- La disponibilité des descriptions et icônes d'objets dépend du cache du client WoW Forever. Les notes de secours ne se substituent pas aux statistiques du client.
- Police sans empattement WoW `Fonts\\ARIALN.TTF`, proche visuellement de Roboto, sans fichier externe fourni.
- Ancien addon archivé dans `main`. Seul le nouveau `WarriorCompanionBuild` est présent dans ce paquet.
- Licence et sources : [README du module](Addon/WarriorCompanionBuild/README.md), [recherche](docs/RESEARCH_FOREVER.md), [audit legacy](docs/LEGACY_AUDIT.md).

**À valider en jeu** : nouvel icône minimap, raccourcis gauche/droit, mini-bilan, valeurs protégées du client (affichées comme indisponibles), compteurs XP/monnaie, quatre onglets et absence de superpositions. Tests de règles, d'état de quêtes, de boussole et de maquettes Lua 5.1/5.4 ne remplacent pas les captures du client.
