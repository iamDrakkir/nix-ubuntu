{ pkgs, system, ... }:

{
  nixpkgs.hostPlatform = system;
  system-manager.allowAnyDistro = true;
  
  # Nix configuration
  nix = {
    package = pkgs.nix;
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
    };
  };

  system-graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Auto-cpufreq systemd service
  systemd.services.auto-cpufreq = {
    enable = true;
    description = "auto-cpufreq - Automatic CPU speed & power optimizer";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    path = with pkgs; [ bash coreutils ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.auto-cpufreq}/bin/auto-cpufreq --daemon";
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };

  environment.systemPackages = with pkgs; [
    git
    neovim
    flatpak
    pipewire
    wireplumber
    auto-cpufreq
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
