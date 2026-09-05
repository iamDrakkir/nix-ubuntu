{ pkgs, ... }:

{
  home.packages = with pkgs; [
    teams-for-linux
  ];

  xdg.desktopEntries.teams-for-linux = {
    categories = [
      "Network"
      "InstantMessaging"
      "Chat"
    ];

    comment = "Unofficial Microsoft Teams client for Linux";
    exec = "teams-for-linux --class=teams-for-linux %U";
    icon = "teams-for-linux";
    mimeType = [ "x-scheme-handler/msteams" ];
    name = "Microsoft Teams for Linux";
    type = "Application";
  };
}
