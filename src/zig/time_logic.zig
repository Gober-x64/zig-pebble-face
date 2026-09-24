const std = @import("std");

// Preserve the stored values from earlier releases.
pub const SecondsOptions = enum(isize) {
    PerSecond = 0,
    PerFifteen = 1,
    PerMinute = 2,
    PerThirty = 3,
};
pub const HourFormat = enum(isize) { System = 0, Twelve = 1, TwentyFour = 2 };

pub fn displayHour(hour: usize, twenty_four: bool) usize {
    return if (twenty_four) hour else if (hour % 12 == 0) 12 else hour % 12;
}

pub fn interval(mode: SecondsOptions) u32 {
    return switch (mode) {
        .PerSecond => 1,
        .PerFifteen => 15,
        .PerThirty => 30,
        .PerMinute => 60,
    };
}

pub fn shouldRefresh(mode: SecondsOptions, live: bool, second: u32) bool {
    return live or second % interval(mode) == 0;
}

pub fn offsetMinutes(hour: c_int, minute: c_int, offset: c_int) struct { hour: c_int, minute: c_int } {
    const total = @mod(hour * 60 + minute + offset, 24 * 60);
    return .{ .hour = @divTrunc(total, 60), .minute = @mod(total, 60) };
}

test "12 and 24 hour boundaries" {
    const expectEqual = std.testing.expectEqual;
    try expectEqual(@as(usize, 0), displayHour(0, true));
    try expectEqual(@as(usize, 23), displayHour(23, true));
    try expectEqual(@as(usize, 12), displayHour(0, false));
    try expectEqual(@as(usize, 12), displayHour(12, false));
    try expectEqual(@as(usize, 1), displayHour(13, false));
}

test "all cadences resume after live seconds ends" {
    for (std.enums.values(SecondsOptions)) |mode| {
        for (0..60) |sec| {
            try std.testing.expect(shouldRefresh(mode, true, @intCast(sec)));
            try std.testing.expectEqual(sec % interval(mode) == 0, shouldRefresh(mode, false, @intCast(sec)));
        }
    }
}

test "timezone minutes, carry, borrow and midnight" {
    const cases = [_][5]c_int{
        .{ 12, 32, 60, 13, 32 }, // Issue #6: :32 must remain :32.
        .{ 23, 45, 330, 5, 15 },
        .{ 0, 10, -210, 20, 40 },
        .{ 23, 30, 345, 5, 15 },
        .{ 12, 40, 210, 16, 10 },
    };
    for (cases) |c| {
        const actual = offsetMinutes(c[0], c[1], c[2]);
        try std.testing.expectEqual(c[3], actual.hour);
        try std.testing.expectEqual(c[4], actual.minute);
    }
}
