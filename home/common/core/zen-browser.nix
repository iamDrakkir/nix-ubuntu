{
  lib,
  config,
  pkgs,
  hostname,
  inputs,
  ...
}:

let
  commonExtensions = with inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system}; [
    clearurls
    dark-mode-webextension
    privacy-badger
    proton-pass
    sponsorblock
    ublock-origin
    vimium
  ];
  commonSearch = {
    engines = {
      "Nix Packages" = {
        definedAliases = [ "n" ];
        icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";

        urls = [
          {
            template = "https://search.nixos.org/packages?channel=unstable&include_home_manager_options=1&include_modular_service_options=1&include_nixos_options=1&query={searchTerms}";
          }
        ];
      };

      "google" = {
        metaData.alias = "g";
      };

      "youtube" = {
        definedAliases = [ "y" ];
        icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/youtube.svg";

        urls = [
          {
            template = "https://www.youtube.com/results?search_query={searchTerms}";
          }
        ];
      };
    };

    force = true;
  };
  commonSettings = {
    # Required for Zen mods / userChrome.css to take effect.
    "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
    "zen.tabs.vertical.right-side" = true;
  };
  # On the work machine the "work" profile is the default; on all other
  # machines "personal" is the default.
  isWork = hostname == "work";
in
{
  programs.zen-browser = {
    enable = true;
    # The nixpkgs Firefox wrapper hardcodes MOZ_LEGACY_PROFILES=1, which forces
    # Zen to read profiles from the legacy path ~/.zen. Home Manager, however,
    # writes profile config (search engines, prefs, etc.) to the XDG path
    # ~/.config/zen. Setting this to "0" makes Zen use ~/.config/zen so the
    # Home Manager managed profiles are actually loaded.
    env.MOZ_LEGACY_PROFILES = "0";

    policies = {
      AutofillAddressEnabled = true;
      AutofillCreditCardEnabled = false;
      DisableAppUpdate = true;
      DisableFeedbackCommands = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableTelemetry = true;
      DontCheckDefaultBrowser = true;

      EnableTrackingProtection = {
        Cryptomining = true;
        Fingerprinting = true;
        Locked = true;
        Value = true;
      };

      NoDefaultBookmarks = true;
      OfferToSaveLogins = false;
    };

    profiles = {
      personal = {
        extensions.packages =
          commonExtensions
          ++ (with inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system}; [
            augmented-steam
            facebook-container
          ]);

        id = 0;
        isDefault = !isWork;
        search = commonSearch;
        settings = commonSettings;
      };

      work = {
        extensions.packages = commonExtensions;
        id = 1;
        isDefault = isWork;
        search = commonSearch;
        settings = commonSettings;
      };

      work_admin = {
        extensions.packages = commonExtensions;
        id = 2;
        isDefault = false;
        search = commonSearch;
        settings = commonSettings;
      };
    };

    setAsDefaultBrowser = true;
  };

  # userChrome.css is written by Noctalia's zen-browser theming template at
  # runtime, so Home Manager must not own it (a read-only store symlink both
  # breaks the template and aborts activation with a clobber error). Point each
  # profile at the repo copy instead, so live edits apply and stay tracked.
  xdg.configFile =
    lib.genAttrs
      (map (p: "zen/${p}/chrome/userChrome.css") [
        "personal"
        "work"
        "work_admin"
      ])
      (_: {
        source = lib.custom.symlink.link config "zen/userChrome.css";
      });
}
