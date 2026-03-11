{
  config,
  lib,
  inputs,
  system,
  ...
}:
# inpired by https://haseebmajid.dev/posts/2025-12-12-how-to-fix-pam-issues-with-home-manager-on-non-nixos-setups/
{
  # PAM authentication fix for non-NixOS
  # Redirects PAM calls from Nix-installed binaries to the host system's PAM
  pamShim.enable = true;

  # Replace PAM in the noctalia-shell package directly
  # The nixpkgs overlay approach doesn't work because noctalia-shell brings its
  # own quickshell (from noctalia-qs), not pkgs.quickshell from nixpkgs
  programs.noctalia-shell.package = lib.mkIf config.programs.noctalia-shell.enable (
    config.lib.pamShim.replacePam inputs.noctalia.packages.${system}.default
  );
}
