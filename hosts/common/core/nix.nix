{ pkgs, system, ... }:

{
  nixpkgs.hostPlatform = system;
  system-manager.allowAnyDistro = true;

  # Nix configuration - Determinate Nix manages nix.conf, we add customizations
  nix = {
    enable = false; # Let Determinate Nix manage /etc/nix/nix.conf
  };

  # Add our custom Nix settings via nix.custom.conf (included by Determinate Nix)
  environment.etc."nix/nix.custom.conf" = {
    text = ''
      experimental-features = nix-command flakes
      auto-optimise-store = true
      warn-dirty = false
    '';
  };

  # Auto-cpufreq systemd service
  systemd.services.auto-cpufreq = {
    enable = true;
    description = "auto-cpufreq - Automatic CPU speed & power optimizer";
    wantedBy = [ "multi-user.target" ];
    after = [
      "network.target"
      "system-manager.target"
    ];
    conflicts = [ "power-profiles-daemon.service" ];
    path = with pkgs; [
      bash
      coreutils
      gawk
      gnugrep
      gnused
      util-linux
    ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.auto-cpufreq}/bin/auto-cpufreq --daemon";
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };

  # Mask power-profiles-daemon to prevent conflicts with auto-cpufreq
  systemd.services.power-profiles-daemon.enable = false;

  # Essential system packages present on all hosts
  environment.systemPackages = with pkgs; [
    neovim
    pipewire
    wireplumber
    auto-cpufreq
  ];

  # Link share directories so desktop files and other resources are available
  environment.pathsToLink = [
    "/bin"
    "/share"
  ];

  # Export XDG_DATA_DIRS to include system-manager packages
  environment.etc."profile.d/system-manager-xdg.sh" = {
    text = ''
      export XDG_DATA_DIRS="/run/system-manager/sw/share:''${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
    '';
    mode = "0444";
  };

  # AppArmor profile for bubblewrap
  environment.etc."apparmor.d/nix-bwrap".text = ''
    abi <abi/4.0>,
    include <tunables/global>

    profile bwrap ${pkgs.bubblewrap}/bin/bwrap flags=(unconfined) {
      userns,
      include if exists <local/bwrap>
    }
  '';

  # Configure sudo to include system-manager paths
  environment.etc."sudoers.d/system-manager-path" = {
    text = ''
      Defaults secure_path="/run/system-manager/sw/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin"
    '';
    mode = "0440";
  };
}
