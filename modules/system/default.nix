{ pkgs, system, ... }:

{
  config = {
    nixpkgs.hostPlatform = "${system}";
    system-manager.allowAnyDistro = true;
    
    system-graphics = {
      enable = true;
      enable32Bit = true;
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
  };
}
