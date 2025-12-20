{
  config,
  lib,
  pkgs,
  homeDirectory,
  ...
}:

{
  programs.git = {
    enable = true;

    settings = {
      user = {
        name = lib.mkDefault "iamDrakkir";
        email = lib.mkDefault "Hagelin.Rickard@gmail.com";
        # signingkey = "YOUR_GPG_KEY";  # Uncomment to enable GPG signing
      };

      # Commit settings
      commit = {
        # gpgSign = true;  # Uncomment to enable GPG signing
        template = "${homeDirectory}/.config/git/template";
        verbose = true; # Add more context to commit messages
      };

      # Core settings
      core = {
        editor = "nvim";
        autocrlf = "input"; 
        compression = 9; # Trade CPU for network
        whitespace = "error";
        preloadindex = true; # Preload index for faster status
      };

      credential.helper = "store";

      advice = {
        addEmptyPathspec = false;
        pushNonFastForward = false;
        statusHints = false;
      };

      blame = {
        coloring = "highlightRecent";
        date = "relative";
      };

      diff = {
        context = 3;
        renames = "copies";
        interHunkContext = 10;
      };

      init.defaultBranch = "main";

      log = {
        abbrevCommit = true;
        graphColors = "blue,yellow,cyan,magenta,green,red";
      };

      status = {
        branch = true;
        short = true;
        showStash = true;
        showUntrackedFiles = "all";
      };

      pager = {
        branch = false;
        tag = false;
      };

      push = {
        autoSetupRemote = true;
        default = "current";
        followTags = true;
      };

      pull = {
        rebase = true;
        default = "current";
      };

      submodule.fetchJobs = 16;

      rebase = {
        autoStash = true;
        missingCommitsCheck = "warn";
      };

      pack = {
        threads = 0; # Use all available threads
        windowMemory = "1g";
        packSizeLimit = "1g";
      };

      transfer.fsckObjects = true;
      receive.fsckObjects = true;
      fetch.fsckObjects = true;

      branch.sort = "-committerdate";
      tag.sort = "-taggerdate";

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

      interactive.singlekey = true;

      # URL shortcuts
      "url \"git@github.com:\"".insteadOf = "gh:";
      "url \"git@github.com:iamDrakkir\"".insteadOf = "drakkir:";
    };
  };

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
