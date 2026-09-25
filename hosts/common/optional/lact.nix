{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.lact ];

  # Upstream ships lib/systemd/system/lactd.service, but system-manager only
  # activates units it declares, so redeclare it. The store path is interpolated
  # rather than symlinked so the unit changes whenever LACT does, which is what
  # makes system-manager restart the daemon on a new generation.
  systemd.services.lactd = {
    after = [ "multi-user.target" ];
    description = "LACT GPU Control Daemon";

    serviceConfig = {
      ExecStart = "${pkgs.lact}/bin/lact daemon";
      # Upstream's priority: keeps polling steady under GPU load.
      Nice = -10;
      Restart = "on-failure";
    };

    wantedBy = [ "multi-user.target" ];
  };

  # ========================================================================
  # AMD GPU Kernel Parameter (Manual Setup Required)
  # ========================================================================
  #
  # Same prerequisite as CoreCtrl — without it the amdgpu driver exposes no
  # clock/voltage controls and LACT shows monitoring only. Edit
  # GRUB_CMDLINE_LINUX_DEFAULT in /etc/default/grub:
  #
  #   GRUB_CMDLINE_LINUX_DEFAULT="quiet splash amdgpu.ppfeaturemask=0xffffffff"
  #
  # Then `sudo update-grub && sudo reboot`. If CoreCtrl's advanced mode already
  # worked on this host, it is already set.
  # ========================================================================
}
