{
  stdenv,
  lib,
  fetchzip,
  autoPatchelfHook,
}:
with stdenv; let
  name = "dao";
  version = "0.4.2";
  description = ''
    dao is a command-line tool used to provide an interface between the users of
    Cinc at DigitalOcean and our various distributed Cinc Servers. It also
    provides several utility functions that don't interact directly with Cinc
    Servers. It is our intention to replace usage of the "knife" tool
    internally with the usage of dao. (pronounced "dow" as in "Dow Jones").
  '';
  artifactoryHost = "artifactory.internal.digitalocean.com";
  artifactoryRepo = "artifacts-dev-local";
  baseUrl = "https://${artifactoryHost}/artifactory/${artifactoryRepo}/${name}";
  systemMap = {
    "aarch64-darwin" = {
      url = "${baseUrl}/v${version}/${name}_v${version}_darwin_arm64.tar.gz";
      sha256 = "sha256-vqFDQcpmNNC5UNOCon4fzP8srijzE/I7uKUtyx14wgY=";
    };
    "aarch64-linux" = {
      url = "${baseUrl}/v${version}/${name}_v${version}_linux_arm64.tar.gz";
      sha256 = "sha256-EgLDooTM2TsYApa3HnV6SDhtyHTKDRzH74VOGI5W/v8=";
    };
    "i386-linux" = {
      url = "${baseUrl}/v${version}/${name}_v${version}_linux_i386.tar.gz";
      sha256 = "sha256-D9RGayOw6ivBVl0z3N3AyFWtqU2u/fWqEN5yyZWPRfA=";
    };
    "x86_64-darwin" = {
      url = "${baseUrl}/v${version}/${name}_v${version}_darwin_x86_64.tar.gz";
      sha256 = "sha256-PAbM2myHsULKH3YrKefu+ZoHyRK1ajInToyozhvIE54=";
    };
    "x86_64-linux" = {
      url = "${baseUrl}/v${version}/${name}_v${version}_linux_x86_64.tar.gz";
      sha256 = "sha256-GGrvuwGHvloFnLG4p+uB4WUEXY7K7+ALDhOoUgf4+gk=";
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
