# Custom packages
# These can be accessed as pkgs.myCustomPackage like any other package

{
  pkgs ? import <nixpkgs> { },
}:

{
  xtrayhide = pkgs.buildGoModule rec {
    pname = "xtrayhide";
    version = "1.0.0";

    src = pkgs.fetchFromGitHub {
      owner = "bnema";
      repo = "xtrayhide";
      rev = "v${version}";
      hash = "sha256-RBgzZg9ThdPeJ1OFK5a/cBVbwwqnSiDSqNQ2evuDxSs=";
    };

    # Patch go.mod to work with Go 1.25.5
    postPatch = ''
      substituteInPlace go.mod --replace-fail "go 1.25.6" "go 1.25.5"
    '';

    vendorHash = "sha256-zIwvd+6f8kmrrJE/T3Jy1BZieXKWG+PzG8EjTzwjeo0=";
    proxyVendor = true;

    meta = with pkgs.lib; {
      description = "Capture and hide X11 tray icons on Wayland, expose them as SNI";
      homepage = "https://github.com/bnema/xtrayhide";
      license = licenses.mit;
      maintainers = [ ];
      platforms = platforms.linux;
    };
  };
}
