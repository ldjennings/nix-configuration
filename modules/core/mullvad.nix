
{ pkgs, ... }:
{
  services.mullvad-vpn.enable = true;
  environment.systemPackages = with pkgs; [ mullvad ];
  # home.packages = [ pkgs.mullvad  ];
}

