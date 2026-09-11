{ ... }:

{
  imports = [
    ../common/core

    ../common/users/rhagelin

    # Optional system configs — opt in per host
    ../common/optional/noctalia-greeter.nix
    ../common/optional/umbriel-portal.nix
  ];

  myConfig = {
    # The picker cannot enumerate an AD account, and the short name "rhagelin"
    # is not resolvable by sssd here (use_fully_qualified_names), so the full
    # name is required.
    greetd.defaultUser = "rhagelin@creatorctek.local";

    # No hyprland on work: rhagelin's home config only installs niri.
    waylandSessions = [
      "niri"
      "umbriel"
    ];
  };
}
