# GitHub — développement Warrior Companion

Mise à jour : 26 novembre 2026.

## Branches

- `main` : ancien addon `WarriorCompanion` et historique, **ne pas supprimer**.
- `feature/build-planner` : branche unique d'intégration et de validation du
  nouvel addon `WarriorCompanionBuild` (PR #29).
- Éviter les branches par bouton ou par correctif ; conserver les commits
  fonctionnels, et fusionner seulement après un test réel du client.
- L'historique Git contient les anciennes spécifications et les versions
  précédentes du changelog ; leur répétition dans le paquet n'est pas utile.

## Toute modification doit passer par

1. **Pertinence** : sert-elle le leveling, les talents, équipements, rotations,
   la navigation, les guides métiers ou les réglages réellement utilisés ?
2. **Compatibilité** : ne pas inventer d'API ni d'événement WoW Forever 1.60.1 ;
   les événements facultatifs sont enregistrés avec protection.
3. **Licence** : `DetailedData30_40.lua` ne peut pas être distribué sans
   `LICENSE-GUIDE.txt` (CC BY-NC-SA 4.0) et ses attributions.
4. **Tests** : valider la structure, les 302 étapes et leur audit, les
   métiers Minage/Forge, la boussole, les 4 onglets et la minimap sur
   Lua 5.1 **et** 5.4. Un test ajouté ne doit pas supposer que le client
   fournit systématiquement les APIs modernes.
5. **Non-régression** : vérifier les modes de parcours, les réglages,
   la reprise de quêtes, le chargement du TOC et l'absence de texture
   ou de fichier legacy dans le paquet.
6. **Test en jeu** : contrôler le rendu, les clics, les tooltip, les valeurs
   secrètes et les événements du client Forever. Garder la version
   `-test` jusqu'à cette confirmation.

## Distribution compacte

`scripts/package_addon.py` produit le ZIP autonome contenant seulement :
- le `.toc` et les **modules Lua déclarés** ;
- le README d'installation et la licence historique.

Les tests, archives de recherche et données de conception restent dans le
**dépôt Git**, pas dans `Interface/AddOns/`. La CI joint un artefact
`WarriorCompanionBuild-installable` au résultat de test pour installer
sans extraire manuellement le grand ZIP du dépôt.

Voir [l'architecture actuelle](ARCHITECTURE_ACTUELLE.md).
