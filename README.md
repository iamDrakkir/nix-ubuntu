# Nix Configuration

Structured Nix configuration for managing system and user environments on Ubuntu using system-manager and home-manager.

Inspired by [EmergentMind's nix-config](https://github.com/EmergentMind/nix-config) 

## Features

- **Multi-host Support**: Separate configurations for terra, bigbox, and work with auto-detection
- **Multiple Desktop Environments**: GNOME (with Pop Shell), Hyprland, and Niri
- **Toggleable Features**: Enable/disable desktops and features via configuration flags
- **Declarative Dotfiles**: Managed symlinks to external dotfiles repository
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
```


### Building for Specific Users

```bash
just home  # Auto-detects current user and hostname
```

The `just` commands automatically detect the current `$USER` and hostname, so they work seamlessly regardless of which user you're logged in as.

## Installation

### Initial Setup

```bash
# Install Nix with Determinate Systems installer
wget -qO- https://install.determinate.systems/nix | sh -s -- install --determinate

# Install git in temporary shell for cloning
nix-shell -p git

# Clone repositories
git clone https://github.com/iamDrakkir/nix-config.git ~/.config/nix
git clone https://github.com/iamDrakkir/dotfiles ~/.dotfiles

# Initial system setup (installs system packages and services)
cd ~/.config/nix
sudo env "PATH=$PATH" nix run 'github:numtide/system-manager' -- switch --flake .#terra

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

The `just` commands automatically detect your hostname and username, so you don't need to specify them manually.

### Shell Aliases

Convenient shell aliases are also available after home-manager setup:

```bash
# Quick rebuild commands (auto-detect hostname)
hm-switch          # Home-manager switch
sys-switch         # System-manager switch (requires sudo)
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

## Acknowledgements

- [EmergentMind's nix-config](https://github.com/EmergentMind/nix-config) - Structure inspiration