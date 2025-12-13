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

### Hyprland Session

```bash
sudo tee /usr/share/wayland-sessions/hyprland.desktop > /dev/null <<EOF
[Desktop Entry]
Name=Hyprland
Comment=An dynamic tiling Wayland compositor
Exec=/run/system-manager/sw/bin/Hyprland
Type=Application
EOF
```


### Niri Session

```bash
sudo tee /usr/share/wayland-sessions/niri.desktop > /dev/null <<EOF
[Desktop Entry]
Name=Niri
Comment=An scrolling Wayland compositor
Exec=/run/system-manager/sw/bin/Hyprland
Type=Application
EOF
```


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