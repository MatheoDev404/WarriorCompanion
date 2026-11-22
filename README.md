# Warrior Companion

Addon **autonome** pour WoW Forever : il observe la session et conseille sans imposer d'itineraire.

## Version 0.2.0 - premiere version a tester
- Mesure XP de session et XP/h depuis le chargement ou la remise a zero
- Morts, variation d'argent et nombre d'entrees de quetes
- Alerte automatique pour les points de talent non depenses (seulement si l'API est disponible), jamais pendant le combat, repetee au maximum toutes les 5 minutes
- Conseils moins urgents dans un panneau ouvrable avec `/wc`
- Journal de diagnostic opt-in (maximum 100 entrees en RAM, efface lorsque desactive)
- Aucun trafic reseau, aucune copie d'un guide tiers

## Installation
Copier le dossier `Addon/WarriorCompanion` dans `Interface/AddOns/WarriorCompanion` de votre client Forever. Verifier le repertoire effectivement utilise et la version d'interface `16001`.

## Commandes
`/wc` (ouvrir/fermer), `/wc status`, `/wc reset`,
`/wc debug on`, `/wc debug off`, `/wc logs`, `/wc clear`,
`/wc alerts on`, `/wc alerts off`, `/wc help`.

## Validation
`python3 tests/check_structure.py` puis `lua5.4 tests/test_addon.lua`, ou GitHub Actions.

**Attention :** cette version a des tests automatises simulant les API ; elle n'a pas encore ete confirmee sur le client WoW Forever. Les controles de sorts, Premiers secours, armes et quetes rentables viendront seulement apres verification de leurs API.
