{ ... }:

{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    settings = {
      "*" = {
        AddKeysToAgent = "yes";
      };

      "github.com" = {
        IdentityAgent = "/run/user/1735616652/proton-pass-agent";
      };

      "ssh.dev.azure.com" = {
        IdentityFile = "~/.ssh/id_rsa";
        IdentitiesOnly = "yes";
      };

      "sevikcsprod01" = {
        # Password-only jump host — skip pubkey to avoid
        # "Too many authentication failures" before password prompt
        PreferredAuthentications = "password,keyboard-interactive";
      };

      "192.168.17.*" = {
        IdentityFile = "~/.ssh/id_ed25519";
        IdentitiesOnly = "no";
        IdentityAgent = "/run/user/1735616652/gnupg/S.gpg-agent.ssh";
      };
    };
  };
}
