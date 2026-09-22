#!/bin/bash
# Telecharge le jeu de journaux Windows du groupe et le depose dans windows-logs/.
# Les fichiers sont renommes de facon neutre pour ne pas divulguer la technique.
# Source : depot public d'echantillons EVTX d'attaque.
set -u

DEST="windows-logs"
detect_group() {
    local src="${GITHUB_REPOSITORY:-${RepositoryName:-}}"
    src="${src,,}"
    if [[ "$src" == *cy3a* ]]; then echo "CY3A"; return; fi
    if [[ "$src" == *cy3b* ]]; then echo "CY3B"; return; fi
    tr -d '[:space:]' < .r512-group 2>/dev/null || echo "CY3B"
}
GROUP="$(detect_group)"

# Deja present : on ne retelecharge pas
if [ -d "$DEST" ] && [ "$(ls -1 "$DEST"/*.evtx 2>/dev/null | wc -l)" -ge 6 ]; then
    echo "Journaux Windows deja en place dans $DEST/"
    exit 0
fi

TMP="$(mktemp -d)"
URL="https://codeload.github.com/sbousseaden/EVTX-ATTACK-SAMPLES/tar.gz/refs/heads/master"
echo "Telechargement des journaux Windows..."
if ! curl -fsSL -o "$TMP/e.tgz" "$URL"; then
    echo "Telechargement impossible. Relancez : fetch-windows-logs"
    rm -rf "$TMP"; exit 0
fi
tar -xzf "$TMP/e.tgz" -C "$TMP"
SRC="$TMP/$(ls "$TMP" | grep EVTX-ATTACK-SAMPLES)"

# Correspondance emplacement neutre -> fichier source, propre a chaque groupe
if [ "$GROUP" = "CY3A" ]; then
    declare -a MAP=(
      "win-evt-01|Credential Access/sysmon_10_1_memdump_comsvcs_minidump.evtx"
      "win-evt-02|Execution/exec_persist_rundll32_mshta_scheduledtask_sysmon_1_3_11.evtx"
      "win-evt-03|Defense Evasion/DE_104_system_log_cleared.evtx"
      "win-evt-04|Lateral Movement/LM_wmiexec_impacket_sysmon_whoami.evtx"
      "win-evt-05|Privilege Escalation/privesc_roguepotato_sysmon_17_18.evtx"
      "win-evt-06|Persistence/sysmon_20_21_1_CommandLineEventConsumer.evtx"
    )
else
    declare -a MAP=(
      "win-evt-01|Lateral Movement/LM_renamed_psexecsvc_5145.evtx"
      "win-evt-02|Credential Access/sysmon_10_lsass_mimikatz_sekurlsa_logonpasswords.evtx"
      "win-evt-03|Execution/revshell_cmd_svchost_sysmon_1.evtx"
      "win-evt-04|Defense Evasion/DE_1102_security_log_cleared.evtx"
      "win-evt-05|Persistence/sysmon_local_account_creation_and_added_admingroup_12_13.evtx"
      "win-evt-06|Privilege Escalation/EfsPotato_sysmon_17_18_privesc_seimpersonate_to_system.evtx"
    )
fi

mkdir -p "$DEST"
n=0
for entry in "${MAP[@]}"; do
    dst="${entry%%|*}"
    src="${entry#*|}"
    if [ -f "$SRC/$src" ]; then
        cp "$SRC/$src" "$DEST/$dst.evtx"
        n=$((n+1))
    else
        echo "Introuvable dans la source : $src"
    fi
done
rm -rf "$TMP"
echo "$n journaux Windows deposes dans $DEST/ (groupe $GROUP)."
