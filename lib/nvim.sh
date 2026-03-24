#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_SOURCE="${SCRIPT_DIR}/../config/nvim"
CONFIG_TARGET="${HOME}/.config/nvim"

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

install_nvim_config() {
    local source_dir="${1:-$CONFIG_SOURCE}"
    local target_dir="${2:-$CONFIG_TARGET}"
    local backup=""

    if [[ -d "$target_dir" ]]; then
        backup="${target_dir}.backup.$(date +%Y%m%d_%H%M%S)"
        log "INFO" "Backing up existing config to: $backup"
        run "mv '$target_dir' '$backup'"
    fi

    log "INFO" "Installing Neovim configuration from: $source_dir"
    run "mkdir -p '$(dirname "$target_dir")'"
    run "cp -r '$source_dir' '$target_dir'"

    log "INFO" "Neovim configuration installed to: $target_dir"
}

remove_nvim_config() {
    local target_dir="${1:-$CONFIG_TARGET}"

    if [[ -d "$target_dir" ]]; then
        run "rm -rf '$target_dir'"
        log "INFO" "Removed Neovim configuration from: $target_dir"
    else
        log "INFO" "No Neovim configuration found at: $target_dir"
    fi
}

verify_nvim_config() {
    local target_dir="${1:-$CONFIG_TARGET}"
    local errors=0

    echo "Verifying Neovim configuration..."

    if [[ ! -d "$target_dir" ]]; then
        echo "ERROR: Config directory not found: $target_dir"
        return 1
    fi

    if [[ ! -f "$target_dir/init.lua" ]]; then
        echo "ERROR: init.lua not found"
        ((errors++))
    fi

    if [[ $errors -eq 0 ]]; then
        echo "Verification passed!"
        return 0
    else
        echo "Verification failed with $errors error(s)"
        return 1
    fi
}

install_nvim_dependencies() {
    echo "Checking Neovim installation..."
    if ! command -v nvim &>/dev/null; then
        echo "Neovim not found. Please install it first."
        return 1
    fi

    local nvim_version
    nvim_version=$(nvim --version | head -n1)
    echo "Found: $nvim_version"
    echo "This is a No Plugins configuration - no additional dependencies needed."
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "${1:-}" in
        --install)
            install_nvim_config "${2:-}" "${3:-}"
            ;;
        --remove)
            remove_nvim_config "${2:-}"
            ;;
        --verify)
            verify_nvim_config "${2:-}"
            ;;
        --deps)
            install_nvim_dependencies
            ;;
        *)
            echo "Usage: $0 {--install [--source DIR] [--target DIR]|--remove|--verify|--deps}"
            ;;
    esac
fi
