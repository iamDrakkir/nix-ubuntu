{ lib, ... }:

{
  options.profile = {
    name = lib.mkOption {
      type = lib.types.str;
      description = "Profile name (personal or work)";
    };

    git = {
      userName = lib.mkOption {
        type = lib.types.str;
        description = "Git user name";
      };

      userEmail = lib.mkOption {
        type = lib.types.str;
        description = "Git user email";
      };

      githubUsername = lib.mkOption {
        type = lib.types.str;
        description = "GitHub username for URL shortcuts";
      };
    };

    machine = {
      hostname = lib.mkOption {
        type = lib.types.str;
        description = "Machine hostname";
      };

      isLaptop = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether this is a laptop (affects power management)";
      };
    };
  };
}
