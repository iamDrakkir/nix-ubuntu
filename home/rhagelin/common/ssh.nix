{ identity, ... }:

{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    settings = {
      "*" = {
        # Don't import on-disk keys into gpg-agent: the local keys are
        # unencrypted, so gpg-agent pops a pinentry asking for a passphrase
        # to protect them in its keystore on every first use.
        AddKeysToAgent = "no";
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
        # Use the on-disk key directly.
        IdentitiesOnly = "yes";
        IdentityFile = "~/.ssh/id_rsa";
      };
    };
  };
}
