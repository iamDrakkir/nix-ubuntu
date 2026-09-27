{
  lib,
  config,
  pkgs,
  inputs,
  system,
  ...
}:

let
  inherit (config.myConfig) browser chatCommand;
  # h/j/k/l mapped to Hyprland's direction names
  directions = {
    h = "l";
    j = "d";
    k = "u";
    l = "r";
  };
  execExpr = cmd: "hl.dsp.exec_cmd(${toLuaStr cmd})";
  kb = config.myConfig.programs.noctalia.keybindings;
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
  mkDirBinds =
    mods: dispatch: lib.mapAttrsToList (key: dir: mkBind "${mods} + ${key}" (dispatch dir)) directions;
  mkExec = key: cmd: mkBind key (execExpr cmd);
  noctaliaBind = name: mkBind kb.${name}.hyprland.key (execExpr kb.${name}.hyprland.cmd);
  # Volume keys repeat while held; every other Noctalia bind fires once.
  noctaliaRepeating = [
    "volumeDown"
    "volumeUp"
  ];
  # Render a Nix value as a Lua literal string (e.g. "foo" → "\"foo\"")
  toLuaStr = lib.generators.toLua { };

in

{
  # Wayland utilities for Hyprland
  home.packages = with pkgs; [
    grim # Screenshot tool
    slurp # Screen area selector
    wl-clipboard # Clipboard utilities
    wl-clipboard-x11 # X11 compatibility
    hypridle # Idle management
    playerctl # Media player control
    wtype # Synthesise key events (universal copy/paste)
    satty
  ];

  imports = [ ../portals.nix ];

  wayland.windowManager.hyprland = {
    configType = "lua";
    enable = true;

    # Autostart, Noctalia colours and the passthru submap. The colour module is
    # rendered by Noctalia's hyprland template and is absent until its first run.
    extraConfig = ''
      hl.on("hyprland.start", function()
        hl.exec_cmd("hypridle")
        hl.exec_cmd("proton-pass")
        hl.exec_cmd("noctalia")
      end)

      pcall(function() require("noctalia").apply_theme() end)

      hl.define_submap("passthru", function()
        hl.bind("SUPER + Escape", hl.dsp.submap("reset"))
      end)
    '';

    package = inputs.hyprland.packages.${system}.hyprland;

    settings = {
      # All keybindings in a single bind list (repeating/drag via _args opts)
      bind = [
        # Applications
        (mkExec "SUPER + RETURN" "ghostty")
        (mkExec "SUPER + SHIFT + RETURN" "kitty")
        (mkExec "SUPER + ALT + RETURN" "foot")
        (mkExec "SUPER + E" "nautilus")
        (mkExec "SUPER + B" "${browser.cmd} -p ${browser.primary}")
        (mkExec "SUPER + SHIFT + B" "${browser.cmd} -p ${browser.secondary}")
        (mkExec "SUPER + CTRL + SHIFT + B" "${browser.cmd} -p ${browser.admin}")
        (mkExec "SUPER + P" "proton-pass")

        # Universal clipboard: send the legacy CUA chords, which both
        # terminals and GTK/Qt apps honour, so one key works everywhere.
        (mkExec "SUPER + C" "wtype -M ctrl -k Insert -m ctrl")
        (mkExec "SUPER + V" "wtype -M shift -k Insert -m shift")
        (mkExec "SUPER + X" "wtype -M ctrl -k x -m ctrl")

        # Screenshot
        (mkExec "SUPER + SHIFT + S" ''grim -g "$(slurp)" - | satty -f - --output-filename ~/Pictures/Screenshots/satty-$(date '+%Y%m%d-%H:%M:%S').png'')

        # Window management
        (mkBind "SUPER + Q" "hl.dsp.window.close()")
        (mkBind "SUPER + F" ''hl.dsp.window.fullscreen({ mode = "maximized" })'')
        (mkBind "SUPER + SHIFT + F" "hl.dsp.window.fullscreen()")
        (mkBind "SUPER + T" "hl.dsp.window.float()")
        (mkBind "SUPER + R" ''hl.dsp.layout("togglesplit")'')
        (mkBind "SUPER + G" "hl.dsp.group.toggle()")
        (mkExec "SUPER + M" "command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch exit")

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
      ]
      ++ lib.optional (chatCommand != null) (mkExec "SUPER + D" chatCommand)
      # The README hierarchy: focus window, move window, focus monitor, move to monitor
      ++ mkDirBinds "SUPER" (d: ''hl.dsp.focus({ direction = "${d}" })'')
      ++ mkDirBinds "SUPER + CTRL" (d: ''hl.dsp.window.move({ direction = "${d}" })'')
      ++ mkDirBinds "SUPER + SHIFT" (d: ''hl.dsp.focus({ monitor = "${d}" })'')
      ++ mkDirBinds "SUPER + SHIFT + CTRL" (d: ''hl.dsp.window.move({ monitor = "${d}" })'')
      ++ map noctaliaBind (lib.subtractLists noctaliaRepeating (lib.attrNames kb))
      ++ map (
        name: mkBindRepeat kb.${name}.hyprland.key (execExpr kb.${name}.hyprland.cmd)
      ) noctaliaRepeating
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

        # Fn / media keys (brightness, volume, mic and lock come from Noctalia)
        (mkExec "XF86AudioPlay" "playerctl play-pause")
        (mkExec "XF86AudioPause" "playerctl pause")
        (mkExec "XF86AudioNext" "playerctl next")
        (mkExec "XF86AudioPrev" "playerctl previous")

        # Passthrough SUPER KEY to virtual machine
        (mkBind "SUPER + Z" ''hl.dsp.submap("passthru")'')

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
