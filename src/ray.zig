const v = @import("vec3.zig");

pub const Ray = struct {
    orig: v.Point3,
    dir: v.Vec3,

    fn at(self: *const Ray, t: f64) v.Point3 {
        return self.orig + t * self.dir;
    }
};
