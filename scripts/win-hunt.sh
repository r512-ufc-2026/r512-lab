#!/bin/bash
# Chasse a base de regles Sigma sur les journaux Windows avec Chainsaw.
# Se placer a la racine du depot, quel que soit son nom
cd "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOGS="${1:-windows-logs}"
if [ ! -d "$LOGS" ]; then
    echo "Dossier $LOGS introuvable. Lancez d'abord : fetch-windows-logs"
    exit 1
fi
chainsaw hunt "$LOGS" \
    -s /opt/sigma/rules \
    --mapping /opt/chainsaw/mappings/sigma-event-logs-all.yml \
    -r /opt/chainsaw/rules
