# Nix Ubuntu Configuration

Structured Nix configuration for managing system and user environments on Ubuntu using system-manager and home-manager.

## Features

- **Multiple Desktop Environments**: GNOME (with Pop Shell), Hyprland, and Niri
- **Multi-Machine Support**: Hostname-based configurations for multiple machines
- **Multi-User Support**: Different users per machine (drakkir, rhaglin)
- **Toggleable Features**: Enable/disable desktops and features via configuration flags
- **Declarative Dotfiles**: Managed symlinks to external dotfiles repository
- **Automated Session Files**: Wayland sessions automatically install to system

## Directory Structure

```
nix-ubuntu/
├── flake.nix                # Main flake configuration
├── home.nix                 # Shared home configuration
├── hosts/                   # Per-machine configurations
│   ├── terra.nix           # Desktop 1 (drakkir)
│   ├── bigbox.nix          # Desktop 2 (drakkir)
│   └── work-laptop.nix     # Work laptop (rhaglin)
└── modules/
    ├── system/              # System-level (system-manager)
    │   └── default.nix     # System packages, services, Nix settings
    ├── home/                # User-level (home-manager)
    │   ├── profile-options.nix  # Profile option definitions
    │   ├── options.nix     # Feature toggles (gaming, development, desktop)
    │   ├── cli.nix         # CLI tools and shell configuration
    │   ├── gui.nix         # GUI applications
    │   ├── dotfiles.nix    # Dotfile symlinks
    │   ├── flatpak.nix     # Flatpak packages
    │   ├── sessions.nix    # Wayland session files (auto-installs)
    │   └── programs/       # Program-specific configs
    └── desktop/             # Desktop environments
        ├── gnome/          # GNOME + Pop Shell
        ├── hyprland/       # Hyprland compositor
        └── niri/           # Niri compositor
```

## Multi-Machine Setup

This configuration supports multiple machines with different hostnames and users:

| Machine | User | Type | Gaming | Desktops |
|---------|------|------|--------|----------|
| **terra** | drakkir | Desktop | ✅ | GNOME, Hyprland, Niri |
| **bigbox** | drakkir | Desktop | ✅ | GNOME, Hyprland, Niri |
| **work-laptop** | rhaglin | Laptop | ❌ | GNOME only |

### Configuring Hosts

Edit the host files in `hosts/` to match your machines. Each host controls:
- Git identity (name, email, GitHub username)
- Machine metadata (hostname, laptop vs desktop)
- **Desktop environments enabled** (GNOME, Hyprland, Niri)
- **Features enabled** (gaming, development)

**Example - Terra Desktop** (`hosts/terra.nix`):
```nix
{ ... }:
{
  profile = {
    name = "terra";
    git = {
      userName = "iamDrakkir";
      userEmail = "Hagelin.Rickard@gmail.com";
      githubUsername = "iamDrakkir";
    };
    machine = {
      hostname = "terra";
      isLaptop = false;  # Desktop
    };
  };

  # Desktop environments
  myConfig.desktop = {
    gnome.enable = true;
    hyprland.enable = true;
    niri.enable = true;
  };

  # Features
  myConfig.features = {
    gaming.enable = true;
    development.enable = true;
  };
}
```

**Example - Work Laptop** (`hosts/work-laptop.nix`):
```nix
{ ... }:
{
  profile = {
    name = "work-laptop";
    git = {
      userName = "Rickard Hagelin";
      userEmail = "rhaglin@work-company.com";
      githubUsername = "rhaglin";
    };
    machine = {
      hostname = "work-laptop";
      isLaptop = true;
    };
  };

  # Desktop environments (minimal for work)
  myConfig.desktop = {
    gnome.enable = true;
    hyprland.enable = false;
    niri.enable = false;
  };

  # Features (no gaming at work)
  myConfig.features = {
    gaming.enable = false;
    development.enable = true;
  };
}
```

## Configuration Options

Desktop environments and features are configured per-host.
Available options:

Desktop environments and features are now configured per-profile (see above).
Available options:

```nix
# Desktop environments
myConfig.desktop = {
  gnome.enable = true;      # GNOME with Pop Shell
  hyprland.enable = true;   # Hyprland compositor
  niri.enable = true;       # Niri compositor
};

# Optional features
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

# Setup home environment (use user@hostname format)
nix shell github:nix-community/home-manager

# On Terra:
home-manager switch --flake ~/.config/nix#drakkir@terra

# On bigbox:
# home-manager switch --flake ~/.config/nix#drakkir@bigbox

# On work laptop:
# home-manager switch --flake ~/.config/nix#rhaglin@work-laptop

# Setup flatpak remote
sudo env "PATH=$PATH" flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Configure AppArmor for bubblewrap (required for some sandboxed apps)
sudo sysctl -w kernel.apparmor_restrict_unprivileged_userns=0

# Note: Wayland session files (Hyprland, Niri) are now automatically installed!
# They will be copied to /usr/share/wayland-sessions/ during home-manager switch.
# You may be prompted for your sudo password during the switch.
```

## Usage

### Daily Commands

```bash
# Update home configuration (use your machine's user@hostname)
# On Terra:
home-manager switch --flake ~/.config/nix#drakkir@terra

# On bigbox:
home-manager switch --flake ~/.config/nix#drakkir@bigbox

# On work laptop:
home-manager switch --flake ~/.config/nix#rhaglin@work-laptop

# Auto-detect (if hostname is set correctly):
home-manager switch --flake ~/.config/nix#$(whoami)@$(hostname)

# Update system configuration (requires sudo, for system services/packages)
cd ~/.config/nix
sudo env "PATH=$PATH" system-manager switch --flake .

# Format Nix files
nix fmt

# Check for errors
nix flake check
```

### Desktop Environment Setup

Desktop session files for Hyprland and Niri are **automatically installed** during `home-manager switch`. The activation script will:
1. Create session files in `~/.local/share/wayland-sessions/`
2. Automatically copy them to `/usr/share/wayland-sessions/` (requires sudo)
3. Make them available in GDM login screen

**Important:** You may be prompted for your sudo password during `home-manager switch` to copy the session files.

If automatic installation fails, you can manually run:
```bash
install-wayland-sessions
```

Sessions will appear in the login screen after logout or restart.

## Updates

```bash
# Update all flake inputs
nix flake update --flake ~/.config/nix

# Rebuild after updates (use your machine's user@hostname)
home-manager switch --flake ~/.config/nix#$(whoami)@$(hostname)
cd ~/.config/nix && sudo env "PATH=$PATH" system-manager switch --flake .

# Update Nix itself
sudo -i nix upgrade-nix

# Upgrade Nix daemon
sudo determinate-nixd upgrade
```