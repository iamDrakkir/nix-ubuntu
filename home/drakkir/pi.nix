{ ... }:

{
  imports = [
    # Core modules that work on any Linux.
    # NOTE: not `../common/core`, which also pulls in the GUI modules
    # (terminals, noctalia, zen-browser) that a headless Pi has no use for.
    ../common/core/development.nix
    ../common/core/git.nix
    ../common/core/home.nix
    ../common/core/nvim.nix
    ../common/core/shell.nix

    # SSH agent routing (uid comes from the `identity` specialArg)
    ./common/ssh.nix
  ];

  # On NixOS neovim is not provided by system-manager, install it here
  programs.neovim = {
    defaultEditor = true;
    enable = true;
  };

  # Override the genericLinux target — not needed on NixOS. This also turns off
  # the system-manager/flatpak session plumbing in core/home.nix.
  targets.genericLinux.enable = false;
}
