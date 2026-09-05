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
- **Hierarchical Keybindings**: One modifier per layer — Super desktop, Alt multiplexer, Ctrl application
- **Core vs Optional Philosophy**: Strict separation between always-present and optional configs

## Keybinding Philosophy

Every keyboard action belongs to the layer it controls, and the modifier says
which layer that is:

**Super = desktop, Alt = multiplexer, Ctrl = application.**

| Layer | Modifier family | Scope |
|-------|-----------------|-------|
| Window manager | `Super + Ctrl/Alt/Shift + x` | Desktop and window actions |
| tmux / Herdr | `Alt + Ctrl/Shift + x` | Multiplexer and pane actions |
| Active TUI/application | `Ctrl + x` | The focused terminal application |

Direction is always `h` left, `j` down, `k` up, `l` right — in every layer, in
every application.

- `Super + h/j/k/l`: focus a window
- `Super + Ctrl + h/j/k/l`: move a window
- `Super + Shift + h/j/k/l`: focus a monitor
- `Alt + h/j/k/l`: focus a tmux or Herdr pane
- `Alt + Shift + h/l`: previous / next tmux window or Herdr tab
- `Alt + Shift + j/k`: next / previous tmux session or Herdr workspace
- `Alt + Ctrl + Shift + h/j/k/l`: resize a tmux or Herdr pane
- `Ctrl + h/j/k/l`: navigate inside the active TUI/application

Each tier has the same shape: a plain direction moves within the current
container, and `Shift + direction` moves between containers. `Super + Shift`
cannot be reused inside tmux or Herdr, because the compositor consumes those
chords before any terminal application can see them.

### Adding a new binding

Direct chords are a finite resource: every `Alt + key` claimed here is one that
no TUI running inside the multiplexer can ever use. So the test is frequency,
not usefulness.

1. **Fundamental and frequent** — navigation, and creating, closing, moving or
   resizing panes and windows — earns a direct chord in its layer.
2. **Everything else** goes behind the prefix (`Ctrl+a` in tmux, `Ctrl+b` in
   Herdr), which costs one keystroke and no keyspace.
3. **Rare or system-wide** actions go in the `Super + Alt + Space` menu rather
   than claiming a chord at all.

Prefer widening an existing tier over inventing a new modifier combination. If
a binding does not fit the hierarchy, that is usually a sign it belongs in the
menu.

Niri, tmux, Herdr, and Neovim are configured to preserve this separation.

### Universal clipboard

`Super + C/V/X` copy, paste, and cut in **any** application, so the same chord
works in a terminal and in a GUI app. Rather than detecting the focused window,
these synthesise the legacy CUA chords `Ctrl+Insert` and `Shift+Insert`, which
both terminals and GTK/Qt apps honour. Keys are sent with `wtype`; niri has no
equivalent of Hyprland's `sendshortcut` action, so both compositors use the same
mechanism.

`Super + Shift + V` opens the clipboard history panel.

### Super + Ctrl utilities

Letters under `Super + Ctrl` open panels and toggles (directions in this tier
still move windows):

| Key | Action |
|-----|--------|
| `Super + Ctrl + A` | Audio controls |
| `Super + Ctrl + B` | Bluetooth controls |
| `Super + Ctrl + W` | Network / WiFi controls |
| `Super + Ctrl + N` | Toggle nightlight |
| `Super + Ctrl + Escape` | Lock session |

These are Control Center tabs in Noctalia, so they only exist when the Noctalia
module is enabled.

### System menu

`Super + Alt + Space` opens a nested system menu rendered by Noctalia's own
launcher (`noctalia dmenu`), covering Session, Nix, Toggles and Display. It is
the overflow valve for actions that are used too rarely to deserve a dedicated
chord — prefer adding entries here over claiming new key combinations.

### Workspaces

`Super + 1-9` switches workspace, `Super + Shift + 1-9` moves the focused column
to a workspace and follows it, and `Super + Shift + Alt + 1-9` moves it there
without following.

Inside tmux and Herdr the same numbers apply one tier down: `Alt + 1-9` selects
a tab or window, `Alt + Shift + 1-9` selects a Herdr workspace, and
`Ctrl + Alt + 1-9` jumps to a Herdr agent.

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
│   ├── core/            # Always present on ALL users/hosts (shell, git, dev, GUI)
│   └── optional/        # Optional user configs
│       ├── apps/        # Per-application configs (discord, tmux, vlc, ...)
│       └── desktops/    # Desktop environment configs (gnome, hyprland, niri)
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

### Core vs Optional

`core` is imported wholesale by every host of its class; `optional` modules are
listed individually by the hosts that want them. There is deliberately **no**
`optional/default.nix` — importing a directory evaluates its `default.nix`, which
would silently make every "optional" module mandatory.

The rule is simply: **if every host imports it, it belongs in `core`.** Don't keep
something optional for a machine that doesn't exist yet — move it back out when a
real host actually needs to opt out. Moving a module in either direction is a
one-line edit, so there's nothing to gain by guessing early.

The one standing exception is `desktops/`: which compositor a machine runs is a
per-host menu by nature, so those stay optional even when all current hosts happen
to import the same ones.

Two things to know when a non-Ubuntu host is added:

- `pam-shim.nix` is in `core` but redirects PAM to the host's system libpam, which
  is correct on Ubuntu and wrong on NixOS. It will need to move out — and it fails
  at runtime (lockscreen auth), not at eval, so it won't announce itself.
- `corectrl.nix` is AMD-only, which is why only `hosts/terra` imports it.


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
just check         # Evaluate every host config without activating anything
just fmt           # Format with pedantix (nixfmt + sorted attrs)
just update        # Update flake inputs
just clean-all     # Full cleanup (careful!)
```

The `just` commands automatically detect your hostname and derive the flake user from your login name, so you don't need to specify them manually. On NixOS hosts `just rebuild` runs `nixos-rebuild`; on Ubuntu hosts it runs system-manager.

`just check` runs `nix flake check`, which covers the home-manager and NixOS
configurations. The `systemConfigs` outputs are re-exported as flake `checks` in
`flake.nix` so the Ubuntu system level is verified by the same command — `nix flake
check` skips `systemConfigs` on its own.

### Shell Aliases

Convenient shell aliases are also available after home-manager setup:

```bash
# Quick rebuild commands (auto-detect hostname)
hms                # Home-manager switch
syss               # System-manager switch (uses --sudo flag)
nix-rebuild        # Both home and system
```

### Desktop Environment Setup

Session entries for Hyprland and Niri are installed into `/usr/share/wayland-sessions/`
by the `wayland-sessions-install` service (see `hosts/common/optional/wayland-sessions.nix`),
which runs on every system rebuild and at boot. GDM only reads that system
directory and won't follow symlinks into the Nix store, so the files are copied
there as real files — no manual step is needed anymore.

The entries launch `$HOME/.nix-profile/bin/{start-hyprland,niri-session}`, so each
user gets their own home-manager compositor build.

Sessions appear in the login screen after `just system` plus a logout or restart.

### CoreCtrl Setup (AMD GPU Control)

CoreCtrl is automatically installed and configured for password-less operation (for sudo group members).

The D-Bus and polkit files it needs are declared in `hosts/common/optional/corectrl.nix`. The bus configuration lives in `/etc/dbus-1/system.d/` (managed by system-manager), while the D-Bus activation files and polkit actions are symlinked into `/usr/share` with `systemd.tmpfiles` rules, because dbus and polkit only scan fixed directories under `/usr/share` for those. Everything is applied on system rebuild and at boot — there is no manual setup step.

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

### `git push` opens a Proton Pass login

SSH keys are served by the Proton Pass agent (`~/.ssh/config` points `IdentityAgent`
at it), and `pass-cli` keeps the key that decrypts its session in the *kernel*
keyring:

```bash
keyctl show @s   # user: keyring:cli-local-key:<fingerprint>@ProtonPassCLI
```

Kernel keyrings do not survive a reboot, so the agent starts empty once per boot.
Rather than failing the push with a credential error, `core.sshCommand` points at a
wrapper (`home/common/optional/apps/proton.nix`) that checks `ssh-add -l` and runs
`pass-cli login` first — on the terminal if there is one, otherwise in a new window.

To skip the login entirely, set `PROTON_PASS_KEY_PROVIDER=fs` so `pass-cli` persists
the key to `~/.local/share/proton-pass-cli/.session/local.key`. Note that the root
filesystem is not encrypted, so that file is then readable by anyone with the disk.

### Polkit prompts do not appear

Noctalia's polkit agent (`polkit_agent` in `dotfiles/noctalia/settings.toml`) is
linked against the Nix `libpolkit-agent-1`, which has the NixOS-only helper path
`/run/wrappers/bin/polkit-agent-helper-1` compiled in. On Ubuntu that path does not
exist, so authentication fails with "Not authorized".

`hosts/common/core/polkit-agent-helper.nix` symlinks it to the host's setuid helper
at `/usr/lib/polkit-1/polkit-agent-helper-1`. Verify with:

```bash
ls -l /run/wrappers/bin/polkit-agent-helper-1
SHELL=/bin/bash pkexec --disable-internal-agent true
```

(`SHELL` has to be overridden because the login shell is a Nix path and `pkexec`
rejects shells missing from `/etc/shells`.)

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
