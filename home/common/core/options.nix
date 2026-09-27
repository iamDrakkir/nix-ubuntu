{ lib, ... }:

# Values shared between the app modules that own them and the compositor
# modules that bind keys to them.
{
  options.myConfig = {
    browser = lib.mkOption {
      description = "Browser command and the profile names bound to Super+B, Super+Shift+B and Super+Ctrl+Shift+B.";

      type = lib.types.submodule {
        options = {
          admin = lib.mkOption { type = lib.types.str; };
          cmd = lib.mkOption { type = lib.types.str; };
          primary = lib.mkOption { type = lib.types.str; };
          secondary = lib.mkOption { type = lib.types.str; };
        };
      };
    };

    chatCommand = lib.mkOption {
      default = null;
      description = "Chat app launched by Super+D, set by the app module that installs it.";
      type = lib.types.nullOr lib.types.str;
    };
  };
}
