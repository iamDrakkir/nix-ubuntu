{ ... }:

{
  imports = [
    ./environment.nix
    ./graphics.nix
    ./keyboard.nix
    ./nix.nix
    ./polkit-agent-helper.nix
    ./power.nix
    ./sandboxing.nix
    ./wayland-sessions.nix
  ];
}
