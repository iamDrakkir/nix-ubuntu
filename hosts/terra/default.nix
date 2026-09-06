{ ... }:

{
  imports = [
    ../common/core
    ../common/users/drakkir

    # Optional system configs — opt in per host
    ../common/optional/corectrl.nix
    ../common/optional/flatpak.nix
    ../common/optional/umbriel-portal.nix
  ];

  myConfig.waylandSessions = [
    "hyprland"
    "niri"
    "umbriel"
  ];
}
