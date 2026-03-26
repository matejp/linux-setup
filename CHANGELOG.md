# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Added
- Modern CLI tools (eza, bat, ripgrep, fd, fzf, zoxide, lazygit, btop, tldr, etc.)
- `--desktop` / `-k` flag for GNOME desktop settings
- `--font` / `-f` flag for JetBrains Mono Nerd Font installation
- `lib/desktop.sh` for desktop configuration
- `lib/fonts.sh` for font installation
- GitHub Actions workflow for automatic releases (.github/workflows/release.yml)
- Automatic semantic versioning with git-auto-semver
- `--fish` / `-s` flag to install fish shell, set as default, and deploy config
- `lib/fish.sh` for fish shell installation and configuration
- `config/fish/config.fish` with basic fish configuration
- `config/fish/conf.d/ssh_agent.fish` - SSH agent startup and key loading for fish
- `--bash` / `-b` flag to deploy bash configuration
- `lib/bash.sh` for bash configuration deployment
- `config/bash/bashrc` - best-practice bash config with SSH agent, aliases, git-aware prompt
- `config/bash/bash_profile` - login shell entry point that sources bashrc
- `detect_ubuntu_version()` and `get_ubuntu_major_version()` in lib/distro.sh
- `filter_packages_for_distro()` in lib/packages.sh: skips lazygit on Ubuntu < 26.04
- 3 new tests for Ubuntu version-based package filtering

### Changed
- Neovim configuration: Updated README to reflect No Plugins edition
- lib/nvim.sh: Removed plugin-related verification and dependencies
- config/nvim/init.lua: Fix invalid 'nowrap' option (use 'wrap' instead)
- config/nvim/init.lua: Fix multiple issues (compatible, filetype, undoreload, statusline, SpellCheckStatus, duplicate functions, terminal keymaps, empty keymap)
- AGENTS.md: Do not automatically commit changes without explicit request
- Updated README.md to reflect new features and options
- Fix tldr-py typo to tldr in apt package list
- Updated test_packages.sh to match current package lists

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