{
  lib,
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    proton-pass
    # proton-vpn  # Disabled on Ubuntu 24.04: the Nix package bundles libnm from
    # NetworkManager 1.56, but Ubuntu 24.04's NM daemon is 1.46. On connect, the
    # app rewrites the active connection to add the VPN server route and libnm 1.56
    # serializes the 802-11-wireless.mac-address-denylist property (added in NM 1.48),
    # which the 1.46 daemon rejects -> crash ("mac-address-denylist: unknown property").
    # Using Proton's official .deb instead (links against host NM 1.46, so it matches).
    # Re-enable once the host NetworkManager is >= 1.48 (e.g. Ubuntu 26.04 ships NM 1.56).
  ];

  services.proton-pass-agent = {
    enable = true;
  };

  # The agent fails on boot if not logged in yet; keep retrying until it succeeds
  systemd.user.services.proton-pass-agent = {
    Service = {
      Restart = "on-failure";
      RestartSec = "10s";
    };
  };
}
