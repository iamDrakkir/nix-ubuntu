{
  ...
}:
# inpired by https://haseebmajid.dev/posts/2025-12-12-how-to-fix-pam-issues-with-home-manager-on-non-nixos-setups/
{
  # PAM authentication fix for non-NixOS
  # Redirects PAM calls from Nix-installed binaries to the host system's PAM
  # via `config.lib.pamShim.replacePam`. Noctalia is the only consumer; its
  # package is assembled in core/noctalia.nix, which applies that transform
  # alongside the SSSD NSS fix the account stack depends on.
  pamShim.enable = true;
}
