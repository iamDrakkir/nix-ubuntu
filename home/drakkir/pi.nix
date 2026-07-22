{
  homeDirectory,
  inputs,
  username,
  ...
}:

{
  imports = [
    # Core modules that work on any Linux
    ../common/core/home.nix
    ../common/core/git.nix
    ../common/core/shell.nix
    ../common/core/nvim.nix

    # User identity
    ./common/git.nix
    ./common/ssh.nix

    # Dev tools
    ../common/optional/development.nix
  ];

  # On NixOS neovim is not provided by system-manager, install it here
  programs.neovim = {
    defaultEditor = true;
    enable = true;
  };

  # Override the genericLinux target — not needed on NixOS
  targets.genericLinux.enable = false;

  # On NixOS, systemd user env fixes from home.nix are still applied but
  # the system-manager path is irrelevant; keep the profile clean.
  xdg.systemDirs.data = [ ];
}
