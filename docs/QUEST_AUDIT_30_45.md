# Audit des quêtes / équipement — version de test 0.3.0

*23 novembre 2026, WoW Forever 1.60.1 — audit des données disponibles dans les guides et dans Zephras.*

Ce document sépare **niveau minimum affiché par le jeu**, **niveau conseillé pour la route**, **niveau requis pour équiper la récompense**, **réputation** et **confirmation des prérequis**. Une chaîne vue dans une base ne suffit pas pour affirmer qu'un PNJ propose une quête immédiatement.

## 1. Parcours pilote 30–40

Les étapes obligatoires du prototype sont des suggestions **de déplacement / regroupement des quêtes déjà connues**. Les quêtes de donjons, les longues chaînes Gelkis et les quêtes Elite sont **optionnelles**. Les chapitres hors 30–40 restent une vue indicative des zones.

| Groupe | Identifiants introduits | Conditions / risque |
|---|---|---|
| Regthar et entrée Désolace | 1361, 1362, 1365, 1366 | Chaîne Horde, guerre centaure ; 1365 implique un chef dangereux |
| Alliance Relations | 1431, 1432, 1433, 1434, 1435 | Orgrimmar → Désolace, satyres à Sargeron. Liens directs à confirmer en jeu |
| Gelkis, branche initiale | 1368 (Gelkis Alliance), 1370 (Stealing Supplies), 1373 (Ongeku), 1374 (premier Khan Jehn) | Choix de réputation face aux Magram ; 1374 n'est **pas** la quête récompensant la nouvelle masse |
| Gelkis, extension Forever | 93034, 93035, 93037, 93041, 93044, 93045 | Vallée des Os / Shen'dralas ; étapes facultatives, nombreuses conditions de réputation |
| Gelkis, fin de chaîne | 93058, 93062, 93122, 93128 | Honored Gelkis, zone élite et longue durée ; **non recommandée comme optimisation solo certaine** |

Sources de données individuelles : [Zephras chaîne 93128](https://zephras.com/forever/enUS/quest/93128/), [93122](https://zephras.com/forever/enUS/quest/93122/), [93034](https://zephras.com/forever/enUS/quest/93034/), [93035](https://zephras.com/forever/enUS/quest/93035/), [1374](https://zephras.com/forever/enUS/quest/1374/). Comparer la logique de hubs et trajets avec [ForeverTavern](https://forevertavern.net/guides/leveling/horde/desolace-34-36) et [wowforeverleveling](https://wowforeverleveling.com/guides/wow-forever-horde-leveling-guide). **Aucun contenu de guide tiers recopié.**

### Erreur de données trouvée pendant les contrôles

La masse **Bludgeon of Betrayed Virtues**, item **#271802**, est la récompense optionnelle de la quête Horde **Khan Jehn #93128** (niveau de quête 42, niveau minimum 35, objet **portable au niveau 35**) et non du premier **Khan Jehn #1374**, qui est une autre quête. La nouvelle quête exige **Honored Gelkis** et les étapes étendues de la chaîne aboutissant à **Checking Things Out #93122** (niveau de quête 43). Pour le parcours prudent du guerrier, la récompense n'est donc montrée comme objectif **qu'autour de 43**, avec avertissement de groupe et réputation ; elle ne constitue pas une amélioration immédiatement accessible au niveau 35/39.

La disponibilité réelle peut différer des données de la build 70938, car Zephras indique une build 71037 plus récente. Ne pas modifier la localisation des PNJ sans capture cliente.

## 2. Comparaison d'équipement du palier choisi

Le moteur donne un score de présentation **heuristique**, et non un DPS estimé ni un verdict sur ce qui est effectivement meilleur que les armes du personnage.

- **Mithril Shortsword #250607** : dague forgée, recette #1252356, Forge 180, niveau pour la porter 36. À comparer à l'arme réellement équipée avant de dépenser temps et composants. [Senseos](https://senseos.gg/wiki/wow-forever/items/250607/mithril-shortsword/).
- **Vanquisher's Sword #10823** : récompense Horde de Bring the End #3341 aux Souilles de Tranchebauge (donjon / groupe, quête à partir de 37). [EndgameTools](https://endgametools.com/en/wow-forever/items/10823).
- **Sword of Omen #6802** : quête Horde Into the Scarlet Monastery #1048 (donjon/groupe, quête min 33). [Wowhead](https://www.wowhead.com/forever/quest=1048).
- **Bludgeon of Betrayed Virtues #271802** : niveau objet 42, niveau de port 35, objectif de longue chaîne Horde Gelkis Honored ; un objet éligible au port n'est **pas forcément obtenable en leveling rapide**. [Zephras](https://zephras.com/forever/enUS/item/271802/).
- **Green Iron Hauberk #3844** : Forge 155, portable au niveau 31. [Wowhead](https://www.wowhead.com/forever/spell=3508).
- **Golden Scale Leggings #3843** : Forge **145 requis pour apprendre**, palier jaune **170** ; niveau requis 29. Confusion corrigée entre difficulté de recette et niveau de métier. [Zephras](https://zephras.com/forever/enUS/item/3843/).
- **Thrash Blade #17705** : Maraudon, option de groupe à partir du milieu des niveaux 40. [Wowhead](https://www.wowhead.com/forever/quest=7064).

**Règle de développement :** un objet est répertorié seulement avec une étape de quête ou de craft `routeId` et une source compatible Horde ; l'affichage trie par proximité du niveau et priorité aux armes, mais les objets de donjon ont un malus et les futures quêtes complexes sont différées. Le vrai gain dépend des armes actuellement équipées, du temps d'obtention et des compétences de Forge. La comparaison automatique de DPS n'est **pas encore** disponible.

## 3. Talents et rotation

Le plan initial `0/51/0` et le prototype hybride `13/38/0` utilisent les **mêmes données versionnées** : 3 arbres, 53 talents, 4 colonnes × 7 lignes, points prévus niveau par niveau. Leurs DPS n'ont **pas été mesurés**. Le client fournit les infobulles réelles lorsque disponibles. L'addon reconnaît les **familles de sorts apprises** via les noms localisés du grimoire, car un rang élevé n'implique pas qu'`IsPlayerSpell` reconnaisse l'ID du rang 1.

L'onglet Rotation distingue maintien des améliorations (Cri de guerre), ouverture, cycle de dégâts, réactions, cooldowns offensifs/défensifs. Fulgurance est placée dans **réactions** parce qu'elle dépend d'une esquive, **mais elle déclenche un GCD** (ne pas annoncer « hors GCD »). Les actions restent un guide éducatif sans lancement automatique.
