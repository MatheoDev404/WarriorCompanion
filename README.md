# Warrior Companion

Addon autonome d'observation et de conseils pour **WoW Forever**.

## Objectif
Observer les événements accessibles au client (niveau, expérience, combats, morts, équipement), produire des indicateurs fiables, puis afficher des **alertes prioritaires discrètes** et un **tableau de bord consultable à la demande**.

Ce projet ne reprend pas le code de PexGuide et ne suit pas de parcours de quêtes imposé.

## Principes
- Mode mixte : alertes importantes automatiques, autres conseils dans le tableau de bord
- Pas d'alerte répétée pendant un combat
- Résultats incertains signalés comme tels
- Logs désactivables et limités ; pas de journalisation intrusive
- Un commit par fonctionnalité et des tests avant chaque version
- Les tests sur WoW Forever doivent être réalisés séparément des simulations

## Statut
Projet initialisé. API cliente, démarrage et interface à valider en jeu. La compatibilité n'est pas encore démontrée.

## Structure visée
`Addon/WarriorCompanion/` : fichiers chargés par WoW ; `tests/` : tests hors jeu ; `docs/` : documentation et scénarios de validation.
