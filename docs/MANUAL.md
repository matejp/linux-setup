# Detailed Manual

## Architecture

The setup system follows a modular architecture with three main layers:

```
┌─────────────────────────────────────────┐
│             setup.sh (CLI)              │
│         Argument parsing, flow         │
├─────────────────────────────────────────┤
│              lib/*.sh                   │
│     distro.sh, packages.sh, nvim.sh    │
│       Abstraction, business logic      │
├─────────────────────────────────────────┤
│              config/*                   │
│     Distribution-specific configs      │
│         Neovim plugin configs           │
└─────────────────────────────────────────┘
```

## Distribution Detection Flow

```
1. User runs: ./setup.sh --all
2. setup.sh sources: lib/distro.sh
3. distro.sh checks: /etc/os-release
4. Returns ID (e.g., "ubuntu", "fedora")
5. Maps ID to package manager: get_package_manager()
6. Returns pm (e.g., "apt", "dnf")
7. Uses pm to build install command
```

## Package Installation Flow

```
1. packages.sh defines packages per package manager
2. get_distro_packages() returns base packages
3. get_dev_packages() returns language-specific packages
4. install_packages() runs appropriate command:
   - apt:  sudo apt install -y <packages>
   - dnf:  sudo dnf install -y <packages>
   - zypper: sudo zypper install -y <packages>
   - pacman: sudo pacman -S --noconfirm <packages>
```

## Neovim Plugin Architecture

### Lazy.nvim Setup
```lua
-- init.lua loads lazy.nvim from stdpath
-- Then loads all plugins from lua/user/plugins.lua
```

### Plugin Configuration Pattern
```lua
{
    "owner/repo",
    dependencies = { "dep1", "dep2" },
    config = function()
        -- Called after plugin loads
        require("module").setup()
    end,
    ft = "filetype",  -- Load only for filetype
    cmd = "Command",  -- Load only for command
    keys = { {"key", "desc"} },  -- Load on keymap
}
```

### LSP Configuration
```lua
-- Each language has LSP configured in plugins.lua
lspconfig.<server>.setup({
    settings = { /* server-specific */ }
})

-- mason-lspconfig auto-installs servers listed in ensure_installed
```

### Debugging Configuration
```lua
-- nvim-dap configured for Go, C, and Python
dap.configurations.<lang> = {
    {
        type = "debugger",
        request = "launch",
        program = "${file}",
    }
}
```

## Adding a New Language

1. Add package mappings in `lib/packages.sh`:
```bash
DEV_PACKAGES_APT[newlang]="compiler interpreter"
```

2. Add LSP config in `config/nvim/lua/user/plugins.lua`:
```lua
lspconfig.newlang.setup({})
```

3. Add Treesitter grammar:
```lua
ensure_installed = { ..., "newlang" }
```

4. Add DAP config in `plugins.lua`:
```lua
dap.configurations.newlang = { ... }
```

## Testing Strategy

### Unit Tests
Test individual functions in isolation:
```bash
./tests/test_distro.sh    # Test distro functions
./tests/test_packages.sh  # Test package functions
```

### Integration Tests
Test full workflow:
```bash
./tests/test.sh           # All tests including shellcheck
```

### Manual Testing
```bash
# Test without installing
./setup.sh --all --dry-run

# Test specific component
./lib/packages.sh --list

# Verify Neovim config
./lib/nvim.sh --verify
```

## Configuration Locations

| Component | Location |
|-----------|----------|
| Neovim config | ~/.config/nvim |
| Backup config | ~/.config/nvim.backup.* |
| Lazy cache | ~/.local/share/nvim/lazy |
| Plugin cache | ~/.local/share/nvim/site/pack |

## Security Considerations

1. Scripts use `set -euo pipefail` for error handling
2. Package installation requires sudo (expected)
3. Neovim config backed up before overwriting
4. No secrets stored in repository
5. Verify checksums for downloaded tools

## Performance Notes

- Lazy.nvim only loads plugins when needed
- Treesitter grammars install on first use
- LSP servers download on :MasonInstall
- Neovim config structure is flat for fast loading
