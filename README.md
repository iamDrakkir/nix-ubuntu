
# Hyprland on Ubuntu 24.04

Hyprland is not available by default on Ubuntu 24.04 so instead we can utilize
the Nix package manager and Home Manager.

## Nix

The benefit of the Nix package manager compared to others in this case is that
the package **and dependencies** of Nix packages is immutable and self
contained. This means that the entire setup is contained to a separate `/nix`
path. Changes to Nix packages does not break Ubuntu and changes to Ubuntu does
not break Nix packages.

To install Nix we use the excellent Determinate Nix Installer from Determinate
Systems.

```sh
sudo apt-get install -y curl
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

With Nix installed you can run the following to make sure that everything is
working correctly.

```sh
# Should output Hello, world!
nix run 'nixpkgs#hello'
```

## Home Manager

In addition to Nix we will also be using Home Manager to have a declarative
system. With Home Manager we can specify everything we need in configuration
files and let it handle the setup and installation for us.

Before we install it we need to setup the configuration files in our home catalog.

```sh
mkdir -p ~/.config/home-manager
touch ~/.config/home-manager/flake.nix
touch ~/.config/home-manager/home.nix
```

`~/.config/home-manager/flake.nix`

Note: replace `drakkir` with your own username.

```nix
{
  description = "Home Manager Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixGL = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nixGL,
    ...
  }: {
    # Replace with your own username
    homeConfigurations."drakkir" = home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config = {
          allowUnfree = true;
          allowUnfreePredicate = _: true;
        };
      };
      extraSpecialArgs = {
        inherit nixGL;
      };
      modules = [./home.nix];
    };
  };
}

```

`~/.config/home-manager/home.nix`

Note: replace `drakkir` with your own username.

```nix
{
  config,
  pkgs,
  lib,
  inputs,
  nixGL,
  ...
}: {
  nixGL = {
    packages = nixGL.packages; # you must set this or everything will be a noop
    defaultWrapper = "mesa"; # choose from nixGL options depending on GPU
  };

  home = {
    username = "drakkir";
    homeDirectory = "/home/drakkir";
    stateVersion = "23.11";
    packages = with pkgs; [
      (config.lib.nixGL.wrap alacritty)
    ];
  };

  programs.home-manager.enable = true;

  xdg.configFile."environment.d/envvars.conf".text = ''
    PATH="$HOME/.nix-profile/bin:$PATH"
  '';

  wayland.windowManager.hyprland = {
    enable = true;
    package = config.lib.nixGL.wrap pkgs.hyprland;
    settings = {
      general = {
        gaps_in = 0;
        gaps_out = 0;
        border_size = 20;
      };
    };
  };
}

```

Then to install everything.

```sh
# Activate a nix shell with latest home-manager from github
$ nix shell github:nix-community/home-manager
# Check that home-manager exists in the activated shell
$ home-manager --version
24.11
# Install your home-manager flake using home-manager
$ home-manager switch --flake ~/.config/home-manager
Starting Home Manager activation
...
# home-manager is now installed even outside the nix shell
$ exit
$ home-manager --version
24.11
# We also have our other packages available
$ which Hyprland
/home/drakkir/.nix-profile/bin/Hyprland
```

## Add Hyprland to Gnome Login (GDM)

To add our Hyprland installation to Gnome Login screen you can add the following file.

`/usr/share/wayland-sessions/hyprland.desktop`

Note: replace `drakkir` with your own username.

```
[Desktop Entry]
Name=Hyprland
Comment=An intelligent dynamic tiling Wayland compositor
Exec=/home/drakkir/.nix-profile/bin/Hyprland
Type=Application
```

## Update Nix, Home Manager and Hyprland

To update everything you need the following commands.

```sh
# Update nix
$ sudo -i nix upgrade-nix
# Update Home Manager & Hyprland lock file
$ nix flake update --flake ~/.config/home-manager
# Upgrade Home Manager & Hyprland
$ home-manager switch --flake ~/.config/home-manager
```

## Uninstall

This is one of best features of Nix and it extends to Home-Manager as well. To
uninstall we basically only need to do

```bash
$ sudo rm -rf /nix
```

That is it.

However, there will be some stuff left over such as groups, temporary files,
shell profile configurations, and other minor stuff. A better way to uninstall
Nix is to use the Determinate Installer that I recommend you use to install
Nix.

```bash
$ /nix/nix-installer uninstall
Nix uninstall plan (v0.27.0)

Planner: linux

Configured settings:
* nix_build_group_id: 30001

Planned actions:
* Remove upstream Nix daemon service
* Remove the directory `/etc/tmpfiles.d` if no other contents exists
* Unconfigure the shell profiles
* Remove the Nix configuration in `/etc/nix/nix.conf`
* Unset the default Nix profile
* Remove Nix users and group
* Remove the directory tree in `/nix`
* Remove the directory `/nix`


Proceed? ([Y]es/[n]o/[e]xplain):
```

This removes everything **properly**, including all files created in home
catalog by Home Manager! Full cleanup of your configurations and the
applications themselves in a single command!

It does not remove local state, cache or temporary files which are unique for
each application and version. This is left up to the user. But this fact
also allows us to do something pretty nifty.

```
# Uninstall everything
$ /nix/nix-installer uninstall
# Reinstall Nix
$ curl -L https://install.determinate.systems/nix | sh -s -- install
# Recreate the entire setup back again
$ nix run "nixpkgs#home-manager" -- switch --flake ~/.config/home-manager
```

The above makes it pretty fool-proof if you ever manage to break Nix or
Home-Manager setup in any way. Simply tear everything down and recreate it.
