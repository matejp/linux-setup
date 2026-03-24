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

### Changed
- Updated README.md to reflect new features and options

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