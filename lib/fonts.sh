#!/usr/bin/env bash
set -euo pipefail

FONT_DIR="${HOME}/.local/share/fonts/jetbrains-nerd"
FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"

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

install_jetbrains_nerd_font() {
    if [[ -d "${FONT_DIR}" ]] && [[ -n "$(ls -A "${FONT_DIR}" 2>/dev/null)" ]]; then
        log "INFO" "JetBrains Mono Nerd Font already installed at ${FONT_DIR}"
        return 0
    fi

    log "INFO" "Installing JetBrains Mono Nerd Font..."

    mkdir -p "${FONT_DIR}"

    if command -v curl &> /dev/null; then
        run "curl -L '${FONT_URL}' -o /tmp/jetbrains-nerd.zip"
    elif command -v wget &> /dev/null; then
        run "wget -O /tmp/jetbrains-nerd.zip '${FONT_URL}'"
    else
        log "ERROR" "Neither curl nor wget found. Cannot download font."
        return 1
    fi

    run "unzip -o /tmp/jetbrains-nerd.zip -d '${FONT_DIR}'"
    run "rm -f /tmp/jetbrains-nerd.zip"

    if command -v fc-cache &> /dev/null; then
        run "fc-cache -fv '${FONT_DIR}'"
    fi

    log "INFO" "JetBrains Mono Nerd Font installed successfully"
}

verify_font_installed() {
    if [[ -d "${FONT_DIR}" ]] && [[ -n "$(ls -A "${FONT_DIR}" 2>/dev/null)" ]]; then
        return 0
    fi
    return 1
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "${1:-}" in
        --install)
            install_jetbrains_nerd_font
            ;;
        --verify)
            if verify_font_installed; then
                echo "Font installed: ${FONT_DIR}"
                exit 0
            else
                echo "Font not installed"
                exit 1
            fi
            ;;
        *)
            echo "Usage: $0 {--install|--verify}"
            ;;
    esac
fi
