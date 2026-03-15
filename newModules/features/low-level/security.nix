# Security and secret management.
# TODO: break this up further once I add more stuff/think of how to organize it
{ ... }: {
  flake.nixosModules.security = { ... }: {
    # Keyring for storing secrets -- used by many apps even outside GNOME
    services.gnome.gnome-keyring.enable = true;

    # SSH daemon
    services.openssh.enable = true;
  };
}