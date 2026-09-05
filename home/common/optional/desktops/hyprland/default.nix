{
  lib,
  config,
  pkgs,
  homeDirectory,
  hostname,
  inputs,
  system,
  ...
}:

let
  # Must match the binary and the profile names declared in
  # core/zen-browser.nix — `-p` is case-sensitive.
  browserAdminProfile = "work_admin";
  browserCmd = "zen-beta";
  # Browser key assignments based on host
  browserPersonalKey = if isWorkHost then "SUPER + SHIFT + B" else "SUPER + B";
  browserPersonalProfile = "personal";
  browserWorkKey = if isWorkHost then "SUPER + B" else "SUPER + SHIFT + B";
  browserWorkProfile = "work";
  # Return a shell bind or null if the field is absent in the active shell
  getOptionalShellBind =
    field:
    let
      kbField = shellKb.${field}.hyprland or null;
    in
    if kbField != null then mkShellBind kbField else null;
  # Get a shell keybind (via .hyprland field) or fall back to an exec bind
  getShellBind =
    field: fallbackKey: fallbackCmd:
    let
      kbField = shellKb.${field}.hyprland or null;
    in
    if kbField != null then
      mkShellBind kbField
    else
      mkBind fallbackKey "hl.dsp.exec_cmd(${toLuaStr fallbackCmd})";
  getShellBindRepeat =
    field: fallbackKey: fallbackCmd:
    let
      kbField = shellKb.${field}.hyprland or null;
    in
    if kbField != null then
      mkShellBindRepeat kbField
    else
      mkBindRepeat fallbackKey "hl.dsp.exec_cmd(${toLuaStr fallbackCmd})";
  hasNoctalia = noctaliaKb != { };
  isWorkHost = hostname == "work";
  # Launcher keybind (provided by the shell; no standalone launcher installed)
  launcherBinds =
    let
      launcherField = shellKb.launcher.hyprland or null;
    in
    lib.optionals (launcherField != null) [ (mkShellBind launcherField) ];
  # Wrap a Nix string as a raw Lua expression (renders without quotes)
  lua = lib.generators.mkLuaInline;
  # Build a settings.bind entry: hl.bind(key, dispatcher)
  mkBind = key: dispExpr: {
    _args = [
      key
      (lua dispExpr)
    ];
  };
  # Like mkBind but with { drag = true } — replaces hyprlang bindm
  mkBindDrag = key: dispExpr: {
    _args = [
      key
      (lua dispExpr)
      { drag = true; }
    ];
  };
  # Like mkBind but with { repeating = true } — replaces hyprlang binde
  mkBindRepeat = key: dispExpr: {
    _args = [
      key
      (lua dispExpr)
      { repeating = true; }
    ];
  };
  # Build a bind from a shell keybinding struct { key; cmd; }
  mkShellBind = kb: mkBind kb.key "hl.dsp.exec_cmd(${toLuaStr kb.cmd})";
  mkShellBindRepeat = kb: mkBindRepeat kb.key "hl.dsp.exec_cmd(${toLuaStr kb.cmd})";
  # Check which shell is enabled
  noctaliaKb = config.myConfig.programs.noctalia.keybindings or { };
  shellEnabled = hasNoctalia;
  shellKb = noctaliaKb;
  # Render a Nix value as a Lua literal string (e.g. "foo" → "\"foo\"")
  toLuaStr = lib.generators.toLua { };

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
      hypridle # Idle management
      playerctl # Media player control
      wtype # Synthesise key events (universal copy/paste)
      satty
    ]
    ++ lib.optionals (!shellEnabled) [
      # Only include these when no shell is enabled
      hyprlock # Lock screen (shells provide their own)
      brightnessctl # Brightness control (shells handle this)
    ];

  wayland.windowManager.hyprland = {
    configType = "lua";
    enable = true;

    # Autostart programs and submap definition
    extraConfig = ''
      hl.on("hyprland.start", function()
        hl.exec_cmd("hypridle")
        hl.exec_cmd("proton-pass")
        hl.exec_cmd("corectrl")
      end)
    ''
    + lib.optionalString hasNoctalia ''
      hl.on("hyprland.start", function()
        hl.exec_cmd("noctalia")
      end)
    ''
    + ''
      hl.define_submap("passthru", function()
        hl.bind("SUPER + Escape", hl.dsp.submap("reset"))
      end)
    '';

    package = inputs.hyprland.packages.${system}.hyprland;

    settings = {
      # All keybindings in a single bind list (repeating/drag via _args opts)
      bind = [
        # Applications
        (mkBind "SUPER + RETURN" ''hl.dsp.exec_cmd("ghostty")'')
        (mkBind "SUPER + SHIFT + RETURN" ''hl.dsp.exec_cmd("kitty")'')
        (mkBind "SUPER + ALT + RETURN" ''hl.dsp.exec_cmd("foot")'')
        (mkBind "SUPER + S" ''hl.dsp.exec_cmd("foot")'')
        (mkBind "SUPER + E" ''hl.dsp.exec_cmd("nautilus")'')
        (mkBind "SUPER + CTRL + SHIFT + B" ''hl.dsp.exec_cmd("${browserCmd} -p ${browserAdminProfile}")'')
        (mkBind "SUPER + P" ''hl.dsp.exec_cmd("proton-pass")'')
        (mkBind "SUPER + D" ''hl.dsp.exec_cmd("discord")'')

        # Universal clipboard: send the legacy CUA chords, which both
        # terminals and GTK/Qt apps honour, so one key works everywhere.
        (mkBind "SUPER + C" ''hl.dsp.exec_cmd("wtype -M ctrl -k Insert -m ctrl")'')
        (mkBind "SUPER + V" ''hl.dsp.exec_cmd("wtype -M shift -k Insert -m shift")'')
        (mkBind "SUPER + X" ''hl.dsp.exec_cmd("wtype -M ctrl -k x -m ctrl")'')

        # Screenshot
        (mkBind "SUPER + SHIFT + S" (
          "hl.dsp.exec_cmd(${toLuaStr ''grim -g "$(slurp)" - | satty -f - --output-filename ~/Pictures/Screenshots/satty-$(date '+%Y%m%d-%H:%M:%S').png''})"
        ))
      ]
      ++ launcherBinds
      # Shell-specific keybindings (only if a shell is enabled)
      ++ lib.optionals shellEnabled (
        lib.filter (b: b != null) [
          (getOptionalShellBind "calendar")
          (getOptionalShellBind "clipboard")
          (getOptionalShellBind "omniMenu")
          (getOptionalShellBind "emoji")
          (getOptionalShellBind "dashboard")
          (getOptionalShellBind "controlCenter")
          (getOptionalShellBind "audioPanel")
          (getOptionalShellBind "bluetoothPanel")
          (getOptionalShellBind "networkPanel")
          (getOptionalShellBind "nightlight")
        ]
      )
      ++ [
        # Window management
        (mkBind "SUPER + Q" "hl.dsp.window.close()")
        (mkBind "SUPER + F" ''hl.dsp.window.fullscreen({ mode = "maximized" })'')
        (mkBind "SUPER + SHIFT + F" "hl.dsp.window.fullscreen()")
        (mkBind "SUPER + T" "hl.dsp.window.float()")
        (mkBind "SUPER + J" ''hl.dsp.layout("togglesplit")'')
        (mkBind "SUPER + G" "hl.dsp.group.toggle()")
        (mkBind "SUPER + M" ''hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch exit")'')

        # Window navigation
        (mkBind "SUPER + left" ''hl.dsp.focus({ direction = "l" })'')
        (mkBind "SUPER + right" ''hl.dsp.focus({ direction = "r" })'')
        (mkBind "SUPER + up" ''hl.dsp.focus({ direction = "u" })'')
        (mkBind "SUPER + down" ''hl.dsp.focus({ direction = "d" })'')
        (mkBind "ALT + Tab" ''
          function()
            hl.dispatch(hl.dsp.window.cycle_next())
            hl.dispatch(hl.dsp.window.alter_zorder({ mode = "top" }))
          end'')

        # Window resizing
        (mkBind "SUPER + SHIFT + right" "hl.dsp.window.resize({ x = 100, y = 0, relative = true })")
        (mkBind "SUPER + SHIFT + left" "hl.dsp.window.resize({ x = -100, y = 0, relative = true })")
        (mkBind "SUPER + SHIFT + up" "hl.dsp.window.resize({ x = 0, y = -100, relative = true })")
        (mkBind "SUPER + SHIFT + down" "hl.dsp.window.resize({ x = 0, y = 100, relative = true })")

        # Lock screen
        (getShellBind "lockScreen" "SUPER + CTRL + Escape" "hyprlock")
      ]
      # Workspace switching: SUPER + 0-9 (0 → workspace 10)
      ++ map (
        n:
        mkBind "SUPER + ${toString n}" "hl.dsp.focus({ workspace = ${
          toString (if n == 0 then 10 else n)
        } })"
      ) (lib.range 0 9)
      # Move window to workspace: SUPER + SHIFT + 0-9
      ++ map (
        n:
        mkBind "SUPER + SHIFT + ${toString n}" "hl.dsp.window.move({ workspace = ${
          toString (if n == 0 then 10 else n)
        } })"
      ) (lib.range 0 9)
      ++ [
        # Workspace scroll via mouse wheel
        (mkBind "SUPER + mouse_down" ''hl.dsp.focus({ workspace = "e+1" })'')
        (mkBind "SUPER + mouse_up" ''hl.dsp.focus({ workspace = "e-1" })'')
        (mkBind "SUPER + CTRL + down" ''hl.dsp.focus({ workspace = "empty" })'')

        # Fn / media keys
        (getShellBind "brightnessUp" "XF86MonBrightnessUp" "brightnessctl -q s +10%")
        (getShellBind "brightnessDown" "XF86MonBrightnessDown" "brightnessctl -q s 10%-")
        (getShellBind "volumeMute" "XF86AudioMute" "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")
        (getShellBind "mediaPlay" "XF86AudioPlay" "playerctl play-pause")
        (mkBind "XF86AudioPause" ''hl.dsp.exec_cmd("playerctl pause")'')
        (getShellBind "mediaNext" "XF86AudioNext" "playerctl next")
        (getShellBind "mediaPrev" "XF86AudioPrev" "playerctl previous")
        (getShellBind "micMute" "XF86AudioMicMute" "pactl set-source-mute @DEFAULT_SOURCE@ toggle")
        (getShellBind "lockKey" "XF86Lock" "hyprlock")

        # Passthrough SUPER KEY to virtual machine
        (mkBind "SUPER + Z" ''hl.dsp.submap("passthru")'')

        # Browser shortcuts (swapped based on hostname)
        (mkBind browserPersonalKey ''hl.dsp.exec_cmd("${browserCmd} -p ${browserPersonalProfile}")'')
        (mkBind browserWorkKey ''hl.dsp.exec_cmd("${browserCmd} -p ${browserWorkProfile}")'')

        # Audio volume — repeatable (replaces binde)
        (getShellBindRepeat "volumeUp" "XF86AudioRaiseVolume"
          "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
        )
        (getShellBindRepeat "volumeDown" "XF86AudioLowerVolume" "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-")

        # Mouse drag binds (replaces bindm)
        (mkBindDrag "SUPER + mouse:272" "hl.dsp.window.drag()")
        (mkBindDrag "SUPER + mouse:273" "hl.dsp.window.resize()")
      ];

      # All config options — renders as hl.config({ ["section.key"] = value, ... })
      config = {
        "animations.enabled" = false;
        "decoration.active_opacity" = 1.0;
        "decoration.fullscreen_opacity" = 1.0;
        "decoration.inactive_opacity" = 1.0;
        "decoration.rounding" = 10;
        "decoration.shadow.color" = "0x66000000";
        "decoration.shadow.enabled" = true;
        "decoration.shadow.range" = 30;
        "decoration.shadow.render_power" = 3;
        "dwindle.preserve_split" = true;
        "general.border_size" = 2;
        "general.col.active_border" = "rgb(fab387)"; # Catppuccin Mocha peach
        "general.col.inactive_border" = "rgb(f5e0dc)"; # Catppuccin Mocha rosewater
        "general.gaps_in" = 3;
        "general.gaps_out" = 5;
        "general.layout" = "dwindle";
        "input.follow_mouse" = 1;
        "input.kb_layout" = "se";
        "input.kb_model" = "";
        "input.kb_options" = "";
        "input.kb_variant" = "";
        "input.mouse_refocus" = false;
        "input.numlock_by_default" = true;
        "input.sensitivity" = 0;
        "input.touchpad.natural_scroll" = false;
        "misc.disable_hyprland_logo" = true;
        "misc.disable_splash_rendering" = true;
      };

      # Environment variables — renders as hl.env("KEY", "VALUE")
      env = [
        {
          _args = [
            "QT_QPA_PLATFORM"
            "wayland"
          ];
        }
        {
          _args = [
            "XDG_CURRENT_DESKTOP"
            "Hyprland"
          ];
        }
        {
          _args = [
            "GTK_IM_MODULE"
            "simple"
          ];
        } # Fix dead keys on GTK 4.20+ / Wayland
      ];
      # Monitor configuration is host-specific hardware: see
      # home/<user>/<host>.nix (e.g. home/drakkir/terra.nix).
    };
  };
}
