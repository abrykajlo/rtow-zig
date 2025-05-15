pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{ .verbose_log = true }){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const outw = std.io.getStdOut().writer();

    // Image

    const aspect_ratio = 16.0 / 9.0;
    const image_width = 400;

    // Calculate the image height, and ensure that it's at least 1
    var image_height: usize = @as(f64, @floatFromInt(image_width)) / aspect_ratio;
    image_height = if (image_height < 1) 1 else image_height;

    // World

    var world = HittableList.init(allocator);
    defer world.deinit();

    try world.add(.{ .sphere = &Sphere.init(&.{ 0, 0, -1 }, 0.5) });
    try world.add(.{ .sphere = &Sphere.init(&.{ 0, -100.5, -1 }, 100) });

    // Camera

    const focal_length = 1.0;
    const viewport_height = 2.0;
    const viewport_width = viewport_height * image_width / @as(f64, @floatFromInt(image_height));
    const camera_center: Point3 = .{ 0, 0, 0 };

    // Calculate the vectors across the horizontal and down the vertical viewport edges.
    const viewport_u: Vec3 = .{ viewport_width, 0, 0 };
    const viewport_v: Vec3 = .{ 0, -viewport_height, 0 };

    // Calculate the horizontal and vertical delta vectors from pixel to pixel.
    const pixel_delta_u = viewport_u / @as(Vec3, @splat(@floatFromInt(image_width)));
    const pixel_delta_v = viewport_v / @as(Vec3, @splat(@floatFromInt(image_height)));

    // Calculate the location of the upper left pixel.
    const viewport_upper_left = camera_center - Vec3{ 0, 0, focal_length } - viewport_u / @as(Vec3, @splat(2.0)) - viewport_v / @as(Vec3, @splat(2.0));
    const pixel00_loc = viewport_upper_left + @as(Vec3, @splat(0.5)) * (pixel_delta_u + pixel_delta_v);

    // Render

    try outw.print("P3\n{} {}\n255\n", .{ image_width, image_height });
    for (0..image_height) |j| {
        std.log.info("\rScanlines remaining: {}", .{image_height - j});
        for (0..image_width) |i| {
            const pixel_center = pixel00_loc + (@as(Vec3, @splat(@as(f64, @floatFromInt(i)))) * pixel_delta_u) + (@as(Vec3, @splat(@as(f64, @floatFromInt(j)))) * pixel_delta_v);
            const ray_direction = pixel_center - camera_center;
            const ray: Ray = .{ .orig = camera_center, .dir = ray_direction };

            const pixel_color = rayColor(&ray, .{ .hittable_list = &world });
            try rtw.color.write(&outw, &pixel_color);
        }
    }

    std.log.info("\rDone.   \n", .{});
}

fn rayColor(ray: *const Ray, world: Hittable) Color {
    if (world.hit(ray, .{ .min = 0, .max = rtw.infinity })) |rec| {
        return @as(Vec3, @splat(0.5)) * (rec.normal + Color{ 1, 1, 1 });
    }

    const unit_direction = rtw.vec3.unitVector(&ray.dir);
    const a = 0.5 * (unit_direction[1] + 1.0);
    return @as(Vec3, @splat(1.0 - a)) * Color{ 1.0, 1.0, 1.0 } + @as(Vec3, @splat(a)) * Color{ 0.5, 0.7, 1.0 };
}

const std = @import("std");

const Hittable = @import("hittable.zig").Hittable;
const HittableList = @import("HittableList.zig");
const Sphere = @import("Sphere.zig");

const rtw = @import("rtweekend.zig");
const Vec3 = rtw.vec3.Vec3;
const Point3 = rtw.vec3.Point3;
const Ray = rtw.Ray;
const Color = rtw.color.Color;
