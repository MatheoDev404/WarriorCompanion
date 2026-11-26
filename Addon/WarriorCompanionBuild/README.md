# Warrior Companion Build — 0.6.3-test

**Addon autonome** pour WoW Forever 1.60.1 (`## Interface: 16001`).
Installation : placer ce dossier `WarriorCompanionBuild` dans
`World of Warcraft/Interface/AddOns/`, puis redémarrer le client.
Ne pas confondre avec l'ancien addon `WarriorCompanion` conservé dans la
branche Git `main`.

## Fonctionnalités conservées

- **Talents** : les 3 arbres Armes/Furie/Protection, allocations déjà investies,
  simulation de niveaux et choix Furie/hybride.
- **Équipement** : recommandations par palier, quêtes, forge et options de
  donjon ; icônes et infobulles, liaison vers le Parcours.
- **Parcours** : 302 étapes détaillées du niveau 30–40 (14 sections), quêtes
  suivies via le journal, prérequis connus, reprise après déviation, modes
  Sécurité/XP rapide et filtres Armes/Armure/Métiers/Donjons. Les niveaux hors
  30–40 ne sont pas encore exhaustifs.
- **Guides métiers** : Minage 1–300, Forge 1–300, guide combiné avec petits lots
  de fabrication, calcul des barres à fondre et des matériaux manquants,
  lecture des compétences, recettes, sacs et banque si accessible.
- **Rotation** : monocible/multicible, buffs, priorités et CD, avec les sorts
  et rangs réellement appris quand l'API du jeu les expose.
- **Boussole** : flèche nette sans fond, direction et distance en ligne droite,
  zoom et position mémorisés, masquée sans destination.
- **Mini-bilan** : XP, temps, morts, monnaie et conseils ; icône minimap et
  panneau Réglages, tous deux accessibles à la souris.

## Contrôles

**Minimap :** clic gauche = grand guide ; clic droit = mini-bilan ; clic molette
= réglages. Le bouton **OPT** du mini-bilan et **Réglages** sous les quatre
onglets ouvrent également la configuration.

**Parcours :** menu déroulant en haut pour changer de guide ; modes
XP/Sécurité, filtres facultatifs et bouton Reprendre. Chaque guide conserve
sa sélection et son défilement dans `WCBuildDB`.

**Saisie de secours :** les réglages permettent de saisir le rang et plafond
de Minage/Forge lorsque le client ne fournit pas les compétences ; une valeur
détectée par le jeu reste prioritaire.

Commandes facultatives de dépannage : `/wcb help`, `/wcb guide`,
`/wcb guide mixte`, `/wcb mode securite`, `/wcb mode xp`,
`/wcb reprendre`, `/wcb compass on/off`.

## Compatibilité et limites

L'événement `PLAYERBANKBAGSLOTS_CHANGED`, inconnu de Forever, n'est pas
enregistré. Les autres événements non indispensables sont protégés ; la
banque est rafraîchie uniquement lorsque l'API est disponible, et ses stocks
fermés sont exclus du calcul.

Les valeurs secrètes ou absentes du client ne doivent pas être comparées ni
utilisées comme des mesures connues. Aucune localisation de gisement,
distance intercontinentale, disponibilité de recette ou XP/heure n'est
inventée. Le guide aide à décider, il ne déplace pas le joueur et n'exécute
aucun sort.

Les tests hors jeu couvrent Lua 5.1/5.4, mais la compatibilité effective
des APIs, fenêtres et coordonnées doit être confirmée sur le client Forever.

## Licences, sources et attribution

**IMPORTANT — à conserver dans toute distribution :**

- Les 302 étapes 30–40 de `DetailedData30_40.lua` sont adaptées d'anciennes
  données **OpenXP/RestedXP** déjà présentes dans le dépôt. La licence
  **CC BY-NC-SA 4.0** est reproduite en entier dans
  [LICENSE-GUIDE.txt](LICENSE-GUIDE.txt). Attribution et conditions de
  redistribution non commerciale et de partage à l'identique applicables.
- Arbres de talents : [Zephras](https://zephras.com/data/), build 1.60.1,
  arrangement et données adaptées **CC BY 4.0** ; libellés de secours en
  français. Noms, graphismes et sorts © Blizzard Entertainment.
- Routes et quêtes : [ForeverTavern](https://forevertavern.net/),
  [Wowhead Forever](https://www.wowhead.com/forever/),
  [WoW Forever Leveling](https://wowforeverleveling.com/). Références de
  comparaison, pas des garanties de disponibilité dans le client.
- Métiers : [ForeverChanges](https://foreverchanges.pro/fr/professions/mining)
  et [Zephras — Forge](https://zephras.com/forever/enUS/profession-guide/164/).

Consulter les audits et l'architecture dans `docs/` à la racine du dépôt.
