#!/bin/bash
# Ouvre un shell interactif sur le serveur compromis, pour le triage a chaud.
if ! docker ps --format '{{.Names}}' | grep -qx victim; then
    echo "La victime ne tourne pas. Lancez d'abord : start-victim"
    exit 1
fi
docker exec -it victim /bin/bash
