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

The limit buttons below exist because this motor ships uncalibrated: with no
travel limits it accepts a percentage target, acks it, and does nothing, since
"50%" has no meaning yet. Relative open/close/stop work regardless, which is
why those came up first. Confirmed by dp=3 only ever reporting 0, even after
the blind had physically moved.

dp=16 is taken from _TZE284_3mzb0sdz and is NOT confirmed for this device --
the same source got the position DPs wrong. If the buttons do nothing, the
motor's physical set button is the fallback.

To calibrate: drive the blind to fully open, press "Set upper limit"; drive it
to fully closed, press "Set lower limit". The delete buttons start over.
"""

import zigpy.types as t

from zhaquirks.tuya import TUYA_CLUSTER_ID
from zhaquirks.tuya.builder import TuyaQuirkBuilder


class BorderSetting(t.enum8):
    """Travel-limit commands for dp=16."""

    Up = 0x00
    Down = 0x01
    Up_delete = 0x02
    Down_delete = 0x03
    Remove_top_bottom = 0x04


(
    TuyaQuirkBuilder("_TZE284_m6lwazh9", "TS0601")
    .tuya_cover(control_dp=1, position_state_dp=3, position_control_dp=2)
    .tuya_battery(dp_id=13)
    .tuya_dp_attribute(
        dp_id=16,
        attribute_name="border",
        type=BorderSetting,
    )
    .write_attr_button(
        attribute_name="border",
        attribute_value=BorderSetting.Up,
        cluster_id=TUYA_CLUSTER_ID,
        unique_id_suffix="border_up",
        translation_key="set_upper_limit",
        fallback_name="Set upper limit",
    )
    .write_attr_button(
        attribute_name="border",
        attribute_value=BorderSetting.Down,
        cluster_id=TUYA_CLUSTER_ID,
        unique_id_suffix="border_down",
        translation_key="set_lower_limit",
        fallback_name="Set lower limit",
    )
    .write_attr_button(
        attribute_name="border",
        attribute_value=BorderSetting.Up_delete,
        cluster_id=TUYA_CLUSTER_ID,
        unique_id_suffix="border_up_delete",
        translation_key="delete_upper_limit",
        fallback_name="Delete upper limit",
    )
    .write_attr_button(
        attribute_name="border",
        attribute_value=BorderSetting.Down_delete,
        cluster_id=TUYA_CLUSTER_ID,
        unique_id_suffix="border_down_delete",
        translation_key="delete_lower_limit",
        fallback_name="Delete lower limit",
    )
    .write_attr_button(
        attribute_name="border",
        attribute_value=BorderSetting.Remove_top_bottom,
        cluster_id=TUYA_CLUSTER_ID,
        unique_id_suffix="border_remove_all",
        translation_key="delete_all_limits",
        fallback_name="Delete all limits",
    )
    # Tuya devices generally reject standard ZCL binding/reporting setup.
    .skip_configuration()
    .add_to_registry()
)
