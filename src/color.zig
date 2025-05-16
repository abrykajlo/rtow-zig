pub const Color = @Vector(3, f64);

pub fn write(writer: *const std.fs.File.Writer, color: *const Color) !void {
    var r = color[0];
    var g = color[1];
    var b = color[2];

    // Apply a linear to gamma transform for gamma 2
    r = linearToGamma(r);
    g = linearToGamma(g);
    b = linearToGamma(b);

    // Translate the [0,1] component values to the byte range [0,255].
    const static = struct {
        const intensity: Interval = .{ .min = 0.000, .max = 0.999 };
    };
    const rbyte: c_int = @intFromFloat(256 * static.intensity.clamp(r));
    const gbyte: c_int = @intFromFloat(256 * static.intensity.clamp(g));
    const bbyte: c_int = @intFromFloat(256 * static.intensity.clamp(b));

    try writer.print("{} {} {}\n", .{ rbyte, gbyte, bbyte });
}

inline fn linearToGamma(linear_component: f64) f64 {
    if (linear_component > 0)
        return @sqrt(linear_component);

    return 0;
}

const std = @import("std");

const Interval = @import("Interval.zig");
