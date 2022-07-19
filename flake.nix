{
  description = "laptop";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-22.05";

    fnctl = {
      url = "github:fnctl/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    cthulhu = {
      url = "git+ssh://git@github.internal.digitalocean.com/digitalocean/cthulhu?ref=master&rev=3281f754a4c2b40b4a219ba732fb66496236da9b";
      flake = false;
    };

    home-manager = {
      inputs.nixpkgs.follows = "fnctl/nixpkgs";
      url = "github:nix-community/home-manager";
    };

    do-nixpkgs = {
      inputs.nixpkgs.follows = "fnctl/nixpkgs";
      ref = "master";
      type = "git";
      url = "git+ssh://git@github.internal.digitalocean.com/digitalocean/do-nixpkgs";
      inputs.flake-utils.follows = "fnctl/utils";
      inputs.cthulhu.follows = "cthulhu";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs = {
    self,
    fnctl,
    ...
  } @ inputs': rec {
    inherit (fnctl) lib formatter devShells;
    overlays.default = import ./overlay/default.nix inputs';
    nixosConfigurations.laptop = import ./default.nix inputs';
  };
}
