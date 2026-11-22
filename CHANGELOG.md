# Changelog

## 0.4.1-rc1 — HUD moderne (design D)

- Remplacement des grands panneaux carrés par un HUD compact à navigation latérale (Bilan, Combat, Conseils, Journal).
- Cartes statistiques plus compactes, rappels de combat et dernières activités ; rafraîchissement limité sans notifications involontaires.
- Variation monétaire affichée avec icônes WoW en or, argent et cuivre, signe correct pour les pertes.
- Tests Lua 5.1 et 5.4 : navigation, données indisponibles, mise à jour et conversions monétaires.

## 0.4.0-rc1 — refonte visuelle Horde guerrier

- Nouveau panneau plus grand, contrasté, rouge sombre / acier noirci / bronze.
- Quatre sections lisibles et séparées, icône guerrier, stats XP/h de session et glissante, combat, conseils et dernières activités.
- Affichage actualisé pendant l'ouverture seulement, sans provoquer de nouvelles notifications.
- Tests d'interface simulée et documentation d'une validation visuelle en jeu.

## 0.3.1-dev — XP/heure récente

- Calcul glissant XP/h sur dix minutes et comparaison à la session via `/wc performance`.
- Échantillons bornés, protection contre les lectures d'XP indisponibles et les mesures tronquées.
- Tests de fenêtres temporelles, périodes sans XP, réinitialisation et saturation du tampon.

## 0.3.0-dev — mesures de combat prudentes

- Compte les intervalles d'etat de combat terminés et leur durée, sans prétendre compter les ennemis.
- Distingue les interruptions par mort, chargement ou durée incohérente.
- Nouveau panneau et commande `/wc combat`, avec tests Lua 5.1/5.4.
- Exclut volontairement les dégâts et l'XP par ennemi en l'absence de validation du journal de combat Forever.

## 0.2.2 — historique de session

- Historique borné des événements effectivement observés, disponible via `/wc history`.
- La chronologie inclut les gains d’XP mesurés au changement de zone et conserve les changements rapprochés sur deux emplacements d’équipement distincts.
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
