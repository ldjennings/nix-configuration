# Fcitx5 input method framework with Pinyin Chinese input.
# Requires XDG autostart to launch fcitx5 on login when
# running a standalone Wayland compositor without a full DE.
{
  flake.nixosModules.pinyinInput = {
    pkgs,
    config,
    ...
  }: {
    i18n.inputMethod = {
      type = "fcitx5";
      enable = true;

      fcitx5 = {
        waylandFrontend = true;
        addons = with pkgs; [
          fcitx5-gtk # GTK integration
          qt6Packages.fcitx5-chinese-addons # Pinyin and table input
          fcitx5-nord # Nord color theme
        ];
        settings.inputMethod = {
          GroupOrder."0" = "Default";
          "Groups/0" = {
            Name = "Default";
            "Default Layout" = config.host.keyboard.variant; # match XKB layout
            DefaultIM = "pinyin";
          };
          "Groups/0/Items/0".Name = "keyboard-us";
          "Groups/0/Items/1".Name = "pinyin";
        };
      };
    };

    # Required to launch fcitx5 on login without a full DE
    services.xserver.desktopManager.runXdgAutostartIfNone = true;
  };
}
