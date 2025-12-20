{ ... }:

{
  imports = [
    ../common/core
    ../common/optional/auto-cpufreq.nix
    ../common/optional/apparmor.nix
    ../common/users/rhagelin
  ];

  # Host-specific overrides for work
  # Add any work-specific system packages or configurations here
}
