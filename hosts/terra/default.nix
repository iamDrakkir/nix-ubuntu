{ ... }:

{
  imports = [
    ../common/core
    ../common/users/drakkir

    # Optional system configs — opt in per host
    ../common/optional/corectrl.nix
    ../common/optional/flatpak.nix
    # gdm-appearance stays imported alongside the greeter: it only configures
    # GDM's look and is inert while greetd owns the login screen, so falling
    # back is `systemctl enable --now gdm` rather than a rebuild.
    ../common/optional/gdm-appearance.nix
    ../common/optional/noctalia-greeter.nix
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

    # Boot goes straight to the desktop, as GDM's AutomaticLogin did. greetd
    # runs this once per boot only, so logging out returns to the greeter.
    greetd.autologin = {
      enable = true;
      session = "umbriel";
      user = "drakkir";
    };

    waylandSessions = [
      "hyprland"
      "niri"
      "umbriel"
    ];
  };
}
