{ pkgs, system, ... }:

{
  # Determinate Nix owns /etc/nix/nix.conf, which `!include`s nix.custom.conf —
  # so customisations go in that file rather than fighting over the main one.
  #
  # replaceExisting: the Determinate installer writes nix.custom.conf itself, so
  # system-manager finds an unmanaged file in place and skips it otherwise.
  environment.etc."nix/nix.custom.conf" = {
    replaceExisting = true;

    text = ''
      experimental-features = nix-command flakes
      auto-optimise-store = true
      warn-dirty = false
    '';
  };

  nix = {
    enable = false; # Let Determinate Nix manage /etc/nix/nix.conf
  };

  nixpkgs.hostPlatform = system;
}
