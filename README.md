# Nix Configuration

Structured Nix configuration for managing system and user environments across multiple machines. Ubuntu/non-NixOS hosts use system-manager + home-manager; NixOS hosts (e.g. Raspberry Pi) use a full NixOS configuration with home-manager as a module.

Inspired by [EmergentMind's nix-config](https://github.com/EmergentMind/nix-config)

## Hosts

| Host | OS | Architecture | Role |
|------|----|--------------|------|
| `terra` | Ubuntu | x86_64 | Desktop — GNOME + Niri |
| `bigbox` | Ubuntu | x86_64 | Desktop — GNOME + Hyprland + Niri |
| `work` | Ubuntu | x86_64 | Work laptop — GNOME |
| `pi` | NixOS | aarch64 | Raspberry Pi 4/5 — headless server |

## Features

- **Multi-host Support**: Separate configurations per host with auto-detection via `just`
- **Dual-mode system management**: system-manager on Ubuntu; native NixOS on the Pi
- **Multiple Desktop Environments**: GNOME, Hyprland, and Niri (desktop hosts only)
- **Declarative Dotfiles**: Managed via out-of-store symlinks to in-repo dotfiles
- **Core vs Optional Philosophy**: Strict separation between always-present and optional configs

## Structure

```
hosts/                   # System-level configurations
├── common/
│   ├── core/            # Always present on ALL system-manager hosts
│   ├── optional/        # Optional system configs (flatpak, corectrl)
│   └── users/           # User definitions for system-manager hosts
│       └── drakkir/
├── terra/               # Ubuntu desktop
├── bigbox/              # Ubuntu desktop
├── work/                # Ubuntu work laptop
└── pi/                  # NixOS Raspberry Pi 4/5 (aarch64)

home/                    # Home-manager configurations
├── common/
│   ├── core/            # Always present on ALL users/hosts
│   └── optional/        # Optional user configs
│       ├── desktops/    # Desktop environment configs (gnome, hyprland, niri)
│       ├── programs/    # Program-specific configs
│       └── tools/       # Tool configs (1password, vscode, etc.)
├── drakkir/
│   ├── terra.nix        # Desktops + dev + gaming
│   ├── bigbox.nix       # Desktops + dev + gaming + all programs
│   ├── pi.nix           # Minimal headless: shell + dev tools
│   └── common/          # Shared identity (git, ssh)
└── rhagelin/
    ├── work.nix
    └── common/

lib/                     # Custom library functions
overlays/                # Package overrides
pkgs/                    # Custom packages
dotfiles/                # Application dotfiles (symlinked to ~/.config)
```


### Building for Specific Users

```bash
just home  # Auto-detects current user and hostname
```

The `just` commands automatically detect the current hostname and derive the flake user from the login name. Domain-qualified usernames such as `user@example.com` are normalized to `user` for flake selection.

## Installation

### Ubuntu / non-NixOS hosts (terra, bigbox, work)

```bash
# Install Nix with Determinate Systems installer
wget -qO- https://install.determinate.systems/nix | sh -s -- install --determinate

# Install git in temporary shell for cloning
nix-shell -p git

# Clone repository
git clone https://github.com/iamDrakkir/nix-config.git ~/.config/nix

# Initial system setup (installs system packages and services)
nix run 'github:numtide/system-manager' -- switch --sudo --flake ~/.config/nix#terra

# Setup home environment for your host
nix shell github:nix-community/home-manager
home-manager switch --flake ~/.config/nix#drakkir@terra

# After this, 'just' commands and shell aliases will be available!

# Setup flatpak remote
sudo env "PATH=$PATH" flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Configure AppArmor for bubblewrap (required for some sandboxed apps)
sudo sysctl -w kernel.apparmor_restrict_unprivileged_userns=0
```

### NixOS hosts (pi)

The Pi uses a full NixOS configuration. Build the SD card image from any x86_64 machine with cross-compilation (or natively on another aarch64 machine):

```bash
# Build the SD card image
nix build .#nixosConfigurations.pi.config.system.build.sdImage

# Flash to SD card (replace /dev/sdX with your card)
zstdcat result/sd-image/*.img.zst | sudo dd of=/dev/sdX bs=4M status=progress
```

On first boot, add your SSH public key to `hosts/pi/default.nix` under `openssh.authorizedKeys.keys` before building the image. Once the Pi is running, rebuild from the Pi itself:

```bash
just nixos  # or: sudo nixos-rebuild switch --flake ~/.config/nix#pi
```

## Usage

### Quick Commands with Just

After the initial setup, you can use the included [just](https://github.com/casey/just) task runner for convenient commands:

```bash
# Show all available commands
just --list

# Frequently used commands:
just home          # Rebuild home-manager (auto-detects user@hostname)
just system        # Rebuild system-manager (Ubuntu hosts only)
just nixos         # Rebuild NixOS (pi and other NixOS hosts)
just rebuild       # Full rebuild — dispatches to nixos or system automatically
just update        # Update flake inputs
just clean-all     # Full cleanup (careful!)
```

The `just` commands automatically detect your hostname and derive the flake user from your login name, so you don't need to specify them manually. On NixOS hosts `just rebuild` runs `nixos-rebuild`; on Ubuntu hosts it runs system-manager.

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

### Customising a Host

Each host config (e.g. `home/drakkir/terra.nix`) controls which optional modules are imported. Add or remove imports to enable/disable features:

```nix
imports = [
  ../common/core          # Always included

  # Desktops (pick what you need)
  ../common/optional/desktops/gnome
  ../common/optional/desktops/hyprland
  ../common/optional/desktops/niri

  # Features
  ../common/optional/development.nix
  ../common/optional/gaming.nix

  # Programs
  ../common/optional/programs/zen-browser.nix
];
```

### Adding a New Host

#### Ubuntu / non-NixOS host

1. Create system config: `hosts/newhost/default.nix`
2. Create home config: `home/drakkir/newhost.nix`
3. Register in `flake.nix`:
   ```nix
   systemConfigs.newhost = mkSystemConfig "newhost";
   homeConfigurations."drakkir@newhost" = mkHomeConfig { configUser = "drakkir"; hostname = "newhost"; };
   ```

#### NixOS host

1. Create system config: `hosts/newhost/default.nix`
2. Create home config: `home/drakkir/newhost.nix`
3. Register in `flake.nix`:
   ```nix
   nixosConfigurations.newhost = mkNixosConfig { hostname = "newhost"; configUser = "drakkir"; };
   ```
   Pass `sys = "x86_64-linux"` if it's not an aarch64 machine.

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