{
  pkgs,
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
    ../common/optional/programs/teams.nix

    # System
    ../common/optional/sessions.nix
    #../common/optional/programs
  ];

  # PKCS#11 / Smartcard support
  home.packages = with pkgs; [
    opensc # OpenSC PKCS#11 provider (opensc-pkcs11)
    libp11 # OpenSSL PKCS#11 engine (libengine-pkcs11-openssl)
  ];

  # Symlink .face file for user avatar
  home.file.".face".source = ../../.face;

}
