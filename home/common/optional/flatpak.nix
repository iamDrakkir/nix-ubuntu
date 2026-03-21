{ inputs, ... }:

{
  imports = [
    inputs.nix-flatpak.homeManagerModules.nix-flatpak
  ];

  services.flatpak = {
    enable = true;
    packages = [
      "com.vysp3r.ProtonPlus"
      "net.davidotek.pupgui2"
      "com.usebottles.bottles"
    ];
  };
}
