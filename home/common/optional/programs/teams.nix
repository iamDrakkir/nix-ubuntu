{ pkgs, ... }:

{
  home.packages = with pkgs; [
    teams-for-linux
  ];

  xdg.desktopEntries.teams-for-linux = {
    name = "Microsoft Teams for Linux";
    comment = "Unofficial Microsoft Teams client for Linux";
    exec = "teams-for-linux --class=teams-for-linux %U";
    icon = "teams-for-linux";
    type = "Application";
    categories = [ "Network" "InstantMessaging" "Chat" ];
    mimeType = [ "x-scheme-handler/msteams" ];
  };
}
