{
  description = "Nix configuration for Ubuntu with system-manager and home-manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # System management
    system-manager = {
      url = "github:numtide/system-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-system-graphics = {
      url = "github:soupglasses/nix-system-graphics";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    auto-cpufreq = {
      url = "github:AdnanHodzic/auto-cpufreq";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # User environment
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Applications
    zen-browser = {
      url = "github:Gurjaka/zen-browser-nix";
      inputs = {
        home-manager.follows = "home-manager";
        nixpkgs.follows = "nixpkgs";
      };
    };

    nix-flatpak = {
      url = "github:gmodena/nix-flatpak";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Desktop environments
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ { self, nixpkgs, home-manager, system-manager, nix-system-graphics, ... }:
    let
      system = "x86_64-linux";
      username = "drakkir";
      homeDirectory = "/home/${username}";

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      # Formatter for `nix fmt`
      formatter.${system} = pkgs.nixpkgs-fmt;

      # System-level configuration (requires sudo)
      systemConfigs.default = system-manager.lib.makeSystemConfig {
        extraSpecialArgs = { inherit system; };
        modules = [
          nix-system-graphics.systemModules.default
          ./modules/system
        ];
      };

      # User-level configuration
      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        extraSpecialArgs = {
          inherit inputs system username homeDirectory;
        };

        modules = [
          ./home.nix

          # Include system-manager CLI in user environment
          { home.packages = [ system-manager.packages.${system}.default ]; }
        ];
      };
    };
}
