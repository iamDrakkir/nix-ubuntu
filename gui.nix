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
    # xdg-desktop-portal-gtk
    # ghostty
    foot
    kitty
    (wrapElectronApp discord "discord")
    qbittorrent
    (wrapElectronApp vscode "code")

  ];
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

