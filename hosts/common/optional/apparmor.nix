{ pkgs, ... }:

{
  # AppArmor configuration for bubblewrap
  environment.etc."apparmor.d/nix-bwrap".text = ''
    abi <abi/4.0>,
    include <tunables/global>

    profile bwrap ${pkgs.bubblewrap}/bin/bwrap flags=(unconfined) {
      userns,
      include if exists <local/bwrap>
    }
  '';
}
