# Custom packages
# These can be accessed as pkgs.myCustomPackage like any other package
# Applied as an overlay in flake.nix, which always passes `pkgs`.

{ pkgs }:

{
  xtrayhide = pkgs.buildGoModule rec {
    meta = with pkgs.lib; {
      description = "Capture and hide X11 tray icons on Wayland, expose them as SNI";
      homepage = "https://github.com/bnema/xtrayhide";
      license = licenses.mit;
      maintainers = [ ];
      platforms = platforms.linux;
    };

    pname = "xtrayhide";

    # Patch go.mod to work with Go 1.25.5
    postPatch = ''
      substituteInPlace go.mod --replace-fail "go 1.25.6" "go 1.25.5"
    '';

    proxyVendor = true;

    src = pkgs.fetchFromGitHub {
      hash = "sha256-RBgzZg9ThdPeJ1OFK5a/cBVbwwqnSiDSqNQ2evuDxSs=";
      owner = "bnema";
      repo = "xtrayhide";
      rev = "v${version}";
    };

    vendorHash = "sha256-zIwvd+6f8kmrrJE/T3Jy1BZieXKWG+PzG8EjTzwjeo0=";
    version = "1.0.0";
  };
}
