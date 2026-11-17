# Home Assistant, native install (services.home-assistant) rather than the
# HAOS VM or the OCI image, so the config is declarative like everything else
# here. The tradeoff, called out in the NixOS manual: this install method is
# unsupported upstream, and "apps"/addons are not available -- their equivalents
# are separate NixOS services (mosquitto, zigbee2mqtt, zwave-js, frigate...).
#
# Usage:
#   Add self.nixosModules.homeAssistant to a host's modules list.
#   Admin UI: http://home.minifridge.home (fronted by Caddy, see caddy.nix).
#   Create the first user through the onboarding flow on first visit.
#
# State lives on the /srv data disk (see disko.nix) so the recorder database
# and history survive OS reinstalls, same reasoning as paperless. /srv is
# 0755 root:root, so the hass user can traverse it; the directory itself is
# created by users.users.hass.createHome in the upstream module.
_: {
  flake.nixosModules.homeAssistant = {
    config,
    pkgs,
    ...
  }: let
    # ZHA imports every .py in custom_quirks_path at startup, so this is a
    # store directory holding just the one file. The filename intentionally
    # doesn't match any module in zhaquirks (ts0601_cover.py) -- a colliding
    # name would shadow the built-in one and drop support for every other
    # device in it.
    zhaQuirks =
      pkgs.writeTextDir "ts0601_cover_m6lwazh9.py"
      (builtins.readFile ./zha-quirks/ts0601_cover_m6lwazh9.py);
  in {
    services.home-assistant = {
      enable = true;

      # Not the default /var/lib/hass -- keep state on the data disk.
      configDir = "/srv/homeassistant";

      extraComponents = [
        # Required to complete the onboarding flow (per the NixOS manual).
        "analytics"
        "google_translate"
        "met"
        "radio_browser"
        "shopping_list"
        # Fast zlib compression -- recommended by upstream.
        "isal"
        # Zigbee radio support. Configured from the UI once a USB stick is
        # plugged in; nothing to discover until then. Z-Wave would need the
        # separate services.zwave-js server, not just a component here.
        "zha"
        # Zeroconf finds HomeKit devices on the LAN, so HA tries to load this
        # integration on every start. Without it listed here its aiohomekit
        # dependency isn't in the Python env and the flow dies with
        # ModuleNotFoundError -- the "First start" case in the NixOS manual.
        "homekit_controller"
      ];

      config = {
        # Pulls in the standard set of integrations (history, logbook,
        # mobile_app, zeroconf, ssdp, usb, ...).
        default_config = {};

        homeassistant = {
          # Follow the system timezone instead of restating it.
          time_zone = config.time.timeZone;
          # The name Caddy serves, so HA builds correct absolute links
          # (notifications, the companion app) instead of guessing from the
          # proxied request.
          internal_url = "https://home.jenningsliamd.me";
        };

        http = {
          # Reachable only through Caddy, like the Pi-hole UI (see pihole.nix).
          # HA is an authenticated surface that controls the house, so it does
          # not get a direct LAN port the way Jellyfin/copyparty do.
          server_host = ["127.0.0.1" "::1"];
          # Caddy terminates the connection, so HA sees 127.0.0.1 as the client
          # unless it is told to trust the proxy's X-Forwarded-For. Without
          # both of these HA rejects proxied requests with a 400.
          use_x_forwarded_for = true;
          trusted_proxies = ["127.0.0.1" "::1"];
        };

        # The Zigbee radio itself stays a UI config entry (it holds the serial
        # path and network key); only the quirk loading is declarative here.
        zha = {
          # Default is already true; stated so it's obvious the custom path
          # below is actually consulted.
          enable_quirks = true;
          custom_quirks_path = "${zhaQuirks}";
        };

        # Temporary, to confirm the quirk loads and to read the device's real
        # Tuya datapoints if the guessed ones are wrong. Chatty -- drop this
        # once the blind works.
        # logger.logs = {
        #   "homeassistant.components.zha" = "debug";
        #   zigpy = "debug";
        #   zhaquirks = "debug";
        # };

        # Let the UI own automations/scenes/scripts while configuration.yaml
        # stays a read-only symlink into the store. The "<domain> ui" key is
        # the documented way to merge UI-managed files with declarative entries
        # (add an "automation nixos" key for the latter).
        "automation ui" = "!include automations.yaml";
        "scene ui" = "!include scenes.yaml";
        "script ui" = "!include scripts.yaml";
      };
    };

    # HA fails to start if an !include target is missing, and it cannot create
    # these itself before the first UI save -- so pre-create them empty.
    systemd.tmpfiles.rules = let
      inherit (config.services.home-assistant) configDir;
    in [
      "f ${configDir}/automations.yaml 0644 hass hass - "
      "f ${configDir}/scenes.yaml      0644 hass hass - "
      "f ${configDir}/scripts.yaml     0644 hass hass - "
    ];

    # Access to a USB Zigbee/Z-Wave radio (/dev/ttyUSB*, /dev/ttyACM*). Takes
    # effect whenever a stick is plugged in; harmless while none is.
    users.users.hass.extraGroups = ["dialout"];
  };
}
