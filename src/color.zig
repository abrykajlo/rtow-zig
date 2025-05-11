const std = @import("std");
const v = @import("vec3.zig");

pub const color = v.vec3;

pub fn writeColor(writer: *const std.fs.File.Writer, pixel_color: *const color) !void {
    const r = pixel_color[0];
    const g = pixel_color[1];
    const b = pixel_color[2];

    const rbyte: c_int = @intFromFloat(255.999 * r);
    const gbyte: c_int = @intFromFloat(255.999 * g);
    const bbyte: c_int = @intFromFloat(255.999 * b);

    try writer.print("{} {} {}\n", .{ rbyte, gbyte, bbyte });
}
