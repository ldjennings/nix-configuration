{ pkgs, ... }:
{
  hardware = {


    bluetooth.enable = true;
    bluetooth.powerOnBoot = true;
  };
  # local.hardware-clock.enable = false;
}
