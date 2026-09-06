{ ... }:

{
  # Symlink .face file for user avatar
  home.file.".face".source = ../../.face;

  imports = [
    ../common/core
    ./common/ssh.nix

    # Desktop environments
    ../common/optional/desktops/gnome
    ../common/optional/desktops/hyprland
    ../common/optional/desktops/niri
    ../common/optional/desktops/umbriel

    # Features
    ../common/optional/gaming.nix

    # Apps
    ../common/optional/apps/discord.nix
    ../common/optional/apps/qbittorrent.nix
    ../common/optional/apps/tmux.nix
    ../common/optional/apps/vlc.nix

    # System
    ../common/optional/flatpak.nix
  ];

  programs = {
    niri.settings.outputs = {
      "DP-1" = {
        mode = {
          height = 1080;
          refresh = 119.982;
          width = 1920;
        };

        position = {
          x = 0;
          y = 0;
        };
      };

      "DP-2" = {
        mode = {
          height = 1440;
          refresh = 143.998;
          width = 2560;
        };

        position = {
          x = 1920;
          y = 0;
        };
      };
    };

    # ---- Host hardware: displays ----
    # terra drives two external displays side by side.
    # Umbriel has no output block by default, so wlroots picks each display's
    # *preferred* mode — which on both of these is 60 Hz, not the 120/144 Hz they
    # are capable of. Mirrors the niri outputs below; keep the two in sync.
    umbriel.settings.output = {
      "DP-1" = {
        mode = "1920x1080@119.982";

        position = [
          0
          0
        ];
      };

      "DP-2" = {
        mode = "2560x1440@143.998";

        position = [
          1920
          0
        ];
      };
    };
  };

  wayland.windowManager.hyprland.settings.monitor = [
    {
      _args = [
        {
          mode = "1920x1080@120";
          output = "DP-1";
          position = "auto";
          scale = 1;
        }
      ];
    }
    {
      _args = [
        {
          mode = "2560x1440@144";
          output = "DP-2";
          position = "auto";
          scale = 1;
        }
      ];
    }
    {
      # Fallback for anything else that gets plugged in.
      _args = [
        {
          mode = "preferred";
          output = "";
          position = "auto";
          scale = 1;
        }
      ];
    }
  ];
}
