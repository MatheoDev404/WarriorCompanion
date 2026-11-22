# Premier test en jeu - WoW Forever

1. Installer le dossier `Addon/WarriorCompanion` dans le dossier `Interface/AddOns/` du jeu.
2. Executer `/console scriptErrors 1` puis `/reload`.
3. Executer `/wc status` ; noter quelles API sont presentes.
4. Executer `/wc` ; la fenetre doit s'ouvrir, afficher les metriques et se fermer avec le bouton X.
5. Executer `/wc debug on`, gagner de l'XP, puis `/wc logs`. Verifier le gain.
6. Observer un passage de niveau si possible ; ne pas accepter un double comptage XP.
7. Changer d'argent ou de journal de quetes et verifier l'affichage.
8. Verifier qu'une alerte de talent (si l'API existe et des points sont libres) ne se repete pas immediatement, ni en combat.
9. Executer `/wc reset`, puis `/wc debug off` pour effacer le journal.

Envoyer les messages d'erreur Lua et le resultat de `/wc status` pour corriger les incompatibilites.

**Limites connues :** XP/h est une moyenne de session, pas un indicateur glissant ; apres un saut de plusieurs niveaux les gains inconnus ne sont pas estimes ; les quetes et competences restent des observations basiques, pas des conseils prescriptifs.
