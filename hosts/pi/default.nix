{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    # Raspberry Pi 4/5 hardware support
    "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
  ];

  # ========== Boot ==========
  boot = {
    # Use latest kernel for best RPi 4/5 support
    kernelPackages = pkgs.linuxPackages_latest;

    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
  };

  # ========== Networking ==========
  networking = {
    hostName = "pi";
    networkmanager.enable = true;
  };

  # ========== Locale / Time ==========
  time.timeZone = "Europe/Stockholm";
  i18n.defaultLocale = "en_US.UTF-8";

  # ========== Nix settings ==========
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  nixpkgs.config.allowUnfree = true;

  # ========== System packages ==========
  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    just
  ];

  # ========== SSH ==========
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # ========== Users ==========
  users.users.drakkir = {
    isNormalUser = true;
    description = "Drakkir";
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    shell = pkgs.fish;
    # Add your public key here:
    # openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAA..." ];
  };

  # Allow drakkir to use sudo without a password (optional, remove if not desired)
  security.sudo.extraRules = [
    {
      users = [ "drakkir" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  # fish is set as the user shell above — enable the NixOS module so it integrates properly
  programs.fish.enable = true;

  system.stateVersion = "25.05";
}
