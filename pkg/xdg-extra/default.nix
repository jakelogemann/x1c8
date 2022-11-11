{ stdenv }:

stdenv.mkDerivation rec {
  name = "xdg-extra";
  src = ./xdg-items.toml;
  builder = let
    cfg = builtins.fromTOML (builtins.readFile src);
    joinLines = builtins.concatStringsSep "\n";
    joinLists = builtins.concatMap joinLines;
    asKeyVal = builtins.mapAttrs (name: value: "${name}=${value}");

    makeDesktopItem = {
      Name,
      ...

    }@args: builtins.toFile "${Name}.desktop" (builtins.concatLists [
      ["[Desktop Entry]"]
      (builtins.attrValues (asKeyVal args))
    ]);

    desktopItems = builtins.concatLists [
      cfg.desktopItem

      (builtins.map (entry: {
          Name = "internal-${entry}";
          DesktopName = "Open ${entry}.internal.";
          Exec = "xdg-open https://${entry}.internal.digitalocean.com";
        })
        cfg.internalHostnames)
    ];

    contents = builtins.concatLists [
      [ "source $stdenv/setup" "mkdir -vp $out/share/applications" ]
      (builtins.map (i: "cp ${makeDesktopItem i} $out/share/applications/") desktopItems)
    ];
  in
    builtins.toFile "builder.sh" (joinLines contents);
}
