# Flake-parts module for printing and scanning support.
# Enables CUPS with Lexmark PostScript drivers, Avahi for network printer
# discovery, ipp-usb for USB IPP printers, and SANE for scanner support.
#
# Usage:
#   Add self.nixosModules.printing to your host's modules list:
#
#   modules = [
#     self.nixosModules.printing
#   ];
{
  flake.nixosModules.printing = { pkgs, ... }: {
    services = {
      printing = {
        enable = true;
        drivers = [
          # Lexmark PostScript driver for Lexmark printers
          pkgs.postscript-lexmark
        ];
      };

      # Avahi enables mDNS/DNS-SD for network printer auto-discovery
      avahi = {
        enable = true;
        nssmdns4 = true;  # mDNS hostname resolution for IPv4
        nssmdns6 = true;  # mDNS hostname resolution for IPv6
        openFirewall = true;
      };

      # IPP-over-USB -- allows USB-connected printers that speak IPP
      # to be used without vendor drivers
      ipp-usb.enable = true;
    };

    # Declarative printer configuration
    hardware.printers = {
      ensurePrinters = [
        {
          name = "Lexmark_E260d";
          location = "Home";
          deviceUri = "usb://Lexmark/E260d?serial=72L5HWM";
          # Full PPD path from: lpinfo -m | grep -i lexmark
          model = "postscript-lexmark/Lexmark-E260d-Postscript-Lexmark.ppd";
          ppdOptions = {
            PageSize = "Letter";
          };
        }
      ];
      ensureDefaultPrinter = "Lexmark_E260d";
    };

    # SANE -- scanner support for all-in-one devices
    hardware.sane = {
      enable = true;
      extraBackends = [ pkgs.sane-airscan ];
      disabledDefaultBackends = [ "escl" ]; # cargo culted from zaneyos, not sure if needed
    };



    # Scanning/printing frontend
    environment.systemPackages = with pkgs; [
      simple-scan
      system-config-printer
    ];
  };
}