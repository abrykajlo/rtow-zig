// Constants

pub const infinity = std.math.inf(f64);
pub const pi = std.math.pi;

// Utility Functions

pub inline fn degreesToRadians(degrees: f64) f64 {
    return degrees * pi / 180.0;
}

pub inline fn randomDouble() f64 {
    const static = struct {
        var ptr = std.Random.DefaultPrng.init(0);
        const random = ptr.random();
    };
    return static.random.float(f64);
}

pub inline fn randomDoubleInRange(min: f64, max: f64) f64 {
    return min + (max - min) * randomDouble();
}

// Common Imports

pub const color = @import("color.zig");
pub const Interval = @import("Interval.zig");
pub const Ray = @import("Ray.zig");
pub const vec3 = @import("vec3.zig");

const std = @import("std");
