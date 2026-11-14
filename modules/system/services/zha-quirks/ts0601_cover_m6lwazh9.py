"""ZHA quirk for the Tuya TS0601 roller blind motor, _TZE284_m6lwazh9.

Without a quirk ZHA creates no entities for this device: it speaks only Tuya's
private 0xEF00 cluster, which carries everything as numbered "datapoints" (DPs)
that ZHA cannot interpret on its own. The device still interviews fine and
shows up as a Router, just with no controls.

Neither _TZE284_m6lwazh9 nor the _TZE200_m6lwazh9 variant appears in
zha-quirks 1.2.0 (the version nixpkgs ships), and a search of
zigpy/zha-device-handlers turned up no issue or quirk for either.

The datapoints below were read off the device itself, by running with debug
logging for zigpy and watching the raw 0xEF00 frames while operating the blind:

    dp=3   type 0x02 (4-byte value)  position, 0-100
    dp=13  type 0x02 (4-byte value)  battery percentage
    dp=103 type 0x05 (bitmap)        motor/work state; 0x00, 0x04, 0x08 seen

So this is the classic Tuya cover layout -- 1 = open/stop/close control,
2 = target position, 3 = reported position -- and NOT the 1/8/9 layout used by
_TZE284_3mzb0sdz, the closest relative in the shipped quirks. Inferring from
that relative was wrong; the logs settled it.

dp=2 is the one value here still not directly observed: the device only reports
position on dp=3 and never echoes the target, so there is nothing to capture.
2 is where it sits in this layout.

dp=103 is deliberately left unmapped. It tracks motor state, which ZHA already
infers from position changes, so handling it would only add an entity. It keeps
emitting "No datapoint handler" at debug level, which is harmless.

If position ends up inverted (slider at 0% showing open), flip `invert`:
tuya_cover inverts by default because Tuya reports 0=closed/100=open, the
opposite of the ZCL convention.
"""

from zhaquirks.tuya.builder import TuyaQuirkBuilder

(
    TuyaQuirkBuilder("_TZE284_m6lwazh9", "TS0601")
    .tuya_cover(control_dp=1, position_state_dp=3, position_control_dp=2)
    .tuya_battery(dp_id=13)
    # Tuya devices generally reject standard ZCL binding/reporting setup.
    .skip_configuration()
    .add_to_registry()
)
