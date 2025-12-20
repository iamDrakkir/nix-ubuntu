{ pkgs, ... }:

{
  # Auto-cpufreq systemd service
  systemd.services.auto-cpufreq = {
    enable = true;
    description = "auto-cpufreq - Automatic CPU speed & power optimizer";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    path = with pkgs; [
      bash
      coreutils
    ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.auto-cpufreq}/bin/auto-cpufreq --daemon";
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };

  environment.systemPackages = with pkgs; [
    auto-cpufreq
  ];
}
