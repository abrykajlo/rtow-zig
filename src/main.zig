pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{ .verbose_log = true }){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var world = HittableList.init(allocator);
    defer world.deinit();

    const material_ground = try material.create(allocator, Lambertian, .{ .albedo = .{ 0.8, 0.8, 0.0 } });
    defer material.destroy(allocator, Lambertian, material_ground);

    const material_center = try material.create(allocator, Lambertian, .{ .albedo = .{ 0.1, 0.2, 0.5 } });
    defer material.destroy(allocator, Lambertian, material_center);

    const material_left = try material.create(allocator, Dielectric, .{ .refraction_index = 1.50 });
    defer material.destroy(allocator, Dielectric, material_left);

    const material_bubble = try material.create(allocator, Dielectric, .{ .refraction_index = 1.00 / 1.50 });
    defer material.destroy(allocator, Dielectric, material_bubble);

    const material_right = try material.create(allocator, Metal, .{ .albedo = .{ 0.8, 0.6, 0.2 }, .fuzz = 1.0 });
    defer material.destroy(allocator, Metal, material_right);

    try world.add(.{ .sphere = &.init(&.{ 0.0, -100.5, -1.0 }, 100.0, material_ground) });
    try world.add(.{ .sphere = &.init(&.{ 0.0, 0.0, -1.2 }, 0.5, material_center) });
    try world.add(.{ .sphere = &.init(&.{ -1.0, 0.0, -1.0 }, 0.5, material_left) });
    try world.add(.{ .sphere = &.init(&.{ -1.0, 0.0, -1.0 }, 0.4, material_bubble) });
    try world.add(.{ .sphere = &.init(&.{ 1.0, 0.0, -1.0 }, 0.5, material_right) });

    var cam = comptime Camera.init(.{
        .aspect_ratio = 16.0 / 9.0,
        .image_width = 400,
        .samples_per_pixel = 100,
        .max_depth = 50,
        .vfov = 20,
        .lookfrom = .{ -2, 2, 1 },
        .lookat = .{ 0, 0, -1 },
        .vup = .{ 0, 1, 0 },
        .defocus_angle = 10,
        .focus_dist = 3.4,
    });

    try cam.render(.{ .hittable_list = &world });
}

const std = @import("std");

const Camera = @import("Camera.zig");

const Hittable = @import("hittable.zig").Hittable;
const HittableList = @import("HittableList.zig");
const Sphere = @import("Sphere.zig");

const material = @import("material.zig");
const Material = material.Material;
const Lambertian = material.Lambertian;
const Metal = material.Metal;
const Dielectric = material.Dielectric;

const rtw = @import("rtweekend.zig");
const Vec3 = rtw.vec3.Vec3;
const Point3 = rtw.vec3.Point3;
const Ray = rtw.Ray;
const Color = rtw.color.Color;
