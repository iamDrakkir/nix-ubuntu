{ ... }:

{
  imports = [
    ../common/core
    ../common/users/drakkir

    # Optional system configs — opt in per host
    ../common/optional/corectrl.nix
    ../common/optional/flatpak.nix
    ../common/optional/gdm-appearance.nix
    ../common/optional/umbriel-portal.nix
  ];

  myConfig = {
    # GDM enumerates these the opposite way round to niri, which puts DP-1
    # first — established empirically, see gdm-appearance.nix.
    gdm = {
      outputOrder = [
        "DP-2"
        "DP-1"
      ];

      wallpaper = ../common/optional/gdm/background.png;
    };

    waylandSessions = [
      "hyprland"
      "niri"
      "umbriel"
    ];
  };
}
