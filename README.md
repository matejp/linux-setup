# Linux Setup - User Manual

A modular system configuration tool for fresh Linux installations. Supports Ubuntu, Debian, Fedora, RHEL, OpenSUSE, and Arch-based distributions.

## Quick Start

```bash
git clone <repository-url> ~/linux-setup
cd ~/linux-setup
chmod +x setup.sh tests/*.sh
sudo ./setup.sh --all
```

## Features

- **Automatic Distribution Detection**: Identifies your Linux distribution and uses the correct package manager
- **Modular Architecture**: Each component (packages, Neovim config, etc.) is independently testable
- **Base Packages**: htop, git, neovim, curl, wget
- **Modern CLI Tools**: eza, bat, ripgrep, fd, fzf, zoxide, lazygit, btop, tldr, and more
- **Development Tools**: Go, C/C++, and Python development environments
- **Neovim Configuration**: Ready-to-use IDE setup with LSP, Treesitter, and DAP
- **Desktop Settings**: GNOME configuration (dash-to-dock, etc.)
- **Fish Shell**: Install fish, set as default shell, and deploy basic config
- **Bash Configuration**: Best-practice `~/.bashrc` and `~/.bash_profile` with SSH agent, aliases, and git-aware prompt
- **Fonts**: JetBrains Mono Nerd Font

## Supported Distributions

| Distribution | Package Manager |
|--------------|-----------------|
| Ubuntu, Debian, Pop!_OS, Linux Mint | apt |
| Fedora, RHEL, CentOS, Rocky, Alma | dnf |
| OpenSUSE, OpenSUSE Tumbleweed | zypper |
| Arch, Manjaro, EndeavourOS | pacman |

## Usage

### Full Setup (All Components)

```bash
sudo ./setup.sh --all
```

### Install Base Packages Only

```bash
sudo ./setup.sh --pkgs
```

### Install Specific Development Tools

```bash
sudo ./setup.sh --dev go          # Go only
sudo ./setup.sh --dev c           # C/C++ only
sudo ./setup.sh --dev python      # Python only
sudo ./setup.sh --dev go python   # Go and Python
```

### Install Neovim Configuration

```bash
sudo ./setup.sh --nvim
```

### Install JetBrains Mono Nerd Font

```bash
./setup.sh --font
```

### Apply Desktop Settings

```bash
./setup.sh --desktop
```

### Install Fish Shell

```bash
./setup.sh --fish
```

This will:
1. Install fish via the system package manager
2. Add fish to `/etc/shells`
3. Set fish as the default shell (`chsh`)
4. Deploy the fish configuration to `~/.config/fish`

### Deploy Bash Configuration

```bash
./setup.sh --bash
```

This will:
1. Back up any existing `~/.bashrc` and `~/.bash_profile`
2. Deploy `config/bash/bashrc` → `~/.bashrc`
3. Deploy `config/bash/bash_profile` → `~/.bash_profile`

### Detect Distribution

```bash
./setup.sh --detect
```

### Dry Run (Preview)

```bash
./setup.sh --all --dry-run
```

### Force Distribution

```bash
./setup.sh --all --distro ubuntu
```

### Echo Commands (Debug)

```bash
./setup.sh --all --echo        # Print all commands before executing
./setup.sh --all -x             # Short form
```

### Log Commands to File

```bash
./setup.sh --all --log setup.log   # Log all commands to file
./setup.sh --all -l setup.log      # Short form
```

### Combined Options

```bash
./setup.sh --all --dry-run --echo    # Dry run with command echo
./setup.sh --all --log full.log      # Log everything to file
```

## Command Line Options

| Option | Description |
|--------|-------------|
| `-h, --help` | Show help message |
| `-d, --distro DISTRO` | Force specific distribution |
| `-p, --pkgs` | Install base packages only |
| `-e, --dev LANG` | Install dev tools for language |
| `-n, --nvim` | Install Neovim configuration |
| `-f, --font` | Install JetBrains Mono Nerd Font |
| `-k, --desktop` | Apply desktop settings (GNOME) |
| `-s, --fish` | Install fish shell and set as default |
| `-b, --bash` | Deploy bash configuration |
| `-a, --all` | Install everything |
| `-v, --verbose` | Enable verbose output |
| `-t, --dry-run` | Show what would be done without executing |
| `-x, --echo` | Echo all commands before executing |
| `-l, --log FILE` | Log all commands to FILE |
| `--detect` | Detect and show distribution |

## Library Scripts

### lib/distro.sh

Distribution detection and package management utilities.

```bash
# Detect current distribution
./lib/distro.sh --detect

# Show full distribution info
./lib/distro.sh --info

# Get package manager for distribution
./lib/distro.sh --pm
```

### lib/packages.sh

Package management utilities.

```bash
# List all available packages
./lib/packages.sh --list

# Install base packages
./lib/packages.sh --base

# Install development packages
./lib/packages.sh --dev go c python
```

### lib/nvim.sh

Neovim configuration management.

```bash
# Install Neovim config
./lib/nvim.sh --install

# Verify installation
./lib/nvim.sh --verify

# Remove configuration
./lib/nvim.sh --remove

# Check dependencies
./lib/nvim.sh --deps
```

## Testing

Run the test suite:

```bash
# Run all tests
./tests/test.sh

# Run specific test
./tests/test_distro.sh
./tests/test_packages.sh

# Run single test case
bash -c 'source ../lib/distro.sh && get_package_manager ubuntu'
```

### Running a Single Test

To run a specific test from the test suite:

```bash
# Run just the shellcheck tests
./tests/test.sh 2>&1 | grep -A5 "Linting"

# Run a specific test function
bash -c '
    source ../lib/distro.sh
    result=$(get_package_manager "ubuntu")
    [[ "$result" == "apt" ]] && echo "PASS" || echo "FAIL"
'
```

## Neovim Configuration

This is a **No Plugins** Neovim configuration using only built-in features. It provides a clean, fast editing experience without external dependencies.

### Features

- **Custom Statusline**: Mode indicator, spell check status, file info, line/column, file type
- **Syntax Highlighting**: Built-in syntax support
- **Smart Editing**: Auto-indent, smart tab, spell checking
- **File Explorer**: Netrw-based file browser
- **Terminal Integration**: Embedded terminal support

### Settings

| Setting | Value |
|---------|-------|
| Leader key | Space |
| Tab size | 4 spaces |
| Encoding | UTF-8 |
| Line numbers | Relative |
| Mouse | Enabled |

### Keybindings

#### General
| Key | Action |
|-----|--------|
| `<Esc>` | Clear search highlight |
| `jj` | Escape insert mode |
| `Q` | Format paragraph |
| `<C-s>` | Save file |
| `<C-q>` | Save and quit |

#### File Explorer
| Key | Action |
|-----|--------|
| `<Leader>e` | Open Netrw (left panel) |
| `<Leader>o` | Open Netrw |

#### Window Navigation
| Key | Action |
|-----|--------|
| `<C-h>` | Move to left window |
| `<C-j>` | Move to below window |
| `<C-k>` | Move to above window |
| `<C-l>` | Move to right window |
| `<Leader>y` | Split horizontally |
| `<Leader>x` | Split vertically |

#### Tab Navigation
| Key | Action |
|-----|--------|
| `<Leader>t` | Next tab |
| `<Leader>c` | New tab |
| `<C-t>` | Open terminal in new tab |

#### Text Manipulation
| Key | Action |
|-----|--------|
| `<Leader>a` | Select all |
| `J` | Move line down (visual) |
| `K` | Move line up (visual) |
| `<` | Indent left (visual) |
| `>` | Indent right (visual) |
| `x` | Delete character (no register) |

#### Terminal
| Key | Action |
|-----|--------|
| `<C-t>` | Open terminal |
| `<Esc>` | Exit terminal mode |
| `<C-q>` | Exit terminal |

#### Special Features
| Key | Action |
|-----|--------|
| `<Leader>ht` | Toggle Hebrew mode (RTL) |
| `<Leader>hx` | Convert to hex dump |
| `<Leader>r` | Show registers |
| `<C-z>` | Toggle spell check |

### Custom Functions

- **ToggleHebrew()**: Switch between LTR and RTL text direction
- **DoHex()**: Convert buffer to hexadecimal dump
- **UndoHex()**: Reverse hex dump back to text

### First Run

After installation, open Neovim:

```bash
nvim
```

You should see: `Neovim configured - No Plugins Edition`

### GUI Font

When running in GUI mode (gvim/Neovim Qt), the font is automatically set to JetBrains Mono Nerd Font size 12.

## Project Structure

```
.
├── AGENTS.md              # Agent instructions
├── README.md             # This file
├── setup.sh              # Main setup script
├── lib/
│   ├── distro.sh         # Distribution detection
│   ├── packages.sh       # Package management
│   ├── nvim.sh           # Neovim configuration
│   ├── fonts.sh          # Font installation
│   ├── desktop.sh        # Desktop settings
│   ├── fish.sh           # Fish shell setup
│   └── bash.sh           # Bash configuration deployment
├── config/
│   ├── nvim/
│   │   └── init.lua      # Neovim entry point
│   ├── fish/
│   │   ├── config.fish   # Fish shell configuration
│   │   └── conf.d/
│   │       └── ssh_agent.fish  # SSH agent (auto-loaded by fish)
│   └── bash/
│       ├── bashrc        # Bash interactive shell config
│       └── bash_profile  # Bash login shell entry point
├── tests/
│   ├── test.sh           # Main test suite
│   ├── test_distro.sh    # Distro lib tests
│   └── test_packages.sh # Packages lib tests
└── docs/
    ├── MANUAL.md         # Detailed manual
    └── FILEMAP.md        # File documentation
```

## Troubleshooting

### Package Installation Fails

1. Update package lists first:
   ```bash
   sudo apt update    # or dnf check-update, etc.
   ```

2. Check if the package name differs for your distribution

### Neovim Plugins Not Loading

1. Check Neovim version (requires 0.8+):
   ```bash
   nvim --version
   ```

2. Update plugins:
   ```vim
   :Lazy sync
   ```

3. Check for errors:
   ```vim
   :Lazy debug
   ```

### LSP Not Working

1. Install Mason packages:
   ```vim
   :MasonInstall gopls clangd pyright
   ```

2. Check LSP status:
   ```vim
   :LspInfo
   ```

## Extending the Setup

### Adding a New Distribution

Edit `lib/distro.sh`:

```bash
get_package_manager() {
    local distro="$1"
    case "$distro" in
        # ... existing cases ...
        your-distro)
            echo "your-pm"
            ;;
    esac
}
```

### Adding New Packages

Edit `lib/packages.sh`:

```bash
# Add to DISTRO_PACKAGES
DISTRO_PACKAGES[your-pm]="pkg1 pkg2 pkg3"

# Add development packages
DEV_PACKAGES_YOUR_PM[go]="golang"
```

### Adding New Languages

Edit `config/nvim/lua/user/plugins.lua` to add LSP and Treesitter support.

### lib/desktop.sh

Desktop configuration management.

```bash
# Apply GNOME settings
./lib/desktop.sh
```

### lib/fish.sh

Fish shell installation and configuration.

```bash
./lib/fish.sh --setup    # Full setup (install + default shell + config)
./lib/fish.sh --install  # Install fish only
./lib/fish.sh --default  # Set fish as default shell only
./lib/fish.sh --config   # Deploy fish config only
```

### lib/bash.sh

Bash configuration deployment.

```bash
./lib/bash.sh --setup    # Deploy ~/.bashrc and ~/.bash_profile
./lib/bash.sh --install  # Same as --setup with optional source dir
```

## Fish Shell Configuration

The fish configuration (`config/fish/config.fish`) includes:

- Suppressed greeting
- `$EDITOR` / `$VISUAL` set to `nvim`
- `~/.local/bin` and `~/bin` added to PATH
- Aliases for modern CLI tools (eza, bat, fd, rg, btop, zoxide) - only active if the tool is installed
- General aliases (`..`, `mkdir`, `df`, `du`, `free`)
- Git aliases (`g`, `gs`, `ga`, `gc`, `gp`, `gl`, `gd`)
- Safety aliases (`rm -i`, `cp -i`, `mv -i`)
- Starship prompt integration (if starship is installed)

SSH agent is configured separately in `config/fish/conf.d/ssh_agent.fish` (auto-loaded by fish).

## Bash Configuration

The bash configuration (`config/bash/bashrc`) includes:

- Persistent 10,000 entry history with timestamps, no duplicates, cross-session sync
- Shell options: `autocd`, `globstar`, `cdspell`, `checkwinsize`
- `$EDITOR` / `$VISUAL` set to `nvim`
- `~/.local/bin` and `~/bin` added to PATH
- Git-aware coloured prompt with exit code indicator
- Starship prompt integration (if starship is installed, overrides default prompt)
- SSH agent started once per login session; all private keys in `~/.ssh/` loaded automatically
- Same modern CLI tool aliases as fish config
- Git aliases and safety aliases (`rm -i`, `cp -i`, `mv -i`)
- Bash completion sourced if available

`config/bash/bash_profile` sources `~/.bashrc`, ensuring the same config applies in both login shells (TTY, SSH) and interactive non-login shells (terminal emulators).

### SSH Key Loading (bash and fish)

Both configurations automatically:
1. Start `ssh-agent` if not already running, persisting the socket to `~/.ssh/agent-env`
2. Re-attach to the existing agent on subsequent shell opens in the same session
3. Scan `~/.ssh/` for private keys (files with a matching `.pub`, or matching `id_*` / `*_rsa` / `*_ed25519` / `*_ecdsa` patterns)
4. Add each key to the agent only if not already loaded (checked by fingerprint)

## Automatic Releases

The project uses GitHub Actions with [git-auto-semver](https://github.com/marketplace/actions/git-automatic-semantic-versioning) for automatic versioning on every push to main:

- **Automatic version bump** based on commit messages (patch for fixes, minor for features)
- **Automatic tag creation** following semantic versioning (v0.1.0, v0.1.1, etc.)
- **Automatic GitHub Release** creation with release notes

### Commit Message Convention

- `fix:` or no prefix → patch bump (0.1.0 → 0.1.1)
- `feat:` → minor bump (0.1.0 → 0.2.0)

## License

MIT License
