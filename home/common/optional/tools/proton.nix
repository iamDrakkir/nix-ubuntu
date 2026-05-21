{
  lib,
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    proton-pass
    proton-vpn
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
