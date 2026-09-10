const std = @import("std");

const Camera = @import("Camera.zig");

const Hittable = @import("hittable.zig").Hittable;
const HittableList = @import("HittableList.zig");
const Sphere = @import("Sphere.zig");

const material = @import("material.zig");
const MaterialManager = material.MaterialManager;
const Material = material.Material;
const Lambertian = material.Lambertian;
const Metal = material.Metal;
const Dielectric = material.Dielectric;

const rtw = @import("rtweekend.zig");
const Vec3 = rtw.vec3.Vec3;
const Point3 = rtw.vec3.Point3;
const Ray = rtw.Ray;
const Color = rtw.color.Color;
const toFloat = rtw.toFloat;

pub fn main(init: std.process.Init) !void {
    const gpa = init.gpa;

    var world: HittableList = .{};
    defer world.deinit(gpa);

    var mat_manager: MaterialManager = .{};
    defer mat_manager.deinit(gpa);

    const ground_material = try mat_manager.create(gpa, Lambertian{ .albedo = .{ 0.5, 0.5, 0.5 } });
    try world.add(gpa, &Sphere.init(&.{ 0, -1000, 0 }, 1000, ground_material));

    var a: isize = -11;
    while (a <= 11) : (a += 1) {
        var b: isize = -11;
        while (b <= 11) : (b += 1) {
            const choose_mat = rtw.randomDouble(void{});
            const center: Point3 = .{ toFloat(a) + 0.9 * rtw.randomDouble(void{}), 0.2, toFloat(b) + 0.9 * rtw.randomDouble(void{}) };

            if (rtw.vec3.length(&(center - Point3{ 4, 0.2, 0 })) > 0.9) {
                if (choose_mat < 0.8) {
                    // diffuse
                    const albedo = rtw.vec3.random(void{}) * rtw.vec3.random(void{});
                    const sphere_material = try mat_manager.create(gpa, Lambertian{ .albedo = albedo });
                    try world.add(gpa, &Sphere.init(&center, 0.2, sphere_material));
                } else if (choose_mat < 0.95) {
                    // metal
                    const albedo = rtw.vec3.random(.{ .min = 0.5, .max = 1 });
                    const fuzz = rtw.randomDouble(.{ .min = 0, .max = 0.5 });
                    const sphere_material = try mat_manager.create(gpa, Metal{ .albedo = albedo, .fuzz = fuzz });
                    try world.add(gpa, &Sphere.init(&center, 0.2, sphere_material));
                } else {
                    // glass
                    const sphere_material = try mat_manager.create(gpa, Dielectric{ .refraction_index = 1.5 });
                    try world.add(gpa, &Sphere.init(&center, 0.2, sphere_material));
                }
            }
        }
    }

    const material1 = try mat_manager.create(gpa, Dielectric{ .refraction_index = 1.5 });
    try world.add(gpa, &Sphere.init(&.{ 0, 1, 0 }, 1.0, material1));

    const material2 = try mat_manager.create(gpa, Lambertian{ .albedo = .{ 0.4, 0.2, 0.1 } });
    try world.add(gpa, &Sphere.init(&.{ -4, 1, 0 }, 1.0, material2));

    const material3 = try mat_manager.create(gpa, Metal{ .albedo = .{ 0.7, 0.6, 0.5 }, .fuzz = 0.0 });
    try world.add(gpa, &Sphere.init(&.{ 4, 1, 0 }, 1.0, material3));

    var cam = comptime Camera.init(.{
        .aspect_ratio = 16.0 / 9.0,
        .image_width = 1200,
        .samples_per_pixel = 500,
        .max_depth = 50,
        .vfov = 20,
        .lookfrom = .{ 13, 2, 3 },
        .lookat = .{ 0, 0, 0 },
        .vup = .{ 0, 1, 0 },
        .defocus_angle = 0.6,
        .focus_dist = 10.0,
    });

    var buf: [128]u8 = undefined;
    var stdout_writer = std.Io.File.stdout().writer(init.io, &buf);
    try cam.render(gpa, init.io, &stdout_writer.interface, .{ .hittable_list = &world });
}
