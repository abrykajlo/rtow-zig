const std = @import("std");

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
            const r: f64 = @as(f64, @floatFromInt(i)) / (image_width - 1);
            const g = @as(f64, @floatFromInt(j)) / (image_height - 1);
            const b = 0.0;

            const ir: c_int = @intFromFloat(255.999 * r);
            const ig: c_int = @intFromFloat(255.999 * g);
            const ib: c_int = @intFromFloat(255.999 * b);

            try outw.print("{} {} {}\n", .{ ir, ig, ib });
        }
    }
}
