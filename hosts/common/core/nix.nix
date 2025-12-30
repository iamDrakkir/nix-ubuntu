{ pkgs, system, ... }:

{
  nixpkgs.hostPlatform = system;
  system-manager.allowAnyDistro = true;

  # Nix configuration
  nix = {
    package = pkgs.nix;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
    };
  };

  # Essential system packages present on all hosts
  environment.systemPackages = with pkgs; [
    neovim
    pipewire
    wireplumber
  ];
}
