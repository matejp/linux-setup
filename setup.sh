#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="${SCRIPT_DIR}/lib"

DRY_RUN=false
VERBOSE=false
ECHO_COMMANDS=false
LOG_FILE=""
INSTALL_BASE=false
INSTALL_DEV=false
INSTALL_NVIM=false
INSTALL_FONT=false
INSTALL_DESKTOP=false
INSTALL_FISH=false
INSTALL_BASH=false
FORCE_DISTRO=""

usage() {
    cat <<USAGE_EOF
Linux Setup - Modular system configuration for fresh installations

Usage: $(basename "$0") [OPTIONS]

OPTIONS:
    -h, --help              Show this help message
    -d, --distro DISTRO     Force specific distribution (auto-detected)
    -p, --pkgs              Install base packages only
    -e, --dev LANG          Install dev tools for language (go, c, python)
    -n, --nvim              Install Neovim configuration
    -f, --font              Install JetBrains Mono Nerd Font
    -k, --desktop           Apply desktop settings (GNOME)
    -s, --fish              Install fish shell, set as default, and deploy config
    -b, --bash              Deploy bash configuration (~/.bashrc and ~/.bash_profile)
    -a, --all               Install everything
    -v, --verbose           Enable verbose output
    -t, --dry-run           Show what would be done without executing
    -x, --echo              Echo all commands before executing
    -l, --log FILE          Log all commands to FILE
    --detect                Detect and show distribution info

EXAMPLES:
    $(basename "$0") --all                  Full setup
    $(basename "$0") --pkgs                 Install base packages only
    $(basename "$0") --dev go python        Install Go and Python dev tools
    $(basename "$0") --nvim                 Install Neovim configuration
    $(basename "$0") --font                 Install JetBrains Mono Nerd Font
    $(basename "$0") --all --echo           Full setup with command echo
    $(basename "$0") --all --log setup.log  Log commands to file

SUPPORTED DISTRIBUTIONS:
    Ubuntu, Debian, Pop!_OS, Linux Mint (apt)
    Fedora, RHEL, CentOS, Rocky, Alma (dnf)
    OpenSUSE, OpenSUSE Tumbleweed (zypper)
    Arch, Manjaro, EndeavourOS (pacman)

USAGE_EOF
}

log_info() {
    echo "[INFO] $*"
    if [[ -n "$LOG_FILE" ]]; then
        echo "[INFO] $*" >> "$LOG_FILE"
    fi
}

log_warn() {
    echo "[WARN] $*" >&2
    if [[ -n "$LOG_FILE" ]]; then
        echo "[WARN] $*" >> "$LOG_FILE"
    fi
}

log_error() {
    echo "[ERROR] $*" >&2
    if [[ -n "$LOG_FILE" ]]; then
        echo "[ERROR] $*" >> "$LOG_FILE"
    fi
}

log_success() {
    echo "[SUCCESS] $*"
    if [[ -n "$LOG_FILE" ]]; then
        echo "[SUCCESS] $*" >> "$LOG_FILE"
    fi
}

log_cmd() {
    local cmd="$*"
    if [[ "$ECHO_COMMANDS" == true ]]; then
        echo "[CMD] $cmd"
    fi
    if [[ -n "$LOG_FILE" ]]; then
        echo "$cmd" >> "$LOG_FILE"
    fi
}

run() {
    local cmd="$*"
    log_cmd "$cmd"
    if [[ "$DRY_RUN" == false ]]; then
        eval "$cmd"
    fi
}

load_library() {
    local lib_name="$1"
    local lib_path="${LIB_DIR}/${lib_name}.sh"

    if [[ ! -f "$lib_path" ]]; then
        log_error "Library not found: $lib_path"
        return 1
    fi

    source "$lib_path"
    log_info "Loaded library: $lib_name"
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                usage
                exit 0
                ;;
            -d|--distro)
                FORCE_DISTRO="$2"
                shift 2
                ;;
            -p|--pkgs)
                INSTALL_BASE=true
                shift
                ;;
            -e|--dev)
                INSTALL_DEV=true
                DEV_LANGS+=("$2")
                shift 2
                ;;
            -n|--nvim)
                INSTALL_NVIM=true
                shift
                ;;
            -f|--font)
                INSTALL_FONT=true
                shift
                ;;
            -k|--desktop)
                INSTALL_DESKTOP=true
                shift
                ;;
            -s|--fish)
                INSTALL_FISH=true
                shift
                ;;
            -b|--bash)
                INSTALL_BASH=true
                shift
                ;;
            -a|--all)
                INSTALL_BASE=true
                INSTALL_DEV=true
                INSTALL_NVIM=true
                INSTALL_FONT=true
                INSTALL_DESKTOP=true
                INSTALL_FISH=true
                INSTALL_BASH=true
                shift
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -t|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -x|--echo)
                ECHO_COMMANDS=true
                shift
                ;;
            -l|--log)
                LOG_FILE="$2"
                shift 2
                ;;
            --detect)
                load_library "distro"
                echo "Distribution: $(detect_distro)"
                echo "Package Manager: $(get_package_manager "$(detect_distro)")"
                exit 0
                ;;
            --*)
                log_error "Unknown option: $1"
                usage
                exit 1
                ;;
            *)
                log_error "Unknown argument: $1"
                usage
                exit 1
                ;;
        esac
    done
}

main() {
    local distro pm

    if [[ -n "$LOG_FILE" ]]; then
        mkdir -p "$(dirname "$LOG_FILE")"
        echo "=== Linux Setup Log - $(date) ===" > "$LOG_FILE"
        log_info "Logging to: $LOG_FILE"
    fi

    export ECHO_COMMANDS LOG_FILE DRY_RUN

    log_info "Starting Linux Setup..."

    load_library "distro"

    if [[ -n "$FORCE_DISTRO" ]]; then
        distro="$FORCE_DISTRO"
        pm=$(get_package_manager "$distro")
        log_info "Using forced distribution: $distro ($pm)"
    else
        distro=$(detect_distro)
        pm=$(get_package_manager "$distro")
        log_info "Detected distribution: $distro"
        log_info "Using package manager: $pm"
    fi

    if [[ "$pm" == "unknown" ]]; then
        log_error "Unsupported distribution: $distro"
        log_info "Supported: Ubuntu/Debian (apt), Fedora/RHEL (dnf), OpenSUSE (zypper), Arch (pacman)"
        exit 1
    fi

    if [[ "$DRY_RUN" == true ]]; then
        log_warn "DRY RUN MODE - No changes will be made"
    fi

    if [[ "$INSTALL_BASE" == true ]] || [[ "$INSTALL_DEV" == true ]]; then
        load_library "packages"
    fi

    if [[ "$INSTALL_BASE" == true ]]; then
        log_info "Installing base packages..."
        install_base "$distro" "$pm"
        log_success "Base packages installed"
    fi

    if [[ "$INSTALL_DEV" == true ]]; then
        local dev_langs=("${DEV_LANGS[@]:-go c python}")
        log_info "Installing development tools for: ${dev_langs[*]}"
        install_dev_tools "$distro" "$pm" "${dev_langs[@]}"
        log_success "Development tools installed"
    fi

    if [[ "$INSTALL_FONT" == true ]]; then
        load_library "fonts"
        log_info "Installing JetBrains Mono Nerd Font..."
        install_jetbrains_nerd_font
        log_success "JetBrains Mono Nerd Font installed"
    fi

    if [[ "$INSTALL_NVIM" == true ]]; then
        load_library "nvim"
        log_info "Installing Neovim configuration..."
        install_nvim_config
        install_nvim_dependencies
        log_success "Neovim configuration installed"
    fi

    if [[ "$INSTALL_DESKTOP" == true ]]; then
        load_library "desktop"
        log_info "Applying desktop settings..."
        install_gnome_settings
        log_success "Desktop settings applied"
    fi

    if [[ "$INSTALL_FISH" == true ]]; then
        load_library "fish"
        log_info "Setting up fish shell..."
        setup_fish
        log_success "Fish shell setup complete"
    fi

    if [[ "$INSTALL_BASH" == true ]]; then
        load_library "bash"
        log_info "Deploying bash configuration..."
        setup_bash
        log_success "Bash configuration deployed"
    fi

    log_success "Setup complete!"
}

declare -a DEV_LANGS=()
parse_args "$@"
main
