{ inputs, system, ... }:

{
  home.packages = [
    inputs.zen-browser.packages.${system}.default
  ];

  # programs.zen-browser.policies = {
  # AutofillAddressEnabled = true;
  # AutofillCreditCardEnabled = false;
  # DisableAppUpdate = true;
  # DisableFeedbackCommands = true;
  # DisableFirefoxStudies = true;
  # DisablePocket = true;
  # DisableTelemetry = true;
  # DontCheckDefaultBrowser = true;
  # NoDefaultBookmarks = true;
  # OfferToSaveLogins = false;
  # EnableTrackingProtection = {
  #   Value = true;
  #   Locked = true;
  #   Cryptomining = true;
  #   Fingerprinting = true;
  # };

}
