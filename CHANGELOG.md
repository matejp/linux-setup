# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Added
- ShellCheck to base packages (all distributions)
- Podman and Distrobox to base packages (all distributions)
- Distrobox testing documentation in docs/MANUAL.md
- `scripts/create-devbox.sh` - One-command devbox creation with full ansible setup
- Comprehensive Ansible test suite (`ansible/tests/`)
  - `test.yml` - Main test runner
  - Individual role tests for distro_facts, packages, nvim, fish, bash, fonts, desktop
  - `run_tests.sh` - Convenient test runner script
- `ansible/README.md` - Quick reference for Ansible commands
- Modern CLI tools (eza, bat, ripgrep, fd, fzf, zoxide, lazygit, btop, tldr, etc.)
- GNOME desktop settings support
- JetBrains Mono Nerd Font installation
- GitHub Actions workflow for automatic releases (.github/workflows/release.yml)
- Automatic semantic versioning with git-auto-semver
- Fish shell installation and configuration
  - `config/fish/config.fish` with basic fish configuration
  - `config/fish/conf.d/ssh_agent.fish` - SSH agent startup and key loading
- Bash configuration deployment
  - `config/bash/bashrc` - best-practice bash config with SSH agent, aliases, git-aware prompt
  - `config/bash/bash_profile` - login shell entry point that sources bashrc
- Ubuntu version detection in distro_facts role
- Version-aware package filtering (lazygit skipped on Ubuntu < 26.04)

### Changed
- **BREAKING**: Removed `setup.sh` wrapper - now use `ansible-playbook` directly
- **BREAKING**: Removed all legacy shell scripts (`lib/*.sh`)
- **BREAKING**: Removed legacy test suite (`tests/*.sh`)
- **BREAKING**: Removed all `linux_setup_install_*` variables - use tags exclusively
- **BREAKING**: Split `packages` role into `packages_base` and `packages_dev`
- Simplified to pure Ansible architecture with tag-based control
- Updated `ansible.cfg` - removed `group_vars_path`
- Removed `ansible/inventories/group_vars` symlink (kept `ansible/group_vars/` as primary)
- Simplified `ansible/playbooks/site.yml` - removed install flag computation, removed `when:` conditions
- Completely rewrote README.md for direct ansible-playbook usage
- Completely rewrote docs/MANUAL.md with Ansible-focused architecture and testing
- Completely rewrote docs/FILEMAP.md to document only Ansible files
- Updated AGENTS.md with Ansible build/test commands and style guidelines
- Neovim configuration: Updated to reflect No Plugins edition
- config/nvim/init.lua: Fix invalid 'nowrap' option (use 'wrap' instead)
- config/nvim/init.lua: Fix multiple issues (compatible, filetype, undoreload, statusline, SpellCheckStatus, duplicate functions, terminal keymaps, empty keymap)
- Fix tldr-py typo to tldr in apt package list

### Removed
- `setup.sh` - shell wrapper (use ansible-playbook directly)
- `lib/` directory - all shell implementation scripts
- `tests/` directory - shell-based test suite
- `ansible/inventories/group_vars` symlink
- `linux_setup_install_base` variable - use `--tags base` instead
- `linux_setup_install_dev` variable - use `--tags dev` instead
- `linux_setup_install_nvim` variable - use `--tags nvim` instead
- `linux_setup_install_font` variable - use `--tags font` instead
- `linux_setup_install_desktop` variable - use `--tags desktop` instead
- `linux_setup_install_fish` variable - use `--tags fish` instead
- `linux_setup_install_bash` variable - use `--tags bash` instead
- `ansible/roles/packages/` - split into packages_base and packages_dev
- `ansible/tests/test_packages.yml` - split into test_packages_base.yml and test_packages_dev.yml

## [0.1.0] - 2026-03-24

### Added
- Initial project setup
- Modular setup.sh with distribution detection
- lib/distro.sh for distribution detection and package management
- lib/packages.sh for package installation
- lib/nvim.sh for Neovim configuration
- Neovim config with LSP, Treesitter, and DAP support
- Test suite for distro and packages libraries
- README.md with comprehensive documentation