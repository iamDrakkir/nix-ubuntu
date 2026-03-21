{
  lib,
  pkgs,
  ...
}:

{
  home.packages = [ (lib.custom.wrapElectronApp pkgs pkgs.discord "discord") ];

  xdg.desktopEntries.discord = {
    name = "Discord";
    comment = "All-in-one cross-platform voice and text chat for gamers";
    exec = "discord %U";
    icon = "${pkgs.discord}/share/pixmaps/discord.png";
    type = "Application";
    categories = [
      "Network"
      "InstantMessaging"
    ];
    mimeType = [ "x-scheme-handler/discord" ];
  };
}
