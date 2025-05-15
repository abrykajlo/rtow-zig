const vecmath = @import("vecmath.zig");

const Ray = @import("Ray.zig");
const Vec3 = vecmath.Vec3;
const Point3 = vecmath.Point3;

const HittableList = @import("HittableList.zig");
const Sphere = @import("Sphere.zig");

pub const HitRecord = struct {
    p: Point3,
    normal: Vec3,
    t: f64,
    front_face: bool = false,

    pub fn setFaceNormal(self: *HitRecord, ray: *const Ray, outward_normal: *const Vec3) void {
        self.front_face = vecmath.dot(&ray.dir, outward_normal) < 0;
        self.normal = if (self.front_face) outward_normal.* else -outward_normal.*;
    }
};

pub const Hittable = union(enum) {
    hittable_list: *const HittableList,
    sphere: *const Sphere,

    pub fn hit(self: *const Hittable, ray: *const Ray, ray_tmin: f64, ray_tmax: f64) ?HitRecord {
        switch (self.*) {
            inline else => |h| return h.hit(ray, ray_tmin, ray_tmax),
        }
    }
};
