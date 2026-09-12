# Flake-parts module for Framework laptop LED control.
# Automatically sets the power LED color based on system state, in order:
#   - Red when battery is low (≤15%) and discharging
#   - Off when screen brightness is low (≤20%) -- wins over the night light
#   - Amber when the night light is on
#   - White otherwise
#
# Triggered by udev events on battery and backlight changes, and by the
# nightlight-watch service whenever the screen tint changes, so it reacts
# instantly with no polling overhead.
#
# On suspend/hibernate the LED is forced off and re-rendered on resume (via
# powerManagement.powerDownCommands/resumeCommands below). Closing the lid
# triggers
# suspend-then-hibernate (services/power-saving.nix), so this is what turns
# the LED off when the lid is shut -- once we pin a colour with `ectool`, the
# EC holds it through sleep, so we have to explicitly clear it.
#
# The LED is driven through `sudo ectool`: EC access needs root, and the
# exact colours (red / white / amber / off) are whitelisted NOPASSWD for the
# user in core/security.nix. That lets the same script work both as root
# (udev / resume hook) and as the user (the nightlight-watch service).
#
# Night light: noctalia applies the tint in-process via wlr-gamma-control and
# exposes no way to query it, but it logs every applied colour temperature.
# The nightlight-watch service (below) tails that log and mirrors the state
# into /run/nightlight-state, which led-control reads. This tracks both the
# geo schedule and the manual "Print" force-toggle (see the bind in
# modules/home/desktop/niri/default.nix), since both change the logged temp.
#
# Usage:
#   Automatically a part of the brick host, via sharing the module.
#
#   Verify it's working after rebuild:
#     udevadm monitor --subsystem-match=backlight    # watch backlight events
#     udevadm monitor --subsystem-match=power_supply # watch battery events
#     sudo ectool led power red                      # manually test LED
_: {
  flake.nixosModules.hostBrick = {
    pkgs,
    config,
    ...
  }: let
    # On/off marker for the night light, written by the watcher below and read
    # by led-control. Kept on tmpfs so it resets to "off" every boot.
    nightlightState = "/run/nightlight-state";
    # Noctalia has no way to query the night-light state (no IPC getter, not in
    # `msg status`, and the wlr-gamma tint is write-only), but it logs every
    # applied colour temperature as "[gamma] target <N>K (... day=<D>K ...)".
    # The watcher tails that log and mirrors the effective tint into the marker
    # + LED, so both the geo schedule (auto) and manual force-toggles are
    # tracked. "on" whenever the applied temp is below the configured day temp.
    noctaliaLog = "/home/${config.host.username}/.cache/noctalia/noctalia.log";
    led-control = pkgs.writeShellApplication {
      name = "led-control";
      runtimeInputs = with pkgs; [
        brightnessctl
      ];
      text = ''
        # EC access needs root; when run from a user context (the night-light
        # watcher, resume hook as root is fine too) go through the NOPASSWD
        # `ectool led power ...` rule from core/security.nix.
        ectool() { /run/wrappers/bin/sudo /run/current-system/sw/bin/ectool "$@"; }

        battery=$(cat /sys/class/power_supply/BAT1/capacity)
        status=$(cat /sys/class/power_supply/BAT1/status)
        brightness=$(brightnessctl get)
        max=$(brightnessctl max)
        brightness_pct=$((brightness * 100 / max))
        # Missing file (e.g. first boot before tmpfiles runs) counts as off.
        nightlight=$(cat ${nightlightState} 2>/dev/null || echo off)

        # Priority 1: low battery while discharging
        if [ "$battery" -le 15 ] && [ "$status" = "Discharging" ]; then
          ectool led power red
          exit 0
        fi

        # Priority 2: low brightness -- off wins over the night-light tint
        if [ "$brightness_pct" -le 20 ]; then
          ectool led power off
          exit 0
        fi

        # Priority 3: night light on -> amber tint
        if [ "$nightlight" = "on" ]; then
          ectool led power amber
          exit 0
        fi

        # Default
        ectool led power white
      '';
    };
    nightlight-watch = pkgs.writeShellApplication {
      name = "nightlight-watch";
      runtimeInputs = with pkgs; [coreutils gnugrep];
      text = ''
        # Mirror a "[gamma] target <N>K (... day=<D>K ...)" log line into the
        # marker + LED. Night light counts as on whenever the applied temp is
        # below the day temp (covers the full ramp, not just the exact night
        # temp).
        apply() {
          target=$(printf '%s' "$1" | grep -oE 'target [0-9]+K' | grep -oE '[0-9]+')
          day=$(printf '%s' "$1" | grep -oE 'day=[0-9]+K' | grep -oE '[0-9]+')
          if [ -n "$target" ] && [ -n "$day" ] && [ "$target" -lt "$day" ]; then
            echo on > ${nightlightState}
          else
            echo off > ${nightlightState}
          fi
          ${led-control}/bin/led-control
        }

        # Seed from the most recent target line -- the night light may already
        # be on (e.g. the schedule engaged before we started).
        last=$(grep -F '[gamma] target' ${noctaliaLog} 2>/dev/null | tail -n1 || true)
        if [ -n "$last" ]; then apply "$last"; fi

        # React to every subsequent change. -F retries if the log is missing or
        # rotated (Noctalia not up yet, logrotate), so we don't need to depend
        # on the session being ready.
        tail -n0 -F ${noctaliaLog} 2>/dev/null | while IFS= read -r line; do
          case "$line" in
            *'[gamma] target'*) apply "$line" ;;
          esac
        done
      '';
    };
  in {
    services.udev.extraRules = ''
      SUBSYSTEM=="power_supply", ATTR{type}=="Battery", RUN+="${led-control}/bin/led-control"
      SUBSYSTEM=="backlight", RUN+="${led-control}/bin/led-control"
    '';

    # led-control on PATH for manual testing; the watcher drives it in normal
    # operation.
    environment.systemPackages = [led-control];

    # Night-light marker, owned by the primary user so the watcher (which runs
    # as that user) can write it. On tmpfs, so it resets to "off" each boot.
    systemd.tmpfiles.rules = [
      "f ${nightlightState} 0644 ${config.host.username} users - off"
    ];

    # Long-running watcher that tails Noctalia's log and keeps the marker + LED
    # in sync with the actual screen tint. Runs as the user (the log lives in
    # their ~/.cache and led-control reaches ectool via the NOPASSWD sudo rule).
    systemd.services.nightlight-watch = {
      description = "Mirror Noctalia night-light state onto the Framework LED";
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        User = config.host.username;
        ExecStart = "${nightlight-watch}/bin/nightlight-watch";
        Restart = "always";
        RestartSec = 2;
      };
    };

    # Force the LED off while asleep, restore it on resume. This hooks NixOS's
    # sleep-actions unit, which fires on sleep.target -- pulled in by both
    # suspend and hibernate -- with the correct StopWhenUnneeded semantics
    # (powerDownCommands run before sleep, resumeCommands on resume). Root
    # context, so ectool is called directly; the re-render just re-runs
    # led-control for the current battery/brightness/night-light state.
    #
    # Earlier attempt (don't reintroduce): a hand-rolled oneshot with
    # WantedBy=sleep.target but no StopWhenUnneeded. WantedBy only *starts* a
    # unit, so the RemainAfterExit oneshot went active on the first suspend and
    # never stopped -- subsequent suspends didn't re-run the off command, and
    # the resume re-render fired late. The sleep-actions wrapper has
    # StopWhenUnneeded=true, so it re-arms on every cycle.
    #
    # Known hardware flakiness (not a bug here): the Framework occasionally
    # drops the lid-close event (ACPI/SW_LID), most often right after a resume
    # or on a quick close. When that happens logind never logs "Lid closed", so
    # no suspend, so the LED stays on. Verified via journalctl that whenever the
    # event *is* delivered the whole chain works -- single suspend/resume and
    # back-to-back suspend/resume/suspend both go off-then-restore correctly,
    # while locked or unlocked. So an occasional LED-stayed-on after closing the
    # lid is missed hardware events, not this module.
    powerManagement.powerDownCommands = "/run/current-system/sw/bin/ectool led power off";
    powerManagement.resumeCommands = "${led-control}/bin/led-control";
  };
}
