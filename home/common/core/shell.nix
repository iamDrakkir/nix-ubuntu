{
  config,
  lib,
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    curl
    # .dev outputs are headers/pkg-config only; they do not provide binaries.
    curl.dev
    systemd.dev
    nerd-fonts.jetbrains-mono
    just
    nix-output-monitor
  ];
  # Centralized shell aliases for all shells
  home.shellAliases = {
    cat = "bat";
    # Quick directory navigation
    cdd = "cd $HOME/.config/nix/dotfiles";
    cdg = "cd $HOME/git";
    cdn = "cd $HOME/.config/nix/dotfiles/nvim/";
    cdw = "cd $HOME/git/work";
    ga = "git add";
    gap = "git add --patch";
    gb = "git branch";
    gba = "git branch --all";
    gc = "git commit";
    gca = "git commit --amend --no-edit";
    gce = "git commit --amend";
    gcl = "git clone --recursive";
    gco = "git checkout";
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
    la = "eza -la";
    ll = "eza -l";
    lla = "eza -la";
    ls = "eza";
    pre = "uvx --with pre-commit-uv pre-commit run --all-files";
    tree = "eza --tree";
    v = "nvim";
    vi = "nvim";
    vim = "nvim";
  };
  programs.bat = {
    config = {
      theme = "TwoDark";
    };
    enable = true;
  };
  programs.btop = {
    enable = true;
  };
  programs.eza = {
    enable = true;
    git = true;
    icons = "auto";
  };
  programs.fastfetch = {
    enable = true;
  };
  programs.fd = {
    enable = true;
  };
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      # Enable vi mode
      fish_vi_key_bindings

      # Initialize zoxide
      zoxide init fish | source
    '';
  };
  programs.fzf = {
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
  programs.ripgrep = {
    enable = true;
  };
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
    settings = {
      add_newline = true;
      character = {
        error_symbol = "[➜](bold red)";
        success_symbol = "[➜](bold green)";
      };
    };
  };
  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
  };
  programs.zsh = {
    autosuggestion.enable = true;
    dotDir = "${config.xdg.configHome}/zsh";
    enable = true;
    enableCompletion = true;
    initContent = ''
      # Initialize zoxide
      eval "$(zoxide init zsh)"

      # opencode completion
      _opencode() {
        local -a completions
        completions=(''${(f)"$(opencode --get-yargs-completions "''${words[@]}")"})
        compadd -a completions
      }
      compdef _opencode opencode
    '';
    syntaxHighlighting.enable = true;
  };
  xdg.configFile."fish/completions/opencode.fish".text = ''
    function __fish_opencode_completions
        set -l cmd (commandline -opc)
        opencode --get-yargs-completions $cmd 2>/dev/null
    end

    complete -c opencode -f -a '(__fish_opencode_completions)'
  '';
}
