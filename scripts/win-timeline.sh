#!/bin/bash
# Construit la timeline des journaux Windows avec Hayabusa.
# Se placer a la racine du depot, quel que soit son nom
cd "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOGS="${1:-windows-logs}"
if [ ! -d "$LOGS" ]; then
    echo "Dossier $LOGS introuvable. Lancez d'abord : fetch-windows-logs"
    exit 1
fi
hayabusa dfir-timeline -d "$LOGS" \
    -r /opt/hayabusa/rules -c /opt/hayabusa/rules/config \
    -o windows-timeline.csv -w -q -m low
echo
echo "Timeline enregistree dans windows-timeline.csv"
echo "Ouvrez-la dans l'editeur, ou filtrez en console, par exemple :"
echo "  column -s, -t windows-timeline.csv | less -S"
