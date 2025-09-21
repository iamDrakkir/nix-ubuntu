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
    xdg-desktop-portal-gtk
    (wrapElectronApp discord "discord")
  ];
}

