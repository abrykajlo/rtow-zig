// Constants

pub const infinity = std.math.inf(f64);
pub const pi = std.math.pi;

// Utility Functions

pub inline fn degreesToRadians(degrees: f64) f64 {
    return degrees * pi / 180.0;
}

// Common Imports

pub const color = @import("color.zig");
pub const Interval = @import("Interval.zig");
pub const Ray = @import("Ray.zig");
pub const vec3 = @import("vec3.zig");

const std = @import("std");
