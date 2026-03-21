{ ... }:

{
  # Disable AppArmor's unprivileged user namespace restrictions
  # This is required for Steam, Flatpak, and other sandboxed applications
  # that use bubblewrap (bwrap) for sandboxing on Ubuntu 24.04+
  #
  # Reference: https://linuxcapable.com/how-to-enable-or-disable-apparmor-on-ubuntu-linux/
  # Section: "Disabling Restrictions System-Wide"
  #
  # This sets: kernel.apparmor_restrict_unprivileged_userns = 0
  # Which allows unprivileged processes to create user namespaces
  environment.etc."sysctl.d/99-enable-userns.conf".text = ''
    # Allow unprivileged user namespaces for bubblewrap-based applications
    # Required for: Steam, Flatpak, Snap applications, and other sandboxed apps
    kernel.apparmor_restrict_unprivileged_userns = 0
  '';
}
