# AGENTS.md

## Overview

This repository contains Linux configuration files, dotfiles, and Ansible automation for system setup. The primary technologies are Ansible (YAML) and configuration files for various tools.

## Build/Lint/Test Commands

### Ansible Setup
```bash
# Run Ansible test suite
cd ansible && ansible-playbook tests/test.yml

# Run specific test
cd ansible && ansible-playbook tests/test.yml --tags packages

# Use test runner script
cd ansible && ./tests/run_tests.sh

# Syntax check all playbooks
cd ansible && ansible-playbook playbooks/site.yml --syntax-check
cd ansible && ansible-playbook playbooks/detect.yml --syntax-check

# Lint Ansible code (requires ansible-lint)
ansible-lint ansible/playbooks/*.yml ansible/roles/*/tasks/*.yml

# Dry-run installation (check mode)
cd ansible && ansible-playbook playbooks/site.yml --tags all --check

# Dry-run specific component
cd ansible && ansible-playbook playbooks/site.yml --tags nvim --check

# Detect distribution
cd ansible && ansible-playbook playbooks/detect.yml

# Verbose output (debug)
cd ansible && ansible-playbook playbooks/site.yml --tags all -vvv

# Install everything
cd ansible && ansible-playbook playbooks/site.yml --tags all

# Install specific components
cd ansible && ansible-playbook playbooks/site.yml --tags base
cd ansible && ansible-playbook playbooks/site.yml --tags dev
cd ansible && ansible-playbook playbooks/site.yml --tags nvim
cd ansible && ansible-playbook playbooks/site.yml --tags fish
cd ansible && ansible-playbook playbooks/site.yml --tags bash
cd ansible && ansible-playbook playbooks/site.yml --tags font
cd ansible && ansible-playbook playbooks/site.yml --tags desktop

# Install multiple components
cd ansible && ansible-playbook playbooks/site.yml --tags base,nvim,fish
```

### YAML Files
```bash
# Check for common issues in YAML files
yamllint ansible/**/*.yml

# Validate YAML syntax
python3 -c 'import yaml, sys; yaml.safe_load(sys.stdin)' < file.yml
```

## Code Style Guidelines

### Ansible

- Use 2 spaces for indentation in YAML files
- Use lowercase for keys and variable names
- Use `linux_setup_` prefix for all custom variables
- Quote strings that might be misinterpreted (yes/no, version numbers)
- Use descriptive task names that explain what the task does
- Add `tags:` to tasks for selective execution
- Use `when:` conditions to control task execution
- Prefer Ansible modules over shell commands when available

### Ansible Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Variables | lowercase_snake_case | `linux_setup_target_user`, `linux_setup_distro_id` |
| Roles | lowercase_snake_case | `distro_facts`, `packages`, `nvim` |
| Files | lowercase_snake_case.yml | `main.yml`, `test_packages.yml` |
| Tags | lowercase | `base`, `dev`, `nvim`, `all` |
| Handlers | Descriptive sentence | `Refresh font cache`, `Reload shell configuration` |

### Variable Naming

- All custom variables MUST start with `linux_setup_`
- Use descriptive names: `linux_setup_nvim_target` not `nvim_dir`
- Boolean flags: `linux_setup_install_<component>` (e.g., `linux_setup_install_nvim`)
- Paths: `linux_setup_<component>_source` and `linux_setup_<component>_target`
- Facts: `linux_setup_<component>_resolved` for computed values

### Task Structure

```yaml
- name: Clear, descriptive task name
  ansible.builtin.module:
    parameter: value
  when: condition
  tags:
    - tag_name
  become: true  # Only if sudo required
```

### Documentation

- Add comments for complex logic in tasks
- Document all variables in role `defaults/main.yml`
- Keep README.md and docs/ in sync with code
- Update tests when changing role behavior

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
- **Before every commit:**
  - Update README.md to document new features
  - Update CHANGELOG.md with details of all changes
  - Add both README.md and CHANGELOG.md to the git commit
- **Do NOT automatically commit changes** - wait for explicit user request before committing

## Security Considerations

- Never commit secrets, API keys, or tokens
- Use `.gitignore` for sensitive files
- Use environment variables or secrets management for credentials
- Verify checksums for downloaded scripts
- Review `chmod` permissions on scripts (755 for scripts, 600 for configs with secrets)
