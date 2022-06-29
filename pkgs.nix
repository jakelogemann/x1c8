inputs @ {
  config,
  lib,
  pkgs,
  ...
}:
with pkgs;
with lib;
with builtins; {
  environment.systemPackages = [
    ossec
    aide
    dmidecode
    hddtemp
    ipmitool
    glxinfo
    sysstat
    docker-credential-helpers
    (writeShellScriptBin "jf" "exec docker run --rm -it --mount type=bind,source=\"$HOME/.jfrog\",target=/root/.jfrog 'releases-docker.jfrog.io/jfrog/jfrog-cli-v2-jf' jf \"$@\"")
    (writeShellScriptBin "list-git-vars" "${getExe bat} -l=ini --file-name 'git var -l (sorted)' <(${getExe git} var -l | sort)")
  ];
}
