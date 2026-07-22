{ ... }:

{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    settings = {
      "*" = {
        AddKeysToAgent = "yes";
      };
      "192.168.17.*" = {
        IdentitiesOnly = false;
        IdentityAgent = "/run/user/1735616652/gnupg/S.gpg-agent.ssh";
        IdentityFile = "~/.ssh/id_ed25519";
      };
      "github.com" = {
        IdentityAgent = "/run/user/1735616652/proton-pass-agent";
      };
      "sevikcsprod01" = {
        # Password-only jump host — skip pubkey to avoid
        # "Too many authentication failures" before password prompt
        PreferredAuthentications = "password,keyboard-interactive";
      };
      "ssh.dev.azure.com" = {
        IdentitiesOnly = true;
        IdentityFile = "~/.ssh/id_rsa";
      };
    };
  };
}
