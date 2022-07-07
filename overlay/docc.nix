{
  stdenv,
  lib,
  fetchzip,
  autoPatchelfHook,
}:
with stdenv; let
  name = "docc";
  version = "b121d710f7";
  description = "DOCC command-line client.";
  baseUrl = "http://artifacts.internal.digitalocean.com/delivery/docc/${version}";
  systemMap = {
    "x86_64-darwin" = {
      url = "${baseUrl}/${name}-${version}-darwin-amd64.tar.gz";
      sha256 = lib.fakeSha256;
    };
    "x86_64-linux" = {
      url = "${baseUrl}/${name}-${version}-linux-amd64.tar.gz";
      sha256 = "sha256-cM+5YoGNCsURKTE8j1/1vDnc1iTL+apQ2qF0+9IE2A8=";
    };
    "aarch64-darwin" = {
      url = "${baseUrl}/${name}-${version}-darwin-arm64.tar.gz";
      sha256 = lib.fakeSha256;
    };
    "aarch64-linux" = {
      url = "${baseUrl}/${name}-${version}-linux-arm64.tar.gz";
      sha256 = lib.fakeSha256;
    };
    "i386-linux" = {
      url = "${baseUrl}/${name}-${version}-linux-i386.tar.gz";
      sha256 = lib.fakeSha256;
    };
  };
in
  mkDerivation {
    inherit name version;
    phases = ["installPhase"];
    nativeBuildInputs = lib.optionals isLinux [autoPatchelfHook];
    src = fetchzip (with systemMap.${system}; {
      name = "${name}-src";
      inherit sha256 url;
      stripRoot = false;
    });
    installPhase = ''
      install -Dm644 $src/${name}.bash $out/share/bash-completion/completions/${name}.bash
      install -Dm755 $src/${name} $out/bin/${name}
    '';
    meta = {
      inherit description;
      platforms = builtins.attrNames systemMap;
    };
  }
