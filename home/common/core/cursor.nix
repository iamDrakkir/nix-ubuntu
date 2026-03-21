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
    rose-pine = {
      package = pkgs.rose-pine-cursor;
      name = "BreezeX-RosePine-Linux";
    };
    bibata = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
    };
  };
  selected = themes.${cursorTheme};
in

{
  home.packages = [ selected.package ];

  home.pointerCursor = {
    package = selected.package;
    name = selected.name;
    size = cursorSize;
    gtk.enable = true;
    x11.enable = true;
    hyprcursor.enable = true;
  };

  gtk.enable = true;

  home.sessionVariables = {
    XCURSOR_THEME = selected.name;
    XCURSOR_SIZE = toString cursorSize;
    CURSOR_THEME = selected.name;
    CURSOR_SIZE = toString cursorSize;
  };
}
