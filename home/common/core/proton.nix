{
  lib,
  config,
  pkgs,
  ...
}:

# Proton Pass, and the SSH agent that serves our git keys.
#
# Why the login wrapper below exists
# ----------------------------------
# `pass-cli` encrypts its on-disk session with a "local key" that its default
# `keyring` provider stores in the *kernel* keyring, not in gnome-keyring:
#
#   $ keyctl show @s
#    \_ user: keyring:cli-local-key:<fingerprint>@ProtonPassCLI
#    \_ keyring: _persistent.1000
#        \_ user: keyring:cli-local-key:<fingerprint>@ProtonPassCLI
#
# Kernel keyrings live in kernel memory: `_persistent.1000` survives logout, but
# nothing survives a reboot. So every boot the local key is gone, the encrypted
# session can't be opened, the SSH agent has no keys, and `git push` fails with
# a credential error until `pass-cli login` is run by hand.
#
# pass-cli has no "unlock" step to hook into — recovery is a full web login — so
# instead of failing, detect the empty agent at push time and run that login.
let
  # `pass-cli login` is an interactive web flow, but git drives ssh with pipes
  # on stdio, so it has nowhere to talk. Borrow the controlling terminal when
  # there is one, otherwise open a terminal window for it.
  gitSsh = pkgs.writeShellApplication {
    name = "git-ssh-proton";

    runtimeInputs = with pkgs; [
      libnotify
      openssh
      proton-pass-cli
      systemd
    ];

    text = ''
      # 0 = agent has keys. 1 = agent reachable but empty, 2 = no agent:
      # both mean "not logged in".
      if ! ssh-add -l >/dev/null 2>&1; then
        # Redirect stderr first: bash reports a failed >/dev/tty redirection on
        # whatever stderr is at that point, so the probe must be silenced before
        # it is attempted.
        if [ -c /dev/tty ] && (: 2>/dev/null >/dev/tty); then
          {
            echo "No SSH keys in the Proton Pass agent — logging in."
            pass-cli login
          } </dev/tty >/dev/tty 2>&1
        else
          notify-send "Proton Pass" "Logging in to unlock your SSH keys" || true
          ${lib.getExe config.programs.ghostty.package} -e pass-cli login || true
        fi

        # The agent unit fails while logged out and retries every 10s; kick it
        # so the fresh session is picked up now rather than up to 10s from now.
        systemctl --user restart proton-pass-agent || true

        # Wait for keys rather than assuming the login has finished: the
        # terminal spawned above may return immediately instead of blocking,
        # and a web login takes as long as it takes. Exits as soon as the agent
        # has keys, so the common case costs one iteration.
        for _ in $(seq 1 240); do
          if ssh-add -l >/dev/null 2>&1; then break; fi
          sleep 0.5
        done
      fi

      exec ssh "$@"
    '';
  };
in

{
  home.packages = with pkgs; [
    proton-pass
    # proton-vpn  # Disabled on Ubuntu 24.04: the Nix package bundles libnm from
    # NetworkManager 1.56, but Ubuntu 24.04's NM daemon is 1.46. On connect, the
    # app rewrites the active connection to add the VPN server route and libnm 1.56
    # serializes the 802-11-wireless.mac-address-denylist property (added in NM 1.48),
    # which the 1.46 daemon rejects -> crash ("mac-address-denylist: unknown property").
    # Using Proton's official .deb instead (links against host NM 1.46, so it matches).
    # Re-enable once the host NetworkManager is >= 1.48 (e.g. Ubuntu 26.04 ships NM 1.56).
  ];

  programs.git.settings.core.sshCommand = lib.getExe gitSsh;

  services.proton-pass-agent = {
    enable = true;
  };

  # The agent fails on boot if not logged in yet; keep retrying until it succeeds
  systemd.user.services.proton-pass-agent = {
    Service = {
      Restart = "on-failure";
      RestartSec = "10s";
    };
  };
}
