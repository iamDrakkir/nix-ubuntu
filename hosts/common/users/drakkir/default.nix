{ ... }:

{
  # Managed by system-manager via userborn (services.userborn is enabled by
  # default), so this really does create/update the user — check with
  # `journalctl -u userborn.service`.
  #
  # users.mutableUsers stays true, so passwords and anything set with usermod by
  # hand are left alone; only what is declared here is enforced.
  users.users.drakkir = {
    description = "Drakkir";

    extraGroups = [
      "wheel"
      "networkmanager"
    ];

    isNormalUser = true;
    # shell is deliberately not set. Pointing it at a Nix store path breaks
    # anything that validates the login shell against /etc/shells — pkexec
    # refuses to run at all ("The value for the SHELL variable was not found in
    # the /etc/shells file"). The shell is set to the system-manager bash
    # (/run/system-manager/sw/bin/bash) at the distro level instead.
    #
    # SSH keys can be added in ./keys/ directory
    # openssh.authorizedKeys.keyFiles = [ ./keys/id_rsa.pub ];
  };
}
