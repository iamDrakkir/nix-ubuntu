{ pkgs, ... }:

{
  # NOTE: users.users is currently a NO-OP in system-manager
  # This configuration documents the intended user setup but doesn't create the user.
  # On non-NixOS systems, create this user manually before applying config:
  #   sudo useradd -m -G wheel,networkmanager -s $(which fish) drakkir
  # On NixOS, this will work automatically when migrated.
  users.users.drakkir = {
    isNormalUser = true;
    description = "Drakkir";
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    shell = pkgs.fish;
    # SSH keys can be added in ./keys/ directory
    # openssh.authorizedKeys.keyFiles = [ ./keys/id_rsa.pub ];
  };
}
