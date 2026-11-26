# WoW Forever — Recherche initiale comparée

**23 novembre 2026 — phase de conception**, non une route validée et non une liste définitive d'équipement. Toujours recontrôler les données de jeu (build / hotfix) et les quêtes en jeu. Sources Web à comparer et non pas à copier intégralement.

## 1. Parcours de quêtes — quelles sources comparer ?

| Référence | Intérêt | Limite |
|---|---|---|
| [Wowhead Forever / prérequis donjon](https://www.wowhead.com/news/new-prerequisites-required-for-ruins-of-lordaeron-dungeon-quests-in-wow-forever-383769) | Exemples de prérequis **modifiés en live** | Concerne une sélection de quêtes |
| [WoW Forever leveling](https://wowforeverleveling.com/guides/wow-forever-horde-leveling-guide) | Ordre général des régions + contenu nouveau | De nombreuses tranches >30 restent un plan, pas une route chronométrée |
| [wow.gg Horde zones](https://wow.gg/guides/wow-forever-leveling-horde) | Niveaux et alternatives de zones par tranche | Donne des zones, pas un prérequis par quête |
| [Icy Veins / quêtes de classe](https://www.icy-veins.com/wow-forever/warrior-class-quests) | Postures, étapes Guerrier, armes de quête | La disponibilité exacte doit être revalidée au niveau / faction |
| [Eternadex / quests](https://eternadex.com/en/) | IDs, récompenses, prérequis, PNJ et coordonnées | Couverture et exactitude variables |
| [Forever Tool / quests](https://forever-tool.com/en/quests/) | Quêtes classées par zone, classe, profession et donjon | Certaines quêtes officielles peuvent ne pas être actives |
| [OpenXP](https://github.com/OpenXP) | Exemple libre d'enchaînement d'étapes ; ancien paquet présent dans le dépôt | Contenu généré après lvl 22 selon une étude externe ; licence du paquet présent à respecter |
| [RestedXP](https://www.restedxp.com/) / Journey | Comparaison **méthodologique** (retours / hubs / détours / donjons) | Ne pas reproduire leurs parcours propriétaires ni transcrire des données payantes |

### Analyse du PexGuide fourni (archive locale de l'utilisateur)

Inspection des fichiers `PexGuide/Engine.lua`, `Chapters.lua`, `DB.lua`, `Data/Corrections.lua`, `Data/Paths.lua` et `Routes/Chap_H_*.lua` :

- Le **moteur d'étapes** distingue `done`, `todo`, `skip` et `wait(level)`. Il relit le journal, les quêtes terminées et le niveau pour se recaler, y compris après un détour donjon.
- Les prérequis sont modélisés en `pre` (**au moins un**) et `preAll` (**tous**), avec quêtes exclusives, suite déjà accomplie et quête déjà active : c'est plus précis que filtrer seulement sur le niveau.
- Une quête trop basse est normalement écartée, **sauf** si elle est nécessaire pour une chaîne utile ou une quête de classe ; les étapes déjà rendues sont conservées comme acquises.
- Une quête en attente de niveau peut être reportée temporairement, avec **limite d'anticipation de six étapes** ; cela évite d'envoyer le joueur à travers plusieurs zones au hasard.
- Des corrections communautaires complètent QuestieDB ; exemple concret dans le ZIP : `A Light in the Darkness` (#98389) après `The Damned` (#376), information signalée comme observée en jeu le 12 octobre 2026.
- `Data/Paths.lua` contient des waypoints enregistrés par les joueurs, distincts de coordonnées approximatives de la base ; intéressante séparation entre trajet empirique et estimation.
- Le ZIP livré contient des chapitres Horde **Tirisfal / Silverpine / Barrens / Crossroads / Stonetalon / Hillsbrad** et régions de départ, mais **pas un parcours Horde 1–60 complet détaillé** (aucun chapitre Désolace dans ce ZIP).

**Décision de conception :** reprendre les **principes** pertinents (état dérivé, dépendances AND/OR, maintien d'une quête-prérequis, preuves du terrain, retour après détour), tout en écrivant notre propre moteur et nos propres étapes, avec un état d'adaptation explicable. Le ZIP ne contient pas de licence de réutilisation identifiable : **ne pas copier son code ni ses routes** dans le nouveau projet sans permission.

**Contradictions importantes :** les guides n'ont pas tous les mêmes tranches, alternent différentes régions, ne tiennent pas systématiquement compte des quêtes Forever et ne prouvent pas les XP/heure optimales. Il faut réconcilier à partir des `questId`, des prérequis, du niveau **minimum** et des PNJ. Un itinéraire sera dit « vérifié » seulement après contrôles et test terrain.

### Étude de cas de prérequis (Horde, Ruins of Lordaeron, source Wowhead)

- `The Wrath of Rath'mael` : chaîne `Rear Guard Patrol` déclenchée auprès de Deathguard Linnea aux clairières de Tirisfal, avec étape élite Riptear, au lieu d'une quête disponible directement au donjon.
- `The New Plague` : chaîne `A Recipe For Death` en plusieurs étapes entre Tirisfal et Silverpine, dont des objets à faible taux de butin et une zone élite.
- Conséquence : une route solo prudente ne doit **pas** détourner systématiquement le joueur pour ces quêtes de donjon sans vérifier le groupe, la chaîne, le coût de déplacement et le gain plausible. Une quête inactive ne doit jamais être marquée « à accepter maintenant ».

### Règles de sélection d'étapes

D'abord filtrer par : faction Horde, classe Guerrier, niveau requis réel, prérequis complets, chapitre accessible, risque solo, validation de la disponibilité. Puis ordonner les quêtes par proximité, regroupement d'objectifs, réduction des allers-retours et récompenses d'équipement utiles. Aucune métrique XP/h n'est déclarée mesurée sans données de terrain ; garder un indicateur « estimé » et la provenance.

## 2. Équipement — strictement quête ou fabrication

**Exemples à vérifier avec IDs définitifs :**

| Objet | Source possible | Conditions et prudence |
|---|---|---|
| [Sword of Omen](https://www.zockify.com/forever/warrior/leveling/) | Récompense **Horde** de `Into the Scarlet Monastery` | Référence : minimum de quête 33. Contenu de donjon / groupe ; vérifier chaîne, niveau requis de l'arme, récompense et côté. |
| [Green Iron Hauberk](https://metabot.gg/en/wow-forever/items/green-iron-hauberk) | Forgé, compétence 160 | Référence : objet **niveau requis 31**, niveau d'objet 36. 20 lingots de fer, 4 pierres à aiguiser lourdes, 2 jades, 2 agates mousse, 1 armure de cuir vert ; confirmer capacité de fabrication. |
| [Whirlwind Weapon](https://www.icy-veins.com/wow-forever/warrior-class-quests) | Quête de classe Guerrier | Les récompenses de cette chaîne sont **armes à deux mains** : ne pas les présenter comme objectif double maniement au niveau 34. Le boss / la chaîne imposent de la prudence. |
| [Thrash Blade](https://www.zockify.com/forever/warrior/leveling/) | Récompense de `Corruption of Earth and Seed` (Maraudon) | Quête minimum 45 selon ce guide ; donjon/groupe. Éligibilité Horde, disponibilité et niveau de l'objet à valider individuellement. |

**Filtres impératifs :** `requiredLevel <= characterLevel`, différence entre ilvl et requiredLevel, équipement de la main (droite/gauche, une main/deux mains), aptitude au type d'arme, faction et classe, `questMinLevel`, chaînes de quête, difficulté et risque, compétence de métier du joueur ou craft délégué **si non-lié**, matériaux et temps de détour. Si un champ déterminant manque, recommandation classée **à vérifier**, pas « obtenable maintenant ».

**Le métier n'est pas gratuit** : progression en Forge / Minage, acquisition des recettes et matériaux doivent entrer dans le coût en temps ; la recommandation d'une recette de compétence 160 ne doit pas supposer que le joueur dispose de cette compétence. Les sources WoW Forever confirment que le niveau d'objet et le niveau utilisable diffèrent.

## 3. Talents — sources, versions et divergences

- **Données d'arbre** : [Zephras, exports versionnés](https://zephras.com/data/). JSON `zephras-talents/1` disponible pour plusieurs builds `1.60.1.x`, grille **4 colonnes × 7 rangées** par arbre, talent ID, position, maxRank, spellId, FileDataID de l'icône, textes par rang, arcs de prérequis, points requis. Partie organisée par Zephras sous **CC BY 4.0** avec attribution ; noms/images Blizzard restent propriété Blizzard.
- **Comparateurs** : [Wowhead Fury leveling (18 nov)](https://www.wowhead.com/forever/guide/classes/warrior/fury/dps-leveling-tips), [Icy Veins Fury](https://www.icy-veins.com/wow-forever/fury-warrior-leveling), [Mobalytics Kargoz](https://mobalytics.gg/wow-forever/classes/1-60-fury-warrior-leveling-guide), [Mobalytics LudiDeo](https://mobalytics.gg/wow-forever/classes/fury-warrior-guide-1-60-talents-rotations-and-more-ludideo), [ForeverSpec](https://foreverspec.com/classes/warrior/fury/).

**Exemples de divergence :**
- Wowhead : rush `Gore Drinker` et `Bloodthirst` pour sustain et moins d'arrêts, puis Rafale et points Armes.
- ForeverSpec : `13/38/0` pour leveling, avec `Gore Drinker` au 32–33 et `Bloodthirst` au 40, puis `Deep Wounds`.
- Kargoz (2 novembre) : `Lingering Rage` en début de parcours puis `Gore Drinker` plus tard ; ordre différent.
- Ancien Companion : `0/51/0` Furie pur. **Ce n'est pas démontré comme le meilleur en DPS, XP/h ou temps de récupération**.
- Préférence utilisateur : Furie, double maniement, **pas de passage temporaire à la spécialisation Armes**. Toute option hybride de points secondaires doit rester *alternative* et expliquée, pas changement imposé.

Ne pas reprendre naïvement une liste ancienne : des descriptions, rangs et connexions ont changé dans les builds de Forever. Tout scénario de talents doit être validé à chaque niveau, non seulement pour le total 51 et les paliers, mais aussi les arcs et l'effet de répartition entre arbres.

### Rotation / priorités par paliers (à valider avec sorts appris)

Sources croisées : Wowhead / Icy Veins / Mobalytics.

- **<20** : Cri de guerre actif, Charge, attaques automatiques, Pourfendre et Fulgurance selon rage/conditions, pas de prétendue rotation de fin de jeu.
- **20–29** : double maniement depuis 20 si entraîné ; `Victory Rush` après une élimination admissible ; maintenir la rage et éviter Heroic Strike inutile.
- **30–35** : posture Berserker (quête de classe), Souhait mortel selon risque, gestion de rage/santé, `Reckless Swings` si appris. Éviter de sacrifier trop de PV.
- **36–39** : `Whirlwind` (Tourbillon) devient prioritaire si appris, dépend de la rage et de la posture.
- **40–60** : `Whirlwind` et `Bloodthirst` comme priorités de dégâts, `Execute` en finition, `Heroic Strike/Cleave` pour excédent de rage ; adapter mono/AoE, soins et risque. Valeurs de coûts et CD à confirmer dans la build live.

**Ne pas automatiser les lancers de sort.** Il s'agit d'un guide / ordre de priorité éducatif, pas d'un bot DPS ou d'un DPS mesuré. L'optimisation « maximum DPS » requiert une simulation sensible aux armes, toucher, rage, compétences débloquées, uptime et cibles, puis des comparaisons en jeu ; en leveling, inclure le downtime et les morts évitées.

## 4. API d'arbre et survol

- [Précédent développement WoW Forever C_Traits testé](https://github.com/nobody174/wow-forever/blob/main/ADDON_PLAN.md) : `C_SpecializationInfo.GetActiveSpecGroup` → `GetCombatConfigIDForSpecGroup` → `C_Traits.GetConfigInfo` → `GetTreeNodes` → `GetNodeInfo` → `GetEntryInfo` → `GetDefinitionInfo`. Obtenir `spellID`, icône, nom localisé et rang actif.
- `C_Spell.GetSpellInfo(spellId)` : nom / icône si chargés ; `GameTooltip:SetSpellByID(spellID)` pour l'info-bulle si l'API client le permet. En prévisualisation historique, afficher aussi le texte **versionné du rang prévu**, qui n'est pas forcément le rang actif du joueur.
- Se méfier des versions : API Classic globales `GetTalentInfo` / `GetNumTalentTabs` peuvent manquer sur Forever. Données secrètes et informations non chargées doivent être protégées, `nil` n'est pas une preuve d'absence.
- Pas de rendu « officiel » de textes d'une build différente sans avertissement. Si le `spellId` est ambigu : tooltip de secours et mention à vérifier.

## 5. Prochaine validation de la recherche

Réaliser un **pilote concret pour les niveaux 30–40**, adapté au Guerrier Furie solo : croiser quêtes accessibles, armes fabriquées/quête, arbre talent par niveau et sorts 30/34/36/40. Vérifier chaque quête et chaque item avec des IDs et au moins deux sources lorsqu'il y a contradiction. Puis étendre au reste de la progression 1–60 en chapitres vérifiés.
