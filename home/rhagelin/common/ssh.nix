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

      "ssh.dev.azure.com" = {
        identityFile = "~/.ssh/id_rsa";
        identitiesOnly = true;
      };

      "sevikcsprod01" = {
        extraOptions = {
          # Password-only jump host — skip pubkey to avoid
          # "Too many authentication failures" before password prompt
          PreferredAuthentications = "password,keyboard-interactive";
        };
      };

      "192.168.17.*" = {
        identityFile = "~/.ssh/id_ed25519";
        identitiesOnly = false;
      };
    };
  };
}
