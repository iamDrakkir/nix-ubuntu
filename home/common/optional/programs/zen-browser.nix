{
  inputs,
  pkgs,
  hostname,
  ...
}:

let
  # On the work machine the "work" profile is the default; on all other
  # machines "personal" is the default.
  isWork = hostname == "work";

  commonSettings = {
    "zen.tabs.vertical.right-side" = true;
    # Required for Zen mods / userChrome.css to take effect.
    "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
  };

  # Zen mod: "Back Fwd Always Hidden" by jean06560
  # https://zen-browser.app/mods/4a222d82-2803-4ed2-a390-90abfce4f195/
  commonUserChrome = ''
    :root:not([customizing]) #zen-sidebar-top-buttons-separator {
      display: none !important;
    }
    :root:not([customizing]) #back-button {
      display: none !important;
    }
    :root:not([customizing]) #forward-button {
      display: none !important;
    }
  '';

  commonSearch = {
    engines = {
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
      "Nix Packages" = {
        definedAliases = [ "n" ];
        icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
        urls = [
          {
            template = "https://search.nixos.org/packages?channel=unstable&include_home_manager_options=1&include_modular_service_options=1&include_nixos_options=1&query={searchTerms}";
          }
        ];
      };
    };
    force = true;
  };

  commonExtensions = with inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system}; [
    clearurls
    dark-mode-webextension
    privacy-badger
    proton-pass
    sponsorblock
    ublock-origin
    vimium
  ];
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
        userChrome = commonUserChrome;
      };

      work = {
        extensions.packages = commonExtensions;
        id = 1;
        isDefault = isWork;
        search = commonSearch;
        settings = commonSettings;
        userChrome = commonUserChrome;
      };

      work_admin = {
        id = 2;
        isDefault = false;
        settings = commonSettings;
        search = commonSearch;
        extensions.packages = commonExtensions;
        userChrome = commonUserChrome;
      };
    };
    setAsDefaultBrowser = true;
  };
}
