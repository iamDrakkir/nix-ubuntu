{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Centralized shell aliases for all shells
  home.shellAliases = {
    ls = "eza";
    ll = "eza -l";
    la = "eza -la";
    lla = "eza -la";
    tree = "eza --tree";

    cat = "bat";

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
    gn = "git checkout -b";
    gp = "git push";
    gr = "git reset";
    gs = "git status --short";
    gu = "git pull";

    hms = "home-manager switch --flake ~/.config/nix#\$USER@(hostname)";
    syss = "cd ~/.config/nix && sudo env PATH=\$PATH system-manager switch --flake .#(hostname)";
    nix-rebuild = "home-manager switch --flake ~/.config/nix#\$USER@(hostname) && cd ~/.config/nix && sudo env PATH=\$PATH system-manager switch --flake .#(hostname)";
  };

  home.packages = with pkgs; [
    curl
    nerd-fonts.jetbrains-mono
    just
  ];
  
  programs.fastfetch = {
    enable = true;
  };
  
  programs.ripgrep = {
    enable = true;
  };
  
  programs.fd = {
    enable = true;
  };

  programs.eza = {
    enable = true;
    icons = true;
    git = true;
  };

  programs.btop = {
    enable = true;
  };

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

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      # Initialize zoxide
      zoxide init fish | source
    '';
  };


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

  programs.lazygit = {
    enable = true;
  };

  programs.opencode = {
    enable = true;
  };
}
