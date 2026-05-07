#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ANSIBLE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
REPO_ROOT="$(cd "${ANSIBLE_DIR}/.." && pwd)"

cd "${ANSIBLE_DIR}"

echo "=== Running Linux Setup Ansible Test Suite ==="
echo ""

ansible-playbook tests/test.yml "$@"

echo ""
echo "=== Ansible Test Suite Complete ==="
echo ""
echo "Run distrobox integration tests with:"
echo "  ${REPO_ROOT}/scripts/test-distrobox.sh"
