const std = @import("std");

const c = @import("color.zig");
const v = @import("vec3.zig");

pub fn main() !void {
    const outw = std.io.getStdOut().writer();

    // Image

    const image_width = 256;
    const image_height = 256;

    // Render

    try outw.print("P3\n{} {}\n255\n", .{ image_width, image_height });
    for (0..image_height) |j| {
        std.log.info("\rScanlines remaining: {}", .{image_height - j});
        for (0..image_width) |i| {
            const pixel_color: c.color = .{ @as(f64, @floatFromInt(i)) / (image_width - 1), @as(f64, @floatFromInt(j)) / (image_height - 1), 0.0 };
            try c.writeColor(&outw, &pixel_color);
        }
    }
}
