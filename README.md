# Warrior Companion

Addon autonome pour **WoW Forever**, dédié au leveling d'un **guerrier mort-vivant Horde Furie à deux armes**, du niveau 1 au niveau 60. L'addon est un assistant de progression : il ne joue pas, ne dépense aucun point de talent et n'invente pas d'objectifs ou d'itinéraires.

## Installation

1. Ouvrir la branche `main` du [dépôt GitHub](https://github.com/MatheoDev404/WarriorCompanion), puis **Code → Download ZIP**.
2. Décompresser l'archive et copier **uniquement** `Addon/WarriorCompanion` dans `World of Warcraft/Interface/AddOns/`.
3. Vérifier que `Interface/AddOns/WarriorCompanion/WarriorCompanion.toc` existe, puis redémarrer le jeu.
4. À la connexion, le mini-bilan s'affiche si le démarrage automatique est activé.

Interface ciblée : `16001`. La compatibilité et le rendu réels doivent être testés dans le client Forever ; les tests Lua simulés ne remplacent pas cette validation.

## Interface actuelle

**Mini-bilan (304 × 88)** : XP gagnée sur la session, temps écoulé `HH:MM:SS`, morts, solde net avec **icônes or/argent/cuivre** et code couleur vert/rouge/gris, et une ligne de conseil. Il est déplaçable, avec position mémorisée. Bouton `>>` pour la fenêtre complète.

**Fenêtre complète (720 × 520)** : quatre rubriques simples, avec les fonctions regroupées dans des sous-onglets :

- **GUIDE** — **Étapes**, **Talents**, **Mes quêtes**, **À prendre**. Suivi du parcours Horde sous forme de quatre cartes d'étapes compactes, barre de progression et texte important mis en avant, puis arbre Furie 10–60.
- **CONSEILS** — **Conseils**, **Équipement**, **Santé**, **Armes**, **Sorts**. Données du personnage accessibles directement sans messages de diagnostic.
- **COMBAT** — **Combats**, **Performance**. Mesures de combat et taux d'XP sur la session et les dix dernières minutes.
- **RÉGLAGES** — boutons pour l'ouverture automatique, les notifications et la remise à zéro des compteurs de session.

Les anciennes commandes `/wc gear`, `health`, `weapons`, `spells`, `combat`, `performance` ouvrent désormais la sous-vue correspondante, mais ne sont plus nécessaires pour y accéder. `/wc guide`, `talents`, `quests`, `discover` sont également des raccourcis vers les sous-onglets du Guide.

Les commandes **techniques** (`/wc status`, `debug`, `logs`, `questie`, `fury`, `history`) restent disponibles dans le chat pour le développement et le diagnostic.

Les anciens onglets principaux **Bilan** et **Journal** ont été supprimés : ils ne reviennent pas dans les sous-onglets. La collecte limitée d'événements reste disponible pour les diagnostics, sans page visible. Fermer la grande fenêtre revient au mini-bilan.

## Guide de leveling

Le suivi visuel du guide reprend les principes de PexGuide (panneaux ardoise à coins arrondis, étapes empilées, accents or) grâce à une texture et une implémentation originales. Aucun fichier de PexGuide n'est intégré au paquet.\n\nLes six fichiers `Guides/Horde_*.lua` contiennent un parcours Horde **1–60** construit à partir d'un guide OpenXP existant. Attribution et licence conservées dans `Addon/WarriorCompanion/Guides/LICENSE-CC-BY-NC-SA-4.0.txt` (**CC BY-NC-SA 4.0**). Le guide utilise la progression mémorisée et permet de reprendre au niveau du personnage.

Les étapes de quête peuvent afficher le nom fourni par le client français. Les objectifs non confirmés conservent leur texte source ; certains noms et parcours importés restent à vérifier dans le jeu.

**Mes quêtes** classe les quêtes acceptées du journal. **À prendre** utilise, uniquement sur demande, les données de QuestieDB si elles sont accessibles : ce sont des pistes à vérifier, pas des quêtes garanties. Les quêtes explicitement élite, groupe ou donjon et les cas dangereux connus ne deviennent pas des recommandations solo certaines. Questie reste responsable de sa carte et de ses marqueurs.

L'ancien module de **regroupement des PNJ de départ** et la commande `/wc route` ont été retirés : ce regroupement ne produisait pas de véritable itinéraire de leveling.

## Talents Furie

Le sous-onglet **GUIDE → TALENTS** présente une grille simplifiée de **7 paliers et 18 talents**, et un ordre de **51 points du niveau 10 au niveau 60** pour un leveling Furie double maniement. Les boutons de navigation permettent de consulter un niveau différent.

Les niveaux, rangs maximum, prérequis et accès aux paliers sont contrôlés dans `TalentPlan.lua`. Voir [l'audit du parcours](docs/TALENT_AUDIT.md).

Le module `TalentLive.lua` essaie de récupérer **les noms localisés et les rangs actifs** via `C_Traits`. Si un talent est reconnu, le nom et le rang renvoyés par le client ont priorité. Au niveau actuel, un écart individuel avec le plan peut apparaître en rouge. Une lecture partielle ou impossible est signalée explicitement. **Aucune modification de talents n'est exécutée.** Il reste à confirmer la compatibilité effective de cette lecture avec le client Forever sur PC.

## Équipement, santé et conseils

Les propositions d'équipement sont prudentes : comparaison de pièces connues et de certains objets de sacs et de quêtes documentés, sans prétendre disposer de tout le catalogue du jeu. Des diagnostics de l'équipement, des armes, des sorts, de la santé et des combats restent disponibles pour tester les observations.

Les notifications importantes sont limitées en fréquence et désactivables. Les lectures indisponibles, protégées ou ambiguës ne deviennent pas des certitudes.

## Commandes utiles

| Commande | Fonction |
| --- | --- |
| `/wc` | Alterner mini-bilan et fenêtre complète |
| `/wc mini`, `/wc full` | Choisir une taille directement |
| `/wc guide` | Ouvrir les étapes du guide |
| `/wc talents` | Ouvrir les talents et diagnostiquer les points disponibles |
| `/wc quests`, `/wc discover` | Quêtes acceptées / pistes QuestieDB à vérifier |
| `/wc gear` | Afficher les conseils d'équipement |
| `/wc reset` | Remettre à zéro la session |
| `/wc autostart on/off` | Activer ou désactiver l'ouverture au login |
| `/wc alerts on/off` | Activer ou désactiver les notifications |
| `/wc advice`, `/wc settings` | Ouvrir Conseils / Réglages |
| `/wc status`, `/wc help` | Diagnostic général / aide |

Les commandes de debug `/wc status`, `fury`, `questie`, `history`, `debug on/off`, `logs` et `clear` restent disponibles, sans onglet supplémentaire.

## Développement et tests

La branche `main` contient les versions intégrées. Les refontes sont préparées dans des branches et vérifiées par **GitHub Actions Lua 5.1 / Lua 5.4**, contrôle du manifeste TOC, des fichiers TGA, de la syntaxe et des simulations de l'API.

Consulter le [plan de test actuel](docs/TEST_PLAN.md). Avant toute fusion, vérifier les régressions fonctionnelles, la pertinence des changements et la lisibilité dans le client Forever.

Historique des choix antérieurs : [CHANGELOG.md](CHANGELOG.md).
