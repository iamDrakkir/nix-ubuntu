{
  lib,
  config,
  inputs,
  system,
  ...
}:

# Noctalia Greeter as the login screen, driven by greetd.
#
# The privilege split is deliberate: greetd comes from apt, only the greeter UI
# comes from Nix.
#
# greetd is the privileged half — it runs as root, drives PAM, and registers the
# session with logind. A Nix-built greetd would link Nix's linux-pam, which
# searches its own store lib/security and ships no pam_systemd.so, so sessions
# would never get a seat or XDG_RUNTIME_DIR. pam-shim does not help: it calls
# pam_open_session in a forked helper, so logind would treat the shim as session
# leader instead of the compositor, breaking libseat's DRM master. The auth path
# therefore stays entirely on the distro's greetd and PAM stack.
#
# The greeter is the unprivileged half, links no PAM, and talks to the daemon
# only over $GREETD_SOCK. It must come from Nix: it needs wlroots 0.20 and noble
# only ships 0.17.
#
# The upstream scripts/setup_greeter_system.sh is intentionally NOT used. It
# looks for pam_systemd.so in /usr/lib/security and /lib/security, misses
# Ubuntu's /usr/lib/x86_64-linux-gnu/security/, and silently skips its PAM
# patch — which is redundant anyway, since common-session already loads
# pam_systemd.so. Its remaining useful effects are reproduced declaratively
# below.
let
  cfg = config.myConfig.greetd;
  greeter = inputs.noctalia-greeter.packages.${system}.default;

  # The Debian/Ubuntu package names its service account _greetd (user and
  # group), not upstream's `greeter`. The state directory is chowned to this, so
  # a mismatch leaves the greeter unable to read its own config.
  greeterUser = "_greetd";

  # greetd runs [initial_session] once per boot and falls back to the greeter
  # afterwards, so logging out lands on the greeter rather than straight back
  # in — the same shape as GDM's AutomaticLogin.
  initialSession = lib.optionalString cfg.autologin.enable ''

    [initial_session]
    command = "${config.myConfig.waylandSessionLaunchers.${cfg.autologin.session}}"
    user = "${cfg.autologin.user}"
  '';
in

{
  config = {
    assertions = [
      {
        assertion =
          cfg.autologin.enable -> lib.hasAttr cfg.autologin.session config.myConfig.waylandSessionLaunchers;

        message = ''
          myConfig.greetd.autologin.session is "${cfg.autologin.session}", which is not
          enabled in myConfig.waylandSessions on this host. greetd would autologin
          into a non-existent launcher and drop straight back to the greeter.
        '';
      }
    ];

    # replaceExisting: the greetd package ships its own config.toml, so
    # system-manager would find an unmanaged file already in place and skip it.
    #
    # vt = 7 keeps Ubuntu's default rather than upstream's vt = 1. The packaged
    # greetd.service declares After/Conflicts against getty@tty7 specifically, so
    # moving the greeter to vt1 would leave it racing getty@tty1. Staying on 7
    # also keeps tty1 free as a recovery console.
    environment.etc."greetd/config.toml" = {
      replaceExisting = true;

      text = ''
        [terminal]
        vt = 7

        [default_session]
        command = "${greeter}/bin/noctalia-greeter-session"
        user = "${greeterUser}"
        ${initialSession}'';
    };

    systemd = {
      services.noctalia-greeter-setup = {
        after = [ "sysinit-reactivation.target" ];
        description = "Prepare the Noctalia Greeter state directory and seed greeter.toml";

        script = ''
          if ! id -u ${greeterUser} >/dev/null 2>&1; then
            echo "Error: user '${greeterUser}' does not exist."
            echo "Install the distro greetd package first: sudo apt install greetd"
            exit 1
          fi

          install -d -m 0750 -o ${greeterUser} -g ${greeterUser} /var/lib/noctalia-greeter
          echo "✓ /var/lib/noctalia-greeter owned by ${greeterUser}"

          # Seed once only. Appearance Sync writes sync.toml and installs
          # wallpapers alongside it; it never rewrites greeter.toml, and
          # greeter.toml wins wherever both set the same key. Keeping it free of
          # appearance keys is what lets the shell drive the theme.
          if [ -e /var/lib/noctalia-greeter/greeter.toml ]; then
            echo "✓ greeter.toml present; leaving the runtime-owned copy untouched"
          else
            GREETER_USER=${greeterUser} \
              ${greeter}/bin/noctalia-greeter-apply-appearance --setup-system
            echo "✓ seeded greeter.toml"
          fi
        '';

        serviceConfig = {
          RemainAfterExit = true;
          Type = "oneshot";
        };

        wantedBy = [ "system-manager.target" ];
      };

      tmpfiles.settings."10-noctalia-greeter" = {
        # Noctalia Shell locates the sync helper by absolute path — it checks
        # /usr/bin then /usr/local/bin and never consults the Nix store, so
        # without this link "Sync Now" reports the helper as missing.
        # /usr/local/bin being root-owned also satisfies the greeter's
        # trusted-install check, which a user profile path would not.
        "/usr/local/bin/noctalia-greeter"."L+".argument = "${greeter}/bin/noctalia-greeter";

        "/usr/local/bin/noctalia-greeter-apply-appearance"."L+".argument =
          "${greeter}/bin/noctalia-greeter-apply-appearance";

        # polkitd only scans /usr/share/polkit-1/actions and will not follow a
        # store path — same reasoning as umbriel-portal.nix. This is the action
        # that authorises appearance sync.
        "/usr/share/polkit-1/actions/org.noctalia.greeter.apply-appearance.policy"."L+".argument =
          "${greeter}/share/polkit-1/actions/org.noctalia.greeter.apply-appearance.policy";
      };
    };
  };

  options.myConfig.greetd.autologin = {
    enable = lib.mkEnableOption ''
      logging straight into a session at boot, skipping the greeter. greetd
      runs this once per boot only, so logging out still returns to the greeter
    '';

    session = lib.mkOption {
      description = ''
        Which session to start, by `myConfig.waylandSessions` name. Must be one
        of the sessions enabled on this host, since it reuses the same launcher
        the login screen would run.
      '';

      example = "umbriel";
      type = lib.types.str;
    };

    user = lib.mkOption {
      description = "Account to log in automatically.";
      example = "drakkir";
      type = lib.types.str;
    };
  };
}
