# AGENTS.md

## Overview

This repository contains Linux configuration files, dotfiles, and setup scripts. The primary languages used are shell scripts (bash), YAML, and TOML.

## Build/Lint/Test Commands

### Linux Setup Scripts
```bash
# Check all shell script syntax
bash -n setup.sh lib/*.sh

# Run full test suite
./tests/test.sh

# Run unit tests for specific library
./tests/test_distro.sh
./tests/test_packages.sh

# Run a single test function
bash -c 'source lib/distro.sh && get_package_manager ubuntu'

# Run shellcheck (if installed)
shellcheck setup.sh lib/*.sh

# Dry-run setup (preview without executing)
./setup.sh --all --dry-run

# Detect current distribution
./setup.sh --detect

# Echo all commands before executing (debug)
./setup.sh --all --echo

# Log all commands to file
./setup.sh --all --log setup.log

# Combined: dry-run with command echo
./setup.sh --all --dry-run --echo
```

### Shell Scripts
```bash
# Check shell script syntax
bash -n script.sh

# Run shellcheck for linting
shellcheck script.sh

# Format shell scripts
shfmt -w script.sh
```

### Ansible
```bash
# Syntax check Ansible playbooks
ansible-playbook --syntax-check playbook.yml

# Check Ansible code (requires ansible-lint)
ansible-lint playbook.yml

# Dry-run playbook
ansible-playbook --check playbook.yml
```

### Nix/NixOS
```bash
# Evaluate Nix expression
nix-instantiate --eval default.nix

# Build NixOS configuration
sudo nixos-rebuild switch

# Format Nix files
nixfmt config.nix
```

### General
```bash
# Check for common issues in YAML files
yamllint config.yml

# Validate TOML files
tomll config.toml
```

## Code Style Guidelines

### Shell Scripts

- Use `#!/usr/bin/env bash` shebang for portability
- Use `set -euo pipefail` for strict error handling
- Use 4 spaces for indentation
- Use `${var}` syntax for variable expansion
- Use `[[ ]]` for conditionals (not `[ ]`)
- Use `local` for function-scoped variables
- Quote all variables: `"$variable"` not `$variable`
- Use uppercase for environment variables: `HOME`, `PATH`
- Use lowercase for local variables: `config_file`, `target_dir`

### Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Variables | lowercase_snake_case | `config_file`, `target_dir` |
| Functions | lowercase_snake_case | `install_packages()`, `setup_dotfiles()` |
| Constants | UPPERCASE_SNAKE_CASE | `DOTFILES_DIR`, `CONFIG_HOME` |
| Files | lowercase-kebab-case or lowercase_snake_case | `install-script.sh`, `zsh_config` |
| Directories | lowercase-kebab-case | `backup-files`, `config-dirs` |

### Imports and Dependencies

- Specify absolute paths when possible
- Use `source` or `.` for shell script includes
- Document all external dependencies in comments
- Prefer native tools over external dependencies

### Error Handling

```bash
# Always use these options at the top of scripts
set -euo pipefail

# For commands that may fail intentionally
command_that_might_fail || true
command_that_might_fail || { echo "Failed"; exit 1; }

# Use error messages
die() { echo "Error: $*" >&2; exit 1; }
```

### Documentation

- Add shebang and brief description at top of scripts
- Use comments for non-obvious logic
- Document all environment variables used
- Keep documentation in sync with code

## Configuration Files

### YAML
- Use 2 spaces for indentation
- Use lowercase keys
- Quote strings that might be misinterpreted

### TOML
- Follow TOML 1.0 specification
- Use descriptive section names

### INI-style
- Use `#` for comments
- Keep sections organized

## Git Workflow

- Commit messages: imperative mood, short first line
- Branch naming: `feature/`, `fix/`, `setup/` prefixes
- Test changes in a VM or container before committing
- Keep commits atomic and focused

## Security Considerations

- Never commit secrets, API keys, or tokens
- Use `.gitignore` for sensitive files
- Use environment variables or secrets management for credentials
- Verify checksums for downloaded scripts
- Review `chmod` permissions on scripts (755 for scripts, 600 for configs with secrets)
