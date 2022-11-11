{
  symlinkJoin,
  lib,
  makeDesktopItem,
}:
with (builtins.fromTOML (builtins.readFile ./xdg-items.toml));
  symlinkJoin {
    name = "xdg-extra";
    paths = lib.concatLists [
      (builtins.map (entry:
        makeDesktopItem {
          name = "internal-${entry}";
          desktopName = "Open ${entry}.internal.";
          exec = "xdg-open https://${entry}.internal.digitalocean.com";
        })
      internalHostnames)

      (builtins.map (entry: makeDesktopItem entry) desktopItem)
    ];
  }
