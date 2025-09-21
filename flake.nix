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

    flatpaks = {
      url = "github:gmodena/nix-flatpak/?ref=latest";
    };
  };

  outputs = { self, nixpkgs, home-manager, system-manager, nix-system-graphics, zen-browser, flatpaks, ... }:
    let
      system = "x86_64-linux";
      username = "drakkir";
      # pkgs = nixpkgs.legacyPackages.${system};
      pkgs = import nixpkgs { system = "x86_64-linux"; config.allowUnfree = true; };
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
                ghostty
                kitty
                hyprland
                xdg-desktop-portal
                xdg-desktop-portal-gtk
              ];
            };
          })
        ];
      };

      homeConfigurations = {
        "${username}" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          extraSpecialArgs = {
            inherit zen-browser;
            inherit flatpaks;
          };

          modules = [
            ./home.nix
            ({
              home.packages = [ system-manager.packages."${system}".default ];
            })
          ];
        };
      };
    };
}
