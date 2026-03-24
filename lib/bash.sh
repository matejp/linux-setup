#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASH_CONFIG_SOURCE="${SCRIPT_DIR}/../config/bash"

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

run() {
    local cmd="$*"
    log "CMD" "$cmd"
    if [[ "${DRY_RUN:-false}" == "false" ]]; then
        eval "$cmd"
    fi
}

_backup_if_exists() {
    local target="$1"
    if [[ -f "${target}" ]]; then
        local backup="${target}.backup.$(date +%Y%m%d_%H%M%S)"
        log "INFO" "Backing up existing $(basename "${target}") to: ${backup}"
        run "cp '${target}' '${backup}'"
    fi
}

install_bash_config() {
    local source_dir="${1:-$BASH_CONFIG_SOURCE}"

    if [[ ! -d "${source_dir}" ]]; then
        log "ERROR" "Bash config source not found: ${source_dir}"
        return 1
    fi

    log "INFO" "Installing bash configuration..."

    _backup_if_exists "${HOME}/.bashrc"
    run "cp '${source_dir}/bashrc' '${HOME}/.bashrc'"
    log "INFO" "Installed ~/.bashrc"

    _backup_if_exists "${HOME}/.bash_profile"
    run "cp '${source_dir}/bash_profile' '${HOME}/.bash_profile'"
    log "INFO" "Installed ~/.bash_profile"

    log "INFO" "Bash configuration installed"
}

setup_bash() {
    install_bash_config
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "${1:-}" in
        --install)
            install_bash_config "${2:-}"
            ;;
        --setup)
            setup_bash
            ;;
        *)
            echo "Usage: $0 {--install [src_dir]|--setup}"
            ;;
    esac
fi
