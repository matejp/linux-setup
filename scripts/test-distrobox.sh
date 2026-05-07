#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

info()    { echo -e "${BLUE}[INFO]${NC}    $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}    $*"; }
error()   { echo -e "${RED}[ERROR]${NC}   $*"; }
ok()      { echo -e "${GREEN}[OK]${NC}      $*"; }
section() { echo -e "\n${CYAN}=== $* ===${NC}"; }

# Test results tracking
TESTS_PASSED=0
TESTS_FAILED=0
FAILED_DISTROS=()

# Container image mapping: distro-version -> image
declare -A IMAGES=(
    ["ubuntu-24.04"]="quay.io/toolbx/ubuntu-toolbox:24.04"
    ["debian-12"]="docker.io/library/debian:12"
    ["fedora-44"]="quay.io/fedora/fedora-toolbox:44"
    ["arch-latest"]="docker.io/library/archlinux:latest"
    ["opensuse-tumbleweed"]="registry.opensuse.org/opensuse/tumbleweed:latest"
)

# Package install commands per distro family
declare -A PKG_INSTALL=(
    ["ubuntu"]="sudo apt update && sudo apt install -y ansible-core"
    ["debian"]="sudo apt update && sudo apt install -y ansible-core"
    ["fedora"]="sudo dnf install -y ansible-core"
    ["arch"]="sudo pacman -Sy --noconfirm ansible-core"
    ["opensuse"]="sudo zypper install -y ansible-core"
)

# Packages/paths to verify after ansible run
# Format: "type:value" where type is: command, file, dir
VERIFY_ITEMS=(
    "command:git"
    "command:curl"
    "command:htop"
    "command:jq"
    "command:eza"
    "command:bat"
    "command:rg"
    "command:fzf"
    "command:zoxide"
    "command:btop"
    "command:duf"
    "command:fish"
    "command:podman"
    "command:distrobox"
    "command:nvim"
    "file:~/.config/nvim/init.lua"
    "file:~/.bashrc"
    "file:~/.bash_profile"
    "file:~/.config/fish/config.fish"
    "dir:~/.local/share/fonts"
)

usage() {
    cat <<EOF
Usage: $(basename "$0") [--distro <name>] [--keep] [--help]

Run integration tests using distrobox to validate ansible setup on all
supported distributions.

Options:
  --distro <name>  Test only this distro (ubuntu, debian, fedora, arch, opensuse)
  --keep           Keep containers after tests (for debugging)
  --help           Show this help message

Examples:
  $(basename "$0")              # Test all distros, clean up after
  $(basename "$0") --distro ubuntu  # Test only Ubuntu
  $(basename "$0") --keep           # Keep containers after tests
EOF
    exit 0
}

# Parse arguments
KEEP_CONTAINERS=false
FILTER_DISTRO=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --distro)
            FILTER_DISTRO="$2"
            shift 2
            ;;
        --keep)
            KEEP_CONTAINERS=true
            shift
            ;;
        --help|-h)
            usage
            ;;
        *)
            error "Unknown option: $1"
            usage
            ;;
    esac
done

# Check prerequisites
section "Checking prerequisites"

if ! command -v podman &>/dev/null; then
    error "podman not found. Install it first."
    exit 1
fi

if ! command -v distrobox &>/dev/null; then
    error "distrobox not found. Install it first."
    exit 1
fi

ok "podman found"
ok "distrobox found"

# Build list of distros to test
declare -a DISTROS_TO_TEST=()

for key in "${!IMAGES[@]}"; do
    distro="${key%%-*}"
    if [[ -n "$FILTER_DISTRO" && "$distro" != "$FILTER_DISTRO" ]]; then
        continue
    fi
    DISTROS_TO_TEST+=("$key")
done

if [[ ${#DISTROS_TO_TEST[@]} -eq 0 ]]; then
    error "No distros to test. Check --distro value."
    exit 1
fi

section "Testing ${#DISTROS_TO_TEST[@]} distribution(s)"
for d in "${DISTROS_TO_TEST[@]}"; do
    echo -e "  ${BLUE}•${NC} $d"
done
echo ""

# Cleanup function
cleanup_container() {
    local name="$1"
    if [[ "$KEEP_CONTAINERS" == "true" ]]; then
        warn "Keeping container: $name"
        return
    fi
    info "Cleaning up container: $name"
    distrobox stop "$name" 2>/dev/null || true
    distrobox rm -f "$name" 2>/dev/null || true
    local home_path
    home_path="$(distrobox inspect "$name" --home 2>/dev/null || echo "")"
    if [[ -n "$home_path" && -d "$home_path" ]]; then
        rm -rf "$home_path"
    fi
}

# Run verification inside container
run_verification() {
    local container_name="$1"
    local distro="$2"
    local failed=0

    for item in "${VERIFY_ITEMS[@]}"; do
        local type="${item%%:*}"
        local value="${item#*:}"

        case "$type" in
            command)
                if distrobox enter "$container_name" -- bash -c "command -v $value &>/dev/null" 2>/dev/null; then
                    ok "$distro | command: $value"
                    ((TESTS_PASSED++)) || true
                else
                    error "$distro | command: $value (not found)"
                    ((TESTS_FAILED++)) || true
                    failed=1
                fi
                ;;
            file)
                if distrobox enter "$container_name" -- bash -c "[[ -f $value ]]" 2>/dev/null; then
                    ok "$distro | file: $value"
                    ((TESTS_PASSED++)) || true
                else
                    error "$distro | file: $value (not found)"
                    ((TESTS_FAILED++)) || true
                    failed=1
                fi
                ;;
            dir)
                if distrobox enter "$container_name" -- bash -c "[[ -d $value ]]" 2>/dev/null; then
                    ok "$distro | dir: $value"
                    ((TESTS_PASSED++)) || true
                else
                    error "$distro | dir: $value (not found)"
                    ((TESTS_FAILED++)) || true
                    failed=1
                fi
                ;;
        esac
    done

    return $failed
}

# Test each distro
for distro_version in "${DISTROS_TO_TEST[@]}"; do
    distro="${distro_version%%-*}"
    version="${distro_version#*-}"
    container_name="test-${distro}-${version//./}"
    image="${IMAGES[$distro_version]}"
    home_path="${HOME}/.distrobox-test/${container_name}"
    repo_path_host="$REPO_ROOT"

    section "Testing: $distro_version"
    info "Container: $container_name"
    info "Image: $image"

    # Skip if container already exists
    if distrobox list 2>/dev/null | grep -q "$container_name"; then
        warn "Container '$container_name' already exists, skipping"
        continue
    fi

    # Create container
    info "Creating container..."
    mkdir -p "$home_path"
    if ! distrobox create \
        --name "$container_name" \
        --image "$image" \
        --home "$home_path" \
        --yes; then
        error "Failed to create container for $distro_version"
        FAILED_DISTROS+=("$distro_version")
        ((TESTS_FAILED++)) || true
        cleanup_container "$container_name"
        continue
    fi
    ok "Container created"

    # Install ansible and run playbook
    info "Installing ansible-core and running playbook..."
    local_ansible_cmd="
        set -e
        ${PKG_INSTALL[$distro]}
        cd /run/host${repo_path_host}/ansible
        ansible-playbook playbooks/site.yml --tags all
    "

    if ! distrobox enter "$container_name" -- bash -c "$local_ansible_cmd"; then
        error "Ansible playbook failed on $distro_version"
        FAILED_DISTROS+=("$distro_version")
        ((TESTS_FAILED++)) || true
        cleanup_container "$container_name"
        continue
    fi
    ok "Ansible playbook completed"

    # Run verification
    info "Verifying installation..."
    if run_verification "$container_name" "$distro_version"; then
        ok "All checks passed for $distro_version"
    else
        error "Some checks failed for $distro_version"
        FAILED_DISTROS+=("$distro_version")
    fi

    # Cleanup
    cleanup_container "$container_name"
    echo ""
done

# Summary
section "Test Summary"
echo -e "  ${GREEN}Passed:${NC} $TESTS_PASSED"
echo -e "  ${RED}Failed:${NC} $TESTS_FAILED"

if [[ ${#FAILED_DISTROS[@]} -gt 0 ]]; then
    echo ""
    echo -e "  ${RED}Failed distributions:${NC}"
    for d in "${FAILED_DISTROS[@]}"; do
        echo -e "    ${RED}✗${NC} $d"
    done
    echo ""
    error "Some tests failed!"
    exit 1
fi

echo ""
ok "All tests passed!"
