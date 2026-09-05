{ ... }:

{
  imports = [
    ../common/core
    ../common/users/drakkir

    # Optional system configs — opt in per host.
    # No corectrl here: bigbox is not an AMD machine.
    ../common/optional/flatpak.nix
  ];

  myConfig.waylandSessions = [
    "hyprland"
    "niri"
  ];

  # Host-specific overrides for bigbox
  # Add any bigbox-specific system packages or configurations here
}
