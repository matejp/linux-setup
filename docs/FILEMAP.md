# File Documentation

## Ansible Playbooks

### ansible/playbooks/site.yml
**Purpose**: Main orchestrator playbook that runs roles based on tags  
**Usage**: `ansible-playbook playbooks/site.yml --tags <tags>`  
**Tags**: `base`, `dev`, `nvim`, `font`, `desktop`, `fish`, `bash`, `all`  
**Exit codes**: 0 on success, non-zero on error  

**Flow:**
1. Always runs `distro_facts` role
2. Runs other roles based on tags selected by user
3. No install flags needed - tags control everything

### ansible/playbooks/detect.yml
**Purpose**: Detect and print distribution metadata  
**Usage**: `ansible-playbook playbooks/detect.yml`  
**Output**: Displays `linux_setup_distro_id`, `linux_setup_package_manager`, and version info  

## Ansible Roles

### ansible/roles/distro_facts
**Purpose**: Distribution detection and package manager mapping  
**Tag**: `always` (runs every time)  
**Files**:
- `defaults/main.yml` - Distribution and package manager mappings
- `tasks/main.yml` - Detection logic
- `vars/main.yml` - Additional variables

**Provides facts:**
- `linux_setup_distro_id` - Normalized distribution ID
- `linux_setup_package_manager` - Package manager (apt/dnf/zypper/pacman)
- `linux_setup_ubuntu_version` - Ubuntu version (if applicable)

### ansible/roles/packages_base
**Purpose**: Install base system packages  
**Tag**: `base`  
**Files**:
- `defaults/main.yml` - Base package lists per package manager
- `tasks/main.yml` - Package resolution and installation
- `vars/main.yml` - Package resolution variables
- `meta/main.yml` - Dependency on distro_facts

**Variables:**
- `linux_setup_base_packages[pm]` - Base packages per package manager

**Features:**
- Version-aware filtering (e.g., lazygit on Ubuntu < 26.04)
- Package manager detection from distro_facts

### ansible/roles/packages_dev
**Purpose**: Install development tools  
**Tag**: `dev`  
**Files**:
- `defaults/main.yml` - Dev package lists per language per package manager
- `tasks/main.yml` - Language resolution and package installation
- `vars/main.yml` - Package resolution variables
- `meta/main.yml` - Dependency on distro_facts

**Variables:**
- `linux_setup_dev_packages[pm][lang]` - Dev packages per language
- `linux_setup_default_dev_languages` - Default: `['go', 'c', 'python']`

**Features:**
- Language-specific packages (go, c, python)
- Default languages if not specified
- Custom languages via `linux_setup_dev_languages` variable
- Unique package deduplication

### ansible/roles/nvim
**Purpose**: Deploy Neovim configuration  
**Tag**: `nvim`  
**Files**:
- `defaults/main.yml` - Source/target paths
- `tasks/main.yml` - Deployment logic

**Process:**
1. Ensure `~/.config` exists
2. Backup existing Neovim config (if exists)
3. Deploy `config/nvim/` → `~/.config/nvim/`
4. Verify `init.lua` exists
5. Check Neovim version

### ansible/roles/fonts
**Purpose**: Install JetBrains Mono Nerd Font  
**Tag**: `font`  
**Files**:
- `defaults/main.yml` - Font URL and paths
- `tasks/main.yml` - Font installation logic
- `handlers/main.yml` - Font cache refresh

**Process:**
1. Install `unzip` package
2. Ensure font directory exists
3. Check if fonts already installed
4. Download and extract font archive
5. Refresh font cache

### ansible/roles/fish
**Purpose**: Install and configure fish shell  
**Tag**: `fish`  
**Files**:
- `defaults/main.yml` - Source/target paths
- `tasks/main.yml` - Fish setup logic
- `handlers/main.yml` - Shell reload handler

**Process:**
1. Install fish package
2. Locate fish binary
3. Register in `/etc/shells`
4. Backup existing config (if exists)
5. Deploy `config/fish/` → `~/.config/fish/`
6. Set fish as default shell

### ansible/roles/bash
**Purpose**: Deploy bash configuration  
**Tag**: `bash`  
**Files**:
- `defaults/main.yml` - Source/target paths
- `tasks/main.yml` - Deployment logic

**Process:**
1. Ensure home directory exists
2. Deploy `config/bash/bashrc` → `~/.bashrc` (with backup)
3. Deploy `config/bash/bash_profile` → `~/.bash_profile` (with backup)

### ansible/roles/desktop
**Purpose**: Apply GNOME desktop settings  
**Tag**: `desktop`  
**Files**:
- `defaults/main.yml` - Desktop settings
- `tasks/main.yml` - Settings application

**Process:**
1. Check if `gsettings` available
2. Apply dash-to-dock settings (if available)

## Configuration Files

### config/nvim/init.lua
**Purpose**: Neovim entry point configuration  
**Type**: Minimal built-in configuration (no plugins)  
**Requirements**: Neovim 0.8+  
**Deployed to**: `~/.config/nvim/init.lua`

**Features:**
- Line numbers, relative numbers
- Smart indentation (2 spaces)
- Custom statusline
- Ergonomic keybindings

### config/fish/config.fish
**Purpose**: Main fish shell configuration  
**Deployed to**: `~/.config/fish/config.fish`

**Features:**
- Aliases
- Environment variables
- Custom functions

### config/fish/conf.d/ssh_agent.fish
**Purpose**: SSH agent auto-start for fish  
**Deployed to**: `~/.config/fish/conf.d/ssh_agent.fish`

**Features:**
- Automatic SSH agent startup
- Key loading on shell start

### config/bash/bashrc
**Purpose**: Bash interactive shell configuration  
**Deployed to**: `~/.bashrc`

**Features:**
- SSH agent auto-start
- Aliases for common commands
- Git-aware prompt
- Custom functions
- Path modifications

### config/bash/bash_profile
**Purpose**: Bash login shell entry point  
**Deployed to**: `~/.bash_profile`

**Features:**
- Sources `~/.bashrc`
- Login shell initialization

## Test Files

### ansible/tests/test.yml
**Purpose**: Main test suite runner  
**Tests**: All roles via included test files  
**Usage**: `ansible-playbook tests/test.yml`

**Includes:**
- `test_distro_facts.yml`
- `test_packages_base.yml`
- `test_packages_dev.yml`
- `test_nvim.yml`
- `test_fish.yml`
- `test_bash.yml`
- `test_fonts.yml`
- `test_desktop.yml`

### ansible/tests/test_distro_facts.yml
**Purpose**: Test distribution detection  
**Tests**:
- Distribution ID detected
- Package manager valid
- Ubuntu version set (if Ubuntu)
- All variables defined

### ansible/tests/test_packages_base.yml
**Purpose**: Test base packages role  
**Tests**:
- Base package definitions exist for all package managers
- Package resolution works
- Ubuntu version filtering works (lazygit on Ubuntu < 26.04)

### ansible/tests/test_packages_dev.yml
**Purpose**: Test dev packages role  
**Tests**:
- Dev package definitions exist
- Default dev languages defined
- Package resolution works
- Custom dev languages work correctly

### ansible/tests/test_nvim.yml
**Purpose**: Test Neovim role  
**Tests**:
- Source config directory exists
- `init.lua` exists in source
- Role runs successfully in check mode
- Target paths defined
- Backup suffix configured

### ansible/tests/test_fish.yml
**Purpose**: Test fish role  
**Tests**:
- Source config directory exists
- `config.fish` exists
- `conf.d/` directory exists
- Target paths defined
- Backup suffix configured

### ansible/tests/test_bash.yml
**Purpose**: Test bash role  
**Tests**:
- Source config directory exists
- `bashrc` exists
- `bash_profile` exists
- Target paths defined

### ansible/tests/test_fonts.yml
**Purpose**: Test fonts role  
**Tests**:
- Font URL is valid HTTPS URL
- Font directory defined
- Archive path defined

### ansible/tests/test_desktop.yml
**Purpose**: Test desktop role  
**Tests**:
- GNOME settings variables defined
- gsettings availability checked
- Role runs in check mode (if GNOME available)

### ansible/tests/run_tests.sh
**Purpose**: Shell wrapper to run test suite  
**Usage**: `./tests/run_tests.sh`  
**Executable**: Yes (chmod +x)

## Configuration Files

### ansible/ansible.cfg
**Purpose**: Ansible configuration for the project  
**Location**: `ansible/ansible.cfg`

**Settings:**
- `inventory`: Points to `inventories/localhost.yml`
- `roles_path`: Points to `roles/`
- `interpreter_python`: Auto-detect Python
- `host_key_checking`: Disabled
- `stdout_callback`: YAML format for better output
- `retry_files_enabled`: Disabled
- `deprecation_warnings`: Disabled
- `forks`: 1 (single-threaded execution)

### ansible/inventories/localhost.yml
**Purpose**: Inventory file for local execution  
**Location**: `ansible/inventories/localhost.yml`

**Content:**
```yaml
all:
  hosts:
    localhost:
      ansible_connection: local
```

### ansible/group_vars/all.yml
**Purpose**: Global variables for all hosts  
**Location**: `ansible/group_vars/all.yml`

**Variables:**
- Dev languages list (default empty)
- Force distro (default empty)
- Target user/home (defaults set at runtime)
- Repo root (default empty, set in playbook)
- Log file (currently unused)
- Supported package managers list

**Note**: No installation flags - component selection is controlled by tags.

## Documentation Files

### README.md
**Purpose**: Main user-facing documentation  
**Audience**: End users  
**Content**:
- Quick start guide
- Feature overview
- Usage examples
- Configuration reference
- Troubleshooting

### ansible/README.md
**Purpose**: Quick Ansible reference  
**Audience**: Developers and operators  
**Content**:
- Common commands
- Directory structure
- Variable reference
- Examples
- Troubleshooting

### docs/MANUAL.md
**Purpose**: Detailed technical manual  
**Audience**: Developers and maintainers  
**Content**:
- Architecture details
- Role execution flow
- Adding distributions
- Testing strategy
- Advanced customization
- Security considerations

### docs/FILEMAP.md
**Purpose**: File reference documentation (this file)  
**Audience**: Developers  
**Content**:
- File locations
- File purposes
- Usage instructions
- Exit codes

### AGENTS.md
**Purpose**: AI agent instructions  
**Audience**: AI coding assistants  
**Content**:
- Build/test commands
- Code style guidelines
- Git workflow rules

### CHANGELOG.md
**Purpose**: Version history and changes  
**Audience**: All users  
**Content**:
- Version releases
- Added features
- Changed functionality
- Bug fixes

## Directory Structure

```
linux-setup/
├── ansible/
│   ├── ansible.cfg              # Ansible configuration
│   ├── group_vars/              # Global variables
│   │   └── all.yml              # All hosts variables
│   ├── inventories/             # Inventory files
│   │   └── localhost.yml        # Local host inventory
│   ├── playbooks/               # Playbooks
│   │   ├── site.yml             # Main playbook
│   │   └── detect.yml           # Detection playbook
│   ├── roles/                   # Ansible roles
│   │   ├── distro_facts/        # Distribution detection
│   │   ├── packages_base/       # Base package installation
│   │   ├── packages_dev/        # Dev tools installation
│   │   ├── nvim/                # Neovim configuration
│   │   ├── fonts/               # Font installation
│   │   ├── fish/                # Fish shell
│   │   ├── bash/                # Bash configuration
│   │   └── desktop/             # Desktop settings
│   ├── tests/                   # Test suite
│   │   ├── test.yml             # Main test runner
│   │   ├── test_*.yml           # Individual role tests
│   │   └── run_tests.sh         # Test runner script
│   └── README.md                # Ansible quick reference
├── config/                      # Source configurations
│   ├── nvim/                    # Neovim config files
│   │   └── init.lua             # Neovim configuration
│   ├── fish/                    # Fish config files
│   │   ├── config.fish          # Main fish config
│   │   └── conf.d/              # Fish config.d directory
│   │       └── ssh_agent.fish   # SSH agent startup
│   └── bash/                    # Bash config files
│       ├── bashrc               # Bash interactive config
│       └── bash_profile         # Bash login config
├── docs/                        # Documentation
│   ├── MANUAL.md                # Detailed manual
│   └── FILEMAP.md               # This file
├── .github/                     # GitHub configuration
│   └── workflows/               # GitHub Actions
│       └── release.yml          # Release workflow
├── AGENTS.md                    # AI agent instructions
├── CHANGELOG.md                 # Version history
└── README.md                    # Main documentation
```

## Variable Flow

### Execution Flow

```
1. User runs: ansible-playbook playbooks/site.yml --tags <tags>
2. Ansible loads group_vars/all.yml
3. Playbook sets default variables (site.yml vars section)
4. distro_facts role detects distribution
5. Other roles use detected facts
6. Roles set role-specific facts
7. Tasks execute based on tags and conditions
```

### Variable Precedence (lowest to highest)

1. Role defaults (`roles/*/defaults/main.yml`)
2. Group vars (`group_vars/all.yml`)
3. Playbook vars (`playbooks/site.yml` vars section)
4. Extra vars (command line `-e`)

### Common Variable Overrides

```bash
# Override target user
-e linux_setup_target_user=myuser

# Override target home
-e linux_setup_target_home=/home/myuser

# Force distribution
-e linux_setup_force_distro=ubuntu

# Custom dev languages
-e linux_setup_dev_languages=go,python

# Override repo root
-e linux_setup_repo_root=/path/to/repo
```

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | General failure |
| 2 | Ansible syntax error |
| 4 | Unreachable host |
| 8 | Task failed |

## File Permissions

| File Type | Permission | Owner | Group |
|-----------|-----------|-------|-------|
| Directories | 0755 | target_user | target_user |
| Config files | 0644 | target_user | target_user |
| Shell scripts | 0755 | target_user | target_user |
| Ansible files | 0644 | repo owner | repo owner |

## Backup Naming

| Component | Backup Pattern |
|-----------|---------------|
| Neovim | `~/.config/nvim.backup.<epoch>` |
| Fish | `~/.config/fish.backup.<epoch>` |
| Bashrc | `~/.bashrc~` (Ansible automatic) |
| Bash profile | `~/.bash_profile~` (Ansible automatic) |

Where `<epoch>` is Unix timestamp at backup time.
