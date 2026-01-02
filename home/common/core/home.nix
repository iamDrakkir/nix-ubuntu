{
  lib,
  pkgs,
  username,
  homeDirectory,
  ...
}:

{
  home = {
    inherit username homeDirectory;
    stateVersion = "25.11";
    sessionPath = [ "/run/system-manager/sw/bin" ];
  };

  programs.home-manager.enable = true;

  news.display = "silent";

  nix.gc = {
    automatic = true;
    options = "--delete-older-than 30d";
  };

  # Fix PATH for systemd user session to include nix profiles
  #
  # Problem: GDM autologin doesn't load environment.d files, causing systemd
  # user services and compositor exec-once commands to not find nix packages.
  #
  # Solution: Run a systemd service before basic.target that sets PATH in the
  # systemd user environment. This ensures all user services and compositors
  # inherit the correct PATH.
  #
  # This fixes:
  # - Compositor autostart programs (e.g., noctalia-shell, hyprpaper)
  # - Keybindings that execute nix-installed programs
  # - Terminal programs like nvim launched from compositor
  systemd.user.services.nix-setup-environment = {
    Unit = {
      Description = "Set up nix environment for user session";
      Before = [
        "basic.target"
        "default.target"
      ];
      DefaultDependencies = false;
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${lib.getBin pkgs.systemd}/bin/systemctl --user set-environment PATH=/run/system-manager/sw/bin:${homeDirectory}/.nix-profile/bin:/nix/var/nix/profiles/default/bin:\${PATH}";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
