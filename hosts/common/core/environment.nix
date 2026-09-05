{ pkgs, ... }:

# NOTE: one merged `environment` block on purpose — pedantix merges repeated
# attrpaths but treats comments as positional, so `environment.etc` /
# `environment.pathsToLink` as separate commented bindings makes it refuse to
# format the file.
{
  environment = {
    # Configure sudo to include system-manager paths
    etc."sudoers.d/system-manager-path" = {
      mode = "0440";

      text = ''
        Defaults secure_path="/run/system-manager/sw/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin"
      '';
    };

    # Link share directories so desktop files and other resources are
    # available. See README.md#troubleshooting: without /share, programs
    # installed here are invisible to application launchers.
    pathsToLink = [
      "/bin"
      "/share"
    ];

    # Essential system packages present on all hosts
    systemPackages = with pkgs; [
      neovim
      pipewire
      wireplumber
      auto-cpufreq
    ];
  };
}
