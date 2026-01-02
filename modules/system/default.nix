{ pkgs, system, auto-cpufreq-pkg, ... }:

{
  nixpkgs.hostPlatform = system;
  system-manager.allowAnyDistro = true;

  system-graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Auto-cpufreq systemd service (using flake version)
  systemd.services.auto-cpufreq = {
    enable = true;
    description = "auto-cpufreq - Automatic CPU speed & power optimizer";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    path = with pkgs; [ bash coreutils ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${auto-cpufreq-pkg}/bin/auto-cpufreq --daemon";
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };

  environment.systemPackages = with pkgs; [
    git
    neovim
    ghostty
    flatpak
    pipewire
    wireplumber
    grim
    slurp
    wl-clipboard
    auto-cpufreq-pkg
  ];

  environment.etc."apparmor.d/nix-bwrap".text = ''
    abi <abi/4.0>,
    include <tunables/global>

    profile bwrap ${pkgs.bubblewrap}/bin/bwrap flags=(unconfined) {
      userns,
      include if exists <local/bwrap>
    }
  '';
}
