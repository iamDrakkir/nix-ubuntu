{ ... }:

# Register the system-manager shells as valid login shells.
#
# The login shell is set to a /run/system-manager/sw/bin path at the distro
# level rather than declaratively (see the note in users/drakkir/default.nix).
# Those paths are not in /etc/shells, and anything validating a login shell
# against it rejects the account — pkexec most visibly, refusing to run at all,
# which silently breaks every privileged desktop action routed through it.
#
# /etc/shells is a dpkg conffile, so this appends idempotently rather than
# taking it over with environment.etc: owning the file would fight dpkg on
# upgrade and drop entries added later by other shell packages. system-manager
# has no environment.shells option to express this natively.
#
# bash stays registered even though zsh is the actual login shell — dropping it
# would strand the account if zsh ever fails to activate.
{
  systemd.services.register-login-shell = {
    # /run/system-manager/sw is a symlink created by system-manager-path.service,
    # so at boot this would otherwise run before the shells it is registering
    # exist — it succeeds during activation and then fails on every reboot.
    after = [ "system-manager-path.service" ];
    description = "Register the system-manager shells in /etc/shells";
    requires = [ "system-manager-path.service" ];

    script = ''
      for login_shell in /run/system-manager/sw/bin/bash /run/system-manager/sw/bin/zsh; do
        if [ ! -e "$login_shell" ]; then
          echo "Error: $login_shell does not exist; is system-manager activated?"
          exit 1
        fi

        if grep -qxF "$login_shell" /etc/shells; then
          echo "✓ $login_shell already registered in /etc/shells"
        else
          printf '%s\n' "$login_shell" >> /etc/shells
          echo "✓ appended $login_shell to /etc/shells"
        fi
      done
    '';

    serviceConfig = {
      RemainAfterExit = true;
      Type = "oneshot";
    };

    wantedBy = [ "system-manager.target" ];
  };
}
