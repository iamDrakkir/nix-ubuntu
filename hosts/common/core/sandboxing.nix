{ pkgs, ... }:

# Ubuntu 24.04+ ships AppArmor restrictions on unprivileged user namespaces,
# which break every bubblewrap-based sandbox: Steam, Flatpak, Snap, Electron
# apps. Both halves of the workaround live here.
#
# Reference: https://linuxcapable.com/how-to-enable-or-disable-apparmor-on-ubuntu-linux/
# Section: "Disabling Restrictions System-Wide"
#
# NOTE: written as one merged `environment.etc` block on purpose — pedantix
# merges repeated attrpaths but treats comments as positional, so splitting
# these into `environment.etc.<a>` / `environment.etc.<b>` with comments makes
# it refuse to format the file.
{
  environment.etc = {
    # An unconfined AppArmor profile for the Nix-provided bwrap binary, which
    # the distro profile doesn't know about.
    "apparmor.d/nix-bwrap".text = ''
      abi <abi/4.0>,
      include <tunables/global>

      profile bwrap ${pkgs.bubblewrap}/bin/bwrap flags=(unconfined) {
        userns,
        include if exists <local/bwrap>
      }
    '';

    # Allow unprivileged processes to create user namespaces at all.
    "sysctl.d/99-enable-userns.conf".text = ''
      # Allow unprivileged user namespaces for bubblewrap-based applications
      # Required for: Steam, Flatpak, Snap applications, and other sandboxed apps
      kernel.apparmor_restrict_unprivileged_userns = 0
    '';
  };
}
