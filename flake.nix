{
  description = "laptop";

  inputs = {
    utils.url = "github:numtide/flake-utils";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    hardware.url = "github:nixos/nixos-hardware";
    nixpkgs.url = "nixpkgs/nixos-22.05";

    do-nixpkgs = {
      inputs.nixpkgs.follows = "nixpkgs";
      ref = "master";
      type = "git";
      url = "git+ssh://git@github.internal.digitalocean.com/digitalocean/do-nixpkgs";
      inputs.flake-utils.follows = "utils";
      inputs.home-manager.follows = "home-manager";
    };

    fnctl = {
      url = "github:fnctl/fnctl.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "utils";
    };
  };

  outputs = specialArgs @ {
    self,
    nixpkgs,
    hardware,
    fnctl,
    home-manager,
    do-nixpkgs,
    ...
  }:
    with nixpkgs.lib; let
      specialArgs.system = "x86_64-linux";
      # This value determines the NixOS release from which the default
      # settings for stateful data, like file locations and database versions
      # on your system were taken. It‘s perfectly fine and recommended to leave
      # this value at the release version of the first install of this system.
      # Before changing this value read the documentation for this option
      # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html)
      specialArgs.stateVersion = "22.05";
      specialArgs.hostName = "laptop";
      specialArgs.userName = "jlogemann";
      specialArgs.flakeDir = "/etc/nixos";
      specialArgs.overlays = [
        (final: prev: {
          fnctl = fnctl.packages.${prev.system};
          do-nixpkgs = do-nixpkgs.packages.${prev.system};
        })
      ];
    in {
      devShell = fnctl.lib.eachSystemMap (s: fnctl.outputs.devShells.${s}.default);
      formatter = fnctl.lib.eachSystemMap (s: fnctl.formatter.${s});
      nixosModules.digitalocean = import ./modules/digitalocean/default.nix;
      nixosConfigurations.laptop = nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        system = specialArgs.system;
        modules = [
          ({lib, ...}: {system.stateVersion = lib.mkForce specialArgs.stateVersion;})
          do-nixpkgs.nixosModules.kolide-launcher
          do-nixpkgs.nixosModules.sentinelone
          hardware.nixosModules.lenovo-thinkpad-x1-9th-gen
          home-manager.nixosModules.home-manager
          ./networking.nix
          ./dnscrypt.nix
          ./system.nix
          ./home-manager.nix
          ./boot.nix
          ./users.nix
          ./pkgs.nix
        ];
      };
    };
}
