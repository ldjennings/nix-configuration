# newModules/home/desktop/hyprland/hypridle.nix
{ self, ... }: {
  flake.modules.homeManager.hyprland = { ... }: {
    services.hypridle = {
      enable = true;
      settings = {
        general = {
          before_sleep_cmd = "loginctl lock-session";
          after_sleep_cmd = "hyprctl dispatch dpms on";
          lock_cmd = "pidof hyprlock || hyprlock";
        };
        listener = [
          {
            # Lock screen after 3 minutes
            timeout = 180;
            on-timeout = "loginctl lock-session";
          }
          {
            # Turn off display after 5 minutes
            timeout = 300;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
          {
            # Suspend after 10 minutes
            timeout = 600;
            on-timeout = "systemctl suspend";
          }
        ];
      };
    };
  };
}