{
  username,
  homeDirectory,
  ...
}:

{
  imports = [
    ../common/core
    ./common/git.nix
    ./common/ssh.nix

    # Desktop environment
    ../common/optional/desktops/gnome
    ../common/optional/desktops/niri

    # Features
    ../common/optional/development.nix
    ../common/optional/tools/proton.nix
    ../common/optional/tools/vscode.nix
    ../common/optional/pam-shim.nix
    ../common/optional/programs/noctalia.nix
    ../common/optional/programs/zen-browser.nix

    # System
    ../common/optional/sessions.nix
    #../common/optional/programs
  ];
}
