{ pkgs, ... }:

# CPU power management via auto-cpufreq. auto-cpufreq and power-profiles-daemon
# both want to drive the CPU governor, so they are configured as a pair: one
# runs, the other is masked. Importing this file enables that pairing; omitting
# it leaves power-profiles-daemon unmasked and free to run.
#
# Opt-in per host rather than part of core, because it is only worth running on
# machines whose frequency scaling is not already handled by the driver. See the
# note in hosts/terra/default.nix.
{
  environment.systemPackages = [ pkgs.auto-cpufreq ];

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

      # kmod provides lsmod, which auto-cpufreq shells out to in
      # battery_scripts/battery.py to probe for ideapad_acpi. Without it the
      # daemon dies with FileNotFoundError on every start and systemd restarts
      # it forever — a silent crash loop that looks like a running service.
      path = with pkgs; [
        bash
        coreutils
        gawk
        gnugrep
        gnused
        kmod
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
