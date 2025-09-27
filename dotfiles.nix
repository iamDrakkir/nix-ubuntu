{ config, ... }:

{
  #home.file.".config/hypr".source = config.lib.file.mkOutOfStoreSymlink "/home/drakkir/.dotfiles/hypr/.config/hypr";
  home.file.".config/hypr/hyprpaper.conf".source = config.lib.file.mkOutOfStoreSymlink "/home/drakkir/.dotfiles/hypr/.config/hypr/hyprpaper.conf";
  home.file.".config/nvim".source = config.lib.file.mkOutOfStoreSymlink "/home/drakkir/.dotfiles/nvim/.config/nvim";
  home.file.".config/rofi".source = config.lib.file.mkOutOfStoreSymlink "/home/drakkir/.dotfiles/rofi/.config/rofi";
  home.file.".config/lazygit".source = config.lib.file.mkOutOfStoreSymlink "/home/drakkir/.dotfiles/lazygit/.config/lazygit";
  home.file.".config/ghostty".source = config.lib.file.mkOutOfStoreSymlink "/home/drakkir/.dotfiles/ghostty/.config/ghostty";
}
