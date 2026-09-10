const Sphere = @This();

const std = @import("std");
const Allocator = std.mem.Allocator;

const hittable = @import("hittable.zig");

const rtw = @import("rtweekend.zig");
const Interval = rtw.Interval;
const Point3 = rtw.vec3.Point3;
const Ray = rtw.Ray;
const toVec3 = rtw.vec3.toVec3;
const AABB = @import("AABB.zig");

const Material = @import("material.zig").Material;

center: Point3,
radius: f64,
mat: Material,
bbox: AABB,

pub fn init(center: Point3, radius: f64, mat: Material) Sphere {
    return .{
        .center = center,
        .radius = @max(0, radius),
        .mat = mat,
        .bbox = .init(@as(Point3, @splat(radius)) + center, @as(Point3, @splat(-radius)) + center),
    };
}

pub fn hit(self: Sphere, ray: Ray, ray_t: Interval) ?hittable.HitRecord {
    const oc = self.center - ray.orig;
    const a = rtw.vec3.lengthSquared(ray.dir);
    const h = rtw.vec3.dot(ray.dir, oc);
    const c = rtw.vec3.lengthSquared(oc) - self.radius * self.radius;
    const discriminant = h * h - a * c;

    if (discriminant < 0) {
        return null;
    }

    const sqrtd = @sqrt(discriminant);

    // Find the nearest root that lies in the acceptable range.
    var root = (h - sqrtd) / a;
    if (!ray_t.surrounds(root)) {
        root = (h + sqrtd) / a;
        if (!ray_t.surrounds(root))
            return null;
    }

    var rec: hittable.HitRecord = undefined;
    rec.t = root;
    rec.p = ray.at(rec.t);
    const outward_normal = (rec.p - self.center) / toVec3(self.radius);
    rec.setFaceNormal(ray, outward_normal);
    rec.mat = self.mat;

    return rec;
}
