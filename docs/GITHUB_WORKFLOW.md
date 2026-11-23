# Stratégie GitHub — Warrior Companion Build Planner

Approuvée en conception le 23 novembre 2026. Ne pas fusionner l'ancienne UI / l'ancienne PR #25 sans test en jeu.

## Règle de branches

- `main` : code stable validé dans WoW Forever.
- `feature/build-planner` : **branche d'intégration unique active pour le nouveau socle et la documentation**. La phase de conception ajoute des documents seulement et laisse l'ancien `Addon/` intact.
- `feature/talents`, `feature/equipement`, `feature/parcours` : **créées uniquement si un travail parallèle et conséquent le justifie**. Une branche par grand module, jamais une branche par bouton/fix/niveau/version.
- Maximum souhaité : **4 branches de travail ouvertes** ; sinon une seule branche `feature/build-planner` suffit.
- Une PR par ensemble fonctionnel testable ; une correction sur le module va dans sa branche existante jusqu'à intégration.
- Après validation, merger/squash et **supprimer la branche de travail**. Ne jamais laisser une longue série de branches `feat/x-v0.n` abandonnées. Tags `vX.Y.Z` pour les livraisons, **pas** des branches de version.

## Inventaire préliminaire effectué

Le dépôt contient de nombreuses branches historiques `feat/*-v0.*`, `fix/*-v0.*`, `feature/guide-on-063` et la branche `refactor/cleanup-lean-guide`. La PR #25 est la seule PR encore ouverte au 23/11/2026 ; elle appartient à l'ancienne interface.

**Nettoyage non destructif d'abord :** comparer chaque ancienne branche à `main` ou ses PR fusionnées ; supprimer uniquement celles totalement intégrées, et préserver un tag ou une référence d'archive pour les travaux encore uniques. Aucune suppression automatique de branches dans cette phase ; ne pas annoncer que l'inventaire a été supprimé tant qu'il ne l'est pas.

## Méthode de développement

1. **Recherche et données** : pour chaque règle/quête/objet/talent, enregistrer source, date, build client, ID et statut de confiance (confirmé jeu / confirmé deux sources / hypothèse).
2. **Tests hors jeu** : compatibilité Lua 5.1/5.4 ; validation de 51 points ou points disponibles, prérequis talents, niveaux d'objets, métiers et chaînes de quête, absence de contenu de faction ennemie.
3. **Revue de pertinence** : chaque changement doit servir Talents/Équipement/Parcours ; aucune métrique ou UI hors de ce périmètre.
4. **Validation en jeu** : screenshots, erreurs Lua, tooltips, noms français et état réel, répétabilité aux levels 10/20/30/34/36/40/60.
5. **Fusion seulement après accord de test**, release tag et changelog. Ne pas modifier l'ancien addon sous la nouvelle architecture avant validation du socle.

## Gestion des licences

Les guides tiers **RestedXP / Journey** sont des références méthodologiques, pas une source de copie de données payantes. Ancien OpenXP dans le projet : conserver crédit et licence propres, vérifier les conditions avant extraction. Export des arbres de talent Zephras : CC BY 4.0 pour l'arrangement et attribution obligatoire ; noms, icônes et textes du jeu restent à Blizzard. Les fichiers de provenance doivent rester explicites.
