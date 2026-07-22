{ ... }:

{
  programs.waybar = {
    enable = true;

    settings = {
      mainBar = {
        battery = {
          format = "{icon} {capacity}%";
          format-alt = "{icon}  {time}";
          format-charging = "󰂄  {capacity}%";
          format-icons = [
            " "
            " "
            " "
            " "
            " "
          ];
          format-plugged = "  {capacity}%";
          states = {
            critical = 15;
            good = 95;
            warning = 30;
          };
        };
        bluetooth = {
          format = " {status}";
          format-disabled = "";
          format-no-controller = "";
          format-off = "";
          interval = 30;
          on-click = "blueman-manager";
          tooltip-format = "{controller_alias}\n{num_connections} connected";
          tooltip-format-connected = "{controller_alias}\n{num_connections} connected\n\n{device_enumerate}";
          tooltip-format-enumerate-connected = "{device_alias}";
          tooltip-format-enumerate-connected-battery = "{device_alias}\t{icon} {device_battery_percentage}%";
        };
        clock = {
          actions = {
            on-click-backward = "tz_down";
            on-click-forward = "tz_up";
            on-click-right = "mode";
            on-scroll-down = "shift_down";
            on-scroll-up = "shift_up";
          };
          calendar = {
            format = {
              days = "<span color='#ecc6d9'><b>{}</b></span>";
              months = "<span color='#ffead3'><b>{}</b></span>";
              today = "<span color='#ff6699'><b><u>{}</u></b></span>";
              weekdays = "<span color='#ffcc66'><b>{}</b></span>";
              weeks = "<span color='#99ffdd'><b>{:%W}</b></span>";
            };
            locale = "sv_SE";
            mode = "month";
            mode-mon-col = 3;
            on-click-right = "mode";
            on-scroll = 1;
            weeks-pos = "left";
          };
          format = "{:%R}";
          format-alt = "{:%R 󰃭 %d·%m·%y}";
          timezone = "Europe/Stockholm";
          tooltip-format = "<tt>{calendar}</tt>";
        };
        cpu = {
          format = "C {usage}% ";
          on-click = "foot htop";
        };
        "custom/appmenu" = {
          format = "Apps";
          on-click = "rofi -show drun -replace";
          on-click-right = "~/.config/hypr/scripts/keybindings.sh";
          tooltip = false;
        };
        "custom/browser" = {
          format = "󰈹";
          on-click = "firefox";
          tooltip = false;
        };
        "custom/chatgpt" = {
          format = "";
          on-click = "firefox -kiosk --new-window https://chat.openai.com";
          tooltip = false;
        };
        # Custom modules
        "custom/cliphist" = {
          format = "";
          on-click = "cliphist list | rofi -dmenu -replace -config ~/.config/rofi/config-cliphist.rasi | cliphist decode | wl-copy";
          tooltip = false;
        };
        "custom/filemanager" = {
          format = "";
          on-click = "nautilus";
          tooltip = false;
        };
        "custom/notification" = {
          escape = true;
          exec = "swaync-client -swb";
          exec-if = "which swaync-client";
          format = "{icon}";
          format-icons = {
            dnd-inhibited-none = " ";
            dnd-inhibited-notification = " ";
            dnd-none = "󰂛";
            dnd-notification = " ";
            inhibited-none = "";
            inhibited-notification = " ";
            none = "";
            notification = "󱅫";
          };
          on-click = "sleep 0.1 && swaync-client -t -sw";
          on-click-right = "sleep 0.1 && swaync-client -d -sw";
          return-type = "json";
          tooltip = false;
        };
        "custom/system" = {
          format = "";
          tooltip = false;
        };
        "custom/updates" = {
          escape = true;
          exec = "~/.dotfiles/scripts/updates.sh";
          format = "  {}";
          on-click = "alacritty --class dotfiles-floating -e ~/.dotfiles/scripts/installupdates.sh";
          restart-interval = 60;
          return-type = "json";
          tooltip = false;
          tooltip-format = "{}";
        };
        "custom/wallpaper" = {
          format = "";
          on-click = "~/.config/hypr/scripts/wallpaper.sh select";
          on-click-right = "~/.config/hypr/scripts/wallpaper.sh";
          tooltip = false;
        };
        disk = {
          format = "D {percentage_used}% ";
          interval = 30;
          on-click = "foot htop";
          path = "/";
        };
        # Groups
        "group/hardware" = {
          drawer = {
            children-class = "not-memory";
            transition-duration = 300;
            transition-left-to-right = false;
          };
          modules = [
            "custom/system"
            "disk"
            "cpu"
            "memory"
          ];
          orientation = "inherit";
        };
        "group/quicklinks" = {
          modules = [
            "custom/chatgpt"
            "custom/wallpaper"
            "custom/browser"
            "custom/filemanager"
          ];
          orientation = "horizontal";
        };
        "hyprland/window" = {
          format = "{}";
          max-length = 1000;
          rewrite = {
            "(.*) — Mozilla Firefox" = "󰈹 - $1 ";
            "(.*)Steam" = "󰓓 - Steam";
          };
          separate-outputs = true;
        };
        # Hyprland modules
        "hyprland/workspaces" = {
          active-only = false;
          all-outputs = true;
          format = "{}";
          format-icons = {
            active = "";
            default = "";
            urgent = "";
          };
          on-click = "activate";
          on-scroll-down = "hyprctl dispatch workspace +1";
          on-scroll-up = "hyprctl dispatch workspace -1";
          persistent-workspaces = { };
        };
        layer = "top";
        margin-bottom = 0;
        margin-top = 0;
        memory = {
          format = "M {}% ";
          on-click = "foot htop";
        };
        modules-center = [ "hyprland/workspaces" ];
        modules-left = [
          "custom/notification"
          "custom/appmenu"
          "wlr/taskbar"
          "hyprland/window"
        ];
        modules-right = [
          "tray"
          "custom/updates"
          "pulseaudio"
          "bluetooth"
          "battery"
          "network"
          "group/hardware"
          "custom/cliphist"
          "clock"
        ];
        network = {
          format = "{ifname}";
          format-alt = " {bandwidthDownBytes} /  {bandwidthUpBytes}";
          format-disconnected = "󰌙";
          format-ethernet = "󰈀 {ifname}";
          format-wifi = "  {signalStrength}%";
          max-length = 50;
          on-click-right = "alacritty --class dotfiles-floating -e nmtui";
          tooltip-format-disconnected = "Disconnected";
          tooltip-format-ethernet = "󰈀 {ifname}\nIP: {ipaddr}\n up: {bandwidthUpBits} down: {bandwidthDownBits}";
          tooltip-format-wifi = "  {ifname} @ {essid}\nIP: {ipaddr}\nStrength: {signalStrength}%\nFreq: {frequency}MHz\nUp: {bandwidthUpBits} Down: {bandwidthDownBits}";
        };
        pulseaudio = {
          format = "{icon} {volume}%";
          format-bluetooth = " {volume}% {icon}  {format_source}";
          format-bluetooth-muted = " 󰸈 {icon}  {format_source}";
          format-icons = {
            car = "";
            default = [
              ""
              ""
              ""
            ];
            hands-free = "";
            headphone = "";
            headset = "";
            phone = "";
            portable = "";
          };
          format-muted = "󰸈";
          format-source = "{volume}% ";
          format-source-muted = "";
          on-click = "pavucontrol";
        };
        # Default modules
        tray = {
          icon-size = 18;
          spacing = 10;
        };
        "wlr/taskbar" = {
          align = "center";
          format = "{icon}";
          icon-size = 18;
          on-click = "activate";
          on-click-middle = "close";
          rewrite = {
            "Firefox Web Browser" = "Firefox";
          };
          spacing = 8;
          tooltip-format = "{title}";
        };
      };
    };

    style = ''
      /* Catppuccin Mocha colors */
      @define-color rosewater #f5e0dc;
      @define-color flamingo #f2cdcd;
      @define-color pink #f5c2e7;
      @define-color mauve #cba6f7;
      @define-color red #f38ba8;
      @define-color maroon #eba0ac;
      @define-color peach #fab387;
      @define-color yellow #f9e2af;
      @define-color green #a6e3a1;
      @define-color teal #94e2d5;
      @define-color sky #89dceb;
      @define-color sapphire #74c7ec;
      @define-color blue #89b4fa;
      @define-color lavender #b4befe;
      @define-color text #cdd6f4;
      @define-color subtext1 #bac2de;
      @define-color subtext0 #a6adc8;
      @define-color overlay2 #9399b2;
      @define-color overlay1 #7f849c;
      @define-color overlay0 #6c7086;
      @define-color surface2 #585b70;
      @define-color surface1 #45475a;
      @define-color surface0 #313244;
      @define-color base #1e1e2e;
      @define-color mantle #181825;
      @define-color crust #11111b;

      @define-color workspacesbackground1 @surface1;

      * {
        border: none;
        border-radius: 15px;
        font-family: "JetBrainsMono Nerd Font";
        font-weight: bold;
        font-size: 13px;
        color: @text;
      }

      #battery,
      #battery.charging,
      #battery.critical:not(.charging),
      #battery.plugged,
      #bluetooth,
      #bluetooth.connected,
      #bluetooth.off,
      #bluetooth.on,
      #clock,
      #cpu,
      #disk,
      #language,
      #memory,
      #network,
      #network.ethernet,
      #network.wifi,
      #pulseaudio,
      #pulseaudio.muted,
      #tray,
      #window,
      #custom-notification,
      #custom-appmenu,
      #custom-browser,
      #custom-keybindings,
      #custom-filemanager,
      #custom-chatgpt,
      #custom-cliphist,
      #custom-wallpaper,
      #custom-system,
      #custom-exit,
      #custom-updates,
      #custom-updates.green {
        background: @base;
        border-radius: 15px;
        padding: 0px 14px 0px 14px;
        margin: 0px 3px 0px 3px;
      }

      window#waybar {
        background-color: alpha(@surface0, .3);
        border-radius: 0px;
        transition-property: background-color;
        transition-duration: .5s;
      }
      window#waybar.empty #window {
        margin: 0;
        padding: 0;
        border: 0;
      }

      #workspaces {
        margin: 0px 3px 0px 3px;
        border: 0px;
        background-color: @base;
        font-weight: bold;
        font-style: normal;
      }
      #workspaces button {
        padding: 0px 5px;
        margin: 0px 3px;
        border: 0px;
        transition: all 0.3s ease-in-out;
      }
      #workspaces button.active {
        background: @workspacesbackground1;
        min-width: 40px;
      }
      #workspaces button:hover {
        background: @workspacesbackground1;
      }

      tooltip {
        background-color: @base;
        color: @text;
        opacity: 0.9;
        padding: 20px;
        margin: 0px;
      }
      tooltip * {
        color: @text;
      }

      #taskbar {
        margin: 0px 5px 0px 5px;
        padding: 0px 1px;
        border-radius: 15px;
        border: 0px;
        background: @base;
        font-weight: bold;
        font-style: normal;
      }
      #taskbar button {
        padding: 0px 5px;
        margin: 0px 3px;
        transition: all 0.3s ease-in-out;
      }
      #taskbar button.active {
        background: @workspacesbackground1;
      }
      #taskbar button:hover {
        background: @workspacesbackground1;
      }
      #taskbar.empty {
        background: transparent;
      }

      #custom-updates.yellow {
        background: #FF9A3C;
      }
      #custom-updates.red {
        background: #DC2F2F;
      }

      #tray menu * {
        color: @text;
      }
      #tray menu separator {
        min-height: 0px;
      }
      #tray menu :hover {
        background-color: @workspacesbackground1;
      }
    '';
  };
}
