{ ... }:

{
  imports = [
    ./sysctl-userns.nix
    ./flatpak.nix
    ./corectrl.nix
  ];
}
