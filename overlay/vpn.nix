{
  openconnect,
  lib,
  writeShellApplication,
}:
writeShellApplication {
  name = "vpn";
  runtimeInputs = [openconnect];
  text = ''
    set -x; exec ${lib.getExe openconnect} \
      --passwd-on-stdin --background --protocol=gp -F _challenge:passwd=1 \
      --csd-wrapper=${openconnect}/libexec/openconnect/hipreport.sh \
      -F _login:user="$1" \
      "https://vpn-$2.digitalocean.com/ssl-vpn"
  '';
}
