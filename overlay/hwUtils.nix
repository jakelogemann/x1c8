args @ {
  usbutils,
  dmidecode,
  glxinfo,
  hddtemp,
  ipmitool,
  lsb-release,
  lsof,
  sysstat,
  symlinkJoin,
  lib,
}:
symlinkJoin {
  name = "hwUtils";
  paths = builtins.attrValues (lib.filterAttrs (name: _: name != "lib" && name != "symlinkJoin") args);
}
