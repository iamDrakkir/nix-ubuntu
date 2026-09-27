{
  lib,
  config,
  pkgs,
  hostname,
  ...
}:

let
  # Wrapper: mint a fresh Entra token for the Azure DevOps MCP server before
  # launching opencode. The token expires ~hourly, so relaunch opencode if a
  # session runs long. Only `work` talks to Azure DevOps, and `az` isn't even
  # installed elsewhere — gating keeps the other hosts from paying an `az`
  # round-trip (and a spurious warning) on every launch.
  azMcpAudience = "https://mcp.dev.azure.com";
  azMcpStaleLogin = "opencode: warning: could not mint Azure DevOps MCP token (is 'az login' current?)";
  # deja hardcodes ~/.local/share/deja; it does not honour XDG_DATA_HOME.
  dejaDir = "$HOME/.local/share/deja";
  needsAzMcpToken = hostname == "work";
in

{
  home = {
    packages = with pkgs; [
      curl
      # .dev outputs are headers/pkg-config only; they do not provide binaries.
      curl.dev
      systemd.dev
      nerd-fonts.jetbrains-mono
      just
      nix-output-monitor
      # The generated deja init script shells out to `deja` by name.
      deja
    ];

    # Centralized shell aliases for all shells
    shellAliases = {
      cat = "bat";
      # Quick directory navigation
      cdd = "cd $HOME/.config/nix/dotfiles";
      cdg = "cd $HOME/git";
      cdi = "cd $HOME/.config/nix";
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
  };

  programs = {
    bat = {
      config = {
        theme = "TwoDark";
      };

      enable = true;
    };

    btop = {
      enable = true;
    };

    eza = {
      enable = true;
      git = true;
      icons = "auto";
    };

    fastfetch = {
      enable = true;
    };

    fd = {
      enable = true;
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    lazygit = {
      enable = true;
    };

    opencode = {
      enable = true;
    };

    ripgrep = {
      enable = true;
    };

    starship = {
      enable = true;
      enableZshIntegration = true;

      settings = {
        add_newline = true;

        character = {
          error_symbol = "[➜](bold red)";
          success_symbol = "[➜](bold green)";
        };
      };
    };

    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

    zsh = {
      # `cd`-less directory jumping, like fish's implicit cd.
      autocd = true;
      # deja replaces zsh-autosuggestions and deliberately stands down if it
      # detects zsh-autosuggestions loaded (both wrap the same ZLE widgets).
      autosuggestion.enable = false;
      dotDir = "${config.xdg.configHome}/zsh";
      enable = true;
      enableCompletion = true;
      # F-Sy-H over zsh-syntax-highlighting: it is meaningfully faster on long
      # lines and highlights more (paths, globs, subshells, here-strings).
      fastSyntaxHighlighting.enable = true;

      history = {
        expireDuplicatesFirst = true;
        extended = true;
        ignoreAllDups = true;
        # Leading space keeps a command out of both zsh history and deja's DB.
        ignoreSpace = true;
        path = "${config.xdg.dataHome}/zsh/history";
        save = 100000;
        share = true;
        size = 100000;
      };

      # fish's signature up-arrow: filter history by what is already typed.
      # home-manager sources this at order 1250, i.e. after F-Sy-H, as its
      # README requires.
      historySubstringSearch = {
        enable = true;

        searchDownKey = [
          "^[[B"
          "^N"
        ];

        searchUpKey = [
          "^[[A"
          "^P"
        ];
      };

      initContent = lib.mkMerge [
        # --- 550: before compinit (570) and before plugins are sourced (900).
        (lib.mkOrder 550 ''
          # LS_COLORS drives both eza-less completion colouring and fzf-tab's
          # file colours; nothing else in this config exports it.
          eval "$(${pkgs.coreutils}/bin/dircolors -b)"

          # zsh-vi-mode defers its setup to the first prompt by default, which
          # then clobbers every bindkey made later in .zshrc (fzf's ^R, fzf-tab's
          # ^I, deja's widgets). `sourcing` makes it initialise inline at the
          # source below, so everything after it wins.
          ZVM_INIT_MODE=sourcing
          ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT
          ZVM_CURSOR_STYLE_ENABLED=true

          # Completion behaviour (fish-ish: case-insensitive, substring, in-word).
          zstyle ':completion:*' matcher-list 'm:{a-zA-Z-_}={A-Za-z_-}' 'r:|=*' 'l:|=* r:|=*'
          zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
          zstyle ':completion:*' group-name ""
          zstyle ':completion:*:descriptions' format '[%d]'
          zstyle ':completion:*' special-dirs true
          # fzf-tab requires the native menu to be off; it renders its own.
          zstyle ':completion:*' menu no

          # fzf-tab: the closest thing zsh has to fish's completion pager.
          zstyle ':fzf-tab:*' use-fzf-default-opts yes
          zstyle ':fzf-tab:*' switch-group '<' '>'
          zstyle ':fzf-tab:*' prefix ""
          zstyle ':fzf-tab:complete:cd:*' fzf-preview '${lib.getExe pkgs.eza} -1 --color=always --icons $realpath'
          zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview '${lib.getExe pkgs.eza} -1 --color=always --icons $realpath'
          zstyle ':fzf-tab:complete:(bat|cat|nvim|v|vi|vim):*' fzf-preview '${lib.getExe pkgs.bat} --color=always --style=numbers --line-range=:200 $realpath'
        '')

        # --- 1000: default slot.
        (lib.mkOrder 1000 ''
          ${lib.optionalString needsAzMcpToken ''
            # See azMcpAudience at the top of this file.
            opencode() {
              local token
              token=$(az account get-access-token --resource ${azMcpAudience} --query accessToken -o tsv 2>/dev/null)
              if [[ -n "$token" ]]; then
                export AZURE_DEVOPS_MCP_TOKEN="$token"
              else
                echo "${azMcpStaleLogin}" >&2
              fi
              command opencode "$@"
            }
          ''}
          # opencode completion
          _opencode() {
            local -a completions
            completions=(''${(f)"$(opencode --get-yargs-completions "''${words[@]}")"})
            compadd -a completions
          }
          compdef _opencode opencode
        '')

        # --- 1300: last. After F-Sy-H (1200) and history-substring-search
        # (1250), because deja wraps ZLE widgets and must see the final set.
        (lib.mkOrder 1300 ''
          # deja: predictive ghost-text autosuggestions. Unlike
          # zsh-autosuggestions it ranks on fuzzy match + frecency + directory
          # affinity + command-sequence, served by one Go daemon over a unix
          # socket. Data is local-only SQLite.
          #
          # Tab is fzf-tab's and ^N/^P are history-substring-search's, so park
          # deja's alternatives picker on Shift+Tab, which zle leaves unbound.
          # Both vars are read once, at source time, so they must be set first.
          export DEJA_CYCLE_KEY='^[[Z'
          export DEJA_HIGHLIGHT_STYLE='fg=8,bold'

          # `deja init zsh` *writes* ${dejaDir}/init.zsh and prints a source
          # line; it does not print the script. Sourcing the cached file skips
          # a ~30ms binary launch on every shell. deja compares the running
          # binary against the one baked into the cache and regenerates in the
          # background, so a nixpkgs bump self-heals without a slow startup.
          if [[ -r "${dejaDir}/init.zsh" ]]; then
            source "${dejaDir}/init.zsh"
          else
            deja import >/dev/null 2>&1
            eval "$(deja init zsh)"
          fi

          # vi-mode history search, matching the ^P/^N and arrow bindings above.
          bindkey -M vicmd 'k' history-substring-search-up
          bindkey -M vicmd 'j' history-substring-search-down
        '')
      ];

      # Sourced at order 900. List order matters: zsh-vi-mode first so that
      # fzf-tab's ^I binding is installed after zvm has finished rebinding.
      plugins = [
        {
          file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
          name = "zsh-vi-mode";
          src = pkgs.zsh-vi-mode;
        }
        {
          file = "share/fzf-tab/fzf-tab.plugin.zsh";
          name = "fzf-tab";
          src = pkgs.zsh-fzf-tab;
        }
      ];

      setOptions = [
        "ALWAYS_TO_END"
        "AUTO_PUSHD"
        "COMPLETE_IN_WORD"
        "EXTENDED_GLOB"
        "GLOB_DOTS"
        "INTERACTIVE_COMMENTS"
        "NO_BEEP"
        "PUSHD_IGNORE_DUPS"
        "PUSHD_SILENT"
      ];

      # EXTENDED_GLOB makes `#` a glob operator, which breaks `nixpkgs#foo`.
      shellAliases.nix = "noglob nix";
    };
  };
}
