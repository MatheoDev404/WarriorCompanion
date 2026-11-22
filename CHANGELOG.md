# Changelog

## 0.2.2 — historique de session

- Historique borné des événements effectivement observés, disponible via `/wc history`.
- Limite de 60 entrées, anti-répétition sur les modifications fréquentes, effacement avec `/wc reset`.
- Tests de chronologie et de confidentialité : aucun détail d'objet ou de quête non disponible n'est inventé.
- Logs de debug toujours indépendants et désactivés par défaut.

## 0.2.1 — audit de compatibilité Forever

- Le tableau compte les quêtes hors en-têtes. Les alertes lisent les points de classe et de spécialisation via les API documentées dans le build 71037.
- Un rechargement en combat diffère la notification. Ouvrir le tableau actualise les conseils sans envoyer de message automatique.
- Le compteur d’XP conserve sa référence pendant les changements de niveau asynchrones. Une barre indisponible ou une moyenne arrondie à zéro ne suffit plus à déclencher le conseil d’inactivité.
- La première lecture disponible de monnaie sert de référence, y compris après la connexion.
- Un profil de sauvegarde endommagé retrouve les options par défaut. Les réglages valides sont conservés.
- La CI vérifie le manifeste, la syntaxe de chaque fichier et les simulations sous Lua 5.1 et 5.4. Le protocole de test en jeu précise les observations encore nécessaires.

## 0.2.0 - test initial
- Corrige chargement, gestion des commandes et compteur d'XP lors des transitions de niveau
- Ajoute observation des morts, monnaie et journal de quetes
- Ajoute conseils informatifs et alerte de talent a delai de rappel 5 minutes hors combat
- Interface plus informative et diagnostics effacables
- Tests Lua simules, controle du TOC, compilation de syntaxe et workflow GitHub Actions

## 0.1.0-dev
- Prototype initial : observateur, conseils, interface et diagnostics
