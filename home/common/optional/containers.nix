{ pkgs, ... }:

{
  # Rootless Podman + DevPod for VSCode-style devcontainer / remote-container
  # development (driven by remote-nvim.nvim). Daemonless: everything runs as
  # your user, with no system service.
  #
  # HOST PREREQUISITE (one-time, per machine): the setuid helpers
  # newuidmap/newgidmap are required for rootless UID mapping and CANNOT be
  # provided by Nix on non-NixOS (they must be setuid root). Install them via:
  #
  #     sudo apt install uidmap
  #
  # /etc/subuid and /etc/subgid are already populated for the user, and
  # unprivileged user namespaces are enabled (hosts/common/core/sysctl-userns.nix).
  #
  # ONE-TIME DevPod setup (points DevPod's docker provider at Podman, so no
  # `docker` alias is needed):
  #
  #     devpod provider add docker --name podman -o DOCKER_PATH=podman
  #     devpod provider use podman

  home.packages = with pkgs; [
    podman # wrapped: bundles conmon, crun, netavark, aardvark-dns, slirp4netns, pasta
    fuse-overlayfs # rootless overlay storage driver
    devpod # devcontainer CLI used by remote-nvim.nvim
  ];

  # Rootless container config. On non-NixOS there is no /etc/containers, so we
  # provide the user-level files Podman needs to pull and run images.
  xdg.configFile = {
    # Accept any image (Docker-like default); without a policy, image pulls fail.
    "containers/policy.json".text = builtins.toJSON {
      default = [ { type = "insecureAcceptAnything"; } ];
    };

    # Resolve unqualified names (e.g. `podman pull ubuntu`) against Docker Hub.
    "containers/registries.conf".text = ''
      unqualified-search-registries = ["docker.io"]
    '';

    # Use fuse-overlayfs for rootless overlay storage.
    "containers/storage.conf".text = ''
      [storage]
      driver = "overlay"

      [storage.options.overlay]
      mount_program = "${pkgs.fuse-overlayfs}/bin/fuse-overlayfs"
    '';
  };
}
