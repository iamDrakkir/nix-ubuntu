{ lib, pkgs, ... }:

{
  programs.gpg.enable = true;

  # Runs gpg-agent (socket-activated) and exposes it as an SSH agent.
  # This replaces the manual steps:
  #   export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
  #   gpgconf --launch gpg-agent
  #
  # With enableSshSupport, home-manager sets SSH_AUTH_SOCK to the gpg-agent
  # socket in your shell init automatically. That is only the *default* agent:
  # ssh.nix uses per-host IdentityAgent, so github.com still goes to
  # proton-pass-agent while 192.168.17.* explicitly uses the gpg-agent socket.
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;

    pinentry.package = pkgs.pinentry-gnome3;
  };

  # pinentry-gnome3 needs gcr to work outside a full GNOME session
  # (e.g. hyprland/niri).
  home.packages = [ pkgs.gcr ];

  # Both services.gpg-agent and services.proton-pass-agent try to own the
  # global SSH_AUTH_SOCK (shell export + socket provider unit) without
  # mkDefault, so they conflict. We make gpg-agent (yubikey) the default
  # agent; proton-pass is still reached via per-host IdentityAgent in ssh.nix.
  sshAuthSock = {
    initialization = {
      bash = lib.mkForce ''
        unset SSH_AGENT_PID
        export SSH_AUTH_SOCK="$(${pkgs.gnupg}/bin/gpgconf --list-dirs agent-ssh-socket)"
      '';
      fish = lib.mkForce ''
        set -e SSH_AGENT_PID
        set -x SSH_AUTH_SOCK (${pkgs.gnupg}/bin/gpgconf --list-dirs agent-ssh-socket)
      '';
      nushell = lib.mkForce ''
        $env.SSH_AUTH_SOCK = (${pkgs.gnupg}/bin/gpgconf --list-dirs agent-ssh-socket)
      '';
    };
    systemd.socketProviderUnit = lib.mkForce "gpg-agent-ssh.socket";
  };
}
