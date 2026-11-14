"""ZHA quirk for the Tuya TS0601 roller blind motor, _TZE284_m6lwazh9.

Without a quirk ZHA creates no entities for this device: it speaks only Tuya's
private 0xEF00 cluster, which carries everything as numbered "datapoints" (DPs)
that ZHA cannot interpret on its own. The device still interviews fine and
shows up as a Router (it's mains-powered), just with no controls.

Neither _TZE284_m6lwazh9 nor the _TZE200_m6lwazh9 variant appears in
zha-quirks 1.2.0 (the version nixpkgs ships), and a search of
zigpy/zha-device-handlers turned up no issue or quirk for either. So the DP
numbers below are a considered guess rather than a known-good mapping.

They are copied from _TZE284_3mzb0sdz in zhaquirks/tuya/ts0601_cover.py -- the
closest relative in the shipped quirks: same TS0601 model and same _TZE284_
manufacturer generation. Notably that generation uses DPs 1/8/9 rather than the
older Tuya convention of 1/2/3, which is why this doesn't reuse the
TuyaZemismartSmartCover0601* classes.

If the blind responds but behaves wrongly, these are the levers, in order of
likelihood:

  - Position reads inverted (0% = open): flip `invert` to False. Tuya normally
    reports 0=closed/100=open, the opposite of the ZCL convention, so
    tuya_cover inverts by default.
  - Open and close are swapped: the motor's own direction setting is backwards.
    The relative above exposes it as an enum on DP 11 (0=Forward, 1=Back),
    which could be added here as a UI control.
  - Nothing moves at all, or position never updates: the DP numbers themselves
    are wrong. home-assistant.nix turns on debug logging for zigpy and
    zhaquirks -- operate the blind with its physical button and the journal
    will show the raw DP IDs and values the device actually sends.

Deliberately minimal for a first pass: just the cover, no battery (mains
powered) and no limit-setting buttons, so that what works and what doesn't is
unambiguous.
"""

from zhaquirks.tuya.builder import TuyaQuirkBuilder

(
    TuyaQuirkBuilder("_TZE284_m6lwazh9", "TS0601")
    .tuya_cover(control_dp=1, position_state_dp=8, position_control_dp=9)
    # Tuya devices generally reject standard ZCL binding/reporting setup.
    .skip_configuration()
    .add_to_registry()
)
