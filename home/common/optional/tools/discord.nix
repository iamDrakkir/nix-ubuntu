{
  lib,
  pkgs,
  ...
}:

{
  home.packages = [ (lib.custom.wrapElectronApp pkgs pkgs.discord "discord") ];

  xdg.desktopEntries.discord = {
    categories = [
      "Network"
      "InstantMessaging"
    ];
    comment = "All-in-one cross-platform voice and text chat for gamers";
    exec = "discord %U";
    icon = "${pkgs.discord}/share/pixmaps/discord.png";
    mimeType = [ "x-scheme-handler/discord" ];
    name = "Discord";
    type = "Application";
  };
}
