# Revue et nettoyage du projet — 26 novembre 2026

Branche concernée : `feature/build-planner` ; point de départ avant la revue :
`2dc5b2254f` (0.6.2-test). Aucun changement sur `main`.

## Inventaire

- Un seul addon dans la branche : `Addon/WarriorCompanionBuild`.
- **20 modules Lua**, tous listés dans `WarriorCompanionBuild.toc`.
- Capacités préservées : 4 onglets, talents, équipements, rotation, mini-bilan,
  minimap, réglages, boussole, guide adaptatif 30–40, quatre parcours
  (Leveling, Minage, Forge, combiné).
- 302 étapes historiques, leur attribution et le texte de licence
  **CC BY-NC-SA 4.0** préservés.
- Aucune police ni texture externe dans ce module ; aucun ancien dossier
  `WarriorCompanion` à intégrer au paquet.
- L'historique du projet, les documents de recherche et les anciens outils
  restent consultables sur `main` et via Git.

## Nettoyage effectivement effectué

1. **Rendu Parcours** : suppression d'une seconde construction des 302 étapes
   à chaque actualisation ; une lecture par étape est partagée avec les filtres
   et la recommandation (pas de requête supplémentaire inutile).
2. **Guides métiers** : suppression de la double construction des étapes de
   Minage/Forge à chaque rafraîchissement, notamment des calculs de
   recettes et de matériaux.
3. **Code mort** : retrait de la fonction `ToggleCompact` devenue sans appel,
   de `AdaptiveOptionLabel` non utilisée et de l'initialisation du champ
   `professionManual` jamais exploité. Les anciennes clés présentes dans
   `WCBuildDB` ne sont pas supprimées.
4. **Documentation** : réécriture plus concise des deux README et du
   changelog, suppression des anciennes spécifications et de l'audit legacy
   devenus contradictoires. Les décisions de conservation des anciens outils
   sont documentées dans `ARCHITECTURE_ACTUELLE.md`.
5. **Distribution** : `scripts/package_addon.py` vérifie le `.toc`,
   interdit les modules Lua manquants/orphelins et construit un ZIP
   reproductible de l'addon seul. Test Python et artefact CI ajoutés.

## Mesures (fichiers du dépôt, hors historique Git)

| Mesure | Avant (0.6.2) | Après (0.6.3) |
|---|---:|---:|
| Taille totale des fichiers suivis | 471 526 octets | 433 042 octets |
| Contenu du dossier addon | 314 254 octets | 298 126 octets |
| Fichiers Lua dans l'addon | 20 | 20 |
| ZIP installable (compression niveau 9) | Aucun paquet dédié | 93 737 octets |
| Contenu du ZIP installable | — | 20 Lua + TOC + licence + README |

**Réduction nette des fichiers suivis : 38 484 octets (8,2 %)**,
malgré le maintien et l'ajout des tests et outils de distribution.

Le ZIP source complet de GitHub garde les tests, documents et scripts de
développement ; l'artefact `WarriorCompanionBuild-installable` est le
choix léger pour installer le jeu.

## Validation automatique

- Lua 5.1 et Lua 5.4 : syntaxe, talents, équipements, 4 onglets, rotations,
  quêtes et prérequis, route adaptative, boussole et valeurs secrètes,
  minimap et mini-bilan, Minage/Forge, reprise de progression.
- Test de performance de l'interface : **un appel** de construction du
  guide détaillé et **un appel** du planificateur métiers par rendu.
- Test Python : toutes les dépendances du TOC, licence incluse, aucune
  ressource orpheline, ZIP binaire reproductible avec 302 étapes.
- Le code de l'ancien addon n'a pas été modifié.

## Points volontairement conservés / non automatisés

- Les données du guide et sa licence (volume nécessaire et obligation légale).
- Les documents de recherche `RESEARCH_FOREVER.md` et audits de quêtes,
  utiles pour corriger les trajets et prérequis dans le client.
- Les API protégées par `pcall`, le comportement de repli lors de secrets et
  les événements optionnels : la prudence est préférable à une petite
  optimisation risquée.
- La comparaison exacte du DPS, le pathfinding réel, les recettes rares,
  les coordonnées de filons et la validation complète 1–60 **ne sont pas
  encore des fonctionnalités garanties**.

## Prochaine validation dans WoW Forever

Démarrage sans erreur Lua, clics sur la minimap, ouverture des Réglages,
affichage des trois arbres, détails d'équipement, bascule 302 étapes/synthèse,
reprise après changement de zone, rotation de la flèche et collecte
Minage/Forge. Les tests Lua simulés ne remplacent pas cette vérification.
