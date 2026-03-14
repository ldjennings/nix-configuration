{ pkgs, ... }: {
  security = {
    rtkit.enable = true;
    polkit = {
      enable = true;
      extraConfig = ''
        polkit.addRule(function(action, subject) {
          if ( subject.isInGroup("users") && (
           action.id == "org.freedesktop.login1.reboot" ||
           action.id == "org.freedesktop.login1.reboot-multiple-sessions" ||
           action.id == "org.freedesktop.login1.power-off" ||
           action.id == "org.freedesktop.login1.power-off-multiple-sessions"
          ))
          { return polkit.Result.YES; }
        })
      '';
    };
    pam.services.swaylock = {
      text = ''auth include login '';
    };

    # sudoers rules to allow scripts to change the LED color without root access
    sudo.extraRules = [
      {
        users = [ "liam" ];
        commands = [
          { command = "${pkgs.fw-ectool}/bin/ectool led power red";   options = [ "NOPASSWD" ]; }
          { command = "${pkgs.fw-ectool}/bin/ectool led power white"; options = [ "NOPASSWD" ]; }
          { command = "${pkgs.fw-ectool}/bin/ectool led power amber"; options = [ "NOPASSWD" ]; }
          { command = "${pkgs.fw-ectool}/bin/ectool led power off";   options = [ "NOPASSWD" ]; }
        ];
      }
    ];
  };
}
