# Environnement d'analyse R512 - Reponse a incident
FROM mcr.microsoft.com/devcontainers/python:1-3.12-bookworm

ENV DEBIAN_FRONTEND=noninteractive

# Outils systeme (le depot Yarn de l'image de base, inutile et mal signe, est retire)
RUN grep -rl yarnpkg /etc/apt/sources.list.d/ | xargs -r rm -f \
    && apt-get update && apt-get install -y --no-install-recommends \
        yara tshark sleuthkit jq unzip p7zip-full file \
    && rm -rf /var/lib/apt/lists/*

# Outils Python : Volatility 3, YARA, EVTX, registre, Sigma
RUN pip install --no-cache-dir \
        volatility3 yara-python python-evtx regipy sigma-cli

# Chainsaw + regles Sigma + mappings
RUN curl -fsSL -o /tmp/chainsaw.tar.gz \
        https://github.com/WithSecureLabs/chainsaw/releases/latest/download/chainsaw_x86_64-unknown-linux-gnu.tar.gz \
    && mkdir -p /tmp/cs && tar -xzf /tmp/chainsaw.tar.gz -C /tmp/cs \
    && install -m 755 "$(find /tmp/cs -type f -name chainsaw | head -n1)" /usr/local/bin/chainsaw \
    && git clone --depth 1 https://github.com/WithSecureLabs/chainsaw.git /opt/chainsaw \
    && git clone --depth 1 https://github.com/SigmaHQ/sigma.git /opt/sigma \
    && rm -rf /tmp/cs /tmp/chainsaw.tar.gz

# Hayabusa (version musl statique, independante de la glibc de l'image)
RUN url="$(curl -fsSL https://api.github.com/repos/Yamato-Security/hayabusa/releases/latest \
        | jq -r '.assets[].browser_download_url' | grep -E 'lin-x64-musl\.zip$' | head -n1)" \
    && curl -fsSL -o /tmp/hayabusa.zip "$url" \
    && mkdir -p /opt/hayabusa && unzip -q /tmp/hayabusa.zip -d /opt/hayabusa \
    && bin="$(find /opt/hayabusa -maxdepth 1 -type f -name 'hayabusa-*' ! -name '*.zip' | head -n1)" \
    && chmod +x "$bin" && ln -s "$bin" /usr/local/bin/hayabusa \
    && chmod -R a+rwX /opt/hayabusa \
    && rm /tmp/hayabusa.zip
