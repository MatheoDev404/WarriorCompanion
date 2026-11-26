# Warrior Companion | Build Planner

**Addon standalone WoW Forever, test 0.6.1.** Un guide de progression pour Guerrier mort-vivant Furie double maniement, pas un tableau de bord de combat.

## Installation

Télécharger la branche [`feature/build-planner`](https://github.com/MatheoDev404/WarriorCompanion/tree/feature/build-planner) puis copier le dossier `Addon/WarriorCompanionBuild` dans le dossier `Interface/AddOns/` de WoW Forever. Le dossier final doit contenir `WarriorCompanionBuild.toc`. Redémarrer le client.

**Minimap :** une icône ronde de guerrier, alignée selon la taille de la minimap comme GearQuest et les autres boutons, apparaît autour de la minimap, déplaçable en la faisant glisser. **Clic gauche** : ouvrir le guide complet ; **clic droit** : ouvrir le mini-bilan ; **clic molette** : ouvrir les réglages (un second clic ne ferme pas la vue, il faut utiliser **Fermer** ou `/wcb hide`) **304 × 88 px** (XP gagnée, temps, morts, solde de session et conseil). Dans le mini, le bouton **>>** ouvre le guide. Les positions sont conservées.

**Commandes :** `/wcb` ouvre/ferme le guide, `/wcb mini`, `/wcb full`, `/wcb hide`, et les onglets `/wcb talents`, `/wcb equipement`, `/wcb parcours`, `/wcb rotation`, `/wcb reel`. Pour les anciennes options : `/wcb reset` (remise à zéro du bilan), `/wcb autostart on/off` (ouverture auto désactivée par défaut), `/wcb alerts on/off` (ligne de conseil), `/wcb minimap on/off`. Taille du guide par `+`/`-` ; le mini conserve son format d'origine.

### Onglets
1. **Talents** : talents investis ambrés et non investis estompés, 3 arbres Armes/Furie/Protection affichés côte à côte, icônes et infobulles, **point du niveau consulté surligné en or**, plan Fury pure ou hybride 13/38, prévisualisation libre.
2. **Équipement** : quêtes, forge et butins de donjons sélectionnés (Hérode : casque/épaulières ; Glouton : hache 1M), **liste pleine largeur à la molette / glissière** (cinq objets visibles ; objets du niveau d'abord, futurs ensuite), icônes/infobulles natives, source du boss et bouton **Voir dans Parcours**. L'estimation n'est pas un calcul de DPS.
3. **Parcours** : **sélecteur de quatre guides (Leveling, Minage 1–300, Forge 1–300 et Minage + Forge 1–300)**. Le guide de leveling garde sa **vue Guide détaillé 30–40 (302 étapes dans 14 sections)**, enrichie avec les **détours facultatifs** par catégorie (Armes, Armure, Métiers, Donjons), les modes **Sécurité / XP rapide**, le regroupement par zone et la sélection dynamique selon le niveau et le journal. Bouton **Reprendre** pour recalculer après une déviation, et possibilité de sélectionner manuellement une étape. La vue synthétique précédente reste disponible pour les équipements et les quêtes particulières. Les autres tranches restent incomplètes.
4. **Rotation** : mode **monocible / multicible**, enchaînement d'ouverture, buffs à maintenir, boucle, réactions, gros CD offensifs/défensifs ; Fracasser armure sur cible résistante, rangs à apprendre chez le maître et grimoire par familles, jamais d'autocast.

### Nouveaux guides Minage et Forge 1–300 (0.6.0-test)

- **Dans l’onglet Parcours**, ouvrir le menu « Guide : ... » pour changer entre **Leveling**, **Minage**, **Forge** et **Minage + Forge**. Chaque guide conserve sa sélection, son défilement et ses étapes validées manuellement.
- **Suivi automatique** des compétences et plafonds (`GetProfessions / GetProfessionInfo`), des recettes connues (`C_TradeSkillUI` quand la fenêtre de métier est ouverte), des matériaux en sacs et de la banque uniquement quand ses données sont accessibles. Les recettes et emplacements illisibles sont signalés ; les données de banque non rafraîchies ne sont pas soustraites des besoins.
- **Guide Minage** : filons et seuils 1–300, zones recommandées pour la Horde selon le niveau du personnage ; possibilité de fonte en fonction des stocks et des recettes connues. Aucune position exacte de filon inventée.
- **Guide Forge** : paliers 1–300 et recettes cibles sourcées Forever ; petits lots de cinq créations maximum, estimation prudente des gains non garantis, vérification des plans et composants en jeu, distinction des créations d’équipement et des consommables.
- **Guide combiné** : premier objectif de Minage 169 → 175 et Forge 127 → 129 (puis paliers suivants) dans le scénario de départ. Le calcul déduit les barres et minerais réellement recensés, propose la fonte des barres manquantes si la recette est accessible, et évite de planifier un stock 1–300 inutile. Les achats ne sont jamais automatiques.
- **Commandes** : `/wcb guide minage`, `/wcb guide forge`, `/wcb guide mixte`, `/wcb guide leveling`, `/wcb metier set minage N CAP`, `/wcb metier set forge N CAP`. Saisie manuelle réservée aux compétences non fournies par le client.
- **Limites** : certaines recettes rares, les spécialités, les circuits exacts de filons et les PNJ/coordonnées détaillés doivent encore être vérifiés. Les autres métiers (Cuisine, Pêche, Secourisme) pourront être ajoutés au registre sans remplacer l’architecture.

### Réglages accessibles dans l'interface (0.6.1)

- **Sans commande à taper** : bouton **Réglages** sous les quatre onglets de la grande fenêtre, bouton **OPT** sur le mini-bilan ou clic **molette** sur l’icône de la minimap.
- Le panneau permet : **activer/masquer la boussole**, changer sa taille de 75 à 135 %, remettre la flèche au centre, afficher le mini-bilan, modifier l’ouverture automatique, les alertes et la présence de l’icône minimap ; passer entre **XP rapide / Sécurité**, ouvrir ou reprendre le Parcours, lancer l’audit des étapes, réinitialiser les statistiques et masquer les fenêtres.
- Deux champs **Minage / Forge** avec rang et maximum offrent une **saisie manuelle de secours** lorsque le client ne sait pas lire la compétence. Une valeur détectée en jeu reste prioritaire.
- La boussole a désormais une **flèche géométrique très nette en trois traits**, sans halo, ombre de silhouette ni fond. Elle disparaît complètement lorsqu’aucune cible de navigation n’est sélectionnée : pas de texte parasite à l'écran.

### Nouvelle boussole et guide détaillé 30–40

- La boussole est désormais un **HUD transparent** : une flèche nette dessinée en trois traits bronze (taille réglable), sans halo ni panneau opaque, accompagnée d'une distance et d'un nom d'objectif discrets. On la déplace en glissant la flèche ; la zone transparente ne bloque pas les clics du jeu. Elle dirige vers les coordonnées de l'étape du guide sélectionnée et indique une **distance en ligne droite**, jamais un trajet routier. Si la position, le sens ou la zone est inaccessible, elle affiche une explication plutôt qu'un chiffre inventé. La flèche se déplace par glisser-déposer et sa position est enregistrée. `/wcb compass on/off` permet de l'activer ou la masquer ; `/wcb guide` ouvre directement le guide ; `/wcb guideaudit` affiche son inventaire.
- Les 302 étapes réimportées sont issues d'une adaptation antérieure OpenXP/RestedXP dans le dépôt. Leur licence **CC BY-NC-SA 4.0** et l'attribution sont conservées dans `DetailedData30_40.lua` et `LICENSE-GUIDE.txt`.
- **Audit du contenu** : 285 destinations dans 14 zones cartographiées ; 217 actions de quêtes renvoyant à 108 identifiants distincts, recoupés avec l'export de WoW Forever. Le comportement des 302 étapes **n'est pas encore validé individuellement en jeu**, notamment certains prérequis non documentés et des textes anglais qui subsistent.

### Étape B — Parcours adaptatif

- **Sécurité** (par défaut) privilégie les objectifs solo à un palier compatible avec le niveau réel, en pénalisant les étapes au-dessus du niveau actuel. **XP rapide** autorise un palier supérieur d'un niveau et privilégie davantage le regroupement des objectifs voisins. Ces règles reposent sur les niveaux des *sections du guide*, pas sur une lecture exacte des niveaux des ennemis ; il n'y a pas encore de mesure XP/heure intégrée au moteur.
- **Reprise après déviation** : changement de zone, niveau ou état de quête → nouvelle proposition. Une sélection manuelle est épinglée tant qu'elle est pertinente, puis libérée si son objectif disparaît ou si le personnage change de zone.
- **Détours facultatifs** : quatre filtres Armes / Armure / Métiers / Donjons dans le Parcours. Les options sont associées aux sections correspondantes, sans coordonnées inventées et sans imposer de donjon au Guerrier solo.
- Commandes : `/wcb mode securite`, `/wcb mode xp`, `/wcb reprendre` et `/wcb guide`. Les filtres et le mode sont mémorisés dans `WCBuildDB`.

### Important
- Ne pas confondre le pilote testable et une route de quêtes 1–60 intégralement validée.
- La disponibilité des descriptions et icônes d'objets dépend du cache du client WoW Forever. Les notes de secours ne se substituent pas aux statistiques du client.
- Police sans empattement WoW `Fonts\\ARIALN.TTF`, proche visuellement de Roboto, sans fichier externe fourni.
- Ancien addon archivé dans `main`. Seul le nouveau `WarriorCompanionBuild` est présent dans ce paquet.
- Licence et sources : [README du module](Addon/WarriorCompanionBuild/README.md), [recherche](docs/RESEARCH_FOREVER.md), [audit legacy](docs/LEGACY_AUDIT.md).

**À valider en jeu** : nouvel icône minimap, raccourcis gauche/droit, mini-bilan, valeurs protégées du client (affichées comme indisponibles), compteurs XP/monnaie, quatre onglets et absence de superpositions. Tests de règles, d'état de quêtes, de boussole et de maquettes Lua 5.1/5.4 ne remplacent pas les captures du client.
