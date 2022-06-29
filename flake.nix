{
  description = "laptop";

  inputs.nixpkgs.url = "nixpkgs/nixos-22.05";

  inputs.fnctl = {
    url = "github:fnctl/fnctl.nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.home-manager = {
    inputs.nixpkgs.follows = "fnctl/nixpkgs";
    url = "github:nix-community/home-manager";
  };

  inputs.do-nixpkgs = {
    inputs.nixpkgs.follows = "fnctl/nixpkgs";
    ref = "master";
    type = "git";
    url = "git+ssh://git@github.internal.digitalocean.com/digitalocean/do-nixpkgs";
    inputs.flake-utils.follows = "fnctl/utils";
    inputs.home-manager.follows = "home-manager";
  };

  outputs = {
    self,
    fnctl,
    ...
  } @ inputs': rec {
    inherit (fnctl) lib formatter devShells;
    overlays.default = import ./overlay.nix inputs';
    nixosConfigurations.laptop = import ./default.nix inputs';
  };
}
