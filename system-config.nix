{ nixpkgs, system-manager, nix-system-graphics, ... }:

{
  systemConfigs.default = system-manager.lib.makeSystemConfig {
    modules = [
      nix-system-graphics.systemModules.default

      ({ config, pkgs, ... }: {
        nixpkgs.hostPlatform = "x86_64-linux";
        system-manager.allowAnyDistro = true;
        system-graphics.enable = true;

        environment.systemPackages = with pkgs; [
          git
          neovim
          hyprland
          rofi
          xdg-desktop-portal
          xdg-desktop-portal-gtk
          proton-pass
        ];
      })
    ];
  };
}
