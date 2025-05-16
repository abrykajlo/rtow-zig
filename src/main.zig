pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{ .verbose_log = true }){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var world = HittableList.init(allocator);
    defer world.deinit();

    try world.add(.{ .sphere = &.init(&.{ 0, 0, -1 }, 0.5) });
    try world.add(.{ .sphere = &.init(&.{ 0, -100.5, -1 }, 100) });

    var cam = comptime Camera.init(16.0 / 9.0, 400, 100, 50);

    try cam.render(.{ .hittable_list = &world });
}

const std = @import("std");

const Camera = @import("Camera.zig");

const Hittable = @import("hittable.zig").Hittable;
const HittableList = @import("HittableList.zig");
const Sphere = @import("Sphere.zig");

const rtw = @import("rtweekend.zig");
const Vec3 = rtw.vec3.Vec3;
const Point3 = rtw.vec3.Point3;
const Ray = rtw.Ray;
const Color = rtw.color.Color;
