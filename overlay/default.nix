{ self, ... } @ inputs: final: prev: with prev; rec {
  do-nixpkgs = self.inputs.do-nixpkgs.packages.${system};
  fnctl = self.inputs.fnctl.packages.${system};
  commonUtils = callPackage ./commonUtils.nix {};
  hwUtils = callPackage ./hwUtils.nix {};
  vpn = callPackage ./vpn.nix {};
  dao = callPackage ./dao.nix {};
}
