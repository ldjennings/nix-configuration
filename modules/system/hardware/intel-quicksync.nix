# Headless Intel Quick Sync / VA-API acceleration for media transcoding
# (Jellyfin, ffmpeg, etc.) on Gen8+ iGPUs. Unlike the desktop `intelGPU`
# module this makes no display/Wayland assumptions -- it just provides the
# render stack and firmware needed for hardware encode/decode.
#
# Usage:
#   Add self.nixosModules.intelQuickSync to a host's modules list, and add any
#   service account that needs the GPU to the "render" group, e.g.
#     users.users.jellyfin.extraGroups = [ "render" ];
#
# Verify after rebuild:
#   vainfo   # should list the iHD driver with H264/HEVC/VP9 encode+decode
{
  flake.nixosModules.intelQuickSync = {pkgs, ...}: {
    # VA-API / QSV firmware blobs are redistributable but non-free.
    hardware.enableRedistributableFirmware = true;

    hardware.graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver # VA-API driver (iHD) for Gen8+ -- UHD 630 included
        vpl-gpu-rt # oneVPL runtime -- Quick Sync encode/decode
        intel-compute-runtime # OpenCL -- tone-mapping and some ffmpeg filters
      ];
    };

    # Load i915 in initrd so the /dev/dri render node is ready early.
    boot.initrd.kernelModules = ["i915"];

    # Load HuC firmware for full fixed-function encode on Coffee Lake (Gen9.5).
    # =2 loads HuC without enabling GuC submission, which is flaky on Gen9.
    boot.kernelParams = ["i915.enable_guc=2"];

    # Gen9.5 uses the iHD VA-API driver.
    environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";

    # vainfo, for checking acceleration from the shell.
    environment.systemPackages = [pkgs.libva-utils];
  };
}
