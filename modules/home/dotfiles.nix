{ config, homeDirectory, ... }:

{
  # home.file.".config/hypr/hyprland.conf".source = config.lib.file.mkOutOfStoreSymlink "${homeDirectory}/.config/nix/hyprland.conf";
  # home.file.".config/hypr".source = config.lib.file.mkOutOfStoreSymlink "${homeDirectory}/.dotfiles/hypr/.config/hypr";
  home.file.".config/hypr/hyprpaper.conf".source = config.lib.file.mkOutOfStoreSymlink "${homeDirectory}/.dotfiles/hypr/.config/hypr/hyprpaper.conf";
  home.file.".config/nvim".source = config.lib.file.mkOutOfStoreSymlink "${homeDirectory}/.dotfiles/nvim/.config/nvim";
  home.file.".config/rofi".source = config.lib.file.mkOutOfStoreSymlink "${homeDirectory}/.dotfiles/rofi/.config/rofi";
  home.file.".config/lazygit".source = config.lib.file.mkOutOfStoreSymlink "${homeDirectory}/.dotfiles/lazygit/.config/lazygit";
  home.file.".config/ghostty".source = config.lib.file.mkOutOfStoreSymlink "${homeDirectory}/.dotfiles/ghostty/.config/ghostty";
}
