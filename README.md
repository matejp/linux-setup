# Linux Setup

A modular system configuration tool for fresh Linux installations, powered by Ansible. Supports Ubuntu, Debian, Fedora, RHEL, OpenSUSE, and Arch-based distributions.

## Quick Start

```bash
# Clone the repository
git clone <repository-url> ~/linux-setup
cd ~/linux-setup

# Install Ansible
sudo apt install ansible-core  # Ubuntu/Debian
# OR
sudo dnf install ansible-core  # Fedora/RHEL

# Install everything
cd ansible
ansible-playbook playbooks/site.yml --tags all
```

## Features

- **Automatic Distribution Detection**: Identifies your Linux distribution and uses the correct package manager
- **Modular Architecture**: Each component is independently configurable and testable
- **Base Packages**: htop, git, neovim, curl, wget
- **Modern CLI Tools**: eza, bat, ripgrep, fd, fzf, zoxide, lazygit, btop, tldr, and more
- **Development Tools**: Go, C/C++, and Python development environments
- **Neovim Configuration**: Minimal `config/nvim/init.lua` setup with statusline and ergonomic keybindings
- **Desktop Settings**: GNOME configuration (dash-to-dock, etc.)
- **Fish Shell**: Install fish, set as default shell, and deploy basic config
- **Bash Configuration**: Best-practice `~/.bashrc` and `~/.bash_profile` with SSH agent, aliases, and git-aware prompt
- **Smart Package Filtering**: Version-aware package filtering (e.g. lazygit skipped on Ubuntu < 26.04)
- **Container Tools**: Podman and Distrobox for containerized environments
- **Fonts**: JetBrains Mono Nerd Font

## Supported Distributions

| Distribution | Package Manager |
|--------------|-----------------|
| Ubuntu, Debian, Pop!_OS, Linux Mint | apt |
| Fedora, RHEL, CentOS, Rocky, Alma | dnf |
| OpenSUSE, OpenSUSE Tumbleweed | zypper |
| Arch, Manjaro, EndeavourOS | pacman |

## Usage

All commands should be run from the `ansible/` directory:

```bash
cd ansible
```

### Full Setup (All Components)

```bash
ansible-playbook playbooks/site.yml --tags all
```

### Individual Components

```bash
# Base packages only
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
# Base packages + Neovim + Fish
ansible-playbook playbooks/site.yml --tags base,nvim,fish
```

### Custom Development Languages

```bash
# Install only Go and Python (not C)
ansible-playbook playbooks/site.yml --tags dev \
  -e linux_setup_dev_languages=go,python
```

### Detect Distribution

```bash
ansible-playbook playbooks/detect.yml
```

### Dry Run (Preview Changes)

```bash
ansible-playbook playbooks/site.yml --tags all --check
```

### Verbose Output

```bash
ansible-playbook playbooks/site.yml --tags all -vvv
```

### Create Devbox (Containerized Dev Environment)

Create an isolated development container with everything pre-installed:

```bash
# Ubuntu 24.04 devbox
./scripts/create-devbox.sh ubuntu 24.04 ~/devbox-ubuntu

# Fedora 42 devbox with custom prefix
./scripts/create-devbox.sh fedora 42 ~/devbox-fedora --prefix work

# Arch Linux devbox
./scripts/create-devbox.sh arch latest ~/devbox-arch --prefix test1
```

Supported distributions:
- **Ubuntu**: 22.04, 24.04, latest
- **Debian**: 12, testing, unstable
- **Fedora**: 41, 42, rawhide
- **Arch**: latest
- **openSUSE**: tumbleweed

The script creates a distrobox container with an isolated home directory, installs ansible-core, and runs the full setup playbook automatically. Enter the container with `distrobox enter <name>`.

## What Gets Installed

### Base Packages (`--tags base`)

**Core utilities:**
- htop, btop - System monitors
- git - Version control
- neovim - Text editor
- curl, wget - Download tools
- jq - JSON processor

**Modern CLI tools:**
- eza - Modern `ls` replacement
- bat - `cat` with syntax highlighting
- ripgrep - Fast text search
- fd - Fast `find` replacement
- fzf - Fuzzy finder
- zoxide - Smart `cd` replacement
- lazygit - Git TUI
- tldr - Simplified man pages
- httpie - HTTP client
- trash-cli - Safe `rm` replacement
- duf - Disk usage tool
- fish - Modern shell

**Container tools:**
- podman - Rootless container engine
- distrobox - Containerized development environments

### Development Tools (`--tags dev`)

**Go:**
- Go compiler and tools
- gopls (LSP)
- delve (debugger)

**C/C++:**
- gcc, g++, make, cmake
- clang, clangd (LSP)
- gdb (debugger)
- valgrind

**Python:**
- python3, pip
- python3-venv
- pylint, black, mypy
- python-lsp-server

### Neovim Configuration (`--tags nvim`)

Deploys a minimal, plugin-free Neovim configuration:
- **Location**: `~/.config/nvim/init.lua`
- **Features**: Statusline, ergonomic keybindings, basic settings
- **Backup**: Existing config backed up to `~/.config/nvim.backup.<timestamp>`

### Fish Shell (`--tags fish`)

1. Installs fish via package manager
2. Registers fish in `/etc/shells`
3. Sets fish as default shell
4. Deploys configuration to `~/.config/fish/`
   - `config.fish` - Main config
   - `conf.d/ssh_agent.fish` - SSH agent setup

### Bash Configuration (`--tags bash`)

Deploys best-practice bash configuration:
- **`~/.bashrc`**: Aliases, functions, prompt, SSH agent
- **`~/.bash_profile`**: Login shell entry point
- **Backup**: Existing files backed up automatically

### Fonts (`--tags font`)

Installs JetBrains Mono Nerd Font:
- **Location**: `~/.local/share/fonts/`
- **Source**: Official Nerd Fonts release
- Font cache automatically refreshed

### Desktop Settings (`--tags desktop`)

Applies GNOME desktop settings (if GNOME available):
- dash-to-dock click action: minimize

## Configuration

### Default Variables

Core variables are defined in `ansible/group_vars/all.yml`:

| Variable | Default | Description |
|----------|---------|-------------|
| `linux_setup_target_user` | Current user | Target user for configs |
| `linux_setup_target_home` | Current home | Target home directory |
| `linux_setup_dev_languages` | `['go', 'c', 'python']` | Dev languages to install |

### Overriding Variables

Use `-e` flag:

```bash
# Custom dev languages
ansible-playbook playbooks/site.yml --tags dev \
  -e linux_setup_dev_languages=go,python

# Force specific distribution
ansible-playbook playbooks/site.yml --tags all \
  -e linux_setup_force_distro=ubuntu
```

**Note**: Component selection is controlled by `--tags`, not by variables.

## Testing

Run the test suite to verify all roles:

```bash
cd ansible

# Run all tests
ansible-playbook tests/test.yml

# Run specific test
ansible-playbook tests/test.yml --tags packages

# Use test runner script
./tests/run_tests.sh
```

Tests verify:
- Distribution detection works correctly
- Package definitions are valid
- Config files exist in source directories
- Roles run successfully in check mode
- Variables are properly defined

## Directory Structure

```
linux-setup/
├── ansible/
│   ├── ansible.cfg              # Ansible configuration
│   ├── group_vars/              # Global variables
│   │   └── all.yml
│   ├── inventories/             # Inventory files
│   │   └── localhost.yml
│   ├── playbooks/               # Playbooks
│   │   ├── site.yml             # Main playbook
│   │   └── detect.yml           # Distribution detection
│   ├── roles/                   # Ansible roles
│   │   ├── distro_facts/        # Distribution detection
│   │   ├── packages_base/       # Base package installation
│   │   ├── packages_dev/        # Dev tools installation
│   │   ├── nvim/                # Neovim config
│   │   ├── fonts/               # Font installation
│   │   ├── fish/                # Fish shell
│   │   ├── bash/                # Bash config
│   │   └── desktop/             # Desktop settings
│   ├── tests/                   # Test suite
│   │   ├── test.yml             # Main test runner
│   │   ├── test_*.yml           # Role tests
│   │   └── run_tests.sh         # Test script
│   └── README.md                # Quick reference
├── config/                      # Source configurations
│   ├── nvim/                    # Neovim config files
│   ├── fish/                    # Fish config files
│   └── bash/                    # Bash config files
├── scripts/                     # Utility scripts
│   └── create-devbox.sh         # Create distrobox dev environment
└── docs/                        # Documentation
    ├── MANUAL.md                # Detailed manual
    └── FILEMAP.md               # File reference
```

## Architecture

```
┌─────────────────────────────────────────┐
│      ansible-playbook (user runs)       │
│         playbooks/site.yml               │
├─────────────────────────────────────────┤
│           Ansible Roles                  │
│  distro_facts → packages → nvim →       │
│  fonts → fish → bash → desktop           │
├─────────────────────────────────────────┤
│        Source Configurations             │
│      config/nvim, config/fish, etc       │
└─────────────────────────────────────────┘
```

**Flow:**
1. User runs `ansible-playbook` with desired tags
2. `distro_facts` role detects distribution and package manager
3. Selected roles execute based on tags
4. Configurations deployed from `config/` to target directories

## Advanced Usage

### Customizing Package Lists

Edit `ansible/roles/packages/defaults/main.yml`:

```yaml
linux_setup_base_packages:
  apt:
    - htop
    - git
    - your-custom-package
```

### Adding a New Distribution

1. Add mapping in `ansible/roles/distro_facts/defaults/main.yml`
2. Add package lists in `ansible/roles/packages/defaults/main.yml`
3. Test with `ansible-playbook playbooks/detect.yml`

### Syntax Validation

```bash
# Check playbook syntax
ansible-playbook playbooks/site.yml --syntax-check

# Lint with ansible-lint (if installed)
ansible-lint playbooks/*.yml roles/*/tasks/*.yml

# Validate YAML
yamllint ansible/**/*.yml
```

## Troubleshooting

### Permission Errors

Most operations require sudo. Ansible will prompt when needed, or use:

```bash
ansible-playbook playbooks/site.yml --tags all --ask-become-pass
```

### Distribution Not Detected

Force a specific distribution:

```bash
ansible-playbook playbooks/site.yml --tags all \
  -e linux_setup_force_distro=ubuntu
```

### Package Installation Fails

1. Update package cache first:
   ```bash
   sudo apt update        # Ubuntu/Debian
   sudo dnf check-update  # Fedora
   ```

2. Check package availability:
   ```bash
   apt search <package>   # Ubuntu/Debian
   dnf search <package>   # Fedora
   ```

3. Run with verbose output:
   ```bash
   ansible-playbook playbooks/site.yml --tags base -vvv
   ```

### Neovim Config Issues

If Neovim doesn't work after installation:

1. Check Neovim version: `nvim --version` (requires 0.8+)
2. Check config syntax: `nvim --headless +quit`
3. Restore backup: `mv ~/.config/nvim.backup.* ~/.config/nvim`

## Configuration Files

### Neovim (`~/.config/nvim/init.lua`)

Minimal configuration with:
- Line numbers, relative numbers
- Smart indentation (2 spaces)
- Search highlighting
- Custom statusline
- Ergonomic keybindings

### Fish (`~/.config/fish/`)

- `config.fish`: Aliases, environment variables
- `conf.d/ssh_agent.fish`: SSH agent auto-start

### Bash (`~/`)

- `.bashrc`: Interactive shell config, aliases, prompt
- `.bash_profile`: Login shell entry point

## Security Considerations

- No secrets or credentials stored in repository
- All files deployed with appropriate permissions (644 for configs, 755 for dirs)
- Existing configurations backed up before overwriting
- Package installation requires sudo (as expected)
- Downloads verified from official sources

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Update tests: `ansible/tests/test_<role>.yml`
5. Run tests: `cd ansible && ansible-playbook tests/test.yml`
6. Test in check mode: `ansible-playbook playbooks/site.yml --check`
7. Submit a pull request

## License

See repository for license information.

## Quick Reference Card

```bash
# Install Ansible
sudo apt install ansible-core  # Ubuntu/Debian

# Full setup
cd ansible && ansible-playbook playbooks/site.yml --tags all

# Individual components
ansible-playbook playbooks/site.yml --tags base      # Base packages
ansible-playbook playbooks/site.yml --tags dev       # Dev tools
ansible-playbook playbooks/site.yml --tags nvim      # Neovim
ansible-playbook playbooks/site.yml --tags fish      # Fish shell
ansible-playbook playbooks/site.yml --tags bash      # Bash config
ansible-playbook playbooks/site.yml --tags font      # Font
ansible-playbook playbooks/site.yml --tags desktop   # GNOME settings

# Multiple components
ansible-playbook playbooks/site.yml --tags base,nvim,fish

# Dry run
ansible-playbook playbooks/site.yml --tags all --check

# Run tests
ansible-playbook tests/test.yml

# Detect distribution
ansible-playbook playbooks/detect.yml

# Create devbox (containerized dev environment)
./scripts/create-devbox.sh ubuntu 24.04 ~/devbox-ubuntu
```

For more details, see:
- `ansible/README.md` - Quick Ansible reference
- `docs/MANUAL.md` - Detailed manual
- `docs/FILEMAP.md` - File documentation
