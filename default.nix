{
  flakeDir ? "/etc/nixos",
  flake ? (builtins.getFlake "${flakeDir}"),
  nixos ? builtins.head (builtins.attrValues (flake.outputs.nixosConfigurations)),
  ...
}: {
  inherit nixos flake;
  inherit (nixos) pkgs config options;
  inherit (nixos.pkgs) lib;
}
