{
  lib,
  pkgs,
  ...
}:

let
  # Copies left in /usr/share by the old imperative setup script; the bus
  # configuration is managed under /etc now.
  legacyConfCopies = [
    "org.corectrl.helper.conf"
    "org.corectrl.helperkiller.conf"
  ];
  # CoreCtrl's helper is a D-Bus system service guarded by polkit. Both daemons
  # only scan fixed system directories, none of which system-manager can own:
  #
  #   /usr/share/dbus-1/system-services  — dbus activation files
  #   /usr/share/polkit-1/actions        — polkit action definitions
  #
  # ("standard_system_servicedirs" is XDG_DATA_DIRS-based, and polkit reads
  # actions only from /usr/share, so /etc is not an option for either.)
  #
  # systemd-tmpfiles can, so declare them as symlinks into the store. `L+`
  # replaces whatever is at the path, which also cleans up the copies the old
  # imperative setup script left behind.
  usrShareFiles = [
    "dbus-1/system-services/org.corectrl.helper.service"
    "dbus-1/system-services/org.corectrl.helperkiller.service"
    "polkit-1/actions/org.corectrl.helper.policy"
    "polkit-1/actions/org.corectrl.helperkiller.policy"
  ];
in

{
  environment = {
    # The bus configuration is the one part dbus does read from /etc, so let
    # system-manager manage it natively — it gets tracked and cleaned up.
    etc = {
      "dbus-1/system.d/org.corectrl.helper.conf".source =
        "${pkgs.corectrl}/share/dbus-1/system.d/org.corectrl.helper.conf";

      "dbus-1/system.d/org.corectrl.helperkiller.conf".source =
        "${pkgs.corectrl}/share/dbus-1/system.d/org.corectrl.helperkiller.conf";

      # Polkit rules to allow CoreCtrl helper to run without password
      # Using polkit version >= 0.106 format
      "polkit-1/rules.d/90-corectrl.rules".text = ''
        polkit.addRule(function(action, subject) {
            if ((action.id == "org.corectrl.helper.init" ||
                 action.id == "org.corectrl.helperkiller.init") &&
                subject.local == true &&
                subject.active == true &&
                subject.isInGroup("sudo")) {
                    return polkit.Result.YES;
            }
        });
      '';
    };

    # Install CoreCtrl system-wide
    systemPackages = [ pkgs.corectrl ];

  };

  systemd = {
    # dbus caches bus configuration, so it has to be told when the files above
    # change. polkit watches its directories and needs no prompting.
    #
    # At boot this is redundant — systemd-tmpfiles runs in sysinit.target, so the
    # files are already in place before dbus starts. It matters when activating a
    # new generation on a running system, which is also why the CoreCtrl store
    # path is interpolated into the script: it makes the unit itself change
    # whenever CoreCtrl does, which is what makes system-manager restart it.
    services.corectrl-dbus-reload = {
      after = [ "dbus.service" ];
      description = "Reload D-Bus after CoreCtrl configuration changes";

      script = ''
        # CoreCtrl: ${pkgs.corectrl}
        systemctl reload dbus
      '';

      serviceConfig = {
        RemainAfterExit = true;
        Type = "oneshot";
      };

      wantedBy = [ "multi-user.target" ];
    };

    tmpfiles.settings."10-corectrl" =
      lib.listToAttrs (
        map (file: {
          name = "/usr/share/${file}";
          value."L+".argument = "${pkgs.corectrl}/share/${file}";
        }) usrShareFiles
      )
      # The bus configuration used to be copied to /usr/share too. It lives in
      # /etc now, so drop the old copies rather than leaving dbus reading two
      # identical files that drift apart on the next CoreCtrl update.
      // lib.listToAttrs (
        map (file: {
          name = "/usr/share/dbus-1/system.d/${file}";
          value.r = { };
        }) legacyConfCopies
      );

  };
  # ========================================================================
  # AMD GPU Kernel Parameter (Manual Setup Required)
  # ========================================================================
  #
  # For full AMD GPU control in CoreCtrl, edit the GRUB_CMDLINE_LINUX_DEFAULT
  # variable in /etc/default/grub:
  #
  #   GRUB_CMDLINE_LINUX_DEFAULT="quiet splash amdgpu.ppfeaturemask=0xffffffff"
  #
  # Keep your existing parameters (like "quiet splash") and append the
  # amdgpu.ppfeaturemask=0xffffffff parameter to the end.
  #
  # Then run:
  #   sudo update-grub
  #   sudo reboot
  #
  # This enables all AMD GPU power management features in CoreCtrl.
  # ========================================================================
}
