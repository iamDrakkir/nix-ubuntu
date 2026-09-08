{ ... }:

# Noctalia's built-in polkit agent uses the Nix-built libpolkit-agent-1, which
# has the NixOS setuid helper path baked in:
#
#   /run/wrappers/bin/polkit-agent-helper-1
#
# On these Ubuntu hosts that path does not exist (system-manager only creates
# mount/umount wrappers there), so the agent registers fine but every
# authentication fails with "Not authorized" — and noctalia crashes on the
# failure path.
#
# The host's own setuid helper lives at /usr/lib/polkit-1/polkit-agent-helper-1
# and matches the host polkitd, so point the expected path at it. Same spirit as
# home/common/optional/pam-shim.nix: bridge Nix binaries to host system paths.
#
# The link must be re-made on every activation. suid-sgid-wrappers.service
# populates a fresh wrappers.XXXXXXXX directory and re-points /run/wrappers/bin
# at it, so anything we linked into the previous one is gone. Hence no
# RemainAfterExit: it would leave this unit "active (exited)" forever and make
# the next activation's `start` a silent no-op, stranding the link in the old
# directory until the next reboot. partOf covers wrappers restarting on its own.
{
  systemd.services.polkit-agent-helper-link = {
    after = [ "suid-sgid-wrappers.service" ];
    description = "Link the NixOS polkit agent helper path to the host helper";
    partOf = [ "suid-sgid-wrappers.service" ];
    requires = [ "suid-sgid-wrappers.service" ];

    script = ''
      HOST_HELPER=/usr/lib/polkit-1/polkit-agent-helper-1

      if [ ! -u "$HOST_HELPER" ]; then
        echo "Error: $HOST_HELPER is missing or not setuid; is polkitd installed?"
        exit 1
      fi

      ln -sfn "$HOST_HELPER" /run/wrappers/bin/polkit-agent-helper-1
      echo "✓ /run/wrappers/bin/polkit-agent-helper-1 -> $HOST_HELPER"
    '';

    serviceConfig = {
      Type = "oneshot";
    };

    wantedBy = [ "system-manager.target" ];
  };
}
