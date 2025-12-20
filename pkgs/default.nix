# Custom packages
# These can be accessed as pkgs.myCustomPackage like any other package

{
  pkgs ? import <nixpkgs> { },
}:

{
  # Example custom package:
  # myScript = pkgs.writeShellScriptBin "my-script" ''
  #   echo "Hello from custom package!"
  # '';
}
