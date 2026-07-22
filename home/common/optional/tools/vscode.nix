{
  lib,
  pkgs,
  ...
}:

{
  home.packages = [ (lib.custom.wrapElectronApp pkgs pkgs.vscode "code") ];

  xdg.desktopEntries.vscode = {
    categories = [
      "Utility"
      "TextEditor"
      "Development"
      "IDE"
    ];
    comment = "Code Editing. Redefined.";
    exec = "code %F";
    icon = "${pkgs.vscode}/share/pixmaps/vscode.png";
    mimeType = [
      "text/plain"
      "inode/directory"
      "application/x-code-workspace"
    ];
    name = "Visual Studio Code";
    settings = {
      StartupWMClass = "Code";
    };
    type = "Application";
  };
}
