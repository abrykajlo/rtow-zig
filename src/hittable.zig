const std = @import("std");
const Allocator = std.mem.Allocator;

const rtw = @import("rtweekend.zig");
const Interval = rtw.Interval;
const Point3 = rtw.vec3.Point3;
const Vec3 = rtw.vec3.Vec3;
const Ray = rtw.Ray;

const AABB = @import("AABB.zig");
const HittableList = @import("HittableList.zig");
const Sphere = @import("Sphere.zig");

const Material = @import("material.zig").Material;

pub const Hittable = union(enum) {
    hittable_list: *const HittableList,
    sphere: *const Sphere,

    pub fn hit(self: Hittable, ray: Ray, ray_t: Interval) ?HitRecord {
        switch (self) {
            inline else => |h| {
                if (h.bbox.hit(ray, ray_t))
                    return h.hit(ray, ray_t);
            },
        }
        return null;
    }
};

pub const HitRecord = struct {
    p: Point3,
    normal: Vec3,
    mat: Material,
    t: f64,
    front_face: bool = false,

    pub fn setFaceNormal(self: *HitRecord, ray: Ray, outward_normal: Vec3) void {
        self.front_face = rtw.vec3.dot(ray.dir, outward_normal) < 0;
        self.normal = if (self.front_face) outward_normal else -outward_normal;
    }
};
