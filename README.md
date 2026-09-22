# R512 - Reponse a incident

Environnement d'analyse pret a l'emploi, ouvert dans le navigateur via GitHub Codespaces. Aucune installation locale.

## Demarrage

1. Bouton vert Code, onglet Codespaces, Create codespace on main.
2. Attendre la fin de la construction. La victime Linux demarre seule et les journaux Windows sont telecharges.
3. Ouvrir un terminal et commencer le TP.

## Volet Linux (serveur web compromis)

- start-victim : (re)demarre le serveur compromis.
- enter-victim : ouvre un shell dessus pour le triage a chaud.

## Volet Windows (journaux d'evenements)

- fetch-windows-logs : recupere le jeu de journaux (fait automatiquement a la creation).
- win-timeline : construit la timeline des detections avec Hayabusa.
- win-hunt : lance la chasse Sigma avec Chainsaw.

Consignes detaillees : voir TP1-windows.md.

## Outils disponibles

vol (Volatility 3), yara, hayabusa, chainsaw, tshark, python-evtx, regipy, sigma-cli, outils Sleuth Kit.
