{
  stdenv,
  lib,
  fetchzip,
  autoPatchelfHook,
}:
with stdenv; let
  name = "do-xdg";
  version = "latest";
in
  mkDerivation {
    inherit name version;
    phases = ["installPhase"];
    src = ./src;
    installPhase = ''
      mkdir -vp $out/share/applications $out/share/icons
      cp -fv $src/applications/*.desktop $out/share/applications/
      # TODO:  cp -rfv $src/icons $out/share/icons/${name}
    '';
    meta = {
      description = "Collection of /usr/share/{applications,icons}/ for a more friendly desktop experience.";
      platforms = [
        "aarch64-darwin"
        "aarch64-linux"
        "i386-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
    };
  }
