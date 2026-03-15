# Flake-parts module for containerisation and virtualisation support.
# Provides Podman, and libvirt/virt-manager configuration.
# Note: Docker and Podman are mutually exclusive -- only enable one at a time.
{
  flake.nixosModules.virtualization = { pkgs, ... }: {
    virtualisation = {
      # Full Linux VM support via QEMU/KVM
      libvirtd.enable = false;

      # Docker container runtime -- mutually exclusive with Podman, prefer Podman
      docker.enable = false;

      podman = {
        enable = true;

        # Adds a `docker` alias pointing to podman for compatibility
        dockerCompat = true;

        # Exposes a Docker-compatible socket at /run/podman/podman.sock
        # allowing tools that target the Docker daemon to work transparently
        dockerSocket.enable = true;

        # Enables DNS resolution between containers on the same Podman network.
        defaultNetwork.settings = {
          dns_enabled = true;
        };
      };
    };

    programs = {
      # GUI for managing libvirt VMs -- requires libvirtd.enable = true
      virt-manager.enable = false;
    };

    # environment.systemPackages = with pkgs; [
    #   virt-viewer  # GUI for viewing/interacting with running VMs
    # ];
  };
}
