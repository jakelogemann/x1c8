{
  vault,
  lib,
  writeShellApplication,
}:
writeShellApplication {
  name = "vault";
  runtimeInputs = [vault];
  text = ''
    # shellcheck disable=SC2060,SC2145

    exec env \
      VAULT_ADDR="https://vault-api.internal.digitalocean.com:8200" \
      VAULT_CACERT="${./sammy-ca.crt}" \
      vault \\"$@\\"
  '';
}
