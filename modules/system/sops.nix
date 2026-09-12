# Secret management via sops-nix. Secrets live encrypted in the repo under
# secrets/ (age-encrypted, see .sops.yaml) and are decrypted to /run/secrets
# at activation using the host's SSH key -- so nothing sensitive is in the Nix
# store or a plaintext file on disk.
#
# Individual secrets are declared next to the service that uses them
# (sops.secrets.<name>), referencing their runtime path via
# config.sops.secrets.<name>.path.
{inputs, ...}: {
  flake.nixosModules.sops = _: {
    imports = [inputs.sops-nix.nixosModules.sops];

    # Decrypt with the machine's SSH host key -- no separate age key to deploy.
    sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];

    # Currently only minifridge carries secrets; point the default file here so
    # per-secret declarations don't have to repeat sopsFile.
    sops.defaultSopsFile = ../../secrets/minifridge.yaml;
  };
}
