# Serveur web "victime" du TP1. Isole, sans acces reseau reel une fois lance.
# Aucun code reellement malveillant : les artefacts sont inertes et servent
# uniquement de traces a decouvrir pendant le triage.
FROM php:8.2-apache

ENV DEBIAN_FRONTEND=noninteractive

# Outils presents sur un vrai serveur, utiles au triage (ps, ss, cron, curl...)
RUN apt-get update && apt-get install -y --no-install-recommends \
        procps iproute2 net-tools cron curl less vim-tiny socat python3 \
    && rm -rf /var/lib/apt/lists/*

# Contenu legitime du site
COPY app/ /var/www/html/

# Scripts d'amorcage et de mise en scene de l'incident
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY compromise.sh /usr/local/bin/compromise.sh
RUN chmod +x /usr/local/bin/entrypoint.sh /usr/local/bin/compromise.sh

EXPOSE 80
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
