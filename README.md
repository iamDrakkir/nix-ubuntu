# Nix Ubuntu Configuration

Structured Nix configuration for managing system and user environments on Ubuntu with Nix.

## Features

- **Modular Design**: System, home, and desktop configurations are separated
- **Easy Maintenance**: Update specific parts without touching others
- **Multiple Desktop Environments**: Hyprland and GNOME with extensions
- **Declarative Dotfiles**: Managed symlinks to external dotfiles repository

## Directory Structure

See [STRUCTURE.md](STRUCTURE.md) for detailed directory layout.

```
nix-ubuntu/
├── flake.nix                # Main flake configuration
├── home.nix                 # Home Manager entry point
└── modules/
    ├── system/              # System-level (system-manager)
    ├── home/                # User-level (home-manager)
    │   ├── cli.nix         # CLI tools
    │   ├── gui.nix         # GUI applications
    │   └── dotfiles.nix    # Dotfile symlinks
    └── desktop/             # Desktop environments
        ├── hyprland/       # Hyprland compositor
        └── gnome/          # GNOME + extensions
```

## Installation

### Initial Setup

```bash
# Install Nix
wget -qO- https://install.determinate.systems/nix | sh -s -- install --determinate

nix-shell -p git

# Clone repositories
git clone https://github.com/iamDrakkir/nix-ubuntu.git ~/.config/nix
git clone https://github.com/iamDrakkir/dotfiles ~/.dotfiles

# Initial system setup
sudo env "PATH=$PATH" nix run 'github:numtide/system-manager' -- switch --flake '.'

# Setup home-manager
nix shell github:nix-community/home-manager
home-manager switch --flake '/home/drakkir/.config/nix/'

# Setup flatpak
sudo env "PATH=$PATH" flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Configure AppArmor for bubblewrap
sudo sysctl -w kernel.apparmor_restrict_unprivileged_userns=0
```

## Usage

### Rebuild Configurations

```bash
# System configuration (requires sudo)
sudo env "PATH=$PATH" system-manager switch --flake '/home/drakkir/.config/nix/'

# Home configuration
home-manager switch --flake '/home/drakkir/.config/nix/'
```

### Test nix-system-graphics

```bash
# Test graphics
nix shell 'nixpkgs#mesa-demos' --command glxgears
```

## Desktop Environment Setup

The desktop session files for Hyprland and Niri are automatically created by home-manager in `~/.local/share/wayland-sessions/`. 

**Important:** GDM doesn't follow symlinks to the Nix store, so the session files need to be copied (not symlinked) to the system directory. After running `home-manager switch`, use the included helper script:

```bash
# Copy session files to system directory (required after home-manager switch)
install-wayland-sessions
```

This will copy the session files to `/usr/share/wayland-sessions/` where GDM can detect them. Sessions will appear in the login screen after logout or restart.

## Updates

```bash
# Update Nix itself
sudo -i nix upgrade-nix

# Update flake inputs
nix flake update --flake ~/.config/nix

# Rebuild with updates
home-manager switch --flake ~/.config/nix
sudo env "PATH=$PATH" system-manager switch --flake ~/.config/nix

# Upgrade Nix daemon
sudo determinate-nixd upgrade
```