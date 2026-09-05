{ ... }:

{
  imports = [
    ./nix.nix
    ./graphics.nix
    ./sysctl-userns.nix
    ./polkit-agent-helper.nix
  ];
}
