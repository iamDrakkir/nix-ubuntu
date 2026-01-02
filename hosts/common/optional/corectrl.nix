{
  config,
  lib,
  pkgs,
  ...
}:

let
  # Create a setup script to install CoreCtrl files to /usr/share
  # This is needed on Ubuntu because system-manager can't manage /usr/share
  corectrlSetupScript = pkgs.writeShellScriptBin "corectrl-setup" ''
    #!/usr/bin/env bash
    set -e

    echo "Setting up CoreCtrl D-Bus and polkit files..."

    # Find the CoreCtrl package in the nix store
    CORECTRL_PATH=$(readlink -f ${pkgs.corectrl})

    if [ ! -d "$CORECTRL_PATH" ]; then
      echo "Error: CoreCtrl package not found at $CORECTRL_PATH"
      exit 1
    fi

    echo "Found CoreCtrl at: $CORECTRL_PATH"

    # Copy D-Bus service files
    echo "Installing D-Bus service files..."
    sudo cp "$CORECTRL_PATH/share/dbus-1/system-services/org.corectrl.helper.service" \
      /usr/share/dbus-1/system-services/
    sudo cp "$CORECTRL_PATH/share/dbus-1/system-services/org.corectrl.helperkiller.service" \
      /usr/share/dbus-1/system-services/

    # Copy D-Bus configuration files
    echo "Installing D-Bus configuration files..."
    sudo cp "$CORECTRL_PATH/share/dbus-1/system.d/org.corectrl.helper.conf" \
      /usr/share/dbus-1/system.d/
    sudo cp "$CORECTRL_PATH/share/dbus-1/system.d/org.corectrl.helperkiller.conf" \
      /usr/share/dbus-1/system.d/

    # Copy polkit policy files
    echo "Installing polkit policy files..."
    sudo cp "$CORECTRL_PATH/share/polkit-1/actions/org.corectrl.helper.policy" \
      /usr/share/polkit-1/actions/
    sudo cp "$CORECTRL_PATH/share/polkit-1/actions/org.corectrl.helperkiller.policy" \
      /usr/share/polkit-1/actions/

    # Reload D-Bus
    echo "Reloading D-Bus..."
    sudo systemctl reload dbus

    echo ""
    echo "✓ CoreCtrl setup complete!"
    echo ""
    echo "You can now run 'corectrl' to start the application."
    echo ""
    echo "For full AMD GPU control, you still need to:"
    echo "1. Edit /etc/default/grub and add to GRUB_CMDLINE_LINUX_DEFAULT:"
    echo "   GRUB_CMDLINE_LINUX_DEFAULT=\"quiet splash amdgpu.ppfeaturemask=0xffffffff\""
    echo "   (Keep your existing parameters and append the amdgpu parameter)"
    echo "2. Run: sudo update-grub"
    echo "3. Reboot your system"
  '';
in
{
  # Install CoreCtrl system-wide
  environment.systemPackages = with pkgs; [
    corectrl
    corectrlSetupScript
  ];

  # Polkit rules to allow CoreCtrl helper to run without password
  # Using polkit version >= 0.106 format
  environment.etc."polkit-1/rules.d/90-corectrl.rules".text = ''
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

  # Automatic setup: Install CoreCtrl files to /usr/share on boot
  systemd.services.corectrl-setup = {
    description = "Install CoreCtrl D-Bus and polkit files";
    wantedBy = [ "multi-user.target" ];
    after = [ "dbus.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      echo "Setting up CoreCtrl D-Bus and polkit files..."

      # Find the CoreCtrl package in the nix store
      CORECTRL_PATH=$(readlink -f ${pkgs.corectrl})

      if [ ! -d "$CORECTRL_PATH" ]; then
        echo "Error: CoreCtrl package not found at $CORECTRL_PATH"
        exit 1
      fi

      echo "Found CoreCtrl at: $CORECTRL_PATH"

      # Copy D-Bus service files
      echo "Installing D-Bus service files..."
      cp -f "$CORECTRL_PATH/share/dbus-1/system-services/org.corectrl.helper.service" \
        /usr/share/dbus-1/system-services/ || true
      cp -f "$CORECTRL_PATH/share/dbus-1/system-services/org.corectrl.helperkiller.service" \
        /usr/share/dbus-1/system-services/ || true

      # Copy D-Bus configuration files
      echo "Installing D-Bus configuration files..."
      cp -f "$CORECTRL_PATH/share/dbus-1/system.d/org.corectrl.helper.conf" \
        /usr/share/dbus-1/system.d/ || true
      cp -f "$CORECTRL_PATH/share/dbus-1/system.d/org.corectrl.helperkiller.conf" \
        /usr/share/dbus-1/system.d/ || true

      # Copy polkit policy files
      echo "Installing polkit policy files..."
      cp -f "$CORECTRL_PATH/share/polkit-1/actions/org.corectrl.helper.policy" \
        /usr/share/polkit-1/actions/ || true
      cp -f "$CORECTRL_PATH/share/polkit-1/actions/org.corectrl.helperkiller.policy" \
        /usr/share/polkit-1/actions/ || true

      # Reload D-Bus
      echo "Reloading D-Bus..."
      systemctl reload dbus || true

      echo "✓ CoreCtrl setup complete!"
    '';
  };

  # ========================================================================
  # CoreCtrl Setup (Automatic via systemd service)
  # ========================================================================
  #
  # CoreCtrl files are automatically installed to /usr/share by the
  # corectrl-setup.service which runs on boot (after dbus.service).
  #
  # The service will re-run on every boot to ensure files are up-to-date.
  # The corectrl-setup script is still available if you need to run it manually.
  #
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
