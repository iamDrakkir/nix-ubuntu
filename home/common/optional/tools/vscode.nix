{
  lib,
  pkgs,
  ...
}:

{
  home.packages = [ (lib.custom.wrapElectronApp pkgs pkgs.vscode "code") ];

  xdg.desktopEntries.vscode = {
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
    settings = {
      StartupWMClass = "Code";
    };
  };
}
