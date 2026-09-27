{
  lib,
  config,
  pkgs,
  homeDirectory,
  username,
  ...
}:

let
  # Everything below that points at system-manager or flatpak paths is only
  # meaningful on the Ubuntu hosts; NixOS hosts (pi) disable genericLinux.
  nonNixos = config.targets.genericLinux.enable;
in

{
  home = {
    inherit homeDirectory username;
    sessionPath = lib.mkIf nonNixos [ "/run/system-manager/sw/bin" ];
    stateVersion = "25.11";
  };

  news.display = "silent";

  nix.gc = {
    automatic = true;
    options = "--delete-older-than 30d";
  };

  programs.home-manager.enable = true;

  # Second layer behind the environment generator below: push PATH and
  # XDG_DATA_DIRS into the systemd user manager before any unit starts.
  systemd.user.services.nix-setup-environment = lib.mkIf nonNixos {
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

  # Enable generic Linux support (shell integration, XDG paths, session
  # variables) on the non-NixOS hosts. NixOS hosts such as pi override this to
  # false in their own home file.
  targets.genericLinux.enable = lib.mkDefault true;

  xdg = {
    # GDM/greetd autologin doesn't load environment.d files, so the
    # systemd.user.sessionVariables that genericLinux sets never reach the
    # compositor. A user-environment-generator sources nix.sh and
    # hm-session-vars.sh before systemd starts any user service.
    # See: https://github.com/nix-community/home-manager/issues/1439#issuecomment-3374894606
    configFile."systemd/user-environment-generators/05-home-manager.sh" = lib.mkIf nonNixos (
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
      }
    );

    # Add system-manager and flatpak directories to XDG_DATA_DIRS
    systemDirs.data = lib.mkIf nonNixos [
      "/run/system-manager/sw/share"
      "${homeDirectory}/.local/share/flatpak/exports/share"
      "/var/lib/flatpak/exports/share"
    ];
  };
}
