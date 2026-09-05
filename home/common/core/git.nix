{
  config,
  homeDirectory,
  identity,
  ...
}:

{
  programs.git = {
    enable = true;

    settings = {
      advice = {
        addEmptyPathspec = false;
        pushNonFastForward = false;
        statusHints = false;
      };

      blame = {
        coloring = "highlightRecent";
        date = "relative";
      };

      branch.sort = "-committerdate";

      "color.branch" = {
        current = "magenta";
        local = "default";
        plain = "blue";
        remote = "yellow";
        upstream = "green";
      };

      "color.decorate" = {
        HEAD = "red";
        branch = "blue";
        remoteBranch = "magenta";
        tag = "yellow";
      };

      "color.diff" = {
        context = "white";
        frag = "magenta";
        meta = "black bold";
        old = "red";
        whitespace = "yellow reverse";
      };

      commit = {
        # gpgSign = true;  # Uncomment to enable GPG signing
        template = "${homeDirectory}/.config/git/template";
        verbose = true;
      };

      core = {
        autocrlf = "input";
        compression = 9; # Trade CPU for network
        editor = "nvim";
        preloadindex = true;
        whitespace = "error";
      };

      # No credential.helper on purpose. Remotes are SSH (keys come from the
      # Proton Pass agent), so nothing needs a stored password — and the old
      # "store" helper wrote tokens as plaintext to ~/.git-credentials, which
      # never expire and are trivially readable. For the occasional HTTPS
      # remote, prefer `gh auth login` (gh manages its own token) or a
      # short-lived `git -c credential.helper=cache push`.

      diff = {
        context = 3;
        interHunkContext = 10;
        renames = "copies";
      };

      fetch.fsckObjects = true;
      init.defaultBranch = "main";
      interactive.singlekey = true;

      log = {
        abbrevCommit = true;
        graphColors = "blue,yellow,cyan,magenta,green,red";
      };

      pack = {
        packSizeLimit = "1g";
        threads = 0; # Use all available threads
        windowMemory = "1g";
      };

      pager = {
        branch = false;
        tag = false;
      };

      pull = {
        default = "current";
        rebase = true;
      };

      push = {
        autoSetupRemote = true;
        default = "current";
        followTags = true;
      };

      rebase = {
        autoStash = true;
        missingCommitsCheck = "warn";
      };

      receive.fsckObjects = true;

      status = {
        branch = true;
        short = true;
        showStash = true;
        showUntrackedFiles = "all";
      };

      submodule.fetchJobs = 16;
      tag.sort = "-taggerdate";
      transfer.fsckObjects = true;
      # URL shortcuts
      "url \"git@github.com:\"".insteadOf = "gh:";
      "url \"git@github.com:iamDrakkir\"".insteadOf = "drakkir:";
      "url \"git@ssh.dev.azure.com:v3/CTEKSwedenAB/CTEK/\"".insteadOf = "ctek:";

      # Authorship comes from the `identity` specialArg (see flake.nix), so
      # there is exactly one place per user to change name/email.
      user = {
        inherit (identity) email name;
      };
    };
  };

  xdg.configFile."git/template" = {
    force = true;

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
  };
}
