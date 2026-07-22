{
  config,
  homeDirectory,
  lib,
  pkgs,
  username,
  ...
}:

{
  home = {
    inherit username homeDirectory;
    sessionPath = [ "/run/system-manager/sw/bin" ];
    stateVersion = "25.11";
  };
  news.display = "silent";
  nix.gc = {
    automatic = true;
    options = "--delete-older-than 30d";
  };
  programs.home-manager.enable = true;
  # Solution 2: Also set up nix environment via systemd service as additional safety layer.
  # This was the original working approach before we tried hm-session-vars.
  systemd.user.services.nix-setup-environment = {
    Install = {
      WantedBy = [ "default.target" ];
    };
    Service = {
      ExecStart = [
        "${lib.getBin pkgs.systemd}/bin/systemctl --user set-environment PATH=/run/system-manager/sw/bin:${homeDirectory}/.nix-profile/bin:/nix/var/nix/profiles/default/bin:\${PATH}"
        "${lib.getBin pkgs.systemd}/bin/systemctl --user set-environment XDG_DATA_DIRS=${homeDirectory}/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share:\${XDG_DATA_DIRS}"
      ];
      Type = "oneshot";
    };
    Unit = {
      Before = [
        "basic.target"
        "default.target"
      ];
      DefaultDependencies = false;
      Description = "Set up nix environment for user session";
    };
  };
  # Enable generic Linux support for proper environment setup
  # This handles shell integration, XDG paths, and session variables
  targets.genericLinux.enable = true;
  # Fix environment for GDM autologin + systemd user services
  #
  # Problem: GDM autologin doesn't load environment.d files, so even though
  # targets.genericLinux sets systemd.user.sessionVariables, they aren't
  # available when the compositor starts.
  #
  # Solution 1: Use user-environment-generator to source both nix.sh and
  # hm-session-vars.sh BEFORE systemd starts any services.
  # See: https://github.com/nix-community/home-manager/issues/1439#issuecomment-3374894606
  xdg.configFile."systemd/user-environment-generators/05-home-manager.sh" =
    let
      nixPkg = if config.nix.package == null then pkgs.nix else config.nix.package;
    in
    {
      executable = true;
      force = true;
      text = ''
        #!/bin/sh
        . "${nixPkg}/etc/profile.d/nix.sh"
        . "${config.home.profileDirectory}/etc/profile.d/hm-session-vars.sh"
      '';
    };
  # Add system-manager and flatpak directories to XDG_DATA_DIRS
  xdg.systemDirs.data = [
    "/run/system-manager/sw/share"
    "${homeDirectory}/.local/share/flatpak/exports/share"
    "/var/lib/flatpak/exports/share"
  ];
}
