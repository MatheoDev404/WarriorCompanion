# Vérification sur WoW Forever

## Référence de l’audit

Le point de départ est la version 0.2.0, commit `c1d15f9`. La revue couvre les cinq modules Lua, le TOC, les deux tests, le workflow, les fichiers de documentation et les exclusions Git. La référence technique est l’export de l’interface Blizzard pour Forever 1.60.1, build 71037, commit `734f065`. [Arbre de référence](https://github.com/Gethe/wow-ui-source/tree/734f065329cff4992835b01a84f210a297db91b6/Interface/AddOns)

| Sujet | Contrat consulté |
| --- | --- |
| Quêtes | `C_QuestLog.GetNumQuestLogEntries()` renvoie les lignes affichées, puis le nombre de quêtes. L’interface Camelot utilise le deuxième résultat pour son compteur. [Interface du journal](https://github.com/Gethe/wow-ui-source/blob/734f065329cff4992835b01a84f210a297db91b6/Interface/AddOns/Blizzard_UIPanels_Game/Camelot/QuestMapFrameUtils.lua#L16) |
| Talents | `C_ClassTalents.HasUnspentTalentPoints()` renvoie un booléen, les points de classe et les points de spécialisation. [Signature](https://github.com/Gethe/wow-ui-source/blob/734f065329cff4992835b01a84f210a297db91b6/Interface/AddOns/Blizzard_APIDocumentationGenerated/ClassTalentsDocumentation.lua#L195) |
| XP et niveau | `UnitXP`, `UnitXPMax` et `UnitLevel` lisent le joueur. `PLAYER_LEVEL_UP` transporte le nouveau niveau. L’ordre de mise à jour de ces lectures reste à vérifier sur le client. [Fonctions et événements](https://github.com/Gethe/wow-ui-source/blob/734f065329cff4992835b01a84f210a297db91b6/Interface/AddOns/Blizzard_APIDocumentationGenerated/UnitDocumentation.lua) |
| Combat et lectures restreintes | L’initialisation lit `InCombatLockdown()`. Les lecteurs écartent les valeurs signalées par `issecretvalue`. [État de combat](https://github.com/Gethe/wow-ui-source/blob/734f065329cff4992835b01a84f210a297db91b6/Interface/AddOns/Blizzard_APIDocumentationGenerated/RestrictedActionsDocumentation.lua#L45) · [Valeurs secrètes](https://github.com/Gethe/wow-ui-source/blob/734f065329cff4992835b01a84f210a297db91b6/Interface/AddOns/Blizzard_APIDocumentationGenerated/FrameScriptDocumentation.lua#L287) |
| Monnaie | `GetMoney()` fournit une valeur numérique. La variation requiert une première lecture exploitable. [Signature](https://github.com/Gethe/wow-ui-source/blob/734f065329cff4992835b01a84f210a297db91b6/Interface/AddOns/Blizzard_APIDocumentationGenerated/PlayerScriptDocumentation.lua#L642) |

## Essai en jeu à effectuer

1. Installer l’addon, activer les erreurs avec `/console scriptErrors 1`, puis faire `/reload`. Relever le build dans `/dump GetBuildInfo()`, la version dans `/wc status` et les API signalées.
2. Ouvrir `/wc`, déplacer la fenêtre et la fermer avec la croix. Vérifier que le tableau reste fermé lors d’un gain d’XP et que les conseils courants sont présents à sa réouverture.
3. Exécuter `/wc reset`, puis `/wc debug on`. Noter l’XP et le seuil avant un gain ordinaire et avant un passage de niveau. Après un seul niveau, comparer le gain au seuil précédent moins l’XP précédente, plus la nouvelle XP. Comparer à nouveau après un changement de zone. Noter toute divergence et les messages de `/wc logs`. Une barre inactive ou un saut de plusieurs niveaux peut laisser une partie du gain non mesurée.
4. Replier une catégorie dans le journal de quêtes puis accepter et rendre une quête. Le repli doit garder le même total. Comparer aussi le solde d’argent avant et après un achat.
5. Avec un point de talent disponible, comparer le message au panneau du personnage. Lors d’un rechargement en combat, vérifier que l’alerte attend la sortie du combat. Dépenser le point et vérifier que le conseil disparaît. Avec `/wc alerts off`, vérifier que le tableau reste consultable sans notification.
6. Après trois morts, chercher le conseil dans le tableau. Changer un objet équipé et observer les traces. Avec `/wc debug off` puis `/wc logs`, vérifier que le journal est vide. Finir avec `/wc reset` et contrôler les compteurs.

Consigner le build, la version de l’addon, l’action, le résultat attendu, le résultat observé et la première erreur Lua éventuelle. Le rendu, les restrictions réelles du client et l’ordre des événements nécessitent cet essai. Aucun résultat en jeu n’a été consigné pour la version 0.2.1.

## Test additionnel — historique 0.2.2

1. Exécuter `/wc reset`, puis `/wc history` avant toute nouvelle activité. Vérifier que l’historique est vide.
2. Gagner de l’XP près d’un changement de zone. Comparer la variation du compteur dans `/wc status` aux gains affichés par `/wc history`. Vérifier que chaque gain mesuré apparaît une fois.
3. Changer rapidement deux pièces sur des emplacements différents. Si les deux numéros sont lisibles, vérifier que l’historique contient les deux emplacements.
4. Exécuter `/wc debug off`, puis consulter `/wc logs` et `/wc history`. Le diagnostic doit être vide et les activités doivent encore être présentes. Vérifier ensuite leur effacement avec `/wc reset`.

Ces scénarios ont été simulés sous Lua. Leur exécution avec la version 0.2.2 de l’addon sur le client Forever reste à consigner.

## Test du module Combat (0.3.0-dev)

1. Faire `/wc combat` avant tout combat : 0 intervalle terminé.
2. Engager un ennemi, sortir du combat puis `/wc combat` : un intervalle et une durée plausibles.
3. Engager deux ennemis à la suite sans sortie de combat : un intervalle (et non deux ennemis) doit être compté.
4. Changer de zone pendant un combat (si possible sans danger) : l'intervalle en cours doit être classé interrompu.
5. Faire `/wc reset` : les métriques de combat doivent revenir à zéro.
6. Le module ne mesure pas les dégâts et n'attribue pas l'XP au dernier ennemi ; ces informations restent à valider avec le client.

## Test additionnel — performance glissante 0.3.1-dev

1. `/wc reset` puis `/wc performance` : taux récents indisponibles pendant la première minute.
2. Gagner de l'XP et attendre au moins 60 secondes depuis le reset : les taux doivent devenir disponibles.
3. Après dix minutes, une XP gagnée il y a plus de dix minutes ne doit plus entrer dans le taux récent.
4. Après `/wc reset`, l'historique de performance doit repartir de zéro.
5. Comparer `/wc`, `/wc performance` et `/wc status`. Les taux peuvent différer légitimement, car les fenêtres sont différentes.

## Test en jeu : style Horde guerrier (0.4.0-rc1)

1. `/wc` doit afficher un cadre acier sombre, bandeau rouge, bordures bronze et icône guerrier intégrée.
2. Contrôler titres, chiffres, couleur et retours à la ligne à plusieurs échelles d'interface, sans chevauchement.
3. Vérifier que les quatre sections montrent XP/heure session, XP/heure 10 minutes, combat, conseils, et deux dernières activités (si observées).
4. Déplacer la fenêtre, fermer avec la croix, rouvrir : aucun nouvel avertissement de talent ne doit être envoyé uniquement à cause de l'ouverture.
5. Vérifier la lisibilité du texte lors d'un combat et après `/wc reset`.
6. En cas de valeur indisponible, le tableau doit afficher un remplacement plutôt qu'une erreur Lua.


## HUD moderne D — test visuel v0.4.1-rc1

1. Installer l'addon, `/reload` puis `/wc` : HUD compact avec bandeau rouge Horde et barre latérale.
2. Cliquer sur les quatre icônes Bilan, Combat, Conseils, Journal : seule la vue choisie doit être visible.
3. Déplacer la fenêtre, la fermer avec la croix et la rouvrir. Aucune erreur Lua ni nouvelle alerte déclenchée par la seule navigation.
4. Vérifier les trois icônes natives **or / argent / cuivre** et une variation de session après achat, butin ou vente.
5. Tester les valeurs : +0, +1 or 23 argent 45 cuivre, et une variation négative. Aucun champ ne doit afficher un nombre négatif isolé en argent ou cuivre.
6. Contrôler les tailles de police et les débordements à l'échelle UI habituelle et sur petit écran.
7. Vérifier le rafraîchissement des valeurs après un gain d'XP et l'absence de notifications supplémentaires provoquées par les mises à jour graphiques.


## Validation visuelle V0.4.2-rc1 — fidélité à la maquette D

1. Vérifier que `Textures/HordeSky.tga` et `Textures/Warcrest.tga` sont présents dans le dossier addon après copie.
2. Faire `/reload` puis `/wc`. Le bandeau rouge doit montrer une silhouette de forteresse, l'écusson doit être un bouclier rouge et noir (pas une texture blanche ou verte).
3. Sur la page Bilan, vérifier simultanément les 4 compteurs du haut, les icônes de monnaie, les deux cartes Combat et Conseil, puis l'historique court en bas.
4. Tester les 4 onglets latéraux, les variations d'or/argent/cuivre négatives, la fermeture, le déplacement et l'échelle de l'interface.
5. Prendre une capture : vérifier que les ornements, chiffres et textes ne se chevauchent pas dans le client réel.

## Test en jeu : conseiller de PV (0.5.0-rc1)

1. Activer `/console scriptErrors 1`, faire `/reload`, puis `/wc health` au repos avec PV complets.
2. Sur un personnage vivant avec moins de 35 % PV **hors combat**, ouvrir `/wc` puis l'onglet Conseils : un rappel de récupération doit apparaître, sans message de chat automatique.
3. Une fois soigné à 35 % ou plus, ce conseil doit disparaître lors du prochain changement de PV.
4. Pendant le combat, aucun rappel de récupération ne doit s'ajouter ; vérifier sa mise à jour après la sortie du combat.
5. Après une mort ou une résurrection, le conseil ne doit pas inventer un pourcentage si l'API n'est pas lisible.
6. `/wc health` affiche la mesure ou `indisponibles`. Fournir les erreurs Lua éventuelles et la sortie de cette commande.

## Tests guerrier Furie 0.5.1-rc1

1. Sur guerrier, faire `/wc fury` : la classe doit être reconnue sans prétendre connaître la spécialisation réelle.
2. Descendre sous 35 % PV hors combat : le conseil doit mentionner les bandages ou la nourriture dans l'onglet Conseils.
3. Repasser au-dessus du seuil : le conseil doit disparaître.
4. Après cinq phases de combat dont la durée moyenne dépasse 45 s, un conseil d'efficacité devrait apparaître ; il ne doit pas prétendre connaître le DPS réel.
5. Vérifier l'absence de notification automatique pour ces conseils.

## Test en jeu du grimoire V0.5.2-rc1

1. Connecter un guerrier puis `/wc spells` : afficher un nombre de sorts/rangs détectés. Si absent, noter précisément le diagnostic.
2. Apprendre réellement un rang chez un maître, puis `/wc spells` : il doit figurer comme nouveauté observée.
3. Ouvrir `/wc` → Conseils : suggestion de vérifier les barres d'action pendant dix minutes, sans notification chat automatique.
4. Si le grimoire est temporairement indisponible, ne pas afficher de conseil fondé sur une lecture incomplète.
5. `/wc reset` réinitialise la référence du grimoire et n'annonce pas les sorts déjà connus comme nouvellement appris.

## Test de la minimap et de l'ouverture automatique (0.5.3-rc1)

1. Activer l'addon, se connecter au personnage : le tableau de bord doit s'ouvrir automatiquement **une fois**.
2. En haut à droite de la minimap, repérer le petit écusson guerrier. Cliquer : la fenêtre doit s'ouvrir/fermer. Le survol doit afficher Warrior Companion.
3. Fermer la fenêtre, changer de zone : elle ne doit pas s'ouvrir à nouveau automatiquement.
4. `/wc autostart off` puis déconnexion/reconnexion : la fenêtre doit rester fermée mais le bouton de minimap reste visible.
5. `/wc autostart on` puis déconnexion/reconnexion : la fenêtre doit à nouveau s'ouvrir au lancement.
6. `/wc` doit continuer à ouvrir/fermer la fenêtre indépendamment de l'option de démarrage.

## Bouton déplaçable V0.5.4-rc1

1. Au lancement, l'icône doit apparaître sur le contour de la minimap.
2. Maintenir le clic gauche sur l'icône et la glisser sur plusieurs côtés : elle doit suivre le bord circulaire sans se déplacer au centre.
3. Relâcher puis cliquer normalement : le tableau s'ouvre et se ferme.
4. Se déconnecter, se reconnecter : l'icône doit retrouver sa dernière position.
5. Vérifier que l'ouverture automatique du tableau reste réglable par `/wc autostart on/off`.

## Vérification visuelle V0.5.5 — icône standard WoW

1. Observer l'icône guerrier sur la minimap à côté de celles des autres addons : elle doit avoir la même bordure circulaire dorée, et non un écusson carré.
2. Vérifier l'effet visuel au survol et au clic, puis glisser le bouton autour du contour circulaire.
3. Cliquer pour ouvrir/fermer Warrior Companion ; la fenêtre ne doit pas s'ouvrir à la fin d'un glisser-déposer.
4. Reconnecter le personnage : la position de l'icône doit rester stable ; l'option d'ouverture auto doit être respectée.
5. Si un addon remplace la minimap par un carré et fournit GetMinimapShape, vérifier le positionnement dans les coins.

## Armes Furie V0.5.6 — test en jeu

1. `/wc weapons` : identifier les emplacements main droite et main gauche (numéro d'objet et type). Noter si la lecture du type est indisponible.
2. Avec une arme à une main et main gauche vide, sur guerrier de niveau 20+, ouvrir Conseils : suggestion conditionnelle de double maniement.
3. Avec une arme à deux mains, vérifier qu'aucun conseil de main gauche vide n'est émis.
4. Avec un bouclier en main gauche, vérifier le conseil informatif ; avec deux armes équipées, il disparaît.
5. Sur une autre classe ou en cas de lecture API impossible, aucun conseil d'arme Furie ne doit apparaître.
6. Vérifier que `/wc reset` reprend une photographie valide des armes.

## Vérification GearQuest et pertinence (0.5.7)

1. Sans GearQuest installé, `/wc gear` doit indiquer que les suggestions de provenance sont indisponibles, sans noms d'objets inventés.
2. Installer GearQuest Forever, relancer le jeu puis `/wc gear` : l'addon doit être détecté.
3. Sur un guerrier Furie, monter d'un niveau ou changer une pièce d'équipement : le conseil doit proposer de consulter `/gq` pour **tous les emplacements**, pas seulement les armes. Après dix minutes, il doit disparaître.
4. Dans GearQuest, sélectionner Guerrier/Furie, niveau actuel, vérifier les sources quêtes/boss/vendeurs et la comparaison avec l'objet équipé.
5. En combat, aucun nouveau conseil de provenance ne doit être généré. Les prix et les disponibilités HDV ne doivent jamais être déclarés confirmés par Warrior Companion.

## Test V0.5.8 : compacité et minimap

1. Faire `/reload`, ouvrir `/wc` : fenêtre 600×360, les quatre compteurs, l'argent, Combat, Conseil et Activités doivent rester visibles.
2. Cliquer Bilan / Combat / Conseils / Journal : aucune vue ne doit déborder ; le conseil complet doit rester visible dans l'onglet dédié.
3. Contrôler que les icônes or / argent / cuivre et l'XP/h restent lisibles à l'échelle UI du joueur.
4. Sur la minimap actuelle, exécuter `/wc minimap reset` : l'icône doit toucher l'anneau sans flotter loin du bord.
5. Faire glisser le bouton sur différents angles ; déconnexion/reconnexion doit conserver l'angle.
6. Comparer une capture d'écran avec les autres boutons d'addons et relever les éventuels conflits de position.

## Tests talents V0.5.9

1. Faire `/wc talents` au repos : vérifier le total, la ventilation classe/spécialisation et l'absence d'affirmation sur un talent précis.
2. Gagner un point par niveau puis `/wc talents` : le compteur doit évoluer si Forever transmet les données.
3. Dépenser un point : un changement du nombre de points doit être consigné dans `/wc history`, sans prétendre connaître le talent choisi.
4. `/wc reset` efface cet historique de session et reconstruit la photographie de référence.
5. API indisponible : `/wc talents` indique l'indisponibilité plutôt que d'afficher des données inventées.

## Test V0.6.0 — quêtes et Questie

1. Tester `/wc quests` sur un guerrier Horde avec des quêtes acceptées de niveaux différents. Vérifier la classification et l'ordre des cinq premières.
2. Une quête marquée donjon/groupe/élite doit être annoncée comme non solo ; si le type n'est pas lisible, le statut doit rester inconnu.
3. Vérifier qu'une quête prête à rendre est priorisée sans inventer son PNJ de remise.
4. Installer une version de Questie adaptée à Forever : `/wc questie` doit indiquer son état. Les marqueurs restent ceux de Questie.
5. Accepter/mettre à jour une quête : le classement doit se rafraîchir sur `QUEST_LOG_UPDATE` ou notification publique Questie.
6. Hors du personnage guerrier Horde, aucun conseil spécifique ne doit être généré.
7. Sans Questie, le journal du client doit continuer de fonctionner, ou annoncer explicitement une indisponibilité API.
8. Vérifier que le nouveau conseiller ne déclenche pas d'alertes intrusives pendant le combat.

## Tests V0.6.1 — quêtes non acceptées

1. Installer QuestieDB **compatible Forever** : `/wc discover` doit afficher jusqu'à sept pistes en dehors du combat. En l'absence de QuestieDB, afficher « indisponible » et non inventer une liste.
2. Vérifier dans Questie que les IDs suggérés existent, que la quête n'est ni déjà acceptée ni terminée, et qu'elle correspond à une race/classe Horde autorisée.
3. Contrôler les PNJ de départ, la disponibilité sur ce royaume et les difficultés réelles (élite, groupe, donjon, ennemis au-dessus du niveau) : ces faits ne sont **pas** garantis par le nouveau moteur.
4. Essayer une quête à prérequis : elle doit être exclue tant que son préalable n'est pas évalué.
5. Changer de niveau et relancer `/wc discover` : la sélection doit être recalculée sur les nouvelles données et rester limitée.
6. En combat, aucune analyse du catalogue ne doit être déclenchée.
7. Confirmer que les marqueurs Questie fonctionnent et qu'aucun marqueur Warrior Companion supplémentaire n'a été créé.
