{
  config,
  lib,
  pkgs,
  ...
}:

let
  wrapElectronApp =
    app: name:
    pkgs.writeShellScriptBin name ''
      exec ${app}/bin/${name} --no-sandbox "$@"
    '';
in
{ # TODO: these should porbebly be moved to some other file... not sure where tho. and use programs.#.enable for most if possible
  home.packages = with pkgs; [
    vlc
    walker
    sherlock-launcher
    foot
    kitty
    (wrapElectronApp discord "discord")
    qbittorrent
    (wrapElectronApp vscode "code")
    _1password-cli
    (wrapElectronApp _1password-gui "1password")
  ];

  # Create desktop entries for wrapped applications
  xdg.desktopEntries = {
    discord = {
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

    vscode = {
      name = "Visual Studio Code";
      comment = "Code Editing. Redefined.";
      exec = "code %F";
      icon = "${pkgs.vscode}/share/pixmaps/vscode.png";
      type = "Application";
      categories = [
        "Utility"
        "TextEditor"
        "Development"
        "IDE"
      ];
      mimeType = [
        "text/plain"
        "inode/directory"
        "application/x-code-workspace"
      ];
    };
  };
}
