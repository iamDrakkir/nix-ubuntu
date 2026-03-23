{ ... }:

{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    matchBlocks = {
      "github.com" = {
        identityAgent = "/run/user/1000/proton-pass-agent";
      };
    };
  };
}
