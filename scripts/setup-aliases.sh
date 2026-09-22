#!/bin/bash
# Installe les raccourcis pratiques dans le shell de l'etudiant.
# Le chemin du depot est deduit a l'execution : il porte le nom du depot
# de chaque etudiant, jamais un nom fige.
BRC="$HOME/.bashrc"
grep -q 'R512 aliases' "$BRC" 2>/dev/null && exit 0
cat >> "$BRC" << 'ALIASES'

# R512 aliases
r512_dir() {
    if [ -n "${CODESPACE_VSCODE_FOLDER:-}" ]; then
        echo "$CODESPACE_VSCODE_FOLDER/scripts"
    else
        # Repli : premier depot present sous /workspaces
        echo "$(find /workspaces -maxdepth 2 -name start-victim.sh -path '*/scripts/*' 2>/dev/null | head -n1 | xargs -r dirname)"
    fi
}
alias start-victim='bash "$(r512_dir)/start-victim.sh"'
alias enter-victim='bash "$(r512_dir)/enter-victim.sh"'
alias fetch-windows-logs='bash "$(r512_dir)/fetch-windows-logs.sh"'
alias win-timeline='bash "$(r512_dir)/win-timeline.sh"'
alias win-hunt='bash "$(r512_dir)/win-hunt.sh"'
ALIASES
