{ identity, ... }:

{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    settings = {
      "github.com" = {
        IdentityAgent = "/run/user/${toString identity.uid}/proton-pass-agent";
      };
    };
  };
}
