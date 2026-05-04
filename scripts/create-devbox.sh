#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()  { echo -e "${BLUE}[INFO]${NC}  $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; }
ok()    { echo -e "${GREEN}[OK]${NC}    $*"; }

# Container image mapping: distro-version -> image
declare -A IMAGES=(
    ["ubuntu-22.04"]="quay.io/toolbx/ubuntu-toolbox:22.04"
    ["ubuntu-24.04"]="quay.io/toolbx/ubuntu-toolbox:24.04"
    ["ubuntu-latest"]="quay.io/toolbx/ubuntu-toolbox:latest"
    ["debian-12"]="docker.io/library/debian:12"
    ["debian-testing"]="docker.io/library/debian:testing"
    ["debian-unstable"]="docker.io/library/debian:unstable"
    ["fedora-41"]="quay.io/fedora/fedora-toolbox:41"
    ["fedora-42"]="quay.io/fedora/fedora-toolbox:42"
    ["fedora-rawhide"]="quay.io/fedora/fedora-toolbox:rawhide"
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

usage() {
    cat <<EOF
Usage: $(basename "$0") <distro> <version> <home-path> [--prefix <prefix>]

Create a distrobox development environment with all tools pre-installed.

Arguments:
  distro        Distribution name (ubuntu, debian, fedora, arch, opensuse)
  version       Distribution version (see supported list below)
  home-path     Path for the container's isolated home directory

Options:
  --prefix      Container name prefix (default: devbox)
                Container name will be: <prefix>-<distro>-<version>

Supported distributions:
  ubuntu        22.04, 24.04, latest
  debian        12, testing, unstable
  fedora        41, 42, rawhide
  arch          latest
  opensuse      tumbleweed

Examples:
  $(basename "$0") ubuntu 24.04 ~/devbox-ubuntu
  $(basename "$0") fedora 42 ~/devbox-fedora --prefix work
  $(basename "$0") arch latest ~/devbox-arch --prefix test1

After creation, enter the container with:
  distrobox enter <container-name>
EOF
    exit 1
}

# Parse arguments
PREFIX="devbox"
POSITIONAL=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        --prefix)
            PREFIX="$2"
            shift 2
            ;;
        --help|-h)
            usage
            ;;
        *)
            POSITIONAL+=("$1")
            shift
            ;;
    esac
done

if [[ ${#POSITIONAL[@]} -ne 3 ]]; then
    error "Expected 3 arguments: <distro> <version> <home-path>"
    usage
fi

DISTRO="${POSITIONAL[0]}"
VERSION="${POSITIONAL[1]}"
HOME_PATH="${POSITIONAL[2]}"

# Normalize inputs
DISTRO="$(echo "$DISTRO" | tr '[:upper:]' '[:lower:]')"
VERSION="$(echo "$VERSION" | tr '[:upper:]' '[:lower:]')"

# Validate distro
if [[ ! "${!PKG_INSTALL[*]}" =~ $DISTRO ]]; then
    error "Unsupported distribution: $DISTRO"
    echo "Supported: ${!PKG_INSTALL[*]}"
    exit 1
fi

# Resolve image
IMAGE_KEY="${DISTRO}-${VERSION}"
IMAGE="${IMAGES[$IMAGE_KEY]:-}"

if [[ -z "$IMAGE" ]]; then
    error "Unsupported version: $VERSION for $DISTRO"
    echo "Supported versions for $DISTRO:"
    for key in "${!IMAGES[@]}"; do
        if [[ "$key" == "${DISTRO}-"* ]]; then
            echo "  ${key#"${DISTRO}"-}"
        fi
    done
    exit 1
fi

# Generate container name
CONTAINER_NAME="${PREFIX}-${DISTRO}-${VERSION//./}"

# Validate home path
if [[ -z "$HOME_PATH" ]]; then
    error "Home path cannot be empty"
    exit 1
fi

# Check prerequisites
info "Checking prerequisites..."

if ! command -v podman &>/dev/null; then
    error "podman not found. Install it first: ansible-playbook playbooks/site.yml --tags base"
    exit 1
fi

if ! command -v distrobox &>/dev/null; then
    error "distrobox not found. Install it first: ansible-playbook playbooks/site.yml --tags base"
    exit 1
fi

ok "podman found"
ok "distrobox found"

# Check if container already exists
if distrobox list 2>/dev/null | grep -q "$CONTAINER_NAME"; then
    error "Container '$CONTAINER_NAME' already exists"
    echo "Remove it first: distrobox rm $CONTAINER_NAME"
    exit 1
fi

# Create home directory
info "Creating home directory: $HOME_PATH"
mkdir -p "$HOME_PATH"

# Create container
info "Creating container: $CONTAINER_NAME"
info "Image: $IMAGE"
info "Home: $HOME_PATH"

distrobox create \
    --name "$CONTAINER_NAME" \
    --image "$IMAGE" \
    --home "$HOME_PATH" \
    --yes

ok "Container created"

# Build the setup command to run inside the container
REPO_PATH_HOST="$REPO_ROOT"
ANSIBLE_CMD="
    set -e
    echo '--- Installing ansible-core ---'
    ${PKG_INSTALL[$DISTRO]}
    echo '--- Running ansible playbook ---'
    cd /run/host${REPO_PATH_HOST}/ansible
    ansible-playbook playbooks/site.yml --tags all
    echo '--- Setup complete ---'
"

info "Installing tools and running ansible playbook inside container..."
info "This may take a while depending on your network speed..."

distrobox enter "$CONTAINER_NAME" -- bash -c "$ANSIBLE_CMD"

echo ""
ok "Devbox setup complete!"
echo ""
echo -e "${GREEN}Container:${NC} $CONTAINER_NAME"
echo -e "${GREEN}Image:${NC}     $IMAGE"
echo -e "${GREEN}Home:${NC}      $HOME_PATH"
echo -e "${GREEN}Repo:${NC}      /run/host${REPO_PATH_HOST}/ansible"
echo ""
echo "Enter the container:"
echo "  distrobox enter $CONTAINER_NAME"
echo ""
echo "Remove the container:"
echo "  distrobox stop $CONTAINER_NAME"
echo "  distrobox rm $CONTAINER_NAME"
echo "  rm -rf $HOME_PATH"
