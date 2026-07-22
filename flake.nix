{
  description = "Nix configuration for Ubuntu/NixOS with system-manager and home-manager";

  inputs = {
    firefox-addons = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
    };
    herdr = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:ogulcancelik/herdr";
    };
    home-manager = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/home-manager";
    };
    hyprland = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:hyprwm/Hyprland";
    };
    niri = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:sodiboo/niri-flake";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak";
    nix-index-database = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/nix-index-database";
    };
    nix-system-graphics = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:soupglasses/nix-system-graphics";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    pedantix = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:swarsel/pedantix";
    };
    noctalia = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:noctalia-dev/noctalia-shell";
    };
    # PAM shim for non-NixOS systems
    # Using 'next' branch for full libpam.so.0 API coverage
    pam-shim = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:Cu3PO42/pam_shim/next";
    };
    system-manager = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:numtide/system-manager";
    };
    zen-browser = {
      inputs = {
        home-manager.follows = "home-manager";
        nixpkgs.follows = "nixpkgs";
      };
      url = "github:0xc000022070/zen-browser-flake";
    };
  };

  outputs =
    inputs@{
      home-manager,
      nix-system-graphics,
      nixpkgs,
      self,
      system-manager,
      ...
    }:
    let
      inherit (self) outputs;
      system = "x86_64-linux";
      systemAarch64 = "aarch64-linux";

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

      # Import overlays
      overlays = [
        customPackages
        inputs.herdr.overlays.default
      ];

      # Helper to build a pkgs instance for any system
      mkPkgs =
        sys:
        import nixpkgs {
          config.allowUnfree = true;
          overlays = overlays;
          system = sys;
        };

      pkgs = mkPkgs system;

      # Helper function to create system configs for each host
      mkSystemConfig =
        hostname:
        system-manager.lib.makeSystemConfig {
          modules = [
            ./hosts/${hostname}
          ];
          specialArgs = {
            inherit
              inputs
              outputs
              lib
              system
              ;
          };
        };

      # Helper function to create home-manager configs for each user@host.
      # configUser selects the repo path/flake attribute, while username and
      # homeDirectory can be overridden for domain-backed logins.
      mkHomeConfig =
        {
          configUser,
          homeDirectory ? "/home/${username}",
          hostname,
          username ? configUser,
        }:
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          extraSpecialArgs = {
            inherit
              inputs
              outputs
              system
              username
              configUser
              hostname
              homeDirectory
              lib
              ;
          };

          modules = [
            ./home/${configUser}/${hostname}.nix

            # PAM shim module for non-NixOS authentication support
            inputs.pam-shim.homeModules.default

            # Zen Browser Home Manager module (provides programs.zen-browser)
            inputs.zen-browser.homeModules.beta

            # nix-index-database (provides programs.nix-index-database.comma)
            inputs.nix-index-database.homeModules.nix-index

            # Include system-manager CLI in user environment
            { home.packages = [ system-manager.packages.${system}.default ]; }
          ];
        };

      # Helper function to create NixOS configurations with home-manager as a module.
      # Used for hosts that actually run NixOS (e.g. Raspberry Pi).
      mkNixosConfig =
        {
          configUser ? "drakkir",
          homeDirectory ? "/home/${username}",
          hostname,
          sys ? systemAarch64,
          username ? configUser,
        }:
        nixpkgs.lib.nixosSystem {
          modules = [
            ./hosts/${hostname}

            # Integrate home-manager as a NixOS module
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                extraSpecialArgs = {
                  inherit
                    inputs
                    outputs
                    lib
                    hostname
                    configUser
                    username
                    homeDirectory
                    ;
                  system = sys;
                };
                useGlobalPkgs = true;
                useUserPackages = true;
                users.${username} = {
                  imports = [
                    ./home/${configUser}/${hostname}.nix
                    inputs.nix-index-database.homeModules.nix-index
                  ];
                };
              };
            }
          ];
          specialArgs = {
            inherit
              inputs
              outputs
              lib
              sys
              hostname
              configUser
              username
              homeDirectory
              ;
          };
          system = sys;
        };
    in
    {
      formatter.${system} = inputs.pedantix.packages.${system}.pedantix-wrapped;
      homeConfigurations = {
        "drakkir@bigbox" = mkHomeConfig {
          configUser = "drakkir";
          hostname = "bigbox";
        };
        "drakkir@terra" = mkHomeConfig {
          configUser = "drakkir";
          hostname = "terra";
        };
        "rhagelin@work" = mkHomeConfig {
          configUser = "rhagelin";
          homeDirectory = "/home/rhagelin.creatorctek.local";
          hostname = "work";
          # username = "rickard.hagelin@ctek.com";
          username = "rhagelin@creatorctek.local";
        };
      };
      nixosConfigurations = {
        pi = mkNixosConfig {
          configUser = "drakkir";
          hostname = "pi";
        };
      };
      systemConfigs = {
        bigbox = mkSystemConfig "bigbox";
        terra = mkSystemConfig "terra";
        work = mkSystemConfig "work";
      };
    };
}
