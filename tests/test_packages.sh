#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

source "${PROJECT_DIR}/lib/packages.sh"

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

TESTS_PASSED=0
TESTS_FAILED=0
TESTS_RUN=0

log_test() {
    local name="$1"
    ((TESTS_RUN++)) || true
    echo -n "Testing: $name ... "
}

log_pass() {
    echo -e "${GREEN}PASS${NC}"
    ((TESTS_PASSED++)) || true
}

log_fail() {
    echo -e "${RED}FAIL${NC} $1"
    ((TESTS_FAILED++)) || true
}

test_get_distro_packages() {
    log_test "get_distro_packages for apt"
    result=$(get_distro_packages "ubuntu" "apt")
    [[ "$result" == "htop git neovim curl wget" ]] && log_pass || log_fail "got: $result"

    log_test "get_distro_packages for dnf"
    result=$(get_distro_packages "fedora" "dnf")
    [[ "$result" == "htop git neovim curl wget" ]] && log_pass || log_fail "got: $result"

    log_test "get_distro_packages for zypper"
    result=$(get_distro_packages "opensuse" "zypper")
    [[ "$result" == "htop git neovim curl wget" ]] && log_pass || log_fail "got: $result"

    log_test "get_distro_packages for pacman"
    result=$(get_distro_packages "arch" "pacman")
    [[ "$result" == "htop git neovim curl wget" ]] && log_pass || log_fail "got: $result"
}

test_get_dev_packages() {
    log_test "get_dev_packages for go/apt"
    result=$(get_dev_packages "ubuntu" "go" "apt")
    [[ "$result" == "golang golang-go" ]] && log_pass || log_fail "got: $result"

    log_test "get_dev_packages for c/apt"
    result=$(get_dev_packages "ubuntu" "c" "apt")
    [[ "$result" == "build-essential gdb lldb" ]] && log_pass || log_fail "got: $result"

    log_test "get_dev_packages for python/apt"
    result=$(get_dev_packages "ubuntu" "python" "apt")
    [[ "$result" == "python3 python3-pip python3-venv" ]] && log_pass || log_fail "got: $result"

    log_test "get_dev_packages for go/dnf"
    result=$(get_dev_packages "fedora" "go" "dnf")
    [[ "$result" == "golang" ]] && log_pass || log_fail "got: $result"

    log_test "get_dev_packages for c/pacman"
    result=$(get_dev_packages "arch" "c" "pacman")
    [[ "$result" == "base-devel gdb lldb" ]] && log_pass || log_fail "got: $result"
}

test_base_packages() {
    log_test "BASE_PACKAGES array has required packages"
    for pkg in htop git neovim curl wget; do
        if [[ " ${BASE_PACKAGES[*]} " =~ " ${pkg} " ]]; then
            continue
        else
            log_fail "$pkg not in BASE_PACKAGES"
            return
        fi
    done
    log_pass
}

main() {
    echo "========================================"
    echo " Packages Library Unit Tests"
    echo "========================================"
    echo ""

    test_base_packages
    echo ""
    test_get_distro_packages
    echo ""
    test_get_dev_packages
    echo ""

    echo "========================================"
    echo " Results: $TESTS_PASSED passed, $TESTS_FAILED failed, $TESTS_RUN total"
    echo "========================================"

    if [[ $TESTS_FAILED -gt 0 ]]; then
        exit 1
    fi
}

main "$@"
