# Flake-parts module for Intel iGPU support on a high-DPI display.
# Includes hardware acceleration, Quick Sync Video, Wayland optimisations,
# font scaling, and early KMS for smooth boot.
#
# Usage:
#   Add self.nixosModules.gpuIntel to your host's modules list,
#   then enable it in your host config:
#
#   drivers.intel.enable = true;
#
#   Verify hardware acceleration is working after rebuild:
#     vainfo          # should show iHD driver with encode/decode profiles
#     vulkaninfo      # should show Intel GPU
#     intel_gpu_top   # should show GPU activity when playing video/games
# based on https://wiki.nixos.org/wiki/Intel_Graphics
{
  flake.nixosModules.intelGPU = {
    pkgs,
    ...
  }: {
    # Load modesetting driver and keep Xorg available for XWayland compatibility
    # services.xserver.videoDrivers = [ "modesetting" ];

    # Required for VA-API / QSV firmware
    hardware.enableRedistributableFirmware = true;

    hardware.graphics = {
      enable = true;
      enable32Bit = true;

      extraPackages = with pkgs; [
        intel-media-driver # VA-API (iHD)
        vpl-gpu-rt # Quick Sync Video
        intel-compute-runtime # OpenCL
      ];
    };

    # Load i915 early in boot for smoother display initialisation
    boot.initrd.kernelModules = ["i915"];

    boot.kernelParams = [
      # Panel self refresh -- reduces power consumption on laptop displays
      "i915.enable_psr=1"

      # Enables GuC/HuC firmware -- improves QSV/VAAPI reliability on 12th gen
      "i915.enable_guc=3"
    ];

    environment.sessionVariables = {
      # VA-API -- use iHD driver for 12th gen Intel and newer
      LIBVA_DRIVER_NAME = "iHD";

      # Hint Electron/Chromium apps to use Wayland native rendering
      NIXOS_OZONE_WL = "1";
    };

    environment.systemPackages = with pkgs; [
      libva-utils # vainfo -- verify VA-API is working
      vulkan-tools # vulkaninfo -- verify Vulkan is working
      intel-gpu-tools # intel_gpu_top -- monitor GPU usage
    ];
  };
}
