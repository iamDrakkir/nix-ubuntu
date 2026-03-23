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
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
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

    dms = {
      url = "github:AvengeMedia/DankMaterialShell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # PAM shim for non-NixOS systems
    # Using 'next' branch for full libpam.so.0 API coverage
    pam-shim = {
      url = "github:Cu3PO42/pam_shim/next";
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

      # Helper function to create home-manager configs for each user@host.
      # configUser selects the repo path/flake attribute, while username and
      # homeDirectory can be overridden for domain-backed logins.
      mkHomeConfig =
        {
          configUser,
          hostname,
          username ? configUser,
          homeDirectory ? "/home/${username}",
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
        "drakkir@terra" = mkHomeConfig {
          configUser = "drakkir";
          hostname = "terra";
        };
        "drakkir@bigbox" = mkHomeConfig {
          configUser = "drakkir";
          hostname = "bigbox";
        };
        "rhagelin@work" = mkHomeConfig {
          configUser = "rhagelin";
          hostname = "work";
          username = "rhagelin@creatorctek.local";
          homeDirectory = "/home/rhagelin.creatorctek.local";
        };
      };
    };
}
