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

      # Rose Pine theme colors
      colors = {
        primary = {
          background = "0x191724";
          foreground = "0xe0def4";
        };

        cursor = {
          text = "0xe0def4";
          cursor = "0x524f67";
        };

        vi_mode_cursor = {
          text = "0xe0def4";
          cursor = "0x524f67";
        };

        selection = {
          text = "0xe0def4";
          background = "0x403d52";
        };

        normal = {
          black = "0x26233a";
          red = "0xeb6f92";
          green = "0x31748f";
          yellow = "0xf6c177";
          blue = "0x9ccfd8";
          magenta = "0xc4a7e7";
          cyan = "0xebbcba";
          white = "0xe0def4";
        };

        bright = {
          black = "0x6e6a86";
          red = "0xeb6f92";
          green = "0x31748f";
          yellow = "0xf6c177";
          blue = "0x9ccfd8";
          magenta = "0xc4a7e7";
          cyan = "0xebbcba";
          white = "0xe0def4";
        };

        hints = {
          start = {
            foreground = "#908caa";
            background = "#1f1d2e";
          };
          end = {
            foreground = "#6e6a86";
            background = "#1f1d2e";
          };
        };

        line_indicator = {
          foreground = "None";
          background = "None";
        };
      };
    };
  };
}
