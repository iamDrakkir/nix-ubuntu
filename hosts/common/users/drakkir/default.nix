{ pkgs, ... }:

{
  # NOTE: users.users is currently a NO-OP in system-manager
  # This configuration documents the intended user setup but doesn't create the user.
  # On non-NixOS systems, create this user manually before applying config:
  #   sudo useradd -m -G wheel,networkmanager -s $(which fish) drakkir
  # On NixOS, this will work automatically when migrated.
  users.users.drakkir = {
    description = "Drakkir";

    extraGroups = [
      "wheel"
      "networkmanager"
    ];

    isNormalUser = true;
    # shell = pkgs.fish;  # Commented out: causes error in system-manager (config.programs doesn't exist)
    # SSH keys can be added in ./keys/ directory
    # openssh.authorizedKeys.keyFiles = [ ./keys/id_rsa.pub ];
  };
}
