const vecmath = @import("vecmath.zig");
const hittable = @import("hittable.zig");

const Ray = @import("Ray.zig");
const Point3 = vecmath.Point3;

const Sphere = @This();

center: Point3,
radius: f64,

pub fn init(center: *const Point3, radius: f64) @This() {
    return .{ .center = center.*, .radius = @max(0, radius) };
}

pub fn hit(self: *const Sphere, ray: *const Ray, ray_tmin: f64, ray_tmax: f64) ?hittable.HitRecord {
    const oc = self.center.* - ray.orig;
    const a = vecmath.lengthSquared(&ray.dir);
    const h = vecmath.dot(&ray.dir, &oc);
    const c = vecmath.lengthSquared(&oc) - self.radius * self.radius;
    const discriminant = h * h - a * c;

    if (discriminant < 0) {
        return .null;
    }

    const sqrtd = @sqrt(discriminant);

    // Find the nearest root that lies in the acceptable range.
    var root = (h - sqrtd) / a;
    if (root <= ray_tmin or ray_tmax <= root) {
        root = (h + sqrtd) / a;
        if (root <= ray_tmin or ray_tmax <= root)
            return .null;
    }

    var rec: hittable.HitRecord = undefined;
    rec.t = root;
    rec.p = ray.at(rec.t);
    const outward_normal = (.p - self.center) / @as(Point3, @splat(self.radius));
    rec.setFaceNormal(ray, &outward_normal);

    return rec;
}
