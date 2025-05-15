const Interval = @This();

min: f64 = rtweekend.infinity,
max: f64 = -rtweekend.infinity,

pub fn size(self: *const Interval) f64 {
    return self.max - self.min;
}

pub fn contains(self: *const Interval, x: f64) bool {
    return self.min <= x and x <= self.max;
}

pub fn surrounds(self: *const Interval, x: f64) bool {
    return self.min < x and x < self.max;
}

pub const empty: Interval = .{};
pub const universe: Interval = .{ .min = -rtweekend.infinity, .max = rtweekend.infinity };

const std = @import("std");
const rtweekend = @import("rtweekend.zig");
