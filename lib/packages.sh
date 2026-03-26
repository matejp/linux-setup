#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

BASE_PACKAGES=(
    htop
    git
    neovim
    curl
    wget
)

declare -gA DISTRO_PACKAGES
DISTRO_PACKAGES[apt]="htop git neovim curl wget eza fd-find bat ripgrep jq btop duf zoxide fzf tldr httpie trash-cli lazygit fish"
DISTRO_PACKAGES[dnf]="htop git neovim curl wget eza ripgrep jq btop duf zoxide fzf tldr lazygit fish"
DISTRO_PACKAGES[zypper]="htop git neovim curl wget ripgrep bat jq btop duf zoxide fzf lazygit fish"
DISTRO_PACKAGES[pacman]="htop git neovim curl wget eza fd bat ripgrep jq btop duf zoxide fzf tldr httpie trash-cli lazygit fish"

declare -gA DEV_PACKAGES_APT
DEV_PACKAGES_APT[go]="golang golang-go"
DEV_PACKAGES_APT[c]="build-essential gdb lldb"
DEV_PACKAGES_APT[python]="python3 python3-pip python3-venv"

declare -gA DEV_PACKAGES_DNF
DEV_PACKAGES_DNF[go]="golang"
DEV_PACKAGES_DNF[c]="gcc gcc-gdb lldb"
DEV_PACKAGES_DNF[python]="python3 python3-pip python3-venv"

declare -gA DEV_PACKAGES_ZYPPER
DEV_PACKAGES_ZYPPER[go]="go golang"
DEV_PACKAGES_ZYPPER[c]="patterns-devel-base-devel_basis gcc-debugger"
DEV_PACKAGES_ZYPPER[python]="python3 python3-pip python3-venv"

declare -gA DEV_PACKAGES_PACMAN
DEV_PACKAGES_PACMAN[go]="go"
DEV_PACKAGES_PACMAN[c]="base-devel gdb lldb"
DEV_PACKAGES_PACMAN[python]="python python-pip python-virtualenv"

get_distro_packages() {
    local distro="$1"
    local pm="${2:-}"

    if [[ -z "${pm:-}" ]]; then
        source "${SCRIPT_DIR}/distro.sh"
        pm=$(get_package_manager "$distro")
    fi

    echo "${DISTRO_PACKAGES[$pm]:-}"
}

get_dev_packages() {
    local distro="$1"
    local lang="$2"
    local pm="${3:-}"

    if [[ -z "$pm" ]]; then
        source "${SCRIPT_DIR}/distro.sh"
        pm=$(get_package_manager "$distro")
    fi

    local var_name="DEV_PACKAGES_${pm^^}[$lang]"
    echo "${!var_name:-}"
}

filter_packages_for_distro() {
    local distro="$1"
    local packages="$2"

    if [[ "$distro" == "ubuntu" ]]; then
        # Source distro.sh only if functions not already loaded
        if ! declare -f detect_ubuntu_version > /dev/null 2>&1 \
            || ! declare -f get_ubuntu_major_version > /dev/null 2>&1; then
            source "${SCRIPT_DIR}/distro.sh"
        fi
        local version major
        version=$(detect_ubuntu_version)
        major=$(get_ubuntu_major_version "${version}")

        if [[ "${major:-0}" -lt 26 ]]; then
            log "INFO" "Ubuntu ${version} detected: skipping lazygit (requires 26.04+)"
            packages="${packages//lazygit/}"
        fi
    fi

    # Normalise extra whitespace left by removals
    echo "${packages}" | tr -s ' '
}

install_base() {
    local distro="${1:-}"
    local pm="${2:-}"

    if [[ -z "$distro" ]] || [[ -z "$pm" ]]; then
        source "${SCRIPT_DIR}/distro.sh"
        distro="${distro:-$(detect_distro)}"
        pm="${pm:-$(get_package_manager "$distro")}"
    fi

    local packages
    packages=$(get_distro_packages "$distro" "$pm")
    packages=$(filter_packages_for_distro "$distro" "$packages")

    if [[ -z "$packages" ]]; then
        log "ERROR" "No packages defined for $distro ($pm)"
        return 1
    fi

    log "INFO" "Installing base packages for $distro..."
    source "${SCRIPT_DIR}/distro.sh"
    install_packages $packages
}

install_dev_tools() {
    local distro="${1:-}"
    local pm="${2:-}"
    shift 2
    local languages=("$@")

    if [[ -z "$distro" ]] || [[ -z "$pm" ]]; then
        source "${SCRIPT_DIR}/distro.sh"
        distro="${distro:-$(detect_distro)}"
        pm="${pm:-$(get_package_manager "$distro")}"
    fi

    if [[ ${#languages[@]} -eq 0 ]]; then
        languages=(go c python)
    fi

    local all_packages=()

    for lang in "${languages[@]}"; do
        local packages
        packages=$(get_dev_packages "$distro" "$lang" "$pm")
        if [[ -n "$packages" ]]; then
            read -ra pkg_array <<< "$packages"
            all_packages+=("${pkg_array[@]}")
        fi
    done

    if [[ ${#all_packages[@]} -gt 0 ]]; then
        log "INFO" "Installing development packages for: ${languages[*]}"
        source "${SCRIPT_DIR}/distro.sh"
        install_packages "${all_packages[@]}"
    fi
}

list_packages() {
    echo "Base packages:"
    for pm in apt dnf zypper pacman; do
        echo "  $pm: ${DISTRO_PACKAGES[$pm]:-}"
    done

    echo ""
    echo "Development packages:"
    for lang in go c python; do
        echo "  $lang:"
        for pm in apt dnf zypper pacman; do
            local var_name="DEV_PACKAGES_${pm^^}[$lang]"
            echo "    $pm: ${!var_name:-}"
        done
    done
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "${1:-}" in
        --list)
            list_packages
            ;;
        --base)
            source "${SCRIPT_DIR}/distro.sh"
            install_base
            ;;
        --dev)
            source "${SCRIPT_DIR}/distro.sh"
            install_dev_tools "${2:-}" "${3:-}" "${@:4}"
            ;;
        *)
            echo "Usage: $0 {--list|--base|--dev [distro] [pm] [languages...]}"
            ;;
    esac
fi
