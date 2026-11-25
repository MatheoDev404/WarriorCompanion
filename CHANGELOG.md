# Changelog — Warrior Companion Build Planner

## 0.4.0-test — 25 novembre 2026

- **Phase A — Guide de niveau 30–40** : réintégration des 302 étapes historiques OpenXP/RestedXP en 14 sections, au lieu de remplacer définitivement le pilote synthétique. Les 285 coordonnées et 217 actions associées à des quêtes sont conservées, avec fichier de licence CC BY-NC-SA 4.0 et attributions.
- **Reprise adaptative** : moteur séparé classant les étapes selon l'acceptation/les objectifs/le rendu réel des quêtes (`C_QuestLog`), le niveau et la zone courante. Prérequis connus vérifiés, autres marqués incertains. Choix prioritaire des quêtes en cours, reprise dans la section du hub majoritaire, sauvegarde de l'étape choisie et corrections manuelles réversibles.
- **Onglet Parcours** : bouton Guide détaillé / Vue synthèse, navigation sur toute la liste des 302 étapes, centrage automatique de l'étape recommandée et infobulle présentant le détail connu. Conservation du lien « Voir dans Parcours » pour les récompenses du pilote.
- **Boussole** : flèche directionnelle autonome, distance en ligne droite, zone et instance vérifiées, fallback local, position mémorisée, `/wcb compass on/off`. Les valeurs secrètes Forever sont filtrées, et l'absence de destination donne un message plutôt qu'une distance inventée. Une simple étape de déplacement peut se valider à l'arrivée, pas un objectif de combat.
- **Audit source** : 108 identifiants de quêtes distincts recoupés avec l'export Forever de `prezus/ForeverGuide`; 285 points géographiques vérifiés syntaxiquement dans 14 zones (mapIDs). Les deux IDs spécifiques Forever 98070 et 93225 sont documentés dans les bases publiques.
- **Tests** : Lua 5.1/5.4 sur le guide, les statuts du journal, la boussole, les valeurs protégées, la carte locale/étrangère et la bascule dans l'UI, audit Python des coordonnées et IDs. **Validation dans le client réel à poursuivre** : géographie, traductions, PNJ et chaînes de prérequis.


## 0.3.7-test — 25 novembre 2026

- **Minimap = lanceur, jamais interrupteur** : clic gauche ouvre le guide complet ; clic droit ouvre le mini-bilan. Cliquer à nouveau sur la vue déjà ouverte ne la ferme pas, la conserve à l'écran.
- **Bascule de vues** : cliquer à droite depuis le guide passe au mini, cliquer à gauche depuis le mini ouvre le guide. Le bouton Fermer du guide revient au mini lorsque le guide a été ouvert depuis celui-ci.
- **Fermeture volontaire** : bouton Fermer de la grande fenêtre ou commande `/wcb hide` pour masquer les deux vues. Les anciennes commandes gardent leur comportement explicite.
- **Régression testée** : clics répétés gauche/droit, changement de vue, restauration du mini, fermeture explicite et réouverture. Aucun changement des talents, des équipements, de la route ou des métriques de session.


## 0.3.6-test — 25 novembre 2026

- **Minimap** : placement de l'icône à la distance `min(largeur, hauteur) / 2 + 5` du centre, comme GearQuest/LibDBIcon ; recalcul automatique si la minimap change de dimensions, icône de guerrier centrée sans masque de portrait déformant.
- **Talents** : icônes sans points estompées, rangs investis avec fond ambré, contour doré et témoin discret ; point conseillé du niveau prévisualisé surligné plus fortement. Trois arbres restent côte à côte.
- **Équipement** : suppression de la fiche redondante à droite. Liste plein format avec cinq lignes et tooltips Blizzard au survol. Ajout de deux options de boss au niveau 37, Casque de berserker rageur (#7719) et Epaulière d'Herode (#7718), tous deux sur Hérode au Monastère écarlate - Armurerie. Ajout également du Fendoir de Glouton (#10772), hache 1M sur Glouton dans les Souilles de Tranchebauge, donjon déjà visité pour la quête #3341. Pas de rang GearQuest prétendu ; l'utilité reste à comparer à l'objet porté.
- **Parcours** : infobulle native de l'objet/recompense au survol de son icône ; bouton Détails pour les étapes, quêtes et objectifs en cours, fabrication et boss. Précisions sur où apprendre ou vérifier les plans de Forge, avec prudence sur les sources non certifiées.
- **Mini-bilan** : palette anthracite et accents bronze alignés sur le guide complet, sans changer sa taille, ses cinq informations ou ses options.
- **Non-régression** : tests Lua 5.1/5.4 et validation des nouvelles sources de butin, des liaisons au parcours, des états de talents, des tooltips et du placement adaptatif.


## 0.3.5-test — 24 novembre 2026

- **Correction du clic droit sur l'icône de minimap** : les nombres secrets de WoW Forever ne sont plus comparés dans `Session.lua` ; lecture protégée par `issecretvalue` et repli sécurisé. L'affichage compact montre `--` quand la donnée est inaccessible (temps, monnaie, objectifs de session).
- **Protection supplémentaire** : même vérification des valeurs dans `CompactDashboard.lua` (horloge, solde, position sauvegardée, delta `OnUpdate`) et `MinimapButton.lua` (coordonnées du curseur, angle et échelle).
- **Bouton rond** : habillage standard des addons utilisant LibDBIcon (31 px, fond `UI-Minimap-Background`, bordure dorée `MiniMap-TrackingBorder`, surbrillance ronde, icône de 20 px avec masque circulaire si l'API est disponible). Suppression de la grande icône carrée.
- **Tests de non-régression** : nombres simulés comme secrets, comportement de l'XP, de la monnaie, de l'horloge, de la santé, du déplacement autour de la minimap ; contrôle des textures et dimensions du bouton.


## 0.3.4-test — 24 novembre 2026

- **Minimap** : icône guerrier visible par défaut, déplaçable autour de la minimap avec angle enregistré. Clic gauche pour ouvrir/fermer le guide ; clic droit pour basculer le mini-bilan ; commande `/wcb minimap on/off`.
- **Mini-bilan 304 × 88 px restauré** depuis le `CompactDashboard.lua` d'origine : XP gagnée, durée de session, morts, solde en or/argent/cuivre avec code couleur, conseil, déplacement libre avec position sauvegardée et bouton `>>` pour développer le guide.
- **Sessions** : suivi indépendant via `PLAYER_XP_UPDATE`, `PLAYER_LEVEL_UP`, `PLAYER_DEAD`, `PLAYER_MONEY` ; remise à zéro par `/wcb reset`. Aucune XP supposée en cas de données ambiguës.
- **Comportement au login** : seule la minimap s'affiche par défaut, sans ouverture forcée de la grande application. `/wcb autostart on/off` restaure l'ouverture automatique dans le dernier mode sélectionné.
- **Compatibilité** : mini / guide n'utilisent pas les mêmes fenêtres que l'ancien addon ; les versions peuvent coexister, mais on recommande de désactiver l'ancien addon lors des tests pour éviter les doublons de suivi de session.
- **Tests** : mini-bilan, monnaie positive/négative, XP/temps/morts, commandes de modes, minimap, position, réinitialisation, autostart et validation syntaxique Lua 5.1/5.4.


## 0.3.3-test — 24 novembre 2026

- **Segments de niveaux** : 1–9, 10–19, 20–29, 30–40 inclusif, 41–50 et 51–60 ; navigation directe d'une tranche a l'autre. Les segments sans quetes verifiees restent des apercus, pas des quetes inventees.
- **Journal de quetes Forever** : utilisation de `C_QuestLog.GetNumQuestLogEntries`, `GetInfo`, `IsComplete` et `IsQuestFlaggedCompleted` (ou `GetAllCompletedQuestIDs` en secours) pour identifier quetes en cours, pretes a rendre et rendues. Ne jamais confondre objectif termine et quete rendue.
- **Liste complete a defilement vertical** : molette et glissiere; cinq lignes visibles en permanence sur la totalite des objectifs du segment; filtre « Afficher les terminees ». Les quetes deja rendues sont masquees par defaut.
- **Recommandations prudentes** : quetes pretes a rendre, puis actives, puis objectifs solo proches du niveau. Regroupement explicite des hubs connus 30–40, sans imposer donjon ou longue chaine facultative. Aucun calcul mensonger de distance ni de DPS.
- **Informations dynamiques** : texte du premier objectif en cours depuis `GetQuestObjectives` lorsqu'il est disponible, et rafraichissement sur les evenements de journal/acceptation/abandon/rendu.
- **Interface** : statuts et reperes couleur quete XP, groupe, option, equipement, trajet, forge; progression de segment; saut depuis la fiche d'equipement vers l'etape correspondante. Footer de diagnostic superflu supprime.
- **Tests** : cas de quete acceptee/en cours/prete a rendre/rendue, liste filtree, variantes d'API Forever, tranches 30–40 et 51–60, curseur et choix de l'objectif propose. Validation Lua 5.1/5.4 en CI.


## 0.3.2-test — 23 novembre 2026

- **Erreur de lancement corrigée** : suppression de l'enregistrement de `LEARNED_SPELL_IN_TAB`, événement inconnu de WoW Forever ; `SPELLS_CHANGED` reste écouté.
- **Talents** : trois arbres affichés simultanément, avec grille complète, rangs, flèches de prérequis, surbrillance et infobulles, sans panneau explicatif latéral.
- **Équipement** : liste ordonnée consultable à la molette et via glissière verticale compatible quand disponible ; objets atteignables d'abord, paliers futurs ensuite. Suppression de la pagination « Paliers suivants ».
- **Parcours** : marqueurs visuels par type (quête XP, équipement, groupe, option, trajet, forge, maître), traduction des intitulés connus et ajouts de quêtes d'XP des Salines #1105 et #1175. Les intitulés non confirmés sont descriptifs, non présentés comme traductions officielles.
- **Rotation** : Fracasser armure intégré au monocible pour les ennemis robustes, pas conseillé à chaque cible ; correction de l'ID Forever d'Ivresse de la victoire vers #402927. Le statut des sorts appris est masqué, les rangs documentés et accessibles chez le maître sont signalés pour Cri de guerre, Frappe héroïque et Fracasser armure. Lecture incomplète du grimoire = « à vérifier ».
- **Tests** : simulation des trois arbres simultanés, du défilement vertical, des badges de route, de la reconnaissance des rangs et de l'absence d'événement inconnu. Compatibilité Lua 5.1/5.4 vérifiée en CI ; rendu final encore à essayer sur Forever.



## 0.3.1-test — 23 novembre 2026

- **Équipement par niveau** : la sélection principale exclut les objets dont le palier d'accès est futur ; pagination des cibles actuelles puis écran séparé pour les récompenses à venir. La fiche distingue niveau requis pour porter et palier conseillé pour obtenir.
- **Grimoire** : reconnaissance des libellés français avec/sans accents et lecture de secours par les noms de sorts quand `GetSpellBookItemInfo` est absent, sans inventer « non appris ».
- **Rotation** : boucle textuelle adaptée au palier, trois réactions visibles (Fulgurance, Ivresse de la victoire, Exécution). Rage sanguinaire mentionnée hors GCD ; Fulgurance reste une réaction sur GCD.
- **Parcours** : The Islander #1718 puis The Affray #1719 (posture Berserker), Salt Flat Venom #1104 (chaîne à vérifier), Kodo Roundup #5561, Catch of the Day #5386 et arrêt de métier chez Wulan à Désolace. Ces ajouts ne constituent pas une route exhaustive 1–60.
- **Tests de non-régression** : équipement accessible/futur, pages de navigation, sort de rang supérieur/accents, API incomplète, réactions et identifiants des nouvelles étapes.



## 0.3.0-test — 23 novembre 2026

- **Trois arbres consultables** Armes, Furie et Protection, même budget de 51 points, positions/icônes et prérequis versionnés, surbrillance du point alloué au niveau demandé. Variantes **Furie pure 0/51/0** et hybride expérimental **13/38/0**, sans changement de spé du personnage.
- **Rotation plus utile** : buffs à maintenir (avec détection prudente de Cri de guerre si aura disponible), ouverture, boucle, réactions/procs, gros CD offensifs et défensifs. Choix mono/multicible ; Fulgurance est réactive mais **soumise au GCD**.
- **Correction de l'état des sorts** : lecture du grimoire par famille et nom localisé, compatible avec rangs supérieurs. En cas d'API incomplète, afficher `Apprentissage à vérifier`, jamais un faux `Non appris`.
- **Équipement** : sélection de 4 recommandations selon niveau, priorité armes, malus pour donjons et futures chaînes longues, navigation vers les autres paliers ; distinction niveau de port / niveau d'accès à une quête.
- **Parcours étoffé** : chaînes Horde Désolace avec identifiants (Kolkar, Alliance Relations, Gelkis), prérequis connus ou statut explicitement incertain, et chaîne Forever facultative de la Vallée des Os vers les niveaux 42–43.
- **Audit critique** : Bludgeon of Betrayed Virtues provient de `Khan Jehn 93128` (**Gelkis Honoré**, longue chaîne), **pas** de `Khan Jehn 1374`. Recommandation différée et reliée à la bonne quête.
- **Correction Forge** : Golden Scale Leggings nécessite 145 pour apprendre le plan ; 170 indique la difficulté jaune, pas le minimum.
- Tests Lua 5.1/5.4 sur les 3 arbres, les variantes, le grimoire de rang supérieur, les états d'aura, les quêtes et le lien objets → route. L'optimisation DPS reste non mesurée et le 1–60 hors pilote non validé.

## 0.2.0-test — 23 novembre 2026

- Police sans empattement `Fonts\\ARIALN.TTF` (police intégrée au client, style moderne proche Roboto).
- Correction du problème de panneaux qui pouvaient masquer les textes : fonds rendus comme textures, sous les contrôles.
- **Talents :** contour doré sur le point obtenu exactement au niveau prévisualisé ; rangs déjà acquis plus discrets, détails accessibles et infobulles par rang.
- **Équipement :** icônes d'objets depuis l'API client, infobulles des vrais objets, détails de source, niveau et fabrication, lien direct avec l'étape du Parcours.
- **Parcours :** grande carte d'étape active et liste de suivantes lisibles, à la manière de PexGuide. Les quêtes de donjon restent facultatives.
- **Rotation :** quatrième onglet avec priorités indicatives monocible/multicible, icônes, conditions et infobulles ; pas de lancement automatique.
- Boutons `+` et `-` conservés pour adapter la taille. Suppression des commandes de mode `compact` et `grand`.
- L'ancien addon et ses tests sont conservés historiquement sur `main` mais retirés du contenu actif de la branche de développement.
- Tests de syntaxe et de comportement Lua 5.1/5.4 mis à jour.

## 0.1.0-test — 23 novembre 2026

- Prototype autonome à trois onglets Talents, Équipement et Parcours, profil Furie 1–60 et pilote de niveaux 30–40.
- Validation structurelle des 51 allocations, des seuils d'équipement et de la correspondance obligatoire équipement → quête/fabrication du parcours.

L'ancien historique du tableau de bord Warrior Companion est disponible dans la branche `main` et dans l'historique Git.
