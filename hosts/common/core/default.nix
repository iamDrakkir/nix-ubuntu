{ ... }:

{
  imports = [
    ./environment.nix
    ./graphics.nix
    ./keyboard.nix
    ./nix.nix
    ./polkit-agent-helper.nix
    ./sandboxing.nix
    ./shells.nix
    ./wayland-sessions.nix
  ];
}
