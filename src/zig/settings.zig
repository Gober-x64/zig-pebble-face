const pebble = @import("pebble");
const presource = @import("pebble_appids");

const logic = @import("time_logic.zig");
pub const SecondsOptions = logic.SecondsOptions;
pub const HourFormat = logic.HourFormat;

pub const TimeZoneOptions = enum(isize) {
    None = -1,
    PagoPago = 0,
    Hololulu = 1,
    Anchorage = 2,
    Vancouver = 3,
    SanFran = 4,
    Edmonton = 5,
    Denver = 6,
    CDMX = 7,
    Chicago = 8,
    NYC = 9,
    Santiago = 10,
    Halifax = 11,
    StJohns = 12,
    Rio = 13,
    FdeNoronha = 14,
    Praia = 15,
    UTC = 16,
    Lisbon = 17,
    London = 18,
    Madrid = 19,
    Paris = 20,
    Rome = 21,
    Berlin = 22,
    Stockholm = 23,
    Athen = 24,
    Cairo = 25,
    Jerusalem = 26,
    Moscow = 27,
    Jeddah = 28,
    Tehran = 29,
    Dubai = 30,
    Kabul = 31,
    Karachi = 32,
    Delhi = 33,
    Kathmandu = 34,
    Dhaka = 35,
    Yangon = 36,
    Bangkok = 37,
    Singapore = 38,
    HongKong = 39,
    Beijing = 40,
    Taipei = 41,
    Seoul = 42,
    Tokyo = 43,
    Adelaide = 44,
    Guam = 45,
    Sydney = 46,
    Noumea = 47,
    Wellington = 48,
};

const DEFAULT = Settings{};

pub const Settings = struct {
    seconds: SecondsOptions = SecondsOptions.PerSecond,
    tz: TimeZoneOptions = TimeZoneOptions.None,
};

pub fn settingsRead(key: usize) ?isize {
    return if (pebble.persist_exists(key)) @intCast(pebble.persist_read_int(key)) else null;
}

pub fn settingsSetSeconds(option: SecondsOptions) void {
    const value: i32 = @intCast(@intFromEnum(option));
    _ = pebble.persist_write_int(@intFromEnum(presource.MESSAGE_KEYS.SettingsEnableSeconds), value);
}

pub fn settingsGetSeconds() SecondsOptions {
    const read = settingsRead(@intFromEnum(presource.MESSAGE_KEYS.SettingsEnableSeconds));
    if (read == null) return DEFAULT.seconds else return @import("std").enums.fromInt(SecondsOptions, read.?) orelse DEFAULT.seconds;
}

pub fn settingsSetTimeZone(option: TimeZoneOptions) void {
    const value: i32 = @intCast(@intFromEnum(option));

    _ = pebble.persist_write_int(@intFromEnum(presource.MESSAGE_KEYS.SettingsTimeZone), value);
}

pub fn settingsGetTimeZone() TimeZoneOptions {
    const value = settingsRead(@intFromEnum(presource.MESSAGE_KEYS.SettingsTimeZone));
    if (value == null) return DEFAULT.tz;
    return @import("std").enums.fromInt(TimeZoneOptions, value.?) orelse DEFAULT.tz;
}

pub fn settingsGetHourFormat() HourFormat {
    const value = settingsRead(@intFromEnum(presource.MESSAGE_KEYS.SettingsHourFormat)) orelse 0;
    return @import("std").enums.fromInt(HourFormat, value) orelse .System;
}

pub fn settingsIs24Hour() bool {
    return switch (settingsGetHourFormat()) {
        .System => pebble.clock_is_24h_style(),
        .Twelve => false,
        .TwentyFour => true,
    };
}

pub fn settingsGetFlickSeconds() u32 {
    const value = settingsRead(@intFromEnum(presource.MESSAGE_KEYS.SettingsFlickSeconds)) orelse 10;
    return if (value == 0 or value == 5 or value == 10 or value == 15) @intCast(value) else 10;
}
