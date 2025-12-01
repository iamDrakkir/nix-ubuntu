{ pkgs, ... }:

let
    wrapElectronApp = app: name: pkgs.writeShellScriptBin name ''
      exec ${app}/bin/${name} --no-sandbox "$@"
    '';
in {
  home.packages = with pkgs; [
    vlc
    hyprpanel
    hyprpaper
    rofi
    waybar
    walker
    sherlock-launcher
    ghostty
    foot
    kitty
    alacritty
    (wrapElectronApp discord "discord")
    qbittorrent
    (wrapElectronApp vscode "code")
    steam
  ];

  # Create desktop entries for wrapped applications
  xdg.desktopEntries = {
    discord = {
      name = "Discord";
      comment = "All-in-one cross-platform voice and text chat for gamers";
      exec = "discord %U";
      icon = "${pkgs.discord}/share/pixmaps/discord.png";
      type = "Application";
      categories = [ "Network" "InstantMessaging" ];
      mimeType = [ "x-scheme-handler/discord" ];
    };
    
    vscode = {
      name = "Visual Studio Code";
      comment = "Code Editing. Redefined.";
      exec = "code %F";
      icon = "${pkgs.vscode}/share/pixmaps/vscode.png";
      type = "Application";
      categories = [ "Utility" "TextEditor" "Development" "IDE" ];
      mimeType = [
        "text/plain"
        "inode/directory"
        "application/x-code-workspace"
      ];
    };
  };
  programs.zen-browser.policies = {
    AutofillAddressEnabled = true;
    AutofillCreditCardEnabled = false;
    DisableAppUpdate = true;
    DisableFeedbackCommands = true;
    DisableFirefoxStudies = true;
    DisablePocket = true;
    DisableTelemetry = true;
    DontCheckDefaultBrowser = true;
    NoDefaultBookmarks = true;
    OfferToSaveLogins = false;
    EnableTrackingProtection = {
      Value = true;
      Locked = true;
      Cryptomining = true;
      Fingerprinting = true;
    };
  };
}

