{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    btop
    curl
    eza
    fd
    lazygit
    nerd-fonts.jetbrains-mono
    node2nix
    nodejs_24
    ripgrep
    stow
    uv
    gnumake
    gcc
    fastfetch
    cargo
  ];

  # Configure Fish shell
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      # Initialize zoxide
      zoxide init fish | source
      
      # Set up aliases
      alias ls="eza --icons"
      alias ll="eza -l --icons"
      alias la="eza -la --icons"
      alias cat="bat"
    '';
  };

  # Configure Starship prompt
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
    settings = {
      add_newline = true;
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };
    };
  };

  # Configure Zsh
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    initContent = ''
      # Initialize zoxide
      eval "$(zoxide init zsh)"
      
      # Set up aliases
      alias ls="eza --icons"
      alias ll="eza -l --icons"
      alias la="eza -la --icons"
      alias cat="bat"
    '';
  };

  # Configure other CLI tools
  programs.bat = {
    enable = true;
    config = {
      theme = "TwoDark";
    };
  };

  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
  };
}

