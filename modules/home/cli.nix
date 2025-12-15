{ config, lib, pkgs, ... }:

{
  # Centralized shell aliases for all shells
  home.shellAliases = {
    # ls/eza
    ls = "eza --icons";
    ll = "eza -l --icons";
    la = "eza -la --icons";
    tree = "eza --tree --icons";
    
    # bat/cat
    cat = "bat";
    
    # git
    ga = "git add";
    gap = "git add --patch";
    gb = "git branch";
    gba = "git branch --all";
    gc = "git commit";
    gca = "git commit --amend --no-edit";
    gce = "git commit --amend";
    gco = "git checkout";
    gcl = "git clone --recursive";
    gd = "git diff";
    gds = "git diff --staged";
    gi = "git init";
    gl = "git log --graph --all --pretty=format:'%C(magenta)%h %C(white) %an  %ar%C(auto)  %D%n%s%n'";
    gm = "git merge";
    gn = "git checkout -b";  # new branch
    gp = "git push";
    gr = "git reset";
    gs = "git status --short";
    gu = "git pull";
  };

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

