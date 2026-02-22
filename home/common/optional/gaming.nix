{
  config,
  lib,
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    steam
    lutris
    gamemode
    wowup-cf
  ];

  programs.mangohud = {
    enable = true;
    settings = {
      # GPU stats
      gpu_stats = true;
      gpu_temp = true;
      gpu_core_clock = true;

      # CPU stats
      cpu_stats = true;
      cpu_temp = true;

      # FPS and frametimes
      fps = true;
      frametime = true;
      frame_timing = true;

      # Graphs - displays temp and load graphs
      # Available: gpu_load, cpu_load, gpu_core_clock, gpu_mem_clock, vram, ram, cpu_temp, gpu_temp
      graphs = "gpu_temp,cpu_temp";

      # Keybinds
      toggle_hud = "F12";
      toggle_hud_position = "F11";

      # Display settings
      position = "top-left";
      background_alpha = 0.5;
    };
  };

  home.sessionVariables = {
    MANGOHUD = "1";
  };
}
