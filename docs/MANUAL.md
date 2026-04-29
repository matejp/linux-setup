# Detailed Manual

## Architecture

The setup system uses pure Ansible with playbooks and roles:

```
┌─────────────────────────────────────────┐
│         ansible-playbook (CLI)          │
│     User runs with tags and variables    │
├─────────────────────────────────────────┤
│            ansible/playbooks            │
│      site.yml (orchestrator), detect.yml │
├─────────────────────────────────────────┤
│              ansible/roles              │
│ distro_facts, packages, fish, bash, nvim │
│ fonts, desktop                           │
├─────────────────────────────────────────┤
│              config/*                    │
│    Source configuration for deployments  │
└─────────────────────────────────────────┘
```

## Distribution Detection Flow

```
1. User runs: ansible-playbook playbooks/site.yml --tags <tags>
2. site.yml runs distro_facts role (always)
3. distro_facts reads Ansible distribution facts
4. The role normalizes distribution and maps package manager
5. Facts are exposed to all subsequent roles
6. Package selections are resolved per manager
```

## Package Installation Flow

```
1. packages_base role (--tags base):
   a. Selects packages from linux_setup_base_packages[package_manager]
   b. Applies version filtering (e.g., Ubuntu < 26.04 excludes lazygit)
   c. Installs with Ansible package module

2. packages_dev role (--tags dev):
   a. Resolves dev languages (default: go, c, python)
   b. Selects packages from linux_setup_dev_packages[package_manager][language]
   c. Deduplicates and installs with Ansible package module
```

## Role Execution Flow

Roles execute based on tags:

| Role | Tag | When | Description |
|------|-----|------|-------------|
| `distro_facts` | always | Always | Detect distribution and package manager |
| `packages_base` | base | Tagged | Install base packages |
| `packages_dev` | dev | Tagged | Install dev tools |
| `nvim` | nvim | Tagged | Deploy Neovim config |
| `fonts` | font | Tagged + not check_mode | Install fonts |
| `fish` | fish | Tagged + not check_mode | Install/configure fish |
| `bash` | bash | Tagged | Deploy bash config |
| `desktop` | desktop | Tagged | Apply GNOME settings |

## Nvim Configuration Notes

This repository ships a minimal, plugin-free Neovim configuration at `config/nvim/init.lua`.

### Adding New Config Files

If you add new Neovim config files:

1. Place them in `config/nvim/`
2. Update `ansible/roles/nvim/tasks/main.yml` if deployment logic changes
3. The entire `config/nvim/` directory is copied to `~/.config/nvim/`

### Neovim Deployment Process

```
1. Check if ~/.config/nvim exists
2. If exists and no backup, move to ~/.config/nvim.backup.<timestamp>
3. Copy config/nvim/ → ~/.config/nvim/
4. Verify init.lua exists
5. Check nvim --version (if not in check mode)
```

## Fish Shell Configuration

### Deployment Process

```
1. Install fish package via package manager
2. Locate fish binary (command -v fish)
3. Register in /etc/shells if not present
4. Backup existing ~/.config/fish if exists
5. Copy config/fish/ → ~/.config/fish/
6. Set fish as default shell (chsh)
```

### Fish Config Structure

- `config/fish/config.fish` - Main configuration
- `config/fish/conf.d/ssh_agent.fish` - SSH agent auto-start

## Bash Configuration

### Deployment Process

```
1. Backup existing ~/.bashrc (automatic via copy module)
2. Copy config/bash/bashrc → ~/.bashrc
3. Backup existing ~/.bash_profile (automatic)
4. Copy config/bash/bash_profile → ~/.bash_profile
```

### Bash Features

**~/.bashrc:**
- SSH agent auto-start
- Aliases for common commands
- Git-aware prompt
- Custom functions

**~/.bash_profile:**
- Sources ~/.bashrc
- Login shell entry point

## Font Installation

### Process

```
1. Install unzip package (required)
2. Ensure ~/.local/share/fonts exists
3. Check if fonts already installed (*.ttf, *.otf)
4. If no fonts:
   a. Download JetBrains Mono Nerd Font archive
   b. Extract to ~/.local/share/fonts
   c. Remove temporary archive
   d. Trigger font cache refresh (handler)
```

### Font Cache Handler

The fonts role includes a handler that refreshes the font cache:
```yaml
- name: Refresh font cache
  command: fc-cache -f
```

## Desktop Settings

Currently applies GNOME settings (if gsettings available):

```
1. Check if gsettings command exists
2. If exists, apply settings:
   - dash-to-dock click-action: minimize
```

### Adding More Desktop Settings

Edit `ansible/roles/desktop/tasks/main.yml`:

```yaml
- name: Apply new setting
  ansible.builtin.command:
    cmd: gsettings set <schema> <key> '<value>'
  when: linux_setup_gsettings_cmd.rc == 0
```

## Adding a New Distribution

### Step 1: Add Distribution Mapping

Edit `ansible/roles/distro_facts/defaults/main.yml`:

```yaml
linux_setup_distro_id_map:
  debian: debian
  ubuntu: ubuntu
  pop: ubuntu          # Pop!_OS uses Ubuntu packages
  fedora: fedora
  rocky: rhel
  centos: rhel
  opensuse: opensuse
  arch: arch
  manjaro: arch        # Manjaro uses Arch packages
  your_distro: your_normalized_id  # Add here
```

### Step 2: Add Package Manager Mapping

In the same file:

```yaml
linux_setup_pkg_mgr_map:
  ubuntu: apt
  debian: apt
  fedora: dnf
  rhel: dnf
  opensuse: zypper
  arch: pacman
  your_normalized_id: your_package_manager  # Add here
```

### Step 3: Add Package Lists

Edit `ansible/roles/packages/defaults/main.yml`:

```yaml
linux_setup_base_packages:
  apt: [...]
  dnf: [...]
  zypper: [...]
  pacman: [...]
  your_package_manager:  # Add here
    - htop
    - git
    - neovim
    # ... etc
```

Add dev packages too:

```yaml
linux_setup_dev_packages:
  your_package_manager:
    go:
      - golang
    c:
      - gcc
      - make
    python:
      - python3
      - python3-pip
```

### Step 4: Test

```bash
cd ansible

# Test detection
ansible-playbook playbooks/detect.yml

# Test in check mode
ansible-playbook playbooks/site.yml --tags all --check
```

## Testing Strategy

### Ansible Role Tests

Run comprehensive tests that verify all roles:

```bash
cd ansible

# Run all tests
ansible-playbook tests/test.yml

# Run specific role test
ansible-playbook tests/test.yml --tags distro_facts
ansible-playbook tests/test.yml --tags packages
ansible-playbook tests/test.yml --tags nvim
```

### What Tests Verify

| Test | Verifies |
|------|----------|
| `test_distro_facts.yml` | Distribution detected, package manager mapped, Ubuntu version set |
| `test_packages.yml` | Package definitions exist, lists valid, version filtering works |
| `test_nvim.yml` | Source config exists, init.lua present, role runs in check mode |
| `test_fish.yml` | Source config exists, config.fish present, paths defined |
| `test_bash.yml` | Source files exist, bashrc and bash_profile present |
| `test_fonts.yml` | Font URL valid, paths defined |
| `test_desktop.yml` | Variables defined, gsettings availability checked |

### Dry-Run Testing

Test without making changes:

```bash
# Test full installation
ansible-playbook playbooks/site.yml --tags all --check

# Test specific component
ansible-playbook playbooks/site.yml --tags nvim --check
```

### Syntax Validation

```bash
# Check playbook syntax
ansible-playbook playbooks/site.yml --syntax-check

# Lint with ansible-lint
ansible-lint playbooks/*.yml roles/*/tasks/*.yml

# Validate YAML
yamllint ansible/**/*.yml
```

### Adding New Tests

When you add a new role:

1. Create `ansible/tests/test_<role>.yml`
2. Include it in `ansible/tests/test.yml`
3. Test structure:

```yaml
---
- name: Load role defaults
  ansible.builtin.include_vars:
    file: "{{ playbook_dir }}/../roles/<role>/defaults/main.yml"

- name: Verify config files exist
  ansible.builtin.stat:
    path: "{{ source_path }}"
  register: result
  failed_when: not result.stat.exists

- name: Test role in check mode
  ansible.builtin.include_role:
    name: <role>
  check_mode: true

- name: Assert expected results
  ansible.builtin.assert:
    that:
      - condition1
      - condition2
    fail_msg: "Test failed"
    success_msg: "✓ Test passed"
```

## Configuration Locations

### Deployed Locations

| Component | Target Location | Backup Location |
|-----------|----------------|-----------------|
| Neovim config | `~/.config/nvim` | `~/.config/nvim.backup.<timestamp>` |
| Fish config | `~/.config/fish` | `~/.config/fish.backup.<timestamp>` |
| Bash config | `~/.bashrc`, `~/.bash_profile` | `~/.bashrc~`, `~/.bash_profile~` |
| Fonts | `~/.local/share/fonts` | N/A |

### Source Locations

| Component | Source Location |
|-----------|----------------|
| Neovim | `config/nvim/` |
| Fish | `config/fish/` |
| Bash | `config/bash/` |

## Variables Reference

### Global Variables

Defined in `ansible/group_vars/all.yml`:

```yaml
# Dev languages
linux_setup_dev_languages: []  # Empty by default, uses role defaults if not set

# Distribution override
linux_setup_force_distro: ""  # Override detection

# Target user/home
linux_setup_target_user: ""  # Defaults to current user
linux_setup_target_home: ""  # Defaults to current home

# Repository root
linux_setup_repo_root: ""  # Auto-detected in playbook

# Log file (currently unused)
linux_setup_log_file: ""

# Supported package managers
linux_setup_supported_package_managers:
  - apt
  - dnf
  - zypper
  - pacman
```

**Note**: Component installation is controlled by tags, not variables. Use `--tags <component>` to select what to install.

### Role-Specific Variables

Each role has defaults in `ansible/roles/<role>/defaults/main.yml`:

**nvim:**
```yaml
linux_setup_nvim_source: "{{ linux_setup_repo_root }}/config/nvim"
linux_setup_nvim_target: "{{ linux_setup_target_home }}/.config/nvim"
linux_setup_nvim_backup_suffix: ".backup.{{ ansible_date_time.epoch }}"
```

**fish:**
```yaml
linux_setup_fish_config_source: "{{ linux_setup_repo_root }}/config/fish"
linux_setup_fish_config_target: "{{ linux_setup_target_home }}/.config/fish"
linux_setup_fish_backup_suffix: ".backup.{{ ansible_date_time.epoch }}"
```

**bash:**
```yaml
linux_setup_bash_source_dir: "{{ linux_setup_repo_root }}/config/bash"
linux_setup_bashrc_target: "{{ linux_setup_target_home }}/.bashrc"
linux_setup_bash_profile_target: "{{ linux_setup_target_home }}/.bash_profile"
```

**fonts:**
```yaml
linux_setup_font_url: "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/JetBrainsMono.zip"
linux_setup_font_dir: "{{ linux_setup_target_home }}/.local/share/fonts"
linux_setup_font_archive: "/tmp/JetBrainsMono.zip"
```

## Security Considerations

1. **No Secrets**: No credentials, API keys, or secrets stored in repository
2. **File Permissions**: 
   - Directories: 0755
   - Config files: 0644
   - Scripts: 0755
3. **Backups**: Existing configurations backed up before overwriting
4. **Sudo Required**: Package installation requires elevated privileges (expected)
5. **Download Verification**: Downloads from official sources only
6. **Check Mode**: Test changes safely without modifying system

## Performance Notes

- **Check Mode**: Non-destructive, avoids package installation
- **Role Conditions**: Roles only execute when tagged or conditions met
- **Idempotency**: Safe to run multiple times, only changes what's needed
- **Parallel Execution**: Ansible executes tasks in parallel where possible
- **Font Installation**: Skips download if fonts already present

## Troubleshooting

### Ansible Not Found

Install ansible-core:
```bash
sudo apt install ansible-core  # Ubuntu/Debian
sudo dnf install ansible-core  # Fedora
sudo pacman -S ansible-core    # Arch
```

### Distribution Not Detected

Force distribution:
```bash
ansible-playbook playbooks/site.yml --tags all \
  -e linux_setup_force_distro=ubuntu
```

### Package Manager Not Supported

Add support by following "Adding a New Distribution" section above.

### Permission Denied

Add `--ask-become-pass` or configure passwordless sudo:
```bash
ansible-playbook playbooks/site.yml --tags all --ask-become-pass
```

### Role Not Running

1. Check tags: `--tags <tag>` must match role tag
2. Check conditions: Role may require specific conditions
3. Verbose mode: Add `-vvv` for debug output

### Config Not Deployed

1. Check target paths in role defaults
2. Verify source files exist: `ls -la config/<component>/`
3. Check role output: Add `-v` for verbose mode
4. Verify in check mode first: `--check`

## Best Practices

### Before Running

1. **Test in check mode first:**
   ```bash
   ansible-playbook playbooks/site.yml --tags all --check
   ```

2. **Review what will change:**
   ```bash
   ansible-playbook playbooks/site.yml --tags all --check -v
   ```

3. **Run tests:**
   ```bash
   ansible-playbook tests/test.yml
   ```

### When Modifying

1. **Edit role defaults** for configuration changes
2. **Update role tasks** for logic changes  
3. **Add tests** for new functionality
4. **Test in check mode** before applying
5. **Validate syntax:**
   ```bash
   ansible-playbook playbooks/site.yml --syntax-check
   ```

### After Changes

1. **Run tests:** `ansible-playbook tests/test.yml`
2. **Update documentation:** README.md, MANUAL.md
3. **Update CHANGELOG.md**
4. **Test on target distributions**

## Advanced Customization

### Custom Package Lists

Create a custom vars file:

```yaml
# custom-vars.yml
linux_setup_base_packages:
  apt:
    - my-custom-package
    - another-package
```

Apply it:
```bash
ansible-playbook playbooks/site.yml --tags base -e @custom-vars.yml
```

### Custom Target Locations

Override target paths:
```bash
ansible-playbook playbooks/site.yml --tags nvim \
  -e linux_setup_nvim_target=/custom/path/.config/nvim
```

### Custom Repository Location

If repository is not in default location:
```bash
ansible-playbook playbooks/site.yml --tags all \
  -e linux_setup_repo_root=/path/to/linux-setup
```

### Skip Specific Packages

Use package module skip lists (requires modifying role):

```yaml
# In roles/packages/tasks/main.yml
- name: Install base packages
  ansible.builtin.package:
    name: "{{ linux_setup_base_packages_resolved | difference(skip_packages | default([])) }}"
```

Then:
```bash
ansible-playbook playbooks/site.yml --tags base \
  -e skip_packages=['lazygit','btop']
```
