# Vérification sur WoW Forever

## Avant les tests
Copier uniquement `Addon/WarriorCompanion` dans `_forever_/Interface/AddOns/` (ou le dossier réellement utilisé par le client). Ne pas modifier les fichiers de PexGuide ni les SavedVariables d'autres addons.

## Vérifications
1. Au chargement, vérifier l'absence d'erreur Lua et la présence de Warrior Companion dans la liste des addons.
2. `/wc` : la fenêtre doit s'ouvrir et se fermer ; elle doit afficher XP gagné, XP/h et morts.
3. `/wc status` : afficher l'état des API, du debug et des métriques.
4. `/wc debug on` ; gagner de l'XP ; `/wc status` : vérifier une trace `xp`.
5. Mourir volontairement seulement si un test sans risque est possible ; le compteur de morts doit augmenter.
6. Vérifier que les notifications de talents disponibles ne se répètent pas à chaque événement et qu'aucune alerte ne s'affiche en combat.
7. `/wc reset` : remettre à zéro uniquement les métriques de session.
8. `/wc debug off` : la journalisation doit cesser.

## Limites
- XP/h est une moyenne depuis la remise à zéro, pas une moyenne mobile.
- Le gain d'XP n'est pas déduit correctement en cas de saut de plusieurs niveaux ou d'API qui retourne des données manquantes.
- Certains événements ou fonctions diffèrent selon la version exacte de WoW Forever : leurs compatibilités doivent être vérifiées en jeu.
- Les traces sont stockées en mémoire vive pour la session uniquement ; aucun fichier externe n'est écrit.
- Les tests structurels ne sont ni un parseur Lua, ni un test d'intégration WoW.

## Débogage
Utiliser `/console scriptErrors 1` puis `/reload`. Copier l'erreur Lua intégrale et le résultat de `/wc status`, sans partager de données personnelles.
