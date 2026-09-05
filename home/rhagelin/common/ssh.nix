{ identity, ... }:

{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    settings = {
      "*" = {
        AddKeysToAgent = "yes";
      };

      "192.168.17.*" = {
        IdentitiesOnly = "no";
        IdentityAgent = "/run/user/${toString identity.uid}/gnupg/S.gpg-agent.ssh";
        IdentityFile = "~/.ssh/id_ed25519";
      };

      "github.com" = {
        IdentityAgent = "/run/user/${toString identity.uid}/proton-pass-agent";
      };

      "sevikcsprod01" = {
        # Password-only jump host — skip pubkey to avoid
        # "Too many authentication failures" before password prompt
        PreferredAuthentications = "password,keyboard-interactive";
      };

      "ssh.dev.azure.com" = {
        # Use the on-disk key directly; don't push it into gpg-agent
        # (which would trigger a "protect this key" passphrase prompt).
        AddKeysToAgent = "no";
        IdentitiesOnly = "yes";
        IdentityFile = "~/.ssh/id_rsa";
      };
    };
  };
}
