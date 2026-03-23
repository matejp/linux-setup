# File Documentation

## Shell Scripts

### setup.sh
**Purpose**: Main entry point for the setup system  
**Usage**: `./setup.sh [OPTIONS]`  
**Options**: `--all`, `--pkgs`, `--dev`, `--nvim`, `--detect`, `--dry-run`  
**Exit codes**: 0 on success, 1 on error  

### lib/distro.sh
**Purpose**: Distribution detection and package manager abstraction  
**Functions**:
- `detect_distro()` - Returns distribution ID from /etc/os-release
- `get_package_manager(distro)` - Returns appropriate package manager
- `get_update_cmd(pm)` - Returns update command for package manager
- `get_install_cmd(pm)` - Returns install command for package manager
- `install_packages(...)` - Installs packages using appropriate manager
- `get_distro_info()` - Returns JSON with distro details

### lib/packages.sh
**Purpose**: Package definitions and installation utilities  
**Variables**:
- `BASE_PACKAGES` - Array of base packages (htop, git, neovim, curl, wget)
- `DISTRO_PACKAGES[pm]` - Package lists per package manager
- `DEV_PACKAGES_{pm}[lang]` - Development packages per language

**Functions**:
- `get_distro_packages(distro, pm)` - Get base packages for distro
- `get_dev_packages(distro, lang, pm)` - Get dev packages for language
- `install_base(distro, pm)` - Install base packages
- `install_dev_tools(distro, pm, langs...)` - Install dev packages

### lib/nvim.sh
**Purpose**: Neovim configuration management  
**Functions**:
- `install_nvim_config(source, target)` - Copy config to target
- `remove_nvim_config(target)` - Remove Neovim config
- `verify_nvim_config(target)` - Validate config structure
- `install_nvim_dependencies()` - Check Neovim installation

## Neovim Configuration

### config/nvim/init.lua
**Purpose**: Neovim entry point  
**Loads**: lazy.nvim plugin manager, then plugins from lua/user/plugins.lua  
**Requirements**: Neovim 0.8+  

### config/nvim/lua/user/plugins.lua
**Purpose**: Plugin definitions using lazy.nvim  
**Plugins**:
| Plugin | Purpose |
|--------|---------|
| telescope.nvim | Fuzzy finder |
| nvim-treesitter | Syntax highlighting |
| nvim-lspconfig | LSP client |
| mason.nvim | LSP/DAP installer |
| mason-lspconfig | LSP auto-setup |
| nvim-cmp | Completion |
| cmp-nvim-lsp | LSP completion source |
| luasnip | Snippets |
| lualine.nvim | Status line |
| tokyonight.nvim | Colorscheme |
| neodev.nvim | Neovim Lua dev |
| nvim-dap | Debugging |
| gopher.nvim | Go utilities |
| vim-test | Test runner |

### config/nvim/lua/user/options.lua
**Purpose**: Neovim settings and keybindings  
**Settings**: number, expandtab, shiftwidth, etc.  
**Keybindings**: Window navigation, yank highlighting  

## Test Files

### tests/test.sh
**Purpose**: Main test suite runner  
**Tests**: All shell scripts, Neovim config structure, shellcheck  
**Usage**: `./tests/test.sh`

### tests/test_distro.sh
**Purpose**: Unit tests for distro.sh  
**Tests**: get_package_manager, get_update_cmd, get_install_cmd, get_distro_info  
**Usage**: `./tests/test_distro.sh`

### tests/test_packages.sh
**Purpose**: Unit tests for packages.sh  
**Tests**: get_distro_packages, get_dev_packages, BASE_PACKAGES  
**Usage**: `./tests/test_packages.sh`
