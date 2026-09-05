{
  lib,
  config,
  pkgs,
  ...
}:

# Wayland session entries for the display manager (GDM).
#
# These used to be written by home-manager into
# ~/.local/share/wayland-sessions/ and then copied to the system directory by
# hand via the `install-wayland-sessions` script — GDM only reads
# /usr/share/wayland-sessions/ (and won't follow symlinks into the Nix store),
# so the manual step was unavoidable at the home level.
#
# system-manager runs as root, so install them here instead: the service below
# copies real files into place on every rebuild and boot.
#
# The Exec launchers resolve the compositor through $HOME at runtime rather than
# a baked-in path, so the same session entry works for any user on the host.
let
  cfg = config.myConfig.waylandSessions;
  known = {
    hyprland = {
      binary = "start-hyprland";
      comment = "A dynamic tiling Wayland compositor";
      label = "Hyprland";
    };

    niri = {
      binary = "niri-session";
      comment = "A scrollable-tiling Wayland compositor";
      label = "Niri";
    };
  };
  launcher =
    name: binary:
    pkgs.writeShellScript "${name}-session-launch" ''
      exec "$HOME/.nix-profile/bin/${binary}"
    '';
  mkSession =
    name:
    {
      binary,
      comment,
      label,
    }:
    pkgs.writeText "${name}.desktop" ''
      [Desktop Entry]
      Name=${label}
      Comment=${comment}
      Exec=${launcher name binary}
      Type=Application
      DesktopNames=${label}
    '';
  selected = lib.getAttrs cfg known;
in

{
  config = {
    systemd.services.wayland-sessions-install = {
      description = "Install Wayland session entries into /usr/share/wayland-sessions";

      script = ''
        install -d -m 0755 /usr/share/wayland-sessions

        ${lib.concatStringsSep "\n" (
          lib.mapAttrsToList (name: session: ''
            install -m 0644 ${mkSession name session} /usr/share/wayland-sessions/${name}.desktop
            echo "✓ installed ${name}.desktop"
          '') selected
        )}

        # Entries for compositors this host no longer selects would otherwise
        # linger and fail at login, since nothing else prunes /usr/share.
        ${lib.concatStringsSep "\n" (
          map (name: ''
            rm -f /usr/share/wayland-sessions/${name}.desktop
          '') (lib.subtractLists cfg (lib.attrNames known))
        )}
      '';

      serviceConfig = {
        RemainAfterExit = true;
        Type = "oneshot";
      };

      wantedBy = [ "system-manager.target" ];
    };
  };

  options.myConfig.waylandSessions = lib.mkOption {
    default = [ ];

    description = ''
      Compositors to offer at the login screen. Entries are only useful when the
      matching compositor is installed by home-manager for the user logging in,
      so this is chosen per host rather than installed unconditionally.
    '';

    example = [ "niri" ];

    type = lib.types.listOf (
      lib.types.enum [
        "hyprland"
        "niri"
      ]
    );
  };
}
