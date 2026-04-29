#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ANSIBLE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

cd "${ANSIBLE_DIR}"

echo "=== Running Linux Setup Ansible Test Suite ==="
echo ""

ansible-playbook tests/test.yml "$@"

echo ""
echo "=== Test Suite Complete ==="
