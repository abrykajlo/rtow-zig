const vecmath = @import("vecmath.zig");

const Point3 = vecmath.Point3;
const Vec3 = vecmath.Vec3;

orig: Point3,
dir: Vec3,

pub fn at(self: *const @This(), t: f64) Point3 {
    return self.orig + @as(Vec3, @splat(t)) * self.dir;
}
