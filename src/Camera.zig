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
max_depth: usize, // Maximum number of ray bounces into scene

vfov: f64, // Vertical view angle (field of view)
lookfrom: Point3, // Point camera is looking from
lookat: Point3, // Point camera is looking at
vup: Vec3, // Camera-relative "up" direction

// Camera frame basis vectors
u: Vec3,
v: Vec3,
w: Vec3,

pub fn init(in: Init) Camera {
    var cam: Camera = undefined;
    cam.aspect_ratio = in.aspect_ratio;
    cam.image_width = in.image_width;
    cam.samples_per_pixel = in.samples_per_pixel;
    cam.max_depth = in.max_depth;
    cam.vfov = in.vfov;
    cam.lookfrom = in.lookfrom;
    cam.lookat = in.lookat;
    cam.vup = in.vup;

    cam.image_height = rtw.toFloat(in.image_width) / in.aspect_ratio;
    cam.image_height = if (cam.image_height < 1) 1 else cam.image_height;

    cam.pixels_samples_scale = 1.0 / toFloat(cam.samples_per_pixel);

    cam.center = cam.lookfrom;

    // Determine viewport dimensions.
    const focal_length = rtw.vec3.length(&(cam.lookfrom - cam.lookat));
    const theta = rtw.degreesToRadians(in.vfov);
    const h = @tan(theta / 2.0);
    const viewport_height = 2.0 * h * focal_length;
    const viewport_width = viewport_height * toFloat(cam.image_width) / toFloat(cam.image_height);

    // Calculate the u,v,w unit basis vectors for the camera coordinate frame.
    cam.w = rtw.vec3.unitVector(&(in.lookfrom - in.lookat));
    cam.u = rtw.vec3.unitVector(&rtw.vec3.cross(&cam.vup, &cam.w));
    cam.v = rtw.vec3.cross(&cam.w, &cam.u);

    // Calculate the vectors across the horizontal and down the vertical viewport edges.
    const viewport_u: Vec3 = toVec3(viewport_width) * cam.u; // Vector across viewport horizontal edge
    const viewport_v: Vec3 = toVec3(viewport_height) * -cam.v; // Vector down viewport vertical edge

    // Calculate the horizontal and vertical delta vectors from pixel to pixel.
    cam.pixel_delta_u = viewport_u / toVec3(cam.image_width);
    cam.pixel_delta_v = viewport_v / toVec3(cam.image_height);

    // Calculate the location of the upper left pixel.
    const viewport_upper_left = cam.center - toVec3(focal_length) * cam.w - viewport_u / toVec3(2.0) - viewport_v / toVec3(2.0);
    cam.pixel00_loc = viewport_upper_left + toVec3(0.5) * (cam.pixel_delta_u + cam.pixel_delta_v);

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
                pixel_color += toVec3(self.pixels_samples_scale) * rayColor(&ray, self.max_depth, world);
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
    const pixel_sample = self.pixel00_loc + toVec3(toFloat(i) + offset[0]) * self.pixel_delta_u + toVec3(toFloat(j) + offset[1]) * self.pixel_delta_v;

    return .{ .orig = self.center, .dir = pixel_sample - self.center };
}

/// Returns the vector to a random point in the [-.5,-.5]-[+.5,+.5] unit square.
fn sampleSquare() @Vector(2, f64) {
    return .{ rtw.randomDouble(void{}) - 0.5, rtw.randomDouble(void{}) - 0.5 };
}

fn rayColor(ray: *const Ray, depth: usize, world: Hittable) Color {
    if (depth <= 0)
        return .{ 0, 0, 0 };

    if (world.hit(ray, .{ .min = 0.001, .max = rtw.infinity })) |rec| {
        var scattered: Ray = undefined;
        var attenuation: Color = undefined;
        if (rec.mat.scatter(ray, &rec, &attenuation, &scattered))
            return attenuation * rayColor(&scattered, depth - 1, world);
        return .{ 0, 0, 0 };
    }

    const unit_direction = rtw.vec3.unitVector(&ray.dir);
    const a = 0.5 * (unit_direction[1] + 1.0);
    return toVec3(1.0 - a) * Color{ 1.0, 1.0, 1.0 } + toVec3(a) * Color{ 0.5, 0.7, 1.0 };
}

const Init = struct {
    aspect_ratio: f64 = 1.0,
    image_width: usize = 100,
    samples_per_pixel: usize = 10,
    max_depth: usize = 10,
    vfov: f64 = 90,
    lookfrom: Point3 = .{ 0, 0, 0 },
    lookat: Point3 = .{ 0, 0, -1 },
    vup: Vec3 = .{ 0, 1, 0 },
};

const std = @import("std");

const Hittable = @import("hittable.zig").Hittable;

const rtw = @import("rtweekend.zig");
const Color = rtw.color.Color;
const Ray = rtw.Ray;
const toFloat = rtw.toFloat;
const Point3 = rtw.vec3.Point3;
const Vec3 = rtw.vec3.Vec3;
const toVec3 = rtw.vec3.toVec3;
