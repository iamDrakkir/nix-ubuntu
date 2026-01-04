{ ... }:

{
  programs.alacritty = {
    enable = true;

    settings = {
      # Window settings
      window = {
        decorations = "none";
      };

      # Hints configuration for URL detection
      hints = {
        enabled = [
          {
            command = "xdg-open";
            hyperlinks = true;
            post_processing = true;
            regex = "(ipfs:|ipns:|magnet:|mailto:|gemini:|gopher:|https:|http:|news:|file:|git:|ssh:|ftp:)[^\u0000-\u001F\u007F-<>\"\\s{-}\\^⟨⟩`]+";
            binding = {
              key = "U";
              mods = "Control|Shift";
            };
            mouse = {
              enabled = true;
              mods = "None";
            };
          }
        ];
      };

      # Keyboard bindings
      keyboard.bindings = [
        {
          key = "V";
          mods = "Control|Shift";
          action = "Paste";
        }
        {
          key = "C";
          mods = "Control|Shift";
          action = "Copy";
        }
        {
          key = "Insert";
          mods = "Control";
          action = "Paste";
        }
        {
          key = "Insert";
          mods = "Shift";
          action = "Copy";
        }
        {
          key = "Plus";
          mods = "Control";
          action = "IncreaseFontSize";
        }
        {
          key = "Minus";
          mods = "Control";
          action = "DecreaseFontSize";
        }
        {
          key = "F11";
          mods = "Control";
          action = "ToggleFullscreen";
        }
      ];

      # Mouse bindings
      mouse.bindings = [
        {
          mouse = "Right";
          action = "ExpandSelection";
        }
        {
          mouse = "Middle";
          action = "PasteSelection";
        }
      ];

      # Theme is imported from auto-generated noctalia theme file
      # The import is handled at the top of alacritty.toml via:
      # [general]
      # import = ["themes/noctalia.toml"]
    };
  };
}
