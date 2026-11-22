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
