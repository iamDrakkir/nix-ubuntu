{
  homeDirectory,
  pkgs,
  username,
  ...
}:

{
  imports = [
    ../common/core
    ./common/git.nix
    ./common/ssh.nix
    ./common/gpg.nix

    # Desktop environment
    ../common/optional/desktops/gnome
    ../common/optional/desktops/niri

    # Features
    ../common/optional/development.nix
    ../common/optional/containers.nix
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

  # PKCS#11 / Smartcard / YubiKey support
  home.packages = with pkgs; [
    opensc # OpenSC PKCS#11 provider (opensc-pkcs11)
    libp11 # OpenSSL PKCS#11 engine (libengine-pkcs11-openssl)
    openssl
    gcx
  ];

  # Symlink .face file for user avatar
  home.file.".face".source = ../../.face;

  home.sessionVariables = {
    UV_INDEX = "";
    # Let the nix compiler find system headers and libraries (non-NixOS)
    C_INCLUDE_PATH = "/usr/include:/usr/include/x86_64-linux-gnu";
    LIBRARY_PATH = "/usr/lib/x86_64-linux-gnu";
    PKG_CONFIG_PATH = "/usr/lib/x86_64-linux-gnu/pkgconfig:/usr/share/pkgconfig";
    # Force pycurl to use system curl-config instead of the nix one
    PYCURL_CURL_CONFIG = "/usr/bin/curl-config";
  };
}
