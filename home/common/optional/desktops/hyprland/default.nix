{
  config,
  hostname,
  inputs,
  lib,
  pkgs,
  system,
  homeDirectory,
  ...
}:

let
  isWorkHost = hostname == "work";
  # Swap browser profile shortcuts based on host
  # Create the full modifier string with proper spacing
  browserPersonalBind = if isWorkHost then "$mainMod SHIFT, B" else "$mainMod, B";
  browserWorkBind = if isWorkHost then "$mainMod, B" else "$mainMod SHIFT, B";

  # Check which shell is enabled (use whichever has keybindings)
  noctaliaKb = config.myConfig.programs.noctalia.keybindings or { };
  dmsKb = config.myConfig.programs.dms.keybindings or { };
  hasNoctalia = noctaliaKb != { };
  hasDms = dmsKb != { };
  shellEnabled = hasNoctalia || hasDms;

  # Get keybindings from the enabled shell (prioritize Noctalia)
  shellKb = if hasNoctalia then noctaliaKb else dmsKb;

  # Fallback keybindings when no shell is enabled
  fallbackBinds = {
    launcher = "$mainMod, SPACE, exec, $menu";
    lockScreen = "$mainMod, X, exec, hyprlock";
    brightnessUp = ",XF86MonBrightnessUp, exec, brightnessctl -q s +10%";
    brightnessDown = ",XF86MonBrightnessDown, exec, brightnessctl -q s 10%-";
    volumeUp = ",XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+";
    volumeDown = ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
    volumeMute = ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
    micMute = ",XF86AudioMicMute, exec, pactl set-source-mute @DEFAULT_SOURCE@ toggle";
    lockKey = ",XF86Lock, exec, hyprlock";
  };

  # Select keybindings based on shell status
  binds =
    if shellEnabled then
      {
        launcher = shellKb.launcher.hyprland or shellKb.spotlight.hyprland or fallbackBinds.launcher;
        calendar = shellKb.calendar.hyprland or "";
        clipboard = shellKb.clipboard.hyprland or "";
        dashboard = shellKb.dashboard.hyprland or "";
        controlCenter = shellKb.controlCenter.hyprland or "";
        lockScreen = shellKb.lockScreen.hyprland or fallbackBinds.lockScreen;
        brightnessUp = shellKb.brightnessUp.hyprland or fallbackBinds.brightnessUp;
        brightnessDown = shellKb.brightnessDown.hyprland or fallbackBinds.brightnessDown;
        volumeUp = shellKb.volumeUp.hyprland or fallbackBinds.volumeUp;
        volumeDown = shellKb.volumeDown.hyprland or fallbackBinds.volumeDown;
        volumeMute = shellKb.volumeMute.hyprland or fallbackBinds.volumeMute;
        micMute = shellKb.micMute.hyprland or fallbackBinds.micMute;
        lockKey = shellKb.lockKey.hyprland or fallbackBinds.lockKey;
        mediaPlay = shellKb.mediaPlay.hyprland or ",XF86AudioPlay, exec, playerctl play-pause";
        mediaNext = shellKb.mediaNext.hyprland or ",XF86AudioNext, exec, playerctl next";
        mediaPrev = shellKb.mediaPrev.hyprland or ",XF86AudioPrev, exec, playerctl previous";
      }
    else
      fallbackBinds
      // {
        mediaPlay = ",XF86AudioPlay, exec, playerctl play-pause";
        mediaNext = ",XF86AudioNext, exec, playerctl next";
        mediaPrev = ",XF86AudioPrev, exec, playerctl previous";
      };
in

{
  # Wayland utilities for Hyprland
  home.packages =
    with pkgs;
    [
      grim # Screenshot tool
      slurp # Screen area selector
      wl-clipboard # Clipboard utilities
      wl-clipboard-x11 # X11 compatibility
      cliphist # Clipboard history
      hyprpaper # Wallpaper
      hypridle # Idle management
      playerctl # Media player control
      emote # Emoji picker
      satty
    ]
    ++ lib.optionals (!shellEnabled) [
      # Only include these when no shell is enabled
      hyprlock # Lock screen (shells provide their own)
      brightnessctl # Brightness control (shells handle this)
    ];

  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${system}.hyprland;

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
        "GTK_IM_MODULE,simple" # Fix dead keys on GTK 4.20+ / Wayland
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
        preserve_split = true;
      };

      # Misc
      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
      };

      # Window rules
      windowrule = [
      ];

      windowrulev2 = [
      ];

      layerrule = [
      ];

      # Keybindings - Applications
      bind = [
        "$mainMod, RETURN, exec, ghostty"
        "$mainMod SHIFT, RETURN, exec, kitty"
        "$mainMod ALT, RETURN, exec, foot"
        "$mainMod, S, exec, foot"
        "$mainMod, E, exec, nautilus"
        "$mainMod CTRL SHIFT, B, exec, $browser -p Work_Admin"
        "$mainMod, P, exec, proton-pass"
        "$mainMod, D, exec, discord"
        "$mainMod, period, exec, emote"

        # Screenshot
        "$mainMod SHIFT, S, exec, grim -g \"$(slurp)\" - | satty -f - --output-filename ~/Pictures/Screenshots/satty-$(date '+%Y%m%d-%H:%M:%S').png"

        # Launcher / menu
        binds.launcher
      ]
      # Shell-specific keybindings (only if enabled)
      ++ lib.optionals shellEnabled (
        lib.filter (s: s != "") [
          binds.calendar
          binds.clipboard
          binds.dashboard
          binds.controlCenter
        ]
      )
      ++ [
        # Window management
        "$mainMod, Q, killactive"
        "$mainMod, F, fullscreen, 1"
        "$mainMod SHIFT, F, fullscreen"
        "$mainMod, T, togglefloating"
        "$mainMod, J, togglesplit"
        "$mainMod, G, togglegroup"

        "$mainMod, M, exec, command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch exit"

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

        # Actions
        binds.lockScreen

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
        binds.brightnessUp
        binds.brightnessDown
        binds.volumeMute
        binds.mediaPlay
        ",XF86AudioPause, exec, playerctl pause"
        binds.mediaNext
        binds.mediaPrev
        binds.micMute
        binds.lockKey

        # Passthrough SUPER KEY to Virtual Machine
        "$mainMod, Z, submap, passthru"

        # Browser shortcuts that swap based on hostname
        "${browserPersonalBind}, exec, $browser -p Personal"
        "${browserWorkBind}, exec, $browser -p Work"
      ];

      # Audio volume control (repeatable)
      binde = [
        binds.volumeUp
        binds.volumeDown
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
      exec-once = dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP

      # Wallpaper
      exec-once = hyprpaper

      # Clipboard history
      exec-once = wl-paste --type text --watch cliphist store
      exec-once = wl-paste --type image --watch cliphist store

      # Idle and lock
      exec-once = hypridle

      # Applications
      exec-once = proton-pass
      exec-once = corectrl
    ''
    + lib.optionalString hasNoctalia ''
      # Noctalia shell
      exec-once = noctalia-shell
    ''
    + lib.optionalString (hasDms && !hasNoctalia) ''
      # DankMaterialShell
      exec-once = dms run
    '';
  };

  # Symlink hyprland config from dotfiles repo
  # Disabled: hyprland config files are missing from dotfiles
  # home.file = lib.custom.symlink.mkDotfilesLinks config homeDirectory [ "hypr" ];
}
