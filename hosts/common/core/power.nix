{ pkgs, ... }:

# CPU power management. auto-cpufreq and power-profiles-daemon both want to
# drive the CPU governor, so they are configured as a pair: one runs, the other
# is masked.
{
  systemd = {
    # power-profiles-daemon is distro-shipped, so it has to be masked:
    # `systemd.services.<n>.enable = false` only suppresses units system-manager
    # generates itself, and silently does nothing for units it doesn't own.
    maskedUnits = [ "power-profiles-daemon.service" ];

    services.auto-cpufreq = {
      after = [
        "network.target"
        "system-manager.target"
      ];

      conflicts = [ "power-profiles-daemon.service" ];
      description = "auto-cpufreq - Automatic CPU speed & power optimizer";
      enable = true;

      path = with pkgs; [
        bash
        coreutils
        gawk
        gnugrep
        gnused
        util-linux
      ];

      serviceConfig = {
        ExecStart = "${pkgs.auto-cpufreq}/bin/auto-cpufreq --daemon";
        Restart = "on-failure";
        RestartSec = "5s";
        Type = "simple";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}
