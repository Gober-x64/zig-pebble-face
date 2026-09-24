const std = @import("std");
const pebble = @import("pebble");
const presource = @import("pebble_appids");
const settings = @import("settings.zig");

const MessagingCallback = *const fn () void;
var on_update: MessagingCallback = undefined;

// Clay select values are strings; also accept integer AppMessages. Never turn
// unvalidated phone data into an enum (which traps in ReleaseSafe).
fn readInt(iter: [*c]pebble.DictionaryIterator, key: presource.MESSAGE_KEYS) ?i32 {
    const tuple = pebble.dict_find(iter, @intFromEnum(key));
    if (tuple == null) return null;
    const t: *const pebble.Tuple = tuple;
    switch (t.type) {
        pebble.TUPLE_CSTRING => {
            if (t.length == 0) return null;
            const ptr: [*]const u8 = @ptrCast(t.value());
            const bytes = ptr[0..t.length];
            if (bytes[bytes.len - 1] != 0) return null;
            return std.fmt.parseInt(i32, bytes[0 .. bytes.len - 1], 10) catch null;
        },
        pebble.TUPLE_INT => return switch (t.length) {
            1 => t.value().*.int8,
            2 => t.value().*.int16,
            4 => t.value().*.int32,
            else => null,
        },
        pebble.TUPLE_UINT => return switch (t.length) {
            1 => t.value().*.uint8,
            2 => t.value().*.uint16,
            4 => std.math.cast(i32, t.value().*.uint32),
            else => null,
        },
        else => return null,
    }
}

fn inbox_received_handler(iter: [*c]pebble.DictionaryIterator, _: ?*anyopaque) callconv(.c) void {
    if (readInt(iter, .SettingsEnableSeconds)) |value| {
        if (std.enums.fromInt(settings.SecondsOptions, value)) |option| settings.settingsSetSeconds(option) else {}
    }
    if (readInt(iter, .SettingsTimeZone)) |value| {
        if (std.enums.fromInt(settings.TimeZoneOptions, value)) |option| settings.settingsSetTimeZone(option) else {}
    }
    if (readInt(iter, .SettingsHourFormat)) |value| {
        if (value >= 0 and value <= 2) _ = pebble.persist_write_int(@intFromEnum(presource.MESSAGE_KEYS.SettingsHourFormat), value);
    }
    if (readInt(iter, .SettingsFlickSeconds)) |value| {
        if (value == 0 or value == 5 or value == 10 or value == 15) _ = pebble.persist_write_int(@intFromEnum(presource.MESSAGE_KEYS.SettingsFlickSeconds), value);
    }
    on_update();
}

pub fn messagingInit(callback: MessagingCallback) void {
    on_update = callback;
    _ = pebble.app_message_register_inbox_received(inbox_received_handler);
    _ = pebble.app_message_open(256, 128);
}

pub fn messagingDeinit() void {
    pebble.app_message_deregister_callbacks();
}
