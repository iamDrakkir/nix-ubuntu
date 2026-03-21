{
  lib,
  pkgs,
  ...
}:

{
  home.packages = [
    pkgs._1password-cli
    (lib.custom.wrapElectronApp pkgs pkgs._1password-gui "1password")
  ];

  xdg.desktopEntries."1password" = {
    name = "1Password";
    comment = "Password Manager";
    exec = "1password %U";
    icon = "${pkgs._1password-gui}/share/icons/hicolor/512x512/apps/1password.png";
    type = "Application";
    categories = [ "Utility" ];
  };
}
