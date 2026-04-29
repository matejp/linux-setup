# Ansible Setup - Quick Reference

## Prerequisites

Install Ansible on your system:

```bash
# Ubuntu/Debian
sudo apt install ansible-core

# Fedora/RHEL
sudo dnf install ansible-core

# Arch
sudo pacman -S ansible-core

# openSUSE
sudo zypper install ansible-core
```

## Quick Start

```bash
# From the ansible/ directory
cd ansible

# Install everything
ansible-playbook playbooks/site.yml --tags all

# Dry-run (check mode)
ansible-playbook playbooks/site.yml --tags all --check
```

## Common Commands

### Install Everything

```bash
ansible-playbook playbooks/site.yml --tags all
```

### Individual Components

```bash
# Base packages
ansible-playbook playbooks/site.yml --tags base

# Development tools (Go, C, Python)
ansible-playbook playbooks/site.yml --tags dev

# Neovim configuration
ansible-playbook playbooks/site.yml --tags nvim

# JetBrains Mono Nerd Font
ansible-playbook playbooks/site.yml --tags font

# Fish shell
ansible-playbook playbooks/site.yml --tags fish

# Bash configuration
ansible-playbook playbooks/site.yml --tags bash

# Desktop settings (GNOME)
ansible-playbook playbooks/site.yml --tags desktop
```

### Multiple Components

```bash
ansible-playbook playbooks/site.yml --tags base,nvim,fish
```

### Dry-Run (Check Mode)

```bash
# See what would be changed without making changes
ansible-playbook playbooks/site.yml --tags all --check
```

### Detect Distribution

```bash
ansible-playbook playbooks/detect.yml
```

### Run Tests

```bash
# Run all tests
ansible-playbook tests/test.yml

# Run specific test
ansible-playbook tests/test.yml --tags packages

# Use the test runner script
./tests/run_tests.sh
```

## Advanced Usage

### Custom Variables

```bash
# Force specific distribution
ansible-playbook playbooks/site.yml \
  -e linux_setup_force_distro=ubuntu

# Customize target user/home
ansible-playbook playbooks/site.yml \
  -e linux_setup_target_user=myuser \
  -e linux_setup_target_home=/home/myuser

# Install specific dev languages
ansible-playbook playbooks/site.yml --tags dev \
  -e linux_setup_dev_languages=go,python
```

### Verbose Output

```bash
# Verbose
ansible-playbook playbooks/site.yml --tags all -v

# Very verbose
ansible-playbook playbooks/site.yml --tags all -vv

# Debug level
ansible-playbook playbooks/site.yml --tags all -vvv
```

### Syntax Validation

```bash
# Check playbook syntax
ansible-playbook playbooks/site.yml --syntax-check

# Lint all playbooks and roles
ansible-lint playbooks/*.yml roles/*/tasks/*.yml
```

## Directory Structure

```
ansible/
├── ansible.cfg              # Ansible configuration
├── group_vars/              # Variables for all hosts
│   └── all.yml              # Default variables
├── inventories/             # Inventory files
│   └── localhost.yml        # Local host inventory
├── playbooks/               # Playbooks
│   ├── site.yml             # Main orchestrator
│   └── detect.yml           # Distribution detection
├── roles/                   # Ansible roles
│   ├── distro_facts/        # Distribution detection
│   ├── packages_base/       # Base package installation
│   ├── packages_dev/        # Dev tools installation
│   ├── nvim/                # Neovim configuration
│   ├── fonts/               # Font installation
│   ├── fish/                # Fish shell setup
│   ├── bash/                # Bash configuration
│   └── desktop/             # Desktop settings
└── tests/                   # Test suite
    ├── test.yml             # Main test playbook
    ├── test_*.yml           # Individual role tests
    └── run_tests.sh         # Test runner script
```

## Available Tags

Tags control which components are installed. Use `--tags <tag>` to select components.

| Tag | Installs |
|-----|----------|
| `all` | Everything (base, dev, nvim, font, desktop, fish, bash) |
| `base` | Base packages (htop, git, neovim, modern CLI tools) |
| `dev` | Development tools (Go, C/C++, Python) |
| `nvim` | Neovim configuration |
| `font` | JetBrains Mono Nerd Font |
| `fish` | Fish shell configuration |
| `bash` | Bash configuration |
| `desktop` | GNOME desktop settings |

## Variables Reference

### Common Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `linux_setup_target_user` | Current user | Target user for configuration |
| `linux_setup_target_home` | Current home | Target home directory |
| `linux_setup_force_distro` | (empty) | Force specific distribution ID |
| `linux_setup_dev_languages` | `['go', 'c', 'python']` | Development languages to install |

**Note**: Components are selected using tags (`--tags <component>`), not variables.

## Supported Distributions

| Distribution | Package Manager |
|--------------|-----------------|
| Ubuntu, Debian, Pop!_OS, Linux Mint | apt |
| Fedora, RHEL, CentOS, Rocky, Alma | dnf |
| OpenSUSE, OpenSUSE Tumbleweed | zypper |
| Arch, Manjaro, EndeavourOS | pacman |

## Troubleshooting

### Permission Errors

Most operations require sudo privileges. Ansible will prompt for your password when needed:

```bash
ansible-playbook playbooks/site.yml --tags all --ask-become-pass
```

Or configure passwordless sudo for your user.

### Distribution Not Detected

Force a specific distribution:

```bash
ansible-playbook playbooks/site.yml --tags all \
  -e linux_setup_force_distro=ubuntu
```

### Verbose Debug Output

Add `-vvv` for maximum verbosity:

```bash
ansible-playbook playbooks/site.yml --tags all -vvv
```

## Examples

### Fresh Linux Installation Setup

```bash
# Install everything on a fresh system
cd ansible
ansible-playbook playbooks/site.yml --tags all
```

### Developer Workstation

```bash
# Base packages + dev tools + Neovim + Fish
ansible-playbook playbooks/site.yml --tags base,dev,nvim,fish
```

### Minimal Setup

```bash
# Just base packages and Neovim
ansible-playbook playbooks/site.yml --tags base,nvim
```

### Desktop Environment Customization

```bash
# Only apply desktop settings
ansible-playbook playbooks/site.yml --tags desktop
```

## Contributing

When modifying roles:

1. Update role defaults in `roles/<role>/defaults/main.yml`
2. Update role tasks in `roles/<role>/tasks/main.yml`
3. Add/update tests in `tests/test_<role>.yml`
4. Run tests: `ansible-playbook tests/test.yml`
5. Test in check mode: `ansible-playbook playbooks/site.yml --check`
