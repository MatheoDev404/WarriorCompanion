# Plan de vérification — Warrior Companion

Ce protocole concerne **l'interface actuellement maintenue**, et remplace les anciens plans de test qui faisaient référence aux onglets **Bilan**, **Journal**, **Parcours** et à la commande `/wc route`.

## 1. Installation et chargement

1. Installer uniquement `Addon/WarriorCompanion` sous `Interface/AddOns/`.
2. Vérifier le manifeste `WarriorCompanion.toc` et le client `16001`.
3. Connecter un guerrier Horde. Confirmer que le mini-bilan s'ouvre automatiquement, sans bouton de minimap ni erreur Lua.
4. Effectuer `/reload`, vérifier les données sauvegardées et la restauration de la position du mini-bilan.

## 2. Mini-bilan (304 × 88)

- XP et morts de session cohérents ; le champ **TEMPS** augmente en `HH:MM:SS`.
- Solde affiché au format or/argent/cuivre avec les icônes du jeu : **vert** pour positif, **rouge** pour négatif, **gris** pour zéro.
- Aucun chevauchement entre le temps et le compteur de morts.
- Ligne de conseil lisible sur une seule ligne.
- Déplacement et sauvegarde de la position ; bouton `>>` ouvrant la grande fenêtre.
- `/wc reset` remet à zéro les mesures et l'heure de départ de la session.

## 3. Grande fenêtre (720 × 460)

- **Trois onglets principaux seulement** : **Combat**, **Conseils**, **Guide**.
- Le contenu ne dépasse pas et la taille des caractères reste lisible.
- Le bouton X revient au mini-bilan, sans ouvrir de fenêtre supplémentaire.
- **Combat** présente les mesures réellement suivies et ne confond pas durée de combat et nombre de monstres tués.
- **Conseils** rassemble les alertes et l'équipement pertinent, sans répéter deux fois les mêmes messages.

## 4. Guide et quêtes

- **Guide** : étapes du parcours Horde, action courante, destination si connue, étape suivante, boutons précédent/suivant, progression restaurée après `/reload`.
- Reprise possible au niveau actuel sans forcer le joueur à recommencer au niveau 1.
- **Mes quêtes** : lecture des quêtes acceptées et état connu, sans inventer la difficulté des monstres.
- **À prendre** : découvertes QuestieDB à la demande, hors combat ; ne jamais prétendre qu'une quête est certainement disponible ni solo.
- Vérifier les transitions de sections et les étapes importantes directement en jeu, notamment les noms français des quêtes.

## 5. Talents Furie — priorité

1. Ouvrir `/wc talents` ; contrôler la présence de la grille de **7 paliers / 18 talents** et des niveaux 10–60.
2. Comparer les noms affichés au **texte français de l'arbre WoW Forever**. Les noms retournés par le jeu doivent prendre priorité sur les noms de secours.
3. Comparer **un à un les rangs réels** dans l'interface Blizzard et les rangs indiqués comme réels par l'addon.
4. Si un talent n'est pas reconnu, une lecture partielle doit être signalée, jamais transformée en un rang vérifié.
5. Les écarts en rouge doivent correspondre à un écart **au niveau actuel** uniquement. En consultant un ancien niveau, pas de fausse comparaison.
6. Tester `/reload`, les changements de talents et une lecture indisponible ; aucune erreur Lua.
7. L'addon **ne doit jamais dépenser de point**.

## 6. Qualité et non-régression

GitHub Actions exécute sur Lua **5.1** et **5.4** :

- `tests/check_structure.py` (tous les modules TOC doivent exister et être uniques).
- `tests/check_art.py` (textures de l'addon).
- Vérification de syntaxe `luac` et tests `tests/test_*.lua`, notamment le mini-bilan, les pages Guide/Combat/Conseils, les quêtes, la grille de talents et la lecture `C_Traits`.

**Critère de fusion** : tous les tests automatiques passent ; aucune fonction voulue n'a disparu ; l'affichage ne présente pas de régression connue. Une validation visuelle en jeu demeure nécessaire lorsque le changement touche l'interface ou les API de WoW Forever.
