#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

source "${PROJECT_DIR}/lib/distro.sh"

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

mock_os_release() {
    cat <<'EOF'
ID=ubuntu
ID_LIKE=debian
VERSION_ID="22.04"
NAME="Ubuntu"
VERSION="22.04.1 LTS (Jammy Jellyfish)"
EOF
}

test_get_package_manager() {
    log_test "get_package_manager for apt"
    result=$(get_package_manager "ubuntu")
    [[ "$result" == "apt" ]] && log_pass || log_fail "got: $result"

    log_test "get_package_manager for dnf"
    result=$(get_package_manager "fedora")
    [[ "$result" == "dnf" ]] && log_pass || log_fail "got: $result"

    log_test "get_package_manager for zypper"
    result=$(get_package_manager "opensuse")
    [[ "$result" == "zypper" ]] && log_pass || log_fail "got: $result"

    log_test "get_package_manager for pacman"
    result=$(get_package_manager "arch")
    [[ "$result" == "pacman" ]] && log_pass || log_fail "got: $result"

    log_test "get_package_manager for unknown"
    result=$(get_package_manager "unknown")
    [[ "$result" == "unknown" ]] && log_pass || log_fail "got: $result"
}

test_get_update_cmd() {
    log_test "get_update_cmd for apt"
    result=$(get_update_cmd "apt")
    [[ "$result" == "sudo apt update" ]] && log_pass || log_fail "got: $result"

    log_test "get_update_cmd for dnf"
    result=$(get_update_cmd "dnf")
    [[ "$result" == "sudo dnf check-update" ]] && log_pass || log_fail "got: $result"

    log_test "get_update_cmd for zypper"
    result=$(get_update_cmd "zypper")
    [[ "$result" == "sudo zypper refresh" ]] && log_pass || log_fail "got: $result"

    log_test "get_update_cmd for pacman"
    result=$(get_update_cmd "pacman")
    [[ "$result" == "sudo pacman -Sy" ]] && log_pass || log_fail "got: $result"
}

test_get_install_cmd() {
    log_test "get_install_cmd for apt"
    result=$(get_install_cmd "apt")
    [[ "$result" == "sudo apt install -y" ]] && log_pass || log_fail "got: $result"

    log_test "get_install_cmd for dnf"
    result=$(get_install_cmd "dnf")
    [[ "$result" == "sudo dnf install -y" ]] && log_pass || log_fail "got: $result"

    log_test "get_install_cmd for zypper"
    result=$(get_install_cmd "zypper")
    [[ "$result" == "sudo zypper install -y" ]] && log_pass || log_fail "got: $result"

    log_test "get_install_cmd for pacman"
    result=$(get_install_cmd "pacman")
    [[ "$result" == "sudo pacman -S --noconfirm" ]] && log_pass || log_fail "got: $result"
}

test_get_distro_info() {
    log_test "get_distro_info JSON format"
    result=$(get_distro_info)
    if echo "$result" | grep -q '"distro"'; then
        log_pass
    else
        log_fail "invalid JSON"
    fi

    log_test "get_distro_info contains package_manager"
    result=$(get_distro_info)
    if echo "$result" | grep -q '"package_manager"'; then
        log_pass
    else
        log_fail "missing package_manager"
    fi
}

main() {
    echo "========================================"
    echo " Distro Library Unit Tests"
    echo "========================================"
    echo ""

    test_get_package_manager
    echo ""
    test_get_update_cmd
    echo ""
    test_get_install_cmd
    echo ""
    test_get_distro_info
    echo ""

    echo "========================================"
    echo " Results: $TESTS_PASSED passed, $TESTS_FAILED failed, $TESTS_RUN total"
    echo "========================================"

    if [[ $TESTS_FAILED -gt 0 ]]; then
        exit 1
    fi
}

main "$@"
