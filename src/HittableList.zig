const HittableList = @This();

objects: std.ArrayList(Hittable),

pub fn init(allocator: Allocator) HittableList {
    return .{
        .objects = std.ArrayList(Hittable).init(allocator),
    };
}

pub fn deinit(self: *HittableList) void {
    self.objects.deinit();
}

pub fn clear(self: *HittableList) void {
    self.objects.clearRetainingCapacity();
}

pub fn add(self: *HittableList, hittable: Hittable) !void {
    const ptr = try self.objects.addOne();
    ptr.* = hittable;
}

pub fn hit(self: *const HittableList, ray: *const Ray, ray_t: Interval) ?HitRecord {
    var temp_rec: HitRecord = undefined;
    var hit_anything = false;
    var closest_so_far = ray_t.max;

    for (self.objects.items) |object| {
        if (object.hit(ray, .{ .min = ray_t.min, .max = closest_so_far })) |rec| {
            hit_anything = true;
            closest_so_far = rec.t;
            temp_rec = rec;
        }
    }

    return if (hit_anything) temp_rec else null;
}

const std = @import("std");
const Allocator = std.mem.Allocator;

const rtw = @import("rtweekend.zig");
const Interval = rtw.Interval;
const Ray = rtw.Ray;

const Hittable = @import("hittable.zig").Hittable;
const HitRecord = @import("hittable.zig").HitRecord;
