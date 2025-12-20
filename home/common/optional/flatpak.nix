{ inputs, ... }:

{
  imports = [
    inputs.nix-flatpak.homeManagerModules.nix-flatpak
  ];

  services.flatpak = {
    enable = true;
    packages = [
      "net.davidotek.pupgui2"
      "com.usebottles.bottles"
    ];
  };
}
