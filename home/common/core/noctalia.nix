{
  lib,
  config,
  pkgs,
  inputs,
  system,
  username,
  ...
}:

let
  # Every Noctalia bind in neutral form; the per-compositor variants are
  # expanded from this below. `cmd` is the IPC command, `key` the chord in the
  # syntax niri and umbriel share, `hyprKey` hyprland's spelling of it.
  binds = {
    # Control Center tabs. Audio, Bluetooth and network have no standalone
    # panels; they are contexts of the control-center panel.
    audioPanel = {
      cmd = "panel-toggle control-center audio";
      hyprKey = "SUPER + CTRL + A";
      key = "Mod+Ctrl+A";
    };

    bluetoothPanel = {
      cmd = "panel-toggle control-center bluetooth";
      hyprKey = "SUPER + CTRL + B";
      key = "Mod+Ctrl+B";
    };

    brightnessDown = {
      cmd = "brightness-down";
      hyprKey = "XF86MonBrightnessDown";
      key = "XF86MonBrightnessDown";
    };

    brightnessUp = {
      cmd = "brightness-up";
      hyprKey = "XF86MonBrightnessUp";
      key = "XF86MonBrightnessUp";
    };

    clipboard = {
      cmd = "panel-toggle clipboard";
      hyprKey = "SUPER + SHIFT + V";
      key = "Mod+Shift+V";
    };

    # Emoji picker: the launcher's built-in emoji provider replaces emote.
    emoji = {
      cmd = "panel-toggle launcher /emo";
      hyprKey = "SUPER + CTRL + E";
      key = "Mod+Ctrl+E";
    };

    launcher = {
      cmd = "panel-toggle launcher";
      hyprKey = "SUPER + SPACE";
      key = "Mod+Space";
    };

    launcherProviders = {
      cmd = "panel-toggle launcher /";
      hyprKey = "SUPER + ALT + SPACE";
      key = "Mod+Alt+Space";
    };

    # No `key`: XF86Lock is not a valid key in niri or umbriel.
    lockKey = {
      cmd = "session lock";
      hyprKey = "XF86Lock";
    };

    lockScreen = {
      cmd = "session lock";
      hyprKey = "SUPER + CTRL + Escape";
      key = "Mod+Ctrl+Escape";
    };

    micMute = {
      cmd = "mic-mute";
      hyprKey = "XF86AudioMicMute";
      key = "XF86AudioMicMute";
    };

    networkPanel = {
      cmd = "panel-toggle control-center network";
      hyprKey = "SUPER + CTRL + W";
      key = "Mod+Ctrl+W";
    };

    nightlight = {
      cmd = "nightlight-toggle";
      hyprKey = "SUPER + CTRL + N";
      key = "Mod+Ctrl+N";
    };

    volumeDown = {
      cmd = "volume-down";
      hyprKey = "XF86AudioLowerVolume";
      key = "XF86AudioLowerVolume";
    };

    volumeMute = {
      cmd = "volume-mute";
      hyprKey = "XF86AudioMute";
      key = "XF86AudioMute";
    };

    volumeUp = {
      cmd = "volume-up";
      hyprKey = "XF86AudioRaiseVolume";
      key = "XF86AudioRaiseVolume";
    };
  };
  # IPC command as a single shell string (e.g. "noctalia msg panel-toggle launcher")
  ipcCmd = cmd: lib.concatStringsSep " " (noctaliaIPC cmd);
  # The same bind in each compositor's own shape: hyprland wants a { key; cmd; }
  # pair (see hyprland/default.nix mkShellBind), niri an argv list, umbriel a
  # "spawn:" action. Binds without a `key` are hyprland-only.
  keybinds = lib.mapAttrs (
    _: b:
    {
      hyprland = {
        cmd = ipcCmd b.cmd;
        key = b.hyprKey;
      };
    }
    // lib.optionalAttrs (b ? key) {
      niri = {
        action = noctaliaIPC b.cmd;
        inherit (b) key;
      };

      umbriel = {
        action = "spawn:${ipcCmd b.cmd}";
        inherit (b) key;
      };
    }
  ) binds;
  # Helper function for Noctalia IPC commands (v5+ uses `noctalia msg <command>`)
  noctaliaIPC =
    cmd:
    [
      "noctalia"
      "msg"
    ]
    ++ (lib.splitString " " cmd);
  # On AD domain hosts the account only exists in SSSD. Nix's glibc resolves it
  # by dlopen()ing libnss_sss.so.2, which its own store lib/ does not contain,
  # so without help Noctalia cannot see the user at all.
  #
  # Give the *binary* a DT_RPATH pointing at Nix's sssd instead. glibc's NSS
  # dlopen searches the main executable's DT_RPATH; DT_RUNPATH is not searched
  # for dlopen, hence --force-rpath.
  #
  # This used to be done with LD_LIBRARY_PATH on the compositor's spawn, which
  # broke the lockscreen. The variable is inherited, and pam_shim_server -- the
  # *host* binary that performs the actual PAM conversation -- would then load
  # Nix's libnss_sss.so.2 against the host glibc and lose every NSS lookup.
  # pam_authenticate still passed (pam_sss talks to sssd over a socket and only
  # needs the username string), but the account stack did not: pam_unix
  # returned PAM_USER_UNKNOWN(10), common-account's
  # `[success=1 ... default=ignore]` fell through to `requisite pam_deny.so`,
  # and Noctalia saw PAM_AUTH_ERR(7) -- correct password, refused unlock.
  #
  # An RPATH belongs to this one ELF and is not inherited, so the helper keeps
  # the host's own NSS and nothing else in the session is affected.
  withSssdNss =
    drv:
    pkgs.runCommand "${drv.name}-sssd-nss" { nativeBuildInputs = [ pkgs.patchelf ]; } ''
      cp -r ${drv} $out
      chmod -R u+w $out

      # bin/noctalia is a makeWrapper script holding an absolute path to the
      # real ELF, so repoint it at our copy before patching that copy.
      substituteInPlace $out/bin/noctalia \
        --replace-fail "${drv}/bin/.noctalia-wrapped" "$out/bin/.noctalia-wrapped"

      patchelf --force-rpath --add-rpath "${pkgs.sssd}/lib" $out/bin/.noctalia-wrapped
    '';
in

{
  config = {
    home = {
      # Noctalia v13+ stores all transferable config (bar layout, enabled
      # plugins, theme/colors, and every GUI setting) in a single TOML file at
      # $XDG_STATE_HOME/noctalia/settings.toml. Out-of-store symlink it to the
      # live repo so GUI edits persist there and rebuilds aren't needed.
      file.".local/state/noctalia/settings.toml".source =
        lib.custom.symlink.link config "noctalia/settings.toml";
    };

    myConfig.programs.noctalia.keybindings = keybinds;
    programs.noctalia = {
      enable = true;

      # Two host-integration patches on the upstream package: PAM redirected to
      # the host stack (core/pam-shim.nix) so the lockscreen can authenticate,
      # and the SSSD NSS module made reachable so the account stack knows the
      # user. The latter is only needed where the username is fully qualified,
      # i.e. an AD domain host.
      package =
        let
          withPam = config.lib.pamShim.replacePam inputs.noctalia.packages.${system}.default;
        in
        if lib.hasInfix "@" username then withSssdNss withPam else withPam;
    };
  };

  imports = [ inputs.noctalia.homeModules.default ];

  options.myConfig.programs.noctalia.keybindings = lib.mkOption {
    default = { };
    description = "Keybinding definitions for Noctalia IPC commands";
    type = lib.types.attrs;
  };
}
