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

Cross-checked against Zigbee2MQTT, which supports the _TZE210_m6lwazh9
sibling (src/devices/tuya.ts, model TS0301_cover_1). Its datapoint table
independently confirms the mapping above and fills in one more:

    [1,  "state",             coverAction]
    [2,  "position",          coverPosition]
    [3,  "position",          coverPosition]
    [5,  "reverse_direction", forward=enum(0), back=enum(1)]
    [13, "battery",           raw]

So motor direction is dp=5, not the dp=11 used by _TZE284_3mzb0sdz. Not mapped
here because direction currently reads correctly; add it if that changes.

TRAVEL LIMITS -- unresolved, and the next thing to work on.

The motor arrives uncalibrated. Until limits are set it accepts a percentage
target, acks it, moves nothing, and reports dp=3 as 0 forever, so HA shows it
permanently closed at 0%. Open/close/stop are unaffected, being relative "run
until stopped" commands. Direction and `invert` cannot be judged until a real
position is ever reported -- a constant 0 is not an inverted reading.

dp=16 does something here. Mapped from _TZE284_3mzb0sdz, the motor echoed back
enum values 0 and 2, ignored 1, 3 and 4, and afterwards stopped moving at all,
which looks like a limit having been set to a degenerate value. So the device
clearly implements dp=16 -- just not with that quirk's five-value BorderSetting
semantics. Those buttons were removed because half of them did nothing and the
other half could wedge the motor, not because the datapoint is meaningless.

Do not read Zigbee2MQTT's silence as proof: its _TZE210_m6lwazh9 definition has
no limit datapoint, and _TZE210_xgzzuerd right next to it does expose
te.coverLimit() -- but its _TZE200_m6lwazh9 entry is explicitly marked
"incomplete", so the table is not exhaustive for this family.

Known hardware: TNCGLF/A-OK AM25, 433MHz remote plus Zigbee, same family as the
Zemismart ZM25AZ01 (Koenkk/zigbee2mqtt#31774) and Trublockout TB25-DC-10/25Z.
The remote is the supported way to calibrate and the thing to try first.

When picking this up again: enum values 0 and 2 on dp=16 are the known-live
ones, the Tuya IoT platform's product datapoint list would settle the real
semantics, and anything tried here should be reversible before it goes near a
limit the motor stores.
"""

from zigpy.zcl.clusters.general import BatterySize
from zigpy.zdo.types import (
    DescriptorCapability,
    FrequencyBand,
    LogicalType,
    MACCapabilityFlags,
    NodeDescriptor,
)

from zhaquirks.tuya.builder import TuyaQuirkBuilder

# The motor runs off a Type-C rechargeable cell but advertises MainsPowered in
# its node descriptor. ZHA's battery sensor is hard-gated on that flag --
# zha/application/platforms/sensor/__init__.py Battery._is_supported() is
# "PlatformEntity._is_supported(self) and not self.device.is_mains_powered" --
# so no battery entity was ever created, even though dp=13 reports correctly
# and the attribute updates were visible in the logs.
#
# This is the device's descriptor as interviewed, with only the MainsPowered
# bit cleared (142 -> 138). logical_type stays Router, which IS accurate: it
# keeps its receiver on and relays for the mesh. Demoting it to EndDevice would
# also stop the mesh using it as a repeater, which is a real change for no gain
# -- the power flag alone is what gates the sensor.
#
# Knock-on effects of the flag, all acceptable for a device that is in fact
# battery powered: consider_unavailable_time moves from the mains default to
# the battery one, ZHA no longer polls it at startup, and attribute reads come
# from cache instead of waking it. The cost is that a dead motor takes longer
# to show as unavailable.
_NODE_DESCRIPTOR = NodeDescriptor(
    logical_type=LogicalType.Router,
    complex_descriptor_available=0,
    user_descriptor_available=0,
    reserved=0,
    aps_flags=0,
    frequency_band=FrequencyBand.Freq2400MHz,
    mac_capability_flags=(
        MACCapabilityFlags.FullFunctionDevice
        | MACCapabilityFlags.RxOnWhenIdle
        | MACCapabilityFlags.AllocateAddress
    ),
    manufacturer_code=4098,
    maximum_buffer_size=82,
    maximum_incoming_transfer_size=82,
    server_mask=11264,
    maximum_outgoing_transfer_size=82,
    descriptor_capability_field=DescriptorCapability.NONE,
)

(
    TuyaQuirkBuilder("_TZE284_m6lwazh9", "TS0601")
    .node_descriptor(_NODE_DESCRIPTOR)
    .tuya_cover(control_dp=1, position_state_dp=3, position_control_dp=2)
    # tuya_battery otherwise defaults to 2x AA, which it isn't -- this motor
    # has a single built-in Type-C rechargeable cell. Cosmetic (the figures
    # only show up as entity attributes) but there's no reason to state it
    # wrongly.
    .tuya_battery(dp_id=13, battery_type=BatterySize.Built_in, battery_qty=1)
    # Tuya devices generally reject standard ZCL binding/reporting setup.
    .skip_configuration()
    .add_to_registry()
)
