{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    system-manager = {
      url = "github:numtide/system-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-system-graphics = {
      url = "github:soupglasses/nix-system-graphics";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      # url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak = {
      url = "github:gmodena/nix-flatpak";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    auto-cpufreq = {
        url = "github:AdnanHodzic/auto-cpufreq";
        inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, system-manager, nix-system-graphics, zen-browser, nix-flatpak, auto-cpufreq, ... }:
    let
      system = "x86_64-linux";
      username = "drakkir";
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
    in {
      defaultPackage.x86_64-linux = home-manager.defaultPackage.x86_64-linux;

      systemConfigs.default = system-manager.lib.makeSystemConfig {
        modules = [
          nix-system-graphics.systemModules.default
          ({
            config = {
              nixpkgs.hostPlatform = "${system}";
              system-manager.allowAnyDistro = true;
              system-graphics = {
                enable = true;
                enable32Bit = true;
              };

              environment.systemPackages = with pkgs; [
                git
                neovim
                hyprland
                ghostty
                flatpak
                xdg-desktop-portal
                xdg-desktop-portal-hyprland
                xdg-desktop-portal-gtk
                auto-cpufreq
              ];

              systemd.services."xdg-desktop-portal" = {
                description = "XDG Desktop Portal";
                after = [ "graphical-session.target" ];
                wantedBy = [ "multi-user.target" ];
                serviceConfig = {
                  ExecStart = "${pkgs.xdg-desktop-portal}/libexec/xdg-desktop-portal";
                  Restart = "on-failure";
                };
              };

              environment.etc."apparmor.d/nix-bwrap".text = ''
                abi <abi/4.0>,
                include <tunables/global>

                profile bwrap ${pkgs.bubblewrap}/bin/bwrap flags=(unconfined) {
                  userns,
                  include if exists <local/bwrap>
                }
              '';
            };
          })
        ];
      };

      homeConfigurations = {
        imports = [
            "${nix-flatpak}/modules/nixos.nix"
          ];
        "${username}" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          extraSpecialArgs = {
            inherit zen-browser;
            inherit nix-flatpak;
            # inherit hyprland;
          };


          modules = [
            ./home.nix
            {
              home.packages = [ system-manager.packages."${system}".default ];
            }

            "${nix-flatpak}/modules/home-manager.nix"

            {
              services.flatpak = {
                enable = true;

                packages = [
                  "net.davidotek.pupgui2"
                  "com.usebottles.bottles"
                  "com.valvesoftware.Steam"
                  "com.discordapp.Discord"
                ];
              };
            }
          ];
        };
      };
    };
}
