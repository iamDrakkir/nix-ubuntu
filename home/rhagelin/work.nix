{
  pkgs,
  homeDirectory,
  username,
  ...
}:

{
  home = {
    # Symlink .face file for user avatar
    file.".face".source = ../../.face;

    # PKCS#11 / Smartcard / YubiKey support
    packages = with pkgs; [
      opensc # OpenSC PKCS#11 provider (opensc-pkcs11)
      libp11 # OpenSSL PKCS#11 engine (libengine-pkcs11-openssl)
      openssl
      gcx
    ];

    sessionVariables = {
      # Let the nix compiler find system headers and libraries (non-NixOS)
      C_INCLUDE_PATH = "/usr/include:/usr/include/x86_64-linux-gnu";
      LIBRARY_PATH = "/usr/lib/x86_64-linux-gnu";
      PKG_CONFIG_PATH = "/usr/lib/x86_64-linux-gnu/pkgconfig:/usr/share/pkgconfig";
      # Force pycurl to use system curl-config instead of the nix one
      PYCURL_CURL_CONFIG = "/usr/bin/curl-config";
      UV_INDEX = "";
    };
  };

  imports = [
    ../common/core
    ./common/gpg.nix
    ./common/ssh.nix

    # Desktop environment
    ../common/optional/desktops/gnome
    ../common/optional/desktops/niri

    # Apps
    ../common/optional/apps/teams.nix
  ];

  # ---- Host hardware: displays ----
  # work is a laptop: internal panel only.
  programs.niri.settings.outputs."eDP-1" = {
    mode = {
      height = 1080;
      refresh = 60.0;
      width = 1920;
    };

    position = {
      x = 0;
      y = 0;
    };

    scale = 1.0;
  };
}
