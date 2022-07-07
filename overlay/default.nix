{ self, ... } @ inputs: final: prev: with prev; rec {
  fnctl = self.inputs.fnctl.packages.${system};
  commonUtils = callPackage ./commonUtils.nix {};
  hwUtils = callPackage ./hwUtils.nix {};
  do-nixpkgs = (self.inputs.do-nixpkgs.packages.${system} // {
    vpn = callPackage ./vpn.nix {};
    do-xdg = callPackage ./do-xdg {};
    dao = callPackage ./dao.nix {};
    vault = callPackage ./vault.nix {};
    sammy-ca = writeText "sammy-ca.crt" (builtins.readFile ./sammy-ca.crt);
    # fly = callPackage ./fly.nix {};
    # docc = callPackage ./docc.nix {};

    ghe = (writeShellApplication {
      name = "ghe";
      runtimeInputs = [gh];
      text = lib.concatStringsSep " " ["exec" "env" "GH_HOST='github.internal.digitalocean.com'" "gh" "\"$@\""];
    });
  });
}
