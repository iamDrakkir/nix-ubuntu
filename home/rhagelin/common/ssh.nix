{ ... }:

{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    matchBlocks = {
      "*" = {
        extraOptions = {
          AddKeysToAgent = "yes";
        };
      };
      "192.168.17.*" = {
        identitiesOnly = false;
        identityAgent = "/run/user/1735616652/gnupg/S.gpg-agent.ssh";
        identityFile = "~/.ssh/id_ed25519";
      };
      "github.com" = {
        identityAgent = "/run/user/1735616652/proton-pass-agent";
      };
      "sevikcsprod01" = {
        extraOptions = {
          # Password-only jump host — skip pubkey to avoid
          # "Too many authentication failures" before password prompt
          PreferredAuthentications = "password,keyboard-interactive";
        };
      };
      "ssh.dev.azure.com" = {
        identitiesOnly = true;
        identityFile = "~/.ssh/id_rsa";
      };
    };
  };
}
