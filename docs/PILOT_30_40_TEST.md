# Pilote testable Warrior Companion Build — audit 30–40

Date : 23 novembre 2026. **Ne pas confondre prototype testable et guide 1–60 validé.**

## Comparaison de parcours

| Plage | ForeverTavern / route basée sur hubs | Autres guides Horde | Choix du pilote |
|---|---|---|---|
| 30–32 | Hautebrande, puis Arathi | Wowdee alterne Hautebrande et Mille pointes | Conseiller de terminer les quêtes solo locales, sans IDs non confirmés |
| 33–34 | Mille pointes/Salines, retours Freewind/Crossroads et parfois Booty Bay | Wowdee conserve les Mille pointes | Salines et objectifs solo déjà disponibles. Ignorer Gnomeregan/quests de donjon sans groupe |
| 34–36 | Désolace : Ghost Walker Post, Shadowprey Village, retours sur PNJ | Wowdee revient aussi vers Desolace | Enchaîner les hubs en minimisant les trajets, prudence niveau/risque |
| 36–38 | Strangleronce, puis Marécage d'Âprefange | Plan 34–41 mélange STV, Dustwallow, Arathi | Comparaison de hubs et objectifs solo ; aucun timing XP/h inventé |
| 38–40 | Arathi, Terres ingrates | Plusieurs variantes de trajet | Préparer les paliers de sort au niveau 40 |

Sources : https://forevertavern.net/guides/leveling/horde/thousand-needles-33-34 ; https://forevertavern.net/guides/leveling/horde/desolace-34-36 ; https://wowforeverleveling.com/guides/wow-forever-horde-leveling-guide ; https://wowhandbook.com/leveling/horde/.

### Quêtes à recontrôler avant de les insérer comme étapes individuelles validées

- Désolace : `Alliance Relations → Befouled by Satyr → The Burning of Spirits` : chainage visible dans ForeverTavern, mais valider les ID de quête et la disponibilité réelle avant d'en faire un clic « accepter maintenant ».
- `The Corrupter`, `Khan Dez'hepah`, `Centaur Bounty`, `Kodo Roundup` : ForeverTavern les place près de Ghost Walker Post ; niveaux et ennemis précis à confirmer.
- `Stealing Supplies`, `Hand of Iruxos`, `Clam Bait` à Shadowprey Village : certaines quêtes demandent 35+ ; ne pas les proposer à 34 sans vérification.
- Nouveau contenu Forever autour de Riverglades : aucune insertion automatique à partir d'une simple mention de zone.
- Quêtes de donjon à part : hors parcours solo obligatoire et avec bouton optionnel.

## Cas d'équipement testés

| Objet | Condition | Statut dans le pilote |
|---|---|---|
| Sword of Omen, #6802 | quête Horde #1048, niveau minimum 33, multi-aile de donjon | Option de groupe, liée à l'étape #quest-scarlet, saut Équipement → Parcours |
| Green Iron Hauberk, #3844 | niveau requis 31, recette #3508, Forge **155** selon la fiche Forever Wowhead du 23/11 | Fabrication, option si composants disponibles ; vérifier armure de cuir vert comme ingrédient |
| Golden Scale Leggings, #3843 | niveau requis 29, recette #3507, Forge **170** selon la fiche Wowhead Forever ; d'autres sites citent 145 pour la version modifiée | Fabrication possible uniquement si plan, métier et matériaux vérifiés |
| Thrash Blade, #17705 | niveau requis 45, quête #7064 Maraudon | Non éligible à 34, groupe optionnel à 45+ |

**Différence de client :** plusieurs bases de données présentent le seuil *jaune* ou l'ancien seuil Classic comme s'il s'agissait du niveau requis pour apprendre la recette. Pour le pilote, l'addon n'annonce jamais « déjà fabriqué » sans confirmation en jeu.

## Ce que mesurent les tests

- Progression de talents du niveau 10 au 60 légale par rang/palier, données de grille issues de Zephras.
- Aucun objet recommandé sans une étape de quête ou de craft correspondante ; type de source strict, questId concordant et filtre de niveau.
- Quêtes de groupe = **option**, non validables comme étape obligatoire solo.
- Niveau réel indépendant de la prévisualisation ; choix d'un objet depuis Équipement déplace l'affichage sur la bonne étape.
- Mode compact 65–115 %, fenêtre mobile et réglage sauvegardé.
- Tests Lua 5.1 et 5.4 pour la logique et les clics simulés, suivis d'un test visuel en jeu.

## Reste à développer avant un guide exhaustif 1–60

1. Importer un catalogue **de quêtes sourcées ID-par-ID**, et calculer les prérequis AND / OR.
2. Confirmer les niveaux minima, objectifs, NPC, coordonnées et changements de zone par étapes.
3. Ajouter plusieurs **armes une main** de quête/craft utilisables à bas et moyen niveau (main droite et main gauche), sans imposer de donjon.
4. Comparer plusieurs variantes de talents Fury double maniement par simulations avec données d'armes, puis mesurer DPS, temps hors combat et morts en jeu.
5. Étendre les chapitres validés au 1–60 seulement après confrontation des données à WoW Forever. Maintenir un indicateur de confiance visible.
