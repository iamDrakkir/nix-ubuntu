{
  username,
  homeDirectory,
  ...
}:

{
  home = {
    inherit username homeDirectory;
    stateVersion = "25.11";
  };

  programs.home-manager.enable = true;

  nix.gc = {
    automatic = true;
    options = "--delete-older-than 30d";
  };
}
