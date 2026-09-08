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
    #
    # Also fix upstream bug: internAtom passes onlyIfExists=true, so on a fresh
    # Xwayland where _NET_SYSTEM_TRAY_S0 has never been created, InternAtom
    # returns atom 0 (None) without an error. The following GetSelectionOwner(0)
    # then fails with BadAtom and the process exits 1, crash-looping forever.
    # xtrayhide *is* the tray manager, so it must create the atom, not require it.
    postPatch = ''
      substituteInPlace go.mod --replace-fail "go 1.25.6" "go 1.25.5"

      substituteInPlace internal/tray/atoms.go \
        --replace-fail "xproto.InternAtom(conn, true," "xproto.InternAtom(conn, false,"
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
