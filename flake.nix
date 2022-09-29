{
  description = "laptop";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";

    fnctl = {
      url = "github:jakelogemann/fnctl";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    cthulhu = {
      type = "github";
      host = "github.internal.digitalocean.com";
      owner = "digitalocean";
      repo = "cthulhu";
      # url = "git+https://github.internal.digitalocean.com/digitalocean/cthulhu?ref=master&rev";
      flake = false;
    };

    do-nixpkgs = {
      url = "git+https://github.internal.digitalocean.com/digitalocean/do-nixpkgs?ref=master";
      inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";
      inputs.cthulhu.follows = "cthulhu";
    };
  };

  outputs = {
    self,
    fnctl,
    ...
  } @ inputs': rec {
    inherit (fnctl) lib formatter devShells;
    overlays.default = import ./overlay/default.nix inputs';
    nixosConfigurations.laptop = import ./system.nix inputs';
  };
}
