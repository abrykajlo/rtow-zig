const Camera = @This();

aspect_ratio: f64, // Ratio of image width over height
image_width: usize, // Rendered image width in pixel count
image_height: usize, // Rendered image height
center: Point3, // Camera center
pixel00_loc: Point3, // Location of pixel 0, 0
pixel_delta_u: Vec3, // Offset to pixel to the right
pixel_delta_v: Vec3, // Offset to pixel below

pub fn init(aspect_ratio: f64, image_width: usize) Camera {
    var cam: Camera = undefined;
    cam.aspect_ratio = aspect_ratio;
    cam.image_width = image_width;

    cam.image_height = @as(f64, @floatFromInt(image_width)) / aspect_ratio;
    cam.image_height = if (cam.image_height < 1) 1 else cam.image_height;

    cam.center = .{ 0, 0, 0 };

    // Determine viewport dimensions.
    const focal_length = 1.0;
    const viewport_height = 2.0;
    const viewport_width = viewport_height * @as(f64, @floatFromInt(cam.image_width)) / @as(f64, @floatFromInt(cam.image_height));

    // Calculate the vectors across the horizontal and down the vertical viewport edges.
    const viewport_u: Vec3 = .{ viewport_width, 0, 0 };
    const viewport_v: Vec3 = .{ 0, -viewport_height, 0 };

    // Calculate the horizontal and vertical delta vectors from pixel to pixel.
    cam.pixel_delta_u = viewport_u / @as(Vec3, @splat(@floatFromInt(cam.image_width)));
    cam.pixel_delta_v = viewport_v / @as(Vec3, @splat(@floatFromInt(cam.image_height)));

    // Calculate the location of the upper left pixel.
    const viewport_upper_left = cam.center - Vec3{ 0, 0, focal_length } - viewport_u / @as(Vec3, @splat(2.0)) - viewport_v / @as(Vec3, @splat(2.0));
    cam.pixel00_loc = viewport_upper_left + @as(Vec3, @splat(0.5)) * (cam.pixel_delta_u + cam.pixel_delta_v);

    return cam;
}

pub fn render(self: *Camera, world: Hittable) !void {
    const outw = std.io.getStdOut().writer();

    try outw.print("P3\n{} {}\n255\n", .{ self.image_width, self.image_height });
    for (0..self.image_height) |j| {
        std.log.info("\rScanlines remaining: {}", .{self.image_height - j});
        for (0..self.image_width) |i| {
            const pixel_center = self.pixel00_loc + (@as(Vec3, @splat(@as(f64, @floatFromInt(i)))) * self.pixel_delta_u) + (@as(Vec3, @splat(@as(f64, @floatFromInt(j)))) * self.pixel_delta_v);
            const ray_direction = pixel_center - self.center;
            const ray: Ray = .{ .orig = self.center, .dir = ray_direction };

            const pixel_color = rayColor(&ray, world);
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

const rtw = @import("rtweekend.zig");
const Color = rtw.color.Color;
const Ray = rtw.Ray;
const Point3 = rtw.vec3.Point3;
const Vec3 = rtw.vec3.Vec3;
