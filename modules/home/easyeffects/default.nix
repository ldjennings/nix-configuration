{ lib, ... }:
{
  services.easyeffects = {
    enable = true;
    extraPresets = lib.importJSON ./presets/fw13-easy-effects.json;
  };

  
  xdg.configFile."easyeffects/irs/IR_22ms_27dB_5t_15s_0c.irs".source =
    ./IR_22ms_27dB_5t_15s_0c.irs;

}