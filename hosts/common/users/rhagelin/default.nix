{ ... }:

{
  # Managed by system-manager via userborn (services.userborn is enabled by
  # default), so this really does create/update the user — check with
  # `journalctl -u userborn.service`.
  #
  # CAVEAT on the work host: the actual login there is the SSSD/AD account
  # rhagelin@creatorctek.local with home /home/rhagelin.creatorctek.local. The
  # entry below is a *local* user also called rhagelin, which userborn will
  # create in /etc/passwd with home /home/rhagelin. The two coexist, but if the
  # local one ever shadows the domain one, drop this import from hosts/work.
  users.users.rhagelin = {
    description = "Rhagelin (Corporate)";

    extraGroups = [
      "wheel"
      "networkmanager"
    ];

    isNormalUser = true;
    # shell is deliberately not set — see the note in ../drakkir/default.nix:
    # a Nix store path as login shell breaks /etc/shells validation (pkexec).
    #
    # SSH keys can be added in ./keys/ directory
    # openssh.authorizedKeys.keyFiles = [ ./keys/id_rsa.pub ];
  };
}
