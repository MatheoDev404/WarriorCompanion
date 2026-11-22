# Changelog

## 0.6.6-rc1 — interface anthracite et bronze

- Grande fenêtre entièrement recolorée : fond anthracite, cartes graphite, filets bronze et texte ivoire.
- En-tête débarrassé des illustrations couvrantes et de la décoration superflue ; blason Horde conservé discrètement.
- Boutons des quatre rubriques agrandis et sous-onglets en police plus lisible.
- Navigation avec **état actif visible** sur les onglets de Guide, Combat et Conseils ; interactions de survol sur la navigation.
- Réglages avec indicateur visuel actif/inactif pour les options et confirmation de réinitialisation.
- Suppression des textures d'en-tête non utilisées, `HordeSky.tga` et `HeaderPlate.tga` (384 Kio environ).
- Aucun changement de logique du guide, de la lecture des talents ni du mini-bilan.
- Tests automatiques de navigation, d'état actif et de la présence des textures après simplification.

## 0.6.5-rc1 — les fonctions joueur dans les onglets

- La fenêtre complète conserve un **Guide**, des **Conseils** et un onglet **Combat**, avec un quatrième onglet **Réglages** pour les options courantes.
- Sous-vues **Conseils / Équipement / Santé / Armes / Sorts** dans Conseils.
- Sous-vues **Combats / Performance** dans Combat, dont les taux XP/h de session et des dix dernières minutes.
- **Réglages** permet de modifier l'ouverture automatique, les notifications et de réinitialiser les compteurs de session après un double clic de confirmation.
- Les anciennes commandes utilisateur `/wc gear`, `health`, `weapons`, `spells`, `combat` et `performance` ouvrent directement les pages correspondantes. Les autres commandes de navigation sont conservées comme raccourcis.
- Les outils de diagnostic et de développement restent dans le chat : `status`, `fury`, `questie`, `history`, `debug`, `logs`, `clear`.
- Les trois pages de Guide **Étapes / Talents / Mes quêtes** et **À prendre** restent inchangées.
- Tests automatisés de navigation, mises à jour de réglages, et compatibilité Lua 5.1/5.4.

## 0.6.4-rc1 — nettoyage et recentrage sur le leveling

- Suppression du module `QuestClusters.lua`, de la commande `/wc route`, de la vue temporaire de regroupement de PNJ et de leur test obsolète.
- Conservation de la véritable progression Horde 1–60, des vues Étapes/Talents/Mes quêtes/À prendre, du mini-bilan, des conseils et du suivi de combat.
- Retrait des fonctions mortes de l'ancien Bilan et de l'ancien Journal, et du double formatage de monnaie de la grande fenêtre. Le formatage monétaire du mini-bilan reste testé.
- Suppression de `AdviceArt.tga` (128 Kio), devenu inutilisé.
- Allègement de la décoration des panneaux : surfaces sobres et bordures simples à la place des couches métalliques et rivets.
- Réécriture de la documentation et du protocole de tests sur les écrans réellement présents.
- Diagnostic avancé, historique et performance conservés en commandes, hors de l'interface principale.
- Contrôle automatique sous Lua 5.1 et 5.4 avant fusion ; vérification du rendu dans le jeu toujours nécessaire.


## 0.6.3-rc1 — correctif de sécurité des recommandations de quêtes

- Les missions d'incursion du Bois de la Pénombre (IDs 81730–81747, vérifiées Élite) ne sont plus proposées comme pistes solo.
- Les tags de difficulté élite/donjon/groupe lus explicitement dans le client sont exclus quand disponibles.
- Les regroupements de PNJ de départ sont affichés comme **pistes à vérifier**, pas comme itinéraires ou quêtes solo garanties.
- Régression issue d'une capture en jeu d'un guerrier Horde niveau 33 ; tests Lua 5.1/5.4.



## 0.6.2-rc1 — regroupement des PNJ de départ

- Nouvelle commande `/wc route` : regroupe des pistes `/wc discover` par zone et proximité de PNJ de départ vérifiés via QuestieDB.
- Exclut les PNJ qui ne sont pas identifiés comme accueillant la Horde, ainsi que les coordonnées invalides et données manquantes.
- Classement par nombre de pistes regroupées et proximité du niveau de quête avec le niveau du guerrier moins deux.
- Aucune route d'objectifs, XP/h, difficulté solo ou temps de trajet inventée.
- Tests Lua 5.1/5.4 et pas de changement d'interface.



## 0.6.1-rc1 — découverte prudente de quêtes avec QuestieDB

- Commande `/wc discover` pour rechercher les quêtes non acceptées à partir des fiches publiques de QuestieDB (contrat v4), sans dupliquer sa base.
- Filtres de faction Horde, race, classe guerrier, niveau, PNJ de départ, acceptées et terminées ; exclusions conservatrices des conditions non vérifiables.
- Classement limité à sept pistes proches du niveau -2 et consultation explicite hors combat, sans prétendre vérifier le niveau réel des ennemis.
- Aucun marqueur de carte ajouté ; Questie conserve ses fonctions de suivi.
- Tests Lua 5.1/5.4 de validation des sources, prérequis, niveaux et absence de fausses recommandations.



## 0.6.0-rc1 — conseiller de quêtes Horde et intégration Questie

- Classement conservateur des quêtes déjà acceptées selon niveau, statut de remise, présence explicite d'indications groupe/donjon/élite et niveau du guerrier Horde.
- Catégorie inconnue si l'API ne confirme pas le type ; les récompenses, la difficulté réelle et les quêtes à aller chercher ne sont pas inventées.
- Écoute optionnelle des notifications via les API publiques de Questie, sans modifier ses données ni dupliquer ses marqueurs minimap/carte.
- Commandes `/wc quests` et `/wc questie`, tests Lua 5.1 / 5.4 et tests de non-régression.



## 0.5.9-rc1 — suivi prudent des talents

- Lecture stricte des points non dépensés avec validation des retours de `C_ClassTalents`.
- Changements enregistrés dans le journal de session sur les événements de talents ; lecture de base au chargement sans faux historique.
- Commande `/wc talents` ; aucune déduction d'un talent exact ou d'un arbre Furie sans API vérifiée.
- Tests Lua 5.1/5.4 sur les états, erreurs API et valeurs protégées.



## 0.5.8-rc1 — HUD compact et minimap recalée

- Recomposition de la fenêtre en 600 × 360 unités WoW (contre 710 × 448) ; statistiques et fonctions préservées.
- Sidebar, bandeau, cartes et journal réorganisés ; conseil abrégé dans le bilan, intégral dans Conseils.
- Rayon de placement de l'icône calculé depuis la taille réelle de la minimap (repli prudent si non disponible).
- Nouvelle commande `/wc minimap reset` pour corriger une position enregistrée gênante ; déplacement toujours possible.
- Tests Lua 5.1/5.4 et protocole visuel en jeu.



## 0.5.7-rc1 — vérification stricte des conseils d'armes

- Vérification du fonctionnement et des sources documentées de GearQuest Forever, classement par spécialisation et niveau.
- Aucun objet, prix ni comparaison d'arme n'est présenté comme confirmé sans accès à une API de données publique stable.
- Détection optionnelle de GearQuest ; rappel vers `/gq` après niveau gagné ou équipement modifié, pour comparer tous les emplacements. Fenêtre de pertinence de dix minutes.
- Diagnostic `/wc gear` et test de non-régression sous Lua 5.1 et 5.4.



## 0.5.6-rc1 — diagnostic des armes guerrier Furie

- Observation des mains droite/gauche, du type équipé (arme à une main, deux mains, bouclier) avec lectures protégées.
- Conseil informatif de double maniement conditionnel si niveau 20+, arme à une main et main gauche vide ; pas de recommandation erronée pour une arme à deux mains.
- Conseil informatif si bouclier ou accessoire porté en main gauche, sans prétendre que cela soit toujours mauvais.
- Commande `/wc weapons` et tests Lua simulés sous 5.1 et 5.4.

## 0.5.5-rc1 — apparence de minimap WoW standard

- Remplacement de l'écusson carré par une icône guerrier native 20 px à l'intérieur de la bordure circulaire Blizzard.
- Bouton 31 px, survol Blizzard, fond miniature et bordure de suivi 53 px, visuellement proches des boutons LibDBIcon.
- Placement circulaire standard 80 px, prise en charge du contour carré en présence de GetMinimapShape.
- Drag et sauvegarde de position conservés, tests des textures, quadrants et clics.

## 0.5.4-rc1 — bouton de minimap standard et deplacable

- Bouton librement déplaçable autour du bord de la minimap, par glisser-déposer.
- Position angulaire sauvegardée et restaurée à la prochaine connexion.
- Protection contre les clics accidentels après déplacement ; ouverture auto inchangée.
- Tests Lua 5.1 et 5.4 du déplacement, des quatre quadrants et de la persistance.

## 0.5.3-rc1 — minimap et lancement automatique

- Bouton guerrier sur le bord de la minimap : clic gauche pour ouvrir et fermer le tableau.
- Tableau de bord automatiquement ouvert une fois à la connexion, sans réouverture à chaque changement de zone.
- Option persistante `/wc autostart on|off` ; repli si la minimap devient disponible après le chargement.
- Tests Lua 5.1/5.4 de l'icône, de l'ouverture/fermeture, du tooltip et des options.

## 0.5.2-rc1 — observation des sorts et rangs

- Lecture prudente des onglets du grimoire via `C_SpellBook` sur Forever.
- Détection des nouvelles entrées ou rangs depuis la référence de session, sans inventer les sorts disponibles chez les maîtres.
- Conseil informatif Furie valable dix minutes après une nouvelle observation ; commande `/wc spells`.
- Protection contre API absentes, valeurs secrètes, indices invalides et changement massif d'onglets.
- Tests Lua 5.1 et 5.4 ajoutés.

## 0.5.1-rc1 — conseils ciblés guerrier Furie

- Conseils de récupération propres au guerrier Furie lorsqu'il est sous 35 % PV hors combat.
- Conseil d'efficacité après cinq phases de combat avec durée moyenne d'au moins 45 s ; pas de causalité supposée.
- Vérification prudente de l'identifiant de classe ; classe et spécialisation non lisibles ne deviennent jamais des affirmations.
- Commande de diagnostic `/wc fury` et tests Lua 5.1/5.4.

## 0.5.0-rc1 — conseil de récupération fiable

- Lecture défensive des PV et PV maximum du personnage par l'API WoW.
- Conseil informatif de récupération hors combat si la vie mesurée est inférieure à 35 %, sans notification automatique.
- Aucune conclusion si le personnage est mort, si la lecture est protégée ou si l'API est absente.
- Commande `/wc health`, tests Lua simulés sous 5.1 et 5.4.

## 0.4.2-rc1 — direction artistique D illustrée

- Bandeau de bataille rouge illustré et écusson guerrier originaux, embarqués en textures TGA compatibles.
- Armature métal noirci, bordures biseautées, reflets bronze, rivets et boutons Horde.
- Bilan complet visible immédiatement : XP, monnaies g/s/c, combat, conseil et activités.
- Tests du rendu structurel, navigation et format de monnaie en Lua 5.1/5.4, validation des fichiers TGA.
- Test visuel sur WoW Forever nécessaire pour confirmer textures et proportions.

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
