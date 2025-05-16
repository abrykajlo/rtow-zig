// Constants

pub const infinity = std.math.inf(f64);
pub const pi = std.math.pi;

// Utility Functions

pub inline fn degreesToRadians(degrees: f64) f64 {
    return degrees * pi / 180.0;
}

pub inline fn randomDouble(args: anytype) f64 {
    const static = struct {
        var ptr = std.Random.DefaultPrng.init(0);
        const random = ptr.random();
    };
    switch (@typeInfo(@TypeOf(args))) {
        .void => return static.random.float(f64),
        .@"struct" => return args.min + (args.max - args.min) * randomDouble(void{}),
        else => @compileError("Args type not supported: " ++ @typeName(args)),
    }
}

// Common Imports

pub const color = @import("color.zig");
pub const Interval = @import("Interval.zig");
pub const Ray = @import("Ray.zig");
pub const vec3 = @import("vec3.zig");

const std = @import("std");
