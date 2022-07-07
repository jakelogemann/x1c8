{
  stdenv,
  lib,
  fetchzip,
  autoPatchelfHook,
}:
with stdenv; let
  name = "fly";
  version = "7.6.0";
  description = "Fly is the Command-line interface for concourse."; 
  hostName = "concourse.internal.digitalocean.com";
  baseUrl = "https://${hostName}/api/v1/cli";
  systemMap = {
    "x86_64-darwin" = {
      url = "${baseUrl}?arch=amd64&platform=darwin";
      sha256 = "sha256-kIBmp63d+vSbc1KiRAIDQiVH8l/W0xIRaLAUKlWYTsA=";
    };
    "x86_64-linux" = {
      url = "${baseUrl}?arch=amd64&platform=linux";
      sha256 = "sha256-kIBmp63d+vSbc1KiRAIDQiVH8l/W0xIRaLAUKlWYTsA=";
    };
    "aarch64-darwin" = {
      url = "${baseUrl}?arch=arm64&platform=darwin";
      sha256 = lib.fakeSha256;
    };
    "aarch64-linux" = {
      url = "${baseUrl}?arch=arm64&platform=linux";
      sha256 = lib.fakeSha256;
    };
    "i386-linux" = {
      url = "${baseUrl}?arch=i386&platform=linux";
      sha256 = lib.fakeSha256;
    };
  };
in
  mkDerivation {
    inherit name version;
    phases = ["installPhase"];
    nativeBuildInputs = lib.optionals isLinux [autoPatchelfHook];
    src = with systemMap.${system};
      fetchzip {
        name = "${name}-source";
        inherit sha256 url;
        stripRoot = false;
      };
    installPhase = "install -Dm755 $src/${name} $out/bin/${name}";
    meta = {
      inherit description;
      platforms = builtins.attrNames systemMap;
    };
  }
