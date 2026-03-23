{ inputs, pkgs, ... }:

let
  commonSettings = {
    "zen.tabs.vertical.right-side" = true;
  };

  commonSearch = {
    force = true;
    engines = {
      "Nix Packages" = {
        urls = [{ template = "https://search.nixos.org/packages?channel=25.11&query={searchTerms}"; }];
        icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
        definedAliases = [ "n" ];
      };
    };
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
    setAsDefaultBrowser = true;

    policies = {
      AutofillAddressEnabled = true;
      AutofillCreditCardEnabled = false;
      DisableAppUpdate = true;
      DisableFeedbackCommands = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableTelemetry = true;
      DontCheckDefaultBrowser = true;
      NoDefaultBookmarks = true;
      OfferToSaveLogins = false;
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
      };
    };

    profiles = {
      personal = {
        id = 0;
        isDefault = true;
        settings = commonSettings;
        search = commonSearch;
        extensions.packages = commonExtensions ++ (with inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system}; [
          augmented-steam
          facebook-container
        ]);
      };

      work = {
        id = 1;
        settings = commonSettings;
        search = commonSearch;
        extensions.packages = commonExtensions;
      };
    };
  };
}
