
# Collection of commands
curl -fsSL https://install.determinate.systems/nix | sh -s -- install --determinate
wget -qO- https://install.determinate.systems/nix | sh -s -- install --determinate

sudo env "PATH=$PATH" nix run 'github:numtide/system-manager' -- switch --flake '.'
sudo env "PATH=$PATH" system-manager switch --flake '/home/drakkir/.config/nix/'

nix shell 'nixpkgs#mesa-demos' --command glxgears

nix shell github:nix-community/home-manager
home-manager switch --flake '/home/drakkir/.config/nix/'


# desktop gnome login

```bash
sudo tee /usr/share/wayland-sessions/hyprland.desktop > /dev/null <<EOF
[Desktop Entry]
Name=Hyprland
Comment=An intelligent dynamic tiling Wayland compositor
Exec=/run/system-manager/sw/bin/Hyprland
Type=Application
EOF
```


## Update Nix, Home Manager and Hyprland

To update everything you need the following commands.

```bash
# Update nix
$ sudo -i nix upgrade-nix
# Update Home Manager & Hyprland lock file
$ nix flake update --flake ~/.config/nix
# Upgrade Home Manager & Hyprland
$ home-manager switch --flake ~/.config/nix
```
