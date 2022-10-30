{ sway, stdenv, }@args: 
let 
  dependencies = builtins.attrValues (builtins.removeAttrs ["stdenv"] args);
in stdenv.mkDerivation {
  name = "customized-sway";
  paths = dependencies;
}


