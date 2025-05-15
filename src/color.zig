pub const Color = @Vector(3, f64);

pub fn write(writer: *const std.fs.File.Writer, color: *const Color) !void {
    const r = color[0];
    const g = color[1];
    const b = color[2];

    const rbyte: c_int = @intFromFloat(255.999 * r);
    const gbyte: c_int = @intFromFloat(255.999 * g);
    const bbyte: c_int = @intFromFloat(255.999 * b);

    try writer.print("{} {} {}\n", .{ rbyte, gbyte, bbyte });
}

const std = @import("std");
