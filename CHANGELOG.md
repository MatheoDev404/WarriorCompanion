# Changelog — Warrior Companion Build Planner

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
