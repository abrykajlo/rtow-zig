const std = @import("std");

const c = @import("color.zig");
const r = @import("ray.zig");
const v = @import("vec3.zig");

fn rayColor(ray: *const r.Ray) c.Color {
    const unit_direction = v.unitVector(&ray.dir);
    const a = 0.5 * (unit_direction[1] + 1.0);
    return @as(v.Vec3, @splat(1.0 - a)) * c.Color{ 1.0, 1.0, 1.0 } + @as(v.Vec3, @splat(a)) * c.Color{ 0.5, 0.7, 1.0 };
}

pub fn main() !void {
    const outw = std.io.getStdOut().writer();

    // Image

    const aspect_ratio = 16.0 / 9.0;
    const image_width = 400;

    // Calculate the image height, and ensure that it's at least 1
    var image_height: usize = @as(f64, @floatFromInt(image_width)) / aspect_ratio;
    image_height = if (image_height < 1) 1 else image_height;

    // Camera

    const focal_length = 1.0;
    const viewport_height = 2.0;
    const viewport_width = viewport_height * image_width / @as(f64, @floatFromInt(image_height));
    const camera_center: v.Point3 = .{ 0, 0, 0 };

    // Calculate the vectors across the horizontal and down the vertical viewport edges.
    const viewport_u: v.Vec3 = .{ viewport_width, 0, 0 };
    const viewport_v: v.Vec3 = .{ 0, -viewport_height, 0 };

    // Calculate the horizontal and vertical delta vectors from pixel to pixel.
    const pixel_delta_u = viewport_u / @as(v.Vec3, @splat(@as(f64, @floatFromInt(image_width))));
    const pixel_delta_v = viewport_v / @as(v.Vec3, @splat(@as(f64, @floatFromInt(image_height))));

    // Calculate the location of the upper left pixel.
    const viewport_upper_left = camera_center - v.Vec3{ 0, 0, focal_length } - viewport_u / @as(v.Vec3, @splat(2.0)) - viewport_v / @as(v.Vec3, @splat(2.0));
    const pixel00_loc = viewport_upper_left + @as(v.Vec3, @splat(0.5)) * (pixel_delta_u + pixel_delta_v);

    // Render

    try outw.print("P3\n{} {}\n255\n", .{ image_width, image_height });
    for (0..image_height) |j| {
        std.log.info("\rScanlines remaining: {}", .{image_height - j});
        for (0..image_width) |i| {
            const pixel_center = pixel00_loc + (@as(v.Vec3, @splat(@as(f64, @floatFromInt(i)))) * pixel_delta_u) + (@as(v.Vec3, @splat(@as(f64, @floatFromInt(j)))) * pixel_delta_v);
            const ray_direction = pixel_center - camera_center;
            const ray: r.Ray = .{ .orig = camera_center, .dir = ray_direction };

            const pixel_color = rayColor(&ray);
            try c.writeColor(&outw, &pixel_color);
        }
    }

    std.log.info("\rDone.   \n", .{});
}
