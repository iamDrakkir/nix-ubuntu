{ ... }:

{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    settings = {
      "github.com" = {
        IdentityAgent = "/run/user/1000/proton-pass-agent";
      };
    };
  };
}
