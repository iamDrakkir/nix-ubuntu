{
  config,
  hostname,
  lib,
  pkgs,
  homeDirectory,
  ...
}:

let
  isWorkHost = hostname == "work";
  # Swap browser profile shortcuts based on host
  # Create the full modifier string with proper spacing
  browserPersonalBind = if isWorkHost then "$mainMod SHIFT, B" else "$mainMod, B";
  browserWorkBind = if isWorkHost then "$mainMod, B" else "$mainMod SHIFT, B";
in

{
  # Wayland utilities for Hyprland
  home.packages = with pkgs; [
    grim # Screenshot tool
    slurp # Screen area selector
    wl-clipboard # Clipboard utilities
    wl-clipboard-x11 # X11 compatibility
    cliphist # Clipboard history
    hyprpanel # Panel
    hyprpaper # Wallpaper
    hypridle # Idle management
    hyprlock # Lock screen
    brightnessctl # Brightness control
    playerctl # Media player control
    emote # Emoji picker
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    package = pkgs.hyprland;

    settings = {
      # Variables
      "$terminal" = "ghostty";
      "$menu" = "rofi -show drun";
      "$browser" = "zen";
      "$mainMod" = "SUPER";

      # Catppuccin Mocha color scheme
      "$rosewater" = "rgb(f5e0dc)";
      "$flamingo" = "rgb(f2cdcd)";
      "$pink" = "rgb(f5c2e7)";
      "$mauve" = "rgb(cba6f7)";
      "$red" = "rgb(f38ba8)";
      "$maroon" = "rgb(eba0ac)";
      "$peach" = "rgb(fab387)";
      "$yellow" = "rgb(f9e2af)";
      "$green" = "rgb(a6e3a1)";
      "$teal" = "rgb(94e2d5)";
      "$sky" = "rgb(89dceb)";
      "$sapphire" = "rgb(74c7ec)";
      "$blue" = "rgb(89b4fa)";
      "$lavender" = "rgb(b4befe)";
      "$text" = "rgb(cdd6f4)";
      "$subtext1" = "rgb(bac2de)";
      "$subtext0" = "rgb(a6adc8)";
      "$overlay2" = "rgb(9399b2)";
      "$overlay1" = "rgb(7f849c)";
      "$overlay0" = "rgb(6c7086)";
      "$surface2" = "rgb(585b70)";
      "$surface1" = "rgb(45475a)";
      "$surface0" = "rgb(313244)";
      "$base" = "rgb(1e1e2e)";
      "$mantle" = "rgb(181825)";
      "$crust" = "rgb(11111b)";

      # Environment variables
      env = [
        "QT_QPA_PLATFORM,wayland"
        "XDG_CURRENT_DESKTOP,Hyprland"
      ];

      # Monitor configuration
      monitor = [
        "DP-1,1920x1080@120,auto,1"
        "DP-3,2560x1440@144,auto,1"
        ",preferred,auto,1"
      ];

      # Input configuration
      input = {
        kb_layout = "se";
        kb_variant = "";
        kb_model = "";
        kb_options = "";
        numlock_by_default = true;
        follow_mouse = 1;
        mouse_refocus = false;
        sensitivity = 0;
        touchpad = {
          natural_scroll = false;
        };
      };

      # General appearance
      general = {
        gaps_in = 3;
        gaps_out = 5;
        border_size = 2;
        "col.active_border" = "$peach";
        "col.inactive_border" = "$rosewater";
        layout = "dwindle";
      };

      # Decoration
      decoration = {
        rounding = 10;
        blur = {
          enabled = true;
          size = 6;
          passes = 2;
          new_optimizations = true;
          ignore_opacity = true;
          xray = true;
          blurls = "waybar";
        };
        active_opacity = 1.0;
        inactive_opacity = 1.0;
        fullscreen_opacity = 1.0;
        shadow = {
          enabled = true;
          range = 30;
          render_power = 3;
          color = "0x66000000";
        };
      };

      # Animations
      animations = {
        enabled = false;
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        animation = [
          "windows, 1, 2, myBezier"
          "windowsOut, 1, 2, default, popin 80%"
          "border, 1, 2, default"
          "borderangle, 1, 2, default"
          "fade, 1, 2, default"
          "workspaces, 1, 2, default"
        ];
      };

      # Layout
      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      # Misc
      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
      };

      # Window rules
      windowrule = [
        "float,title:^(pavucontrol)$"
        "float,title:^(blueman-manager)$"
        "float,title:^(nm-connection-editor)$"
        "float,title:^(dotfiles-floating)$"
        "opacity 1 override,title:^(firefox)$"
        "opacity 1 override,title:^(zen-alpha)$"
      ];

      windowrulev2 = [
        "bordercolor $mauve, fullscreen:1"
        "stayfocused, title:^()$,class:^(steam)$"
        "minsize 1 1, title:^()$,class:^(steam)$"
      ];

      layerrule = [
        "blur, gtk-layer-shell"
        "blur, logout_dialog"
      ];

      # Keybindings - Applications
      bind = [
        "$mainMod, RETURN, exec, ghostty"
        "$mainMod SHIFT, RETURN, exec, kitty"
        "$mainMod ALT, RETURN, exec, foot"
        "$mainMod, S, exec, foot"
        "$mainMod, E, exec, nautilus"
        "$mainMod CTRL SHIFT, B, exec, $browser -p Work_Admin"
        "$mainMod, P, exec, 1password"
        "$mainMod SHIFT, P, exec, 1password --quick-access"
        "$mainMod, D, exec, discord"
        "$mainMod, period, exec, emote"

        # Window management
        "$mainMod, Q, killactive"
        "$mainMod, F, fullscreen, 1"
        "$mainMod SHIFT, F, fullscreen"
        "$mainMod, T, togglefloating"
        "$mainMod, J, togglesplit"
        "$mainMod, G, togglegroup"

        # Window navigation
        "$mainMod, left, movefocus, l"
        "$mainMod, right, movefocus, r"
        "$mainMod, up, movefocus, u"
        "$mainMod, down, movefocus, d"
        "ALT, Tab, cyclenext"
        "ALT, Tab, bringactivetotop"

        # Window resizing
        "$mainMod SHIFT, right, resizeactive, 100 0"
        "$mainMod SHIFT, left, resizeactive, -100 0"
        "$mainMod SHIFT, up, resizeactive, 0 -100"
        "$mainMod SHIFT, down, resizeactive, 0 100"

        # Rofi menus
        "$mainMod, SPACE, exec, $menu"
        "$mainMod, V, exec, cliphist list | rofi -dmenu -p cliphist | cliphist decode | wl-copy"

        # Actions
        "$mainMod, L, exec, hyprlock"

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
        "$mainMod, mouse_down, workspace, e+1"
        "$mainMod, mouse_up, workspace, e-1"
        "$mainMod CTRL, down, workspace, empty"

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

        # Fn keys
        ",XF86MonBrightnessUp, exec, brightnessctl -q s +10%"
        ",XF86MonBrightnessDown, exec, brightnessctl -q s 10%-"
        ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ",XF86AudioPlay, exec, playerctl play-pause"
        ",XF86AudioPause, exec, playerctl pause"
        ",XF86AudioNext, exec, playerctl next"
        ",XF86AudioPrev, exec, playerctl previous"
        ",XF86AudioMicMute, exec, pactl set-source-mute @DEFAULT_SOURCE@ toggle"
        ",XF86Lock, exec, hyprlock"

        # Passthrough SUPER KEY to Virtual Machine
        "$mainMod, Z, submap, passthru"

        # Browser shortcuts that swap based on hostname
        "${browserPersonalBind}, exec, $browser -p Personal"
        "${browserWorkBind}, exec, $browser -p Work"
      ];

      # Audio volume control (repeatable)
      binde = [
        ",XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
        ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
      ];

      # Mouse bindings
      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];

      # Submap for passthrough
      submap = [
        "passthru"
        "SUPER,Escape,submap,reset"
        "reset"
      ];
    };

    # Autostart programs
    extraConfig = ''
      # Panel and wallpaper
      exec-once = hyprpanel
      exec-once = hyprpaper

      # Clipboard history
      exec-once = wl-paste --type text --watch cliphist store
      exec-once = wl-paste --type image --watch cliphist store

      # Idle and lock
      exec-once = hypridle

      # Applications
      exec-once = 1password --silent
      exec-once = corectrl

      # Environment
      exec-once = dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
    '';
  };

  # Symlink hyprland config from dotfiles repo
  # Disabled: hyprland config files are missing from dotfiles
  # home.file = lib.custom.symlink.mkDotfilesLinks config homeDirectory [ "hypr" ];
}
