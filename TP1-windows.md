# TP1 - Volet Windows : triage des journaux d'evenements

## Contexte

L'investigation du serveur web a montre que l'attaquant a rebondi vers une machine Windows du systeme d'information. Vous disposez d'un jeu de journaux d'evenements exportes de cet hote, dans le dossier windows-logs. Votre travail est de reconstruire ce qui s'est passe sur cette machine a partir des seuls journaux.

## Objectifs

A l'issue de ce volet, vous devez etre capable de :

- construire une timeline de detection a partir de journaux EVTX bruts avec Hayabusa ;
- mener une chasse a base de regles Sigma avec Chainsaw ;
- distinguer le bruit des evenements reellement lies a l'attaque ;
- reconstituer la chaine d'attaque sur l'hote et la cartographier sur MITRE ATT&CK.

## Outils

Deux raccourcis sont disponibles dans le terminal.

- win-timeline : genere windows-timeline.csv, la timeline horodatee des detections.
- win-hunt : lance la chasse Sigma et affiche les correspondances.

Vous pouvez aussi appeler directement hayabusa et chainsaw si vous voulez ajuster les options.

## Marche a suivre

1. Verifiez le contenu du dossier a analyser :
       ls -la windows-logs

2. Construisez la timeline :
       win-timeline
 Ouvrez windows-timeline.csv dans l'editeur (clic dans l'explorateur de gauche), ou en console :
       column -s, -t windows-timeline.csv | less -S

3. Parcourez la timeline de haut en bas. Pour chaque detection de niveau eleve ou critique, notez l'horodatage, le journal source, l'identifiant d'evenement, le processus et l'utilisateur concernes.

4. Lancez la chasse Sigma pour recouper :
       win-hunt

5. Recoupez les deux sorties et construisez votre propre chronologie de l'attaque.

## Questions a traiter

- Quel a ete le premier evenement malveillant observable sur l'hote, et par quel moyen l'attaquant a-t-il execute son code ?
- Quels mecanismes de persistance et d'elevation de privileges apparaissent dans les journaux ?
- Une action visant les secrets d'authentification est-elle visible ? Laquelle, et dans quel journal ?
- L'attaquant s'est-il deplace vers ou depuis cet hote ? Par quel protocole ou service ?
- Une tentative d'effacement de traces est-elle presente ? Laquelle ?

## Livrable

Une fiche d'une a deux pages contenant :

- la chronologie reconstruite des evenements malveillants sur l'hote ;
- pour chaque etape, l'identifiant d'evenement et le journal qui l'atteste ;
- la cartographie MITRE ATT&CK, une technique par etape ;
- la liste des IOC exploitables (comptes, processus, chemins, noms de service).

Deposez la fiche dans votre depot, dans un fichier rapport-tp1.md, puis validez par un commit.
