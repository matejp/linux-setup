#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

test_distro_lib() {
    log_test "distro.sh syntax"
    if bash -n "${PROJECT_DIR}/lib/distro.sh"; then
        log_pass
    else
        log_fail "syntax error"
    fi

    log_test "distro detection function exists"
    if grep -q "detect_distro()" "${PROJECT_DIR}/lib/distro.sh"; then
        log_pass
    else
        log_fail "function not found"
    fi

    log_test "package manager mappings"
    local pms="apt dnf zypper pacman"
    local found=0
    for pm in $pms; do
        if grep -q "get_package_manager" "${PROJECT_DIR}/lib/distro.sh" && \
           grep -q "$pm" "${PROJECT_DIR}/lib/distro.sh"; then
            ((found++)) || true
        fi
    done
    if [[ $found -ge 4 ]]; then
        log_pass
    else
        log_fail "missing package managers"
    fi
}

test_packages_lib() {
    log_test "packages.sh syntax"
    if bash -n "${PROJECT_DIR}/lib/packages.sh"; then
        log_pass
    else
        log_fail "syntax error"
    fi

    log_test "BASE_PACKAGES array defined"
    if grep -q "BASE_PACKAGES=" "${PROJECT_DIR}/lib/packages.sh"; then
        log_pass
    else
        log_fail "BASE_PACKAGES not found"
    fi

    log_test "Development packages arrays"
    for lang in go c python; do
        if grep -q "DEV_PACKAGES_.*\[$lang\]" "${PROJECT_DIR}/lib/packages.sh"; then
            log_pass
        else
            log_fail "DEV_PACKAGES for $lang not found"
        fi
    done
}

test_fonts_lib() {
    log_test "fonts.sh syntax"
    if bash -n "${PROJECT_DIR}/lib/fonts.sh"; then
        log_pass
    else
        log_fail "syntax error"
    fi

    log_test "fonts.sh install function exists"
    if grep -q "install_jetbrains_nerd_font()" "${PROJECT_DIR}/lib/fonts.sh"; then
        log_pass
    else
        log_fail "install_jetbrains_nerd_font not found"
    fi

    log_test "fonts.sh font URL defined"
    if grep -q "FONT_URL=" "${PROJECT_DIR}/lib/fonts.sh"; then
        log_pass
    else
        log_fail "FONT_URL not found"
    fi
}

test_nvim_lib() {
    log_test "nvim.sh syntax"
    if bash -n "${PROJECT_DIR}/lib/nvim.sh"; then
        log_pass
    else
        log_fail "syntax error"
    fi

    log_test "install_nvim_config function exists"
    if grep -q "install_nvim_config()" "${PROJECT_DIR}/lib/nvim.sh"; then
        log_pass
    else
        log_fail "function not found"
    fi
}

test_main_setup() {
    log_test "setup.sh syntax"
    if bash -n "${PROJECT_DIR}/setup.sh"; then
        log_pass
    else
        log_fail "syntax error"
    fi

    log_test "setup.sh is executable"
    if [[ -x "${PROJECT_DIR}/setup.sh" ]]; then
        log_pass
    else
        log_fail "not executable"
    fi

    log_test "help option works"
    if "${PROJECT_DIR}/setup.sh" --help > /dev/null 2>&1; then
        log_pass
    else
        log_fail "help failed"
    fi

    log_test "detect option works"
    if "${PROJECT_DIR}/setup.sh" --detect > /dev/null 2>&1; then
        log_pass
    else
        log_fail "detect failed"
    fi

    log_test "setup.sh has --font option"
    if "${PROJECT_DIR}/setup.sh" --help 2>&1 | grep -q "\-\-font"; then
        log_pass
    else
        log_fail "--font option not found"
    fi
}

test_nvim_config() {
    log_test "init.lua exists"
    if [[ -f "${PROJECT_DIR}/config/nvim/init.lua" ]]; then
        log_pass
    else
        log_fail "init.lua not found"
    fi

    log_test "init.lua has no plugins"
    if ! grep -q "lazy\|packer\|vim\.pack\|plugins/" "${PROJECT_DIR}/config/nvim/init.lua"; then
        log_pass
    else
        log_fail "plugins detected in init.lua"
    fi

    log_test "init.lua has statusline config"
    if grep -q "statusline\|StatuslineMode" "${PROJECT_DIR}/config/nvim/init.lua"; then
        log_pass
    else
        log_fail "no statusline config"
    fi

    log_test "init.lua has keybindings"
    if grep -q "nvim_set_keymap" "${PROJECT_DIR}/config/nvim/init.lua"; then
        log_pass
    else
        log_fail "no keybindings"
    fi

    log_test "init.lua has guifont config"
    if grep -q "guifont\|JetBrains" "${PROJECT_DIR}/config/nvim/init.lua"; then
        log_pass
    else
        log_fail "no guifont config"
    fi
}

run_shellcheck() {
    log_test "shellcheck on distro.sh"
    if command -v shellcheck &> /dev/null; then
        if shellcheck "${PROJECT_DIR}/lib/distro.sh" > /dev/null 2>&1; then
            log_pass
        else
            log_fail "shellcheck warnings"
        fi
    else
        echo -e "${YELLOW}SKIP${NC} (shellcheck not installed)"
    fi

    log_test "shellcheck on packages.sh"
    if command -v shellcheck &> /dev/null; then
        if shellcheck "${PROJECT_DIR}/lib/packages.sh" > /dev/null 2>&1; then
            log_pass
        else
            log_fail "shellcheck warnings"
        fi
    else
        echo -e "${YELLOW}SKIP${NC} (shellcheck not installed)"
    fi

    log_test "shellcheck on fonts.sh"
    if command -v shellcheck &> /dev/null; then
        if shellcheck "${PROJECT_DIR}/lib/fonts.sh" > /dev/null 2>&1; then
            log_pass
        else
            log_fail "shellcheck warnings"
        fi
    else
        echo -e "${YELLOW}SKIP${NC} (shellcheck not installed)"
    fi

    log_test "shellcheck on nvim.sh"
    if command -v shellcheck &> /dev/null; then
        if shellcheck "${PROJECT_DIR}/lib/nvim.sh" > /dev/null 2>&1; then
            log_pass
        else
            log_fail "shellcheck warnings"
        fi
    else
        echo -e "${YELLOW}SKIP${NC} (shellcheck not installed)"
    fi

    log_test "shellcheck on setup.sh"
    if command -v shellcheck &> /dev/null; then
        if shellcheck "${PROJECT_DIR}/setup.sh" > /dev/null 2>&1; then
            log_pass
        else
            log_fail "shellcheck warnings"
        fi
    else
        echo -e "${YELLOW}SKIP${NC} (shellcheck not installed)"
    fi
}

main() {
    echo "========================================"
    echo " Linux Setup Test Suite"
    echo "========================================"
    echo ""

    echo "--- Library Tests ---"
    test_distro_lib
    test_packages_lib
    test_fonts_lib
    test_nvim_lib
    echo ""

    echo "--- Main Script Tests ---"
    test_main_setup
    echo ""

    echo "--- Neovim Config Tests ---"
    test_nvim_config
    echo ""

    echo "--- Linting Tests ---"
    run_shellcheck
    echo ""

    echo "========================================"
    echo " Results: $TESTS_PASSED passed, $TESTS_FAILED failed, $TESTS_RUN total"
    echo "========================================"

    if [[ $TESTS_FAILED -gt 0 ]]; then
        exit 1
    fi
}

main "$@"
