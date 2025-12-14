# Nix Ubuntu Configuration

Structured Nix configuration for managing system and user environments on Ubuntu using system-manager and home-manager.

## Features

- **Multiple Desktop Environments**: GNOME (with Pop Shell), Hyprland, and Niri
- **Toggleable Features**: Enable/disable desktops and features via configuration flags
- **Declarative Dotfiles**: Managed symlinks to external dotfiles repository

## Directory Structure

```
nix-ubuntu/
├── flake.nix                # Main flake configuration
├── home.nix                 # Home Manager entry point
└── modules/
    ├── system/              # System-level (system-manager)
    │   └── default.nix     # System packages, services, Nix settings
    ├── home/                # User-level (home-manager)
    │   ├── options.nix     # Feature toggles (gaming, development, desktop)
    │   ├── cli.nix         # CLI tools and shell configuration
    │   ├── gui.nix         # GUI applications
    │   ├── dotfiles.nix    # Dotfile symlinks
    │   ├── flatpak.nix     # Flatpak packages
    │   ├── sessions.nix    # Wayland session files
    │   └── programs/       # Program-specific configs
    └── desktop/             # Desktop environments
        ├── gnome/          # GNOME + Pop Shell
        ├── hyprland/       # Hyprland compositor
        └── niri/           # Niri compositor
```

## Configuration Options

You can enable/disable features in `home.nix`:

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
  development.enable = true;
};
```

## Installation

### Initial Setup

```bash
# Install Nix with Determinate Systems installer
wget -qO- https://install.determinate.systems/nix | sh -s -- install --determinate

# Install git in temporary shell for cloning
nix-shell -p git

# Clone repositories
git clone https://github.com/iamDrakkir/nix-ubuntu.git ~/.config/nix
git clone https://github.com/iamDrakkir/dotfiles ~/.dotfiles

# Initial system setup (installs system packages and services)
sudo env "PATH=$PATH" nix run 'github:numtide/system-manager' -- switch --flake ~/.config/nix

# Setup home environment
nix shell github:nix-community/home-manager
home-manager switch --flake ~/.config/nix

# Setup flatpak remote
sudo env "PATH=$PATH" flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Configure AppArmor for bubblewrap (required for some sandboxed apps)
sudo sysctl -w kernel.apparmor_restrict_unprivileged_userns=0
```

## Usage

### Daily Commands

```bash
# Update home configuration (most common)
home-manager switch --flake ~/.config/nix

# Update system configuration (requires sudo, for system services/packages)
cd ~/.config/nix
sudo env "PATH=$PATH" system-manager switch --flake .

# Format Nix files
nix fmt

# Check for errors
nix flake check
```

### Desktop Environment Setup

Desktop session files for Hyprland and Niri are automatically created by home-manager in `~/.local/share/wayland-sessions/`. 

**Important:** GDM doesn't follow symlinks to the Nix store, so the session files need to be copied (not symlinked) to the system directory. After running `home-manager switch`, use the included helper script:

```bash
# Copy session files to system directory (makes them appear in GDM)
install-wayland-sessions
```

Sessions will appear in the login screen after logout or restart.

## Updates

```bash
# Update all flake inputs
nix flake update --flake ~/.config/nix

# Rebuild after updates
home-manager switch --flake ~/.config/nix
cd ~/.config/nix && sudo env "PATH=$PATH" system-manager switch --flake .

# Update Nix itself
sudo -i nix upgrade-nix

# Upgrade Nix daemon
sudo determinate-nixd upgrade
```