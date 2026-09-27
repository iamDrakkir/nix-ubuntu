{ lib, ... }:

{
  imports = [
    # No ../common/users import: the login is the SSSD/AD account, and a
    # same-named local user only gives the greeter a passwordless decoy.
    ../common/core

    # Optional system configs — opt in per host
    ../common/optional/noctalia-greeter.nix
    ../common/optional/umbriel-portal.nix
  ];

  myConfig = {
    # The picker cannot enumerate an AD account, and the short name "rhagelin"
    # is not resolvable by sssd here (use_fully_qualified_names), so the full
    # name is required.
    greetd.defaultUser = lib.custom.domainLogins.work;

    # No hyprland on work: rhagelin's home config only installs niri.
    waylandSessions = [
      "niri"
      "umbriel"
    ];
  };
}
