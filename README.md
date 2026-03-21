# Nix Configuration

Structured Nix configuration for managing system and user environments on Ubuntu using system-manager and home-manager.

Inspired by [EmergentMind's nix-config](https://github.com/EmergentMind/nix-config) 

## Features

- **Multi-host Support**: Separate configurations for terra, bigbox, and work with auto-detection
- **Multiple Desktop Environments**: GNOME (with Pop Shell), Hyprland, and Niri
- **Toggleable Features**: Enable/disable desktops and features via configuration flags
- **Declarative Dotfiles**: Managed via out-of-store symlinks to in-repo dotfiles
- **Core vs Optional Philosophy**: Strict separation between always-present and optional configs

## Structure

Following EmergentMind's organizational principles with adaptations for system-manager:

```
hosts/                   # System-level configurations (system-manager)
├── common/
│   ├── core/            # Always present on ALL hosts
│   ├── optional/        # Optional system configs
│   └── users/           # User definitions (EmergentMind pattern)
│       └── drakkir/     # drakkir user definition
│           ├── default.nix  # User creation, shell, groups
│           └── keys/        # SSH public keys
├── terra/               # Host-specific configs
└── work/

home/                    # Home-manager configurations
├── common/
│   ├── core/            # Always present on ALL users
│   └── optional/        # Optional user configs
│       ├── desktops/    # Desktop environment configs
│       └── programs/    # Program-specific configs
├── drakkir/             # User settings per machine
│   ├── terra.nix        # Host-specific user config for terra
│   ├── bigbox.nix       # Host-specific user config for bigbox
│   └── work.nix         # Host-specific user config for work

modules/                 # Custom modules
├── home-manager/        # Home-manager specific modules
│   └── options.nix      # Feature toggle options
├── system/              # System-manager specific modules (legacy)
└── common/              # Shared modules (future)

lib/                     # Custom library functions
overlays/                # Custom modifications to upstream packages 
pkgs/                    # Custom packages
scripts/                 # Helper scripts
dotfiles/                # Application dotfiles (symlinked to ~/.config)
```


### Building for Specific Users

```bash
just home  # Auto-detects current user and hostname
```

The `just` commands automatically detect the current hostname and derive the flake user from the login name. Domain-qualified usernames such as `user@example.com` are normalized to `user` for flake selection.

## Installation

### Initial Setup

```bash
# Install Nix with Determinate Systems installer
wget -qO- https://install.determinate.systems/nix | sh -s -- install --determinate

# Install git in temporary shell for cloning
nix-shell -p git

# Clone repository
git clone https://github.com/iamDrakkir/nix-config.git ~/.config/nix

# Initial system setup (installs system packages and services)
cd ~/.config/nix
nix run 'github:numtide/system-manager' -- switch --sudo --flake .#terra

# Setup home environment for your host
nix shell github:nix-community/home-manager
home-manager switch --flake ~/.config/nix#drakkir@terra

# After this, 'just' commands and shell aliases will be available!
# You can now use: just home, just system, hm-switch, etc.

# Setup flatpak remote
sudo env "PATH=$PATH" flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Configure AppArmor for bubblewrap (required for some sandboxed apps)
sudo sysctl -w kernel.apparmor_restrict_unprivileged_userns=0
```

## Usage

### Quick Commands with Just

After the initial setup, you can use the included [just](https://github.com/casey/just) task runner for convenient commands:

```bash
# Show all available commands
just --list

# freqeuntly used commands:
just home          # Rebuild home-manager (auto-detects user@hostname)
just system        # Rebuild system-manager (auto-detects hostname)
just rebuild       # Full rebuild (both home and system)
just update        # Update flake inputs
just clean-all     # Full cleanup (careful!)

```

The `just` commands automatically detect your hostname and derive the flake user from your login name, so you don't need to specify them manually.

### Shell Aliases

Convenient shell aliases are also available after home-manager setup:

```bash
# Quick rebuild commands (auto-detect hostname)
hms                # Home-manager switch
syss               # System-manager switch (uses --sudo flag)
nix-rebuild        # Both home and system
```

### Desktop Environment Setup

Desktop session files for Hyprland and Niri are automatically created by home-manager in `~/.local/share/wayland-sessions/`. 

**Important:** GDM doesn't follow symlinks to the Nix store, so the session files need to be copied (not symlinked) to the system directory. After running `home-manager switch`, use the included helper script:

```bash
# Copy session files to system directory (makes them appear in GDM)
install-wayland-sessions
```

Sessions will appear in the login screen after logout or restart.

### CoreCtrl Setup (AMD GPU Control)

CoreCtrl is automatically installed and configured for password-less operation (for sudo group members). The required D-Bus and polkit files are automatically installed during system rebuild.

**For full GPU control** (overclocking, custom power profiles, fan curves), add the AMD GPU kernel parameter to GRUB:

1. Edit `/etc/default/grub`
2. Find `GRUB_CMDLINE_LINUX_DEFAULT` and append `amdgpu.ppfeaturemask=0xffffffff`
   ```bash
   GRUB_CMDLINE_LINUX_DEFAULT="quiet splash amdgpu.ppfeaturemask=0xffffffff"
   ```
3. Update GRUB: `sudo update-grub`
4. Reboot

CoreCtrl will autostart with Hyprland and be available in the application launcher.

## Configuration

### Enabling/Disabling Features

Edit your host-specific file (e.g., `home/drakkir/terra.nix`):

```nix
# Enable desktop environments you want to use
myConfig.desktop = {
  gnome.enable = true;      # GNOME with Pop Shell
  hyprland.enable = true;   # Hyprland compositor
  niri.enable = true;       # Niri compositor
};

# Enable optional features
myConfig.features = {
  gaming.enable = true;     # Steam, Lutris
  development.enable = true; # Dev tools
};
```

### Adding a New Host

1. Create system config: `hosts/newhost/default.nix`
2. Create user config: `home/drakkir/newhost.nix`
3. Add to `flake.nix`:
   ```nix
   systemConfigs.newhost = mkSystemConfig "newhost";
   homeConfigurations."drakkir@newhost" = mkHomeConfig "newhost";
   ```

## Updates

```bash
just update

# Update Nix itself
sudo -i nix upgrade-nix

# Upgrade Nix daemon
sudo determinate-nixd upgrade
```

## Troubleshooting

### System-Manager Packages Not Available in Hyprland Autostart

If programs installed via system-manager's `environment.systemPackages` don't autostart in Hyprland or aren't visible in application launchers, ensure both of these are configured:

1. **PATH for systemd user session** - In `home/common/core/home.nix`, the `nix-setup-environment` service must include `/run/system-manager/sw/bin` in PATH:
   ```nix
   ExecStart = "systemctl --user set-environment PATH=/run/system-manager/sw/bin:${homeDirectory}/.nix-profile/bin:...";
   ```

2. **XDG_DATA_DIRS for desktop files** - In `home/common/optional/desktops/hyprland/default.nix`, add to the `env` array:
   ```nix
   env = [
     "XDG_DATA_DIRS,/run/system-manager/sw/share:$XDG_DATA_DIRS"
   ];
   ```

Additionally, system-manager must be configured to link share directories in `hosts/common/core/nix.nix`:
```nix
environment.pathsToLink = [ "/bin" "/share" ];
```

This ensures programs in `environment.systemPackages` are accessible to Hyprland's `exec-once` commands and visible in application launchers.

## Acknowledgements

- [EmergentMind's nix-config](https://github.com/EmergentMind/nix-config) - Structure inspiration