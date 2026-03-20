# Flake-parts module for containerisation and virtualisation support.
# Provides Podman, and libvirt/virt-manager configuration.
# Note: Docker and Podman are mutually exclusive -- only enable one at a time.
{ ... }: {
  flake.nixosModules.virtualization = { config, pkgs, ... }: {
    virtualisation = {
      # libvirtd disabled -- pulls in ~1.4GB of virtualization infrastructure
      # (QEMU, OVMF, Xen, openvswitch etc.) which is overkill for occasional use.
      # To enable full VM support:
      #   1. set libvirtd.enable = true
      #   2. set programs.virt-manager.enable = true for GUI
      #   3. the user group below handles libvirtd group membership automatically
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
        # Enables DNS resolution between containers on the same Podman network
        defaultNetwork.settings.dns_enabled = true;
      };
    };

    programs = {
      # GUI for managing libvirt VMs -- requires libvirtd.enable = true
      virt-manager.enable = false;
    };

    # User group membership for container and VM access
    users.users.${config.host.username}.extraGroups = [
      "podman"    # access to Podman socket
      # "libvirtd" # uncomment when libvirtd.enable = true
      # "kvm"      # uncomment for direct KVM device access
    ];

    environment.systemPackages = with pkgs; [
      # virt-viewer  # GUI for viewing/interacting with running VMs
      # qemu # for running VMs without the full stack

      # Docker Compose is kept for compatibility with existing compose files.
      # Works transparently with Podman via the Docker-compatible socket
      # enabled by virtualisation.podman.dockerSocket.enable = true.
      # Podman handles the actual container runtime -- docker-compose just
      # talks to the socket without knowing it's Podman underneath.
      docker-compose
    ];
  };
}