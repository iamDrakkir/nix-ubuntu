{ config, lib, pkgs, homeDirectory, ... }:

{
  programs.git = {
    enable = true;

    settings = {
      user = {
        name = config.profile.git.userName;
        email = config.profile.git.userEmail;
        # signingkey = "YOUR_GPG_KEY";  # Uncomment to enable GPG signing
      };

      # Commit settings
      commit = {
        # gpgSign = true;  # Uncomment to enable GPG signing
        template = "${homeDirectory}/.config/git/template";
        verbose = true;  # Add more context to commit messages
      };

      # Core settings
      core = {
        editor = "nvim";
        autocrlf = "input";  # Keep newlines as in input
        compression = 9;  # Trade CPU for network
        whitespace = "error";  # Treat incorrect whitespace as errors
        preloadindex = true;  # Preload index for faster status
      };

      # Credential helper
      credential.helper = "store";

      # Disable advice messages
      advice = {
        addEmptyPathspec = false;
        pushNonFastForward = false;
        statusHints = false;
      };

      # Blame settings
      blame = {
        coloring = "highlightRecent";
        date = "relative";
      };

      # Diff settings
      diff = {
        context = 3;
        renames = "copies";  # Detect copies as renames
        interHunkContext = 10;  # Merge near hunks
      };

      # Init settings
      init.defaultBranch = "main";

      # Log settings
      log = {
        abbrevCommit = true;
        graphColors = "blue,yellow,cyan,magenta,green,red";
      };

      # Status settings
      status = {
        branch = true;
        short = true;
        showStash = true;
        showUntrackedFiles = "all";
      };

      # Pager settings
      pager = {
        branch = false;
        tag = false;
      };

      # Push settings
      push = {
        autoSetupRemote = true;  # Easier to push new branches
        default = "current";  # Push only current branch
        followTags = true;  # Push tags too
      };

      # Pull settings
      pull = {
        rebase = true;
        default = "current";
      };

      # Submodule settings
      submodule.fetchJobs = 16;

      # Rebase settings
      rebase = {
        autoStash = true;
        missingCommitsCheck = "warn";
      };

      # Performance settings
      pack = {
        threads = 0;  # Use all available threads
        windowMemory = "1g";
        packSizeLimit = "1g";
      };

      # Integrity checks
      transfer.fsckObjects = true;
      receive.fsckObjects = true;
      fetch.fsckObjects = true;

      # Sorting
      branch.sort = "-committerdate";
      tag.sort = "-taggerdate";

      # Colors
      "color.branch" = {
        current = "magenta";
        local = "default";
        remote = "yellow";
        upstream = "green";
        plain = "blue";
      };

      "color.diff" = {
        meta = "black bold";
        frag = "magenta";
        context = "white";
        whitespace = "yellow reverse";
        old = "red";
      };

      "color.decorate" = {
        HEAD = "red";
        branch = "blue";
        tag = "yellow";
        remoteBranch = "magenta";
      };

      # Interactive settings
      interactive.singlekey = true;

      # URL shortcuts
      "url \"git@github.com:\"".insteadOf = "gh:";
      "url \"git@github.com:iamDrakkir\"".insteadOf = "drakkir:";
    };
  };

  # Commit message template with emojis
  xdg.configFile."git/template" = {
    text = ''
      # feat: ✨ new feature
      # feat: 🔍 search/find feature
      # feat: 🔗 linking/integration
      # feat: 🔒 security feature

      # fix: 🐛 general bug fix
      # fix: 🐞 minor bug fix
      # fix: 🩹 simple fix
      # fix: 🚑️ critical hotfix

      # style: 💅 styling/formatting
      # style: 🎨 code structure
      # style: 💄 UI/cosmetic

      # ci: 🦊 CI/CD changes
      # ci: 📦 build/package

      # deploy: 🚀 deployment
      # chore: 🧹 maintenance
      # chore: 🔧 config/tools
      # docs: 📜 documentation

      # refactor: 🔨 code refactoring
      # perf: ⚡ performance improvement
      # test: 🚦 testing
      # debug: 🧪 debugging

      # BREAKING CHANGE: 🚨 breaking change
      # BREAKING CHANGE: 💥 major breaking change
    '';
    force = true;
  };
}
