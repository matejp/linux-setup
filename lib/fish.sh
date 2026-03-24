#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FISH_CONFIG_SOURCE="${SCRIPT_DIR}/../config/fish"
FISH_CONFIG_TARGET="${HOME}/.config/fish"

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

install_fish() {
    source "${SCRIPT_DIR}/distro.sh"

    local distro pm install_cmd
    distro=$(detect_distro)
    pm=$(get_package_manager "$distro")
    install_cmd=$(get_install_cmd "$pm")

    if [[ -z "$install_cmd" ]]; then
        log "ERROR" "Unsupported package manager: $pm"
        return 1
    fi

    if command -v fish &>/dev/null; then
        log "INFO" "fish is already installed: $(fish --version 2>&1)"
        return 0
    fi

    log "INFO" "Installing fish shell..."
    run "$install_cmd fish"
    log "INFO" "fish shell installed"
}

set_fish_default_shell() {
    local fish_path
    fish_path=$(command -v fish 2>/dev/null || true)

    if [[ -z "$fish_path" ]]; then
        log "ERROR" "fish not found in PATH; install it first"
        return 1
    fi

    # Add fish to /etc/shells if not already listed
    if ! grep -qx "$fish_path" /etc/shells; then
        log "INFO" "Adding $fish_path to /etc/shells"
        run "echo '$fish_path' | sudo tee -a /etc/shells > /dev/null"
    fi

    local current_shell
    current_shell=$(getent passwd "$USER" | cut -d: -f7)

    if [[ "$current_shell" == "$fish_path" ]]; then
        log "INFO" "fish is already the default shell for $USER"
        return 0
    fi

    log "INFO" "Setting fish as the default shell for $USER"
    run "chsh -s '$fish_path' '$USER'"
    log "INFO" "Default shell changed to fish (restart session to take effect)"
}

install_fish_config() {
    local source_dir="${1:-$FISH_CONFIG_SOURCE}"
    local target_dir="${2:-$FISH_CONFIG_TARGET}"

    if [[ ! -d "$source_dir" ]]; then
        log "ERROR" "Fish config source not found: $source_dir"
        return 1
    fi

    if [[ -d "$target_dir" ]]; then
        local backup="${target_dir}.backup.$(date +%Y%m%d_%H%M%S)"
        log "INFO" "Backing up existing fish config to: $backup"
        run "mv '$target_dir' '$backup'"
    fi

    log "INFO" "Installing fish configuration to: $target_dir"
    run "mkdir -p '$(dirname "$target_dir")'"
    run "cp -r '$source_dir' '$target_dir'"
    log "INFO" "Fish configuration installed"
}

setup_fish() {
    install_fish
    set_fish_default_shell
    install_fish_config
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "${1:-}" in
        --install)
            install_fish
            ;;
        --default)
            set_fish_default_shell
            ;;
        --config)
            install_fish_config "${2:-}" "${3:-}"
            ;;
        --setup)
            setup_fish
            ;;
        *)
            echo "Usage: $0 {--install|--default|--config [src] [dst]|--setup}"
            ;;
    esac
fi
