{ pkgs, system, ... }:

{
  # AppArmor profile for bubblewrap
  environment.etc."apparmor.d/nix-bwrap".text = ''
    abi <abi/4.0>,
    include <tunables/global>

    profile bwrap ${pkgs.bubblewrap}/bin/bwrap flags=(unconfined) {
      userns,
      include if exists <local/bwrap>
    }
  '';
  # Add our custom Nix settings via nix.custom.conf (included by Determinate Nix)
  # replaceExisting: the Determinate installer writes this file itself, so
  # system-manager finds an unmanaged file in place and skips it otherwise.
  environment.etc."nix/nix.custom.conf" = {
    replaceExisting = true;

    text = ''
      experimental-features = nix-command flakes
      auto-optimise-store = true
      warn-dirty = false
    '';
  };
  # Configure sudo to include system-manager paths
  environment.etc."sudoers.d/system-manager-path" = {
    mode = "0440";
    text = ''
      Defaults secure_path="/run/system-manager/sw/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin"
    '';
  };
  # Link share directories so desktop files and other resources are available
  environment.pathsToLink = [
    "/bin"
    "/share"
  ];
  # Essential system packages present on all hosts
  environment.systemPackages = with pkgs; [
    neovim
    pipewire
    wireplumber
    auto-cpufreq
  ];
  # Nix configuration - Determinate Nix manages nix.conf, we add customizations
  nix = {
    enable = false; # Let Determinate Nix manage /etc/nix/nix.conf
  };
  nixpkgs.hostPlatform = system;
  system-manager.allowAnyDistro = true;
  # Auto-cpufreq systemd service
  systemd.services.auto-cpufreq = {
    after = [
      "network.target"
      "system-manager.target"
    ];
    conflicts = [ "power-profiles-daemon.service" ];
    description = "auto-cpufreq - Automatic CPU speed & power optimizer";
    enable = true;
    path = with pkgs; [
      bash
      coreutils
      gawk
      gnugrep
      gnused
      util-linux
    ];
    serviceConfig = {
      ExecStart = "${pkgs.auto-cpufreq}/bin/auto-cpufreq --daemon";
      Restart = "on-failure";
      RestartSec = "5s";
      Type = "simple";
    };
    wantedBy = [ "multi-user.target" ];
  };
  # Mask power-profiles-daemon to prevent conflicts with auto-cpufreq
  systemd.services.power-profiles-daemon.enable = false;
}
