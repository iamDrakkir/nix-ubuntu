{ inputs, ... }:

{
  imports = [
    inputs.nix-system-graphics.systemModules.default
  ];

  # Graphics support for all hosts
  system-graphics = {
    enable = true;
    enable32Bit = true;
  };
}
