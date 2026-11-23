# Warrior Companion — Architecture Build Planner 1–60

Date de conception : 23 novembre 2026. **Statut : SPECIFICATION / aucune modification de l'ancien addon.**

## Mission

Guide de progression du build **Guerrier mort-vivant Horde, Furie double maniement**, pour un personnage solo. Trois écrans principaux et seulement trois : **Talents**, **Équipement**, **Parcours**. Le résultat est un guide de build, non un compteur de combat ni un tableau de bord.

**Contraintes utilisateur :** niveau détecté automatiquement, prévisualisation libre d'un niveau passé/futur sans toucher au personnage ; équipement uniquement par quêtes ou fabrication (objets précis, alternatives, niveau utilisable) ; parcours ordonné avec adaptation prudente. Rester en orientation Furie pendant le leveling ; comparer les builds mais ne pas basculer en Armes par défaut.

### Données partagées (BuildContext)

```
BuildContext:
  buildId: "undead-warrior-fury-dw-1-60"
  contentVersion: "forever-1.60.1-<build>"
  characterLevel: number|null         # réellement observé, jamais modifié par le planner
  viewLevel: number                   # niveau librement sélectionné : 1..60
  levelMode: "follow"|"preview"       # follow = suit UnitLevel; preview = fixe
  character: { faction, race, class, skills?, professionSkills? }
  observed: { talents?, equippedItems?, learnedSpells?, questLog?, completedQuests? }
  progress: { chapterId, stepId, manuallyCompleted, skipped, gearAcquired }
```

**Règle essentielle :** changer `viewLevel` modifie la simulation Talents / les paliers Équipement / l'aperçu du Parcours, **jamais** les rangs investis, la progression réelle du parcours ou les quêtes. Bouton **Retour au niveau réel**. Passage de niveau détecté automatiquement si mode follow, pas de changement inattendu de niveau quand l'utilisateur est en prévisualisation.

### Trois modules et dépendances

**TalentPlanner**
- Source de vérité par version de WoW Forever : identifiants de talent, `spellId`, `icon` (FileDataID), `tree`, `row`, `column`, `maxRank`, description **par rang**, arcs de prérequis, palier de points à dépenser ; ne plus placer arbitrairement les cellules.
- Séquences de 51 allocations (ou nombre réel par version / effet de Legacy, lorsque confirmé). `planAtLevel(level)`, `nextPoint(level)`, `validateBuild(sequence)`, `compareObserved()`.
- Arbre en icônes et flèches, survol : nom, rang actuel/prévu, description du rang sélectionné et suivant, prérequis ; source principale du tooltip : ID de sort du client si fiable, repli vers le texte versionné.
- Comparer **plusieurs variantes Furie** en coût de rage, dégâts attendus, survie, disponibilité de deux armes, efficacité du leveling ; ne jamais déclarer un gagnant chiffré sans simulation ou données de tests.
- Un sous-panneau **Priorité des sorts** (pas un quatrième onglet) qui se met à jour aux niveaux de déblocage et selon situation monocible/multicible/défensive.

**GearPlanner**
- Des paliers orientés améliorations concrètes d'armes main droite et gauche puis armure.
- Une recommandation valide uniquement si `source.kind` est `quest-reward` ou `crafted`.
- Source de quête : `questId`, `questMinLevel`, prérequis complets, faction, classe, groupe/donjon/élite, localisation et disponibilité ; le parcours peut la programmer.
- Source fabrication : `recipeId`, profession, compétence de fabrication, composants, prérequis d'apprentissage, `bindType` (Lié quand ramassé => fabricant obligatoirement joueur), possibilité ou non de faire fabriquer par tiers et temps/coût estimés.
- Vérifier indépendamment `itemRequiredLevel` et `itemLevel` (jamais confondus), règles de classe, type d'arme, aptitude de maniement et niveau d'équipement. L'absence de l'une de ces données = **non vérifié**, pas recommandé comme accessible immédiatement.
- Alternatives par objectif et palier. Éviter les détours de craft/quête dont le temps dépasse le bénéfice plausible avant le prochain palier.
- Filtre **strict** : pas de récompense Alliance pour le Mort-vivant, pas de vente AH comme *source* d'un équipement, pas de loot boss ou drop aléatoire comme recommandation centrale. Les matériaux achetés restent possibles pour une recette éligible.

**RoutePlanner**
- Les étapes forment un graphe d'actions ordonnées : `travel`, `accept`, `objective`, `turnin`, `train`, `craft`, `grind`, `rest`. Un chapitre possède un plan de base et des sorties alternatives documentées.
- Chaque action porte `questId` si possible, zone/PNJ/coordonnées sourcées, niveaux **minimum** et **conseillé** distincts, quêtes préalables ET conditions `or/and`, faction et classe, risques (élite, groupe, donjon, packs, PvP), temps mesuré/estimé avec indication de confiance.
- Adapter seulement à des faits observés : niveau réel, quête acceptée/terminée, profession connue, objet déjà obtenu, danger de la route, absence d'une quête. Les quêtes ambiguës restent « à confirmer ».
- Ne pas faire du simple « une zone de niveaux 30–40 » un chemin de quêtes exact : vérifier PNJ, prérequis, retours et trajet.
- Optimiser une valeur **temps total pour progresser** : trajet + acquisition + combats + régénération + risque de mort + gains XP/objet. Ne pas inventer les temps ou des gains XP/h.
- Contrainte guerrier solo prudent : préférer ennemis approximativement 2 niveaux sous le personnage, avec vérification en jeu, et éviter élites/donjons sans groupe. Les donjons sont des options clairement marquées.
- État de progression réel distinct de l'aperçu au niveau `viewLevel`. Les skips sont explicites, réversibles, et ne valident pas artificiellement une quête.

### Interfaces minimales

Bandeau commun : **niveau réel**, **niveau prévisualisé**, bouton **niveau réel**, identifiant de build ; barre de navigation **Talents | Équipement | Parcours**.

- Talents : arbre graphique 4 colonnes x 7 lignes par spécialisation, icônes, arcs, états « obtenu / actuel / recommandé / verrouillé », survol, précédent/suivant niveau et rang. Mini-rappel de priorité des sorts du niveau.
- Équipement : progression par paliers, deux armes mises en avant, objet ciblé et alternatives, source « quête » ou « forge », verrouillage du niveau et compétence. Accès à l'étape du Parcours qui permet d'obtenir l'objet.
- Parcours : étapes ordonnées, quête/PNJ/lieu/prérequis, gain attendu, risques, étape courante, suivante et raison de l'adaptation. Une étape de craft est liée au GearPlanner.

### Schéma des fichiers futurs (non créés pour l'instant)

```
Addon/WarriorCompanionBuild/
  Core.lua                 # bootstrap / événements
  BuildContext.lua         # niveau réel, prévisualisation, profil
  SaveState.lua            # sauvegardes/migrations
  CharacterObserver.lua    # lectures API WoW Forever en lecture seule
  TalentPlanner.lua
  GearPlanner.lua
  RoutePlanner.lua
  BuildUI.lua              # trois onglets, composants
  Data/Builds/...          # talents (séquences/règles), équipement, étapes
  Data/Sources/...         # provenance, build de jeu, date et licence
tests/...                  # données, règles, compatibilité 5.1/5.4
```

### Garde-fous et intégration

- Pas d'accès réseau requis ou supposé dans l'addon : données préparées, versionnées et livrées avec le code.
- Les API `C_Traits`, `C_Spell`, `C_QuestLog`, `C_Item` sont facultatives et à protéger (`pcall`, valeurs secrètes, chargement asynchrone). Ne jamais attribuer de talent, accepter/compléter une quête ou lancer un sort automatiquement.
- Compatibilité du client Forever à confirmer en jeu ; tests Lua 5.1 et 5.4, validation des sources et des prérequis de chaque plan.
- Réutilisation du code ancien par extraction **explicite** après validation, pas de fusion automatique de l'ancien tableau de bord.
- Licence et provenance gérées par source ; ne pas copier des guides commerciaux RestedXP/Journey ni des descriptions longues protégées sans licence.
