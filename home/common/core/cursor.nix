{ pkgs, ... }:

# TODO: Ghostty and Walker still do not respect cursor theme/size after reboot
# despite all the following being correctly configured:
#   - GTK settings files (~/.config/gtk-{3,4}.0/settings.ini) are created with correct theme
#   - XCURSOR_THEME, XCURSOR_SIZE, XCURSOR_PATH environment variables are set
#   - GNOME dconf settings (org.gnome.desktop.interface) are configured
#   - Cursor theme symlinks exist in ~/.icons, ~/.local/share/icons, ~/.nix-profile/share/icons
#   - Default cursor index.theme files point to Bibata-Modern-Ice

let
  # ===== CURSOR THEME CONFIGURATION =====
  # Change 'cursorTheme' to switch between themes:
  #   - "rose-pine"
  #   - "bibata"
  cursorTheme = "bibata";

  cursorSize = 24;
  # ======================================

  themes = {
    bibata = {
      name = "Bibata-Modern-Ice";
      package = pkgs.bibata-cursors;
    };
    rose-pine = {
      name = "BreezeX-RosePine-Linux";
      package = pkgs.rose-pine-cursor;
    };
  };
  selected = themes.${cursorTheme};
in

{
  gtk.enable = true;
  home.packages = [ selected.package ];
  home.pointerCursor = {
    gtk.enable = true;
    hyprcursor.enable = true;
    name = selected.name;
    package = selected.package;
    size = cursorSize;
    x11.enable = true;
  };
  home.sessionVariables = {
    CURSOR_SIZE = toString cursorSize;
    CURSOR_THEME = selected.name;
    XCURSOR_SIZE = toString cursorSize;
    XCURSOR_THEME = selected.name;
  };
}
