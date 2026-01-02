{ ... }:

{
  imports = [
    ./sysctl-userns.nix
    ./auto-cpufreq.nix
    ./flatpak.nix
    ./corectrl.nix
  ];
}
