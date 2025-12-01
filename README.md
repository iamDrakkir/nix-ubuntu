
# Collection of commands
wget -qO- https://install.determinate.systems/nix | sh -s -- install --determinate

nix-shell -p git

git clone https://github.com/iamDrakkir/nix-ubuntu.git ~/.config/nix

git clone https://github.com/iamDrakkir/dotfiles ~/.dotfiles

sudo env "PATH=$PATH" nix run 'github:numtide/system-manager' -- switch --flake '.'

sudo env "PATH=$PATH" system-manager switch --flake '/home/drakkir/.config/nix/'

nix shell 'nixpkgs#mesa-demos' --command glxgears

nix shell github:nix-community/home-manager

home-manager switch --flake '/home/drakkir/.config/nix/'

sudo env "PATH=$PATH" flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo


# desktop gnome login

```bash
sudo tee /usr/share/wayland-sessions/hyprland.desktop > /dev/null <<EOF
[Desktop Entry]
Name=Hyprland
Comment=An dynamic tiling Wayland compositor
Exec=/run/system-manager/sw/bin/Hyprland
Type=Application
EOF
```


```bash
sudo tee /usr/share/wayland-sessions/niri.desktop > /dev/null <<EOF
[Desktop Entry]
Name=Niri
Comment=An scrolling Wayland compositor
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
