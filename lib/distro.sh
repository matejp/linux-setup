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

run() {
    local cmd="$*"
    log "CMD" "$cmd"
    if [[ "${DRY_RUN:-false}" == "false" ]]; then
        eval "$cmd"
    fi
}

detect_distro() {
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        echo "$ID"
    elif [[ -f /etc/SuSE-release ]]; then
        echo "opensuse"
    elif [[ -f /etc/redhat-release ]]; then
        if grep -q "Red Hat" /etc/redhat-release; then
            echo "rhel"
        else
            echo "fedora"
        fi
    elif [[ -f /etc/arch-release ]]; then
        echo "arch"
    else
        echo "unknown"
    fi
}

get_package_manager() {
    local distro="$1"
    case "$distro" in
        ubuntu|debian|pop|linuxmint)
            echo "apt"
            ;;
        fedora|rhel|centos|rocky|alma)
            echo "dnf"
            ;;
        opensuse|opensuse-tumbleweed|opensuse-leap|suse)
            echo "zypper"
            ;;
        arch|manjaro|endeavouros)
            echo "pacman"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

get_update_cmd() {
    local pm="$1"
    case "$pm" in
        apt)
            echo "sudo apt update"
            ;;
        dnf)
            echo "sudo dnf check-update"
            ;;
        zypper)
            echo "sudo zypper refresh"
            ;;
        pacman)
            echo "sudo pacman -Sy"
            ;;
        *)
            echo ""
            ;;
    esac
}

get_install_cmd() {
    local pm="$1"
    case "$pm" in
        apt)
            echo "sudo apt install -y"
            ;;
        dnf)
            echo "sudo dnf install -y"
            ;;
        zypper)
            echo "sudo zypper install -y"
            ;;
        pacman)
            echo "sudo pacman -S --noconfirm"
            ;;
        *)
            echo ""
            ;;
    esac
}

install_packages() {
    local packages=("$@")
    local distro
    local pm
    local install_cmd

    distro=$(detect_distro)
    pm=$(get_package_manager "$distro")

    if [[ "$pm" == "unknown" ]]; then
        log "ERROR" "Unsupported distribution: $distro"
        return 1
    fi

    log "INFO" "Detected distribution: $distro"
    log "INFO" "Using package manager: $pm"

    install_cmd=$(get_install_cmd "$pm")

    if [[ -n "$install_cmd" ]]; then
        log "INFO" "Installing packages: ${packages[*]}"
        run "$install_cmd ${packages[*]}"
    else
        log "ERROR" "No install command found for $pm"
        return 1
    fi
}

install_packages_array() {
    local distro
    local pm
    local install_cmd
    local -a packages

    distro=$(detect_distro)
    pm=$(get_package_manager "$distro")

    if [[ "$pm" == "unknown" ]]; then
        echo "Error: Unsupported distribution: $distro" >&2
        return 1
    fi

    echo "Detected distribution: $distro"
    echo "Using package manager: $pm"

    install_cmd=$(get_install_cmd "$pm")

    if [[ -n "$install_cmd" ]]; then
        while IFS= read -r package; do
            [[ -n "$package" ]] && packages+=("$package")
        done
        echo "Installing packages: ${packages[*]}"
        eval "$install_cmd ${packages[*]}"
    else
        echo "Error: No install command found for $pm" >&2
        return 1
    fi
}

get_distro_info() {
    local distro
    local pm
    local update_cmd
    local install_cmd

    distro=$(detect_distro)
    pm=$(get_package_manager "$distro")
    update_cmd=$(get_update_cmd "$pm")
    install_cmd=$(get_install_cmd "$pm")

    cat <<EOF
{
    "distro": "$distro",
    "package_manager": "$pm",
    "update_command": "$update_cmd",
    "install_command": "$install_cmd"
}
EOF
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "${1:-}" in
        --info)
            get_distro_info
            ;;
        --detect)
            detect_distro
            ;;
        --pm)
            detect_distro | xargs -I{} get_package_manager {}
            ;;
        *)
            echo "Usage: $0 {--info|--detect|--pm}"
            echo "  --info   Show full distribution info as JSON"
            echo "  --detect Show detected distribution ID"
            echo "  --pm     Show package manager for detected distribution"
            ;;
    esac
fi
