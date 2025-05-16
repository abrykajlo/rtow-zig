pub const Color = @Vector(3, f64);

pub fn write(writer: *const std.fs.File.Writer, color: *const Color) !void {
    const r = color[0];
    const g = color[1];
    const b = color[2];

    // Translate the [0,1] component values to the byte range [0,255].
    const static = struct {
        const intensity: Interval = .{ .min = 0.000, .max = 0.999 };
    };
    const rbyte: c_int = @intFromFloat(256 * static.intensity.clamp(r));
    const gbyte: c_int = @intFromFloat(256 * static.intensity.clamp(g));
    const bbyte: c_int = @intFromFloat(256 * static.intensity.clamp(b));

    try writer.print("{} {} {}\n", .{ rbyte, gbyte, bbyte });
}

const std = @import("std");

const Interval = @import("Interval.zig");
