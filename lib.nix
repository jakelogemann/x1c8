self: let
  inherit (self.inputs) flake-utils nixpkgs;
in rec {
  inherit (flake-utils.lib) filterPackages mkApp check-utils;
  supportedSystems = ["x86_64-linux" "x86_64-darwin" "aarch64-darwin" "aarch64-linux"];
  eachSystem = flake-utils.lib.eachSystem supportedSystems;
  eachSystemMap = flake-utils.lib.eachSystemMap supportedSystems;
  overlaysList = builtins.attrValues self.overlays;
  modulesList = builtins.attrValues self.nixosModules;
  eachSystemWithPkgs = f:
    eachSystemMap (system:
      f (import nixpkgs {
        inherit system;
        overlays = overlaysList;
      }));

  withPkgs = eachSystemWithPkgs;
}
