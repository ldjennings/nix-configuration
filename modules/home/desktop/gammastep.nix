{ ... }:
{
  flake.modules.homeManager.gammastep =
    { ... }:
    {
      services.gammastep = {
        enable = true;
        provider = "manual";
        # Seattle coordinates
        latitude = 47.6;
        longitude = -122.3;
        temperature = {
          day = 6500;
          night = 3500;
        };
        settings.general = {
          # Smooth transition between day and night
          fade = 1;
          # Adjustment method -- wayland requires randr or wayland backend
          adjustment-method = "wayland";
        };
        settings.wayland.screen = 0;
      };
    };
}
