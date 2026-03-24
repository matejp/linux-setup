#!/usr/bin/env bash
set -euo pipefail

log() {
    local level="$1"
    shift
    local msg="$*"
    if [[ -n "${LOG_FILE:-}" ]]; then
        echo "[$level] $msg" >> "$LOG_FILE"
    fi
    if [[ "${ECHO_COMMANDS:-false}" == "true" ]] && [[ "$level" == "CMD" ]]; then
        echo "[CMD] $msg"
    fi
}

install_gnome_settings() {
    if ! command -v gsettings &>/dev/null; then
        log "INFO" "gsettings not found, skipping GNOME settings"
        return
    fi

    log "INFO" "Applying GNOME desktop settings..."

    gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'minimize' 2>/dev/null || true
}
