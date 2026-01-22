{ lib, ... }:
{
  # This config is taken from the repo: https://github.com/FrameworkComputer/linux-docs/tree/main/easy-effects
  # specifically tuned for the framework laptop 13
  # after switching, start easyeffects then select "My Preset". Not sure if will stay selected
  services.easyeffects = {
    enable = true;
    extraPresets = lib.importJSON ./fw13-easy-effects.json;
  };

  
  xdg.configFile."easyeffects/irs/IR_22ms_27dB_5t_15s_0c.irs".source =
    ./IR_22ms_27dB_5t_15s_0c.irs;

}