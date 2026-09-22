#!/bin/bash
# Construit et demarre le conteneur victime dans le Codespace.
# Idempotent : relançable sans risque. Ne fait jamais echouer le Codespace.
set -u

# Se placer a la racine du depot (parent du dossier scripts), quel que soit son nom
cd "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Determination du groupe, par ordre de priorite :
# 1) nom du depot (variable Codespaces) s'il contient cy3a / cy3b
# 2) fichier .r512-group  3) defaut CY3B
detect_group() {
    local src="${GITHUB_REPOSITORY:-${RepositoryName:-}}"
    src="${src,,}"
    if [[ "$src" == *cy3a* ]]; then echo "CY3A"; return; fi
    if [[ "$src" == *cy3b* ]]; then echo "CY3B"; return; fi
    tr -d '[:space:]' < .r512-group 2>/dev/null || echo "CY3B"
}
GROUP="$(detect_group)"
if [ "$GROUP" = "CY3A" ]; then HOSTN="web-app-02"; else HOSTN="web-prod-01"; fi
IMG="r512-victim"
NAME="victim"

# Attente que le demon Docker soit pret (jusqu'a 60 s)
for i in $(seq 1 30); do
    docker info >/dev/null 2>&1 && break
    sleep 2
done
if ! docker info >/dev/null 2>&1; then
    echo "Docker n'est pas encore pret. Relancez : bash scripts/start-victim.sh"
    exit 0
fi

# Conteneur deja en cours : rien a faire
if docker ps --format '{{.Names}}' | grep -qx "$NAME"; then
    echo "La victime tourne deja. Pour entrer : enter-victim"
    exit 0
fi

# Nettoyage d'un ancien conteneur arrete
docker rm -f "$NAME" >/dev/null 2>&1 || true

echo "Construction de la victime (premier lancement : 30 a 60 s)..."
if ! docker build -q -t "$IMG" victim >/dev/null; then
    echo "Echec de construction de la victime. Relancez la commande."
    exit 0
fi

docker run -d --name "$NAME" --hostname "$HOSTN" -e R512_GROUP="$GROUP" "$IMG" >/dev/null 2>&1 || true
sleep 2
if docker ps --format '{{.Names}}' | grep -qx "$NAME"; then
    echo "Victime demarree (groupe $GROUP). Pour commencer le triage : enter-victim"
else
    echo "La victime n'a pas demarre. Relancez : bash scripts/start-victim.sh"
fi
