{
  description = "Nix configuration for Ubuntu with system-manager and home-manager";

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
      # url = "github:0xc000022070/zen-browser-flake"; # TODO: issue with no sound
      url = "github:Gurjaka/zen-browser-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak";

    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      system-manager,
      nix-system-graphics,
      ...
    }:
    let
      inherit (self) outputs;
      system = "x86_64-linux";

      # ========== Extend lib with lib.custom and lib.hm ==========
      lib = nixpkgs.lib.extend (
        self: super:
        (import ./lib { lib = self; })
        // {
          # Import home-manager's lib.hm to fix missing lib.hm errors
          hm = import "${home-manager}/modules/lib" { lib = self; };
        }
      );

      # Custom packages overlay (empty for now, add custom packages to ./pkgs/default.nix)
      customPackages = final: prev: (import ./pkgs { pkgs = prev; });

      # Import overlays (empty for now, add custom overlays to ./overlays/default.nix)
      overlays = [ customPackages ];

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = overlays;
      };

      # Helper function to create system configs for each host
      mkSystemConfig =
        hostname:
        system-manager.lib.makeSystemConfig {
          extraSpecialArgs = {
            inherit
              inputs
              outputs
              lib
              system
              ;
          };
          modules = [
            ./hosts/${hostname}
          ];
        };

      # Helper function to create home-manager configs for each user@host
      mkHomeConfig =
        username: hostname:
        let
          homeDirectory = "/home/${username}";
        in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          extraSpecialArgs = {
            inherit
              inputs
              outputs
              system
              username
              hostname
              homeDirectory
              lib
              ;
          };

          modules = [
            ./home/${username}/${hostname}.nix

            # Include system-manager CLI in user environment
            { home.packages = [ system-manager.packages.${system}.default ]; }
          ];
        };
    in
    {
      formatter.${system} = pkgs.nixfmt-rfc-style;

      systemConfigs = {
        terra = mkSystemConfig "terra";
        bigbox = mkSystemConfig "bigbox";
        work = mkSystemConfig "work";
      };

      homeConfigurations = {
        "drakkir@terra" = mkHomeConfig "drakkir" "terra";
        "drakkir@bigbox" = mkHomeConfig "drakkir" "bigbox";
        "rhagelin@work" = mkHomeConfig "rhagelin" "work";
      };
    };
}
