{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:

{
  # ========== Boot ==========
  boot = {
    # Use latest kernel for best RPi 4/5 support
    kernelPackages = pkgs.linuxPackages_latest;

    loader = {
      generic-extlinux-compatible.enable = true;
      grub.enable = false;
    };
  };

  # ========== System packages ==========
  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    just
  ];

  i18n.defaultLocale = "en_US.UTF-8";

  imports = [
    # Raspberry Pi 4/5 hardware support
    "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
  ];

  # ========== Networking ==========
  networking = {
    hostName = "pi";
    networkmanager.enable = true;
  };

  # ========== Nix settings ==========
  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };

    settings = {
      auto-optimise-store = true;

      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
  };

  nixpkgs.config.allowUnfree = true;
  # fish is set as the user shell above — enable the NixOS module so it integrates properly
  programs.fish.enable = true;

  # Allow drakkir to use sudo without a password (optional, remove if not desired)
  security.sudo.extraRules = [
    {
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];

      users = [ "drakkir" ];
    }
  ];

  # ========== SSH ==========
  services.openssh = {
    enable = true;

    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  system.stateVersion = "25.05";
  # ========== Locale / Time ==========
  time.timeZone = "Europe/Stockholm";

  # ========== Users ==========
  users.users.drakkir = {
    description = "Drakkir";

    extraGroups = [
      "wheel"
      "networkmanager"
    ];

    isNormalUser = true;
    shell = pkgs.fish;
    # Add your public key here:
    # openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAA..." ];
  };
}
