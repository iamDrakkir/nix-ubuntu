{ ... }:

{
  imports = [
    ../common/core
    ../common/users/rhagelin
  ];

  # No hyprland on work: rhagelin's home config only installs niri.
  myConfig.waylandSessions = [ "niri" ];

  # Host-specific overrides for work
  # Add any work-specific system packages or configurations here
}
