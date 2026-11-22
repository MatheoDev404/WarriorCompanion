# Audit de l'arbre de talents Furie — WoW Forever

Date : 22 novembre 2026. Portee : plan de leveling **Furie double maniement, sans respe**, du niveau 10 au niveau 60.

## Sources consultees

- [Forever Talents, Guerrier](https://forevertalents.net/talents/warrior/) — 18 talents Furie, 7 paliers, rangs maximum, pre-requis, et conditions de debloquage de palier.
- [ForeverChanges, Guerrier](https://foreverchanges.pro/talents/warrior) — changements sur les paliers, Sanguinaire et Buveur de sang.
- [Forever Tavern, calculateur Guerrier](https://www.wowforevertavern.com/talents/warrior) — controle de la nomenclature et des rangs du snapshot 1.60.1.
- [Outpost, parcours guerrier 10–60](https://www.wofwforever.com/en/guides/wow-forever-warrior-leveling-talents/) — exemple de progression Furie valide mais **different** du parcours retenu.

Le plan de Warrior Companion est un **choix de leveling** ; il ne pretend pas etre le seul build viable ni le meilleur dans toutes les situations. Les ordres des sites divergent. Ne pas substituer silencieusement un guide a un autre.

## Invariants verifies en code

- Exactement **51 allocations**, une par niveau, du **10 au 60**.
- Aucun rang ne depasse le maximum de son talent ; un rang augmente d'exactement un lors de son allocation.
- Un talent situe au palier N demande **5 x (N-1) points places dans des paliers precedents de Furie**, pas simplement dans la specialisation ou dans le meme palier.
- **Gore Drinker** (Buveur de sang) n'est pas choisi avant **Blood Craze 3/3** (Folie sanguinaire).
- **Bloodthirst** (Sanguinaire) n'est pas choisi avant **Death Wish 1/1** (Souhait mortel).
- Aucun point n'est attribue a Armes ou Protection dans **cette variante Furie pure**.

La fonction `ValidateTalentPlan()` verifie les 51 allocations et retourne un diagnostic en cas d'erreur. Le controle initial est bloque si le plan est invalide. Tests dans `tests/test_talent_plan.lua` : plan valide, palier verrouille, prerequis absents, rang invalide, niveau manquant, grille 7 x 4.

### Jalons

| Niveau | Talent du point | Justification de disponibilite |
| --- | --- | --- |
| 10 | Cruaute 1/5 | Palier 1 |
| 15 | Rage debridee 1/5 | 5 points au palier 1 |
| 20 | Precision furieuse 1/3 | 10 points aux paliers 1–2 |
| 25 | Specialisation Ambidextrie 1/5 | 15 points aux paliers 1–3 |
| 30 | Souhait mortel 1/1 | 20 points aux paliers 1–4 |
| 35 | Rafale 1/3 | 25 points aux paliers 1–5 |
| 40 | Sanguinaire 1/1 | 30 points aux paliers 1–6 et Souhait mortel acquis |
| 44 | Buveur de sang 1/2 | Folie sanguinaire 3/3 aux niveaux 41–43 |
| 60 | Voix tonitruante 3/5 | 51 points depenses depuis le niveau 10 |

## Limites importantes

- La grille dessinee dans l'addon est une **representation pedagogique**, non une copie exacte des coordonnees des icones Blizzard.
- Les libelles francais doivent etre revus **dans le client francais WoW Forever** ; certains sont adaptes manuellement.
- L'addon ne verifie **pas encore les rangs reellement places dans le personnage**. Les nombres representent le plan recommande, pas une lecture de l'arbre actuel. Les points libres sont lus separément si l'API le permet.
- La validation automatisee ne prouve pas que le joueur dispose d'un rang exact ni que le plan est le plus rentable en XP/h. Toute modification d'arbre par correctif du serveur necessitera un nouvel audit.
