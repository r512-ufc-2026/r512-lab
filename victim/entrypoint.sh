#!/bin/bash
set -u

# Demarrage du serveur web
apachectl start 2>/dev/null || service apache2 start 2>/dev/null || true

# Mise en place de l'incident (une seule fois)
if [ ! -f /var/run/.r512-done ]; then
    R512_GROUP="${R512_GROUP:-CY3B}" /usr/local/bin/compromise.sh || true
    touch /var/run/.r512-done
fi

# Lancement du processus malveillant (porte derobee) sous son vrai chemin
MAL=$(ls /usr/local/bin/.dbus-daemon /usr/local/bin/.gvfsd-helper 2>/dev/null | head -n1)
if [ -n "${MAL:-}" ]; then
    nohup python3 "$MAL" >/dev/null 2>&1 &
fi

# Maintien du conteneur en vie
tail -f /var/log/apache2/access.log
