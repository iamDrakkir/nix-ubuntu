{ ... }:

# Keyboard layout for the two places beyond the compositors, which set it
# themselves:
#   - KEYMAP in vconsole.conf, so the TTYs and `localectl` agree.
#   - XKB_DEFAULT_* in the session environment, because libxkbcommon's "system
#     default" means those variables and otherwise falls back to "us". Nothing
#     in Wayland consults localed.
{
  environment = {
    # Ubuntu ships /etc/vconsole.conf as a symlink to /etc/default/keyboard,
    # which console-setup owns and which carries XKB* but no KEYMAP — leaving
    # the console keymap unset. Replacing the symlink is the trade: KEYMAP is
    # declared here, and a later `dpkg-reconfigure keyboard-configuration` will
    # no longer propagate into this file (it still updates /etc/default/keyboard
    # for console-setup itself, which stays "se" to match).
    etc."vconsole.conf" = {
      replaceExisting = true;

      text = ''
        KEYMAP=se
        XKBMODEL=pc105
        XKBLAYOUT=se
        XKBVARIANT=
        XKBOPTIONS=
      '';
    };

    # Read by the systemd user manager via /etc/environment.d, so compositors
    # and apps started as user services inherit it.
    variables = {
      XKB_DEFAULT_LAYOUT = "se";
      XKB_DEFAULT_MODEL = "pc105";
    };
  };
}
