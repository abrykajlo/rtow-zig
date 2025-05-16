const Camera = @This();

aspect_ratio: f64, // Ratio of image width over height
image_width: usize, // Rendered image width in pixel count
image_height: usize, // Rendered image height
center: Point3, // Camera center
pixel00_loc: Point3, // Location of pixel 0, 0
pixel_delta_u: Vec3, // Offset to pixel to the right
pixel_delta_v: Vec3, // Offset to pixel below
samples_per_pixel: usize, // Count of random samples for each pixel
pixels_samples_scale: f64, // Color scale factor for a sum of pixel samples

pub fn init(aspect_ratio: f64, image_width: usize, samples_per_pixel: usize) Camera {
    var cam: Camera = undefined;
    cam.aspect_ratio = aspect_ratio;
    cam.image_width = image_width;
    cam.samples_per_pixel = samples_per_pixel;

    cam.image_height = @as(f64, @floatFromInt(image_width)) / aspect_ratio;
    cam.image_height = if (cam.image_height < 1) 1 else cam.image_height;

    cam.pixels_samples_scale = 1.0 / @as(f64, @floatFromInt(cam.samples_per_pixel));

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
            var pixel_color: Color = .{ 0, 0, 0 };
            for (0..self.samples_per_pixel) |_| {
                const ray = self.getRay(i, j);
                pixel_color += @as(Color, @splat(self.pixels_samples_scale)) * rayColor(&ray, world);
            }
            try rtw.color.write(&outw, &pixel_color);
        }
    }

    std.log.info("\rDone.   \n", .{});
}

/// Construct a camera ray origination from the origin and directed at randomly sampled
/// point around the pixel location i, j
fn getRay(self: *const Camera, i: usize, j: usize) Ray {
    const offset = sampleSquare();
    const pixel_sample = self.pixel00_loc + @as(Vec3, @splat(@as(f64, @floatFromInt(i)) + offset[0])) * self.pixel_delta_u + @as(Vec3, @splat(@as(f64, @floatFromInt(j)) + offset[1])) * self.pixel_delta_v;

    return .{ .orig = self.center, .dir = pixel_sample - self.center };
}

/// Returns the vector to a random point in the [-.5,-.5]-[+.5,+.5] unit square.
fn sampleSquare() @Vector(2, f64) {
    return .{ rtw.randomDouble() - 0.5, rtw.randomDouble() - 0.5 };
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
