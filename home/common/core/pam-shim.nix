{
  lib,
  config,
  inputs,
  system,
  ...
}:
# inpired by https://haseebmajid.dev/posts/2025-12-12-how-to-fix-pam-issues-with-home-manager-on-non-nixos-setups/
{
  # PAM authentication fix for non-NixOS
  # Redirects PAM calls from Nix-installed binaries to the host system's PAM
  pamShim.enable = true;

  # Replace PAM in the noctalia package directly so the lockscreen can
  # authenticate against the host's PAM stack on non-NixOS.
  programs.noctalia.package = lib.mkIf config.programs.noctalia.enable (
    config.lib.pamShim.replacePam inputs.noctalia.packages.${system}.default
  );
}
