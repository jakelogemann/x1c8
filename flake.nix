{
  description = "laptop";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-22.05";

    fnctl = {
      url = "github:fnctl/fnctl.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    cthulhu = {
      follows = "do-nixpkgs/cthulhu";
      flake = false;
    };

    home-manager = {
      inputs.nixpkgs.follows = "fnctl/nixpkgs";
      url = "github:nix-community/home-manager";
    };

    do-nixpkgs = {
      inputs.nixpkgs.follows = "fnctl/nixpkgs";
      ref = "jlogemann/cleanup";
      type = "git";
      url = "git+ssh://git@github.internal.digitalocean.com/digitalocean/do-nixpkgs";
      inputs.flake-utils.follows = "fnctl/utils";
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
