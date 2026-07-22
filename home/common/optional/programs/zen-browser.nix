{ inputs, pkgs, ... }:

let
  commonSettings = {
    "zen.tabs.vertical.right-side" = true;
  };

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
        isDefault = false;
        search = commonSearch;
        settings = commonSettings;
      };

      work = {
        extensions.packages = commonExtensions;
        id = 1;
        isDefault = true;
        search = commonSearch;
        settings = commonSettings;
      };
    };
    setAsDefaultBrowser = true;
  };
}
