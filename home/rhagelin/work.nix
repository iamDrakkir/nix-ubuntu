{
  username,
  homeDirectory,
  ...
}:

{
  imports = [
    ../common/core
    ./common/git.nix

    # Desktop environment (only GNOME for work)
    ../common/optional/desktops/gnome

    # Features
    ../common/optional/development.nix
    ../common/optional/tools

    # System
    ../common/optional/flatpak.nix
    ../common/optional/sessions.nix
    ../common/optional/programs
  ];
}
