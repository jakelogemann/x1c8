args @ {
  bat,
  gnugrep,
  gnumake,
  gnupg,
  gnused,
  coreutils,
  direnv,
  fd,
  file,
  lsd,
  symlinkJoin,
  mtr,
  parallel,
  pass,
  pinentry,
  ripgrep,
  topgrade,
  skim,
  tree,
  unrar,
  unzip,
  w3m,
  whois,
  zip,
  zoxide,
  lib,
}:
symlinkJoin {
  name = "commonUtils";
  paths = builtins.attrValues (lib.filterAttrs (name: _: name != "lib" && name != "symlinkJoin") args);
}
