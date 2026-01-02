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

  # Link share directories so desktop files and other resources are available
  environment.pathsToLink = [
    "/bin"
    "/share"
  ];

  # Export XDG_DATA_DIRS to include system-manager packages
  environment.etc."profile.d/system-manager-xdg.sh" = {
    text = ''
      export XDG_DATA_DIRS="/run/system-manager/sw/share:''${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
    '';
    mode = "0444";
  };
}
