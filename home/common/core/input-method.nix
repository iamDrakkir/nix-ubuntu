{ ... }:

# Suppress Ubuntu's input-method autostart.
#
# /etc/xdg/autostart/im-launch.desktop starts ibus-daemon --xim and exports
# QT_IM_MODULE=ibus / GTK_IM_MODULE=simple / XMODIFIERS=@im=ibus. Nothing here
# needs it — the only configured engine is xkb:us::eng, a passthrough, while the
# real layout comes from the compositor via XKB_DEFAULT_LAYOUT (see
# hosts/common/core/keyboard.nix) — and --xim with QT_IM_MODULE=ibus is a known
# source of input quirks in Qt apps on Wayland.
#
# Hidden=true is the XDG-specified way for a user entry to cancel a system one:
# ~/.config/autostart shadows /etc/xdg/autostart by filename, and
# systemd-xdg-autostart-generator honours it, leaving the dpkg file untouched.
#
# To re-enable an input method (CJK and similar), remove this file and configure
# the Wayland input method properly rather than relying on --xim.
{
  xdg.configFile."autostart/im-launch.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=im-launch
    Exec=true
    Hidden=true
    X-GNOME-Autostart-enabled=false
  '';
}
