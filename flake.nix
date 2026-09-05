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

    pedantix = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:swarsel/pedantix";
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
      self,
      home-manager,
      nix-system-graphics,
      nixpkgs,
      system-manager,
      ...
    }:
    let
      # Custom packages overlay: see ./pkgs/default.nix
      customPackages = final: prev: (import ./pkgs { pkgs = prev; });
      # ========== Per-user identity ==========
      # Single source of truth for git authorship and the uid used to locate
      # per-user runtime sockets (/run/user/<uid>/...). Consumed via the
      # `identity` specialArg by home/common/core/git.nix and home/*/common/ssh.nix.
      identities = {
        drakkir = {
          email = "Hagelin.Rickard@gmail.com";
          name = "iamDrakkir";
          uid = 1000;
        };

        rhagelin = {
          email = "rickard.hagelin@ctek.com";
          name = "Rickard Hagelin";
          uid = 1735616652;
        };
      };
      # ========== Extend lib with lib.custom and lib.hm ==========
      lib = nixpkgs.lib.extend (
        self: super:
        (import ./lib { lib = self; })
        // {
          # Import home-manager's lib.hm to fix missing lib.hm errors
          hm = import "${home-manager}/modules/lib" { lib = self; };
        }
      );
      # Helper function to create home-manager configs for each user@host.
      # configUser selects the repo path/flake attribute, while username and
      # homeDirectory can be overridden for domain-backed logins.
      mkHomeConfig =
        {
          configUser,
          hostname,
          identity,
          homeDirectory ? "/home/${username}",
          username ? configUser,
        }:
        home-manager.lib.homeManagerConfiguration {
          extraSpecialArgs = {
            inherit
              configUser
              homeDirectory
              hostname
              identity
              inputs
              lib
              outputs
              system
              username
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

          inherit pkgs;
        };
      # Helper function to create NixOS configurations with home-manager as a module.
      # Used for hosts that actually run NixOS (e.g. Raspberry Pi).
      mkNixosConfig =
        {
          hostname,
          identity,
          configUser ? "drakkir",
          homeDirectory ? "/home/${username}",
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
                    configUser
                    homeDirectory
                    hostname
                    identity
                    inputs
                    lib
                    outputs
                    username
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
              configUser
              homeDirectory
              hostname
              inputs
              lib
              outputs
              sys
              username
              ;
          };

          system = sys;
        };
      # Helper to build a pkgs instance for any system
      mkPkgs =
        sys:
        import nixpkgs {
          config.allowUnfree = true;
          overlays = overlays;
          system = sys;
        };
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
              lib
              outputs
              system
              ;
          };
        };
      inherit (self) outputs;
      # Import overlays
      overlays = [
        customPackages
        inputs.herdr.overlays.default
      ];
      pkgs = mkPkgs system;
      system = "x86_64-linux";
      systemAarch64 = "aarch64-linux";
    in
    {
      # `nix flake check` walks homeConfigurations and nixosConfigurations on its
      # own, but reports "The following flake outputs are unchecked:
      # systemConfigs." — re-export them here so the system level is covered by
      # the same gate instead of only being caught at `just system` time.
      checks.${system} = {
        systemConfig-bigbox = self.systemConfigs.bigbox;
        systemConfig-terra = self.systemConfigs.terra;
        systemConfig-work = self.systemConfigs.work;
      };

      formatter.${system} = inputs.pedantix.packages.${system}.pedantix-wrapped;

      homeConfigurations = {
        "drakkir@bigbox" = mkHomeConfig {
          configUser = "drakkir";
          hostname = "bigbox";
          identity = identities.drakkir;
        };

        "drakkir@terra" = mkHomeConfig {
          configUser = "drakkir";
          hostname = "terra";
          identity = identities.drakkir;
        };

        "rhagelin@work" = mkHomeConfig {
          configUser = "rhagelin";
          homeDirectory = "/home/rhagelin.creatorctek.local";
          hostname = "work";
          identity = identities.rhagelin;
          username = "rhagelin@creatorctek.local";
        };
      };

      nixosConfigurations = {
        pi = mkNixosConfig {
          configUser = "drakkir";
          hostname = "pi";
          identity = identities.drakkir;
        };
      };

      systemConfigs = {
        bigbox = mkSystemConfig "bigbox";
        terra = mkSystemConfig "terra";
        work = mkSystemConfig "work";
      };
    };
}
