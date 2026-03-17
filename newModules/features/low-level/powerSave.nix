# Power management for Intel laptop.
# Uses TLP for fine-grained CPU/battery control and thermald
# for Intel thermal management.
# Note: power-profiles-daemon conflicts with TLP -- do not enable both.
{ ... }: {
  flake.nixosModules.powerSave = { ... }: {
    # Intel thermal management -- prevents throttling
    services.thermald.enable = true;

    # Powertop auto-tune on boot -- Intel power optimisation
    powerManagement.powertop.enable = true;

    services.tlp = {
      enable = true;
      settings = {
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
        CPU_MIN_PERF_ON_AC = 0;
        CPU_MAX_PERF_ON_AC = 100;
        CPU_MIN_PERF_ON_BAT = 0;
        CPU_MAX_PERF_ON_BAT = 20;
        # Charge thresholds -- improves long term battery health
        # starts charging at 40%, stops at 80%
        START_CHARGE_THRESH_BAT0 = 40;
        STOP_CHARGE_THRESH_BAT0 = 80;
      };
    };

    # Lid close: suspend first, hibernate after 5 minutes
    services.logind.settings.Login = {
      HandleLidSwitch = "suspend-then-hibernate";
      HandlePowerKey = "suspend";
      HandlePowerKeyLongPress = "poweroff";
    };

    systemd.sleep.extraConfig = ''
      HibernateDelaySec=5m
      SuspendState=mem
    '';
  };
}