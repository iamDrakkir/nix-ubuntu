{
  lib,
  config,
  pkgs,
  ...
}:

{
  home = {
    packages = with pkgs; [
      steam
      lutris
      gamemode
      wowup-cf
    ];

    sessionVariables = {
      MANGOHUD = "1";
    };
  };

  programs.mangohud = {
    enable = true;

    settings = {
      background_alpha = 0.5;
      # CPU stats
      cpu_stats = true;
      cpu_temp = true;
      # FPS and frametimes
      fps = true;
      frame_timing = true;
      frametime = true;
      gpu_core_clock = true;
      # GPU stats
      gpu_stats = true;
      gpu_temp = true;
      # Graphs - displays temp and load graphs
      # Available: gpu_load, cpu_load, gpu_core_clock, gpu_mem_clock, vram, ram, cpu_temp, gpu_temp
      graphs = "gpu_temp,cpu_temp";
      # Display settings
      position = "top-left";
      # Keybinds
      toggle_hud = "F12";
      toggle_hud_position = "F11";
    };
  };
}
