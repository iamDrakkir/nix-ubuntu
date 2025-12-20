{
  config,
  lib,
  pkgs,
  homeDirectory,
  ...
}:

{
  config = lib.mkIf config.myConfig.desktop.hyprland.enable {
    wayland.windowManager.hyprland = {
      enable = true;
      package = pkgs.hyprland;
      
      # Minimal settings to avoid warning about empty config
      settings = {
        # Set default terminal and menu
        "$terminal" = "ghostty";
        "$menu" = "rofi -show drun";
        
        # Monitor configuration (auto-detect)
        monitor = [ ",preferred,auto,auto" ];
        
        # Input configuration
        input = {
          kb_layout = "se";
          follow_mouse = 1;
          sensitivity = 0;
        };
        
        # General appearance
        general = {
          gaps_in = 5;
          gaps_out = 20;
          border_size = 2;
          "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
          "col.inactive_border" = "rgba(595959aa)";
          layout = "dwindle";
        };
        
        # Basic keybindings
        "$mainMod" = "SUPER";
        bind = [
          "$mainMod, RETURN, exec, $terminal"
          "$mainMod, Q, killactive"
          "$mainMod, M, exit"
          "$mainMod, V, togglefloating"
          "$mainMod, SPACE, exec, $menu"
          
          # Window navigation
          "$mainMod, left, movefocus, l"
          "$mainMod, right, movefocus, r"
          "$mainMod, up, movefocus, u"
          "$mainMod, down, movefocus, d"
          
          # Workspace switching
          "$mainMod, 1, workspace, 1"
          "$mainMod, 2, workspace, 2"
          "$mainMod, 3, workspace, 3"
          "$mainMod, 4, workspace, 4"
          "$mainMod, 5, workspace, 5"
          "$mainMod, 6, workspace, 6"
          "$mainMod, 7, workspace, 7"
          "$mainMod, 8, workspace, 8"
          "$mainMod, 9, workspace, 9"
          "$mainMod, 0, workspace, 10"
          
          # Move window to workspace
          "$mainMod SHIFT, 1, movetoworkspace, 1"
          "$mainMod SHIFT, 2, movetoworkspace, 2"
          "$mainMod SHIFT, 3, movetoworkspace, 3"
          "$mainMod SHIFT, 4, movetoworkspace, 4"
          "$mainMod SHIFT, 5, movetoworkspace, 5"
          "$mainMod SHIFT, 6, movetoworkspace, 6"
          "$mainMod SHIFT, 7, movetoworkspace, 7"
          "$mainMod SHIFT, 8, movetoworkspace, 8"
          "$mainMod SHIFT, 9, movetoworkspace, 9"
          "$mainMod SHIFT, 0, movetoworkspace, 10"
        ];
        
        # Mouse bindings
        bindm = [
          "$mainMod, mouse:272, movewindow"
          "$mainMod, mouse:273, resizewindow"
        ];
        
        # Multimedia keys
        bindel = [
          ",XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
          ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
          ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
          ",XF86MonBrightnessUp, exec, brightnessctl -e4 -n2 set 5%+"
          ",XF86MonBrightnessDown, exec, brightnessctl -e4 -n2 set 5%-"
        ];
      };
      
      # Autostart programs
      extraConfig = ''
        # Autostart
        exec-once = hyprpanel &
        exec-once = hyprpaper &
        exec-once = dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
      '';
    };

    # Symlink hyprland config from dotfiles repo
    # Disabled: hyprland config files are missing from dotfiles
    # home.file = lib.custom.symlink.mkDotfilesLinks config homeDirectory [ "hypr" ];

    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-gnome
      ];
      config = {
        hyprland = {
          default = [
            "hyprland"
            "gtk"
          ];
          "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
        };
        gnome = {
          default = [
            "gnome"
            "gtk"
          ];
          "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
        };
      };
    };

    # Configure systemd user environment to find portal service files
    xdg.configFile."systemd/user.conf" = {
      text = ''
        [Manager]
        ManagerEnvironment="XDG_DATA_DIRS=/usr/local/share:/usr/share:${homeDirectory}/.local/state/nix/profiles/profile/share/:/nix/var/nix/profiles/default/share"
      '';
    };

    # Hyprland-specific packages
    home.packages = with pkgs; [
      hyprpanel
      hyprpaper
    ];
  };
}
