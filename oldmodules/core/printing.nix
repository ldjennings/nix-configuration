{ host, pkgs, ... }:
let
  inherit (import ../../hosts/${host}/variables.nix) printEnable;
in
{
  services = {
    printing = {
      enable = printEnable;
      drivers = [
        # pkgs.hplipWithPlugin
        pkgs.postscript-lexmark
      ];
    };
    avahi = {
      enable = printEnable;
      nssmdns4 = true;
      openFirewall = true;
    };
    ipp-usb.enable = printEnable;
  };
}
